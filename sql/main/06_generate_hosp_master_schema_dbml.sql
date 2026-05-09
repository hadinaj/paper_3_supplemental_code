-- 06_generate_hosp_master_schema_dbml.sql
-- Generates a DBML file representing the hospital-module table and column structure.
--
-- Purpose:
-- This script creates a tables-and-columns-only DBML representation of the
-- MIMIC-IV Demo hospital module. The output supports schema representation
-- before relationship filtering.
--
-- Input:
-- DuckDB tables in the hosp schema, created by 05_load_all_hosp_tables.sql.
--
-- Output:
-- schema/hosp_master_schema_tables_only.dbml
--
-- Note:
-- The generated DBML file does not include inferred relationships. Candidate
-- relationships are evaluated separately in 08_export_hosp_candidate_relationship_checks.sql
-- and added to the inferred schema representation in
-- 09_generate_hosp_inferred_relationships_dbml.sql.
COPY (
    SELECT dbml_line
    FROM (
        SELECT
            table_name,
            0 AS sort_order,
            0 AS ordinal_position,
            'Table ' || table_name || ' {' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'

        UNION ALL

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
TO 'output/hosp_master_schema_tables_only.dbml'
WITH (FORMAT CSV, HEADER false, DELIMITER '|', QUOTE '');