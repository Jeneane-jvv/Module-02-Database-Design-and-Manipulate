-- FirstCommit Data Layer — exact SQLite export
-- Project 02 — Database Design and Manipulation
-- Generated directly from database/firstcommit.db
-- Contains schema, indexes, stored rows and sqlite_sequence state.
-- Import target: SQLite.

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;
CREATE TABLE attempts (
    attempt_id           INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id              INTEGER NOT NULL,
    scenario_id          INTEGER NOT NULL,
    started_at           TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at         TEXT,
    status               TEXT NOT NULL DEFAULT 'in_progress'
                             CHECK (status IN ('in_progress', 'submitted', 'reviewed')),
    submitted_reasoning  TEXT,

    CONSTRAINT ck_attempt_completion
        CHECK (
            (status = 'in_progress' AND completed_at IS NULL)
            OR
            (status IN ('submitted', 'reviewed')
             AND completed_at IS NOT NULL
             AND submitted_reasoning IS NOT NULL
             AND length(trim(submitted_reasoning)) >= 10)
        ),

    CONSTRAINT fk_attempt_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_attempt_scenario
        FOREIGN KEY (scenario_id)
        REFERENCES scenarios(scenario_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
INSERT INTO "attempts" VALUES(1,3,1,'2026-08-12 09:10:00','2026-08-12 09:48:00','reviewed','The deployed authentication audience does not match the audience expected by token validation.');
INSERT INTO "attempts" VALUES(2,4,2,'2026-08-13 13:20:00','2026-08-13 13:55:00','submitted','The interface and database are healthy; the API filter excludes records that should be returned.');
INSERT INTO "attempts" VALUES(3,5,3,'2026-08-14 15:05:00',NULL,'in_progress',NULL);
CREATE TABLE cause_assessments (
    assessment_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    attempt_id          INTEGER NOT NULL,
    cause_id            INTEGER NOT NULL,
    assessment_status   TEXT NOT NULL
                            CHECK (assessment_status IN ('considering', 'eliminated', 'supported')),
    reasoning           TEXT NOT NULL
                            CHECK (length(trim(reasoning)) >= 5),
    assessed_at         TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_attempt_cause
        UNIQUE (attempt_id, cause_id),

    CONSTRAINT fk_assessment_attempt
        FOREIGN KEY (attempt_id)
        REFERENCES attempts(attempt_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_assessment_cause
        FOREIGN KEY (cause_id)
        REFERENCES cause_options(cause_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
INSERT INTO "cause_assessments" VALUES(1,1,1,'eliminated','The token is current and works in the local environment.','2026-08-16 22:14:41');
INSERT INTO "cause_assessments" VALUES(2,1,3,'supported','Configuration and backend log evidence both point to the same audience mismatch.','2026-08-16 22:14:41');
INSERT INTO "cause_assessments" VALUES(3,1,4,'eliminated','The request reaches the backend and fails before database access is relevant.','2026-08-16 22:14:41');
INSERT INTO "cause_assessments" VALUES(4,2,5,'eliminated','The dashboard is visible and there is no console evidence of a rendering failure.','2026-08-16 22:14:41');
INSERT INTO "cause_assessments" VALUES(5,2,7,'supported','The database contains active rows while the API returns an empty result set.','2026-08-16 22:14:41');
INSERT INTO "cause_assessments" VALUES(6,3,9,'considering','The foreign key error makes missing parent data the strongest current hypothesis.','2026-08-16 22:14:41');
CREATE TABLE cause_options (
    cause_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    scenario_id       INTEGER NOT NULL,
    description       TEXT NOT NULL
                          CHECK (length(trim(description)) >= 5),
    is_root_cause     INTEGER NOT NULL DEFAULT 0
                          CHECK (is_root_cause IN (0, 1)),
    created_at        TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cause_description
        UNIQUE (scenario_id, description),

    CONSTRAINT fk_cause_scenario
        FOREIGN KEY (scenario_id)
        REFERENCES scenarios(scenario_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
INSERT INTO "cause_options" VALUES(1,1,'Expired authentication token',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(2,1,'Incorrect deployed API URL',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(3,1,'Authentication audience configuration mismatch',1,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(4,1,'Database service unavailable',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(5,2,'Dashboard CSS hides the records',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(6,2,'Frontend state never receives the API result',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(7,2,'API status filter excludes the active records',1,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(8,2,'Database service is offline',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(9,3,'Integration database has a missing parent record',1,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(10,3,'Network connection times out',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(11,3,'Database connection is read-only',0,'2026-08-16 22:14:41');
INSERT INTO "cause_options" VALUES(12,3,'Insert statement contains malformed SQL',0,'2026-08-16 22:14:41');
CREATE TABLE evidence_items (
    evidence_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    scenario_id          INTEGER NOT NULL,
    system_layer         TEXT NOT NULL,
    evidence_type        TEXT NOT NULL,
    content_reference    TEXT NOT NULL,
    sequence_no          INTEGER NOT NULL
                             CHECK (sequence_no > 0),
    created_at           TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_evidence_sequence
        UNIQUE (scenario_id, sequence_no),

    CONSTRAINT fk_evidence_scenario
        FOREIGN KEY (scenario_id)
        REFERENCES scenarios(scenario_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
INSERT INTO "evidence_items" VALUES(1,1,'Browser / HTTP','Network response','GET /api/profile returns HTTP 401 after deployment.',1,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(2,1,'Deployment configuration','Environment comparison','Authentication audience differs between local and deployed environments.',2,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(3,1,'Backend','Application log','Token validation log reports an audience mismatch.',3,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(4,2,'Frontend','Browser console','Dashboard renders with no JavaScript error.',1,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(5,2,'API','Network response','GET /api/scenarios returns HTTP 200 with an empty array.',2,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(6,2,'Database','Query result','Active scenario rows exist in the database.',3,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(7,3,'Application','Error log','Insert request reaches the database but the transaction is rolled back.',1,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(8,3,'Database','Constraint error','Foreign key constraint fails for the referenced scenario identifier.',2,'2026-08-16 22:14:41');
INSERT INTO "evidence_items" VALUES(9,3,'Integration data','Reference check','The scenario identifier used by the request does not exist in the integration database.',3,'2026-08-16 22:14:41');
CREATE TABLE feedback (
    feedback_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    attempt_id      INTEGER NOT NULL,
    reviewer_id     INTEGER NOT NULL,
    feedback_text   TEXT NOT NULL
                        CHECK (length(trim(feedback_text)) >= 5),
    created_at      TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_feedback_attempt
        FOREIGN KEY (attempt_id)
        REFERENCES attempts(attempt_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_feedback_reviewer
        FOREIGN KEY (reviewer_id)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
INSERT INTO "feedback" VALUES(1,1,1,'Strong evidence chain. You eliminated unrelated database behaviour before changing authentication code.','2026-08-12 10:05:00');
CREATE TABLE investigation_steps (
    step_id               INTEGER PRIMARY KEY AUTOINCREMENT,
    attempt_id            INTEGER NOT NULL,
    evidence_id           INTEGER NOT NULL,
    sequence_no           INTEGER NOT NULL
                              CHECK (sequence_no > 0),
    action_taken          TEXT NOT NULL
                              CHECK (length(trim(action_taken)) >= 3),
    observation           TEXT NOT NULL
                              CHECK (length(trim(observation)) >= 3),
    reason_for_next_step  TEXT,
    created_at            TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_investigation_sequence
        UNIQUE (attempt_id, sequence_no),

    CONSTRAINT fk_step_attempt
        FOREIGN KEY (attempt_id)
        REFERENCES attempts(attempt_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_step_evidence
        FOREIGN KEY (evidence_id)
        REFERENCES evidence_items(evidence_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
INSERT INTO "investigation_steps" VALUES(1,1,1,1,'Inspect the failing network request','The deployed profile request returns HTTP 401.','A 401 points to authentication before database behaviour, so inspect authentication configuration next.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(2,1,2,2,'Compare local and deployed authentication settings','The configured audience differs between the two environments.','The configuration difference is a candidate cause; inspect backend validation logs for confirming evidence.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(3,1,3,3,'Inspect token validation logs','The backend explicitly reports an authentication audience mismatch.','The log confirms the configuration mismatch and supports the final reasoning.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(4,2,4,1,'Check the browser console','The dashboard renders without a JavaScript error.','The visible page is healthy enough to inspect the data request next.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(5,2,5,2,'Inspect the scenarios API response','The request succeeds but returns an empty list.','Because transport works, compare the API result with the records stored in the database.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(6,2,6,3,'Compare the API result with database rows','Active scenario records exist even though the API returns none.','The mismatch supports investigating API-side filtering rather than the frontend or database service.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(7,3,7,1,'Inspect the integration insert error','The request reaches the database but the transaction rolls back.','Inspect the database error to determine whether the failure is connection, syntax or integrity related.','2026-08-16 22:14:41');
INSERT INTO "investigation_steps" VALUES(8,3,8,2,'Inspect the database constraint message','The database reports a foreign key constraint failure.','Check whether the parent identifier exists in the integration dataset before changing the SQL.','2026-08-16 22:14:41');
CREATE TABLE scenarios (
    scenario_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    created_by_user_id   INTEGER NOT NULL,
    title                TEXT NOT NULL
                             CHECK (length(trim(title)) >= 5),
    difficulty           TEXT NOT NULL
                             CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    learning_goal        TEXT NOT NULL
                             CHECK (length(trim(learning_goal)) >= 10),
    status               TEXT NOT NULL DEFAULT 'draft'
                             CHECK (status IN ('draft', 'active', 'archived')),
    created_at           TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_scenarios_creator
        FOREIGN KEY (created_by_user_id)
        REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
INSERT INTO "scenarios" VALUES(1,1,'API authentication fails after deployment','intermediate','Trace authentication evidence systematically before changing application code.','active','2026-08-16 22:14:41','2026-08-16 22:14:41');
INSERT INTO "scenarios" VALUES(2,1,'Dashboard loads but live data is missing','beginner','Separate interface rendering problems from API and data-source problems.','active','2026-08-16 22:14:41','2026-08-16 22:14:41');
INSERT INTO "scenarios" VALUES(3,2,'Database write works locally but fails in integration','advanced','Follow database evidence from application request to relational-integrity failure.','active','2026-08-16 22:14:41','2026-08-16 22:14:41');
CREATE TABLE users (
    user_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    display_name     TEXT NOT NULL
                         CHECK (length(trim(display_name)) >= 2),
    email            TEXT NOT NULL COLLATE NOCASE UNIQUE
                         CHECK (instr(email, '@') > 1),
    role             TEXT NOT NULL
                         CHECK (role IN ('learner', 'reviewer')),
    account_status   TEXT NOT NULL DEFAULT 'active'
                         CHECK (account_status IN ('active', 'inactive')),
    created_at       TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "users" VALUES(1,'Maya Reviewer','maya.reviewer@firstcommit.local','reviewer','active','2026-08-16 22:14:41');
INSERT INTO "users" VALUES(2,'Theo Reviewer','theo.reviewer@firstcommit.local','reviewer','active','2026-08-16 22:14:41');
INSERT INTO "users" VALUES(3,'Lebo Learner','lebo.learner@firstcommit.local','learner','active','2026-08-16 22:14:41');
INSERT INTO "users" VALUES(4,'Aisha Learner','aisha.learner@firstcommit.local','learner','active','2026-08-16 22:14:41');
INSERT INTO "users" VALUES(5,'Daniel Learner','daniel.learner@firstcommit.local','learner','active','2026-08-16 22:14:41');
CREATE INDEX idx_scenarios_creator
    ON scenarios(created_by_user_id);
CREATE INDEX idx_evidence_scenario
    ON evidence_items(scenario_id, sequence_no);
CREATE INDEX idx_attempts_user
    ON attempts(user_id);
CREATE INDEX idx_attempts_scenario
    ON attempts(scenario_id);
CREATE INDEX idx_steps_attempt
    ON investigation_steps(attempt_id, sequence_no);
CREATE INDEX idx_steps_evidence
    ON investigation_steps(evidence_id);
CREATE INDEX idx_causes_scenario
    ON cause_options(scenario_id);
CREATE INDEX idx_assessments_attempt
    ON cause_assessments(attempt_id);
CREATE INDEX idx_assessments_cause
    ON cause_assessments(cause_id);
CREATE INDEX idx_feedback_attempt
    ON feedback(attempt_id);
CREATE INDEX idx_feedback_reviewer
    ON feedback(reviewer_id);
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('users',5);
INSERT INTO "sqlite_sequence" VALUES('scenarios',3);
INSERT INTO "sqlite_sequence" VALUES('evidence_items',9);
INSERT INTO "sqlite_sequence" VALUES('cause_options',12);
INSERT INTO "sqlite_sequence" VALUES('attempts',3);
INSERT INTO "sqlite_sequence" VALUES('investigation_steps',8);
INSERT INTO "sqlite_sequence" VALUES('cause_assessments',6);
INSERT INTO "sqlite_sequence" VALUES('feedback',1);
COMMIT;
PRAGMA foreign_keys = ON;

-- Optional post-import verification:
-- PRAGMA integrity_check;
-- PRAGMA foreign_key_check;
