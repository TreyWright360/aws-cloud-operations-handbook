# Video 3: The Safe Deployment Workflow

> **Platform:** LinkedIn Video / YouTube
> **Duration:** 2–3 minutes
> **Target Audience:** DevOps/platform hiring managers evaluating CI/CD judgment, not just AWS knowledge
> **Pattern demonstrated across:** all 4 deployable repos (Multi-AZ, IAM Governance, DataOps, ECS/Bedrock)

---

## 0:00–0:20 — Hook
- **Visual:** GitHub Actions tab, a workflow run that's paused waiting on approval — yellow "Waiting" state on the `production` environment.
- **Say this:**
  > "Every one of these repos can push to AWS from CI — but none of them can do it by accident. Here's the pattern I used everywhere, and why."

## 0:20–0:55 — OIDC over static keys
- **Visual:** Open `.github/workflows/deploy-production.yml`, highlight `permissions: id-token: write` and the `role-to-assume` step.
- **Say this:**
  > "No long-lived AWS access keys stored in GitHub secrets anywhere in this portfolio. Every workflow assumes a role via OpenID Connect — GitHub issues a short-lived token, AWS trusts it based on a scoped trust policy, and the credentials expire when the job ends."
- **Show on screen:** the IAM role's trust policy — the `sub` condition scoped to `repo:TreyWright360/REPO:environment:production`.
- **Say this (cont.):**
  > "That trust policy is scoped down to one specific repo and one specific environment — not 'any workflow in my org can assume this.'"

## 0:55–1:30 — The manual gate
- **Visual:** GitHub repo Settings → Environments → `production`, showing "Required reviewers" enabled.
- **Say this:**
  > "On top of that, pushing to `main` never touches AWS by itself — it only runs lint, tests, and a container scan. Actually deploying requires manually triggering a `workflow_dispatch` and a human approval on a protected environment. I added that after thinking about what 'push to main' should and shouldn't be allowed to do."
- **Show on screen:** the approval click itself — "Approve and deploy" button, then the job unblocking.

## 1:30–2:00 — The honest gap
- **Visual:** Open `aws-ecs-bedrock-devsecops/CASE-STUDY.md`, the line: "it does not apply Terraform at all — the cluster, service, task definition... were applied directly, outside CI."
- **Say this:**
  > "I'm not going to pretend this is fully mature. In the ECS project, the deploy workflow only pushes a container image to ECR — it doesn't apply Terraform or update the running service. I applied that infrastructure by hand and documented that gap instead of hiding it. Closing it — wiring `terraform apply` and an ECS service update into the same gated workflow — is the next thing I'd build."

## 2:00–2:20 — Close
- **Visual:** Fast cut across all 4 repos' `deploy-production.yml` files, same OIDC block visible in each.
- **Say this:**
  > "Same pattern, four repos: no static keys, scoped trust, and a human in the loop before anything touches production."

---

## Production notes
- The "honest gap" beat (1:30–2:00) is the most important 30 seconds in this video — it's what separates this from marketing copy. Don't cut it for time.
- If time is tight, cut the OIDC trust-policy JSON zoom (0:35–0:45) before cutting the honest-gap beat.
