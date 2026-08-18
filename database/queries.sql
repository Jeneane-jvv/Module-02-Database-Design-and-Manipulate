-- FirstCommit Data Layer
-- Project 02 — Query and manipulation evidence
--
-- Sections 1–7 are read-only reporting queries.
-- Section 8 demonstrates INSERT, UPDATE and DELETE inside a transaction that is rolled back,
-- allowing the evidence pack to be re-run without changing the seed database.

PRAGMA foreign_keys = ON;

-- ===========================================================================
-- 1. SELECT — active scenarios with creator
-- ===========================================================================

SELECT
    s.scenario_id,
    s.title,
    s.difficulty,
    s.status,
    u.display_name AS created_by
FROM scenarios AS s
JOIN users AS u
    ON u.user_id = s.created_by_user_id
WHERE s.status = 'active'
ORDER BY
    CASE s.difficulty
        WHEN 'beginner' THEN 1
        WHEN 'intermediate' THEN 2
        ELSE 3
    END,
    s.title;


-- ===========================================================================
-- 2. SELECT — scenario evidence in investigation order
-- Change the title in the WHERE clause to inspect another scenario.
-- ===========================================================================

SELECT
    s.title AS scenario,
    e.sequence_no,
    e.system_layer,
    e.evidence_type,
    e.content_reference
FROM scenarios AS s
JOIN evidence_items AS e
    ON e.scenario_id = s.scenario_id
WHERE s.title = 'API authentication fails after deployment'
ORDER BY e.sequence_no;


-- ===========================================================================
-- 3. JOIN — attempt summary with learner and scenario
-- ===========================================================================

SELECT
    a.attempt_id,
    u.display_name AS learner,
    s.title AS scenario,
    s.difficulty,
    a.status,
    a.started_at,
    a.completed_at,
    a.submitted_reasoning
FROM attempts AS a
JOIN users AS u
    ON u.user_id = a.user_id
JOIN scenarios AS s
    ON s.scenario_id = a.scenario_id
ORDER BY a.started_at;


-- ===========================================================================
-- 4. JOIN — complete investigation trail
-- ===========================================================================

SELECT
    u.display_name AS learner,
    s.title AS scenario,
    st.sequence_no AS step_no,
    e.system_layer,
    e.evidence_type,
    st.action_taken,
    st.observation,
    st.reason_for_next_step
FROM investigation_steps AS st
JOIN attempts AS a
    ON a.attempt_id = st.attempt_id
JOIN users AS u
    ON u.user_id = a.user_id
JOIN scenarios AS s
    ON s.scenario_id = a.scenario_id
JOIN evidence_items AS e
    ON e.evidence_id = st.evidence_id
ORDER BY a.attempt_id, st.sequence_no;


-- ===========================================================================
-- 5. JOIN — cause assessments with possible causes
-- ===========================================================================

SELECT
    u.display_name AS learner,
    s.title AS scenario,
    c.description AS possible_cause,
    ca.assessment_status,
    ca.reasoning
FROM cause_assessments AS ca
JOIN attempts AS a
    ON a.attempt_id = ca.attempt_id
JOIN users AS u
    ON u.user_id = a.user_id
JOIN scenarios AS s
    ON s.scenario_id = a.scenario_id
JOIN cause_options AS c
    ON c.cause_id = ca.cause_id
ORDER BY a.attempt_id, c.cause_id;


-- ===========================================================================
-- 6. JOIN — reviewer feedback
-- ===========================================================================

SELECT
    learner.display_name AS learner,
    s.title AS scenario,
    reviewer.display_name AS reviewer,
    f.feedback_text,
    f.created_at
FROM feedback AS f
JOIN attempts AS a
    ON a.attempt_id = f.attempt_id
JOIN users AS learner
    ON learner.user_id = a.user_id
JOIN scenarios AS s
    ON s.scenario_id = a.scenario_id
JOIN users AS reviewer
    ON reviewer.user_id = f.reviewer_id
ORDER BY f.created_at;


-- ===========================================================================
-- 7. Dashboard-style aggregate queries for the later FirstCommit Data Studio
-- ===========================================================================

SELECT
    (SELECT COUNT(*) FROM scenarios WHERE status = 'active') AS active_scenarios,
    (SELECT COUNT(*) FROM evidence_items) AS evidence_items,
    (SELECT COUNT(*) FROM attempts) AS attempts,
    (SELECT COUNT(*) FROM investigation_steps) AS investigation_steps,
    (SELECT COUNT(*) FROM cause_assessments) AS cause_assessments,
    (SELECT COUNT(*) FROM feedback) AS feedback_records;

SELECT
    s.title,
    COUNT(DISTINCT a.attempt_id) AS attempt_count,
    COUNT(DISTINCT st.step_id) AS investigation_step_count
FROM scenarios AS s
LEFT JOIN attempts AS a
    ON a.scenario_id = s.scenario_id
LEFT JOIN investigation_steps AS st
    ON st.attempt_id = a.attempt_id
GROUP BY s.scenario_id, s.title
ORDER BY attempt_count DESC, s.title;


-- ===========================================================================
-- 8. SAFE CRUD DEMONSTRATION
--
-- This transaction proves INSERT, UPDATE and DELETE while ending with ROLLBACK.
-- The original seed database is unchanged after the demonstration.
-- ===========================================================================

BEGIN TRANSACTION;

-- INSERT: create a temporary draft scenario owned by a reviewer.
INSERT INTO scenarios
    (created_by_user_id, title, difficulty, learning_goal, status)
SELECT
    user_id,
    'Temporary CRUD demonstration scenario',
    'beginner',
    'Demonstrate controlled insert update and delete operations without altering seed evidence.',
    'draft'
FROM users
WHERE email = 'theo.reviewer@firstcommit.local';

SELECT
    scenario_id,
    title,
    status
FROM scenarios
WHERE title = 'Temporary CRUD demonstration scenario';

-- UPDATE: change only the intended draft record and explicitly update its timestamp.
UPDATE scenarios
SET
    status = 'active',
    updated_at = CURRENT_TIMESTAMP
WHERE title = 'Temporary CRUD demonstration scenario'
  AND status = 'draft';

SELECT
    scenario_id,
    title,
    status,
    updated_at
FROM scenarios
WHERE title = 'Temporary CRUD demonstration scenario';

-- DELETE: remove only the temporary record and only if it has no learner attempts.
-- The WHERE clause plus NOT EXISTS prevents an unsafe broad delete.
DELETE FROM scenarios
WHERE title = 'Temporary CRUD demonstration scenario'
  AND NOT EXISTS (
      SELECT 1
      FROM attempts
      WHERE attempts.scenario_id = scenarios.scenario_id
  );

SELECT COUNT(*) AS temporary_scenario_remaining
FROM scenarios
WHERE title = 'Temporary CRUD demonstration scenario';

-- Return the database to its original seed state.
ROLLBACK;
