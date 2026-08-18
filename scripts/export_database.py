"""Regenerate portable SQL exports from the validated FirstCommit SQLite database.

Run from the repository root:
    python scripts/export_database.py

Outputs:
    database/export/firstcommit-full-export.sql
    database/export/firstcommit-data-only.sql
"""

from __future__ import annotations

from pathlib import Path
import sqlite3


ROOT = Path(__file__).resolve().parent.parent
DATABASE_PATH = ROOT / "database" / "firstcommit.db"
EXPORT_DIR = ROOT / "database" / "export"
TABLE_ORDER = [
    "users",
    "scenarios",
    "evidence_items",
    "cause_options",
    "attempts",
    "investigation_steps",
    "cause_assessments",
    "feedback",
]


def sql_literal(value: object) -> str:
    """Return a SQLite-safe literal for a value from a trusted local database."""
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def write_full_export(connection: sqlite3.Connection) -> Path:
    """Write the exact schema + data snapshot produced by SQLite iterdump()."""
    dump_lines = [
        line
        for line in connection.iterdump()
        if line.strip() not in {"BEGIN TRANSACTION;", "COMMIT;"}
    ]

    output = EXPORT_DIR / "firstcommit-full-export.sql"
    lines = [
        "-- FirstCommit Data Layer — exact SQLite export",
        "-- Project 02 — Database Design and Manipulation",
        "-- Generated directly from database/firstcommit.db",
        "-- Contains schema, indexes, stored rows and sqlite_sequence state.",
        "-- Import target: SQLite.",
        "",
        "PRAGMA foreign_keys = OFF;",
        "BEGIN TRANSACTION;",
        *dump_lines,
        "COMMIT;",
        "PRAGMA foreign_keys = ON;",
        "",
        "-- Optional post-import verification:",
        "-- PRAGMA integrity_check;",
        "-- PRAGMA foreign_key_check;",
        "",
    ]
    output.write_text("\n".join(lines), encoding="utf-8", newline="\n")
    return output


def write_data_only_export(connection: sqlite3.Connection) -> Path:
    """Write all stored rows in referentially safe table order."""
    output = EXPORT_DIR / "firstcommit-data-only.sql"
    lines = [
        "-- FirstCommit Data Layer — data-only SQLite export",
        "-- Generated directly from database/firstcommit.db",
        "-- Import into an EMPTY schema created from database/schema.sql.",
        "",
        "PRAGMA foreign_keys = ON;",
        "BEGIN TRANSACTION;",
        "",
    ]

    for table in TABLE_ORDER:
        columns = [
            row[1] for row in connection.execute(f"PRAGMA table_info({table})")
        ]
        rows = connection.execute(f"SELECT * FROM {table} ORDER BY 1").fetchall()
        lines.append(f"-- {table} ({len(rows)} rows)")
        column_list = ", ".join(columns)
        for row in rows:
            values = ", ".join(sql_literal(value) for value in row)
            lines.append(
                f"INSERT INTO {table} ({column_list}) VALUES ({values});"
            )
        lines.append("")

    lines.extend(["COMMIT;", ""])
    output.write_text("\n".join(lines), encoding="utf-8", newline="\n")
    return output


def main() -> None:
    if not DATABASE_PATH.exists():
        raise SystemExit(f"Database not found: {DATABASE_PATH}")

    EXPORT_DIR.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DATABASE_PATH) as connection:
        full_export = write_full_export(connection)
        data_only_export = write_data_only_export(connection)

    print("FirstCommit SQL exports regenerated successfully.")
    print(f"Full export: {full_export.relative_to(ROOT)}")
    print(f"Data-only export: {data_only_export.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
