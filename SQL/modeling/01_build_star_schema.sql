-- FP&A Budget vs Actual | 01 — Build Analytical Model
-- MySQL 8.0+
-- Grain: Department × Date × Scenario (BUDGET / ACTUAL)

USE fpna_budget_actual;

DROP TABLE IF EXISTS fact_budget_actual;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_scenario;
DROP TABLE IF EXISTS dim_department;
DROP TABLE IF EXISTS budget_actual_long;

CREATE TABLE budget_actual_long AS
SELECT source_row_id, Department, FullDate, 'BUDGET' AS Scenario,
       Budget_Revenue AS Revenue, Budget_COGS AS COGS,
       Budget_Shipping AS Shipping, Budget_Salary AS Salary, Budget_Taxes AS Taxes
FROM clean_budget_actual
UNION ALL
SELECT source_row_id, Department, FullDate, 'ACTUAL',
       Actual_Revenue, Actual_COGS, Actual_Shipping, Actual_Salary, Actual_Taxes
FROM clean_budget_actual;

ALTER TABLE budget_actual_long
    MODIFY source_row_id INT NOT NULL,
    MODIFY Department VARCHAR(50) NOT NULL,
    MODIFY FullDate DATE NOT NULL,
    MODIFY Scenario VARCHAR(6) NOT NULL,
    MODIFY Revenue DECIMAL(18,2), MODIFY COGS DECIMAL(18,2),
    MODIFY Shipping DECIMAL(18,2), MODIFY Salary DECIMAL(18,2), MODIFY Taxes DECIMAL(18,2),
    ADD INDEX ix_long_department_date (Department, FullDate),
    ADD INDEX ix_long_scenario (Scenario);

CREATE TABLE dim_department (
    DepartmentID INT NOT NULL AUTO_INCREMENT,
    Department VARCHAR(50) NOT NULL,
    PRIMARY KEY (DepartmentID),
    UNIQUE KEY uq_department (Department)
) ENGINE=InnoDB;

INSERT INTO dim_department (Department)
SELECT DISTINCT Department FROM budget_actual_long ORDER BY Department;

CREATE TABLE dim_scenario (
    ScenarioID INT NOT NULL AUTO_INCREMENT,
    Scenario VARCHAR(6) NOT NULL,
    PRIMARY KEY (ScenarioID),
    UNIQUE KEY uq_scenario (Scenario)
) ENGINE=InnoDB;

INSERT INTO dim_scenario (Scenario)
SELECT DISTINCT Scenario FROM budget_actual_long ORDER BY Scenario;

CREATE TABLE dim_date (
    DateID INT NOT NULL AUTO_INCREMENT,
    FullDate DATE NOT NULL,
    Year SMALLINT NOT NULL,
    Quarter TINYINT NOT NULL,
    Month TINYINT NOT NULL,
    MonthName VARCHAR(12) NOT NULL,
    PRIMARY KEY (DateID),
    UNIQUE KEY uq_full_date (FullDate)
) ENGINE=InnoDB;

INSERT INTO dim_date (FullDate, Year, Quarter, Month, MonthName)
SELECT DISTINCT FullDate, YEAR(FullDate), QUARTER(FullDate), MONTH(FullDate), MONTHNAME(FullDate)
FROM budget_actual_long
ORDER BY FullDate;

CREATE TABLE fact_budget_actual (
    DepartmentID INT NOT NULL,
    ScenarioID INT NOT NULL,
    DateID INT NOT NULL,
    Revenue DECIMAL(18,2),
    COGS DECIMAL(18,2),
    Shipping DECIMAL(18,2),
    Salary DECIMAL(18,2),
    Taxes DECIMAL(18,2),
    PRIMARY KEY (DepartmentID, ScenarioID, DateID),
    CONSTRAINT fk_fact_department FOREIGN KEY (DepartmentID) REFERENCES dim_department(DepartmentID),
    CONSTRAINT fk_fact_scenario FOREIGN KEY (ScenarioID) REFERENCES dim_scenario(ScenarioID),
    CONSTRAINT fk_fact_date FOREIGN KEY (DateID) REFERENCES dim_date(DateID)
) ENGINE=InnoDB;

INSERT INTO fact_budget_actual
    (DepartmentID, ScenarioID, DateID, Revenue, COGS, Shipping, Salary, Taxes)
SELECT d.DepartmentID, s.ScenarioID, dt.DateID,
       l.Revenue, l.COGS, l.Shipping, l.Salary, l.Taxes
FROM budget_actual_long l
JOIN dim_department d ON d.Department=l.Department
JOIN dim_scenario s ON s.Scenario=l.Scenario
JOIN dim_date dt ON dt.FullDate=l.FullDate;

SELECT COUNT(*) AS long_rows FROM budget_actual_long;
SELECT COUNT(*) AS fact_rows FROM fact_budget_actual;
