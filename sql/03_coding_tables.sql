-- 03_coding_tables.sql
-- Coding and dictionary table inspection for the MIMIC-IV Demo Step 0 workflow.

-- Most frequent ICD diagnosis codes in the demo dataset
SELECT
    d.icd_code,
    d.icd_version,
    dic.long_title,
    COUNT(*) AS frequency
FROM hosp.diagnoses_icd d
LEFT JOIN hosp.d_icd_diagnoses dic
    ON d.icd_code = dic.icd_code
   AND d.icd_version = dic.icd_version
GROUP BY
    d.icd_code,
    d.icd_version,
    dic.long_title
ORDER BY frequency DESC
LIMIT 25;

-- Number of diagnosis records by ICD version
SELECT
    icd_version,
    COUNT(*) AS diagnosis_rows,
    COUNT(DISTINCT icd_code) AS distinct_icd_codes
FROM hosp.diagnoses_icd
GROUP BY icd_version
ORDER BY icd_version;

-- Most frequent laboratory item codes
SELECT
    l.itemid,
    items.label,
    items.fluid,
    items.category,
    COUNT(*) AS frequency
FROM hosp.labevents l
LEFT JOIN hosp.d_labitems items
    ON l.itemid = items.itemid
GROUP BY
    l.itemid,
    items.label,
    items.fluid,
    items.category
ORDER BY frequency DESC
LIMIT 25;

-- Number of laboratory events by category
SELECT
    items.category,
    COUNT(*) AS lab_event_rows,
    COUNT(DISTINCT l.itemid) AS distinct_itemids
FROM hosp.labevents l
LEFT JOIN hosp.d_labitems items
    ON l.itemid = items.itemid
GROUP BY items.category
ORDER BY lab_event_rows DESC;

-- Check whether all diagnosis codes map to the diagnosis dictionary
SELECT
    COUNT(*) AS diagnosis_rows,
    COUNT(dic.icd_code) AS matched_to_dictionary,
    COUNT(*) - COUNT(dic.icd_code) AS unmatched_to_dictionary
FROM hosp.diagnoses_icd d
LEFT JOIN hosp.d_icd_diagnoses dic
    ON d.icd_code = dic.icd_code
   AND d.icd_version = dic.icd_version;

-- Check whether all lab item IDs map to the lab item dictionary
SELECT
    COUNT(*) AS lab_event_rows,
    COUNT(items.itemid) AS matched_to_dictionary,
    COUNT(*) - COUNT(items.itemid) AS unmatched_to_dictionary
FROM hosp.labevents l
LEFT JOIN hosp.d_labitems items
    ON l.itemid = items.itemid;