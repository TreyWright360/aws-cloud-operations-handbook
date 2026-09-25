# Video 1: Portfolio Overview

> **Platform:** LinkedIn Video / YouTube / Portfolio site embed
> **Duration:** 60–90 seconds
> **Target Audience:** Hiring managers, recruiters, technical screeners (first 10 seconds decide if they keep watching)
> **Goal:** One clip that proves "I deploy real AWS, break it on purpose, measure recovery, document it honestly" — not a slideshow of architecture diagrams nobody ran.

---

## Visual-layer rules (apply to every shot)
- Screen recording only — no talking head, no slides-as-screenshots.
- Every claim on screen must be something a viewer could click and verify (a repo file, a CloudTrail timestamp, a terminal output) — no stock icons standing in for real evidence.
- Lower-third captions repeat the spoken numbers (timestamps, durations) since this plays muted on LinkedIn feed autoplay.
- Cut on action — no dead air while a page scrolls.

---

## 0:00–0:08 — Hook
- **Visual:** Fast cut across 4 terminal/console moments — a `terraform apply` completing, a CloudTrail `AccessDenied` event, a `curl /health` returning 200, an ECS task cycling.
- **Say this:**
  > "Five AWS projects. I deployed all of them for real, broke them on purpose, and timed how long it took to fix."

## 0:08–0:20 — The pattern
- **Visual:** GitHub profile page (TreyWright360), scroll across the 5 repo cards, land on the handbook repo.
- **Say this:**
  > "Every project follows the same loop: deploy real infrastructure, inject a real failure, measure recovery with timestamps, then document exactly what worked and what didn't — in this operations handbook."
- **Show on screen:** [aws-cloud-operations-handbook](https://github.com/TreyWright360/aws-cloud-operations-handbook) README, `evidence/` folder listing.

## 0:20–0:55 — Four proof beats (one per project, ~8s each)
- **Multi-AZ:** NAT gateway crash-loop injected → recovery measured at 2m40s.
  **Show on screen:** [evidence/multi-az-instance-replacement/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/multi-az-instance-replacement/INDEX.md)
- **IAM Governance:** real virtual MFA device, deny-without-MFA policy, `AccessDenied` captured live in CloudTrail.
  **Show on screen:** [evidence/iam-access-denied-mfa/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/iam-access-denied-mfa/INDEX.md)
- **DataOps:** DMS full-load + CDC replication + a real Glue SCD2 PySpark job, not a stub.
  **Show on screen:** [evidence/dataops-cdc-replication-scd2/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/dataops-cdc-replication-scd2/INDEX.md)
- **ECS/Bedrock:** a genuine Bedrock access gap found in production — `/health` stays green while `/api/analyze` silently returns canned text.
  **Show on screen:** [evidence/ecs-bedrock-deployment/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/ecs-bedrock-deployment/INDEX.md)
- **Say this (over the four cuts):**
  > "A NAT gateway crash-loop, an IAM lockout with a real MFA device, a database migration with change-data-capture, and a production AI service that looked healthy while silently failing — all real, all timestamped, all torn down clean afterward."

## 0:55–1:10 — The honesty beat
- **Visual:** Scroll to a "PARTIALLY TESTED" badge and a documented limitation (e.g. the ECS circuit-breaker gap, or the declined Kinesis test).
- **Say this:**
  > "I also document what I didn't test and why — because a portfolio that only shows wins isn't credible."
- **Show on screen:** CASE-STUDY.md "Production improvements" section, any repo.

## 1:10–1:20 — Close / CTA
- **Visual:** GitHub profile README, cursor hovers over repo list.
- **Say this:**
  > "All five projects, full evidence trail, linked below. Let's talk."
- **Show on screen:** [TreyWright360 profile](https://github.com/TreyWright360)

---

## Production notes
- Record this LAST, after 2–7 exist — the deep-dive clips are the raw footage this one gets cut down from.
- Keep captions burned in; LinkedIn autoplay is muted by default.
