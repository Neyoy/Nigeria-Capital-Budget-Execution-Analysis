# Nigeria Federal Capital Budget Execution Analysis

## Project Overview

A data-driven evaluation of Nigeria's federal capital budget execution
from 2020 to 2024 across five priority sectors using official reports
from the Budget Office of the Federation.

**Core Questions:**
- Are approved capital allocations credibly funded?
- Are released funds efficiently converted into executed projects?
- Does increased funding automatically translate into better outcomes?

---

## Tools

- MySQL 8.0
- Power BI Desktop

## Dataset

Budget Office of the Federation — Official Capital Budget Utilization Reports (2020–2024)
5 fiscal years | 5 priority sectors | MDA-level granularity

---

## Key Findings

- Overall approved capital utilization: **67.78%**, highlighting a significant gap between appropriation and execution
- **Defence** accounts for 40% of total capital spending and records **96% spending efficiency**
- **Agriculture** received **142% cash backing** but achieved only **66% utilization efficiency**
- **Education** and **Health** recorded proportional absorption gaps of **37.5%** and **31.5%** respectively
- Strong cash backing does not consistently translate into proportional execution outcomes

---

## Contents

| File | Description |
|------|-------------|
| `budget_execution_analysis_complete.sql` | Complete MySQL pipeline including stage tables, fact table, sector mapping, KPI views and validation queries |

---

## Pipeline Structure

| Table / View | Grain | Purpose |
|---|---|---|
| `capital_utilization_stage_*` | MDA / Year | Raw annual backups — source data never modified |
| `capital_utilization_fact` | MDA / Year | Unified fact table consolidating all five fiscal years |
| `MDA_to_sector_mapping` | MDA | Maps each MDA to one of five priority sectors |
| `vw_execution_base` | MDA / Year | Standardized base layer with consistent decimal types |
| `vw_execution_kpi` | MDA / Year | KPI-enriched view with performance indicators per MDA |
| `vw_sector_year_summary` | Sector / Year | Aggregated output view for dashboard and trend analysis |

---

## Dashboard

The interactive Power BI dashboard is available here:
[View Dashboard](https://app.powerbi.com/view?r=eyJrIjoiOGY3YzdjYjctZGEwZi00ZDBkLWI3NjMtNmExZDQyNjc0NDhkIiwidCI6Ijc2MTk0OTUzLTA1ZTMtNDZlNi1hMmI5LTQ3NmFkOGE5NGQ2ZSJ9)

## Portfolio

Full project write-up including methodology, findings and
analytical decisions is available here:
[View Portfolio](https://raheemwaliyi79.wixsite.com/my-site-1)
