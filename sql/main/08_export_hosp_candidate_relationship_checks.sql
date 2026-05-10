-- 08_export_hosp_candidate_relationship_checks.sql
-- Exports join-based candidate relationship checks for the MIMIC-IV Demo hospital module.
--
-- Purpose:
-- This script evaluates selected model-relevant candidate relationships among
-- MIMIC-IV Demo hospital-module tables using row-based LEFT JOIN checks.
-- Candidate relationships are selected from documented identifiers, identifier-like
-- fields, shared-column patterns, and relationships needed for schema and
-- conceptual model construction. The checks are not intended to exhaustively
-- enumerate all possible joins in the database.
--
-- Method:
-- Each query compares source-table rows with rows that match a proposed
-- reference structure. The output separates source rows with null linking values
-- from non-null source rows that do not match the proposed reference structure.
-- Candidate relationships with zero unmatched non-null source rows are treated
-- as conservative inferred relationships for schema representation. Candidate
-- relationships with unmatched non-null source rows are retained as partial or
-- context-dependent candidate links requiring review.
--
-- Input:
-- DuckDB tables in the hosp schema, created by sql/main/05_load_all_hosp_tables.sql.
--
-- Output:
--   - output/relationship_assessments/hosp_candidate_relationship_checks.csv

COPY (
    WITH relationship_checks AS (

        SELECT
            'admissions.subject_id -> patients.subject_id' AS candidate_relationship,
            COUNT(*) AS source_rows,
            COUNT(*) FILTER (WHERE a.subject_id IS NOT NULL) AS source_non_null_link_rows,
            COUNT(*) FILTER (WHERE a.subject_id IS NULL) AS source_null_link_rows,
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL) AS matched_rows,
            COUNT(*) FILTER (WHERE a.subject_id IS NOT NULL AND p.subject_id IS NULL) AS unmatched_non_null_rows
        FROM hosp.admissions a
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON a.subject_id = p.subject_id

        UNION ALL

        SELECT
            'diagnoses_icd.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE d.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE d.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE d.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.diagnoses_icd d
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON d.subject_id = p.subject_id

        UNION ALL

        SELECT
            'diagnoses_icd.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE d.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE d.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE d.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.diagnoses_icd d
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON d.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'diagnoses_icd.(icd_code, icd_version) -> d_icd_diagnoses.(icd_code, icd_version)',
            COUNT(*),
            COUNT(*) FILTER (WHERE d.icd_code IS NOT NULL AND d.icd_version IS NOT NULL),
            COUNT(*) FILTER (WHERE d.icd_code IS NULL OR d.icd_version IS NULL),
            COUNT(*) FILTER (WHERE dic.icd_code IS NOT NULL AND dic.icd_version IS NOT NULL),
            COUNT(*) FILTER (
                WHERE d.icd_code IS NOT NULL
                  AND d.icd_version IS NOT NULL
                  AND dic.icd_code IS NULL
            )
        FROM hosp.diagnoses_icd d
        LEFT JOIN (
            SELECT DISTINCT icd_code, icd_version
            FROM hosp.d_icd_diagnoses
        ) dic
            ON d.icd_code = dic.icd_code
           AND d.icd_version = dic.icd_version

        UNION ALL

        SELECT
            'procedures_icd.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE pr.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE pr.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE pr.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.procedures_icd pr
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON pr.subject_id = p.subject_id

        UNION ALL

        SELECT
            'procedures_icd.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE pr.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE pr.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE pr.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.procedures_icd pr
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON pr.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'procedures_icd.(icd_code, icd_version) -> d_icd_procedures.(icd_code, icd_version)',
            COUNT(*),
            COUNT(*) FILTER (WHERE pr.icd_code IS NOT NULL AND pr.icd_version IS NOT NULL),
            COUNT(*) FILTER (WHERE pr.icd_code IS NULL OR pr.icd_version IS NULL),
            COUNT(*) FILTER (WHERE dic.icd_code IS NOT NULL AND dic.icd_version IS NOT NULL),
            COUNT(*) FILTER (
                WHERE pr.icd_code IS NOT NULL
                  AND pr.icd_version IS NOT NULL
                  AND dic.icd_code IS NULL
            )
        FROM hosp.procedures_icd pr
        LEFT JOIN (
            SELECT DISTINCT icd_code, icd_version
            FROM hosp.d_icd_procedures
        ) dic
            ON pr.icd_code = dic.icd_code
           AND pr.icd_version = dic.icd_version

        UNION ALL

        SELECT
            'labevents.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE l.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE l.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE l.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.labevents l
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON l.subject_id = p.subject_id

        UNION ALL

        SELECT
            'labevents.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE l.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE l.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE l.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.labevents l
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON l.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'labevents.itemid -> d_labitems.itemid',
            COUNT(*),
            COUNT(*) FILTER (WHERE l.itemid IS NOT NULL),
            COUNT(*) FILTER (WHERE l.itemid IS NULL),
            COUNT(*) FILTER (WHERE items.itemid IS NOT NULL),
            COUNT(*) FILTER (WHERE l.itemid IS NOT NULL AND items.itemid IS NULL)
        FROM hosp.labevents l
        LEFT JOIN (SELECT DISTINCT itemid FROM hosp.d_labitems) items
            ON l.itemid = items.itemid

        UNION ALL

        SELECT
            'transfers.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE t.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE t.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.transfers t
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON t.subject_id = p.subject_id

        UNION ALL

        SELECT
            'transfers.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE t.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE t.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.transfers t
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON t.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'services.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE s.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE s.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.services s
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON s.subject_id = p.subject_id

        UNION ALL

        SELECT
            'services.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE s.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE s.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.services s
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON s.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'drgcodes.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE drg.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE drg.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE drg.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.drgcodes drg
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON drg.subject_id = p.subject_id

        UNION ALL

        SELECT
            'drgcodes.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE drg.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE drg.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE drg.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.drgcodes drg
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON drg.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'prescriptions.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE rx.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.prescriptions rx
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON rx.subject_id = p.subject_id

        UNION ALL

        SELECT
            'prescriptions.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE rx.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.prescriptions rx
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON rx.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'pharmacy.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE ph.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ph.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ph.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.pharmacy ph
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON ph.subject_id = p.subject_id

        UNION ALL

        SELECT
            'pharmacy.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE ph.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ph.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ph.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.pharmacy ph
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON ph.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'poe.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE po.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE po.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE po.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.poe po
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON po.subject_id = p.subject_id

        UNION ALL

        SELECT
            'poe.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE po.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE po.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE po.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.poe po
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON po.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'emar.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE e.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.emar e
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON e.subject_id = p.subject_id

        UNION ALL

        SELECT
            'emar.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE e.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.emar e
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON e.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'hcpcsevents.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE h.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE h.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE h.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.hcpcsevents h
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON h.subject_id = p.subject_id

        UNION ALL

        SELECT
            'hcpcsevents.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE h.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE h.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE h.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.hcpcsevents h
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON h.hadm_id = a.hadm_id
    
            UNION ALL

        SELECT
            'admissions.admit_provider_id -> provider.provider_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE a.admit_provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE a.admit_provider_id IS NULL),
            COUNT(*) FILTER (WHERE pr.provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE a.admit_provider_id IS NOT NULL AND pr.provider_id IS NULL)
        FROM hosp.admissions a
        LEFT JOIN (SELECT DISTINCT provider_id FROM hosp.provider) pr
            ON a.admit_provider_id = pr.provider_id

        UNION ALL

        SELECT
            'labevents.order_provider_id -> provider.provider_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE l.order_provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE l.order_provider_id IS NULL),
            COUNT(*) FILTER (WHERE pr.provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE l.order_provider_id IS NOT NULL AND pr.provider_id IS NULL)
        FROM hosp.labevents l
        LEFT JOIN (SELECT DISTINCT provider_id FROM hosp.provider) pr
            ON l.order_provider_id = pr.provider_id

        UNION ALL

        SELECT
            'microbiologyevents.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE m.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE m.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE m.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.microbiologyevents m
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON m.subject_id = p.subject_id

        UNION ALL

        SELECT
            'microbiologyevents.hadm_id -> admissions.hadm_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE m.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE m.hadm_id IS NULL),
            COUNT(*) FILTER (WHERE a.hadm_id IS NOT NULL),
            COUNT(*) FILTER (WHERE m.hadm_id IS NOT NULL AND a.hadm_id IS NULL)
        FROM hosp.microbiologyevents m
        LEFT JOIN (SELECT DISTINCT hadm_id FROM hosp.admissions) a
            ON m.hadm_id = a.hadm_id

        UNION ALL

        SELECT
            'microbiologyevents.order_provider_id -> provider.provider_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE m.order_provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE m.order_provider_id IS NULL),
            COUNT(*) FILTER (WHERE pr.provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE m.order_provider_id IS NOT NULL AND pr.provider_id IS NULL)
        FROM hosp.microbiologyevents m
        LEFT JOIN (SELECT DISTINCT provider_id FROM hosp.provider) pr
            ON m.order_provider_id = pr.provider_id

        UNION ALL

        SELECT
            'poe.order_provider_id -> provider.provider_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE po.order_provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE po.order_provider_id IS NULL),
            COUNT(*) FILTER (WHERE pr.provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE po.order_provider_id IS NOT NULL AND pr.provider_id IS NULL)
        FROM hosp.poe po
        LEFT JOIN (SELECT DISTINCT provider_id FROM hosp.provider) pr
            ON po.order_provider_id = pr.provider_id

        UNION ALL

        SELECT
            'poe_detail.poe_id -> poe.poe_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE pd.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE pd.poe_id IS NULL),
            COUNT(*) FILTER (WHERE po.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE pd.poe_id IS NOT NULL AND po.poe_id IS NULL)
        FROM hosp.poe_detail pd
        LEFT JOIN (SELECT DISTINCT poe_id FROM hosp.poe) po
            ON pd.poe_id = po.poe_id

        UNION ALL

        SELECT
            'poe_detail.(poe_id, poe_seq) -> poe.(poe_id, poe_seq)',
            COUNT(*),
            COUNT(*) FILTER (WHERE pd.poe_id IS NOT NULL AND pd.poe_seq IS NOT NULL),
            COUNT(*) FILTER (WHERE pd.poe_id IS NULL OR pd.poe_seq IS NULL),
            COUNT(*) FILTER (WHERE po.poe_id IS NOT NULL AND po.poe_seq IS NOT NULL),
            COUNT(*) FILTER (
                WHERE pd.poe_id IS NOT NULL
                  AND pd.poe_seq IS NOT NULL
                  AND po.poe_id IS NULL
            )
        FROM hosp.poe_detail pd
        LEFT JOIN (
            SELECT DISTINCT poe_id, poe_seq
            FROM hosp.poe
        ) po
            ON pd.poe_id = po.poe_id
           AND pd.poe_seq = po.poe_seq

        UNION ALL

        SELECT
            'prescriptions.poe_id -> poe.poe_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE rx.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.poe_id IS NULL),
            COUNT(*) FILTER (WHERE po.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.poe_id IS NOT NULL AND po.poe_id IS NULL)
        FROM hosp.prescriptions rx
        LEFT JOIN (SELECT DISTINCT poe_id FROM hosp.poe) po
            ON rx.poe_id = po.poe_id

        UNION ALL

        SELECT
            'prescriptions.(poe_id, poe_seq) -> poe.(poe_id, poe_seq)',
            COUNT(*),
            COUNT(*) FILTER (WHERE rx.poe_id IS NOT NULL AND rx.poe_seq IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.poe_id IS NULL OR rx.poe_seq IS NULL),
            COUNT(*) FILTER (WHERE po.poe_id IS NOT NULL AND po.poe_seq IS NOT NULL),
            COUNT(*) FILTER (
                WHERE rx.poe_id IS NOT NULL
                  AND rx.poe_seq IS NOT NULL
                  AND po.poe_id IS NULL
            )
        FROM hosp.prescriptions rx
        LEFT JOIN (
            SELECT DISTINCT poe_id, poe_seq
            FROM hosp.poe
        ) po
            ON rx.poe_id = po.poe_id
           AND rx.poe_seq = po.poe_seq

        UNION ALL

        SELECT
            'prescriptions.pharmacy_id -> pharmacy.pharmacy_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE rx.pharmacy_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.pharmacy_id IS NULL),
            COUNT(*) FILTER (WHERE ph.pharmacy_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.pharmacy_id IS NOT NULL AND ph.pharmacy_id IS NULL)
        FROM hosp.prescriptions rx
        LEFT JOIN (SELECT DISTINCT pharmacy_id FROM hosp.pharmacy) ph
            ON rx.pharmacy_id = ph.pharmacy_id

        UNION ALL

        SELECT
            'prescriptions.order_provider_id -> provider.provider_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE rx.order_provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.order_provider_id IS NULL),
            COUNT(*) FILTER (WHERE pr.provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE rx.order_provider_id IS NOT NULL AND pr.provider_id IS NULL)
        FROM hosp.prescriptions rx
        LEFT JOIN (SELECT DISTINCT provider_id FROM hosp.provider) pr
            ON rx.order_provider_id = pr.provider_id

        UNION ALL

        SELECT
            'pharmacy.poe_id -> poe.poe_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE ph.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ph.poe_id IS NULL),
            COUNT(*) FILTER (WHERE po.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ph.poe_id IS NOT NULL AND po.poe_id IS NULL)
        FROM hosp.pharmacy ph
        LEFT JOIN (SELECT DISTINCT poe_id FROM hosp.poe) po
            ON ph.poe_id = po.poe_id

        UNION ALL

        SELECT
            'emar.poe_id -> poe.poe_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE e.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.poe_id IS NULL),
            COUNT(*) FILTER (WHERE po.poe_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.poe_id IS NOT NULL AND po.poe_id IS NULL)
        FROM hosp.emar e
        LEFT JOIN (SELECT DISTINCT poe_id FROM hosp.poe) po
            ON e.poe_id = po.poe_id

        UNION ALL

        SELECT
            'emar.pharmacy_id -> pharmacy.pharmacy_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE e.pharmacy_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.pharmacy_id IS NULL),
            COUNT(*) FILTER (WHERE ph.pharmacy_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.pharmacy_id IS NOT NULL AND ph.pharmacy_id IS NULL)
        FROM hosp.emar e
        LEFT JOIN (SELECT DISTINCT pharmacy_id FROM hosp.pharmacy) ph
            ON e.pharmacy_id = ph.pharmacy_id

        UNION ALL

        SELECT
            'emar.enter_provider_id -> provider.provider_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE e.enter_provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.enter_provider_id IS NULL),
            COUNT(*) FILTER (WHERE pr.provider_id IS NOT NULL),
            COUNT(*) FILTER (WHERE e.enter_provider_id IS NOT NULL AND pr.provider_id IS NULL)
        FROM hosp.emar e
        LEFT JOIN (SELECT DISTINCT provider_id FROM hosp.provider) pr
            ON e.enter_provider_id = pr.provider_id

        UNION ALL

        SELECT
            'emar_detail.subject_id -> patients.subject_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE ed.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.subject_id IS NULL),
            COUNT(*) FILTER (WHERE p.subject_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.subject_id IS NOT NULL AND p.subject_id IS NULL)
        FROM hosp.emar_detail ed
        LEFT JOIN (SELECT DISTINCT subject_id FROM hosp.patients) p
            ON ed.subject_id = p.subject_id

        UNION ALL

        SELECT
            'emar_detail.emar_id -> emar.emar_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE ed.emar_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.emar_id IS NULL),
            COUNT(*) FILTER (WHERE e.emar_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.emar_id IS NOT NULL AND e.emar_id IS NULL)
        FROM hosp.emar_detail ed
        LEFT JOIN (SELECT DISTINCT emar_id FROM hosp.emar) e
            ON ed.emar_id = e.emar_id

        UNION ALL

        SELECT
            'emar_detail.(emar_id, emar_seq) -> emar.(emar_id, emar_seq)',
            COUNT(*),
            COUNT(*) FILTER (WHERE ed.emar_id IS NOT NULL AND ed.emar_seq IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.emar_id IS NULL OR ed.emar_seq IS NULL),
            COUNT(*) FILTER (WHERE e.emar_id IS NOT NULL AND e.emar_seq IS NOT NULL),
            COUNT(*) FILTER (
                WHERE ed.emar_id IS NOT NULL
                  AND ed.emar_seq IS NOT NULL
                  AND e.emar_id IS NULL
            )
        FROM hosp.emar_detail ed
        LEFT JOIN (
            SELECT DISTINCT emar_id, emar_seq
            FROM hosp.emar
        ) e
            ON ed.emar_id = e.emar_id
           AND ed.emar_seq = e.emar_seq

        UNION ALL

        SELECT
            'emar_detail.pharmacy_id -> pharmacy.pharmacy_id',
            COUNT(*),
            COUNT(*) FILTER (WHERE ed.pharmacy_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.pharmacy_id IS NULL),
            COUNT(*) FILTER (WHERE ph.pharmacy_id IS NOT NULL),
            COUNT(*) FILTER (WHERE ed.pharmacy_id IS NOT NULL AND ph.pharmacy_id IS NULL)
        FROM hosp.emar_detail ed
        LEFT JOIN (SELECT DISTINCT pharmacy_id FROM hosp.pharmacy) ph
            ON ed.pharmacy_id = ph.pharmacy_id

        UNION ALL

        SELECT
            'hcpcsevents.hcpcs_cd -> d_hcpcs.code',
            COUNT(*),
            COUNT(*) FILTER (WHERE h.hcpcs_cd IS NOT NULL),
            COUNT(*) FILTER (WHERE h.hcpcs_cd IS NULL),
            COUNT(*) FILTER (WHERE dh.code IS NOT NULL),
            COUNT(*) FILTER (WHERE h.hcpcs_cd IS NOT NULL AND dh.code IS NULL)
        FROM hosp.hcpcsevents h
        LEFT JOIN (SELECT DISTINCT code FROM hosp.d_hcpcs) dh
            ON h.hcpcs_cd = dh.code
    )

    SELECT
        candidate_relationship,
        source_rows,
        source_non_null_link_rows,
        source_null_link_rows,
        matched_rows,
        unmatched_non_null_rows,
        CASE
            WHEN unmatched_non_null_rows = 0
                 AND source_null_link_rows = 0
                THEN 'complete_conservative_inferred_relationship'

            WHEN unmatched_non_null_rows = 0
                 AND source_null_link_rows > 0
                THEN 'complete_when_link_present_with_null_source_links'

            ELSE 'partial_or_context_dependent_candidate_link'
        END AS relationship_assessment
    FROM relationship_checks
)
TO 'output/relationship_assessments/hosp_candidate_relationship_checks.csv'
WITH (HEADER, DELIMITER ',');