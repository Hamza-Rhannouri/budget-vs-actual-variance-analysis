# FP&A Budget vs Actual — Variance & Sensitivity Analysis

## Executive summary

This project turns a messy synthetic financial dataset into an analytical model for **Budget vs Actual performance, profit-driver analysis, sensitivity testing, and management recommendations**.

The workflow covers the full analytical path: **raw data → controlled analytical scope → SQL cleaning → dimensional modeling → DAX semantic measures → Power BI storytelling**.

> **Data:** synthetic portfolio data. No confidential or production company data is used.

## Business problem

A finance team needs more than a variance number. The useful question is **what changed, why did it change, and what happens if the underlying drivers move?**

The report answers:

- How is actual revenue tracking against budget?
- Which cost drivers are creating the largest unfavorable variances?
- Which departments are driving the profit gap?
- How sensitive is profit to changes in revenue and COGS assumptions?
- What management actions follow from the observed drivers?

## Analytical scope

The raw CSV contains **300 observations**. The historical analytical dataset used by the original model contains **253 observations**. The downstream Budget/Actual normalization therefore produces **506 rows**: one Budget and one Actual observation for each analytical record.

The release deliberately does not invent a new business rule for the 47 historical exclusions. The preserved analytical population is treated as the controlled input to the reproducible cleaning/modeling workflow.

## SQL workflow

The SQL is organized by analytical responsibility rather than by exported database-table names:

```text
sql/
├── cleaning/
│   ├── 01_initialize_working_schema.sql
│   ├── 02_build_working_copy.sql
│   ├── 03_standardize_financial_fields.sql
│   └── 04_finalize_clean_table.sql
├── modeling/
│   └── 01_build_star_schema.sql
└── validation/
    └── 01_validate_pipeline.sql
```

### Cleaning

The pipeline uses an isolated project schema and a working-copy pattern. Financial fields are standardized with regular expressions, invalid/missing tokens are converted to `NULL`, dates are parsed explicitly, and department-level median imputation is applied where financial values are missing.

### Modeling

The cleaned wide table is normalized into Budget/Actual scenario rows. The final star schema contains:

- `fact_budget_actual`
- `dim_department`
- `dim_scenario`
- `dim_date`

The declared fact grain is **Department × Date × Scenario** and is enforced with a composite primary key.

## Power BI report

The Power BI report contains four pages:

1. **Executive Overview** — headline profitability and Budget vs Actual performance.
2. **Profit Drivers** — explains the sources of profit variance.
3. **Sensitivity Analysis** — tests alternative revenue and COGS assumptions.
4. **Recommendations** — translates the financial analysis into management actions.

## Selected technical capabilities

- MySQL 8.0+ and CTEs
- Window functions for data-quality and median logic
- Regular-expression data cleaning
- Controlled working-table pattern
- Wide-to-long transformation
- Star-schema dimensional modeling
- Primary and foreign keys
- DAX measures for profitability and variance analysis
- Power BI financial storytelling
- Sensitivity/scenario analysis

## Repository structure

```text
FP&A_Budget_vs_Actual/
├── README.md
├── data/
│   ├── raw/bdac.csv
│   └── processed/
├── sql/
│   ├── cleaning/
│   ├── modeling/
│   └── validation/
├── dax/measures.dax
├── powerbi/FPNA_Budget_vs_Actual.pbix
├── screenshots/
└── docs/
```

## Reproduce the SQL workflow

1. Import `data/raw/bdac.csv` into `fpna_source.budget_actual_raw`.
2. Run the four scripts under `sql/cleaning/` in order.
3. Run `sql/modeling/01_build_star_schema.sql`.
4. Run `sql/validation/01_validate_pipeline.sql`.
5. Open the PBIX in Power BI Desktop and refresh the MySQL connection/model as appropriate for the local environment.

The PBIX is included as a portfolio artifact; connection credentials and local server details are not stored in the repository.
