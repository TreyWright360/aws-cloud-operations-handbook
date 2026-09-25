# Video 7: Containerized GenAI Microservice (ECS/Bedrock) Deep Dive

> **Platform:** YouTube (long-form) / LinkedIn (cut down)
> **Duration:** 4–6 minutes
> **Repo:** [aws-ecs-bedrock-devsecops](https://github.com/TreyWright360/aws-ecs-bedrock-devsecops)
> **Evidence:** [evidence/ecs-bedrock-deployment/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/ecs-bedrock-deployment/INDEX.md)

---

## 0:00–0:20 — Hook
- **Visual:** `curl /health` returning `{"status":"healthy"}`, then `curl /api/analyze` returning a plausible-looking response.
- **Say this:**
  > "Both of these calls return success. Only one of them is actually calling the AI model. This video is about the gap between 'the health check is green' and 'the feature works' — and I found a real instance of it in my own deployment."

## 0:20–1:00 — What's deployed
- **Visual:** Architecture diagram — FastAPI in Docker, ECS Fargate, IAM task role, Bedrock.
- **Say this:**
  > "A document-analysis API on ECS Fargate, calling Amazon Bedrock through an IAM task role — no static credentials in the container. Deployed live, `/health` confirmed genuinely up across task cycles with two different public IPs."

## 1:00–1:40 — The model ID problem
- **Visual:** `aws bedrock get-foundation-model` output showing end-of-life status.
- **Say this:**
  > "First problem: the model I'd originally wired up had reached end of life. Its replacement needed something I hadn't used before — a cross-region inference profile ID, not the bare model ID — for on-demand calls. I confirmed that by testing both directly against the API rather than trusting documentation."

## 1:40–2:50 — The silent-fallback finding
- **Visual:** `/api/analyze` request/response side by side with CloudWatch logs open.
- **Say this:**
  > "Here's the real finding. Calling `/api/analyze` returns `HTTP 200` with a plausible summary — but the response says `\"source\":\"simulation-fallback\"`. The actual Bedrock call was being rejected the whole time."
- **Show on screen:** CloudWatch log line: `ResourceNotFoundException: Model use case details have not been submitted for this account.`
- **Say this (cont.):**
  > "That's a genuine AWS account-level requirement — Anthropic requires a use-case form for this model family, separate from IAM permissions entirely. I reproduced it independently with admin credentials to confirm it wasn't an app bug. The app's own error handling swallows the exception and falls back to canned text — which means the failure is completely invisible unless you're reading server-side logs."

## 2:50–3:30 — Why this matters
- **Visual:** `/health` endpoint code — no Bedrock call in the health check.
- **Say this:**
  > "This is exactly the failure mode this project's own documentation predicted before I ran the test: a health check that only checks the process is up, not that the feature actually works. Monitoring stays green, users get a wrong answer with a 200 status code."

## 3:30–4:30 — Bad release / no circuit breaker lab
- **Visual:** A container built to crash on start, pushed as `:latest`; ECS console showing the deployment.
- **Say this:**
  > "Second lab: I pushed a deliberately broken image as `:latest` — the tag the task definition always pulls. Along the way I hit two real Docker build issues — an arm64/amd64 platform mismatch, then a Buildx provenance attestation that broke Fargate's image pull even after fixing the platform. Once the image was clean, the new task crashed on start, and ECS kept retrying it forever — no circuit breaker configured to stop the loop."
- **Show on screen:** ECS deployment stuck at `rolloutState: IN_PROGRESS`, spawning new crashing tasks every few seconds.

## 4:30–5:00 — The nuance
- **Visual:** `curl /health` during the incident, still returning 200.
- **Say this:**
  > "But here's the specific nuance my case study didn't have evidence for until I ran this: zero user-facing downtime. The old, good task was never replaced, because the default rolling-deployment settings kept it alive the whole time. The real cost of this bug is wasted compute on an infinite retry loop, not an outage."

## 5:00–5:30 — Close / teardown
- **Visual:** `aws ecr put-image` restoring the known-good digest, deployment reaching `COMPLETED`.
- **Say this:**
  > "Recovered by restoring the last known-good image digest — no rebuild needed. I've documented adding a real circuit breaker and a Bedrock-aware health check as the next fixes, rather than applying them quietly and erasing the evidence that they were ever missing."

---

## Production notes
- The 1:40–2:50 silent-fallback segment is the single strongest beat in the entire 7-video series — it's a real production-grade finding, not a staged demo. Don't compress it below 60 seconds even when cutting for time.
- If cutting for LinkedIn: keep the hook, the silent-fallback finding, and the zero-downtime nuance; cut the Docker platform/Buildx detail first.
