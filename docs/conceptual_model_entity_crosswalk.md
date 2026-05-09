# Conceptual model entity crosswalk

This file documents how candidate conceptual data model entities relate to MIMIC-IV Demo source structures and to broad correspondences in existing MIMIC-IV on FHIR and MIMIC-IV Demo OMOP resources.

The crosswalk is intended as a documentation-based orientation aid for conceptual modeling and stakeholder review. It is not a formal FHIR mapping, OMOP mapping, ETL specification, transformation rule, or conformance assessment.

The external resources referenced here have different objectives from the conceptual data model developed in this study. MIMIC-IV on FHIR represents MIMIC-IV data using FHIR resources for interoperability-oriented use. MIMIC-IV Demo OMOP represents MIMIC-IV Demo data in the OMOP Common Data Model for standardized observational research and OHDSI tooling. In contrast, the conceptual data model developed here is intended as a stakeholder-reviewable representation of candidate source-data concepts, selected attributes, candidate identifiers or linking fields, and relationships.

FHIR correspondences are based on the MIMIC-IV on FHIR resource and its published approximate table-to-profile mapping. OMOP correspondences are based on the MIMIC-IV Demo OMOP resource, the OHDSI/MIMIC ETL documentation, and the broad target-table structure of the OMOP Common Data Model.

## Crosswalk table

| Conceptual data model entity | MIMIC-IV Demo source structure(s) | Conceptual role in this study | Broad MIMIC-IV on FHIR orientation | Broad MIMIC-IV Demo OMOP orientation | Notes |
|---|---|---|---|---|---|
| Patient | `patients` | Represents the individual whose clinical data appear across hospital-module structures. | `MimicPatient` / FHIR `Patient` | `person` | Patient-level linkage is represented primarily through `subject_id`. |
| Hospital admission | `admissions` | Represents a hospital-level episode of care. | `MimicEncounter` / FHIR `Encounter` | `visit_occurrence` | Hospitalization-level linkage is represented primarily through `hadm_id`. |
| Care location event / transfer | `transfers` | Represents movement through care units or ward-stay/location contexts during hospital care. | `MimicEncounter`, `MimicLocation` / FHIR encounter-location representation | `visit_detail`, `care_site`, `location` | MIMIC-IV on FHIR represents care units as Location resources referenced by Encounter. OMOP orientation is broad because location/care-site representation depends on ETL logic. |
| Diagnosis | `diagnoses_icd`, `d_icd_diagnoses` | Represents coded diagnosis information associated with patients and hospital admissions. | `MimicCondition` / FHIR `Condition` | `condition_occurrence` | Dictionary structure supports interpretation of `icd_code` and `icd_version`. |
| Procedure | `procedures_icd`, `d_icd_procedures` | Represents coded procedure information associated with patients and hospital admissions. | `MimicProcedure` / FHIR `Procedure` | `procedure_occurrence` | Dictionary structure supports interpretation of `icd_code` and `icd_version`. |
| Laboratory observation | `labevents`, `d_labitems` | Represents laboratory measurements and related test observations. | `MimicObservationLabevents`, `MimicSpecimen` / FHIR `Observation`, `Specimen` | `measurement`; possibly `observation` depending on ETL conventions | MIMIC-IV on FHIR notes that original `itemid` values are used rather than LOINC for lab terminology. |
| Laboratory item definition | `d_labitems` | Represents reference information used to interpret laboratory item identifiers. | Terminology/profile support for laboratory observation resources | OMOP vocabulary/concept-related orientation | Treated as a reference/dictionary concept in the conceptual model. |
| Medication order / request | `poe`, `prescriptions` | Represents medication-related ordering or prescribing structures. | `MimicMedicationRequest` / FHIR `MedicationRequest` | `drug_exposure` | FHIR orientation distinguishes medication request/order representation. OMOP orientation is broad because OMOP `drug_exposure` is exposure-oriented rather than request-oriented. |
| Pharmacy / medication dispense | `pharmacy` | Represents pharmacy-related medication dispensing or supply structures. | `MimicMedicationDispense` / FHIR `MedicationDispense` | `drug_exposure` | The MIMIC-IV Demo OMOP documentation states that drug exposure entries were populated from `prescriptions` and `pharmacy`. |
| Medication administration | `emar`, `emar_detail` | Represents electronic medication administration structures. | `MimicMedicationAdministration` / FHIR `MedicationAdministration` | Cautious orientation to `drug_exposure`; not treated as a direct OMOP correspondence | The MIMIC-IV Demo OMOP documentation states that `emar` and `emar_detail` were not used for additional detail extraction. Therefore this crosswalk does not treat EMAR as a formal OMOP mapping. |
| Clinical service context | `services` | Represents service assignment or clinical service context associated with hospital care. | Broad encounter/service context orientation | Broad orientation to visit-related tables, such as `visit_occurrence` or `visit_detail` | Treated as contextual information requiring stakeholder review because service meaning may depend on local workflow. |
| DRG / billing-related code | `drgcodes` | Represents diagnosis-related group or billing-related coded information. | No single direct orientation used here | Possible broad orientation to visit/condition/procedure-related billing context | Included as administrative/coded context rather than as a core clinical diagnosis or procedure entity. |
| HCPCS event | `hcpcsevents` | Represents HCPCS-coded events or billing/procedure-related structures. | Broad procedure-related orientation | Possible broad orientation to `procedure_occurrence` or billing/procedure-related logic | Treated cautiously because conceptual meaning may depend on coding and billing context. |
| Provider | `provider` and provider-related fields where present | Represents clinician or provider identifiers where source structures include provider references. | FHIR `Practitioner` or related provider-oriented representation, where applicable | `provider` | Included as a candidate reference concept when provider identifiers appear in inspected structures. |
| Code definition / dictionary concept | `d_icd_diagnoses`, `d_icd_procedures`, `d_labitems`, and other dictionary/reference tables | Represents reference structures used to interpret coded clinical fields. | Terminology/codeable concept support within relevant FHIR profiles | OMOP vocabulary/concept-related tables | These structures support interpretation of coded fields but are not treated as formal terminology mappings in this crosswalk. |

## Interpretation notes

- The crosswalk compares candidate conceptual data model entities with broad external representations. It should not be used as an implementation specification.
- The FHIR orientation is closer to MIMIC-IV source-table structure because MIMIC-IV on FHIR provides published table-to-profile mappings.
- The OMOP orientation is broader because OMOP CDM transformation reorganizes source data into standardized analytical tables and vocabularies.
- Medication-related structures require particular caution because MIMIC-IV source data distribute medication information across ordering, prescribing, pharmacy, and administration structures, while MIMIC-IV Demo OMOP documentation notes limitations related to EMAR detail extraction.
- The conceptual data model developed in this study is intended to support stakeholder review and clinical data management interpretation, not to replace FHIR or OMOP transformations.

## References

Bennett, A., Wiedekopf, J., Ulrich, H., van Damme, P., Szul, P., Grimes, J., & Johnson, A. (2024). *MIMIC-IV on FHIR* (version 2.1). PhysioNet. RRID:SCR_007345. https://doi.org/10.13026/rrj1-ny66

Kallfelz, M., Tsvetkova, A., Pollard, T., Kwong, M., Lipori, G., Huser, V., Osborn, J., Hao, S., & Williams, A. (2021). *MIMIC-IV demo data in the OMOP Common Data Model* (version 0.9). PhysioNet. https://doi.org/10.13026/p1f5-7x35

OHDSI. (n.d.). *MIMIC to OMOP ETL*. GitHub. https://github.com/OHDSI/MIMIC