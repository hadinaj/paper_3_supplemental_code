-- 10_load_icu_ed_tables.sql
-- Loads the MIMIC-IV Demo ICU module and the MIMIC-IV-ED Demo tables into DuckDB.
--
-- Purpose:
-- These modules are analyzed as an extension of the hospital-module application.
-- They are used to examine relationships within each module and between each
-- module and the hospital module (see 12_export_extension_relationship_checks.sql).
--
-- Input:
--   data/raw/mimic-iv-clinical-database-demo-2.2/icu/*.csv.gz   (MIMIC-IV Clinical Database Demo v2.2)
--   data/raw/mimic-iv-ed-demo-2.2/ed/*.csv.gz                    (MIMIC-IV-ED Demo v2.2)
--
-- Output:
--   DuckDB tables in the icu and ed schemas.
--
-- Requires: sql/main/05_load_all_hosp_tables.sql (the extension checks link to hosp).

CREATE SCHEMA IF NOT EXISTS icu;

CREATE OR REPLACE TABLE icu.caregiver AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/caregiver.csv.gz');

CREATE OR REPLACE TABLE icu.chartevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/chartevents.csv.gz');

CREATE OR REPLACE TABLE icu.d_items AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/d_items.csv.gz');

CREATE OR REPLACE TABLE icu.datetimeevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/datetimeevents.csv.gz');

CREATE OR REPLACE TABLE icu.icustays AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/icustays.csv.gz');

CREATE OR REPLACE TABLE icu.ingredientevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/ingredientevents.csv.gz');

CREATE OR REPLACE TABLE icu.inputevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/inputevents.csv.gz');

CREATE OR REPLACE TABLE icu.outputevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/outputevents.csv.gz');

CREATE OR REPLACE TABLE icu.procedureevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/icu/procedureevents.csv.gz');

CREATE SCHEMA IF NOT EXISTS ed;

CREATE OR REPLACE TABLE ed.diagnosis AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-ed-demo-2.2/ed/diagnosis.csv.gz');

CREATE OR REPLACE TABLE ed.edstays AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-ed-demo-2.2/ed/edstays.csv.gz');

CREATE OR REPLACE TABLE ed.medrecon AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-ed-demo-2.2/ed/medrecon.csv.gz');

CREATE OR REPLACE TABLE ed.pyxis AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-ed-demo-2.2/ed/pyxis.csv.gz');

CREATE OR REPLACE TABLE ed.triage AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-ed-demo-2.2/ed/triage.csv.gz');

CREATE OR REPLACE TABLE ed.vitalsign AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-ed-demo-2.2/ed/vitalsign.csv.gz');
