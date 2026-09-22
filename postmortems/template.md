# Blameless postmortem: [incident title]

**Event type:** Controlled AWS lab simulation / production (choose one)
**Date and region:**
**Evidence status:** DOCUMENTATION ONLY
**Owner and reviewers:**

## Summary and user impact

Describe what users experienced, the affected path, start/end time, and scope. For a lab, say that no real customer was affected.

## Timeline

| UTC time | Observation or action | Evidence | Decision owner |
| --- | --- | --- | --- |

## Root cause and contributing conditions

Distinguish the trigger from the underlying weakness. Explain how evidence supports the conclusion. Avoid attributing fault to a person.

## Detection and response

What signaled the issue? What delayed detection or recovery? Which runbook branch was used? Include the rollback decision and why it was safe.

## Recovery validation

Record the original request succeeding, target/service health, metrics after mitigation, and the observation window. Calculate elapsed recovery from timestamps; do not invent RTO or RPO.

## Follow-up actions

| Action | Owner | Due date | Proof of completion |
| --- | --- | --- | --- |

## Evidence and limits

Link redacted artifacts under `evidence/<episode>/`. List what was not tested and what would differ in production.
