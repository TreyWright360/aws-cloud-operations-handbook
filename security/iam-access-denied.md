# IAM AccessDenied investigation

**Evidence status:** DOCUMENTATION ONLY
**Related project:** [Cloud security and IAM governance](https://github.com/TreyWright360/aws-cloud-security-iam-governance)

## Symptom and impact

An AWS API call returns AccessDenied. Record the caller, action, resource ARN, region, request ID, and UTC time. An identity policy Allow is only one part of the authorization decision.

## Decision tree

1. Confirm the **actual principal** with `aws sts get-caller-identity`; check whether a role was assumed and which session is active.
2. Find the failed action in CloudTrail when available. Separate the action and resource from the human-readable error, which can be incomplete.
3. Compare identity and resource policies. Check permissions boundaries, session policies, service control policies or resource control policies, trust policy for `AssumeRole`, and any KMS key policy involved.
4. Locate an explicit Deny or missing Allow. Do not remove an intentional organization guardrail to make a lab command work.
5. Change the narrowest policy statement after review, repeat the exact failed call, then test that unrelated access remains denied.

## Read-only checks

```bash
aws sts get-caller-identity
aws iam get-role --role-name <role-name>
aws iam list-attached-role-policies --role-name <role-name>
aws iam list-role-policies --role-name <role-name>
```

The [IAM governance module](https://github.com/TreyWright360/aws-cloud-security-iam-governance/blob/main/modules/iam_governance/main.tf) creates groups and an MFA-related deny policy. It is a code example, not evidence of a captured AccessDenied incident. For a lab, use a disposable role and a harmless read action. Save redacted denial, policy evaluation, correction, and success under `evidence/`.

## Recovery and limitations

Repeat the exact API call with the same principal and resource. Record the request ID and observed result. Policy simulation can help narrow identity policy behavior, but it does not replace an end-to-end call across every policy type. Do not claim production IAM remediation without a real permitted record.
