# FirstCommit SQL Export and Import Guide

This folder contains SQL exports generated directly from the validated `database/firstcommit.db` SQLite database.

## Files

- `firstcommit-full-export.sql` — exact SQLite snapshot containing tables, constraints, indexes, stored rows and `sqlite_sequence` state.
- `firstcommit-data-only.sql` — stored rows only, in foreign-key-safe order. Use this after creating an empty database from `database/schema.sql`.

These exports are **SQLite SQL**. They are directly importable into SQLite. MySQL, SQL Server and PostgreSQL use different dialects and would require a deliberate migration/conversion rather than being claimed as direct imports.

## Rebuild option A — exact snapshot

If the SQLite command-line tool is installed:

```bash
sqlite3 firstcommit-imported.db < database/export/firstcommit-full-export.sql
```

Then verify:

```bash
sqlite3 firstcommit-imported.db "PRAGMA integrity_check;"
sqlite3 firstcommit-imported.db "PRAGMA foreign_key_check;"
```

Expected integrity result:

```text
ok
```

Expected foreign-key result: no rows.

## Rebuild option B — schema plus exact exported rows

Create the schema first:

```bash
sqlite3 firstcommit-imported.db < database/schema.sql
```

Then import the stored data snapshot:

```bash
sqlite3 firstcommit-imported.db < database/export/firstcommit-data-only.sql
```

## Rebuild option C — source scripts

The original reproducible build path remains:

```bash
sqlite3 firstcommit-rebuilt.db < database/schema.sql
sqlite3 firstcommit-rebuilt.db < database/seed.sql
```

This route demonstrates how the database was intentionally designed and seeded. Because several audit timestamps use SQLite `CURRENT_TIMESTAMP` defaults, a fresh schema+seed rebuild can contain new timestamp values even though its logical records, relationships and counts are the same. The export files above demonstrate the **actual stored snapshot**, including the historical timestamp values, after validation.

## Regenerate the exports

No third-party Python packages are required:

```bash
python scripts/export_database.py
```

## Verify an export round trip

Run:

```bash
python scripts/verify_database_export.py
```

The verifier creates temporary databases from both export methods and compares every domain table with the source `firstcommit.db`. It also checks SQLite integrity and foreign-key consistency.

The most recent machine-readable verification result is stored in:

`evidence/database-export-verification.json`

## Current validated record counts

| Table | Rows |
|---|---:|
| `users` | 5 |
| `scenarios` | 3 |
| `evidence_items` | 9 |
| `cause_options` | 12 |
| `attempts` | 3 |
| `investigation_steps` | 8 |
| `cause_assessments` | 6 |
| `feedback` | 1 |

All records are fictional portfolio demonstration data.
