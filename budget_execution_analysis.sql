-- ============================================================
-- PROJECT   : Nigeria Federal Capital Budget Execution Analysis
-- DATASET   : Budget Office of the Federation — Official Capital
--             Budget Utilization Reports (2020–2024)
-- TOOL      : MySQL
-- OBJECTIVE : Evaluate capital budget execution performance
--             across five priority sectors (Defence, Agriculture,
--             Transport, Health, Education) by measuring funding
--             credibility, utilization efficiency and
--             absorption gaps from 2020 to 2024

-- ============================================================
-- CORE QUESTIONS
-- 1. Are approved capital allocations credibly funded?
-- 2. Are released funds efficiently converted into
--    executed projects?
-- 3. Does increased funding automatically translate
--    into better outcomes?
-- ============================================================

-- PIPELINE OVERVIEW
-- ┌──────────────────────────────────────┐
-- │  Raw Annual Tables (2020 to 2024)    │  Source data
-- └──────────────────┬───────────────────┘
--                    │
-- ┌──────────────────▼───────────────────┐
-- │  Stage Tables (per year)             │  Raw backups
-- └──────────────────┬───────────────────┘
--                    │
-- ┌──────────────────▼───────────────────┐
-- │  capital_utilization_fact            │  Unified fact table
-- └──────────────────┬───────────────────┘
--                    │
-- ┌──────────────────▼───────────────────┐
-- │  MDA_to_sector_mapping               │  Sector classification
-- └──────────────────┬───────────────────┘
--                    │
-- ┌──────────────────▼───────────────────┐
-- │  vw_execution_base                   │  Standardized base view
-- └──────────────────┬───────────────────┘
--                    │
-- ┌──────────────────▼───────────────────┐
-- │  vw_execution_kpi                    │  KPI-enriched view
-- └──────────────────┬───────────────────┘
--                    │
-- ┌──────────────────▼───────────────────┐
-- │  vw_sector_year_summary              │  Aggregated output view
-- └──────────────────────────────────────┘


-- ============================================================
-- DATABASE SETUP
-- ============================================================
 CREATE DATABASE Nigeria_Public_Budget_Performance;

USE Nigeria_Public_Budget_Performance;

-- ============================================================
-- RAW DATA INSPECTION
-- Preview each annual source table before any transformation
-- ============================================================
SELECT * FROM `2020 capital budget utilization by mdas`;
SELECT * FROM `2021 capital budget utilization by mdas`;
SELECT * FROM `2022 capital budget utilization by mdas`;
SELECT * FROM `2023 capital budget utilization by mdas`;
SELECT * FROM `2024 capital budget utilization by mdas`;

-- ============================================================
-- STAGE TABLES
-- Copy each raw annual table into a dedicated stage table.
-- This preserves raw data integrity throughout the pipeline.
-- ============================================================
CREATE TABLE capital_utilization_stage_2020
LIKE `2020 capital budget utilization by mdas`;
INSERT capital_utilization_stage_2020
SELECT * 
FROM `2020 capital budget utilization by mdas`;

CREATE TABLE capital_utilization_stage_2021
LIKE `2021 capital budget utilization by mdas`;
INSERT capital_utilization_stage_2021
SELECT * 
FROM `2021 capital budget utilization by mdas`;

CREATE TABLE capital_utilization_stage_2022
LIKE `2022 capital budget utilization by mdas`;
INSERT capital_utilization_stage_2022
SELECT * 
FROM `2022 capital budget utilization by mdas`;

CREATE TABLE capital_utilization_stage_2023
LIKE `2023 capital budget utilization by mdas`;
INSERT capital_utilization_stage_2023
SELECT * 
FROM `2023 capital budget utilization by mdas`;

CREATE TABLE capital_utilization_stage_2024
LIKE `2024 capital budget utilization by mdas`;
INSERT capital_utilization_stage_2024
SELECT * 
FROM `2024 capital budget utilization by mdas`;

-- ============================================================
-- UNIFIED FACT TABLE
-- PURPOSE : Consolidate all five annual datasets into a single
--           structured fact table.
--           Comma characters are stripped from numeric fields
--           during insertion to ensure correct decimal storage.
--           Each row represents one MDA for one fiscal year.
-- GRAIN   : One row per fiscal year per MDA
-- ============================================================
CREATE TABLE capital_utilization_fact(
fiscal_year INT NOT NULL,
report_cutoff DATE NOT NULL,
mda VARCHAR(255) NOT NULL,
annual_appropriation DECIMAL(20,2),
total_released DECIMAL(20,2),
cash_backed DECIMAL(20,2),
utilized DECIMAL(20,2),
PRIMARY KEY(fiscal_year,mda)
);

-- INSERT THE 2020 CAPITAL UTILIZATIN INTO THE FACT TABLE
INSERT INTO capital_utilization_fact(
fiscal_year,
report_cutoff,
mda,
annual_appropriation,
total_released,
cash_backed,
utilized)
SELECT 
	2020 AS fiscal_year,
    '2021-03-31' AS report_cutoff,
    MDA,
    REPLACE(`Annual Appropriation`, ',', '') AS annual_appropriation,
    REPLACE(`Total Amount Released`, ',', '') AS total_released,
    REPLACE(`Total Amount Cash Backed`, ',', '') AS cash_backed,
    REPLACE(Utilization, ',', '')
FROM capital_utilization_stage_2020;

-- INSERT THE 2021 CAPITAL UTILIZATIN INTO THE FACT TABLE
INSERT INTO capital_utilization_fact (
 fiscal_year,
 report_cutoff,
 mda,
 annual_appropriation,
 total_released,
 cash_backed,
 utilized
 )
 SELECT
	 2021 AS fiscal_year,
	 '2022-05-31' AS report_cutoff,
	 MDA,
	 REPLACE(`Annual Appropriation`,',','') AS annual_appropriation,
	 REPLACE(`Total Amount Released`, ',','') AS total_released,
	 REPLACE(`Total Amount Cash Backed`, ',','') AS cash_backed,
	 REPLACE(Utilization,',','') AS utilized
FROM capital_utilization_stage_2021;

-- INSERT THE 2022 CAPITAL UTILIZATIN INTO THE FACT TABLE
INSERT INTO capital_utilization_fact(
fiscal_year,
report_cutoff,
mda,
annual_appropriation,
total_released,
cash_backed, 
utilized
)
SELECT
	2022 AS fiscal_year,
    '2022-12-31' AS report_cutoff,
    MDA,
    REPLACE(`Annual
Appropriation`, ',','') AS annual_appropriation,
    REPLACE(`Total Amount
Released`,',','') AS total_released,
    REPLACE(`Total Amount
Cash Backed`, ',','') AS cash_backed,
    REPLACE(`Utilization`, ',','') AS utilized
FROM capital_utilization_stage_2022;
 
 -- INSERT THE 2023 CAPITAL UTILIZATIN INTO THE FACT TABLE
 INSERT INTO capital_utilization_fact(
 fiscal_year,
 report_cutoff,
 mda,
 annual_appropriation,
 total_released,
 cash_backed,
 utilized
 )
 SELECT 
	 2023 AS fiscal_year,
	 '2023-12-31' AS report_cutoff,
	 MDA,
	 REPLACE(`Annual Appropriation`,',','') AS annual_appropriation,
	 REPLACE(`Total Amount Released`, ',','') AS total_released,
	 REPLACE(`Total Amount Cash Backed`,',','') AS cash_backed,
	 REPLACE(Utilization,',','') AS utilized
 FROM capital_utilization_stage_2023;
 
  -- INSERT THE 2024 CAPITAL UTILIZATIN INTO THE FACT TABLE
  INSERT INTO capital_utilization_fact(
  fiscal_year,
  report_cutoff,
  mda,
  annual_appropriation,
  total_released,
  cash_backed,
  utilized
  )
  SELECT
	2024 AS fiscal_year,
    '2025-06-30' AS report_cutoff,
    MDA,
    REPLACE(`Annual Appropriation`,',','') AS annual_appropriation,
    REPLACE(`Total Amount Released`,',','') AS total_released,
    REPLACE(`Total Amount Cash Backed`,',','') AS cash_backed,
    REPLACE(Utilization,',','') AS utilized
FROM capital_utilization_stage_2024;

-- ============================================================
--  SECTOR MAPPING TABLE
-- PURPOSE : Map each MDA to one of five priority sectors.
--           Only MDAs belonging to the five sectors under
--           analysis are included. All other MDAs are excluded
--           from downstream views and KPI calculations.
-- SECTORS : Defence, Agriculture, Transport, Health, Education
-- ============================================================
CREATE TABLE MDA_to_sector_mapping(
mda VARCHAR(250) PRIMARY KEY,
sector VARCHAR(200) NOT NULL
);


INSERT INTO MDA_to_sector_mapping (mda, sector) 
VALUES
('Agriculture', 'Agriculture'),
('Education', 'Education'),
('Defence', 'Defence'),
('Health', 'Health'),
('Transportation', 'Transport'),
('Transport', 'Transport');

-- Verify sector mapping loaded correctly
SELECT * FROM MDA_to_sector_mapping;

-- ============================================================
-- BASE EXECUTION VIEW
-- PURPOSE : Standardize raw capital utilization data by
--           attaching sector information to each MDA and
--           enforcing consistent decimal types before any
--           KPI calculations are applied.
--           All downstream views depend on this base layer.
-- SOURCE  : capital_utilization_fact + MDA_to_sector_mapping
-- GRAIN   : One row per fiscal year per MDA
-- ============================================================
CREATE VIEW vw_execution_base AS
SELECT
f.fiscal_year,
f.report_cutoff,
f.mda,
m.sector,
CAST(f.annual_appropriation AS DECIMAL(18,2)) AS annual_appropriation,
CAST(f.total_released AS DECIMAL(18,2)) AS total_released,
CAST(f.cash_backed AS DECIMAL(18,2)) AS cash_backed,
CAST(f.utilized AS DECIMAL(18,2)) AS utilized
FROM capital_utilization_fact AS f
JOIN MDA_to_sector_mapping AS m
ON f.mda = m.mda;


-- ============================================================
--  KPI-ENRICHED EXECUTION VIEW
-- PURPOSE : Translate raw execution data into interpretable
--           performance indicators. KPI logic is defined
--           once centrally here to prevent inconsistent
--           definitions across downstream analyses.
-- SOURCE  : vw_execution_base
-- GRAIN   : One row per fiscal year per MDA
-- METRICS :
--   funding_credibility_ratio   : Cash backed vs appropriation
--   utilization_efficiency      : Utilized vs cash backed
--   absorption_gap              : Unused cash-backed funds
--   execution_flag              : Execution behaviour category
-- ============================================================

CREATE VIEW vw_execution_kpi AS
SELECT
	fiscal_year,
	report_cutoff,
	mda,
	sector,
	annual_appropriation,
	total_released,
	cash_backed,
	utilized,

	/*
	 Funding credibility ratio
	Measure how much of approved capital was actually cash-backed.
	*/
	CASE 
	WHEN annual_appropriation > 0
	THEN cash_backed/annual_appropriation
	ELSE NULL
	END AS funding_credibility_ratio,

	/* 
	Utilization efficiency
	Measure the ability of sector to covert cash into actual spending.
	*/
	CASE 
	WHEN cash_backed > 0
	THEN utilized/cash_backed
	ELSE NULL
	END AS utilization_efficiency,

	/* 
	capital absorption gap
	measure unused cash-basked funds
	*/
	cash_backed - utilized AS absorption_gap,

	 /*
	Execution Behavior Classification
	Flags execution dynamics instead of hiding them
	*/
	CASE
	 WHEN cash_backed > annual_appropriation THEN 'Over-cash-backed'
	 WHEN cash_backed = annual_appropriation THEN 'Fully-backed'
	 WHEN cash_backed < annual_appropriation THEN 'Under-backed'
	 ELSE 'Unclassified'
	END AS execution_flag
FROM vw_execution_base;

-- ============================================================
--  SECTOR-YEAR SUMMARY VIEW
-- PURPOSE : Aggregate execution performance to sector level
--           for each fiscal year. This is the primary output
--           view for dashboard consumption and trend analysis.
-- SOURCE  : vw_execution_kpi
-- GRAIN   : One row per fiscal year per sector
-- METRICS :
--   sector_funding_credibility      : Sector-level cash backing ratio
--   sector_utilization_efficiency   : Sector-level spending efficiency
--   sector_capital_conversion_ratio : Approved to outcome ratio
--   sector_absorption_gap           : Absolute unused cash-backed funds
--   sector_absorption_gap_pct       : Proportional unused cash-backed
--   sector_execution_share          : Sector share of total annual spend
-- ============================================================

CREATE OR REPLACE VIEW vw_sector_year_summary AS
SELECT
fiscal_year,
sector,
SUM(annual_appropriation) AS sector_annual_appropriation,
SUM(cash_backed) AS sector_cash_backed,
SUM(utilized) AS sector_utilized,
/*
sector funding credibility
*/
CASE
WHEN SUM(annual_appropriation) > 0
THEN SUM(cash_backed)/SUM(annual_appropriation) 
ELSE NULL
END AS sector_funding_credibility,
/*
sector utilization efficiency
*/
CASE
WHEN SUM(cash_backed) > 0
THEN SUM(utilized)/SUM(cash_backed)
ELSE NULL
END AS sector_utilization_efficiency,
/* Capital conversion ratio (Approved → Outcome) */
CASE
WHEN SUM(annual_appropriation) > 0
THEN SUM(utilized)/SUM(annual_appropriation)
ELSE NULL
END AS sector_capital_conversion_ratio,
 /*
Sector Absorption Gap
*/
SUM(cash_backed) - SUM(utilized) AS sector_absorption_gap,
 /* 
 Proportional absorption gap */
 CASE
 WHEN SUM(cash_backed) > 0
 THEN (SUM(cash_backed) - SUM(utilized)) / SUM(cash_backed)
 ELSE NULL
 END AS sector_absorption_gap_pct,
 /* 
 Execution dominance share */
 SUM(utilized)/
 SUM(SUM(utilized)) OVER (PARTITION BY fiscal_year) AS sector_execution_share
FROM vw_execution_kpi
GROUP BY fiscal_year, sector;



-- ============================================================
--  ANALYTICAL VALIDATION QUERIES
-- PURPOSE : Confirm pipeline outputs are consistent and
-- ============================================================
-- Check funding credibility extremes
SELECT fiscal_year, sector, sector_funding_credibility
FROM vw_sector_year_summary
ORDER BY sector_funding_credibility DESC;

SELECT sector, 
ROUND(AVG(sector_funding_credibility),2) AS sector_funding_credibility
FROM vw_sector_year_summary
GROUP BY sector
ORDER BY sector_funding_credibility DESC;

--  utilization efficiency
SELECT fiscal_year, sector, 
	   ROUND(sector_utilization_efficiency,2)
FROM vw_sector_year_summary
ORDER BY sector_utilization_efficiency DESC;

SELECT sector, 
	   ROUND(AVG(sector_utilization_efficiency),2) AS avg_sector_utilization_efficiency
FROM vw_sector_year_summary
GROUP BY sector
ORDER BY avg_sector_utilization_efficiency DESC;


-- Check for negative utilization (should not exist)
SELECT *
FROM vw_execution_kpi
WHERE utilized < 0 OR cash_backed < 0;


-- ============================================================
-- FINAL DATABASE STRUCTURE
-- ============================================================
--
--  TABLE / VIEW                  GRAIN          PURPOSE
--  ─────────────────────────────────────────────────────────
--  capital_utilization_stage_  MDA/Year       Raw annual backups
--  capital_utilization_fact      MDA/Year       Unified fact table
--  MDA_to_sector_mapping         MDA            Sector classification
--  vw_execution_base             MDA/Year       Standardized base layer
--  vw_execution_kpi              MDA/Year       KPI-enriched MDA view
--  vw_sector_year_summary        Sector/Year    Aggregated output view

