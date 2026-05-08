# CMD_master entity crosswalk

This file documents how candidate CMD_master entities relate to MIMIC-IV Demo source structures and to broadly corresponding concepts in common health data models. The crosswalk is intended as an orientation aid for conceptual modeling and stakeholder review. It is not a formal OMOP or FHIR mapping.

| CMD_master entity | MIMIC-IV source structure | Conceptual role | Approximate OMOP correspondence | Approximate FHIR correspondence | Notes |
|---|---|---|---|---|---|
| Patient | `patients` | Person/patient subject | Person | Patient | Patient-level structure identified through `subject_id`. |
| Hospital admission | `admissions` | Hospital encounter/visit | Visit Occurrence | Encounter | Admission-level structure identified through `hadm_id`. |
| Diagnosis | `diagnoses_icd` | Coded diagnosis assigned during admission | Condition Occurrence | Condition | Linked to admission and ICD diagnosis definitions. |
| Diagnosis code definition | `d_icd_diagnoses` | Diagnosis terminology/reference definition | Concept / Vocabulary-related tables | CodeSystem / ValueSet context | Reference structure for diagnosis code meaning. |
| Procedure | `procedures_icd` | Coded procedure during admission | Procedure Occurrence | Procedure | Linked to admission and ICD procedure definitions. |
| Procedure code definition | `d_icd_procedures` | Procedure terminology/reference definition | Concept / Vocabulary-related tables | CodeSystem / ValueSet context | Reference structure for procedure code meaning. |
| Laboratory observation | `labevents` | Laboratory measurement/observation | Measurement | Observation | Observation-level structure linked to laboratory item definitions. |
| Laboratory item definition | `d_labitems` | Laboratory item/reference definition | Concept / Measurement concept mapping | Observation code / CodeSystem context | Reference structure for laboratory item meaning. |
| Provider order | `poe` | Provider-entered order/request | No single direct target; may inform source-specific order logic | ServiceRequest / MedicationRequest / Procedure request context | Requires interpretation based on order type and use case. |
| Medication prescription | `prescriptions`, `pharmacy` | Medication prescribing/pharmacy workflow | Drug Exposure | MedicationRequest / MedicationDispense context | Medication workflow representation depends on ETL/modeling objective. |
| Medication administration | `emar` | Medication administration event | Drug Exposure or source-specific medication event logic | MedicationAdministration | Kept separate in CMD_master to preserve workflow traceability. |
| Clinical service context | `services` | Organizational/service assignment during admission | Visit Detail / Provider / Care Site context | Encounter service/type context | Contextual structure requiring local interpretation. |
| Care location event | `transfers` | Patient movement/location/stay context | Visit Detail / Care Site / Location context | Encounter location / Location | Partial/context-dependent links should be reviewed. |