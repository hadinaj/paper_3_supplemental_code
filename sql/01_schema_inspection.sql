-- 01_schema_inspection.sql
-- Basic schema inspection queries for the MIMIC-IV Demo Step 0 workflow.

-- List loaded tables
SHOW TABLES FROM hosp;
SHOW TABLES FROM icu;

-- Row counts for selected core tables
SELECT 'hosp.patients' AS table_name, COUNT(*) AS row_count FROM hosp.patients
UNION ALL
SELECT 'hosp.admissions', COUNT(*) FROM hosp.admissions
UNION ALL
SELECT 'hosp.diagnoses_icd', COUNT(*) FROM hosp.diagnoses_icd
UNION ALL
SELECT 'hosp.d_icd_diagnoses', COUNT(*) FROM hosp.d_icd_diagnoses
UNION ALL
SELECT 'hosp.labevents', COUNT(*) FROM hosp.labevents
UNION ALL
SELECT 'hosp.d_labitems', COUNT(*) FROM hosp.d_labitems
UNION ALL
SELECT 'icu.icustays', COUNT(*) FROM icu.icustays;

-- Column inspection
DESCRIBE hosp.patients;
DESCRIBE hosp.admissions;
DESCRIBE hosp.diagnoses_icd;
DESCRIBE hosp.d_icd_diagnoses;
DESCRIBE hosp.labevents;
DESCRIBE hosp.d_labitems;
DESCRIBE icu.icustays;

-- Candidate identifier checks
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT subject_id) AS distinct_subject_id
FROM hosp.patients;

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT subject_id) AS distinct_subject_id,
    COUNT(DISTINCT hadm_id) AS distinct_hadm_id
FROM hosp.admissions;

SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT stay_id) AS distinct_stay_id,
    COUNT(DISTINCT hadm_id) AS distinct_hadm_id,
    COUNT(DISTINCT subject_id) AS distinct_subject_id
FROM icu.icustays;

-- Relationship checks
SELECT
    COUNT(*) AS diagnosis_rows,
    COUNT(a.hadm_id) AS matched_to_admissions
FROM hosp.diagnoses_icd d
LEFT JOIN hosp.admissions a
    ON d.hadm_id = a.hadm_id;

SELECT
    COUNT(*) AS lab_rows,
    COUNT(a.hadm_id) AS matched_to_admissions
FROM hosp.labevents l
LEFT JOIN hosp.admissions a
    ON l.hadm_id = a.hadm_id;

SELECT
    COUNT(*) AS icu_stay_rows,
    COUNT(a.hadm_id) AS matched_to_admissions
FROM icu.icustays i
LEFT JOIN hosp.admissions a
    ON i.hadm_id = a.hadm_id;