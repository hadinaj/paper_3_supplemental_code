-- 08_export_hosp_candidate_relationship_checks.sql
-- Exports empirical checks for candidate relationships in the MIMIC-IV Demo hospital module.
-- These checks support Step 2: inferred PK/FK-style relationships.

COPY (
    SELECT
        'admissions.subject_id -> patients.subject_id' AS candidate_relationship,
        COUNT(*) AS source_rows,
        COUNT(p.subject_id) AS matched_rows,
        COUNT(*) - COUNT(p.subject_id) AS unmatched_rows
    FROM hosp.admissions a
    LEFT JOIN hosp.patients p
        ON a.subject_id = p.subject_id

    UNION ALL

    SELECT
        'diagnoses_icd.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.diagnoses_icd d
    LEFT JOIN hosp.patients p
        ON d.subject_id = p.subject_id

    UNION ALL

    SELECT
        'diagnoses_icd.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.diagnoses_icd d
    LEFT JOIN hosp.admissions a
        ON d.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'diagnoses_icd.(icd_code, icd_version) -> d_icd_diagnoses.(icd_code, icd_version)',
        COUNT(*),
        COUNT(dic.icd_code),
        COUNT(*) - COUNT(dic.icd_code)
    FROM hosp.diagnoses_icd d
    LEFT JOIN hosp.d_icd_diagnoses dic
        ON d.icd_code = dic.icd_code
       AND d.icd_version = dic.icd_version

    UNION ALL

    SELECT
        'procedures_icd.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.procedures_icd pr
    LEFT JOIN hosp.patients p
        ON pr.subject_id = p.subject_id

    UNION ALL

    SELECT
        'procedures_icd.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.procedures_icd pr
    LEFT JOIN hosp.admissions a
        ON pr.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'procedures_icd.(icd_code, icd_version) -> d_icd_procedures.(icd_code, icd_version)',
        COUNT(*),
        COUNT(dic.icd_code),
        COUNT(*) - COUNT(dic.icd_code)
    FROM hosp.procedures_icd pr
    LEFT JOIN hosp.d_icd_procedures dic
        ON pr.icd_code = dic.icd_code
       AND pr.icd_version = dic.icd_version

    UNION ALL

    SELECT
        'labevents.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.labevents l
    LEFT JOIN hosp.patients p
        ON l.subject_id = p.subject_id

    UNION ALL

    SELECT
        'labevents.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.labevents l
    LEFT JOIN hosp.admissions a
        ON l.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'labevents.itemid -> d_labitems.itemid',
        COUNT(*),
        COUNT(items.itemid),
        COUNT(*) - COUNT(items.itemid)
    FROM hosp.labevents l
    LEFT JOIN hosp.d_labitems items
        ON l.itemid = items.itemid

    UNION ALL

    SELECT
        'transfers.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.transfers t
    LEFT JOIN hosp.patients p
        ON t.subject_id = p.subject_id

    UNION ALL

    SELECT
        'transfers.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.transfers t
    LEFT JOIN hosp.admissions a
        ON t.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'services.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.services s
    LEFT JOIN hosp.patients p
        ON s.subject_id = p.subject_id

    UNION ALL

    SELECT
        'services.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.services s
    LEFT JOIN hosp.admissions a
        ON s.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'drgcodes.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.drgcodes drg
    LEFT JOIN hosp.patients p
        ON drg.subject_id = p.subject_id

    UNION ALL

    SELECT
        'drgcodes.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.drgcodes drg
    LEFT JOIN hosp.admissions a
        ON drg.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'prescriptions.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.prescriptions rx
    LEFT JOIN hosp.patients p
        ON rx.subject_id = p.subject_id

    UNION ALL

    SELECT
        'prescriptions.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.prescriptions rx
    LEFT JOIN hosp.admissions a
        ON rx.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'pharmacy.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.pharmacy ph
    LEFT JOIN hosp.patients p
        ON ph.subject_id = p.subject_id

    UNION ALL

    SELECT
        'pharmacy.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.pharmacy ph
    LEFT JOIN hosp.admissions a
        ON ph.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'poe.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.poe po
    LEFT JOIN hosp.patients p
        ON po.subject_id = p.subject_id

    UNION ALL

    SELECT
        'poe.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.poe po
    LEFT JOIN hosp.admissions a
        ON po.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'emar.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.emar e
    LEFT JOIN hosp.patients p
        ON e.subject_id = p.subject_id

    UNION ALL

    SELECT
        'emar.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.emar e
    LEFT JOIN hosp.admissions a
        ON e.hadm_id = a.hadm_id

    UNION ALL

    SELECT
        'hcpcsevents.subject_id -> patients.subject_id',
        COUNT(*),
        COUNT(p.subject_id),
        COUNT(*) - COUNT(p.subject_id)
    FROM hosp.hcpcsevents h
    LEFT JOIN hosp.patients p
        ON h.subject_id = p.subject_id

    UNION ALL

    SELECT
        'hcpcsevents.hadm_id -> admissions.hadm_id',
        COUNT(*),
        COUNT(a.hadm_id),
        COUNT(*) - COUNT(a.hadm_id)
    FROM hosp.hcpcsevents h
    LEFT JOIN hosp.admissions a
        ON h.hadm_id = a.hadm_id
)
TO 'output/hosp_candidate_relationship_checks.csv'
WITH (HEADER, DELIMITER ',');