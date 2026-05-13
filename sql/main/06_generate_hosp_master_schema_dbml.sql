-- 06_generate_hosp_master_schema_dbml.sql
-- Generates a tables-only DBML representation for the MIMIC-IV Demo hospital module.
--
-- Purpose:
-- This script creates a source-oriented DBML representation of the inspected
-- hospital-module tables and columns before inferred relationship lines are added.
-- The output supports review of table structure and available columns as an
-- intermediate schema representation.
--
-- Input:
-- DuckDB tables in the hosp schema, created by 05_load_all_hosp_tables.sql.
--
-- Output:
--   - output/03_schema_representations/01_hosp_tables_only_dbml_representation.dbml
--
-- Note:
-- The generated DBML file does not include inferred relationships. Candidate
-- relationships are evaluated separately in 08_export_hosp_candidate_relationship_checks.sql.
-- Relationship-enhanced DBML components are generated in
-- 09_generate_hosp_inferred_relationships_dbml.sql.
--
-- This DBML representation should not be interpreted as a formal database
-- implementation schema or declared primary-key/foreign-key specification.

COPY (
    SELECT dbml_line
    FROM (
        -- Opening table lines
        SELECT
            table_name,
            0 AS sort_order,
            0 AS ordinal_position,
            'Table ' || table_name || ' {' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'

        UNION ALL

        -- Column lines
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

        -- Closing table lines
        SELECT
            table_name,
            2 AS sort_order,
            9999 AS ordinal_position,
            '}' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'
    ) AS dbml_lines
    ORDER BY table_name, sort_order, ordinal_position
)
TO 'output/03_schema_representations/01_hosp_tables_only_dbml_representation.dbml'
WITH (FORMAT CSV, HEADER false, DELIMITER '|', QUOTE '');