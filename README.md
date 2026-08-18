# Project 02 — Database Design and Manipulation

**FirstCommit Data Layer | Relational Modelling, SQL, CRUD, Validation & Read-Only Flask Integration**

This repository is the second FirstCommit software-engineering portfolio project. It carries the validated system design from Project 01 into a working SQLite relational database and demonstrates database creation, seeded data, relational querying, controlled data manipulation, integrity constraints, validation and a small local Flask interface that reads the database in read-only mode.

## Portfolio evidence chain

**Problem → Data model → Physical schema → Seed data → Queries and joins → CRUD → Validation → Read-only application view → Evidence**

## What was built

- a physical SQLite schema with eight FirstCommit domain tables;
- primary-key, foreign-key, UNIQUE and CHECK constraints;
- explicit `RESTRICT` and `CASCADE` relationship behaviour;
- reproducible fictional seed data;
- SELECT, JOIN, LEFT JOIN, GROUP BY and aggregate reporting queries;
- a controlled INSERT → UPDATE → DELETE → ROLLBACK demonstration;
- deliberate invalid-data tests that prove constraint enforcement;
- a validated `firstcommit.db` database;
- a local Flask Data Studio that queries the validated database through a read-only connection;
- selected screenshots and written validation evidence.

## Technology

- SQLite
- SQL
- Python 3
- Flask
- HTML / CSS
- Mermaid ERD

## Repository structure

```text
Module-02-Database-Design-and-Manipulate/
├── README.md
├── requirements.txt
├── .gitignore
├── app/
│   ├── app.py
│   ├── database.py
│   ├── static/
│   │   └── css/
│   │       └── styles.css
│   └── templates/
│       └── index.html
├── database/
│   ├── firstcommit.db
│   ├── schema.sql
│   ├── seed.sql
│   ├── queries.sql
│   └── validation-tests.sql
├── diagrams/
│   ├── physical-database-erd.md
│   └── physical-database-erd.mmd
├── docs/
│   └── Database-Blueprint.md
└── evidence/
    ├── database-validation.md
    └── screenshots/
        ├── README.md
        └── 01–08 selected evidence images
```

## Database design

The relational core consists of:

`users → scenarios → evidence_items / cause_options`

and

`users → attempts → investigation_steps / cause_assessments / feedback`

The physical ERD is documented in `diagrams/physical-database-erd.md`, while the reasoning behind the schema is preserved in `docs/Database-Blueprint.md`.

## Validation result

The validated seed database contains:

| Table | Records |
|---|---:|
| `users` | 5 |
| `scenarios` | 3 |
| `evidence_items` | 9 |
| `attempts` | 3 |
| `investigation_steps` | 8 |
| `cause_options` | 12 |
| `cause_assessments` | 6 |
| `feedback` | 1 |

`PRAGMA integrity_check` returns `ok`, `PRAGMA foreign_key_check` returns no violations, and the deliberate invalid-data tests are rejected as expected. Full details are in `evidence/database-validation.md`.

## Run the local Data Studio

From the repository root:

```powershell
python -m pip install -r requirements.txt
python app/app.py
```

Then open:

```text
http://127.0.0.1:5000
```

The Data Studio uses SQLite URI `mode=ro` plus `PRAGMA query_only = ON`, so its application connection cannot alter the validated evidence database.

## Reproduce the SQL evidence

The implementation files are intentionally separated by purpose:

- `database/schema.sql` — physical tables, constraints and indexes;
- `database/seed.sql` — fictional demonstration data;
- `database/queries.sql` — reporting, joins, aggregates and safe CRUD transaction;
- `database/validation-tests.sql` — integrity and deliberate invalid-data tests.

The validation file is designed to be run test-by-test because several statements are intentionally expected to fail.

## Security and scope boundary

This project demonstrates database-focused protections that are actually implemented: read-only application access, foreign-key integrity, UNIQUE/CHECK constraints, specific DELETE conditions, transaction rollback, local-only Flask execution and exclusion of local environment/cache files from Git.

It does **not** claim production authentication, penetration testing, production deployment or a complete security implementation.

## Evidence

Selected screenshots are indexed in `evidence/screenshots/README.md` and the validation narrative is in `evidence/database-validation.md`.

All names and email addresses in the seed database are fictional demonstration data.
