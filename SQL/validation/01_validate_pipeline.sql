-- FP&A Budget vs Actual | Validation Suite
-- MySQL 8.0+
-- These checks are intended to be run after the cleaning and modeling stages.
-- A healthy run should return zero rows for duplicate/orphan tests.

USE fpna_budget_actual;

-- Population reconciliation.
SELECT 'raw_source' AS layer, COUNT(*) AS row_count FROM stg_budget_actual
UNION ALL SELECT 'analytical_working', COUNT(*) FROM wrk_budget_actual
UNION ALL SELECT 'clean_wide', COUNT(*) FROM clean_budget_actual
UNION ALL SELECT 'long_budget_actual', COUNT(*) FROM budget_actual_long
UNION ALL SELECT 'fact', COUNT(*) FROM fact_budget_actual;

-- Business grain.
SELECT Department, FullDate, COUNT(*) AS row_count
FROM clean_budget_actual
GROUP BY Department, FullDate
HAVING COUNT(*) > 1;

-- Fact grain.
SELECT DepartmentID, ScenarioID, DateID, COUNT(*) AS row_count
FROM fact_budget_actual
GROUP BY DepartmentID, ScenarioID, DateID
HAVING COUNT(*) > 1;

-- Scenario coverage: every clean source row should create one Budget and one Actual row.
SELECT Scenario, COUNT(*) AS row_count
FROM budget_actual_long
GROUP BY Scenario
ORDER BY Scenario;

-- Referential integrity.
SELECT COUNT(*) AS orphan_department_rows
FROM fact_budget_actual f
LEFT JOIN dim_department d ON d.DepartmentID=f.DepartmentID
WHERE d.DepartmentID IS NULL;

SELECT COUNT(*) AS orphan_scenario_rows
FROM fact_budget_actual f
LEFT JOIN dim_scenario s ON s.ScenarioID=f.ScenarioID
WHERE s.ScenarioID IS NULL;

SELECT COUNT(*) AS orphan_date_rows
FROM fact_budget_actual f
LEFT JOIN dim_date d ON d.DateID=f.DateID
WHERE d.DateID IS NULL;

-- Final financial null profile.
SELECT
    SUM(Revenue IS NULL) AS null_revenue,
    SUM(COGS IS NULL) AS null_cogs,
    SUM(Shipping IS NULL) AS null_shipping,
    SUM(Salary IS NULL) AS null_salary,
    SUM(Taxes IS NULL) AS null_taxes
FROM fact_budget_actual;

-- Date coverage.
SELECT MIN(FullDate) AS min_date, MAX(FullDate) AS max_date,
       COUNT(DISTINCT FullDate) AS distinct_dates
FROM dim_date;
