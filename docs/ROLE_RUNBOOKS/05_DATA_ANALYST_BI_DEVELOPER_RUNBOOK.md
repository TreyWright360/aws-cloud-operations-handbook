# Role Runbook: Data Analyst & BI Developer

**Target Job Titles:** Data Analyst | Business Intelligence Developer | Power BI / SQL Specialist  
**Core Responsibility:** Resolving data model refresh failures, detecting upstream schema drift, and optimizing slow DAX/SQL queries for executive dashboards.

---

## 🚨 Scenario: Scheduled Power BI Semantic Model Refresh Failure

* **Trigger:** Power BI Service Alert: `Scheduled refresh failed for Business_360_Executive_Dashboard. Error: Column 'Customer_ID' not found in source schema.`
* **Business Impact:** Executive morning standup dashboards are out of date by 24 hours.

---

## 🛠️ Step-by-Step Resolution Protocol

### Phase 1: Upstream Schema Drift & Pipeline Inspection
1. **Identify the Broken Source Query:**
   * Open Power BI Desktop $\rightarrow$ Power Query Editor $\rightarrow$ locate the failing M-query transformation step.
2. **Inspect Upstream SQL / Lakehouse Table:**
   * Query database metadata to see if a recent upstream migration renamed or dropped the column:
     ```sql
     SELECT column_name, data_type 
     FROM information_schema.columns 
     WHERE table_name = 'customers';
     ```

### Phase 2: Query Refactoring & DAX Optimization
1. **Patch Power Query M-Script:**
   * Use robust column selection (`Table.SelectColumns(..., MissingField.Ignore)`) to prevent hard crashes when optional metadata changes.
2. **Profile and Optimize Slow DAX Calculations (DAX Studio):**
   * Run DAX Studio Server Timings on slow visual measures.
   * Replace iterative functions (`FILTER(ALL(...))`) with high-speed filter context modifiers (`KEEPFILTERS()`, `CALCULATE()`).

### Phase 3: Manual Refresh & Gateway Verification
1. **Trigger On-Demand Gateway Refresh:**
   * Trigger semantic model refresh via Power BI REST API or Web Portal.
2. **Validate Business Metric Consistency:**
   * Spot-check Total Revenue and Active User counts against production SQL raw tables to ensure accuracy.

---

## 🎤 How to Explain This Runbook in Interviews
> *"Data analysis isn't just making pretty charts; it's data integrity. When a dashboard refresh breaks due to upstream schema drift, my runbook isolates the offending transformation in Power Query, fixes the column mappings, optimizes the DAX measures with DAX Studio, and reconciles the numbers against raw SQL tables."*
