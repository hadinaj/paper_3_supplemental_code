-- 14_export_review_followup_checks.sql
-- Follow-up counts for selected partially complete relationships.
--
-- Purpose:
-- The relationship checks (scripts 08 and 12) show that some links are not always
-- populated. These counts describe the rows behind three such links, as material for
-- stakeholder review. They do not change any classification.
--   (1) ED stays to hospital admissions: ED disposition against the presence of hadm_id,
--       and the admission type of ED stays with disposition HOME that have a hadm_id.
--   (2) Transfers to hospital admissions: event type of transfer rows without hadm_id.
--   (3) Laboratory and microbiology events to hospital admissions: how many rows without
--       hadm_id fall within an admission of the same patient, with no time window and
--       with a window of 24 hours before admission and after discharge.
--       For microbiology rows without charttime, chartdate is used.
--
-- Input: DuckDB tables in the hosp and ed schemas (scripts 05 and 10).
-- Output:
--   - output/02_relationship_assessments/07_review_followup_checks.csv

COPY (

    -- (1) ED disposition against the presence of hadm_id
    SELECT
        'ED stays by disposition' AS check_name,
        disposition AS category,
        'stays' AS measure,
        COUNT(*) AS value
    FROM ed.edstays
    GROUP BY disposition

    UNION ALL

    SELECT
        'ED stays by disposition',
        disposition,
        'stays with hadm_id',
        COUNT(hadm_id)
    FROM ed.edstays
    GROUP BY disposition

    UNION ALL

    SELECT
        'ED stays with disposition HOME and a hadm_id, by admission type',
        a.admission_type,
        'stays',
        COUNT(*)
    FROM ed.edstays e
    JOIN hosp.admissions a ON a.hadm_id = e.hadm_id
    WHERE e.disposition = 'HOME'
    GROUP BY a.admission_type

    UNION ALL

    SELECT
        'ED stays with disposition HOME and a hadm_id, by admission type',
        a.admission_type,
        'admission ends when the ED stay ends',
        COUNT(*) FILTER (WHERE a.dischtime = e.outtime)
    FROM ed.edstays e
    JOIN hosp.admissions a ON a.hadm_id = e.hadm_id
    WHERE e.disposition = 'HOME'
    GROUP BY a.admission_type

    UNION ALL

    -- (2) Transfer rows without hadm_id, by event type
    SELECT
        'Transfer rows without hadm_id, by event type',
        eventtype,
        'rows',
        COUNT(*)
    FROM hosp.transfers
    WHERE hadm_id IS NULL
    GROUP BY eventtype

    UNION ALL

    -- (3) Laboratory rows without hadm_id and admissions of the same patient
    SELECT
        'Laboratory rows without hadm_id',
        'all',
        'rows',
        COUNT(*)
    FROM hosp.labevents
    WHERE hadm_id IS NULL

    UNION ALL

    SELECT
        'Laboratory rows without hadm_id',
        'within an admission of the same patient',
        'rows',
        COUNT(*)
    FROM hosp.labevents l
    WHERE l.hadm_id IS NULL
      AND EXISTS (
          SELECT 1 FROM hosp.admissions a
          WHERE a.subject_id = l.subject_id
            AND l.charttime BETWEEN a.admittime AND a.dischtime)

    UNION ALL

    SELECT
        'Laboratory rows without hadm_id',
        'within an admission of the same patient, plus or minus 24 hours',
        'rows',
        COUNT(*)
    FROM hosp.labevents l
    WHERE l.hadm_id IS NULL
      AND EXISTS (
          SELECT 1 FROM hosp.admissions a
          WHERE a.subject_id = l.subject_id
            AND l.charttime BETWEEN a.admittime - INTERVAL 24 HOUR
                                AND a.dischtime + INTERVAL 24 HOUR)

    UNION ALL

    -- (3) Microbiology rows without hadm_id and admissions of the same patient
    SELECT
        'Microbiology rows without hadm_id',
        'all',
        'rows',
        COUNT(*)
    FROM hosp.microbiologyevents
    WHERE hadm_id IS NULL

    UNION ALL

    SELECT
        'Microbiology rows without hadm_id',
        'within an admission of the same patient',
        'rows',
        COUNT(*)
    FROM hosp.microbiologyevents m
    WHERE m.hadm_id IS NULL
      AND EXISTS (
          SELECT 1 FROM hosp.admissions a
          WHERE a.subject_id = m.subject_id
            AND COALESCE(CAST(m.charttime AS TIMESTAMP), CAST(m.chartdate AS TIMESTAMP))
                BETWEEN a.admittime AND a.dischtime)

    UNION ALL

    SELECT
        'Microbiology rows without hadm_id',
        'within an admission of the same patient, plus or minus 24 hours',
        'rows',
        COUNT(*)
    FROM hosp.microbiologyevents m
    WHERE m.hadm_id IS NULL
      AND EXISTS (
          SELECT 1 FROM hosp.admissions a
          WHERE a.subject_id = m.subject_id
            AND COALESCE(CAST(m.charttime AS TIMESTAMP), CAST(m.chartdate AS TIMESTAMP))
                BETWEEN a.admittime - INTERVAL 24 HOUR
                    AND a.dischtime + INTERVAL 24 HOUR)

    ORDER BY check_name, category, measure
)
TO 'output/02_relationship_assessments/07_review_followup_checks.csv'
WITH (HEADER, DELIMITER ',');
