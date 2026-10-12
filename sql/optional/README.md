# Optional exploratory scripts

These are early exploratory scripts written while setting up the workflow. They work on a small set of core tables and are **not used for the results reported in the manuscript**. The manuscript results are produced by the scripts in `sql/main/`.

| Script | What it does |
|---|---|
| `00_load_core_tables.sql` | Loads six hospital-module tables and `icu.icustays` (requires the `icu/icustays.csv.gz` file, which is outside the hospital-module scope of the manuscript) |
| `01_schema_inspection.sql` | Lists loaded tables, row counts and columns for the core tables |
| `02_relationship_checks.sql` | Runs a few join-based checks among the core tables |
| `03_coding_tables.sql` | Summarizes ICD diagnosis codes and laboratory items |
| `04_export_summary_outputs.sql` | Exports the core-table summaries to `output/` |

They are kept to document how the workflow was developed.
