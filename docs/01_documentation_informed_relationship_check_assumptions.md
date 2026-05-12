# Documentation-Informed Relationship Check Assumptions

This document records documentation-informed assumptions used before running candidate relationship checks for the MIMIC-IV Demo hospital-module application.

The assumptions below were derived from MIMIC-IV documentation and used to orient the selection and interpretation of candidate relationship checks. They were not treated as proven relationships or formal database constraints. The join-based relationship checks were then used to evaluate how selected candidate links behaved in the Demo data, including whether non-null source values matched the proposed target or reference structure and whether links were complete, complete when present, or partial/context-dependent.

## Documentation-informed assumptions

| Documentation-informed assumption used before relationship checks | Exact MIMIC-IV quote to verify | Candidate relationship checks affected |
|---|---|---|
| Use the `hosp` module as the hospital-wide EHR-derived source scope. | “hospital (`hosp`) module contains data acquired from the hospital wide electronic health record” ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview.html)) | Selection of hosp tables; exclusion of ICU-specific checks. |
| Treat `subject_id` as the patient-level identifier. | “`subject_id` is a unique identifier which specifies an individual patient.” ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview.html)) | Source table `subject_id` → `patients.subject_id` checks. |
| Treat `hadm_id` as the hospitalization-level identifier. | “`hadm_id` is an integer identifier which is unique for each patient hospitalization.” ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview.html)) | Source table `hadm_id` → `admissions.hadm_id` checks. |
| Treat `admissions` as the definition table for hospital admissions. | “the admissions table can be considered as a definition table for `hadm_id`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/admissions.html)) | `admissions.subject_id` → `patients.subject_id`; source `hadm_id` → `admissions.hadm_id`. |
| Interpret `transfers` as physical location/care-location events. | “Physical locations for patients throughout their hospital stay.” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/transfers.html)) | `transfers.subject_id` → `patients.subject_id`; `transfers.hadm_id` → `admissions.hadm_id`. |
| Treat `transfer_id` as location-level, not admission-level. | “`transfer_id` is unique to a patient physical location.” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/transfers.html)) | Supports modeling transfers as care-location events rather than admissions. |
| Interpret `services` as clinical service context linked to patient/admission. | “describes the service that a patient was admitted under” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/services.html)) | `services.subject_id` → `patients.subject_id`; `services.hadm_id` → `admissions.hadm_id`. |
| Treat `labevents.itemid` as linking to the lab item dictionary. | “d_labitems on `itemid`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/labevents.html)) | `labevents.itemid` → `d_labitems.itemid`. |
| Interpret null `hadm_id` in laboratory rows cautiously. | “does not always perfectly capture labs proximal to the hospital stay” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/labevents.html)) | `labevents.hadm_id` → `admissions.hadm_id`; supports “complete when link present with null source links.” |
| Treat `d_labitems` as the reference structure for lab item concepts. | “definitions for all `itemid` associated with lab measurements” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/d_labitems.html)) | `labevents.itemid` → `d_labitems.itemid`; lab item reference entity. |
| Interpret microbiology rows as specimen/test/organism/susceptibility structured. | “multiple rows for the single specimen” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/microbiologyevents.html)) | Supports microbiology as its own event/result structure, not a simple admission-level table. |
| Interpret null `hadm_id` in microbiology rows cautiously. | “does not always perfectly capture labs around the hospital stay” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/microbiologyevents.html)) | `microbiologyevents.hadm_id` → `admissions.hadm_id`; supports null-link context. |
| Treat `provider` as the provider reference table. | “A description table for providers in the database referenced by provider_id.” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/provider.html)) | Provider-related checks to `provider.provider_id`. |
| Treat prefixed provider columns as provider links. | “All columns with a suffix link to `provider_id`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/provider.html)) | `order_provider_id`, `enter_provider_id`, `admit_provider_id` → `provider.provider_id`. |
| Interpret `poe` as the provider order entry structure. | “care providers at the hospital enter orders” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/poe.html)) | Medication/order links involving `poe_id`. |
| Treat `poe_id` as an order identifier. | “A unique identifier for the given order.” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/poe.html)) | `poe_detail.poe_id` → `poe.poe_id`; `prescriptions/pharmacy/emar.poe_id` → `poe.poe_id`. |
| Treat `poe_detail` as an EAV-style detail table. | “uses an Entity-Attribute-Value (EAV) model” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/poe_detail.html)) | `poe_detail.poe_id` → `poe.poe_id`; detail/workflow-specific structure. |
| Treat `prescriptions` as medication prescription information. | “provides information about prescribed medications” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/prescriptions.html)) | Medication workflow checks involving prescriptions. |
| Treat prescriptions as linkable to POE orders through `poe_id`/`poe_seq`. | “allow linking prescriptions to associated orders in the poe table” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/prescriptions.html)) | `prescriptions.poe_id` → `poe.poe_id`. |
| Treat `pharmacy` as filled-medication/pharmacy workflow information. | “detailed information regarding filled medications” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/pharmacy.html)) | `pharmacy.poe_id` → `poe.poe_id`; `pharmacy.pharmacy_id` medication workflow links. |
| Treat `pharmacy_id` as a pharmacy entry identifier and medication-workflow link. | “unique identifier for the given pharmacy entry” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/pharmacy.html)) | `prescriptions.pharmacy_id` → `pharmacy.pharmacy_id`; `emar.pharmacy_id` → `pharmacy.pharmacy_id`; `emar_detail.pharmacy_id` → `pharmacy.pharmacy_id`. |
| Treat `emar` as medication administration data. | “record administrations of a given medicine” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/emar.html)) | `emar.emar_id`, `emar.poe_id`, `emar.pharmacy_id`, `emar.hadm_id` checks. |
| Interpret eMAR coverage cautiously. | “eMAR data is not available for all patients” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/emar.html)) | Supports modeling eMAR as available administration evidence, not complete medication administration coverage. |
| Treat `emar_detail` as a detail table under eMAR. | “information for each medicine administration made in the EMAR table” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/emar_detail.html)) | `emar_detail.emar_id` → `emar.emar_id`; `emar_detail.pharmacy_id` → `pharmacy.pharmacy_id`. |
| Expect possible one-to-many eMAR detail structure. | “multiple rows in emar_detail correspond to a single row in emar” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/emar_detail.html)) | Supports detail-structure interpretation of `emar_detail`. |
| Treat diagnosis code links as composite `icd_code` + `icd_version`. | “d_icd_diagnoses ON `icd_code` and `icd_version`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/diagnoses_icd.html)) | `diagnoses_icd.(icd_code, icd_version)` → `d_icd_diagnoses.(icd_code, icd_version)`. |
| Treat procedure code links as composite `icd_code` + `icd_version`. | “d_icd_procedures on `icd_code` and `icd_version`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/procedures_icd.html)) | `procedures_icd.(icd_code, icd_version)` → `d_icd_procedures.(icd_code, icd_version)`. |
| Treat HCPCS event codes as linking to `d_hcpcs` using a different column name. | “Link this to `code` in d_hcpcs” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/hcpcsevents.html)) | `hcpcsevents.hcpcs_cd` → `d_hcpcs.code`; example not discoverable by same-name scan alone. |
| Treat DRG records as hospitalization-related reimbursement/billing structures. | “DRGs are used by the hospital to obtain reimbursement” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/drgcodes.html)) | `drgcodes.subject_id` → `patients.subject_id`; `drgcodes.hadm_id` → `admissions.hadm_id`. |
| Treat OMR as patient-level/miscellaneous EHR context, not admission-linked by default. | “stores miscellaneous information documented in the electronic health record” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/omr.html)) | `omr.subject_id` → `patients.subject_id`; no direct `omr.hadm_id` → `admissions.hadm_id` check. |

## Selection categories for candidate relationship checks

The main relationship-assessment output evaluated 48 selected candidate relationship checks. These checks were selected using MIMIC-IV documentation, structural inspection outputs, and conceptual-model relevance. They were not intended to exhaustively enumerate all possible joins in the MIMIC-IV Demo hospital module.

| Relationship-check category | Count | Why included |
|---|---:|---|
| Patient-level linkage checks | **16** | Selected hospital-module source tables containing `subject_id` were checked against `patients.subject_id` when relevant to the conceptual model. |
| Admission-level linkage checks | **12** | Selected hospital-module source tables containing `hadm_id` were checked against `admissions.hadm_id` when relevant to admission-level context. |
| Dictionary/reference checks | **4** | Code, item, or billing event tables were checked against documented dictionary/reference tables. |
| Provider-reference checks | **6** | Provider-related columns were checked against `provider.provider_id` based on MIMIC-IV documentation on prefixed provider columns. |
| Order, medication, and detail workflow checks | **10** | Selected documented or model-relevant workflow links were checked among `poe`, `poe_detail`, `prescriptions`, `pharmacy`, `emar`, and `emar_detail`. |
| **Total** | **48** | Selected candidate relationship checks used in the main relationship assessment. |

## Relationship to the SQL checks

These documentation-informed assumptions helped define candidate reference structures, table roles, and plausible linking columns before the relationship checks were run. Structural inspection outputs then confirmed which relevant columns were present in the loaded MIMIC-IV Demo hospital-module tables.

The SQL relationship checks evaluated selected candidate links empirically in the MIMIC-IV Demo data. The checks assessed whether non-null source values matched the proposed target or reference structure and whether each selected link was complete, complete when present but not always populated, or partial/context-dependent.

The selected checks should be interpreted as a curated, documentation- and structure-informed relationship assessment set. They should not be interpreted as an exhaustive discovery of all possible joins or as formal primary-key/foreign-key constraints.