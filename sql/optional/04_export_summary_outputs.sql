-- 04_export_summary_outputs.sql
-- Exports summary outputs for the optional core-table workflow.
--
-- Purpose:
-- This script exports selected row counts, relationship checks, diagnosis code
-- summaries, and laboratory item summaries from the core tables loaded by
-- 00_load_core_tables.sql.
--
-- Outputs:
--   - output/core_table_row_counts.csv
--   - output/core_relationship_checks.csv
--   - output/core_diagnosis_code_summary.csv
--   - output/core_lab_item_summary.csv
--
-- Note:
-- These outputs provide a small, reproducible example of structural inspection.
-- The main hospital-module outputs used for the framework application are generated
-- by sql/main/07_export_hosp_identifier_inventory.sql,
-- sql/main/08_export_hosp_candidate_relationship_checks.sql, and
-- sql/main/09_generate_hosp_inferred_relationships_dbml.sql.

-- Export row counts
COPY (
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
    SELECT 'icu.icustays', COUNT(*) FROM icu.icustays
)
TO 'output/core_table_row_counts.csv'
WITH (HEADER, DELIMITER ',');

-- Export relationship checks
COPY (
    SELECT
        'hosp.admissions -> hosp.patients' AS relationship,
        COUNT(*) AS source_rows,
        COUNT(p.subject_id) AS matched_rows,
        COUNT(*) - COUNT(p.subject_id) AS unmatched_rows
    FROM hosp.admissions a
    LEFT JOIN hosp.patients p
        ON a.subject_id = p.subject_id

    UNION ALL

    SELECT
        'hosp.diagnoses_icd -> hosp.admissions',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.diagnoses_icd d
    LEFT JOIN hosp.admissions a
        ON d.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'hosp.diagnoses_icd -> hosp.d_icd_diagnoses',
        COUNT(*),
        COUNT(dic.icd_code),
        COUNT(*) - COUNT(dic.icd_code)
    FROM hosp.diagnoses_icd d
    LEFT JOIN hosp.d_icd_diagnoses dic
        ON d.icd_code = dic.icd_code
       AND d.icd_version = dic.icd_version

    UNION ALL

    SELECT
        'hosp.labevents -> hosp.admissions',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.labevents l
    LEFT JOIN hosp.admissions a
        ON l.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'hosp.labevents -> hosp.d_labitems',
        COUNT(*),
        COUNT(items.itemid),
        COUNT(*) - COUNT(items.itemid)
    FROM hosp.labevents l
    LEFT JOIN hosp.d_labitems items
        ON l.itemid = items.itemid

    UNION ALL

    SELECT
        'icu.icustays -> hosp.admissions',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM icu.icustays i
    LEFT JOIN hosp.admissions a
        ON i.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'icu.icustays -> hosp.patients',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM icu.icustays i
    LEFT JOIN hosp.patients p
        ON i.subject_id = p.subject_id
)
TO 'output/core_relationship_checks.csv'
WITH (HEADER, DELIMITER ',');

-- Export diagnosis code summary
COPY (
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
    LIMIT 25
)
TO 'output/core_diagnosis_code_summary.csv'
WITH (HEADER, DELIMITER ',');

-- Export lab item summary
COPY (
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
    LIMIT 25
)
TO 'output/core_lab_item_summary.csv'
WITH (HEADER, DELIMITER ',');