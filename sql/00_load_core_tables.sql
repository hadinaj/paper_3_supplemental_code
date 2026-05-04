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