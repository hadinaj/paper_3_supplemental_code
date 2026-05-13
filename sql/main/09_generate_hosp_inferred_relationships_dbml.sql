-- 09_generate_hosp_inferred_relationships_dbml.sql
-- Generates a relationship-enhanced DBML representation for the MIMIC-IV Demo hospital module.
--
-- Purpose:
-- This script creates a source-oriented DBML schema representation that includes
-- the inspected hospital-module tables and selected conservative inferred relationships.
-- Relationship lines are generated from the candidate relationship-assessment output
-- produced by 08_export_hosp_candidate_relationship_checks.sql.
--
-- The relationship-enhanced DBML includes only relationships classified as
-- complete_conservative_inferred_relationship in the selected join-based checks.
-- Relationships affected by null values in evaluated linking columns or unmatched
-- non-null source values are retained in the relationship-assessment output, but are
-- not added as DBML Ref lines here.
--
-- Inputs:
--   - DuckDB tables in the hosp schema, created by 05_load_all_hosp_tables.sql
--   - output/relationship_assessments/hosp_candidate_relationship_checks.csv,
--     created by 08_export_hosp_candidate_relationship_checks.sql
--
-- Output:
--   - output/schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml
--
-- Note:
-- The generated relationships are inferred modeling relationships for schema
-- representation. They should not be interpreted as formally declared database
-- constraints, primary-key/foreign-key constraints, or exhaustive relationship
-- discovery results.

COPY (
    WITH table_lines AS (
        -- Opening table lines
        SELECT
            1 AS section_order,
            table_name,
            0 AS sort_order,
            0 AS ordinal_position,
            'Table ' || table_name || ' {' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'

        UNION ALL

        -- Column lines
        SELECT
            1 AS section_order,
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
            1 AS section_order,
            table_name,
            2 AS sort_order,
            9999 AS ordinal_position,
            '}' AS dbml_line
        FROM information_schema.tables
        WHERE table_schema = 'hosp'
    ),

    relationship_lines AS (
    SELECT
        2 AS section_order,
        candidate_relationship AS table_name,
        row_number() OVER (ORDER BY candidate_relationship) AS sort_order,
        0 AS ordinal_position,
        'Ref: ' ||
        replace(
            replace(candidate_relationship, ' -> ', ' > '),
            ' → ',
            ' > '
        ) AS dbml_line
    FROM read_csv_auto('output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv')
    WHERE relationship_assessment = 'complete_conservative_inferred_relationship'
    ), 

    combined_lines AS (
        SELECT
            section_order,
            table_name,
            sort_order,
            ordinal_position,
            dbml_line
        FROM table_lines

        UNION ALL

        SELECT
            2 AS section_order,
            '' AS table_name,
            0 AS sort_order,
            0 AS ordinal_position,
            '' AS dbml_line

        UNION ALL

        SELECT
            section_order,
            table_name,
            sort_order,
            ordinal_position,
            dbml_line
        FROM relationship_lines
    )

    SELECT dbml_line
    FROM combined_lines
    ORDER BY section_order, table_name, sort_order, ordinal_position
)
TO 'output/03_schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml'
WITH (FORMAT CSV, HEADER false, DELIMITER '|', QUOTE '');