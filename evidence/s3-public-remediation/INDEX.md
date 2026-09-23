# Evidence: S3 public-bucket detection and auto-remediation

Lab run against the deployed [`aws-cloud-security-iam-governance`](https://github.com/TreyWright360/aws-cloud-security-iam-governance) stack.

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Code revision | `aws-cloud-security-iam-governance@a00bfc78b4422284f5765f4af2440f07bbe2ad9a`, deployed via `deploy-production.yml` run [35882474724](https://github.com/TreyWright360/aws-cloud-security-iam-governance/actions/runs/35882474724) |
| Failure injection | 15:48:47Z — created a throwaway bucket, disabled its Block Public Access, and attached a public-read bucket policy (`s3:GetObject` for `Principal: "*"`) |
| Observed symptom | 15:48:48Z — anonymous `GET` against the object succeeded (public). AWS Config had not yet evaluated the change. |
| Diagnosis | AWS Config recorded the configuration change and evaluated the `s3-bucket-public-read-prohibited` rule, marking the bucket `NON_COMPLIANT` at 15:51:21.686Z (recorded) / 15:51:30Z (confirmed via CLI polling) — roughly **2m 43s** after the policy was applied. EventBridge's `Config Rules Compliance Change` rule invoked the remediation Lambda at 15:51:21Z, ~1s after the compliance result was recorded. |
| Recovery | The Lambda re-applied `PutPublicAccessBlock` (all four flags `true`) on the flagged bucket at 15:51:22Z-ish (Lambda `REPORT` line: 621ms duration) and published an SNS alert to the confirmed `wrightt3@outlook.com` subscription. |
| Validation | Anonymous `GET` against the same object after remediation returned `HTTP 403`. `aws s3api get-public-access-block` confirmed all four flags back to `true`. |
| Limits | The Lambda re-blocks public access; it does **not** remove the public bucket policy statement itself, so the policy document still technically grants public read — it's just overridden by the reinstated Block Public Access. A second, unrelated finding from the same run: the Lambda also fired for the `s3-bucket-ssl-requests-only` rule on the same bucket and logged `"Triggering automated remediation..."` even though its remediation branch only checks `"public" in rule_name.lower()` — so for any non-S3-public rule, that log line is printed but nothing is actually remediated. Worth fixing before calling this Lambda "remediation" for every rule it watches. |

## Timeline

- `15:48:47Z` — public policy applied (failure injection start)
- `15:51:21.686Z` — Config records `NON_COMPLIANT`
- `15:51:21Z` — EventBridge invokes remediation Lambda
- `15:51:22Z` (approx) — `PutPublicAccessBlock` re-applied
- `15:51:30Z` — confirmed non-compliant via CLI poll
- Post-fix — anonymous access returns `403`; SNS alert delivered to confirmed subscriber

Test bucket and object deleted immediately after the validation step. No resources remain running from this lab.
