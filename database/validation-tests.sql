-- FirstCommit Database Validation Tests
-- Project 02 — Database Design and Manipulation
--
-- Purpose:
-- Prove database integrity, referential integrity, UNIQUE constraints,
-- CHECK constraints and preservation of the original seed data.
--
-- IMPORTANT:
-- Run each numbered validation test individually.
-- Tests marked "expected to fail" PASS when SQLite rejects the invalid data.

PRAGMA foreign_keys = ON;

-- 1. SQLite integrity check — expected result: ok
PRAGMA integrity_check;

-- 2. Foreign-key integrity check — expected result: no rows
PRAGMA foreign_key_check;

-- 3. Duplicate email test — expected to fail
INSERT INTO users (
    display_name,
    email,
    role,
    account_status
)
VALUES (
    'Duplicate Email Test',
    'maya.reviewer@firstcommit.local',
    'reviewer',
    'active'
);

-- 4. Invalid role test — expected to fail
INSERT INTO users (
    display_name,
    email,
    role,
    account_status
)
VALUES (
    'Invalid Role Test',
    'invalid.role@firstcommit.local',
    'administrator',
    'active'
);

-- 5. Invalid foreign-key test — expected to fail
-- Include PRAGMA foreign_keys = ON when running this block independently.
PRAGMA foreign_keys = ON;

INSERT INTO attempts (
    user_id,
    scenario_id,
    status
)
VALUES (
    999,
    1,
    'in_progress'
);

-- 6. Duplicate evidence sequence test — expected to fail
INSERT INTO evidence_items (
    scenario_id,
    system_layer,
    evidence_type,
    content_reference,
    sequence_no
)
VALUES (
    1,
    'Validation Test',
    'Duplicate sequence test',
    'This row should be rejected by the composite UNIQUE constraint.',
    1
);

-- 7. Invalid attempt completion test — expected to fail
INSERT INTO attempts (
    user_id,
    scenario_id,
    completed_at,
    status,
    submitted_reasoning
)
VALUES (
    5,
    3,
    NULL,
    'submitted',
    'This reasoning is long enough for the validation test.'
);

-- 8. Final seed-count verification
SELECT
    (SELECT COUNT(*) FROM users) AS users,
    (SELECT COUNT(*) FROM scenarios) AS scenarios,
    (SELECT COUNT(*) FROM evidence_items) AS evidence_items,
    (SELECT COUNT(*) FROM attempts) AS attempts,
    (SELECT COUNT(*) FROM investigation_steps) AS investigation_steps,
    (SELECT COUNT(*) FROM cause_options) AS cause_options,
    (SELECT COUNT(*) FROM cause_assessments) AS cause_assessments,
    (SELECT COUNT(*) FROM feedback) AS feedback;
