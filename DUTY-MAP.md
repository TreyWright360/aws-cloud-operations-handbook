# Cloud operations duty map

This maps hiring duties to code and to the evidence still needed. A repository link proves that code is published; it does not prove an incident was run.

| Duty | Code or procedure | Proof to capture |
| --- | --- | --- |
| Monitor infrastructure | [ALB module](https://github.com/TreyWright360/aws-multi-az-web-infrastructure/blob/main/modules/alb/main.tf), [ALB runbook](load-balancing/alb-504.md) | 504 alarm configuration and alarm transition; CloudWatch graph |
| Troubleshoot incidents | [ALB decision tree](load-balancing/alb-504.md#diagnostic-decision-tree) | Symptom, competing causes, chosen branch, recovery request |
| Support EC2 and ALB | [ASG module](https://github.com/TreyWright360/aws-multi-az-web-infrastructure/blob/main/modules/asg/main.tf), [replacement runbook](compute/autoscaling-failures.md) | ASG activity and stable target health after correction |
| Manage IAM | [IAM governance module](https://github.com/TreyWright360/aws-cloud-security-iam-governance/blob/main/modules/iam_governance/main.tf), [AccessDenied runbook](security/iam-access-denied.md) | Redacted denied event, policy evaluation, least-privilege fix |
| Use Terraform | [Multi-AZ Terraform](https://github.com/TreyWright360/aws-multi-az-web-infrastructure), [state runbook](infrastructure-as-code/terraform-locking.md) | Format/validate/plan result, backend configuration, reviewed apply |
| Support deployments | [ECS CI workflow](https://github.com/TreyWright360/aws-ecs-bedrock-devsecops/blob/main/.github/workflows/devsecops.yml) | Failed deployment and controlled rollback; workflow support still needed |
| Recover services | [AZ exercise](disaster-recovery/availability-zone-failure.md) | Timeline, target health, successful request, measured recovery time |
| Document and escalate | [Article template](templates/knowledge-article.md), [incident template](incident-response/incident-template.md) | Completed ticket and postmortem with timestamps and ownership |
| Explain technical work | [Video guide](videos/README.md) | Published video linked back to article and evidence |

## Evidence standard

For every claimed duty, link to a dated artifact showing the action and outcome. Record the lab account/region without publishing account IDs, credentials, resource secrets, or customer data. See [evidence rules](evidence/README.md).
