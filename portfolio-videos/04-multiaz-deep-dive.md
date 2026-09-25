# Video 4: Multi-AZ Web Infrastructure Deep Dive

> **Platform:** YouTube (long-form) / LinkedIn (cut down)
> **Duration:** 4–6 minutes
> **Repo:** [aws-multi-az-web-infrastructure](https://github.com/TreyWright360/aws-multi-az-web-infrastructure)
> **Evidence:** [evidence/multi-az-instance-replacement/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/multi-az-instance-replacement/INDEX.md)

---

## 0:00–0:20 — Hook
- **Visual:** Architecture diagram — 2 AZs, ALB, 2× t3.small EC2, Multi-AZ RDS, single NAT gateway.
- **Say this:**
  > "This is a standard 'highly available' web tier — two availability zones, an application load balancer, Multi-AZ RDS. Looks resilient on paper. I deployed it for real and broke the one piece that isn't."

## 0:20–1:00 — What's actually deployed
- **Visual:** `terraform apply` output scroll, then AWS console — target group showing 2 healthy targets.
- **Say this:**
  > "`prod.tfvars` — two EC2 instances across two AZs, Multi-AZ RDS for automatic database failover, an ALB health-checking both targets. Baseline healthy state, confirmed."
- **Show on screen:** baseline `curl` loop returning 200, timestamped.

## 1:00–2:00 — The architectural flaw
- **Visual:** Zoom into `modules/vpc/main.tf` — a single NAT gateway and single route table shared across both AZs.
- **Say this:**
  > "Here's the flaw I didn't fix — I documented it instead. Both AZs share one NAT gateway. That's the one thing in this diagram that isn't actually multi-AZ. If it fails, both subnets lose outbound internet at once, no matter how many EC2 instances or AZs you have."

## 2:00–3:15 — The fault injection
- **Visual:** Terminal — command that forces the NAT gateway into a failure state, then a live timer overlay starting.
- **Say this:**
  > "I killed it on purpose. Baseline recovery time before this test was 2 minutes 8 seconds for a normal instance replacement. This test is different — it's a NAT crash-loop, and outbound-dependent health checks start failing within seconds."
- **Show on screen:** CloudWatch/ALB target health flipping unhealthy, timestamped.

## 3:15–4:00 — Recovery, measured
- **Visual:** Terminal timer stops at the fix; ALB targets flip back to healthy.
- **Say this:**
  > "Recovery measured at 6 minutes for the crash-loop scenario, and 2 minutes 40 seconds once the fix path was applied directly. Both numbers are in the evidence file with exact timestamps — not rounded, not estimated after the fact."
- **Show on screen:** [evidence INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/multi-az-instance-replacement/INDEX.md) table.

## 4:00–4:40 — What I'd actually fix
- **Visual:** CASE-STUDY.md "Production improvements" section.
- **Say this:**
  > "The real fix is a NAT gateway per AZ — it costs more, and that trade-off is exactly why I didn't just silently 'fix' the diagram. I wanted the video and the evidence to show the actual failure mode teams hit when they assume 'Multi-AZ' means every component is redundant."

## 4:40–5:00 — Close
- **Visual:** Teardown terminal output — `terraform destroy`, 0 resources remaining confirmed.
- **Say this:**
  > "Torn down and verified clean afterward — no orphaned NAT gateways, EIPs, or RDS instances left billing."

---

## Production notes
- Reuse footage from the actual lab run where possible; if the live AWS console isn't re-creatable, the evidence file's exact numbers must still appear on screen verbatim.
- Don't round 2m8s / 2m40s / 6min to "about 2 minutes" — the precision is the credibility signal.
