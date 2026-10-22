# Recorded assumptions (Step 1)

Before the relationship checks were run, the MIMIC-IV documentation was used to formulate assumptions about table roles, identifiers, and plausible links. Each assumption is listed with the documentation quote it is based on and the checks it affects. The assumptions guided the selection of checks; they were not treated as established relationships or database constraints.

## Hospital module (30 assumptions)

| Assumption | Documentation quote | Checks affected |
|---|---|---|
| Use the `hosp` module as the hospital-wide EHR-derived source scope. | “hospital (`hosp`) module contains data acquired from the hospital wide electronic health record” ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview.html)) | Selection of hosp tables; exclusion of ICU-specific checks. |
| Treat `subject_id` as the patient-level identifier. | “`subject_id` is a unique identifier which specifies an individual patient.” ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview.html)) | Source table `subject_id` → `patients.subject_id` checks. |
| Treat `hadm_id` as the hospitalization-level identifier. | “`hadm_id` is an integer identifier which is unique for each patient hospitalization.” ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview.html)) | Source table `hadm_id` → `admissions.hadm_id` checks. |
| Treat `admissions` as the definition table for hospital admissions. | “the admissions table can be considered as a definition table for `hadm_id`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/admissions.html)) | `admissions.subject_id` → `patients.subject_id`; source `hadm_id` → `admissions.hadm_id`. |
| Interpret `transfers` as physical location/care-location events. | “Physical locations for patients throughout their hospital stay.” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/transfers.html)) | `transfers.subject_id` → `patients.subject_id`; `transfers.hadm_id` → `admissions.hadm_id`. |
| Treat `transfer_id` as location-level, not admission-level. | “`transfer_id` is unique to a patient physical location.” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/transfers.html)) | Supports modeling transfers as care-location events rather than admissions. |
| Interpret `services` as clinical service context linked to patient/admission. | “describes the service that a patient was admitted under” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/services.html)) | `services.subject_id` → `patients.subject_id`; `services.hadm_id` → `admissions.hadm_id`. |
| Treat `labevents.itemid` as linking to the lab item dictionary. | “d_labitems on `itemid`” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/labevents.html)) | `labevents.itemid` → `d_labitems.itemid`. |
| Interpret null `hadm_id` in laboratory rows cautiously. | “does not always perfectly capture labs proximal to the hospital stay” ([MIMIC](https://mimic.mit.edu/docs/IV/modules/hosp/labevents.html)) | `labevents.hadm_id` → `admissions.hadm_id`;  supports classification as a partially complete inferred relationship. |
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

Each quote links to the documentation page it is taken from.

## How the 48 hospital-module checks were selected

The checks were selected using the assumptions above, the structural summaries, and their relevance for the conceptual data model. They do not enumerate all possible joins.

Selection followed two principles: each source table was checked against its documented parent or reference structure (for example, `admissions` for `hadm_id`, `d_labitems` for `itemid` and `pharmacy` for `pharmacy_id`), and tables that only share a patient or admission identifier, such as laboratory and microbiology events, were not checked against each other, because their connection runs through the patient or admission.

| Relationship-check category | Count | Why included |
|---|---:|---|
| Patient-level linkage checks | **15** | Selected hospital-module source tables containing `subject_id` were checked against `patients.subject_id` when relevant to the conceptual model. |
| Admission-level linkage checks | **12** | Selected hospital-module source tables containing `hadm_id` were checked against `admissions.hadm_id` when relevant to admission-level context. |
| Dictionary/reference checks | **4** | Code, item, or billing event tables were checked against documented dictionary/reference tables. |
| Provider-reference checks | **6** | Provider-related columns were checked against `provider.provider_id` based on MIMIC-IV documentation on prefixed provider columns. |
| Order, medication, and detail workflow checks | **11** | Selected documented or model-relevant workflow links were checked among `poe`, `poe_detail`, `prescriptions`, `pharmacy`, `emar`, and `emar_detail`. |
| **Total** | **48** | Selected candidate relationship checks used in the main relationship assessment. |

## Extension: ICU and ED modules (3 assumptions)

Three further assumptions were recorded before the extension checks in `sql/main/12_export_extension_relationship_checks.sql` were run.

| Assumption | Documentation quote | Checks affected |
|---|---|---|
| Treat `icustays` and `d_items` as the reference structures of the ICU module. | "MetaVision tables were denormalized to create a star schema where the icustays and d_items tables link to a set of data tables all suffixed with 'events'." "All events tables contain a stay_id column allowing identification of the associated ICU patient in icustays, and an itemid column allowing identification of the concept documented in d_items." ([MIMIC](https://mimic.mit.edu/docs/IV/modules/icu/)) | ICU event tables → `icustays.stay_id`; ICU event tables → `d_items.itemid` (12 checks) |
| Treat `stay_id` as derived from the earliest `transfer_id` of a unit stay. | "As stay_id is generated using the earliest transfer_id existing for the department (e.g. the first transfer_id for an ICU), stay_id and transfer_id are often identical for the same ward stay." ([MIMIC](https://mimic.mit.edu/docs/IV/about/schema-overview/)) | `icustays.stay_id` → `transfers.transfer_id`; `edstays.stay_id` → `transfers.transfer_id` (2 checks) |
| Treat the ED module as linkable to the hospital module through `subject_id`. | "the MIMIC-IV-ED demo is linkable to the MIMIC-IV Clinical Database demo via subject_id" ([PhysioNet](https://doi.org/10.13026/jzz5-vs76)) | ED tables → `patients.subject_id` (6 checks) |

The remaining extension checks follow the same selection principles as the hospital-module checks: ICU event tables → `caregiver.caregiver_id` (6); `icustays.subject_id` → `patients.subject_id` (1); `icustays`, the six ICU event tables and `edstays` → `admissions.hadm_id` (8); and the five ED data tables → `edstays.stay_id` (5). In total, 40 extension checks were evaluated (12 + 2 + 6 + 6 + 1 + 8 + 5).

## How the assumptions were checked

The join-based checks (`sql/main/08` and `12`) test each selected link in the data and classify it by a fixed rule: fully complete (every source row links and every link matches), partially complete (some linking values are missing, but every value present matches), or context-dependent (some values present do not match the target). The checks are a curated set, not an exhaustive search for joins, and not declared primary or foreign key constraints.

## References

MIMIC-IV documentation. MIT Laboratory for Computational Physiology. Available at: https://mimic.mit.edu/docs/IV/

Johnson, A. E. W., Stone, D. J., Celi, L. A., & Pollard, T. J. (2018). The MIMIC Code Repository: Enabling reproducibility in critical care research. *Journal of the American Medical Informatics Association, 25*(1), 32–39. https://doi.org/10.1093/jamia/ocx084
