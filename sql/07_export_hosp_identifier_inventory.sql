-- 07_export_hosp_identifier_inventory.sql
-- Exports table/column and identifier inventories for the MIMIC-IV Demo hospital module.
--
-- Purpose:
-- This script generates preparatory work outputs for the Step 0 structural
-- exploration workflow. The outputs document the hospital-module table and
-- column structure, identify columns shared across multiple tables, and extract
-- identifier-like fields that may support candidate key and relationship assessment.
--
-- Input:
-- DuckDB tables in the hosp schema, created by 05_load_all_hosp_tables.sql.
--
-- Outputs:
--   - output/hosp_column_inventory.csv
--   - output/hosp_shared_columns.csv
--   - output/hosp_identifier_columns.csv
--
-- Note:
-- Shared column names and identifier-like fields are used to propose candidate
-- relationships, but they do not establish formal database constraints.
-- Candidate relationships are evaluated separately using join-based match
-- checks in 08_export_hosp_candidate_relationship_checks.sql.
COPY (
    SELECT
        table_schema,
        table_name,
        ordinal_position,
        column_name,
        data_type
    FROM information_schema.columns
    WHERE table_schema = 'hosp'
    ORDER BY table_name, ordinal_position
)
TO 'output/hosp_column_inventory.csv'
WITH (HEADER, DELIMITER ',');

-- Columns that appear in more than one hosp table
COPY (
    SELECT
        column_name,
        COUNT(DISTINCT table_name) AS number_of_tables,
        string_agg(table_name, ', ' ORDER BY table_name) AS tables
    FROM information_schema.columns
    WHERE table_schema = 'hosp'
    GROUP BY column_name
    HAVING COUNT(DISTINCT table_name) > 1
    ORDER BY number_of_tables DESC, column_name
)
TO 'output/hosp_shared_columns.csv'
WITH (HEADER, DELIMITER ',');

-- Common identifier-like columns
COPY (
    SELECT
        table_name,
        ordinal_position,
        column_name,
        data_type
    FROM information_schema.columns
    WHERE table_schema = 'hosp'
      AND (
          column_name LIKE '%id'
          OR column_name LIKE '%_id'
          OR column_name IN (
              'subject_id',
              'hadm_id',
              'icd_code',
              'icd_version',
              'itemid',
              'poe_id',
              'pharmacy_id',
              'emar_id',
              'provider_id',
              'hcpcs_cd'
          )
      )
    ORDER BY column_name, table_name, ordinal_position
)
TO 'output/hosp_identifier_columns.csv'
WITH (HEADER, DELIMITER ',');