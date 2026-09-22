# Incident response and triage

**Evidence status:** DOCUMENTATION ONLY. Use this checklist for a controlled lab or adapt it to an organization's actual incident process.

## First five minutes

1. Record the UTC start time, caller, affected service, region, and user-visible symptom. Open an [incident record](incident-template.md).
2. Establish whether the issue is active, widespread, and customer facing. State what is known and what remains a hypothesis.
3. Check one direct user path and the matching service metrics. Preserve request IDs and time ranges.
4. Compare recent deployments, infrastructure changes, scaling events, and AWS Health notices.
5. Choose a diagnostic branch from the [22-point map](../architecture/master-failure-map.md). Assign an owner for investigation and a separate owner for communication when the team allows it.

## Investigation order

`User symptom → entry point → target/compute → network → dependency → recent change`

Use read-only checks first. The [AWS triage script](../scripts/aws/triage_diagnostics.sh) collects ALB, target, ASG, and optional RDS views without modifying resources. Each runbook names the signal that distinguishes competing faults.

## Containment and escalation

Choose a reversible action that reduces impact while preserving enough capacity. Record the intended change, owner, expected result, rollback trigger, and prior configuration. Escalate when the fault domain is unclear, capacity is insufficient, a destructive change is proposed, or recovery fails after the first correction.

## Close only after validation

Repeat the original user request and verify service metrics and dependencies for a stated observation window. Record recovery time, any remaining risk, and the follow-up owner. Produce a [blameless postmortem](../postmortems/template.md) with evidence links.
