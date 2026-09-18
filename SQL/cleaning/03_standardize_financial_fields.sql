-- FP&A Budget vs Actual | 03 — Standardize Dates and Financial Fields
-- MySQL 8.0+
-- Purpose: remove source-system noise, normalize missing tokens, parse dates,
-- and cast financial measures to DECIMAL for reliable aggregation.

USE fpna_budget_actual;

DROP TABLE IF EXISTS stg_typed_budget_actual;

CREATE TABLE stg_typed_budget_actual AS
SELECT
    source_row_id,
    TRIM(Department) AS Department,
    STR_TO_DATE(
        SUBSTRING(TRIM(Date), LOCATE(',', TRIM(Date)) + 1),
        '%M %d,%Y'
    ) AS FullDate,

    CAST(NULLIF(REGEXP_REPLACE(TRIM(Budget_Revenue), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Budget_Revenue,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Actual_Revenue), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Actual_Revenue,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Budget_COGS), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Budget_COGS,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Actual_COGS), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Actual_COGS,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Budget_Shipping), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Budget_Shipping,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Actual_Shipping), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Actual_Shipping,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Budget_Salary), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Budget_Salary,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Actual_Salary), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Actual_Salary,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Budget_Taxes), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Budget_Taxes,
    CAST(NULLIF(REGEXP_REPLACE(TRIM(Actual_Taxes), '[^0-9.-]', ''), '') AS DECIMAL(18,2)) AS Actual_Taxes
FROM wrk_budget_actual;

ALTER TABLE stg_typed_budget_actual
    MODIFY source_row_id INT NOT NULL,
    MODIFY Department VARCHAR(50) NOT NULL,
    MODIFY FullDate DATE NOT NULL,
    ADD PRIMARY KEY (source_row_id),
    ADD INDEX ix_typed_department_date (Department, FullDate);

SELECT COUNT(*) AS typed_rows FROM stg_typed_budget_actual;
SELECT COUNT(*) AS invalid_dates
FROM stg_typed_budget_actual
WHERE FullDate IS NULL;
