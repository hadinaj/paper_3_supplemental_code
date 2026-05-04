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

## 4. Load core tables

From the repository root, run:

```bash
duckdb mimic_demo.duckdb < sql/00_load_core_tables.sql
```

This creates the `hosp` and `icu` schemas and loads selected MIMIC-IV Demo tables into DuckDB.

## 5. Run schema inspection queries

```bash
duckdb mimic_demo.duckdb < sql/01_schema_inspection.sql
```

This script inspects loaded tables, row counts, columns, candidate identifiers, and selected relationships.

## 6. Run relationship checks

```bash
duckdb mimic_demo.duckdb < sql/02_relationship_checks.sql
```

This script checks selected relationships among patient, admission, diagnosis, laboratory, and ICU stay tables.

## 7. Inspect coding and dictionary tables

```bash
duckdb mimic_demo.duckdb < sql/03_coding_tables.sql
```

This script summarizes diagnosis coding and laboratory item dictionary structures.

## 8. Export summary outputs

```bash
duckdb mimic_demo.duckdb < sql/04_export_summary_outputs.sql
```

This creates local CSV outputs in the `output/` folder, including row counts, relationship checks, diagnosis code summaries, and laboratory item summaries.

## 9. Notes

This workflow uses only local files and open-source software. DuckDB can read the compressed `.csv.gz` files directly, so the raw MIMIC-IV Demo files do not need to be uncompressed.

The workflow is intended to support the Step 0 reverse-engineering process used to derive a preliminary conceptual representation of selected MIMIC-IV Demo data structures.