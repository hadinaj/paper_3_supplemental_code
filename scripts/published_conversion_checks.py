"""Relationship-level checks in published conversions of the MIMIC-IV Demo.

Purpose
-------
Shows how two relationships flagged in the conceptual data model are represented in the
published FHIR and OMOP conversions of the MIMIC-IV Demo (manuscript Sections 3.4 and 4):
  - laboratory results without a hospital admission (labevents.hadm_id is null in
    28,420 of 107,727 rows; partially complete in check 08);
  - provider links (provider_id columns; partially complete in check 08).

Usage (from the repository root):
    python3 scripts/published_conversion_checks.py

Inputs (download from PhysioNet and place under data/raw/):
    MIMIC-IV Clinical Database Demo on FHIR v2.1.0
        data/raw/mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir/*.ndjson.gz
    MIMIC-IV demo data in the OMOP Common Data Model v0.9 (Kallfelz et al., 2021)
        data/raw/mimic-iv-demo-data-in-the-omop-common-data-model-0.9/1_omop_data_csv/*.csv

Output
------
    output/02_relationship_assessments/06_published_conversion_checks.csv
Requires: Python 3 with pandas.
"""
import gzip
import json
import os

import pandas as pd

FHIR = "data/raw/mimic-iv-clinical-database-demo-on-fhir-2.1.0/fhir"
OMOP = "data/raw/mimic-iv-demo-data-in-the-omop-common-data-model-0.9/1_omop_data_csv"
rows = []


def ndjson(name):
    with gzip.open(os.path.join(FHIR, name + ".ndjson.gz"), "rt") as f:
        for line in f:
            yield json.loads(line)


lab = list(ndjson("MimicObservationLabevents"))
with_enc = sum("encounter" in r for r in lab)
rows += [
    ("FHIR", "MimicObservationLabevents", "resources", len(lab)),
    ("FHIR", "MimicObservationLabevents", "with an encounter reference", with_enc),
    ("FHIR", "MimicObservationLabevents", "without an encounter reference", len(lab) - with_enc),
]
adm = list(ndjson("MimicMedicationAdministration"))
rows += [
    ("FHIR", "MimicMedicationAdministration", "resources", len(adm)),
    ("FHIR", "MimicMedicationAdministration", "with a request reference", sum("request" in r for r in adm)),
]

meas = pd.read_csv(os.path.join(OMOP, "measurement.csv"), usecols=["visit_occurrence_id", "provider_id"], low_memory=False)
drug = pd.read_csv(os.path.join(OMOP, "drug_exposure.csv"), usecols=["visit_occurrence_id", "provider_id"], low_memory=False)
prov = pd.read_csv(os.path.join(OMOP, "provider.csv"))
rows += [
    ("OMOP", "measurement", "rows", len(meas)),
    ("OMOP", "measurement", "rows without visit_occurrence_id", int(meas.visit_occurrence_id.isna().sum())),
    ("OMOP", "measurement", "rows with provider_id", int(meas.provider_id.notna().sum())),
    ("OMOP", "drug_exposure", "rows", len(drug)),
    ("OMOP", "drug_exposure", "rows with provider_id", int(drug.provider_id.notna().sum())),
    ("OMOP", "provider", "rows", len(prov)),
]
out = pd.DataFrame(rows, columns=["standard", "table_or_resource", "measure", "value"])
out.to_csv("output/02_relationship_assessments/06_published_conversion_checks.csv", index=False)
print(out.to_string(index=False))
