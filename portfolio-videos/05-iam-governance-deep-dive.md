# Video 5: IAM Security & Governance Deep Dive

> **Platform:** YouTube (long-form) / LinkedIn (cut down)
> **Duration:** 4–6 minutes
> **Repo:** [aws-cloud-security-iam-governance](https://github.com/TreyWright360/aws-cloud-security-iam-governance)
> **Evidence:** [evidence/s3-public-remediation/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/s3-public-remediation/INDEX.md), [evidence/iam-access-denied-mfa/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/iam-access-denied-mfa/INDEX.md)

---

## 0:00–0:20 — Hook
- **Visual:** Architecture diagram — AWS Config, Access Analyzer, EventBridge, Lambda remediation function.
- **Say this:**
  > "Two labs here: an auto-remediating public S3 bucket, and an IAM lockout using a real virtual MFA device I built from scratch — no phone app, no third-party library."

## 0:20–1:10 — Lab 1: public bucket auto-remediation
- **Visual:** S3 console — bucket policy edited to allow public read; AWS Config timeline.
- **Say this:**
  > "I made a bucket public on purpose. AWS Config flagged the non-compliant resource, EventBridge routed the finding, and a Lambda function automatically remediated it — reverted the policy without me touching it."
- **Show on screen:** CloudTrail event showing the Lambda's `PutBucketPolicy` call, timestamped remediation.

## 1:10–1:40 — The quiet-failure bug I found
- **Visual:** Open `modules/remediation_engine/remediate.py`, highlight the logging line.
- **Say this:**
  > "While testing this, I found a real bug in my own code: the function logs 'Triggering automated remediation...' even on rules it doesn't actually act on. That's a dangerous kind of bug — a log line that looks like success when nothing happened. I documented it rather than quietly patching it out of the evidence."

## 1:40–2:20 — Building the MFA device
- **Visual:** Terminal — Python script implementing TOTP (RFC 6238) using only `hmac`, `base64`, `struct`, `time`.
- **Say this:**
  > "For the second lab I needed a real MFA device, not a mocked one. Rather than use my phone, I implemented the TOTP algorithm myself in about 30 lines of Python standard library — same algorithm your phone's authenticator app runs."
- **Show on screen:** `aws iam create-virtual-mfa-device`, then the script generating a code that AWS actually accepts.

## 2:20–3:20 — The deny policy and the lockout
- **Visual:** `modules/iam_governance/main.tf` — the MFA-conditional deny statement (`BoolIfExists`, `aws:MultiFactorAuthPresent`).
- **Say this:**
  > "This policy explicitly denies any action unless MFA is present on the session — and an explicit deny always beats an allow in AWS's evaluation logic, no matter what other policies are attached. I tested that by attempting an action without MFA."
- **Show on screen:** CloudTrail `AccessDenied` event, real, with the exact error and timestamp.

## 3:20–3:50 — Passing with MFA
- **Visual:** Same action, this time with a TOTP code from the self-built generator, succeeding.
- **Say this:**
  > "Same call, same identity, MFA code from the generator I built — and it goes through. That's the control working exactly as designed, proven both ways."

## 3:50–4:20 — Close / teardown
- **Visual:** Teardown confirmation — MFA device deleted, IAM policies removed, Config recorder stopped.
- **Say this:**
  > "Fully torn down afterward, including deleting the virtual MFA device — nothing left running or billing."

---

## Production notes
- The TOTP-from-scratch segment is the strongest differentiator in this video — most candidates would screenshot an authenticator app. Give it real screen time (don't rush 1:40–2:20).
- Keep the "quiet-failure bug" beat — it's a stronger signal of real engineering than a clean demo would be.
