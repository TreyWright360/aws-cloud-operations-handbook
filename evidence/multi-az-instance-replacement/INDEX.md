# Evidence: unhealthy-target replacement and NAT single-point-of-failure

Two labs run back to back against the deployed [`aws-multi-az-web-infrastructure`](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) stack (`prod.tfvars`: 2× `t3.small`, Multi-AZ RDS).

## Lab 1 — normal instance replacement (baseline)

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Code revision | `aws-multi-az-web-infrastructure@a00bfc7`, deployed via `deploy-production.yml` run [35888394224](https://github.com/TreyWright360/aws-multi-az-web-infrastructure/actions/runs/35888394224) |
| Failure injection | 17:00:25Z — terminated instance `i-0787698f503fa55a1` (running, healthy, in `us-east-1b`) directly via EC2 API |
| Observed symptom | Continuous `/health` polling every 10s throughout showed **zero downtime** — `HTTP 200` at every check (17:00:30 through 17:01:21) — the ALB routed all traffic to the remaining healthy instance in `us-east-1a` |
| Diagnosis | ASG scaling activity: replacement instance `i-03f29db4a12188dd9` launched at 17:01:07Z, 42s after termination |
| Recovery | Replacement instance passed the ALB `/health` check and joined the target group |
| Validation | 17:02:33Z — target group showed both instances `healthy` again; new instance confirmed in `us-east-1b` |
| Limits | Single-instance failure only; does not test simultaneous multi-instance loss or an actual AZ outage |

**Total recovery time: 2m 8s. Zero user-visible downtime.**

## Lab 2 — NAT gateway single point of failure (real finding)

The [multi-AZ README](https://github.com/TreyWright360/aws-multi-az-web-infrastructure) and [operations handbook](../../README.md) previously flagged, from reading the Terraform, that both private subnets share one route table pointing at a single NAT gateway in `us-east-1a`, and that instances install `httpd` via boot-time `dnf install` — meaning a replacement instance with no internet path can never become healthy. This lab proves it against the live stack instead of just the code.

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Code revision | same deploy as Lab 1 |
| Failure injection | 17:11:xx Z — removed the `0.0.0.0/0 → nat-0e8aa78e2ce2da52d` route from `rtb-085aadd3309047946` (the shared private route table). 17:11:30Z — terminated a running, healthy instance (`i-03f29db4a12188dd9`) to force a replacement to launch with no outbound internet path. |
| Observed symptom | Brief single-request blip (one `HTTP 000` timeout) during target deregistration, then the app kept serving `HTTP 200` throughout via the one remaining unaffected instance — a real user would not have noticed. The **replacement** instance, however, never became healthy. |
| Diagnosis | ASG scaling-activity log is the direct proof: replacement instance `i-03a788c7a53d8e27b` launched at 17:13:09Z, ran for exactly **6 minutes**, and was terminated at 17:19:09Z with recorded cause `"an ELB system health check failure"` — it never passed `/health` because `dnf install -y httpd` had no route to the package repository. A second replacement (`i-0904154682f6b7a34`, launched 17:19:11Z) was booting into the identical trap when the fix landed — this is the documented **Auto Scaling replacement loop**, reproduced on purpose, not simulated. |
| Recovery | 17:19:53Z — restored the `0.0.0.0/0 → NAT` route. Because the already-booting instance's user-data had already failed (it runs once at first boot and does not retry), it was terminated immediately (17:20:00Z) rather than waiting out its grace period, to force a clean relaunch with a working network path from boot. |
| Validation | New instance `i-071f08158188929cd` (launched 17:21:02Z) passed the ALB health check at 17:22:33Z — **2m 40s** from route restoration to a healthy target. Final state: 2/2 targets healthy, `curl /health` → `HTTP 200`, route table confirmed to have the NAT route active again. |
| Limits | This tests loss of the NAT egress path specifically, which is the same underlying dependency an actual `us-east-1a` impairment would break (the NAT gateway itself lives in that AZ) — it is not a literal AZ outage. Only one instance was replaced under the failure condition; simultaneous loss of both instances while NAT is down was not tested. |

## The finding, plainly

Despite running instances across two Availability Zones, this stack has a single point of failure: one NAT gateway, in one AZ, that every private-subnet instance depends on to finish booting. If that AZ (or just that NAT gateway) is impaired, **every future instance replacement fails**, even though the surviving old instances keep serving traffic in the meantime. The fix — one NAT gateway and one private route table per AZ — is a known, standard pattern; it just wasn't in the original code, and this lab is what surfaced it.

Route table, instances, and target group were returned to their pre-lab state (route restored, all instances healthy) by the end of the lab. The stack itself remains running for further testing/filming and has not been torn down.
