# Master failure map: 22 operational scenarios

**Evidence status:** DOCUMENTATION ONLY. This is a triage map, not a record of completed incidents. Confirm the fault domain before making changes. A proposed permanent fix needs a test, a change plan, and recovery validation.

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

The same 22 rows are in [importable CSV](failure-point-matrix.csv). Each completed exercise should link to a runbook and dated [evidence](../evidence/README.md).
