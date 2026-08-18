-- FirstCommit Data Layer
-- Project 02 — Database Design and Manipulation
-- Physical SQLite schema
--
-- Project 01 established the conceptual entities and relationships.
-- Project 02 implements them as a working relational database.
--
-- Implementation refinements introduced here are deliberately documented:
--   1. scenarios.created_by_user_id records which reviewer created a scenario.
--   2. timestamps and CHECK/UNIQUE constraints make the physical model safer.
--   3. indexes are added for common foreign-key and lookup paths.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS cause_assessments;
DROP TABLE IF EXISTS investigation_steps;
DROP TABLE IF EXISTS cause_options;
DROP TABLE IF EXISTS evidence_items;
DROP TABLE IF EXISTS attempts;
DROP TABLE IF EXISTS scenarios;
DROP TABLE IF EXISTS users;

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

-- Indexes support the relationship paths used by the application and JOIN queries.
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
