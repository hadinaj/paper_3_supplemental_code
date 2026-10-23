# Conceptual data modeling of EHR-derived clinical data: code and documentation

Code and documentation for the article **Conceptual Data Modeling of EHR-Derived Clinical Data: A Stakeholder-Oriented Methodological Framework** (citation to be added on publication). Release `v1.3-revision` corresponds to the revised version of the article.

The code inspects the tables of the MIMIC-IV Clinical Database Demo and the MIMIC-IV-ED Demo, checks candidate relationships between them, and compares the results with the published FHIR and OMOP versions of the same data.

## Data you need

The data is not included. Download it from PhysioNet and place each dataset, as unpacked, in a folder under `data/raw/`:

| Dataset | Folder under `data/raw/` |
|---|---|
| MIMIC-IV Clinical Database Demo v2.2: https://doi.org/10.13026/dp1f-ex47 | `mimic-iv-clinical-database-demo-2.2/` |
| MIMIC-IV-ED Demo v2.2: https://doi.org/10.13026/jzz5-vs76 | `mimic-iv-ed-demo-2.2/` |
| MIMIC-IV Clinical Database Demo on FHIR v2.1.0: https://physionet.org/content/mimic-iv-fhir-demo/2.1.0/ | `mimic-iv-clinical-database-demo-on-fhir-2.1.0/` |
| MIMIC-IV demo data in the OMOP Common Data Model v0.9: https://doi.org/10.13026/p1f5-7x35 | `mimic-iv-demo-data-in-the-omop-common-data-model-0.9/` |

The FHIR and OMOP datasets are needed only for `scripts/published_conversion_checks.py`.

## Requirements

- DuckDB command-line interface
- Python 3 with the `duckdb` and `pandas` packages

The results were produced with DuckDB 1.5.2, Python 3.11.2, and pandas 3.0.2.

## How to run

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

The commands create the DuckDB database file `mimiciv_demo.duckdb`; the SQL scripts must run in this order. All results are written to `output/`.

## Repository contents

```
sql/main/      SQL scripts that load the data and produce all results
sql/optional/  early exploratory scripts, not used for the results (see its README)
scripts/       Python scripts: independent re-implementation, same-name column scan,
               and checks in the published FHIR and OMOP datasets
docs/          documentation of the manual steps (not used by the scripts)
```

| Script | What it produces (files in `output/`) |
|---|---|
| `sql/main/05_load_all_hosp_tables.sql` | loads the 22 hospital-module tables |
| `sql/main/06_generate_hosp_master_schema_dbml.sql` | `03_schema_representations/01_hosp_tables_only_dbml_representation.dbml` |
| `sql/main/07_export_hosp_structural_summaries.sql` | `01_structural_summaries/01`–`04`: column inventory, row counts, identifier-like columns, shared columns |
| `sql/main/08_export_hosp_candidate_relationship_checks.sql` | `02_relationship_assessments/01_hosp_candidate_relationship_checks.csv` |
| `sql/main/09_generate_hosp_inferred_relationships_dbml.sql` | `03_schema_representations/02_hosp_relationship_enhanced_dbml_representation.dbml` |
| `sql/main/10_load_icu_ed_tables.sql` | loads the 9 ICU and 6 ED tables |
| `sql/main/11_export_extension_structural_summaries.sql` | `01_structural_summaries/05`–`07`: the same summaries for the ICU and ED tables |
| `sql/main/12_export_extension_relationship_checks.sql` | `02_relationship_assessments/02_extension_candidate_relationship_checks.csv` |
| `sql/main/13_compare_declared_foreign_keys.sql` | `02_relationship_assessments/03`–`04`: checks compared with the foreign keys declared in the MIMIC Code Repository |
| `sql/main/14_export_review_followup_checks.sql` | `02_relationship_assessments/07_review_followup_checks.csv` |
| `scripts/independent_reimplementation_check.py` | `02_relationship_assessments/05_independent_reimplementation_comparison.csv` |
| `scripts/exploratory_shared_column_relationship_discovery.py` | `02_relationship_assessments/exploratory_shared_column_relationship_discovery.csv` |
| `scripts/published_conversion_checks.py` | `02_relationship_assessments/06_published_conversion_checks.csv` |

Each relationship-check file has one row per check: the checked link, five counts (`source_rows`, `source_non_null_link_rows`, `source_null_link_rows`, `matched_rows`, `unmatched_non_null_rows`), and the resulting category (`relationship_assessment`).

## Documentation of the manual steps (`docs/`)

`docs/01_documentation_informed_relationship_check_assumptions.md` lists the 33 assumptions recorded before the checks were run, each with the documentation quote it is based on, a link to that page, and the checks it affects.

`docs/02_source_to_concept_attribute_dictionary.csv` records, for each of the 229 hospital-module columns, how it was represented in the conceptual data model. Its columns:

| Column | Content |
|---|---|
| `source_table`, `source_column` | the source column |
| `conceptual_entity_or_structure` | the entity (or detail structure) the column belongs to |
| `conceptual_attribute` | a readable attribute name |
| `conceptual_attribute_group` | the attribute group in which the column is shown |
| `attribute_modeling_role` | `candidate_identifier`, `linking_column`, `descriptive_attribute`, `reference_attribute`, or `supporting_attribute` |
| `attribute_modeling_treatment` | how the column is shown: `included_as_identifier_or_linking_column`, `grouped_in_conceptual_attribute_group`, `mapped_directly`, `retained_as_reference_or_supporting_field`, or `retained_for_traceability` |
| `notes` | a short explanation |

## License and data use

The MIMIC-IV data is subject to the licenses stated on its PhysioNet pages and is not redistributed here.
