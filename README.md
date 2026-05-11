# Supplemental code and documentation

This repository supports the framework application described in the manuscript:

**Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework**

The repository contains SQL/DuckDB scripts, schema representations, documentation files, and figure files used to apply the framework to the MIMIC-IV Demo hospital module.

## Framework steps represented in this repository

The repository is organized around the reproducible technical parts of the framework.

### Step 1. Identify input data structures and documentation

The input data structures are the MIMIC-IV Demo hospital-module source tables. Supporting documentation is used to guide assumptions about identifiers, levels of granularity, and candidate relationships.

### Step 2. Inspect source data structures

The SQL/DuckDB scripts inspect the selected source structures and generate structural inventories and empirically informed relationship assessments.

Examples of generated outputs include:

- table and column inventory
- table row-count summary
- candidate identifier summary
- shared-column summary
- join-based candidate relationship checks

Generated CSV outputs are not tracked in this repository.

### Step 3. Construct the conceptual data model artifact

The structural inventories and relationship assessments are used to support construction of the conceptual data model artifact. The repository includes schema representations, documentation files, and figure files that support traceability from source structures to candidate conceptual model elements.

### Stakeholder review, refinement, and adaptation

Stakeholder review, refinement, and adaptation are part of the proposed framework, but were not empirically implemented in this repository.

### Conceptual model mapping artifacts

The conceptual model is supported by two mapping artifacts:

1. `docs/conceptual_entity_mapping.md` records table-level mappings from MIMIC-IV Demo hospital-module source structures to candidate conceptual entities, supporting reference structures, and modeling notes.
2. `docs/source_to_concept_attribute_dictionary.csv` records column-level source-to-concept mappings used to preserve traceability and support coverage checks.

The entity mapping is intended to be human-readable. The attribute dictionary is intended to support verification that inspected source tables and columns are either represented directly, grouped into conceptual attributes, used as identifiers/linking fields, or recorded as supporting/reference fields.

## Repository structure

```text
sql/
  main/        Main SQL/DuckDB scripts used for the MIMIC-IV Demo hospital-module application
  optional/    Earlier or optional exploratory scripts

schema/        DBML schema representations

docs/
  workflow.md
  conceptual_entity_mapping.md
  source_to_concept_attribute_dictionary.csv
  conceptual_model_representation_notes.md
  conceptual_model_entity_crosswalk.md

  
figures/       Draw.io files and figure artifacts

output/        Local generated outputs; not tracked

results/       Local generated results; not tracked