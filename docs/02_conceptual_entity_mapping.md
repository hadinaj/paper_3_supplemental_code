# Conceptual Entity Mapping

This document records how the MIMIC-IV Demo hospital-module source tables were interpreted during construction of the conceptual data model artifact. It maps inspected source tables to candidate conceptual entities, reference entities, detail or workflow-specific structures, or source structures retained for traceability. The mapping preserves table-level traceability from inspected source structures to conceptual model elements and supporting modeling decisions.

The mappings are intended for stakeholder review and methodological transparency. They do not represent finalized stakeholder-validated concepts or formal database constraints.

## Modeling role definitions

The `Modeling role` column records how each MIMIC-IV Demo hospital-module source table was interpreted during conceptual model construction.

- **Candidate entity**: A source-derived clinical, administrative, workflow, or context concept represented as a candidate entity in the conceptual data model artifact. Candidate entities are reviewable and not stakeholder-validated concepts.
- **Reference entity**: A dictionary, code-definition, item-definition, provider, or other reference structure used to interpret coded or identifier-based source records.
- **Detail or workflow-specific structure**: A supporting source structure that records additional detail, operational workflow information, or EAV-style content linked to another source structure.
- **Source structure retained for traceability**: A source structure documented in the mapping for transparency but not necessarily emphasized as a main candidate entity in the conceptual model representation.

| Source table | Conceptual entity or structure | Modeling role | Candidate identifier or linking field(s) | Notes |
|---|---|---|---|---|
| patients | Patient | candidate entity | subject_id | Patient-level source table. |
| admissions | Hospital admission | candidate entity | hadm_id; subject_id | Admission-level source table. |
| transfers | Care location event | candidate entity | transfer_id; hadm_id; subject_id | Physical location or unit transfer source table. |
| services | Clinical service context | candidate entity | hadm_id; subject_id | Hospital service context source table. |
| diagnoses_icd | Diagnosis | candidate entity | subject_id; hadm_id; icd_code; icd_version | Billed diagnosis source table. |
| d_icd_diagnoses | Diagnosis code definition | reference entity | icd_code; icd_version | ICD diagnosis code dictionary. |
| procedures_icd | Procedure | candidate entity | subject_id; hadm_id; icd_code; icd_version | Billed procedure source table. |
| d_icd_procedures | Procedure code definition | reference entity | icd_code; icd_version | ICD procedure code dictionary. |
| drgcodes | DRG assignment | candidate entity | subject_id; hadm_id; drg_code | DRG reimbursement classification source table. |
| hcpcsevents | HCPCS billed event | candidate entity | subject_id; hadm_id; hcpcs_cd | HCPCS/CPT billed event source table. |
| d_hcpcs | HCPCS code definition | reference entity | code | HCPCS/CPT code dictionary. |
| labevents | Laboratory observation | candidate entity | labevent_id; subject_id; hadm_id; itemid | Laboratory result source table. |
| d_labitems | Laboratory item definition | reference entity | itemid | Laboratory item dictionary. |
| microbiologyevents | Microbiology observation | candidate entity | microevent_id; subject_id; hadm_id | Microbiology specimen/test/result source table. |
| provider | Provider | reference entity | provider_id | Provider identifier reference table. |
| poe | Provider order | candidate entity | poe_id; subject_id; hadm_id | Provider order entry source table. |
| poe_detail | Provider order detail | detail or workflow-specific structure | poe_id; field_name | EAV-style supplementary order detail table. |
| prescriptions | Medication prescription | candidate entity | pharmacy_id; poe_id; subject_id; hadm_id | Medication prescription source table. |
| pharmacy | Pharmacy workflow record | candidate entity | pharmacy_id; poe_id; subject_id; hadm_id | Pharmacy medication workflow source table. |
| emar | Medication administration | candidate entity | emar_id; pharmacy_id; poe_id; subject_id; hadm_id | Electronic medication administration source table. |
| emar_detail | Medication administration detail | detail or workflow-specific structure | emar_id; pharmacy_id | Supplementary eMAR detail source table. |
| omr | Online medical record measurement/context | candidate entity | subject_id; chartdate | Online medical record measurements and miscellaneous EHR context. |