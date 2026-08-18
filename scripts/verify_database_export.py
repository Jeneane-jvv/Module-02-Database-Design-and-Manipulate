"""Round-trip verification for the FirstCommit database SQL exports.

The script imports the full SQL dump into a temporary SQLite database, checks
integrity/foreign keys, and compares every domain table with the source DB.
It also verifies the data-only export against a fresh schema.

Run from the repository root:
    python scripts/verify_database_export.py
"""

from __future__ import annotations

from pathlib import Path
import hashlib
import json
import sqlite3
import tempfile


ROOT = Path(__file__).resolve().parent.parent
DATABASE_PATH = ROOT / "database" / "firstcommit.db"
SCHEMA_PATH = ROOT / "database" / "schema.sql"
FULL_EXPORT_PATH = ROOT / "database" / "export" / "firstcommit-full-export.sql"
DATA_EXPORT_PATH = ROOT / "database" / "export" / "firstcommit-data-only.sql"
EVIDENCE_JSON_PATH = ROOT / "evidence" / "database-export-verification.json"
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


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def snapshot(connection: sqlite3.Connection) -> dict[str, list[tuple]]:
    return {
        table: connection.execute(f"SELECT * FROM {table} ORDER BY 1").fetchall()
        for table in TABLE_ORDER
    }


def validate(connection: sqlite3.Connection) -> tuple[str, list[tuple], dict[str, int]]:
    integrity = connection.execute("PRAGMA integrity_check").fetchone()[0]
    foreign_keys = connection.execute("PRAGMA foreign_key_check").fetchall()
    counts = {
        table: connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        for table in TABLE_ORDER
    }
    return integrity, foreign_keys, counts


def main() -> None:
    required = [DATABASE_PATH, SCHEMA_PATH, FULL_EXPORT_PATH, DATA_EXPORT_PATH]
    missing = [path for path in required if not path.exists()]
    if missing:
        raise SystemExit("Missing required file(s): " + ", ".join(map(str, missing)))

    with sqlite3.connect(DATABASE_PATH) as source:
        source_snapshot = snapshot(source)
        source_integrity, source_fk, source_counts = validate(source)

    if source_integrity != "ok" or source_fk:
        raise SystemExit("Source database failed integrity or foreign-key validation.")

    with tempfile.TemporaryDirectory() as temporary_directory:
        temporary_directory = Path(temporary_directory)

        full_db = temporary_directory / "full-import.db"
        with sqlite3.connect(full_db) as imported:
            imported.executescript(FULL_EXPORT_PATH.read_text(encoding="utf-8"))
            integrity, foreign_keys, counts = validate(imported)
            if integrity != "ok" or foreign_keys or counts != source_counts:
                raise SystemExit("Full export round-trip validation failed.")
            if snapshot(imported) != source_snapshot:
                raise SystemExit("Full export data differs from source database.")

        data_db = temporary_directory / "data-only-import.db"
        with sqlite3.connect(data_db) as imported:
            imported.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
            imported.executescript(DATA_EXPORT_PATH.read_text(encoding="utf-8"))
            integrity, foreign_keys, counts = validate(imported)
            if integrity != "ok" or foreign_keys or counts != source_counts:
                raise SystemExit("Data-only export round-trip validation failed.")
            if snapshot(imported) != source_snapshot:
                raise SystemExit("Data-only export data differs from source database.")

    evidence = {
        "database_sha256": sha256(DATABASE_PATH),
        "full_export_sha256": sha256(FULL_EXPORT_PATH),
        "data_only_export_sha256": sha256(DATA_EXPORT_PATH),
        "integrity_check": source_integrity,
        "foreign_key_violations": len(source_fk),
        "counts": source_counts,
        "round_trip_full_export": "PASS",
        "round_trip_data_only_export": "PASS",
    }
    EVIDENCE_JSON_PATH.write_text(
        json.dumps(evidence, indent=2) + "\n", encoding="utf-8"
    )

    print("Database export verification: PASS")
    print(json.dumps(evidence, indent=2))


if __name__ == "__main__":
    main()
