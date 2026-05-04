-- 06_generate_hosp_master_schema_dbml.sql
-- Generates a DBML file representing the hospital-module table and column structure.
-- This output supports Step 1 of the relational schema prototype: tables and columns only.
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
TO 'output/hosp_master_schema_step1_tables_only.dbml'
WITH (FORMAT CSV, HEADER false, DELIMITER '|', QUOTE '');