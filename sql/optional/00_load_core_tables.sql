-- 00_load_core_tables.sql
-- Loads a small set of selected MIMIC-IV Demo tables into a local DuckDB database.
--
-- Purpose:
-- This script provides an initial core-table loading step for testing the local
-- SQL/DuckDB workflow and demonstrating basic structural exploration.
--
-- Scope:
-- The selected tables represent central patient, admission, diagnosis,
-- laboratory, and ICU-stay structures:
--   - hosp.patients
--   - hosp.admissions
--   - hosp.diagnoses_icd
--   - hosp.d_icd_diagnoses
--   - hosp.labevents
--   - hosp.d_labitems
--   - icu.icustays
--
-- Note:
-- The main hospital-module structural exploration is performed in
-- 05_load_all_hosp_tables.sql. This script is retained as a smaller
-- core-table workflow for testing and demonstration purposes.

CREATE SCHEMA IF NOT EXISTS hosp;
CREATE SCHEMA IF NOT EXISTS icu;

CREATE OR REPLACE TABLE hosp.patients AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/patients.csv.gz');

CREATE OR REPLACE TABLE hosp.admissions AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/admissions.csv.gz');

CREATE OR REPLACE TABLE hosp.diagnoses_icd AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/diagnoses_icd.csv.gz');

CREATE OR REPLACE TABLE hosp.d_icd_diagnoses AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/d_icd_diagnoses.csv.gz');

CREATE OR REPLACE TABLE hosp.labevents AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/labevents.csv.gz');

CREATE OR REPLACE TABLE hosp.d_labitems AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/d_labitems.csv.gz');

CREATE OR REPLACE TABLE icu.icustays AS
SELECT *
FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/icustays.csv.gz');