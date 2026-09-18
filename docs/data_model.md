# Data Model

## Fact grain

**One row per Department × Date × Scenario.**

## Star schema

```text
                 dim_department
                       │
                       ▼
dim_date ───── fact_budget_actual ───── dim_scenario
```

## Fact measures

- Revenue
- COGS
- Shipping
- Salary
- Taxes

## Derived financial logic

The semantic layer derives gross profit, operating profit, net profit, margins, Budget vs Actual variance, and driver decomposition from the additive fact measures.

## Why this model

The design separates descriptive dimensions from financial measures, gives the fact table a declared grain, and supports clean slicing by department, scenario, and date in Power BI.
