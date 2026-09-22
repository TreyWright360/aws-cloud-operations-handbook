# Availability Zone failure exercise

**Evidence status:** DOCUMENTATION ONLY
**Related project:** [Multi-AZ web infrastructure](https://github.com/TreyWright360/aws-multi-az-web-infrastructure)

## Question and impact

Can the application keep serving requests when capacity in one Availability Zone becomes unhealthy? Record the baseline target count and AZ placement, request success, and the time of the controlled fault.

## Current design limits

The ALB and ASG use subnets in multiple AZs, and the RDS module can enable Multi-AZ. The VPC module creates **one NAT gateway in the first public subnet** and routes all private subnets through it. Bootstrap of replacement instances may therefore depend on that AZ's NAT path. The web page is static and does not exercise RDS failover. No AZ failure test or measured recovery time is checked into the projects.

## Lab decision tree

1. Before fault injection, verify healthy targets in each intended AZ and confirm enough capacity remains if one AZ is lost.
2. Simulate loss of application targets in one AZ using an approved reversible lab method. Do not claim this is a complete physical AZ outage.
3. Observe target health, ALB request success, ASG replacement activity, and whether remaining capacity handles the bounded traffic.
4. Restore the targets. Verify placement, steady target health, and repeated client requests.
5. For a deeper exercise, separately test RDS failover and private-subnet egress; do not infer either from the static web page.

## Evidence required

Capture baseline and fault target placement, request timestamps, CloudWatch graphs, ASG events, recovery request, and the measured elapsed time. Record precisely which part of the AZ dependency chain was simulated. A regional recovery claim needs a separate regional exercise.
