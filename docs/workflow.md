# MIMIC-IV Demo DuckDB Workflow

This document describes the local SQL/DuckDB workflow used for the Step 0 demonstration of conceptual data modeling using the MIMIC-IV Demo dataset.


## 1. Repository structure

```text
paper_3_supplemental_code/
  data/
    raw/
      mimic-iv-clinical-database-demo-2.2/
  sql/
    00_load_core_tables.sql
    01_schema_inspection.sql
    02_relationship_checks.sql
    03_coding_tables.sql
    04_export_summary_outputs.sql
    05_load_all_hosp_tables.sql
    06_generate_hosp_master_schema_dbml.sql
    07_export_hosp_identifier_inventory.sql
    08_export_hosp_candidate_relationship_checks.sql
    09_generate_hosp_inferred_relationships_dbml.sql
  output/
  docs/
  ```

The `data/`, `output/`, and local DuckDB database files are not committed to GitHub.

## 2. Data location

The MIMIC-IV Demo dataset should be placed locally at:

```text
data/raw/mimic-iv-clinical-database-demo-2.2/
```

The original compressed `.csv.gz` files should be kept in their original `hosp/` and `icu/` folders.

## 3. Create or open the DuckDB database

From the repository root, run:

```bash
duckdb mimic_demo.duckdb
```

Then exit DuckDB with:

```sql
.quit
```

## 4. Optional initial core-table loading check

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/00_load_core_tables.sql
```

This script loads a small set of selected tables used to test the local DuckDB setup and demonstrate the basic structural exploration workflow on a manageable subset of MIMIC-IV Demo tables. The main hospital-module workflow begins with `05_load_all_hosp_tables.sql`.

## 5. Optional core-table schema inspection

```bash
duckdb mimic_demo.duckdb < sql/01_schema_inspection.sql
```

This script inspects the selected core tables loaded by `00_load_core_tables.sql`. It reports loaded tables, row counts, column structures, candidate identifier checks, and selected relationship checks. The main hospital-module inventory used for the Step 0 demonstration is generated later by `07_export_hosp_identifier_inventory.sql`.

## 6. Optional core-table relationship checks

```bash
duckdb mimic_demo.duckdb < sql/02_relationship_checks.sql
```

This script performs selected relationship checks among the core tables loaded by `00_load_core_tables.sql`. Each query compares source rows with rows that match a proposed reference table using a join-based match check. The main hospital-module candidate relationship checks used for the Step 0 demonstration are generated later by `08_export_hosp_candidate_relationship_checks.sql`.

## 7. Optional coding and dictionary table inspection

```bash
duckdb mimic_demo.duckdb < sql/03_coding_tables.sql
```

This script provides an optional coding and dictionary table inspection step. Although it is demonstrated using ICD diagnosis codes and laboratory item identifiers in MIMIC-IV Demo, the same type of inspection may be useful for other EHR-derived datasets that contain coded clinical fields and local or standardized dictionary tables.

## 8. Optional core-table summary exports

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/04_export_summary_outputs.sql
```

This script exports selected row counts, relationship checks, diagnosis code summaries, and laboratory item summaries from the optional core-table workflow. The exported files are prefixed with core_ to distinguish them from the main hospital-module outputs. These outputs provide a small reproducible example of preparatory structural exploration. The main hospital-module outputs used for the Step 0 demonstration are generated later by `07_export_hosp_identifier_inventory.sql`, `08_export_hosp_candidate_relationship_checks.sql`, and `09_generate_hosp_inferred_relationships_dbml.sql`.

## 9. Load all hospital-module tables

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/05_load_all_hosp_tables.sql
```

This script loads all MIMIC-IV Demo hospital-module (`hosp`) tables into the local DuckDB database. This is the starting point for the main Step 0 preparatory structural exploration workflow reported in the manuscript. The raw `.csv.gz` files are not modified; DuckDB creates local tables in the `hosp` schema for subsequent table inventory, identifier assessment, candidate relationship checks, and schema visualization.


## 10. Generate hospital-module table and column DBML

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/06_generate_hosp_master_schema_dbml.sql
```

This script generates a DBML representation of the hospital-module table and column structure. The output can be pasted into dbdiagram.io to create a preliminary schema visualization. This version includes tables and columns only; inferred relationships are evaluated and added in later steps.

Output:

```text
output/hosp_master_schema_tables_only.dbml
```


## 11. Export hospital-module table, column, and identifier inventories

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/07_export_hosp_identifier_inventory.sql
```

This script exports the main table and column inventory for the hospital module, a list of columns shared across multiple tables, and a list of identifier-like fields. These outputs support the Step 0 preparatory work outputs described in the manuscript: table and column inventory and candidate identifier summary. Shared column names and identifier-like fields are used to propose candidate relationships, but they are not interpreted as formal database constraints.

Outputs:

```text
output/hosp_column_inventory.csv
output/hosp_shared_columns.csv
output/hosp_identifier_columns.csv
```

## 12. Export hospital-module candidate relationship checks

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/08_export_hosp_candidate_relationship_checks.sql
```

This script evaluates selected candidate relationships among hospital-module tables using join-based match checks. Candidate relationships are proposed from documented identifiers and shared identifier-like fields, but are not interpreted as formally declared database constraints. The output reports source rows, matched rows, and unmatched rows for each candidate relationship. Relationships with zero unmatched rows can be treated as conservative inferred relationships for preliminary schema visualization, while relationships with unmatched rows should be treated as partial or context-dependent links.

Output:

```text
output/hosp_candidate_relationship_checks.csv
```


## 13. Generate hospital-module inferred relationship DBML

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/09_generate_hosp_inferred_relationships_dbml.sql
```

This script generates DBML components for a preliminary hospital-module schema visualization with inferred relationships. The relationship lines include only conservative inferred relationships supported by join-based match checks with zero unmatched source rows. These relationships are modeling assumptions for preliminary schema visualization and should not be interpreted as formally declared database constraints.

Outputs:

```text
output/hosp_inferred_schema_tables_part.dbml
output/hosp_inferred_schema_relationships_part.dbml
```

To create the visualization, paste the contents of `hosp_inferred_schema_tables_part.dbml` into dbdiagram.io first, then paste the contents of `hosp_inferred_schema_relationships_part.dbml` below it.


## 14. Notes

This workflow uses only local files and open-source software. DuckDB can read the compressed `.csv.gz` files directly, so the raw MIMIC-IV Demo files do not need to be uncompressed.

The workflow supports the Step 0 preparatory structural exploration process described in the manuscript. It is intended to generate preparatory work outputs, including table and column inventories, candidate identifier summaries, candidate relationship checks, and preliminary schema visualizations.

Candidate relationships generated by this workflow should be interpreted as inferred modeling relationships rather than formally declared database constraints. Relationships with unmatched rows in the join-based match checks should be treated as partial or context-dependent candidate links.