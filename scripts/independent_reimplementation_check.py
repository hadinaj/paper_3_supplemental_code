"""Independent re-implementation of the inventories and candidate relationship checks.

Purpose
-------
Recomputes, with pandas and without DuckDB/SQL, the structural counts and every
candidate relationship check reported by the SQL workflow, and compares the results
count by count. This provides a second, independent implementation of the
rule-based classification.

Usage (from the repository root, after running sql/main/05-12):
    python3 scripts/independent_reimplementation_check.py

Inputs
------
    data/raw/mimic-iv-clinical-database-demo-2.2/{hosp,icu}/*.csv.gz
    data/raw/mimic-iv-ed-demo-2.2/ed/*.csv.gz
    output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv
    output/02_relationship_assessments/02_extension_candidate_relationship_checks.csv

Output
------
    output/02_relationship_assessments/05_independent_reimplementation_comparison.csv
Requires: Python 3 with pandas.
"""
import glob
import os
import re
import sys
from collections import Counter

import pandas as pd

DIRS = {
    "hosp": "data/raw/mimic-iv-clinical-database-demo-2.2/hosp",
    "icu": "data/raw/mimic-iv-clinical-database-demo-2.2/icu",
    "ed": "data/raw/mimic-iv-ed-demo-2.2/ed",
}
DOC_CODE_COLUMNS = {"subject_id", "hadm_id", "icd_code", "icd_version", "itemid",
                    "poe_id", "pharmacy_id", "emar_id", "provider_id", "hcpcs_cd"}
COUNTS = ["source_rows", "source_non_null_link_rows", "source_null_link_rows",
          "matched_rows", "unmatched_non_null_rows"]


def load(schema):
    files = sorted(glob.glob(os.path.join(DIRS[schema], "*.csv.gz")))
    return {os.path.basename(f).split(".")[0]: pd.read_csv(f, low_memory=False) for f in files}


def norm(s):
    # Integer identifiers with missing values are read as floats; compare them as integers.
    if pd.api.types.is_float_dtype(s):
        s = s.astype("Int64")
    return s.astype("string")


def check(src, scols, tgt, tcols):
    s = pd.DataFrame({c: norm(src[c]) for c in scols})
    t = pd.DataFrame({c: norm(tgt[c]) for c in tcols}).dropna()
    non_null = s.notna().all(axis=1)
    target = set(map(tuple, t.values.tolist()))
    matched = sum(tuple(x) in target for x in s[non_null].values.tolist())
    n_non_null = int(non_null.sum())
    return [len(s), n_non_null, int((~non_null).sum()), matched, n_non_null - matched]


def classify(c):
    if c[4] > 0:
        return "context-dependent_candidate_relationship"
    return "partially_complete_inferred_relationship" if c[2] > 0 else "fully_complete_inferred_relationship"


def parse_side(side, default_schema):
    side = side.strip()
    parts = side.split(".", 2) if side.count(".") >= 2 and not side.split(".")[1].startswith("(") else None
    if parts and parts[0] in DIRS:
        schema, table, cols = parts
    else:
        schema, (table, cols) = default_schema, side.split(".", 1)
    cols = [c.strip() for c in re.sub(r"[()]", "", cols).split(",")]
    return schema, table, cols


def main():
    data = {k: load(k) for k in DIRS}
    rows, mismatches = [], 0
    hosp = data["hosp"]
    n_cols = sum(d.shape[1] for d in hosp.values())
    ids = sum(1 for d in hosp.values() for c in d.columns
              if c.endswith("id") or c.endswith("_id") or c in DOC_CODE_COLUMNS)
    shared = sum(1 for v in Counter(c for d in hosp.values() for c in set(d.columns)).values() if v > 1)
    print(f"hosp: {len(hosp)} tables, {n_cols} columns, {ids} identifier-like columns, {shared} shared column names")
    for path in ["output/02_relationship_assessments/01_hosp_candidate_relationship_checks.csv",
                 "output/02_relationship_assessments/02_extension_candidate_relationship_checks.csv"]:
        sql = pd.read_csv(path)
        for _, r in sql.iterrows():
            a, b = r.candidate_relationship.split("->")
            ss, st, sc = parse_side(a, "hosp")
            ts, tt, tc = parse_side(b, "hosp")
            counts = check(data[ss][st], sc, data[ts][tt], tc)
            same = counts == [int(r[c]) for c in COUNTS] and classify(counts) == r.relationship_assessment
            mismatches += not same
            rows.append([r.candidate_relationship, *counts, classify(counts), r.relationship_assessment, same])
    out = pd.DataFrame(rows, columns=["candidate_relationship", *COUNTS, "pandas_assessment", "sql_assessment", "identical"])
    out.to_csv("output/02_relationship_assessments/05_independent_reimplementation_comparison.csv", index=False)
    print(f"{len(out)} checks compared; {mismatches} differences between the pandas and SQL implementations")
    sys.exit(1 if mismatches else 0)


if __name__ == "__main__":
    main()
