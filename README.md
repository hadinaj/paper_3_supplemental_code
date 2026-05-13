# Supplemental code and documentation

This repository supports the framework application described in the manuscript:

**Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework**

The repository contains SQL/DuckDB scripts and supporting documentation used to apply the framework to the MIMIC-IV Demo hospital module. The repository supports the reproducible technical parts of the framework: identifying input data structures and documentation, inspecting source data structures, and constructing a conceptual data model artifact.

Stakeholder review, refinement, and organizational use are part of the proposed framework, but were not empirically implemented in this MIMIC-IV Demo application.

## Scope of this repository

This repository supports:

- loading selected MIMIC-IV Demo hospital-module tables into DuckDB;
- generating structural summaries of inspected source tables and columns;
- identifying identifier-like columns and shared column names;
- evaluating selected candidate relationship checks;
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