#!/usr/bin/env bash
# Read-only AWS incident snapshot. No files are written and no resources are changed.
set -euo pipefail

usage() {
  printf 'Usage: %s --region REGION [--alb-arn ARN] [--target-group-arn ARN] [--asg-name NAME] [--db-id IDENTIFIER]\n' "$0"
  printf 'At least one resource selector is required. Review output before sharing; it can contain account IDs and resource names.\n'
}

region=""
alb_arn=""
target_group_arn=""
asg_name=""
db_id=""

while (($# > 0)); do
  case "$1" in
    --region|--alb-arn|--target-group-arn|--asg-name|--db-id)
      if (($# < 2)) || [[ "$2" == --* ]]; then
        usage >&2
        exit 2
      fi
      case "$1" in
        --region) region="$2" ;;
        --alb-arn) alb_arn="$2" ;;
        --target-group-arn) target_group_arn="$2" ;;
        --asg-name) asg_name="$2" ;;
        --db-id) db_id="$2" ;;
      esac
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$region" ]] || [[ -z "$alb_arn$target_group_arn$asg_name$db_id" ]]; then
  usage >&2
  exit 2
fi
if ! command -v aws >/dev/null 2>&1; then
  printf 'AWS CLI is required.\n' >&2
  exit 127
fi

printf 'Read-only triage snapshot at %s (UTC), region %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$region"
printf 'Caller ARN (confirm account and role):\n'
aws sts get-caller-identity --query Arn --output text

if [[ -n "$alb_arn" ]]; then
  printf '\nALB description:\n'
  aws elbv2 describe-load-balancers --region "$region" --load-balancer-arns "$alb_arn" \
    --query 'LoadBalancers[].{Name:LoadBalancerName,State:State.Code,Scheme:Scheme,DNSName:DNSName,AvailabilityZones:AvailabilityZones[].ZoneName}'
  printf '\nALB access-log and timeout attributes:\n'
  aws elbv2 describe-load-balancer-attributes --region "$region" --load-balancer-arn "$alb_arn" \
    --query 'Attributes[?Key==`access_logs.s3.enabled` || Key==`idle_timeout.timeout_seconds`]'
fi

if [[ -n "$target_group_arn" ]]; then
  printf '\nTarget health:\n'
  aws elbv2 describe-target-health --region "$region" --target-group-arn "$target_group_arn" \
    --query 'TargetHealthDescriptions[].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason,Description:TargetHealth.Description}'
fi

if [[ -n "$asg_name" ]]; then
  printf '\nAuto Scaling group health and capacity:\n'
  aws autoscaling describe-auto-scaling-groups --region "$region" --auto-scaling-group-names "$asg_name" \
    --query 'AutoScalingGroups[].{Name:AutoScalingGroupName,Desired:DesiredCapacity,Min:MinSize,Max:MaxSize,GracePeriod:HealthCheckGracePeriod,Instances:Instances[].{Id:InstanceId,Health:HealthStatus,Lifecycle:LifecycleState,AZ:AvailabilityZone}}'
  printf '\nRecent scaling activities:\n'
  aws autoscaling describe-scaling-activities --region "$region" --auto-scaling-group-name "$asg_name" --max-items 20 \
    --query 'Activities[].{Start:StartTime,Status:StatusCode,Cause:Cause,Description:Description}'
fi

if [[ -n "$db_id" ]]; then
  printf '\nRDS status and storage configuration:\n'
  aws rds describe-db-instances --region "$region" --db-instance-identifier "$db_id" \
    --query 'DBInstances[].{Identifier:DBInstanceIdentifier,Status:DBInstanceStatus,Engine:Engine,MultiAZ:MultiAZ,AllocatedStorage:AllocatedStorage,MaxAllocatedStorage:MaxAllocatedStorage,Endpoint:Endpoint.Address}'
fi

printf '\nSnapshot complete. Redact identifiers and endpoint names before publication.\n'
