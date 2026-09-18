# Methodology

## 1. Source and scope

The raw synthetic CSV contains 300 observations. The original analytical model uses 253 observations. This release preserves that analytical population rather than changing the historical project definition.

## 2. Working-copy pattern

The SQL initializes an isolated project schema and creates a staging working table before transformations are applied. This keeps the source snapshot separate from transformation logic.

## 3. Data cleaning

Source financial values are initially treated as text so malformed tokens such as currency symbols and other non-numeric characters can be normalized before casting. Missing and invalid tokens become `NULL` and are subsequently handled with department-level median imputation.

The source date format includes a weekday prefix; the SQL explicitly removes that prefix before converting the remaining month/day/year string to a MySQL `DATE`.

## 4. Modeling

Budget and Actual measures are normalized into a scenario attribute. This produces two analytical rows per source record and supports a conventional star schema.

## 5. Semantic analysis

Power BI/DAX provides profitability measures, variance measures, margin analysis, period comparisons, waterfall-style driver decomposition, and sensitivity logic.
