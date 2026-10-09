# Supplemental code and documentation

This repository supports the framework application described in the manuscript:

**Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework**

The repository contains SQL/DuckDB scripts and supporting documentation used to apply the framework to the MIMIC-IV Demo hospital module. The repository supports the reproducible technical parts of the framework: identifying input data structures and documentation, inspecting source data structures, and constructing a conceptual data model artifact.

Stakeholder review, refinement, and organizational use are part of the proposed framework, but were not empirically implemented in this MIMIC-IV Demo application.

## Scope of this repository

This repository supports:

- loading all 22 MIMIC-IV Demo hospital-module tables into DuckDB;
- generating structural summaries of inspected source tables and columns;
- identifying identifier-like columns and shared column names;
- evaluating 48 documentation- and structure-informed candidate relationship checks;
- running an optional exploratory same-name column scan that illustrates which links automated discovery can and cannot identify;
- generating source-structure schema representations in Database Markup Language (DBML);
- documenting how inspected source structures were interpreted during conceptual model construction.

The generated outputs are intended to support methodological transparency and reproducibility. They should not be interpreted as formal database constraints, declared primary-key/foreign-key specifications, exhaustive relationship discovery results, or stakeholder-validated conceptual models.

## Data requirement

The MIMIC-IV Demo data are not included in this repository. Users must obtain access to MIMIC-IV Demo separately and place the required hospital-module source files locally before running the workflow.

Generated data outputs are not tracked in this repository.

## Repository structure

```text
sql/
  main/        Main SQL/DuckDB scripts for the MIMIC-IV Demo hospital-module application
  optional/    Earlier or optional exploratory SQL scripts

docs/
  00_workflow.md
  01_documentation_informed_relationship_check_assumptions.md
  02_conceptual_entity_mapping.md
  03_source_to_concept_attribute_dictionary.csv
  04_conceptual_model_representation_notes.md
  05_conceptual_model_entity_crosswalk.md

scripts/
  exploratory_shared_column_relationship_discovery.py

output/        Local generated outputs; ignored by git
data/          Local data files; ignored by git

## Software versions

The workflow was developed and re-executed with:

- DuckDB command-line interface 1.5.2
- Python 3.11.2 with the `duckdb` package 1.5.2

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

# 4. Optional: exploratory same-name column scan
python3 scripts/exploratory_shared_column_relationship_discovery.py mimiciv_demo.duckdb
```

## Expected results

A correct run reproduces the counts reported in the manuscript:

- 22 hospital-module tables and 229 columns
- 71 identifier-like columns and 24 shared column names
- 48 candidate relationship checks: 33 fully complete inferred relationships, 9 partially complete inferred relationships and 6 context-dependent candidate relationships
- Optional exploratory scan: 500 same-name candidate links, of which 32 have unique target values and no unmatched non-null source values

The workflow was re-executed from a clean clone of this repository, reproducing all counts and classifications reported in the manuscript.

## Relationship classification rule

Each candidate relationship check reports source rows, non-null and null linking values, matched rows and unmatched non-null rows. The classification is rule-based:

| Classification | Rule |
|---|---|
| Fully complete inferred relationship | unmatched non-null rows = 0 and null linking rows = 0 |
| Partially complete inferred relationship | unmatched non-null rows = 0 and null linking rows > 0 |
| Context-dependent candidate relationship | unmatched non-null rows > 0 |
