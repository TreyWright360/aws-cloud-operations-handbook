# Evidence: IAM explicit-deny-beats-allow (MFA enforcement)

Lab run against the deployed [`aws-cloud-security-iam-governance`](https://github.com/TreyWright360/aws-cloud-security-iam-governance) stack, following the [IAM AccessDenied runbook](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/security/iam-access-denied.md).

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Code revision | `aws-cloud-security-iam-governance@a00bfc78b4422284f5765f4af2440f07bbe2ad9a` (same deploy as the [S3 remediation evidence](../s3-public-remediation/INDEX.md)) |
| Failure injection | Created a disposable IAM user, added it to the `enterprise-security-governance-cloud-developers` group (which has both `PowerUserAccess` and the `enterprise-security-governance-enforce-mfa` deny policy), and called `s3:ListAllMyBuckets` with a static access key — no MFA context present. |
| Observed symptom | 16:04:11Z — `AccessDenied`: `User: .../lab-test-developer is not authorized to perform: s3:ListAllMyBuckets with an explicit deny in an identity-based policy: arn:aws:iam::050451394862:policy/enterprise-security-governance-enforce-mfa` |
| Diagnosis | CloudTrail event `2be4cc9e-91fe-41d4-9136-6f2a53b75054` confirms the exact principal, action, and denying policy — no session MFA attribute present. `PowerUserAccess` would have allowed the call; the group's explicit MFA-enforcement `Deny` overrides it, exactly as documented in the runbook. |
| Recovery | Enrolled a virtual MFA device for the same user via CLI (TOTP implemented directly against the IAM-issued Base32 seed, no phone needed), called `sts:GetSessionToken` with a fresh TOTP code (allowed — it's in the deny policy's `NotAction` exclusion list so a user can always bootstrap an MFA session), then retried the identical `ListAllMyBuckets` call using the resulting MFA-backed temporary credentials. |
| Validation | 16:08:35Z — call succeeded, returned the account's 3 buckets. CloudTrail event `ad6d8598-d8a1-48cc-a917-4bfb6c71ee86` shows `sessionContext.attributes.mfaAuthenticated: "true"` and `httpStatusCode: 200` — same user, same action, only the MFA session state differs from the denied call 4m 24s earlier. |
| Limits | Tests only the MFA-deny policy path, not the other `cloud_developers` grants, the `security_auditors` group, or resource-level/boundary policies. Static long-term access keys were used to obtain the initial (denied and bootstrap) calls; a production environment would typically also restrict or rotate these. |

## Side-by-side

| | Without MFA | With MFA |
| --- | --- | --- |
| Time | 16:04:11Z | 16:08:35Z |
| Result | `AccessDenied` (403) | `200 OK`, 3 buckets returned |
| CloudTrail `mfaAuthenticated` | absent | `true` |
| Denying statement | `enterprise-security-governance-enforce-mfa` | — |

Test user, access key, and MFA device were all deleted immediately after capturing both CloudTrail events. No resources remain.
