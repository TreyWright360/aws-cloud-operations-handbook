# Role Runbook 06: Cybersecurity Governance, Risk, and Compliance (GRC) Analyst

## 🎯 Target Job Profile
* **Target Roles:** GRC Analyst, Information Security Compliance Specialist, Third-Party Risk Analyst (TPRM), SOC 2 / ISO 27001 Readiness Consultant.
* **Core Competencies:** SOC 2 Type II, ISO/IEC 27001:2022, NIST CSF 2.0, NIST AI RMF, Risk Assessments, Business Impact Analysis (BIA), Policy Authoring, Auditor Evidence Management (PBC).

---

## 🚨 Production Compliance Emergency: Major Non-Conformance Discovery Prior to SOC 2 Type II External Audit

### Scenario Overview
During the final pre-audit internal review (2 weeks prior to the AICPA external audit window closing), you discover that a newly deployed microservice processing customer PII lacks mandatory database-level encryption at rest, and 12 developer accounts bypassed quarterly access reviews.

```
┌────────────────────────────────────────────────────────────────────────┐
│ 1. INCIDENT TRIAGE: Evaluate breach vs. compliance exception risk      │
├────────────────────────────────────────────────────────────────────────┤
│ 2. IMMEDIATE CONTAINMENT: Deploy emergency compensating controls       │
├────────────────────────────────────────────────────────────────────────┤
│ 3. ROOT CAUSE & CORRECTIVE ACTION: Enforce automated IaC guardrails    │
├────────────────────────────────────────────────────────────────────────┤
│ 4. AUDIT DISCLOSURE & EVIDENCE PACKAGING: Defend with auditor          │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Step-by-Step Incident Resolution Playbook

### Step 1: Emergency Risk Evaluation & Inherent Risk Scoring
* **Asset:** `prod-customer-profile-db` (PostgreSQL RDS instance).
* **Deficiency:** Unencrypted database storage (`storage_encrypted = false`); bypassed quarterly user access review.
* **Inherent Risk Score:** $4 \times 5 = 20$ (Critical - Potential audit qualification / SOC 2 exception).

### Step 2: Compensating Controls & Immediate Containment
1. **Network Isolation:** Verify database is contained within a private VPC subnet with zero public internet routing (`associate_public_ip_address = false`).
2. **Access Revocation:** Immediately suspend the 12 stale developer accounts via IAM Identity Center / IdP and conduct an emergency out-of-band user access certification.
3. **Database Migration:** Create an encrypted snapshot using AWS KMS CMK, restore the snapshot to an encrypted target database, and point application connection pools to the encrypted replica during a 15-minute maintenance window.

### Step 3: Implement Preventative Shift-Left Governance (IaC Guardrails)
Add automated OPA / tfsec policy check to the CI/CD deployment pipeline to block any unencrypted database deployment at code commit:

```terraform
# Enforced Terraform Standard for SOC 2 CC6.6 & CC6.7
resource "aws_db_instance" "production" {
  identifier        = "prod-customer-profile-db"
  allocated_storage = 50
  engine            = "postgres"
  instance_class    = "db.t4g.medium"
  
  # Mandatory Encryption at Rest
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn
  
  # Audit Logging Enforced
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  deletion_protection             = true
  publicly_accessible             = false
}
```

### Step 4: Auditor Packaging & Evidence Management
1. **Document Corrective Action Plan (CAP):** Log the event in the GRC Risk Register with root cause (manual drift), containment time, and permanent fix.
2. **Management Representation Memo:** Provide external auditors with the formal change management ticket, snapshot verification logs, and updated CI/CD IaC automated blocking evidence.
3. **Outcome:** Auditor confirms compensating control sufficiency; issue documented as an internally resolved self-identified finding rather than a qualified adverse exception.

---

## 💼 Core GRC Interview Stories & Key Metrics

* **Audit Success Metric:** Led internal gap assessment across 64 SOC 2 controls, achieving zero auditor qualified exceptions.
* **Vendor Risk Throughput:** Streamlined Third-Party Risk Management (TPRM) intake process, reducing vendor review cycle time from 21 days to 5 business days using standardized SIG Lite scoring.
* **Cost / Revenue Impact:** Unlocked \$3.2M in pending enterprise B2B sales pipeline by delivering an attestation-ready SOC 2 Type II security package.
