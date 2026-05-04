-- 02_relationship_checks.sql
-- Relationship checks for the MIMIC-IV Demo Step 0 workflow.

-- Patient to admissions relationship
SELECT
    COUNT(*) AS admission_rows,
    COUNT(p.subject_id) AS matched_to_patients,
    COUNT(*) - COUNT(p.subject_id) AS unmatched_to_patients
FROM hosp.admissions a
LEFT JOIN hosp.patients p
    ON a.subject_id = p.subject_id;

-- Admission to diagnoses relationship
SELECT
    COUNT(*) AS diagnosis_rows,
    COUNT(a.hadm_id) AS matched_to_admissions,
    COUNT(*) - COUNT(a.hadm_id) AS unmatched_to_admissions
FROM hosp.diagnoses_icd d
LEFT JOIN hosp.admissions a
    ON d.hadm_id = a.hadm_id;

-- Diagnoses to ICD dictionary relationship
SELECT
    COUNT(*) AS diagnosis_rows,
    COUNT(dic.icd_code) AS matched_to_icd_dictionary,
    COUNT(*) - COUNT(dic.icd_code) AS unmatched_to_icd_dictionary
FROM hosp.diagnoses_icd d
LEFT JOIN hosp.d_icd_diagnoses dic
    ON d.icd_code = dic.icd_code
   AND d.icd_version = dic.icd_version;

-- Admission to laboratory events relationship
SELECT
    COUNT(*) AS lab_event_rows,
    COUNT(a.hadm_id) AS matched_to_admissions,
    COUNT(*) - COUNT(a.hadm_id) AS unmatched_to_admissions
FROM hosp.labevents l
LEFT JOIN hosp.admissions a
    ON l.hadm_id = a.hadm_id;

-- Laboratory events to laboratory item dictionary relationship
SELECT
    COUNT(*) AS lab_event_rows,
    COUNT(items.itemid) AS matched_to_lab_item_dictionary,
    COUNT(*) - COUNT(items.itemid) AS unmatched_to_lab_item_dictionary
FROM hosp.labevents l
LEFT JOIN hosp.d_labitems items
    ON l.itemid = items.itemid;

-- Admissions to ICU stays relationship
SELECT
    COUNT(*) AS icu_stay_rows,
    COUNT(a.hadm_id) AS matched_to_admissions,
    COUNT(*) - COUNT(a.hadm_id) AS unmatched_to_admissions
FROM icu.icustays i
LEFT JOIN hosp.admissions a
    ON i.hadm_id = a.hadm_id;

-- Patient to ICU stays relationship
SELECT
    COUNT(*) AS icu_stay_rows,
    COUNT(p.subject_id) AS matched_to_patients,
    COUNT(*) - COUNT(p.subject_id) AS unmatched_to_patients
FROM icu.icustays i
LEFT JOIN hosp.patients p
    ON i.subject_id = p.subject_id;