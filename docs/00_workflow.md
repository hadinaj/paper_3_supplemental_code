

00 workflow · MD
# Reproducible workflow
 
This document describes how to reproduce the technical workflow for the MIMIC-IV Demo hospital-module application used in the manuscript:
 
**Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework**
 
The workflow supports the reproducible technical parts of the framework: identifying input data structures and documentation, inspecting source data structures, and generating outputs used for conceptual data model artifact construction.
 
Stakeholder review, refinement, and adaptation are part of the proposed framework, but they are not empirically implemented in this repository.
 
## 1. Before running
 
Run commands from the repository root.
 
Example:
 
```bash
cd path/to/paper_3_supplemental_code
pwd
```
 
The `pwd` command should show the repository folder. The `ls` command should show folders such as:
 
```text
docs
sql
scripts
```
 
## 2. Required data
 
The MIMIC-IV Demo data are not included in this repository.
 
Place the MIMIC-IV Demo hospital-module files locally under:
 
```text
data/raw/mimic-iv-clinical-database-demo-2.2/hosp/
```
 
The SQL loading script expects compressed CSV files such as:
 
```text
admissions.csv.gz
patients.csv.gz
transfers.csv.gz
services.csv.gz
diagnoses_icd.csv.gz
procedures_icd.csv.gz
labevents.csv.gz
microbiologyevents.csv.gz
poe.csv.gz
poe_detail.csv.gz
prescriptions.csv.gz
pharmacy.csv.gz
emar.csv.gz
emar_detail.csv.gz
provider.csv.gz
drgcodes.csv.gz
hcpcsevents.csv.gz
d_hcpcs.csv.gz
d_icd_diagnoses.csv.gz
d_icd_procedures.csv.gz
d_labitems.csv.gz
omr.csv.gz
```
 
Raw data files are ignored by git and should not be committed.
 
## 3. Software requirement
 
The workflow uses the DuckDB command-line interface.
 
Check that DuckDB is available:
 
```bash
duckdb --version
```
 
## 4. Generated output folders
 
Generated outputs are written under `output/`. The `output/` folder is ignored by git.
 
Create the output folders before running the workflow:
 
```bash
mkdir -p output/01_structural_summaries
mkdir -p output/02_relationship_assessments
mkdir -p output/03_schema_representations
```
 
If you want to regenerate outputs from scratch, first remove existing generated outputs:
 
```bash
rm -rf output/*
 
mkdir -p output/01_structural_summaries
mkdir -p output/02_relationship_assessments
mkdir -p output/03_schema_representations
```
 
## 5. Main workflow scripts
 
Run the scripts from the repository root.
 
For a full run, including loading the hospital-module tables into DuckDB:
 
```bash
duckdb mimiciv_demo.duckdb < sql/main/05_load_all_hosp_tables.sql
duckdb mimiciv_demo.duckdb < sql/main/06_generate_hosp_master_schema_dbml.sql
duckdb mimiciv_demo.duckdb < sql/main/07_export_hosp_structural_summaries.sql
duckdb mimiciv_demo.duckdb < sql/main/08_export_hosp_candidate_relationship_checks.sql
duckdb mimiciv_demo.duckdb < sql/main/09_generate_hosp_inferred_relationships_dbml.sql
```
 
If the DuckDB database already exists and the hospital-module tables have already been loaded, scripts `06` through `09` can be rerun to regenerate outputs:
 
```bash
duckdb mimiciv_demo.duckdb < sql/main/06_generate_hosp_master_schema_dbml.sql
duckdb mimiciv_demo.duckdb < sql/main/07_export_hosp_structural_summaries.sql
duckdb mimiciv_demo.duckdb < sql/main/08_export_hosp_candidate_relationship_checks.sql
duckdb mimiciv_demo.duckdb < sql/main/09_generate_hosp_inferred_relationships_dbml.sql
```
 
## 6. What each main script does
 
```text
sql/main/05_load_all_hosp_tables.sql
```
 
Loads all 22 MIMIC-IV Demo hospital-module source tables into a local DuckDB database under the `hosp` schema.
 
```text
sql/main/06_generate_hosp_master_schema_dbml.sql
```
 
Generates a tables-only Database Markup Language (DBML) representation of the inspected hospital-module tables and columns.
 
```text
sql/main/07_export_hosp_structural_summaries.sql
```
 
Generates structural summaries, including the table and column inventory, row-count summary, identifier-like column summary, and shared-column summary.
 
```text
sql/main/08_export_hosp_candidate_relationship_checks.sql
```
 
Evaluates selected candidate relationship checks using join-based comparisons.
 
```text
sql/main/09_generate_hosp_inferred_relationships_dbml.sql
```
 
Generates a relationship-enhanced DBML representation using fully complete inferred relationships from the selected relationship checks.
 
## 7. Expected generated outputs
 
After running the workflow, the generated outputs should be:
 
```text
output/01_structural_summaries/01_hosp_table_column_inventory.csv
output/01_structural_summaries/02_hosp_table_row_counts.csv
output/01_structural_summaries/03_hosp_identifier_like_columns.csv
output/01_structural_summaries/04_hosp_shared_columns.csv
output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv
output/03_schema_representations/01_hosp_tables_only_dbml_representation.dbml
output/03_schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml
```
 
Check generated files:
 
```bash
find output -maxdepth 2 -type f | sort
```
 
 
## 8. Output groups and manuscript alignment
 
The generated output folders correspond to the manuscript output groups as follows:
 
| Output folder | Manuscript-aligned output group |
|---|---|
| `output/01_structural_summaries/` | Structural inventories and summaries |
| `output/02_relationship_assessments/` | Relationship-assessment outputs |
| `output/03_schema_representations/` | Source-oriented DBML schema representations |
 
The DBML outputs correspond to:
 
| Filename | Manuscript-aligned wording |
|---|---|
| `01_hosp_tables_only_dbml_representation.dbml` | Tables-only DBML representation |
| `02_hosp_relationship_enhanced_dbml_representation.dbml` | Relationship-enhanced DBML representation |
| Both DBML files together | Source-oriented DBML schema representations |
 
The relationship-assessment output uses technical category labels. In the manuscript, these are reported using more readable relationship-category names:
 
| Repository label | Manuscript-aligned label |
|---|---|
| `complete_conservative_inferred_relationship` | Fully complete inferred relationship |
| `complete_when_link_present_with_null_source_links` | Partially complete inferred relationship |
| `partial_or_context_dependent_candidate_link` | Context-dependent candidate relationship |
 
 
## 9. Sanity checks
 
Check that both DBML representations include all 22 hospital-module tables:
 
```bash
grep -c "^Table " output/03_schema_representations/01_hosp_tables_only_dbml_representation.dbml
grep -c "^Table " output/03_schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml
```
 
Expected output:
 
```text
22
22
```
 
Check that the relationship-enhanced DBML representation contains 33 relationships classified as fully_complete_inferred_relationship:
 
```bash
grep -c "^Ref:" output/03_schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml
```
 
Expected output:
 
```text
33
```
 
Check that the selected candidate relationship-check output contains 48 rows, excluding the header:
 
```bash
tail -n +2 output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv | wc -l
```
 
Expected output:
 
```text
48
```
 
Check that structural summary files are not swapped:
 
```bash
head output/01_structural_summaries/02_hosp_table_row_counts.csv
head output/01_structural_summaries/04_hosp_shared_columns.csv
```
 
The row-count file should show table names and row counts. The shared-column file should show column names that appear in more than one table.
 
## 10. Interpretation of relationship outputs
 
The candidate relationship checks are selected, documentation- and structure-informed assessments. They are not exhaustive relationship discovery results.
 
The relationship-check output separates:
 
- source rows with non-null values in the evaluated linking column;
- source rows with null values in the evaluated linking column;
- matched source rows;
- unmatched non-null source rows.
This distinction is used to separate absent linkage information from non-null values that fail to match the proposed target or reference structure.
 
The relationship-enhanced DBML representation includes only relationships classified as fully_complete_inferred_relationship / fully complete inferred relationships. Relationships affected by null values in evaluated linking columns or unmatched non-null source values are retained in the relationship-assessment output for contextual interpretation and later review rather than added as straightforward DBML relationship lines.
 
The DBML files should not be interpreted as formal database implementation schemas, formally declared primary-key/foreign-key constraints, or stakeholder-validated conceptual models.
 
## 11. Optional exploratory script
 
The repository also includes:
 
```text
scripts/exploratory_shared_column_relationship_discovery.py
```
 
This optional script performs a broader same-name column overlap scan. It is not part of the main manuscript workflow. It can be used to illustrate why documentation-informed selection and conceptual interpretation are needed before treating shared column names as meaningful relationships.
 
## 12. Troubleshooting
 
If a script cannot find the raw MIMIC-IV Demo files, check that the files are placed under:
 
```text
data/raw/mimic-iv-clinical-database-demo-2.2/hosp/
```
 
If a script cannot write output files, recreate the output folders:
 
```bash
mkdir -p output/01_structural_summaries
mkdir -p output/02_relationship_assessments
mkdir -p output/03_schema_representations
```
 
If the terminal says `duckdb: command not found`, DuckDB is not available from the command line.
 
If the terminal says a SQL script cannot be found, check that you are running commands from the repository root:
 
```bash
pwd
ls sql/main
```
 
## 13. Git notes
 
The following are local/generated and should not be committed:
 
```text
data/
output/
*.duckdb
*.duckdb.wal
```
 
The generated outputs are reproducible by running the workflow.
 
Claude finished the response
