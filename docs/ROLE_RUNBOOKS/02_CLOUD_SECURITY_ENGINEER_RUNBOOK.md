# Role Runbook: Cloud Security Engineer & DevSecOps

**Target Job Titles:** Cloud Security Engineer | DevSecOps Engineer | IAM & Cloud Infrastructure Security Specialist  
**Core Responsibility:** Enforcing Zero Trust guardrails, remediating IAM privilege escalations, and securing IaC before production deployment.

---

## 🚨 Scenario: Unauthorized Production IAM Policy Modification & S3 Public Exposure

* **Trigger:** AWS GuardDuty / SIEM Alert: `PrivilegeEscalation:IAMUser/AnomalousBehavior` and `S3:PublicAccessBlockConfigurationDisabled`.
* **Business Impact:** High risk of data breach, compliance violation (SOC 2 / GDPR), and regulatory exposure.

---

## 🛠️ Step-by-Step Incident Containment & Hardening Protocol

### Phase 1: Containment & Access Quarantine (Immediate)
1. **Revoke Active Sessions of the Compromised Principal:**
   * Attach an explicit inline Deny policy to cut off active STS credentials:
     ```bash
     aws iam put-user-policy --user-name <COMPROMISED_USER> \
       --policy-name EmergencyDenyAll \
       --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"*","Resource":"*"}]}'
     ```
2. **Re-Enable S3 Public Access Block Immediately:**
   ```bash
   aws s3api put-public-access-block --bucket <TARGET_BUCKET> \
     --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
   ```

### Phase 2: Forensics & CloudTrail Audit
1. **Filter CloudTrail for Event History:**
   * Determine exact API actions taken during the compromise window:
     ```bash
     aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=<COMPROMISED_USER> \
       --start-time $(date -v -2H -u +%s) --query 'Events[*].[EventTime,EventName,SourceIPAddress]' --output table
     ```
2. **Inspect S3 Object Access Logs:**
   * Confirm if any objects were accessed from external IP addresses during the exposure window.

### Phase 3: Shift-Left Prevention & IaC Hardening
1. **Implement Automated GuardDuty / AWS Config Auto-Remediation:**
   * Deploy EventBridge rule + Lambda to auto-re-enable S3 Public Access Blocks whenever disabled.
2. **Scan Terraform for Privilege Escalation Vectors:**
   * Scan codebase with tfsec/Checkov to enforce `block_public_acls = true` and ban `"Action": "*"` wildcards.

---

## 🎤 How to Explain This Runbook in Interviews
> *"In a Cloud Security role, minutes matter. When an anomalous IAM modification occurs, my runbook isolates the principal within 60 seconds by attaching an emergency `DenyAll` policy, locks down exposed storage, audits CloudTrail for data exfiltration evidence, and permanently eliminates the vector by embedding automated pre-deployment scanning into the Terraform CI/CD pipeline."*
