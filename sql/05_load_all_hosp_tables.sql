-- 05_load_all_hosp_tables.sql
-- Loads all MIMIC-IV Demo hospital-module tables into a local DuckDB database.
--
-- Purpose:
-- This script prepares the main hospital-module dataset used for the Step 0
-- preparatory structural exploration workflow. The hospital module is the
-- primary scope of the manuscript demonstration.
--
-- Input:
-- Compressed MIMIC-IV Demo CSV files stored locally under:
-- data/raw/mimic-iv-clinical-database-demo-2.2/hosp/
--
-- Output:
-- DuckDB tables created under the hosp schema.
--
-- Note:
-- The raw CSV files are not modified. CREATE OR REPLACE TABLE creates local
-- DuckDB tables from the compressed CSV files so that subsequent scripts can
-- inspect table structures, identifiers, and candidate relationships.
CREATE SCHEMA IF NOT EXISTS hosp;

CREATE OR REPLACE TABLE hosp.admissions AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/admissions.csv.gz');

CREATE OR REPLACE TABLE hosp.d_hcpcs AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/d_hcpcs.csv.gz');

CREATE OR REPLACE TABLE hosp.d_icd_diagnoses AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/d_icd_diagnoses.csv.gz');

CREATE OR REPLACE TABLE hosp.d_icd_procedures AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/d_icd_procedures.csv.gz');

CREATE OR REPLACE TABLE hosp.d_labitems AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/d_labitems.csv.gz');

CREATE OR REPLACE TABLE hosp.diagnoses_icd AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/diagnoses_icd.csv.gz');

CREATE OR REPLACE TABLE hosp.drgcodes AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/drgcodes.csv.gz');

CREATE OR REPLACE TABLE hosp.emar AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/emar.csv.gz');

CREATE OR REPLACE TABLE hosp.emar_detail AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/emar_detail.csv.gz');

CREATE OR REPLACE TABLE hosp.hcpcsevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/hcpcsevents.csv.gz');

CREATE OR REPLACE TABLE hosp.labevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/labevents.csv.gz');

CREATE OR REPLACE TABLE hosp.microbiologyevents AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/microbiologyevents.csv.gz');

CREATE OR REPLACE TABLE hosp.omr AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/omr.csv.gz');

CREATE OR REPLACE TABLE hosp.patients AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/patients.csv.gz');

CREATE OR REPLACE TABLE hosp.pharmacy AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/pharmacy.csv.gz');

CREATE OR REPLACE TABLE hosp.poe AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/poe.csv.gz');

CREATE OR REPLACE TABLE hosp.poe_detail AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/poe_detail.csv.gz');

CREATE OR REPLACE TABLE hosp.prescriptions AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/prescriptions.csv.gz');

CREATE OR REPLACE TABLE hosp.procedures_icd AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/procedures_icd.csv.gz');

CREATE OR REPLACE TABLE hosp.provider AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/provider.csv.gz');

CREATE OR REPLACE TABLE hosp.services AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/services.csv.gz');

CREATE OR REPLACE TABLE hosp.transfers AS
SELECT * FROM read_csv_auto('data/raw/mimic-iv-clinical-database-demo-2.2/hosp/transfers.csv.gz');