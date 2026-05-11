# Conceptual Model Representation Notes

This document records representation decisions used during construction of the conceptual data model artifact, including candidate conceptual entities, selected attributes, candidate identifiers or linking fields, supporting reference structures, supporting detail structures, and relationship notation. The notes are intended to preserve traceability between inspected MIMIC-IV Demo hospital-module source structures, intermediate mapping outputs, and the final conceptual model representation.

| Conceptual model term | Meaning in the conceptual data model | Related MIMIC-IV Demo table(s) | Key or linking field(s) | Modeling note |
|---|---|---|---|---|
| Patient | Person receiving care | `patients` | `subject_id` | Candidate patient-level entity |
| Hospital admission | Hospitalization episode | `admissions` | `hadm_id`, `subject_id` | Candidate admission-level entity/event |
| Care location event | Ward/unit movement or location-related episode | `transfers` | `transfer_id`, `subject_id`, `hadm_id` | Candidate contextual/event structure; admission-level link should be interpreted cautiously if relationship checks are partial |
| Clinical service context | Hospital service assignment or service context | `services` | `subject_id`, `hadm_id` | Candidate contextual structure for admission-level care |
| Diagnosis | Diagnosis associated with a hospital admission | `diagnoses_icd` | `subject_id`, `hadm_id`, `icd_code`, `icd_version` | Linked to diagnosis code definitions |
| Diagnosis code definition | Reference definition for ICD diagnosis codes | `d_icd_diagnoses` | `icd_code`, `icd_version` | Supporting dictionary/reference structure |
| Procedure | Procedure associated with a hospital admission | `procedures_icd` | `subject_id`, `hadm_id`, `icd_code`, `icd_version` | Linked to procedure code definitions |
| Procedure code definition | Reference definition for ICD procedure codes | `d_icd_procedures` | `icd_code`, `icd_version` | Supporting dictionary/reference structure |
| Laboratory observation | Laboratory result or measurement event | `labevents` | `labevent_id`, `subject_id`, `hadm_id`, `itemid` | `hadm_id` link was partial in the demo subset; admission-level interpretation may require caution |
| Laboratory item definition | Reference definition for laboratory item codes | `d_labitems` | `itemid` | Supporting dictionary/reference structure |
| Microbiology observation | Microbiology test, organism, and susceptibility-related event | `microbiologyevents` | `microevent_id`, `subject_id`, `hadm_id`, `micro_specimen_id`, `spec_itemid`, `test_itemid`, `org_itemid`, `ab_itemid` | Candidate microbiology event structure; item-like fields are retained as attributes unless dedicated reference structures and checked links are added |
| Provider order | Order placed in the provider order entry system | `poe` | `poe_id`, `subject_id`, `hadm_id` | Candidate order-level structure |
| Provider order detail | Supporting detail fields for provider orders | `poe_detail` | `poe_id`, `poe_seq`, `subject_id` | Supporting detail/extension structure rather than a primary conceptual entity |
| Medication prescription | Medication prescription/order record | `prescriptions` | `subject_id`, `hadm_id`, `pharmacy_id`, `poe_id` | Medication concept may require alignment across order, pharmacy, and administration tables |
| Pharmacy / dispense context | Pharmacy-related medication workflow or dispensing context | `pharmacy` | `pharmacy_id`, `subject_id`, `hadm_id`, `poe_id` | May represent dispensing/workflow context rather than a simple medication entity |
| Medication administration | Medication administration event | `emar` | `emar_id`, `subject_id`, `hadm_id`, `pharmacy_id`, `poe_id` | `hadm_id` link was partial in the demo subset; should be reviewed cautiously |
| Medication administration detail | Supporting detail fields for medication administration | `emar_detail` | `subject_id`, `emar_id`, `emar_seq`, `pharmacy_id` | Supporting detail/extension structure rather than a primary conceptual entity |
| OMR measurement | Outpatient/inpatient medical record measurement or result-like entry linked to a patient | `omr` | `subject_id`, `chartdate`, `seq_num` | Candidate patient-level observation/context structure. Relationship check classified `omr.subject_id -> patients.subject_id` as `complete_conservative_inferred_relationship`; OMR is therefore modeled as patient-linked additional clinical context rather than admission-level data. |
| DRG code record | Diagnosis-related group code associated with an admission | `drgcodes` | `subject_id`, `hadm_id`, `drg_code` | Coding/billing-related structure; may be represented in the full source-traceable schema output |
| HCPCS event | HCPCS-coded hospital event or billing-related procedure record | `hcpcsevents` | `subject_id`, `hadm_id`, `hcpcs_cd` | Coding/billing-related structure; may be represented in the full source-traceable schema output |
| HCPCS code definition | Reference definition for HCPCS codes | `d_hcpcs` | `code` | Supporting dictionary/reference structure |
| Provider | Provider identifier reference structure | `provider` | `provider_id` | Supporting identifier/reference structure |