# Role Runbook: Site Reliability Engineer (SRE) & Cloud Operations

**Target Job Titles:** Site Reliability Engineer (SRE) | Cloud Operations Engineer | DevOps Support Specialist  
**Core Responsibility:** Maintaining 99.99% infrastructure availability, managing high-severity incident bridges, and executing zero-downtime rollbacks.

---

## 🚨 Scenario: ALB 504 / 503 Cascading Failure Post-Production Deployment

* **Trigger:** PagerDuty SEV-1 Alert: `HTTP 5xx Error Rate > 5%` and `TargetResponseTime > 30s` within 10 minutes of CI/CD deployment.
* **Business Impact:** Customer-facing web application is unreachable; checkout transactions are failing.

---

## 🛠️ Step-by-Step SEV-1 Incident Response Protocol

### Phase 1: Immediate Triage & Containment (First 3 Minutes)
1. **Declare SEV-1 Incident & Open Slack War Room:**
   * Post status: `"SEV-1 Declared: Elevating 5xx error rate post-deployment. Initiating immediate rollback."`
2. **Execute Emergency Deployment Rollback (Priority #1):**
   * Do NOT spend time debugging application code during an active SEV-1. Revert to the last known good commit immediately:
     ```bash
     git revert HEAD --no-edit && git push origin main
     # OR switch ALB Target Group traffic back to Blue environment
     ```

### Phase 2: Host & Target Group Stabilization
1. **Check Target Health State:**
   ```bash
   aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN> \
     --query 'TargetHealthDescriptions[?TargetHealth.State!=`healthy`]'
   ```
2. **Restart / Drain Impaired Compute Targets:**
   * If memory is exhausted, restart container tasks on ECS or trigger graceful instance recycle in AutoScaling Group.

### Phase 3: Post-Rollback Verification & Blameless Postmortem
1. **Verify Error Rate Returns to Baseline (0%):**
   * Check CloudWatch metric `HTTPCode_Target_5XX_Count = 0`.
2. **Preserve Ephemeral Logs for Forensics:**
   * Export crashed container logs from CloudWatch to S3 before containers are recycled.
3. **Draft Postmortem within 24 Hours:**
   * Document root cause using the 5 Whys framework and schedule engineering review.

---

## 🎤 How to Explain This Runbook in Interviews
> *"As an SRE, my primary metric is Mean Time to Recovery (MTTR). During a SEV-1 incident immediately following a release, my runbook dictates an instant, automated rollback to protect the user experience before diving into root-cause log forensics."*
