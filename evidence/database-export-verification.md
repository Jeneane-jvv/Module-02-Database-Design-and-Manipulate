# Database Export Verification

## Purpose

The SQL export evidence exists to show that the public repository does not rely only on screenshots or manually typed result tables. The exported SQL files are generated from the actual validated SQLite database and can reconstruct the stored Project 02 data.

## Verified artefacts

- source database: `database/firstcommit.db`
- complete SQLite export: `database/export/firstcommit-full-export.sql`
- data-only SQLite export: `database/export/firstcommit-data-only.sql`
- regeneration script: `scripts/export_database.py`
- round-trip verifier: `scripts/verify_database_export.py`

## Round-trip result

**Full export:** PASS  
**Data-only export:** PASS  
**SQLite integrity check:** `ok`  
**Foreign-key violations:** `0`

Both export methods were imported into fresh temporary SQLite databases. Every domain table was compared with the source database after import.

## Verified record counts

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

## SHA-256 snapshot identifiers

These hashes identify the exact validated files in this publication package. A later legitimate database change will produce different hashes and should be re-verified.

```text
database/firstcommit.db
beb250b4560bea2240f4e77e66ac433b376af3ab2d40c802a301338a856e594b

database/export/firstcommit-full-export.sql
d39ac930f8313ac8c00d9c714071f6bfff4e20332ce8f13b27d9962735f94bf3

database/export/firstcommit-data-only.sql
6d9323fdf3a6c67efd1d7222f0712af111288c5507b01b30502afe10d97f44e5
```

A hash proves file identity/integrity for this snapshot; it is **not by itself proof of authorship**. Authorship and assistance boundaries are documented separately in `AUTHORSHIP-AND-PROVENANCE.md`.
