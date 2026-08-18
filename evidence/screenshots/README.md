# Project 02 — Database Evidence Screenshots

This folder contains selected visual evidence from the FirstCommit Project 02 database implementation and validation process.

The screenshots are intentionally limited to evidence that demonstrates the progression from physical database creation through querying, manipulation and validation.

## Evidence sequence

### 01 — Database structure and seed data

`01-database-structure-and-seed-data.png`

Shows the working `firstcommit.db` SQLite database, its relational tables and the seeded FirstCommit scenarios.

**Demonstrates:** physical database implementation, populated relational data and table structure.

---

### 02 — Active-scenarios query result

`02-query-active-scenarios-result.png`

Shows an executed SQL query retrieving active scenarios together with the reviewer who created each scenario.

**Demonstrates:** `SELECT`, `JOIN`, `WHERE`, foreign-key relationship resolution and custom ordering.

---

### 03 — Multi-table investigation trail

`03-multi-table-investigation-trail.png`

Shows the complete investigation trail reconstructed across learners, attempts, scenarios, investigation steps and evidence items.

**Demonstrates:** multi-table relational querying and ordered reasoning history.

---

### 04 — Cause assessment and reasoning

`04-cause-assessment-and-reasoning.png`

Shows possible causes together with learner assessment states and stored reasoning.

**Demonstrates:** relational cause analysis, junction-style data and preservation of engineering reasoning.

---

### 05 — Dashboard aggregate results

`05-dashboard-aggregate-results.png`

Shows aggregate values calculated directly from the working database.

**Demonstrates:** `COUNT`, database-derived metrics and preparation for application/dashboard use.

---

### 06 — Safe CRUD transaction

`06-safe-crud-transaction.png`

Shows a controlled temporary record moving through:

`INSERT → UPDATE → DELETE → ROLLBACK`

**Demonstrates:** data manipulation, targeted `WHERE` conditions, safe deletion and transactional rollback.

---

### 07 — Database constraint validation

`07-database-constraint-validation.png`

Shows a deliberately invalid submitted attempt being rejected by the database.

**Demonstrates:** `CHECK` constraint enforcement and protection against invalid application state.

The complete validation suite is stored in:

`../../database/validation-tests.sql`

---

### 08 — Final database validation

`08-final-database-validation.png`

Shows the final seed-record counts after the validation process.

**Demonstrates:** preservation of the intended database state after safe CRUD and deliberate invalid-data testing.

---

## Evidence outcome

Together, these screenshots demonstrate that the FirstCommit Project 01 conceptual data design was translated into a working Project 02 relational database capable of:

- storing structured application data;
- enforcing primary-key, foreign-key, UNIQUE and CHECK constraints;
- resolving relationships with joins;
- recording investigation and reasoning history;
- manipulating data safely;
- producing aggregate information;
- rejecting invalid records;
- preserving the intended seed state.

Detailed validation results are documented in:

`../database-validation.md`
