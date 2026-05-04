# Paper 3 Supplemental Code

This repository contains supplemental SQL code for the Step 0 demonstration of conceptual data modeling using the MIMIC-IV Demo dataset.

The workflow uses DuckDB to query local MIMIC-IV Demo files and generate summary outputs that support the reverse-engineering process used to derive a preliminary conceptual data model.

## Repository contents

```text
sql/
  00_load_core_tables.sql
  01_schema_inspection.sql
  02_relationship_checks.sql
  03_coding_tables.sql
  04_export_summary_outputs.sql

docs/
  workflow.md
```

## Data

The MIMIC-IV Demo dataset is not included in this repository. The dataset should be downloaded separately and placed locally in:

```text
data/raw/mimic-iv-clinical-database-demo-2.2/
```

The raw data files, local DuckDB database files, and generated outputs are excluded from version control.

## Workflow

See [`docs/workflow.md`](docs/workflow.md) for instructions on running the DuckDB workflow.