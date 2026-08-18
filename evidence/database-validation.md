# Project 02 — Database Validation Evidence

## 1. Validation purpose

The Project 02 database was validated to confirm that the physical FirstCommit data layer:

- is structurally consistent;
- preserves referential integrity;
- enforces relational constraints;
- rejects deliberately invalid data;
- supports relational queries and multi-table joins;
- supports controlled INSERT, UPDATE and DELETE operations;
- preserves the original seed state after safe CRUD demonstrations.

Validation was performed against the SQLite implementation in:

`database/firstcommit.db`

The reproducible validation statements are stored in:

`database/validation-tests.sql`

---

## 2. Database integrity checks

### SQLite integrity check

Executed:

```sql
PRAGMA integrity_check;
```

Result:

`ok`

**Status:** PASS

SQLite reported no structural integrity problems in the database.

### Foreign-key integrity check

Executed:

```sql
PRAGMA foreign_key_check;
```

Result:

`0 violations`

**Status:** PASS

No existing database records contain broken foreign-key references.

---

## 3. Deliberate constraint validation

The following invalid operations were executed individually to confirm that the database rejects data that violates its rules.

### 3.1 Duplicate email

A user was deliberately inserted using an email address already stored in the `users` table.

Result:

`UNIQUE constraint failed: users.email`

**Status:** PASS — invalid duplicate data was rejected.

### 3.2 Invalid user role

A user was deliberately assigned the unsupported role:

`administrator`

Result:

`CHECK constraint failed: users`

**Status:** PASS — the invalid role was rejected.

### 3.3 Invalid foreign key

An attempt was deliberately created with:

`user_id = 999`

No user with this ID exists.

Foreign-key enforcement was enabled for the execution connection using:

```sql
PRAGMA foreign_keys = ON;
```

Result:

`FOREIGN KEY constraint failed`

**Status:** PASS — the database prevented a broken relationship.

### 3.4 Duplicate evidence sequence

An evidence item was deliberately inserted using an existing combination of:

`scenario_id = 1`

and

`sequence_no = 1`

Result:

`UNIQUE constraint failed: evidence_items.scenario_id, evidence_items.sequence_no`

**Status:** PASS — duplicate sequence positions inside one scenario were rejected.

### 3.5 Invalid attempt completion

An attempt was deliberately assigned:

`status = 'submitted'`

while:

`completed_at = NULL`

Result:

`CHECK constraint failed: ck_attempt_completion`

**Status:** PASS — the attempt could not be submitted without the required completion information.

---

## 4. Relational query validation

The Project 02 query pack was executed against the seeded database.

Validated operations include:

- SELECT;
- WHERE filtering;
- CASE-based ordering;
- INNER JOIN;
- LEFT JOIN;
- COUNT;
- COUNT DISTINCT;
- GROUP BY;
- INSERT;
- UPDATE;
- DELETE;
- transactions;
- ROLLBACK.

### Verified query results

Active scenarios returned:

`3`

Attempt-summary JOIN rows returned:

`3`

Complete investigation-trail JOIN rows returned:

`8`

Cause-assessment rows returned:

`6`

Dashboard aggregate values returned:

- Active scenarios: `3`
- Evidence items: `9`
- Attempts: `3`
- Investigation steps: `8`
- Cause assessments: `6`
- Feedback records: `1`

**Status:** PASS

---

## 5. Safe CRUD validation

A temporary scenario was created specifically for the CRUD demonstration.

The controlled sequence was:

`INSERT → verify → UPDATE → verify → DELETE → verify → ROLLBACK`

The temporary scenario was:

`Temporary CRUD demonstration scenario`

It was first inserted with:

`status = 'draft'`

It was then updated to:

`status = 'active'`

The controlled DELETE returned:

`temporary_scenario_remaining = 0`

The transaction then ended with:

```sql
ROLLBACK;
```

The original seed state remained unchanged after the transaction.

**Status:** PASS

---

## 6. Final seed-state verification

After the complete validation process, the database contained:

| Table | Final record count |
|---|---:|
| `users` | 5 |
| `scenarios` | 3 |
| `evidence_items` | 9 |
| `attempts` | 3 |
| `investigation_steps` | 8 |
| `cause_options` | 12 |
| `cause_assessments` | 6 |
| `feedback` | 1 |

These values match the intended seed state.

**Status:** PASS

---

## 7. Evidence screenshots

The database-validation process is supported by the following portfolio evidence:

1. `01-database-structure-and-seed-data.png` — physical database structure and seeded scenario data.
2. `02-query-active-scenarios-result.png` — active-scenario SELECT and JOIN result.
3. `03-multi-table-investigation-trail.png` — multi-table investigation-trail JOIN.
4. `04-cause-assessment-and-reasoning.png` — possible-cause assessments and stored reasoning.
5. `05-dashboard-aggregate-results.png` — aggregate values derived directly from the database.
6. `06-safe-crud-transaction.png` — controlled INSERT, UPDATE, DELETE and ROLLBACK.
7. `07-database-constraint-validation.png` — deliberate invalid-data rejection.
8. `08-final-database-validation.png` — final seed-count verification.

---

## 8. Validation conclusion

The Project 02 SQLite database passed the validation gate.

The evidence demonstrates that the FirstCommit conceptual design from Project 01 has been translated into a working relational database that can:

- store structured application data;
- enforce relationships;
- protect data integrity;
- reject invalid records;
- reconstruct information across related tables;
- support controlled data manipulation;
- produce aggregate information suitable for a local application interface.

The local FirstCommit Data Studio reads this validated database through a read-only Flask data-access layer. The interface does not modify the evidence database.
