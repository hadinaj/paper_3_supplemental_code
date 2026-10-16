# Supplemental code and documentation

This repository supports the framework application described in the manuscript:

**Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework**

The repository contains SQL/DuckDB scripts and supporting documentation used to apply the framework to the MIMIC-IV Demo hospital module, with the ICU module and the MIMIC-IV-ED Demo as an extension. The repository supports the reproducible technical parts of the framework: identifying input data structures and documentation, inspecting source data structures, and constructing a conceptual data model artifact.

Stakeholder review, refinement, and organizational use are part of the proposed framework, but were not empirically implemented in this MIMIC-IV Demo application.

## Scope of this repository

This repository supports:

- loading all 22 MIMIC-IV Demo hospital-module tables into DuckDB;
- generating structural summaries of inspected source tables and columns;
- identifying identifier-like columns and shared column names;
- evaluating 48 documentation- and structure-informed candidate relationship checks;
- extension: loading the 9 ICU-module and 6 ED-module tables and evaluating 40 candidate relationship checks within these modules and between them and the hospital module;
- comparing the 48 classified checks with the foreign key constraints declared in the MIMIC Code Repository;
- re-implementing all checks independently in Python (pandas) and comparing the results count by count;
- reporting how two flagged relationships are represented in the published FHIR and OMOP conversions of the MIMIC-IV Demo;
- running an optional exploratory same-name column scan that illustrates which links automated discovery can and cannot identify;
- generating source-structure schema representations in Database Markup Language (DBML);
- documenting how inspected source structures were interpreted during conceptual model construction.

The generated outputs are intended to support methodological transparency and reproducibility. They should not be interpreted as formal database constraints, declared primary-key/foreign-key specifications, exhaustive relationship discovery results, or stakeholder-validated conceptual models.

## Data requirement

The data are not included in this repository. All datasets used are openly available on PhysioNet and must be downloaded separately:

- MIMIC-IV Clinical Database Demo v2.2 (hosp and icu folders): https://doi.org/10.13026/dp1f-ex47
- MIMIC-IV-ED Demo v2.2 (extension): https://doi.org/10.13026/jzz5-vs76
- Optional, for `scripts/published_conversion_checks.py`: MIMIC-IV Clinical Database Demo on FHIR v2.1.0 and MIMIC-IV demo data in the OMOP Common Data Model v0.9 (https://doi.org/10.13026/p1f5-7x35)

Generated data outputs are not tracked in this repository.

## Repository structure

```text
sql/
  main/        Main SQL/DuckDB scripts for the MIMIC-IV Demo hospital-module application
  optional/    Early exploratory SQL scripts on a small set of core tables; not used for the manuscript results

docs/
  00_workflow.md
  01_documentation_informed_relationship_check_assumptions.md
  02_conceptual_entity_mapping.md
  03_source_to_concept_attribute_dictionary.csv
  04_conceptual_model_representation_notes.md
  05_conceptual_model_entity_crosswalk.md

scripts/
  exploratory_shared_column_relationship_discovery.py
  independent_reimplementation_check.py
  published_conversion_checks.py

output/        Local generated outputs; ignored by git
data/          Local data files; ignored by git
```

## Software versions

The workflow was developed and re-executed with:

- DuckDB command-line interface 1.5.2
- Python 3.11.2 with the `duckdb` package 1.5.2
- Python 3 with `pandas`, for the two scripts added in the revision

## How to reproduce

Full step-by-step instructions are in [`docs/00_workflow.md`](docs/00_workflow.md). In short, from the repository root:

```bash
# 1. Place the MIMIC-IV Demo v2.2 hospital-module files under:
#    data/raw/mimic-iv-clinical-database-demo-2.2/hosp/

# 2. Create output folders
mkdir -p output/01_structural_summaries output/02_relationship_assessments output/03_schema_representations

# 3. Run the main workflow
duckdb mimiciv_demo.duckdb < sql/main/05_load_all_hosp_tables.sql
duckdb mimiciv_demo.duckdb < sql/main/06_generate_hosp_master_schema_dbml.sql
duckdb mimiciv_demo.duckdb < sql/main/07_export_hosp_structural_summaries.sql
duckdb mimiciv_demo.duckdb < sql/main/08_export_hosp_candidate_relationship_checks.sql
duckdb mimiciv_demo.duckdb < sql/main/09_generate_hosp_inferred_relationships_dbml.sql

# 4. Extension (ICU and ED modules) and comparison with declared foreign keys
#    Place the ICU files under data/raw/mimic-iv-clinical-database-demo-2.2/icu/
#    and the ED files under data/raw/mimic-iv-ed-demo-2.2/ed/
duckdb mimiciv_demo.duckdb < sql/main/10_load_icu_ed_tables.sql
duckdb mimiciv_demo.duckdb < sql/main/11_export_extension_structural_summaries.sql
duckdb mimiciv_demo.duckdb < sql/main/12_export_extension_relationship_checks.sql
duckdb mimiciv_demo.duckdb < sql/main/13_compare_declared_foreign_keys.sql

# 5. Independent re-implementation of all checks (requires pandas)
python3 scripts/independent_reimplementation_check.py

# 6. Optional: exploratory same-name column scan
python3 scripts/exploratory_shared_column_relationship_discovery.py mimiciv_demo.duckdb

# 7. Optional: relationship-level checks in the published FHIR and OMOP conversions (requires pandas)
python3 scripts/published_conversion_checks.py
```

## Expected results

A correct run reproduces the counts reported in the manuscript:

- 22 hospital-module tables and 229 columns
- 71 identifier-like columns and 24 shared column names
- 48 candidate relationship checks: 33 fully complete inferred relationships, 9 partially complete inferred relationships and 6 context-dependent candidate relationships
- Extension: 9 ICU tables (113 columns) and 6 ED tables (53 columns); 40 extension checks: 37 fully complete and 3 partially complete inferred relationships, 0 context-dependent candidate relationships
- Declared foreign keys (MIMIC Code Repository, commit b24cb8e): of the 48 checks, 28 correspond to a declared foreign key (26 fully complete, 2 partially complete); none of the 6 context-dependent candidate relationships is declared
- Independent re-implementation: 88 checks compared, 0 differences
- Published conversions: 28,420 of 107,727 FHIR laboratory Observations have no encounter reference; in the OMOP demo, no measurement row lacks a visit and the provider table is empty
- Optional exploratory scan (written to `output/02_relationship_assessments/exploratory_shared_column_relationship_discovery.csv`): 500 same-name candidate links, of which 32 have unique target values and no unmatched non-null source values; 31 of these 32 correspond to curated candidate relationship checks

The workflow was re-executed from a clean clone of this repository, reproducing all counts and classifications reported in the manuscript.

## Relationship classification rule

Each candidate relationship check reports source rows, non-null and null linking values, matched rows and unmatched non-null rows. The classification is rule-based:

| Classification | Rule |
|---|---|
| Fully complete inferred relationship | unmatched non-null rows = 0 and null linking rows = 0 |
| Partially complete inferred relationship | unmatched non-null rows = 0 and null linking rows > 0 |
| Context-dependent candidate relationship | unmatched non-null rows > 0 |
