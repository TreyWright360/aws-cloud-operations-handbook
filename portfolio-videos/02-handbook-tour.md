# Video 2: Operations Handbook Tour

> **Platform:** LinkedIn Video / YouTube
> **Duration:** 2–3 minutes
> **Target Audience:** Hiring managers who want to see how you think about incidents, not just that you can deploy Terraform
> **Accompanying repo:** [aws-cloud-operations-handbook](https://github.com/TreyWright360/aws-cloud-operations-handbook)

---

## 0:00–0:20 — Hook
- **Visual:** Repo root listing — folders: architecture, checklists, compute, databases, disaster-recovery, incident-response, load-balancing, networking, postmortems, security, evidence, videos.
- **Say this:**
  > "This is my operations handbook — the same reference I'd want on a real team. It's organized around failure domains, not services, because that's how incidents actually get diagnosed."

## 0:20–0:50 — Architecture / master failure map
- **Visual:** Open `architecture/master-failure-map.md`, scroll the fault-domain breakdown (e.g. the ALB 504 six-boundary list).
- **Say this:**
  > "This master failure map is the thing I check first during an incident: for a given symptom — say, a 504 — what are the actual distinct places in the stack that could cause it? Most people jump straight to 'restart the instance.' This forces evidence-first isolation instead."
- **Show on screen:** the 6-boundary ALB list, then cut to `videos/01-alb-504.md` as the companion walkthrough.

## 0:50–1:20 — Evidence folder (the differentiator)
- **Visual:** Open `evidence/` — list all 6 INDEX.md files.
- **Say this:**
  > "This folder is what separates this from a normal 'here's my architecture' portfolio. Every project I built has a dated evidence record: what I broke, what the CloudTrail or CloudWatch timestamps actually showed, how long recovery took, and — just as important — what I didn't test and why."
- **Show on screen:** open `evidence/ecs-bedrock-deployment/INDEX.md`, scroll to the "Limits" row.
- **Say this (cont.):**
  > "Real engineering work has edges. I write those down instead of hiding them."

## 1:20–1:50 — Postmortems & checklists
- **Visual:** Open `postmortems/`, then `checklists/`.
- **Say this:**
  > "Postmortems follow a fixed format — timeline, root cause, contributing factors, action items — the same shape you'd file after a real production incident. The checklists folder is the pre-flight version: what I check before I call a deployment safe."

## 1:50–2:20 — Cross-repo evidence links
- **Visual:** Split-screen or fast cut: handbook evidence file → the actual repo's CASE-STUDY.md "PARTIALLY TESTED" banner it supports.
- **Say this:**
  > "Every one of the five project repos links back here for its test evidence, and this repo links back out to the exact commit and workflow run. It's a closed loop — nothing here is asserted without a receipt on the other end."

## 2:20–2:40 — Close
- **Visual:** Repo README top, badge/status line.
- **Say this:**
  > "This is the reference I built for myself to operate these systems like production — not just to pass a portfolio review."

---

## Production notes
- This video sets up vocabulary ("evidence record," "PARTIALLY TESTED," "failure domain") that videos 4–7 will use without re-explaining — record this before the deep-dives.
- Pull b-roll of scrolling through 2–3 evidence INDEX.md files at real reading speed, not a fast blur — the content itself is the proof.
