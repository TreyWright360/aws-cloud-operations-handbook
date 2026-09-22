# Auto Scaling replacement loop

**Evidence status:** DOCUMENTATION ONLY
**Related project:** [Multi-AZ ASG module](https://github.com/TreyWright360/aws-multi-az-web-infrastructure/blob/main/modules/asg/main.tf)
**Video:** Not recorded

## Symptom and impact

New EC2 instances repeatedly launch, fail a health check, and terminate. Capacity may fall below the desired level, and clients may see errors or slower responses. Record ASG activity times, instance IDs, target health reasons, and the original request path.

## Fault domains and decision tree

1. **Launch failure:** If no instance reaches `InService`, inspect launch template version, subnet capacity, AMI, IAM instance profile, and user-data output.
2. **Bootstrap failure:** If the instance runs but `/health` fails, inspect Apache/service startup and cloud-init logs. The current module installs Apache and writes `/health` through [user data](https://github.com/TreyWright360/aws-multi-az-web-infrastructure/blob/main/modules/asg/main.tf).
3. **Health timing:** Compare measured startup time with the target group's health thresholds and the ASG's 300-second grace period. A grace period change must be based on measured startup behavior.
4. **Network path:** If local health succeeds but ALB health fails, check target port, app security group, NACL, and subnet path.
5. **Host failure:** If EC2 status checks fail, inspect instance/system checks separately from application health.

## Read-only checks

```bash
aws autoscaling describe-auto-scaling-groups --region <region> --auto-scaling-group-names <asg-name>
aws autoscaling describe-scaling-activities --region <region> --auto-scaling-group-name <asg-name> --max-items 20
aws elbv2 describe-target-health --region <region> --target-group-arn <target-group-arn>
aws ec2 describe-instance-status --region <region> --instance-ids <instance-id> --include-all-instances
```

In the Console, use Auto Scaling → Activity to read the exact replacement reason; compare it with Target Groups → Health and EC2 status checks. If instance access is available, inspect `/var/log/cloud-init-output.log`, `systemctl status httpd`, and a local request to `/health`.

## Containment and repair

Preserve enough healthy capacity before changing the launch template or health settings. In a controlled lab, a temporary process suspension can preserve an instance for diagnosis, but it can also stop normal replacement; record which process was suspended and resume it promptly. Fix the observed bootstrap, registration, network, or timing fault. Roll back to the prior launch template version if the correction fails.

## Recovery proof

Capture ASG activity, a stable desired/in-service count, healthy targets across the intended AZs, and successful client requests for an observation period. Do not describe a historical replacement loop in the project README as lab tested until the logs and timeline are checked in under `evidence/`.

## Lab plan

Use a disposable ASG stack. Record baseline target health. Introduce a reversible broken health path or user-data version; capture replacement activity and target-health reason. Restore the prior version or correct the path, then record stable capacity and the original client request. Clean up the stack after capturing redacted evidence.

## Reference

[AWS: troubleshoot unhealthy Auto Scaling instances](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ts-as-healthchecks.html)
