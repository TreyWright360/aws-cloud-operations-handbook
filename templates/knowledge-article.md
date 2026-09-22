# [Operational question]

**Evidence status:** DOCUMENTATION ONLY
**Last reviewed:** YYYY-MM-DD
**Related project:** [repository](https://github.com/TreyWright360/)
**Video:** Not recorded

## Failure symptom and customer impact

What fails? What can users still do? State whether the impact is observed in a lab or only hypothetical.

## Architecture and fault domains

Link exact Terraform/application files. List the plausible fault domains and the signal that distinguishes each.

## Evidence to collect

Name metric/log/event, time window, resource, and expected interpretation. Redact account IDs, IPs, credentials, and personal data before publication.

## Diagnostic decision tree

Write ordered if/then branches. Include a stop/escalate condition when evidence is insufficient.

## AWS Console checks and CLI commands

Use read-only commands first. Label placeholders. State required region and IAM permissions. Commands that change resources belong in the lab section with a rollback path.

## Safe containment, remediation, and rollback

Separate short-term user impact reduction from root-cause correction. Record who authorizes production changes.

## Recovery validation

Check the original user path, service metrics, and dependent components. State the observation window.

## Lab simulation and captured evidence

Prerequisites, fault injection, expected symptom, diagnosis, correction, recovery, cleanup, and dated artifact links. Do not upgrade the status label without the proof.

## Related Terraform files, video, and interview explanation

Provide exact source links. Explain the decision in two or three plain sentences.

## Limitations and production improvements

Distinguish current code from proposed controls, untested assumptions, and production requirements.
