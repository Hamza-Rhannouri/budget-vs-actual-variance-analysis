-- FP&A Budget vs Actual | 02 — Build Analytical Working Table
-- MySQL 8.0+
-- Purpose: isolate the historical analytical population before data-type
-- standardization. This mirrors the original working-copy approach while
-- making the scope transition explicit.

USE fpna_budget_actual;

DROP TABLE IF EXISTS wrk_budget_actual;

CREATE TABLE wrk_budget_actual AS
SELECT
    ROW_NUMBER() OVER (ORDER BY s.Department, s.Date) AS source_row_id,
    s.*
FROM stg_budget_actual AS s
JOIN analytical_scope AS a
  ON a.Department = TRIM(s.Department)
 AND a.RawDate = TRIM(s.Date);

ALTER TABLE wrk_budget_actual
    MODIFY source_row_id INT NOT NULL,
    ADD PRIMARY KEY (source_row_id),
    ADD INDEX ix_work_department_date (Department, Date);

-- Business-grain check: one analytical record per Department × Date.
SELECT Department, TRIM(Date) AS RawDate, COUNT(*) AS row_count
FROM wrk_budget_actual
GROUP BY Department, TRIM(Date)
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS analytical_working_rows
FROM wrk_budget_actual;
