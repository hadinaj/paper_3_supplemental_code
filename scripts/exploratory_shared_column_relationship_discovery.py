from pathlib import Path
import csv
import sys
import duckdb


def quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def find_database(repo_root: Path) -> Path:
    if len(sys.argv) > 1:
        return Path(sys.argv[1]).expanduser().resolve()

    preferred = [
        repo_root / "mimic_demo.duckdb",
        repo_root / "mimiciv_demo.duckdb",
    ]

    for path in preferred:
        if path.exists():
            return path

    db_files = list(repo_root.glob("*.duckdb"))
    if len(db_files) == 1:
        return db_files[0]

    raise FileNotFoundError(
        "Could not automatically find a DuckDB database. "
        "Run again with the database path, for example:\n"
        "python3 scripts/exploratory_shared_column_relationship_discovery.py mimic_demo.duckdb"
    )


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    db_path = find_database(repo_root)

    output_dir = repo_root / "output" / "relationship_assessments"
    output_dir.mkdir(parents=True, exist_ok=True)

    output_path = output_dir / "exploratory_shared_column_relationship_discovery.csv"

    print(f"Using database: {db_path}")
    print(f"Writing output to: {output_path}")

    con = duckdb.connect(str(db_path))

    # Check that schema hosp exists
    schema_exists = con.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.schemata
        WHERE schema_name = 'hosp'
        """
    ).fetchone()[0]

    if schema_exists == 0:
        raise RuntimeError(
            "Schema 'hosp' was not found. Run the table-loading script first."
        )

    candidate_pairs = con.execute(
        """
        WITH candidate_columns AS (
            SELECT
                table_name,
                column_name
            FROM information_schema.columns
            WHERE table_schema = 'hosp'
              AND (
                    right(lower(column_name), 3) = '_id'
                 OR right(lower(column_name), 2) = 'id'
                 OR lower(column_name) IN (
                        'subject_id',
                        'hadm_id',
                        'icd_code',
                        'icd_version',
                        'itemid',
                        'poe_id',
                        'pharmacy_id',
                        'emar_id',
                        'provider_id',
                        'hcpcs_cd',
                        'drg_code',
                        'code'
                    )
              )
        ),
        shared_columns AS (
            SELECT column_name
            FROM candidate_columns
            GROUP BY column_name
            HAVING COUNT(DISTINCT table_name) > 1
        )
        SELECT
            a.table_name AS source_table,
            b.table_name AS target_table,
            a.column_name AS shared_column
        FROM candidate_columns a
        JOIN candidate_columns b
          ON a.column_name = b.column_name
        JOIN shared_columns sc
          ON a.column_name = sc.column_name
        WHERE a.table_name <> b.table_name
        ORDER BY a.column_name, a.table_name, b.table_name
        """
    ).fetchall()

    print(f"Candidate shared-column checks to run: {len(candidate_pairs)}")

    rows = []

    for source_table, target_table, shared_column in candidate_pairs:
        s_table = quote_ident(source_table)
        t_table = quote_ident(target_table)
        col = quote_ident(shared_column)

        sql = f"""
        WITH result AS (
            SELECT
                '{source_table}.{shared_column} -> {target_table}.{shared_column}' AS candidate_relationship,
                '{shared_column}' AS link_column,
                '{source_table}' AS source_table,
                '{target_table}' AS target_table,

                COUNT(*) AS source_rows,
                COUNT(s.{col}) AS source_non_null_link_rows,
                COUNT(*) - COUNT(s.{col}) AS source_null_link_rows,

                COUNT(DISTINCT CASE
                    WHEN s.{col} IS NOT NULL THEN CAST(s.{col} AS VARCHAR)
                END) AS source_distinct_non_null_values,

                (SELECT COUNT(*) FROM hosp.{t_table}) AS target_rows,

                (SELECT COUNT(*)
                 FROM hosp.{t_table}
                 WHERE {col} IS NOT NULL) AS target_non_null_rows,

                (SELECT COUNT(DISTINCT CAST({col} AS VARCHAR))
                 FROM hosp.{t_table}
                 WHERE {col} IS NOT NULL) AS target_distinct_non_null_values,

                SUM(CASE
                    WHEN s.{col} IS NOT NULL AND t.link_value IS NOT NULL THEN 1
                    ELSE 0
                END) AS matched_source_rows,

                SUM(CASE
                    WHEN s.{col} IS NOT NULL AND t.link_value IS NULL THEN 1
                    ELSE 0
                END) AS unmatched_non_null_source_rows

            FROM hosp.{s_table} s
            LEFT JOIN (
                SELECT DISTINCT CAST({col} AS VARCHAR) AS link_value
                FROM hosp.{t_table}
                WHERE {col} IS NOT NULL
            ) t
              ON CAST(s.{col} AS VARCHAR) = t.link_value
        )
        SELECT
            *,
            CASE
                WHEN target_non_null_rows = target_distinct_non_null_values THEN TRUE
                ELSE FALSE
            END AS target_values_unique,

            ROUND(
                100.0 * matched_source_rows / NULLIF(source_non_null_link_rows, 0),
                2
            ) AS non_null_match_pct,

            CASE
                WHEN source_non_null_link_rows = 0
                    THEN 'no_non_null_source_values'
                WHEN unmatched_non_null_source_rows = 0
                     AND source_null_link_rows = 0
                     AND target_non_null_rows = target_distinct_non_null_values
                    THEN 'complete_candidate_reference_link'
                WHEN unmatched_non_null_source_rows = 0
                     AND source_null_link_rows > 0
                     AND target_non_null_rows = target_distinct_non_null_values
                    THEN 'complete_when_link_present_target_unique'
                WHEN unmatched_non_null_source_rows = 0
                    THEN 'all_non_null_values_match_but_target_not_unique'
                ELSE 'partial_or_context_dependent_value_overlap'
            END AS exploratory_assessment
        FROM result
        """

        result = con.execute(sql).fetchone()
        columns = [desc[0] for desc in con.description]
        rows.append(dict(zip(columns, result)))

    rows.sort(
        key=lambda r: (
            -(r["non_null_match_pct"] or -1),
            r["link_column"],
            r["source_table"],
            r["target_table"],
        )
    )

    with output_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    print("Done.")
    print(f"Created: {output_path}")
    print()
    print("Top 10 exploratory links:")
    for row in rows[:10]:
        print(
            f"- {row['candidate_relationship']} | "
            f"{row['non_null_match_pct']}% | "
            f"{row['exploratory_assessment']}"
        )


if __name__ == "__main__":
    main()