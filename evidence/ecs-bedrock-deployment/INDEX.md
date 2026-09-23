# Evidence: ECS/Bedrock deployment, live inference, and a bad-release lab

Two labs run against the deployed [`aws-ecs-bedrock-devsecops`](https://github.com/TreyWright360/aws-ecs-bedrock-devsecops) stack.

## Setup note: the deploy pipeline only pushes an image

`deploy-production.yml` builds, scans, and pushes the image to ECR — it does not run `terraform apply` at all, matching what the repository's own CASE-STUDY already stated. The ECS cluster, service, task definition, IAM roles, and security group were applied directly (`terraform apply`, 12 resources, 0 errors) since there is no CI path for infrastructure in this repo. That gap is real and worth closing, not something this lab worked around silently.

## 1. Live deployment and Bedrock model-access finding

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Model ID fix | `anthropic.claude-3-5-haiku-20241022-v1:0` (the repo's original default) has reached end of life — confirmed via `bedrock get-foundation-model`. Its replacement also requires a cross-region **inference profile ID**, not the bare model ID, for on-demand `InvokeModel`/`Converse` calls — confirmed by testing both directly. Updated to `us.anthropic.claude-haiku-4-5-20251001-v1:0` in the app, Terraform, and README. |
| `/health` | `HTTP 200`, `{"status":"healthy", ..., "default_model":"us.anthropic.claude-haiku-4-5-20251001-v1:0"}` — genuinely live, public IP `54.81.194.252` / `98.80.65.236` across task cycles. |
| `/api/analyze` finding | Returns `HTTP 200` with `"source":"simulation-fallback"` — **not** a real model response. Root cause found in CloudWatch logs: `ResourceNotFoundException: Model use case details have not been submitted for this account. Fill out the Anthropic use case details form before using the model.` Reproduced independently with admin credentials via `aws bedrock-runtime converse` — a genuine AWS/Anthropic account-level requirement, not an app bug. Raw `InvokeModel` (tested separately via CLI) already worked, since it doesn't require this form. |
| Why this matters | This is a real, unstaged instance of the exact failure mode the project's own case study predicted: Bedrock access not fully provisioned, `/health` stays green throughout (it never calls Bedrock), and the caller gets a plausible-looking canned response with `HTTP 200` and no indication anything failed. The app's own error handling (`except Exception: # fall back`) hides the failure entirely from the API response — only visible in server-side logs. |
| Fix required (not applied here) | Submitting the Anthropic use-case-details form in the Bedrock console is a manual, account-holder action — outside what Terraform or the CLI can do. Documented as a known gap rather than worked around. |

## 2. Bad release / no circuit breaker (found and fixed as I went)

| Field | Record |
| --- | --- |
| Setup | Built a container that starts and immediately `sys.exit(1)`s, pushed it to ECR as `:latest` — the exact tag the task definition always references, and the exact scenario the repo's own case study names as unhandled ("no circuit breaker"). |
| Two build issues found along the way | (1) A locally-built arm64 image failed to pull on Fargate (`CannotPullContainerError: ... does not contain descriptor matching platform 'linux/amd64'`) — real evidence that architecture mismatches are a genuine deploy failure mode. (2) After rebuilding for `linux/amd64` via buildx, the pull *still* failed the same way — buildx's default provenance/SBOM attestation added a manifest-list entry with `platform: unknown/unknown` that Fargate's manifest selection couldn't handle. Fixed with `--provenance=false --sbom=false`. |
| Failure injection | 23:10:55Z — forced a new deployment with the clean-manifest broken image |
| Observed | New task reached `RUNNING`, its container exited with code 1 within ~10s, task moved to `DEPROVISIONING`. The **old, good task was never replaced** — `desiredCount:1, runningCount:1` throughout, and `curl /health` returned `200` continuously during the failure. |
| The actual bug | ECS then entered a genuine, unbounded retry loop: `rolloutState: IN_PROGRESS` indefinitely, `pendingCount:1, runningCount:0` for the *deployment*, spawning a new crashing task every few seconds (`d8051d8a...`, `0b689a52...`, ...) with no `deployment_circuit_breaker` configured to stop it. This matches "no circuit breaker" exactly — except the nuance the case study didn't have evidence for: **zero user-facing downtime**, because the default rolling-deployment minimum-healthy-percent kept the last good task alive the whole time. The real cost of this bug is wasted Fargate minutes on an infinite retry, not an outage. |
| Recovery | 23:11:50Z — restored `:latest` to the known-good image digest via `aws ecr put-image` (no rebuild needed, since the good image was also tagged with its git SHA), then forced a clean deployment. |
| Validation | 23:14:51Z — deployment `rolloutState: COMPLETED`, `runningCount:1`, and a direct `curl /health` against the new task returned `200` with the correct model ID. |
| Limits | One crash-on-start scenario tested, not a slow-degrading or partially-healthy release. `deployment_circuit_breaker` was not added to the Terraform as part of this lab — the finding is documented, not yet fixed in code. |

## Teardown

Broken image artifacts remain in ECR (still useful for a future circuit-breaker fix/demo); the good `:latest` tag is restored and the service is healthy. The stack itself remains running as of this evidence record.
