# Preliminary Conceptual Model Mapping

This document records how selected MIMIC-IV Demo hospital-module tables were interpreted as candidate conceptual entities or supporting reference structures during Step 0. These mappings are preliminary and are intended to support later stakeholder review.

| Conceptual model term | Meaning in the preliminary model | Related MIMIC-IV Demo table(s) | Key identifier-like fields | Notes for stakeholder review |
|---|---|---|---|---|
| Patient | Person receiving care | `patients` | `subject_id` | Candidate patient-level entity |
| Hospital admission | Hospitalization episode | `admissions` | `hadm_id`, `subject_id` | Candidate admission-level entity/event |
| Care location event | Ward/unit movement or location-related episode | `transfers` | `transfer_id`, `subject_id`, `hadm_id`, `stay_id` | Needs stakeholder clarification because location movements may not always represent clinically distinct care episodes |
| Diagnosis | Diagnosis associated with a hospital admission | `diagnoses_icd` | `subject_id`, `hadm_id`, `icd_code`, `icd_version` | Linked to diagnosis code definitions |
| Diagnosis code definition | Reference definition for ICD diagnosis codes | `d_icd_diagnoses` | `icd_code`, `icd_version` | Supporting dictionary/reference structure |
| Procedure | Procedure associated with a hospital admission | `procedures_icd` | `subject_id`, `hadm_id`, `icd_code`, `icd_version` | Linked to procedure code definitions |
| Procedure code definition | Reference definition for ICD procedure codes | `d_icd_procedures` | `icd_code`, `icd_version` | Supporting dictionary/reference structure |
| Laboratory observation | Laboratory result or measurement event | `labevents` | `labevent_id`, `subject_id`, `hadm_id`, `itemid` | `hadm_id` link was partial in the demo subset; admission-level interpretation may require caution |
| Laboratory item definition | Reference definition for laboratory item codes | `d_labitems` | `itemid` | Supporting dictionary/reference structure |
| Provider order | Order placed in the provider order entry system | `poe` | `poe_id`, `subject_id`, `hadm_id` | Candidate order-level structure |
| Medication prescription | Medication prescription/order record | `prescriptions` | `subject_id`, `hadm_id`, `pharmacy_id`, `poe_id` | Medication concept may require alignment across order, pharmacy, and administration tables |
| Pharmacy workflow record | Pharmacy-related medication workflow record | `pharmacy` | `pharmacy_id`, `subject_id`, `hadm_id`, `poe_id` | May represent dispensing/workflow context rather than a simple medication entity |
| Medication administration | Medication administration event | `emar` | `emar_id`, `subject_id`, `hadm_id`, `pharmacy_id` | `hadm_id` link was partial in the demo subset; should be reviewed cautiously |
| Clinical service context | Hospital service assignment or service context | `services` | `subject_id`, `hadm_id` | Candidate contextual structure for admission-level care |