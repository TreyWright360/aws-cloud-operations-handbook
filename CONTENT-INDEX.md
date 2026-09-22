# Content index

Status describes evidence for the **operational demonstration**, not whether a Terraform file exists. All topics are **DOCUMENTATION ONLY** until captured lab proof is added.

Use the [22-point failure map](architecture/master-failure-map.md) to select the next scenario and the [CSV version](architecture/failure-point-matrix.csv) for a searchable tracker.

| Episode | Operational question | Article | Project | Status |
| --- | --- | --- | --- | --- |
| 1 | Is an ALB 504 caused by the load balancer, target, network, or dependency? | [ALB 504](load-balancing/alb-504.md) | [Multi-AZ web](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) | DOCUMENTATION ONLY |
| 2 | Why is Auto Scaling replacing new instances? | [Replacement loop](compute/autoscaling-failures.md) | [Multi-AZ web](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) | DOCUMENTATION ONLY |
| 3 | Why does an allowed role receive AccessDenied? | [IAM AccessDenied](security/iam-access-denied.md) | [IAM governance](https://github.com/TreyWright360/aws-cloud-security-iam-governance) | DOCUMENTATION ONLY |
| 4 | Is RDS unavailable or unreachable from the app? | [RDS connectivity](databases/rds-connectivity.md) | [Multi-AZ web](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) | DOCUMENTATION ONLY |
| 5 | When is a Terraform state lock safe to remove? | [State lock recovery](infrastructure-as-code/terraform-locking.md) | [All Terraform projects](README.md#project-implementations) | DOCUMENTATION ONLY |
| 6 | Does the app survive loss of one AZ? | [AZ failure](disaster-recovery/availability-zone-failure.md) | [Multi-AZ web](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) | DOCUMENTATION ONLY |
| 7 | What must be recovered first after regional loss? | Planned: `disaster-recovery/regional-recovery.md` | [DataOps](https://github.com/TreyWright360/aws-enterprise-dataops-migration-pipeline) | NOT WRITTEN |
| 8 | What happens after a consumer rejects an event? | Planned: `event-driven/pipeline-failure-and-replay.md` | [Event pipeline](https://github.com/TreyWright360/aws-resilient-event-driven-pipeline) | IMPLEMENTATION PENDING |
| 9 | How is a failed ECS release restored? | Planned: `deployments/ecs-rollback.md` | [ECS Bedrock](https://github.com/TreyWright360/aws-ecs-bedrock-devsecops) | NOT WRITTEN |
| 10 | Which change caused a cost spike? | Planned: `cost-operations/cost-anomaly.md` | Cross-project | NOT WRITTEN |

## Publication sequence

1. Complete the [ALB lab prerequisites and run](load-balancing/alb-504.md#lab-simulation-plan).
2. Add redacted before/after proof to `evidence/alb-504/`, then change the article label only if the complete path was tested.
3. Record the investigation and publish its LinkedIn post using [the video guide](videos/README.md).
4. Add the video and article to the portfolio site.
5. Repeat for episodes 2–6; build the missing infrastructure or workflow capability before claiming episodes 7–10.
