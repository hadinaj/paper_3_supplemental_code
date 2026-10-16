-- 11_export_extension_structural_summaries.sql
-- Exports structural inventories for the ICU and ED modules (extension).
--
-- Uses the same identifier-like naming rule as 07_export_hosp_structural_summaries.sql:
-- column names ending in "id" or "_id", plus the documented code columns listed below.
--
-- Input: DuckDB tables in the icu and ed schemas (10_load_icu_ed_tables.sql).
-- Outputs:
--   - output/01_structural_summaries/05_extension_table_column_inventory.csv
--   - output/01_structural_summaries/06_extension_table_row_counts.csv
--   - output/01_structural_summaries/07_extension_identifier_like_columns.csv

COPY (
    SELECT table_schema, table_name, ordinal_position, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema IN ('icu', 'ed')
    ORDER BY table_schema, table_name, ordinal_position
)
TO 'output/01_structural_summaries/05_extension_table_column_inventory.csv'
WITH (HEADER, DELIMITER ',');

COPY (
    SELECT 'icu' AS table_schema, 'caregiver' AS table_name, COUNT(*) AS row_count FROM icu.caregiver
    UNION ALL
    SELECT 'icu', 'chartevents', COUNT(*) FROM icu.chartevents
    UNION ALL
    SELECT 'icu', 'd_items', COUNT(*) FROM icu.d_items
    UNION ALL
    SELECT 'icu', 'datetimeevents', COUNT(*) FROM icu.datetimeevents
    UNION ALL
    SELECT 'icu', 'icustays', COUNT(*) FROM icu.icustays
    UNION ALL
    SELECT 'icu', 'ingredientevents', COUNT(*) FROM icu.ingredientevents
    UNION ALL
    SELECT 'icu', 'inputevents', COUNT(*) FROM icu.inputevents
    UNION ALL
    SELECT 'icu', 'outputevents', COUNT(*) FROM icu.outputevents
    UNION ALL
    SELECT 'icu', 'procedureevents', COUNT(*) FROM icu.procedureevents
    UNION ALL
    SELECT 'ed', 'diagnosis', COUNT(*) FROM ed.diagnosis
    UNION ALL
    SELECT 'ed', 'edstays', COUNT(*) FROM ed.edstays
    UNION ALL
    SELECT 'ed', 'medrecon', COUNT(*) FROM ed.medrecon
    UNION ALL
    SELECT 'ed', 'pyxis', COUNT(*) FROM ed.pyxis
    UNION ALL
    SELECT 'ed', 'triage', COUNT(*) FROM ed.triage
    UNION ALL
    SELECT 'ed', 'vitalsign', COUNT(*) FROM ed.vitalsign
)
TO 'output/01_structural_summaries/06_extension_table_row_counts.csv'
WITH (HEADER, DELIMITER ',');

COPY (
    SELECT table_schema, table_name, ordinal_position, column_name, data_type
    FROM information_schema.columns
    WHERE table_schema IN ('icu', 'ed')
      AND (
          column_name LIKE '%id'
          OR column_name LIKE '%_id'
          OR column_name IN ('subject_id', 'hadm_id', 'stay_id', 'itemid', 'caregiver_id', 'icd_code', 'icd_version')
      )
    ORDER BY table_schema, column_name, table_name
)
TO 'output/01_structural_summaries/07_extension_identifier_like_columns.csv'
WITH (HEADER, DELIMITER ',');
