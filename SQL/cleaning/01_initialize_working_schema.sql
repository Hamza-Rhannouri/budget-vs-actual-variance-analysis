-- FP&A Budget vs Actual | 01 — Initialize Working Schema
-- MySQL 8.0+
-- Purpose: create an isolated project schema and preserve the source as a
-- working copy before any transformation is applied.
--
-- Import data/raw/bdac.csv into fpna_source.budget_actual_raw first.
-- The portfolio source contains 300 raw observations. The historical analytical
-- population used by the report contains 253 observations.

CREATE DATABASE IF NOT EXISTS fpna_source;
CREATE DATABASE IF NOT EXISTS fpna_budget_actual;

USE fpna_budget_actual;

DROP TABLE IF EXISTS stg_budget_actual;
CREATE TABLE stg_budget_actual LIKE fpna_source.budget_actual_raw;

INSERT INTO stg_budget_actual
SELECT *
FROM fpna_source.budget_actual_raw;

-- Preserve the source snapshot and make the analytical scope explicit.
DROP TABLE IF EXISTS analytical_scope;
CREATE TABLE analytical_scope (
    Department VARCHAR(50) NOT NULL,
    RawDate VARCHAR(80) NOT NULL,
    PRIMARY KEY (Department, RawDate)
) ENGINE=InnoDB;

INSERT INTO analytical_scope (Department, RawDate)
SELECT TRIM(Department), TRIM(Date)
FROM stg_budget_actual
WHERE (TRIM(Department), TRIM(Date)) NOT IN (
    ('IT', 'Saturday,February 06,2021'),
('Operations', 'Wednesday,February 24,2021'),
('Operations', 'Monday,March 15,2021'),
('HR', 'Thursday,April 08,2021'),
('IT', 'Tuesday,June 08,2021'),
('Marketing', 'Monday,June 14,2021'),
('Operations', 'Saturday,August 14,2021'),
('Marketing', 'Friday,August 27,2021'),
('Sales', 'Saturday,October 02,2021'),
('Operations', 'Friday,January 14,2022'),
('Marketing', 'Thursday,January 20,2022'),
('Operations', 'Thursday,March 10,2022'),
('HR', 'Friday,April 15,2022'),
('Operations', 'Wednesday,May 04,2022'),
('Sales', 'Saturday,May 28,2022'),
('Sales', 'Friday,June 03,2022'),
('Sales', 'Friday,September 09,2022'),
('Marketing', 'Wednesday,September 21,2022'),
('HR', 'Sunday,October 16,2022'),
('IT', 'Sunday,March 05,2023'),
('Operations', 'Saturday,March 11,2023'),
('Operations', 'Thursday,March 23,2023'),
('IT', 'Tuesday,April 04,2023'),
('Operations', 'Saturday,April 29,2023'),
('HR', 'Monday,June 05,2023'),
('Sales', 'Tuesday,July 11,2023'),
('HR', 'Wednesday,November 29,2023'),
('Sales', 'Friday,December 29,2023'),
('Sales', 'Thursday,January 04,2024'),
('IT', 'Wednesday,January 10,2024'),
('Operations', 'Saturday,February 10,2024'),
('IT', 'Wednesday,February 28,2024'),
('Marketing', 'Sunday,March 24,2024'),
('IT', 'Thursday,April 11,2024'),
('Sales', 'Wednesday,April 17,2024'),
('Operations', 'Tuesday,April 23,2024'),
('HR', 'Saturday,August 17,2024'),
('Sales', 'Friday,August 23,2024'),
('Marketing', 'Thursday,December 05,2024'),
('HR', 'Tuesday,December 17,2024'),
('Sales', 'Sunday,February 16,2025'),
('Sales', 'Thursday,March 06,2025'),
('Sales', 'Monday,March 31,2025'),
('Sales', 'Tuesday,September 30,2025'),
('Operations', 'Monday,October 06,2025'),
('Operations', 'Saturday,October 18,2025'),
('Sales', 'Tuesday,November 18,2025')
);

CREATE INDEX ix_scope_department_date
    ON analytical_scope (Department, RawDate);

SELECT COUNT(*) AS source_rows FROM stg_budget_actual;
SELECT COUNT(*) AS analytical_scope_rows FROM analytical_scope;
