-- 13_compare_declared_foreign_keys.sql
-- Compares the 48 hospital-module candidate relationship checks with the foreign key
-- constraints declared by the MIMIC-IV maintainers in the MIMIC Code Repository.
--
-- Purpose:
-- Provides an external reference for the rule-based classification. The declared
-- constraints were NOT used to select or classify the checks; they are compared here
-- only after classification.
--
-- Source of the declared constraints:
--   MIT-LCP/mimic-code, mimic-iv/buildmimic/postgres/constraint.sql,
--   commit b24cb8e3dfe2344759917aa99c6ebb2ddc9953e5 (2022-07-10; unchanged since).
--   https://github.com/MIT-LCP/mimic-code/blob/b24cb8e3dfe2344759917aa99c6ebb2ddc9953e5/mimic-iv/buildmimic/postgres/constraint.sql
--   The 29 FOREIGN KEY constraints between hosp tables are listed below verbatim
--   (source table, source columns, target table, target columns).
--
-- Input:
--   - output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv
-- Outputs:
--   - output/02_relationship_assessments/03_hosp_checks_vs_declared_foreign_keys.csv
--   - output/02_relationship_assessments/04_hosp_declared_foreign_keys_crosstab.csv

CREATE OR REPLACE TEMP TABLE declared_fk AS
SELECT * FROM (VALUES
    ('admissions', 'subject_id', 'patients', 'subject_id'),
    ('diagnoses_icd', 'subject_id', 'patients', 'subject_id'),
    ('diagnoses_icd', 'hadm_id', 'admissions', 'hadm_id'),
    ('drgcodes', 'subject_id', 'patients', 'subject_id'),
    ('drgcodes', 'hadm_id', 'admissions', 'hadm_id'),
    ('emar_detail', 'subject_id', 'patients', 'subject_id'),
    ('emar_detail', 'emar_id', 'emar', 'emar_id'),
    ('emar', 'subject_id', 'patients', 'subject_id'),
    ('emar', 'hadm_id', 'admissions', 'hadm_id'),
    ('hcpcsevents', 'subject_id', 'patients', 'subject_id'),
    ('hcpcsevents', 'hadm_id', 'admissions', 'hadm_id'),
    ('hcpcsevents', 'hcpcs_cd', 'd_hcpcs', 'code'),
    ('labevents', 'subject_id', 'patients', 'subject_id'),
    ('labevents', 'itemid', 'd_labitems', 'itemid'),
    ('microbiologyevents', 'subject_id', 'patients', 'subject_id'),
    ('microbiologyevents', 'hadm_id', 'admissions', 'hadm_id'),
    ('pharmacy', 'subject_id', 'patients', 'subject_id'),
    ('pharmacy', 'hadm_id', 'admissions', 'hadm_id'),
    ('poe_detail', 'subject_id', 'patients', 'subject_id'),
    ('poe_detail', 'poe_id', 'poe', 'poe_id'),
    ('poe', 'subject_id', 'patients', 'subject_id'),
    ('poe', 'hadm_id', 'admissions', 'hadm_id'),
    ('prescriptions', 'subject_id', 'patients', 'subject_id'),
    ('prescriptions', 'hadm_id', 'admissions', 'hadm_id'),
    ('procedures_icd', 'subject_id', 'patients', 'subject_id'),
    ('procedures_icd', 'hadm_id', 'admissions', 'hadm_id'),
    ('services', 'subject_id', 'patients', 'subject_id'),
    ('services', 'hadm_id', 'admissions', 'hadm_id'),
    ('transfers', 'subject_id', 'patients', 'subject_id')
) AS t(source_table, source_columns, target_table, target_columns);

CREATE OR REPLACE TEMP TABLE checks AS
SELECT
    *,
    split_part(split_part(candidate_relationship, ' -> ', 1), '.', 1) AS source_table,
    regexp_replace(split_part(split_part(candidate_relationship, ' -> ', 1), '.', 2), '[() ]', '', 'g') AS source_columns,
    split_part(split_part(candidate_relationship, ' -> ', 2), '.', 1) AS target_table,
    regexp_replace(split_part(split_part(candidate_relationship, ' -> ', 2), '.', 2), '[() ]', '', 'g') AS target_columns
FROM read_csv_auto('output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv');

CREATE OR REPLACE TEMP TABLE compared AS
SELECT
    c.candidate_relationship,
    c.relationship_assessment,
    c.source_null_link_rows,
    c.unmatched_non_null_rows,
    (f.source_table IS NOT NULL) AS declared_foreign_key
FROM checks c
LEFT JOIN declared_fk f
    USING (source_table, source_columns, target_table, target_columns);

COPY (SELECT * FROM compared ORDER BY declared_foreign_key DESC, relationship_assessment, candidate_relationship)
TO 'output/02_relationship_assessments/03_hosp_checks_vs_declared_foreign_keys.csv'
WITH (HEADER, DELIMITER ',');

COPY (
    SELECT
        relationship_assessment,
        COUNT(*) FILTER (WHERE declared_foreign_key) AS declared_foreign_key,
        COUNT(*) FILTER (WHERE NOT declared_foreign_key) AS not_declared,
        COUNT(*) AS total
    FROM compared
    GROUP BY relationship_assessment
    UNION ALL
    SELECT 'declared but not among the 48 checks',
           (SELECT COUNT(*) FROM declared_fk f
            WHERE NOT EXISTS (SELECT 1 FROM checks c
                              WHERE c.source_table = f.source_table AND c.source_columns = f.source_columns
                                AND c.target_table = f.target_table AND c.target_columns = f.target_columns)),
           NULL, NULL
)
TO 'output/02_relationship_assessments/04_hosp_declared_foreign_keys_crosstab.csv'
WITH (HEADER, DELIMITER ',');
