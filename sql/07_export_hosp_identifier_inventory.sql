-- 07_export_hosp_identifier_inventory.sql
-- Exports column and shared-identifier inventories for the MIMIC-IV Demo hospital module.
-- These outputs support Step 2 by identifying candidate relationship fields.

-- Full column inventory for all loaded hosp tables
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