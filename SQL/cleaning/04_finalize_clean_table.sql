-- FP&A Budget vs Actual | 04 — Impute Missing Financial Values
-- MySQL 8.0+
-- Purpose: apply the project's department-level median treatment to missing
-- financial observations, then publish the clean wide analytical table.

USE fpna_budget_actual;

DROP TABLE IF EXISTS clean_budget_actual;

CREATE TABLE clean_budget_actual AS
WITH metric_long AS (
    SELECT source_row_id, Department, FullDate, 'Budget_Revenue' AS metric, Budget_Revenue AS value FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Actual_Revenue', Actual_Revenue FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Budget_COGS', Budget_COGS FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Actual_COGS', Actual_COGS FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Budget_Shipping', Budget_Shipping FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Actual_Shipping', Actual_Shipping FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Budget_Salary', Budget_Salary FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Actual_Salary', Actual_Salary FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Budget_Taxes', Budget_Taxes FROM stg_typed_budget_actual
    UNION ALL SELECT source_row_id, Department, FullDate, 'Actual_Taxes', Actual_Taxes FROM stg_typed_budget_actual
),
ranked AS (
    SELECT
        Department,
        metric,
        value,
        ROW_NUMBER() OVER (PARTITION BY Department, metric ORDER BY value) AS rn,
        COUNT(*) OVER (PARTITION BY Department, metric) AS n
    FROM metric_long
    WHERE value IS NOT NULL
),
medians AS (
    SELECT Department, metric, AVG(value) AS median_value
    FROM ranked
    WHERE rn IN (FLOOR((n + 1) / 2), FLOOR((n + 2) / 2))
    GROUP BY Department, metric
),
filled AS (
    SELECT
        t.source_row_id,
        t.Department,
        t.FullDate,
        t.Budget_Revenue,
        t.Actual_Revenue,
        t.Budget_COGS,
        t.Actual_COGS,
        t.Budget_Shipping,
        t.Actual_Shipping,
        t.Budget_Salary,
        t.Actual_Salary,
        t.Budget_Taxes,
        t.Actual_Taxes,
        MAX(CASE WHEN m.metric='Budget_Revenue' THEN m.median_value END) AS med_Budget_Revenue,
        MAX(CASE WHEN m.metric='Actual_Revenue' THEN m.median_value END) AS med_Actual_Revenue,
        MAX(CASE WHEN m.metric='Budget_COGS' THEN m.median_value END) AS med_Budget_COGS,
        MAX(CASE WHEN m.metric='Actual_COGS' THEN m.median_value END) AS med_Actual_COGS,
        MAX(CASE WHEN m.metric='Budget_Shipping' THEN m.median_value END) AS med_Budget_Shipping,
        MAX(CASE WHEN m.metric='Actual_Shipping' THEN m.median_value END) AS med_Actual_Shipping,
        MAX(CASE WHEN m.metric='Budget_Salary' THEN m.median_value END) AS med_Budget_Salary,
        MAX(CASE WHEN m.metric='Actual_Salary' THEN m.median_value END) AS med_Actual_Salary,
        MAX(CASE WHEN m.metric='Budget_Taxes' THEN m.median_value END) AS med_Budget_Taxes,
        MAX(CASE WHEN m.metric='Actual_Taxes' THEN m.median_value END) AS med_Actual_Taxes
    FROM stg_typed_budget_actual t
    LEFT JOIN medians m ON m.Department=t.Department
    GROUP BY t.source_row_id, t.Department, t.FullDate,
        t.Budget_Revenue, t.Actual_Revenue, t.Budget_COGS, t.Actual_COGS,
        t.Budget_Shipping, t.Actual_Shipping, t.Budget_Salary, t.Actual_Salary,
        t.Budget_Taxes, t.Actual_Taxes
)
SELECT
    source_row_id,
    Department,
    FullDate,
    COALESCE(Budget_Revenue, med_Budget_Revenue) AS Budget_Revenue,
    COALESCE(Actual_Revenue, med_Actual_Revenue) AS Actual_Revenue,
    COALESCE(Budget_COGS, med_Budget_COGS) AS Budget_COGS,
    COALESCE(Actual_COGS, med_Actual_COGS) AS Actual_COGS,
    COALESCE(Budget_Shipping, med_Budget_Shipping) AS Budget_Shipping,
    COALESCE(Actual_Shipping, med_Actual_Shipping) AS Actual_Shipping,
    COALESCE(Budget_Salary, med_Budget_Salary) AS Budget_Salary,
    COALESCE(Actual_Salary, med_Actual_Salary) AS Actual_Salary,
    COALESCE(Budget_Taxes, med_Budget_Taxes) AS Budget_Taxes,
    COALESCE(Actual_Taxes, med_Actual_Taxes) AS Actual_Taxes
FROM filled;

ALTER TABLE clean_budget_actual
    MODIFY source_row_id INT NOT NULL,
    MODIFY Department VARCHAR(50) NOT NULL,
    MODIFY FullDate DATE NOT NULL,
    MODIFY Budget_Revenue DECIMAL(18,2), MODIFY Actual_Revenue DECIMAL(18,2),
    MODIFY Budget_COGS DECIMAL(18,2), MODIFY Actual_COGS DECIMAL(18,2),
    MODIFY Budget_Shipping DECIMAL(18,2), MODIFY Actual_Shipping DECIMAL(18,2),
    MODIFY Budget_Salary DECIMAL(18,2), MODIFY Actual_Salary DECIMAL(18,2),
    MODIFY Budget_Taxes DECIMAL(18,2), MODIFY Actual_Taxes DECIMAL(18,2),
    ADD PRIMARY KEY (source_row_id),
    ADD UNIQUE KEY uq_department_date (Department, FullDate);

SELECT COUNT(*) AS clean_rows FROM clean_budget_actual;
