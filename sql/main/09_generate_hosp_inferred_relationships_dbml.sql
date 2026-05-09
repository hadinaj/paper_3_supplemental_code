-- 09_generate_hosp_inferred_relationships_dbml.sql
-- Generates DBML components for a hospital-module schema visualization with inferred relationships.
--
-- Purpose:
-- This script creates DBML output for preliminary schema visualization of the
-- MIMIC-IV Demo hospital module. The relationship lines include only conservative
-- inferred relationships supported by join-based match checks with zero unmatched
-- source rows in 08_export_hosp_candidate_relationship_checks.sql.
--
-- Input:
-- DuckDB tables in the hosp schema, created by 05_load_all_hosp_tables.sql.
--
-- Outputs:
--   - output/hosp_inferred_schema_tables_part.dbml
--   - output/hosp_inferred_schema_relationships_part.dbml
--
-- Note:
-- The generated relationships are modeling assumptions for preliminary schema
-- visualization. They should not be interpreted as formally declared database
-- constraints in the source files.

COPY (
    SELECT dbml_line
    FROM (
        -- Tables
        SELECT
            table_name,
            0 AS sort_order,
            0 AS ordinal_position,
            'Table ' || table_name || ' {' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'

        UNION ALL

        -- Columns
        SELECT
            table_name,
            1 AS sort_order,
            ordinal_position,
            '  ' || column_name || ' ' ||
            CASE
                WHEN data_type ILIKE '%INT%' THEN 'int'
                WHEN data_type ILIKE '%DOUBLE%' THEN 'double'
                WHEN data_type ILIKE '%FLOAT%' THEN 'double'
                WHEN data_type ILIKE '%DECIMAL%' THEN 'decimal'
                WHEN data_type ILIKE '%TIMESTAMP%' THEN 'timestamp'
                WHEN data_type ILIKE '%DATE%' THEN 'date'
                ELSE 'varchar'
            END AS dbml_line
        FROM information_schema.columns
        WHERE table_schema = 'hosp'

        UNION ALL

        -- Closing braces
        SELECT
            table_name,
            2 AS sort_order,
            9999 AS ordinal_position,
            '}' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'
    )
    ORDER BY table_name, sort_order, ordinal_position
)
TO 'output/hosp_inferred_schema_tables_part.dbml'
WITH (FORMAT CSV, HEADER false, DELIMITER '|', QUOTE '');

COPY (
    SELECT ref_line
    FROM (
        SELECT '' AS ref_line, 0 AS sort_order

        UNION ALL SELECT 'Ref: admissions.subject_id > patients.subject_id', 1

        UNION ALL SELECT 'Ref: diagnoses_icd.subject_id > patients.subject_id', 2
        UNION ALL SELECT 'Ref: diagnoses_icd.hadm_id > admissions.hadm_id', 3
        UNION ALL SELECT 'Ref: diagnoses_icd.(icd_code, icd_version) > d_icd_diagnoses.(icd_code, icd_version)', 4

        UNION ALL SELECT 'Ref: procedures_icd.subject_id > patients.subject_id', 5
        UNION ALL SELECT 'Ref: procedures_icd.hadm_id > admissions.hadm_id', 6
        UNION ALL SELECT 'Ref: procedures_icd.(icd_code, icd_version) > d_icd_procedures.(icd_code, icd_version)', 7

        UNION ALL SELECT 'Ref: labevents.subject_id > patients.subject_id', 8
        UNION ALL SELECT 'Ref: labevents.itemid > d_labitems.itemid', 9

        UNION ALL SELECT 'Ref: transfers.subject_id > patients.subject_id', 10

        UNION ALL SELECT 'Ref: services.subject_id > patients.subject_id', 11
        UNION ALL SELECT 'Ref: services.hadm_id > admissions.hadm_id', 12

        UNION ALL SELECT 'Ref: drgcodes.subject_id > patients.subject_id', 13
        UNION ALL SELECT 'Ref: drgcodes.hadm_id > admissions.hadm_id', 14

        UNION ALL SELECT 'Ref: prescriptions.subject_id > patients.subject_id', 15
        UNION ALL SELECT 'Ref: prescriptions.hadm_id > admissions.hadm_id', 16

        UNION ALL SELECT 'Ref: pharmacy.subject_id > patients.subject_id', 17
        UNION ALL SELECT 'Ref: pharmacy.hadm_id > admissions.hadm_id', 18

        UNION ALL SELECT 'Ref: poe.subject_id > patients.subject_id', 19
        UNION ALL SELECT 'Ref: poe.hadm_id > admissions.hadm_id', 20

        UNION ALL SELECT 'Ref: hcpcsevents.subject_id > patients.subject_id', 21
        UNION ALL SELECT 'Ref: hcpcsevents.hadm_id > admissions.hadm_id', 22
    )
    ORDER BY sort_order
)
TO 'output/hosp_inferred_schema_relationships_part.dbml'
WITH (FORMAT CSV, HEADER false, DELIMITER '|', QUOTE '');