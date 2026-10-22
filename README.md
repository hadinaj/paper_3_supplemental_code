# Conceptual data modeling of EHR-derived clinical data: reproducible workflow

This repository provides the reproducible workflow for the framework application described in the article **Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework** (citation to be added when the article is published).

The workflow applies the framework to the MIMIC-IV Clinical Database Demo: the hospital module, with the ICU module and the MIMIC-IV-ED Demo as an extension. Release `v1.0` corresponds to the version of the article submitted for publication.

## Framework steps and repository contents

| Framework step | What it produces | In this repository |
|---|---|---|
| 1. Identify input data structures and documentation | Source tables, documentation, and recorded assumptions | `docs/01_documentation_informed_relationship_check_assumptions.md`: each assumption with its documentation quote |
| 2. Inspect source data structures | Structural summaries and relationship checks | `sql/main/05`–`12` and `14`: table and column inventories, identifier-like and shared columns, classified relationship checks, DBML schema representations, and follow-up counts for selected links |
| 3. Construct the conceptual data model | Entities, attributes, and classified relationships | `docs/03_source_to_concept_attribute_dictionary.csv`: each source column mapped to a conceptual entity, attribute, and attribute group |
| 4. Present the conceptual data model | Model views, flagged relationships, and recorded assumptions | Not covered by the code; the model views are in the article |
| 5. Review, refinement, and adaptation by stakeholders involved in data reuse | | Not covered by the code; not carried out in this application |
| Evaluation of the application (not a framework step) | | `sql/main/13` and `scripts/`: comparison with declared foreign keys, independent re-implementation, same-name column scan, and checks in the published FHIR and OMOP conversions |

`sql/optional/` contains early exploratory scripts that are not used for the results.

## Data

The data is not included. Download it from PhysioNet and place it under `data/raw/`:

| Dataset | Folder under `data/raw/` |
|---|---|
| MIMIC-IV Clinical Database Demo v2.2 (`hosp` and `icu`): https://doi.org/10.13026/dp1f-ex47 | `mimic-iv-clinical-database-demo-2.2/` |
| MIMIC-IV-ED Demo v2.2: https://doi.org/10.13026/jzz5-vs76 | `mimic-iv-ed-demo-2.2/` |
| MIMIC-IV Clinical Database Demo on FHIR v2.1.0 (only for `published_conversion_checks.py`) | `mimic-iv-clinical-database-demo-on-fhir-2.1.0/` |
| MIMIC-IV demo data in the OMOP Common Data Model v0.9 (only for `published_conversion_checks.py`): https://doi.org/10.13026/p1f5-7x35 | `mimic-iv-demo-data-in-the-omop-common-data-model-0.9/` |

## How to run

Requirements: DuckDB command-line interface, and Python 3 with the `duckdb` and `pandas` packages. The results were produced with DuckDB 1.5.2, Python 3.11.2, and pandas 3.0.2.

From the repository root:

```bash
mkdir -p output/01_structural_summaries output/02_relationship_assessments output/03_schema_representations

for f in 05 06 07 08 09 10 11 12 13 14; do
  duckdb mimiciv_demo.duckdb < sql/main/${f}_*.sql
done

python3 scripts/independent_reimplementation_check.py
python3 scripts/exploratory_shared_column_relationship_discovery.py mimiciv_demo.duckdb
python3 scripts/published_conversion_checks.py
```

All outputs are written to `output/`.

| Script | Output |
|---|---|
| `05_load_all_hosp_tables.sql` | Loads the 22 hospital-module tables |
| `06_generate_hosp_master_schema_dbml.sql` | `03_schema_representations/01_hosp_tables_only_dbml_representation.dbml` |
| `07_export_hosp_structural_summaries.sql` | `01_structural_summaries/01`–`04`: column inventory, row counts, identifier-like columns, shared columns |
| `08_export_hosp_candidate_relationship_checks.sql` | `02_relationship_assessments/01_hosp_candidate_relationship_checks.csv` |
| `09_generate_hosp_inferred_relationships_dbml.sql` | `03_schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml` |
| `10_load_icu_ed_tables.sql` | Loads the 9 ICU and 6 ED tables |
| `11_export_extension_structural_summaries.sql` | `01_structural_summaries/05`–`07` |
| `12_export_extension_relationship_checks.sql` | `02_relationship_assessments/02_extension_candidate_relationship_checks.csv` |
| `13_compare_declared_foreign_keys.sql` | `02_relationship_assessments/03`–`04` |
| `14_export_review_followup_checks.sql` | `02_relationship_assessments/07_review_followup_checks.csv` |
| `independent_reimplementation_check.py` | `02_relationship_assessments/05_independent_reimplementation_comparison.csv` |
| `exploratory_shared_column_relationship_discovery.py` | `02_relationship_assessments/exploratory_shared_column_relationship_discovery.csv` |
| `published_conversion_checks.py` | `02_relationship_assessments/06_published_conversion_checks.csv` |

## Relationship classification rule

Each relationship check counts source rows, rows with and without a linking value, matched rows, and unmatched non-null rows.

| Category | Rule |
|---|---|
| Fully complete inferred relationship | unmatched non-null rows = 0 and null linking rows = 0 |
| Partially complete inferred relationship | unmatched non-null rows = 0 and null linking rows > 0 |
| Context-dependent candidate relationship | unmatched non-null rows > 0 |

The classified relationships describe how completely candidate links are populated and matched in the data. They are not declared primary or foreign key constraints.

## Expected results

A correct run reproduces the counts reported in the article:

- Hospital module: 22 tables, 229 columns, 71 identifier-like columns, 24 shared column names; 48 relationship checks: 33 fully complete, 9 partially complete, 6 context-dependent.
- Extension: 9 ICU tables and 6 ED tables (166 columns); 40 relationship checks: 37 fully complete, 3 partially complete, 0 context-dependent.
- Declared foreign keys (MIMIC Code Repository, commit b24cb8e): 28 of the 48 checks correspond to a declared foreign key (26 fully complete, 2 partially complete, 0 context-dependent).
- Independent re-implementation: 88 checks compared, 0 differences.
- Same-name column scan: 500 candidate links; 32 with complete matching of non-null values and unique target values, of which 31 correspond to curated checks.
- Follow-up counts: 54 of 54 transfer rows without hadm_id are ED events; 796 of 28,420 laboratory rows without hadm_id fall within an admission of the same patient (9,178 within 24 hours of one); 17 of 60 ED stays with disposition HOME have a hadm_id, 15 of them observation admissions that end when the ED stay ends.
- Published conversions: 28,420 of 107,727 FHIR laboratory Observations have no encounter reference; in the OMOP release, no measurement row lacks a visit, 31,713 measurement rows are assigned to 577 visits created per patient and date, and the provider table is empty.
