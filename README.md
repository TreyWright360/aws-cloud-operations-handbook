# AWS Cloud Operations Handbook

An operations portfolio connecting incident questions to investigation procedures, infrastructure code, and recorded recovery evidence. The project repositories hold the current code and planned builds; this handbook holds the runbooks and the proof trail.

> **Current evidence status:** Documentation only. The procedures are written against the linked code, but this repository does not yet contain captured AWS lab results. A topic moves to **LAB TESTED** only after a dated failure test and recovery validation are checked into `evidence/`.

## Start here

1. [Content index](CONTENT-INDEX.md) — episodes, article status, and next work.
2. [Duty map](DUTY-MAP.md) — the job duty each project can help demonstrate.
3. [ALB 504 investigation](load-balancing/alb-504.md) — first complete runbook and lab plan.
4. [Article template](templates/knowledge-article.md) and [evidence rules](evidence/README.md) — how new episodes become verifiable.

## Operational runbooks

- [Incident response and triage](incident-response/incident-triage.md)
- [ALB 504 deep dive](load-balancing/alb-504.md)
- [Auto Scaling replacement loop](compute/autoscaling-failures.md)
- [Terraform state lock recovery](infrastructure-as-code/terraform-locking.md)
- [Blameless postmortem template](postmortems/template.md)
- [Read-only AWS triage script](scripts/aws/triage_diagnostics.sh)

## 22 failure points

This table is also available as the [master failure map](architecture/master-failure-map.md) and an [importable CSV](architecture/failure-point-matrix.csv). Actions are triage starting points; confirm the cause before changing a service.

| Domain | Failure mode | Key symptom | Immediate action | Permanent fix |
| --- | --- | --- | --- | --- |
| ALB | 504 Gateway Timeout | Requests time out | Compare ALB 504 metrics, target health, and target response time | Correct the proven target, network, or dependency cause; tune timeout or keep-alive only when measurements justify it |
| ALB | 503 Service Unavailable | No usable target for a request | Inspect target health and recent registration or deployment events | Repair health endpoint, target registration, or capacity |
| ALB | TLS / SSL Failure | HTTPS handshake errors | Inspect listener certificate, SNI hostname, and ACM status | Renew or attach the correct certificate and test the full chain |
| EC2 | CPU Exhaustion | High CPU and slow responses | Identify process and correlate CPU with request volume | Fix workload or scale based on measured capacity |
| EC2 | Memory Exhaustion (OOM) | Process exits or OOM events | Check service logs, memory metrics, and recent changes | Fix leak or memory settings; right-size after testing |
| EC2 | Disk Full (100%) | Writes fail; filesystem at capacity | Identify the full filesystem and large paths; preserve needed logs | Set retention and monitoring; expand EBS if justified |
| EC2 | Status Check Failed | Instance fails system or instance check | Inspect both status checks and ASG replacement state | Repair OS or replace failed instance; investigate underlying cause |
| ASG | Replacement Thrash Loop | Repeated launch and terminate events | Inspect ASG activity, user data, target health, and grace period | Correct bootstrap or health timing; verify stable capacity |
| VPC | Security Group Block | Connection timeout | Compare source, destination, port, and security group rules; use flow logs if enabled | Add the narrow required rule and test access |
| VPC | NACL Block | Asymmetric traffic or timeout | Inspect subnet NACL rules and ephemeral return path | Correct stateless ingress and egress rules |
| RDS | Connections Exhausted | Too many connections | Inspect DatabaseConnections and application pool behavior | Tune pooling, limits, or RDS Proxy based on load test |
| RDS | Storage Full | Low FreeStorageSpace; writes may fail | Check free storage and pending storage changes | Enable appropriate autoscaling and capacity alarms |
| IAM | AccessDenied | API action denied | Identify principal, action, resource, and request ID | Grant only the needed action and resource after policy evaluation |
| IAM | Explicit Deny | Denied despite an Allow | Inspect identity, resource, boundary, session, and organization policies | Correct the specific deny only if its intent is wrong |
| S3 | AccessDenied | Object operation denied | Check caller, bucket/object policy, ownership, and KMS context | Add the minimum S3 and KMS permissions required |
| Terraform | State Lock Blocked | Plan or apply cannot acquire lock | Confirm which run owns the lock and whether it remains active | Fix concurrency or stale-run cause; unlock only after proving no writer remains |
| Terraform | Configuration Drift | Plan shows unexpected changes | Pause apply and compare state, config, and cloud resource | Reconcile configuration or import reviewed resources |
| Deploy | Bad Release (5xx) | Error rate rises after release | Identify release and restore last known good version using a tested procedure | Fix regression and add pre-release coverage |
| Backup | Restore Failure | Restore job errors or restored data unusable | Inspect job event, IAM, KMS, and backup health | Repair access or backup design; rehearse restore regularly |
| DR | Failover Failure | Secondary environment cannot serve traffic | Verify dependencies and invoke the approved DR playbook | Repair replication, capacity, DNS, and failback gaps |
| Cost | Spend Spike | Billing anomaly | Identify account, region, service, resource, and recent change | Add budgets, anomaly alerts, tags, and lifecycle controls |
| Monitor | Missing Alarm | Failure occurs without alert | Verify the symptom directly from metrics and logs | Add alarm and test its delivery and runbook link |

## Traceability

`LinkedIn explanation → handbook article → exact project files → failure test → recovery proof → portfolio case study`

The recording workspace is private. Publish a video link only after the demonstration and its evidence have been reviewed.

## Project implementations

| Project | Existing implementation | Operations topics |
| --- | --- | --- |
| [Multi-AZ web infrastructure](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) | VPC, ALB, EC2 Auto Scaling, RDS modules | ALB, instance replacement, connectivity, AZ recovery |
| [Cloud security and IAM governance](https://github.com/TreyWright360/aws-cloud-security-iam-governance) | IAM, Config, Access Analyzer, remediation modules | AccessDenied and governance |
| [Enterprise DataOps migration](https://github.com/TreyWright360/aws-enterprise-dataops-migration-pipeline) | DMS, streaming, Glue, S3 replication modules | Migration and recovery dependencies |
| [ECS Bedrock DevSecOps](https://github.com/TreyWright360/aws-ecs-bedrock-devsecops) | FastAPI, Docker, ECS Terraform, CI | Deployment failure and rollback design |
| [Resilient event-driven pipeline](https://github.com/TreyWright360/aws-resilient-event-driven-pipeline) | Documentation only; implementation pending | Failure and replay design |

## Evidence labels

- **DOCUMENTATION ONLY:** procedure or design exists; no captured end-to-end lab proof.
- **PARTIALLY TESTED:** dated proof exists for some steps; gaps are listed.
- **LAB TESTED:** a controlled failure, diagnosis, correction, and recovery check are recorded.
- **PRODUCTION EXPERIENCE:** use only for work actually performed in production with disclosure permitted.

## Current implementation limits

The Multi-AZ project's ALB module does not currently enable access logs or define a 504 alarm. Its Apache instance serves a static page and `/health`; it does not call the RDS instance. The CI workflow checks health after `terraform apply` but does not implement rollback. Those are useful future lab additions and must not be presented as completed capabilities. See the [ALB runbook](load-balancing/alb-504.md) for the specific gap list.
