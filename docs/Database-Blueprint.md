# Project 02 — Database Design and Manipulation
## Step 1: FirstCommit Database Blueprint

> **Implementation status:** Completed and validated. The sections below preserve the design decisions made before implementation. The working artefacts are `database/schema.sql`, `database/seed.sql`, `database/queries.sql`, `database/validation-tests.sql`, `database/firstcommit.db`, and the read-only local `app/` Data Studio. Final executed results are recorded in `evidence/database-validation.md`.

**Status:** Proposed architecture — pending Jeneane approval  
**Project handoff:** Project 01 conceptual system design → Project 02 working relational data layer  
**Primary database for the working portfolio build:** SQLite  
**Secondary relational translation planned:** MySQL  
**NoSQL evidence planned:** MongoDB comparison / small proof of concept only where it adds value

---

## 1. Purpose

Project 01 ended with a conceptual ERD and four logical data stores:

- D1 Users
- D2 Scenarios
- D3 Attempts
- D4 Feedback

Project 02 turns those concepts into a physical database that can be created, populated, queried, updated, validated and connected to a small professional interface.

The goal is not to invent a different project. The goal is to prove that the FirstCommit design can become a working data layer.

---

## 2. Project 01 → Project 02 handoff

| Project 01 logical data store | Project 02 physical tables |
|---|---|
| D1 Users | `users` |
| D2 Scenarios | `scenarios`, `evidence_items`, `cause_options` |
| D3 Attempts | `attempts`, `investigation_steps`, `cause_assessments` |
| D4 Feedback | `feedback` |

This preserves the architecture already approved in Project 01.

---

## 3. Why the core database is relational

FirstCommit contains structured relationships that must stay consistent:

- one user can make many attempts;
- one scenario can contain many evidence items;
- one scenario can define many possible causes;
- one attempt can contain many investigation steps;
- one attempt can evaluate many possible causes;
- one attempt can receive feedback from a reviewer.

A relational database makes those relationships visible and enforceable through primary keys, foreign keys, constraints and joins.

MongoDB remains useful as a comparison because the completed learning work included document-oriented storage, collections, embedded documents and CRUD operations. It is not being forced into the core FirstCommit architecture simply to add another technology.

---

# 4. Physical tables

## 4.1 `users`

**Purpose:** Stores people who interact with FirstCommit.

| Field | SQLite type | Rules |
|---|---|---|
| `user_id` | INTEGER | PK, AUTOINCREMENT |
| `display_name` | TEXT | NOT NULL |
| `email` | TEXT | NOT NULL, UNIQUE |
| `role` | TEXT | NOT NULL, CHECK learner/reviewer |
| `account_status` | TEXT | NOT NULL, CHECK active/inactive |
| `created_at` | TEXT | NOT NULL, default current timestamp |

**Project 01 origin:** `USER`

**Skills carried forward:** primary keys, unique values, entity creation, text fields and application-driven inserts.

---

## 4.2 `scenarios`

**Purpose:** Stores engineering scenarios that learners can investigate.

| Field | SQLite type | Rules |
|---|---|---|
| `scenario_id` | INTEGER | PK, AUTOINCREMENT |
| `created_by_user_id` | INTEGER | NOT NULL, FK → users |
| `title` | TEXT | NOT NULL |
| `difficulty` | TEXT | NOT NULL, CHECK beginner/intermediate/advanced |
| `learning_goal` | TEXT | NOT NULL |
| `status` | TEXT | NOT NULL, CHECK draft/active/archived |
| `created_at` | TEXT | NOT NULL, default current timestamp |
| `updated_at` | TEXT | NOT NULL, default current timestamp |

**Project 01 origin:** `SCENARIO`

**Implementation refinement:** `created_by_user_id` is added in Project 02 because the Project 01 use-case model already says a Mentor / Reviewer can create or maintain a scenario. The database now records who created it.

---

## 4.3 `evidence_items`

**Purpose:** Stores the technical evidence belonging to each scenario.

| Field | SQLite type | Rules |
|---|---|---|
| `evidence_id` | INTEGER | PK, AUTOINCREMENT |
| `scenario_id` | INTEGER | NOT NULL, FK → scenarios |
| `system_layer` | TEXT | NOT NULL |
| `evidence_type` | TEXT | NOT NULL |
| `content_reference` | TEXT | NOT NULL |
| `sequence_no` | INTEGER | NOT NULL, CHECK > 0 |
| `created_at` | TEXT | NOT NULL, default current timestamp |

**Constraint:** `UNIQUE (scenario_id, sequence_no)`

**Project 01 origin:** `EVIDENCE_ITEM`

**Reason:** The sequence constraint prevents two evidence items from occupying the same ordered position inside one scenario.

---

## 4.4 `attempts`

**Purpose:** Stores each learner's attempt at an engineering scenario.

| Field | SQLite type | Rules |
|---|---|---|
| `attempt_id` | INTEGER | PK, AUTOINCREMENT |
| `user_id` | INTEGER | NOT NULL, FK → users |
| `scenario_id` | INTEGER | NOT NULL, FK → scenarios |
| `started_at` | TEXT | NOT NULL, default current timestamp |
| `completed_at` | TEXT | nullable |
| `status` | TEXT | NOT NULL, CHECK in_progress/submitted/reviewed |
| `submitted_reasoning` | TEXT | nullable |

**Project 01 origin:** `ATTEMPT`

**Important continuity:** Project 01 deliberately renamed the final field to `submitted_reasoning`. Project 02 keeps that decision.

---

## 4.5 `investigation_steps`

**Purpose:** Stores the learner's chronological reasoning trail.

| Field | SQLite type | Rules |
|---|---|---|
| `step_id` | INTEGER | PK, AUTOINCREMENT |
| `attempt_id` | INTEGER | NOT NULL, FK → attempts |
| `evidence_id` | INTEGER | NOT NULL, FK → evidence_items |
| `sequence_no` | INTEGER | NOT NULL, CHECK > 0 |
| `action_taken` | TEXT | NOT NULL |
| `observation` | TEXT | NOT NULL |
| `reason_for_next_step` | TEXT | nullable |
| `created_at` | TEXT | NOT NULL, default current timestamp |

**Constraint:** `UNIQUE (attempt_id, sequence_no)`

**Project 01 origin:** `INVESTIGATION_STEP`

**Reason:** This table is the database version of the FirstCommit principle that a learner should be able to explain what was inspected, what was observed and why the next step followed.

---

## 4.6 `cause_options`

**Purpose:** Stores the possible causes defined for a scenario.

| Field | SQLite type | Rules |
|---|---|---|
| `cause_id` | INTEGER | PK, AUTOINCREMENT |
| `scenario_id` | INTEGER | NOT NULL, FK → scenarios |
| `description` | TEXT | NOT NULL |
| `is_root_cause` | INTEGER | NOT NULL, CHECK 0/1 |
| `created_at` | TEXT | NOT NULL, default current timestamp |

**Constraint:** `UNIQUE (scenario_id, description)`

**Project 01 origin:** `CAUSE_OPTION`

---

## 4.7 `cause_assessments`

**Purpose:** Stores how a learner evaluates a possible cause during an attempt.

| Field | SQLite type | Rules |
|---|---|---|
| `assessment_id` | INTEGER | PK, AUTOINCREMENT |
| `attempt_id` | INTEGER | NOT NULL, FK → attempts |
| `cause_id` | INTEGER | NOT NULL, FK → cause_options |
| `assessment_status` | TEXT | NOT NULL, CHECK considering/eliminated/supported |
| `reasoning` | TEXT | NOT NULL |
| `assessed_at` | TEXT | NOT NULL, default current timestamp |

**Constraint:** `UNIQUE (attempt_id, cause_id)`

**Project 01 origin:** `CAUSE_ASSESSMENT`

**Design pattern:** This is a junction-style table connecting an attempt to a possible cause while also storing information about that relationship.

---

## 4.8 `feedback`

**Purpose:** Stores reviewer feedback against an attempt.

| Field | SQLite type | Rules |
|---|---|---|
| `feedback_id` | INTEGER | PK, AUTOINCREMENT |
| `attempt_id` | INTEGER | NOT NULL, FK → attempts |
| `reviewer_id` | INTEGER | NOT NULL, FK → users |
| `feedback_text` | TEXT | NOT NULL |
| `created_at` | TEXT | NOT NULL, default current timestamp |

**Project 01 origin:** `FEEDBACK`

---

# 5. Relationship rules

```text
users 1 ───────< attempts
users 1 ───────< scenarios             (creator / reviewer role)
users 1 ───────< feedback              (reviewer)

scenarios 1 ───< evidence_items
scenarios 1 ───< cause_options
scenarios 1 ───< attempts

attempts 1 ────< investigation_steps
attempts 1 ────< cause_assessments
attempts 1 ────< feedback

evidence_items 1 ───< investigation_steps
cause_options 1 ────< cause_assessments
```

---

# 6. Referential-integrity strategy

The baseline uses simple, understandable foreign-key rules.

| Parent → child | Proposed delete behaviour | Reason |
|---|---|---|
| users → attempts | RESTRICT | Do not remove a learner if investigation history exists |
| users → scenarios | RESTRICT | Preserve scenario ownership |
| users → feedback | RESTRICT | Preserve reviewer attribution |
| scenarios → attempts | RESTRICT | Do not remove a scenario with learner history |
| scenarios → evidence_items | CASCADE | Scenario-owned definition data |
| scenarios → cause_options | CASCADE | Scenario-owned definition data |
| attempts → investigation_steps | CASCADE | Steps belong to the attempt |
| attempts → cause_assessments | CASCADE | Assessments belong to the attempt |
| attempts → feedback | CASCADE | Feedback belongs to the attempt |
| evidence_items → investigation_steps | RESTRICT | Do not silently break a reasoning trail |
| cause_options → cause_assessments | RESTRICT | Do not silently break cause history |

For the public interface, archiving will be preferred over destructive deletion for important records such as users and scenarios.

---

# 7. Original CRUD and query plan — implemented

Project 02 was designed to visibly prove manipulation, not only database creation. The implemented SQL evidence is now stored in `database/queries.sql`.

## SELECT
- list active scenarios;
- search scenarios by title/difficulty;
- show attempts with learner and scenario names;
- show an investigation trail in sequence;
- show feedback with reviewer name;
- show cause assessments with cause descriptions.

## INSERT
- add a scenario;
- add scenario evidence;
- start an attempt;
- record an investigation step;
- assess a possible cause;
- add reviewer feedback.

## UPDATE
- change scenario status;
- update an investigation step;
- update a cause assessment;
- submit final reasoning;
- move an attempt from `in_progress` → `submitted` → `reviewed`.

## DELETE
- demonstrate a safe, specific delete using a test/draft record and a `WHERE` condition;
- show that foreign-key constraints prevent unsafe deletion of referenced records;
- use archive/status changes for records that form part of a professional evidence trail.

## JOIN
At minimum:
- learner + attempt + scenario;
- attempt + investigation steps + evidence;
- attempt + cause assessment + cause option;
- attempt + feedback + reviewer.

---

# 8. Original validation / debugging targets

The database will be considered correct only when we prove:

1. foreign keys are enabled;
2. duplicate user emails are rejected;
3. invalid status/difficulty values are rejected;
4. negative/zero sequence numbers are rejected;
5. duplicate evidence sequence numbers in one scenario are rejected;
6. duplicate investigation-step sequence numbers in one attempt are rejected;
7. an attempt cannot reference a user/scenario that does not exist;
8. deleting a referenced user/scenario is blocked;
9. joined queries return readable business information, not only IDs;
10. Flask database access remains read-only and does not construct SQL from user input.

---

# 9. Security boundary for Project 02

Project 02 truthfully demonstrates database-focused protections that are present in the implementation:

- read-only SQLite application access using URI `mode=ro`;
- `PRAGMA query_only = ON` for the Data Studio connection;
- UNIQUE and CHECK constraints;
- foreign-key integrity;
- no committed credentials;
- safe, specific DELETE operations inside a rolled-back demonstration transaction;
- closed database connections / context-managed connections;
- `.gitignore` protection for local configuration, cache and environment files.

The current Data Studio does not accept user-entered query or form data, so parameterised user-input queries and server-side form validation are **not claimed as implemented evidence**.

Project 02 does **not** claim penetration testing, production-grade authentication, production deployment or complete application security.

---

# 10. SQL / MySQL / MongoDB strategy

## Core working database — SQLite

Why:
- reproducible from the GitHub repository;
- easy for a recruiter to run locally;
- already proven in Jeneane's completed database work;
- supports foreign keys, CHECK constraints, UNIQUE constraints, joins and parameterised queries;
- works cleanly with Flask.

## MySQL translation

A second schema file can later demonstrate that Jeneane can translate the same relational model into MySQL syntax:

- `AUTO_INCREMENT`;
- MySQL-compatible data types;
- foreign-key constraints;
- the same joins and CRUD concepts.

This is evidence of database-platform awareness, not a second unrelated project.

## MongoDB

MongoDB remains a documented comparison / optional small proof of concept.

It will only be used where a document model makes sense. It will not replace the relational core merely to show another technology.

---

# 11. Cross-check against Jeneane's completed practical work

The new tables do **not** claim that these exact FirstCommit tables existed in the original assignments.

Instead, the underlying database skills are carried forward:

| FirstCommit requirement | Prior practical pattern already demonstrated |
|---|---|
| `users` | customer/user-style entity with primary key and contact fields |
| `scenarios` | independent business entity with typed fields and constraints |
| `evidence_items` | one-to-many child records linked to a parent |
| `attempts` | transaction/order-style record linking major entities |
| `investigation_steps` | ordered child records belonging to a parent transaction/attempt |
| `cause_options` | scenario-owned reference records |
| `cause_assessments` | junction-table pattern with two foreign keys plus relationship data |
| `feedback` | child record linked to an attempt and a user/reviewer |
| CRUD | SELECT, INSERT, UPDATE and DELETE |
| reporting | INNER JOIN across related tables |
| integrity | PK, FK, UNIQUE and CHECK-style rules |
| app connection | Flask ↔ database connection |
| NoSQL awareness | MongoDB collections, documents, CRUD and PyMongo connectivity |

This is the professional progression:

> **Skills proved in earlier practical work → applied to the FirstCommit domain → validated as one coherent database architecture**

---

# 12. Pre-implementation approval gate — completed

Before creating `schema.sql`, the architecture should answer YES to all of these:

- Does every Project 01 ERD entity have a physical home?
- Do the Project 01 DFD stores map cleanly to the tables?
- Does every foreign key have a reason?
- Can the planned queries prove the database relationships?
- Are destructive operations controlled?
- Is the design understandable enough for Jeneane to explain in an interview?
- Does the database prepare Project 03 without building Project 03 too early?

**Implementation outcome:** the approved design was carried into `schema.sql`, `seed.sql`, `queries.sql`, the physical Mermaid ERD, `validation-tests.sql`, `firstcommit.db` and the read-only local Data Studio. Executed validation evidence is recorded separately in `evidence/database-validation.md`.
