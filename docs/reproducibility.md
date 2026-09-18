# Reproducibility Guide

A recruiter or reviewer can inspect the project without access to the original development environment.

### SQL

Import the raw CSV into a table named `fpna_source.budget_actual_raw`, then execute the SQL files in numerical order. The scripts create the project schema, working tables, cleaned financial table, long-format analytical table, dimensions, fact table, and validation checks.

### Power BI

The included PBIX contains the report artifact. Because MySQL connection settings are environment-specific, the local connection may need to be repointed before refreshing.

### Expected row flow

```text
Raw source                 300
Historical analytical      253
Clean analytical           253
Budget + Actual            506
Fact                       506
```
