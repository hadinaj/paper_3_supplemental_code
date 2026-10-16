-- 12_export_extension_relationship_checks.sql
-- Exports join-based candidate relationship checks for the ICU and ED modules (extension).
--
-- Selection follows the same two principles as the 48 hospital-module checks
-- (08_export_hosp_candidate_relationship_checks.sql):
--   (1) each table is checked against its documented parent or reference structure
--       (ICU events -> icustays, d_items, caregiver; ED tables -> edstays);
--   (2) the patient, admission and stay identifiers of each module are checked against
--       the corresponding hospital-module tables (patients, admissions, transfers).
-- The MIMIC-IV documentation states that stay_id is generated from the earliest
-- transfer_id of a unit stay, which is why stay_id is checked against transfers.transfer_id.
--
-- Classification rule: identical to 08_export_hosp_candidate_relationship_checks.sql.
--
-- Input: DuckDB tables in the hosp, icu and ed schemas.
-- Output:
--   - output/02_relationship_assessments/02_extension_candidate_relationship_checks.csv

COPY (
    WITH relationship_checks AS (

        SELECT
            'ICU within module' AS check_group,
            'icu.chartevents.stay_id -> icu.icustays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM icu.chartevents s
        LEFT JOIN (SELECT DISTINCT stay_id FROM icu.icustays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.chartevents.itemid -> icu.d_items.itemid' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.itemid IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL AND t.itemid IS NULL) AS unmatched_non_null_rows
        FROM icu.chartevents s
        LEFT JOIN (SELECT DISTINCT itemid FROM icu.d_items) t
            ON s.itemid = t.itemid

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.chartevents.caregiver_id -> icu.caregiver.caregiver_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.caregiver_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL AND t.caregiver_id IS NULL) AS unmatched_non_null_rows
        FROM icu.chartevents s
        LEFT JOIN (SELECT DISTINCT caregiver_id FROM icu.caregiver) t
            ON s.caregiver_id = t.caregiver_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.datetimeevents.stay_id -> icu.icustays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM icu.datetimeevents s
        LEFT JOIN (SELECT DISTINCT stay_id FROM icu.icustays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.datetimeevents.itemid -> icu.d_items.itemid' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.itemid IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL AND t.itemid IS NULL) AS unmatched_non_null_rows
        FROM icu.datetimeevents s
        LEFT JOIN (SELECT DISTINCT itemid FROM icu.d_items) t
            ON s.itemid = t.itemid

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.datetimeevents.caregiver_id -> icu.caregiver.caregiver_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.caregiver_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL AND t.caregiver_id IS NULL) AS unmatched_non_null_rows
        FROM icu.datetimeevents s
        LEFT JOIN (SELECT DISTINCT caregiver_id FROM icu.caregiver) t
            ON s.caregiver_id = t.caregiver_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.ingredientevents.stay_id -> icu.icustays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM icu.ingredientevents s
        LEFT JOIN (SELECT DISTINCT stay_id FROM icu.icustays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.ingredientevents.itemid -> icu.d_items.itemid' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.itemid IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL AND t.itemid IS NULL) AS unmatched_non_null_rows
        FROM icu.ingredientevents s
        LEFT JOIN (SELECT DISTINCT itemid FROM icu.d_items) t
            ON s.itemid = t.itemid

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.ingredientevents.caregiver_id -> icu.caregiver.caregiver_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.caregiver_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL AND t.caregiver_id IS NULL) AS unmatched_non_null_rows
        FROM icu.ingredientevents s
        LEFT JOIN (SELECT DISTINCT caregiver_id FROM icu.caregiver) t
            ON s.caregiver_id = t.caregiver_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.inputevents.stay_id -> icu.icustays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM icu.inputevents s
        LEFT JOIN (SELECT DISTINCT stay_id FROM icu.icustays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.inputevents.itemid -> icu.d_items.itemid' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.itemid IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL AND t.itemid IS NULL) AS unmatched_non_null_rows
        FROM icu.inputevents s
        LEFT JOIN (SELECT DISTINCT itemid FROM icu.d_items) t
            ON s.itemid = t.itemid

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.inputevents.caregiver_id -> icu.caregiver.caregiver_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.caregiver_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL AND t.caregiver_id IS NULL) AS unmatched_non_null_rows
        FROM icu.inputevents s
        LEFT JOIN (SELECT DISTINCT caregiver_id FROM icu.caregiver) t
            ON s.caregiver_id = t.caregiver_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.outputevents.stay_id -> icu.icustays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM icu.outputevents s
        LEFT JOIN (SELECT DISTINCT stay_id FROM icu.icustays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.outputevents.itemid -> icu.d_items.itemid' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.itemid IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL AND t.itemid IS NULL) AS unmatched_non_null_rows
        FROM icu.outputevents s
        LEFT JOIN (SELECT DISTINCT itemid FROM icu.d_items) t
            ON s.itemid = t.itemid

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.outputevents.caregiver_id -> icu.caregiver.caregiver_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.caregiver_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL AND t.caregiver_id IS NULL) AS unmatched_non_null_rows
        FROM icu.outputevents s
        LEFT JOIN (SELECT DISTINCT caregiver_id FROM icu.caregiver) t
            ON s.caregiver_id = t.caregiver_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.procedureevents.stay_id -> icu.icustays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM icu.procedureevents s
        LEFT JOIN (SELECT DISTINCT stay_id FROM icu.icustays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.procedureevents.itemid -> icu.d_items.itemid' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.itemid IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.itemid IS NOT NULL AND t.itemid IS NULL) AS unmatched_non_null_rows
        FROM icu.procedureevents s
        LEFT JOIN (SELECT DISTINCT itemid FROM icu.d_items) t
            ON s.itemid = t.itemid

        UNION ALL

        SELECT
            'ICU within module' AS check_group,
            'icu.procedureevents.caregiver_id -> icu.caregiver.caregiver_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.caregiver_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.caregiver_id IS NOT NULL AND t.caregiver_id IS NULL) AS unmatched_non_null_rows
        FROM icu.procedureevents s
        LEFT JOIN (SELECT DISTINCT caregiver_id FROM icu.caregiver) t
            ON s.caregiver_id = t.caregiver_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.icustays.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM icu.icustays s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.icustays.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.icustays s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.icustays.stay_id -> hosp.transfers.transfer_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.transfer_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.transfer_id IS NULL) AS unmatched_non_null_rows
        FROM icu.icustays s
        LEFT JOIN (SELECT DISTINCT transfer_id FROM hosp.transfers) t
            ON s.stay_id = t.transfer_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.chartevents.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.chartevents s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.datetimeevents.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.datetimeevents s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.ingredientevents.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.ingredientevents s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.inputevents.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.inputevents s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.outputevents.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.outputevents s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ICU to hosp' AS check_group,
            'icu.procedureevents.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM icu.procedureevents s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ED within module' AS check_group,
            'ed.diagnosis.stay_id -> ed.edstays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM ed.diagnosis s
        LEFT JOIN (SELECT DISTINCT stay_id FROM ed.edstays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ED within module' AS check_group,
            'ed.medrecon.stay_id -> ed.edstays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM ed.medrecon s
        LEFT JOIN (SELECT DISTINCT stay_id FROM ed.edstays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ED within module' AS check_group,
            'ed.pyxis.stay_id -> ed.edstays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM ed.pyxis s
        LEFT JOIN (SELECT DISTINCT stay_id FROM ed.edstays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ED within module' AS check_group,
            'ed.triage.stay_id -> ed.edstays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM ed.triage s
        LEFT JOIN (SELECT DISTINCT stay_id FROM ed.edstays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ED within module' AS check_group,
            'ed.vitalsign.stay_id -> ed.edstays.stay_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.stay_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.stay_id IS NULL) AS unmatched_non_null_rows
        FROM ed.vitalsign s
        LEFT JOIN (SELECT DISTINCT stay_id FROM ed.edstays) t
            ON s.stay_id = t.stay_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.edstays.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM ed.edstays s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.edstays.hadm_id -> hosp.admissions.hadm_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND t.hadm_id IS NULL) AS unmatched_non_null_rows
        FROM ed.edstays s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) t
            ON s.hadm_id = t.hadm_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.edstays.stay_id -> hosp.transfers.transfer_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.transfer_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.stay_id IS NOT NULL AND t.transfer_id IS NULL) AS unmatched_non_null_rows
        FROM ed.edstays s
        LEFT JOIN (SELECT DISTINCT transfer_id FROM hosp.transfers) t
            ON s.stay_id = t.transfer_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.diagnosis.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM ed.diagnosis s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.medrecon.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM ed.medrecon s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.pyxis.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM ed.pyxis s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.triage.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM ed.triage s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

        UNION ALL

        SELECT
            'ED to hosp' AS check_group,
            'ed.vitalsign.subject_id -> hosp.patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND t.subject_id IS NULL) AS unmatched_non_null_rows
        FROM ed.vitalsign s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) t
            ON s.subject_id = t.subject_id

    )

    SELECT
        check_group,
        candidate_relationship,
        source_rows,
        source_non_null_link_rows,
        source_null_link_rows,
        matched_rows,
        unmatched_non_null_rows,
        CASE
            WHEN unmatched_non_null_rows = 0 AND source_null_link_rows = 0
                THEN 'fully_complete_inferred_relationship'
            WHEN unmatched_non_null_rows = 0 AND source_null_link_rows > 0
                THEN 'partially_complete_inferred_relationship'
            ELSE 'context-dependent_candidate_relationship'
        END AS relationship_assessment
    FROM relationship_checks
)
TO 'output/02_relationship_assessments/02_extension_candidate_relationship_checks.csv'
WITH (HEADER, DELIMITER ',');
