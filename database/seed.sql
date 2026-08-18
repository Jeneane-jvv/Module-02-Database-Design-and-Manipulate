-- FirstCommit Data Layer
-- Project 02 — Seed data
--
-- All names, email addresses and scenario records below are fictional demonstration data.
-- Seed data exists so the database can be queried and the later Data Studio UI can show
-- meaningful relationships immediately after setup.

PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- ---------------------------------------------------------------------------
-- USERS
-- ---------------------------------------------------------------------------

INSERT INTO users (display_name, email, role, account_status) VALUES
('Maya Reviewer',  'maya.reviewer@firstcommit.local',  'reviewer', 'active'),
('Theo Reviewer',  'theo.reviewer@firstcommit.local',  'reviewer', 'active'),
('Lebo Learner',   'lebo.learner@firstcommit.local',   'learner',  'active'),
('Aisha Learner',  'aisha.learner@firstcommit.local',  'learner',  'active'),
('Daniel Learner', 'daniel.learner@firstcommit.local', 'learner',  'active');

-- ---------------------------------------------------------------------------
-- SCENARIOS
-- ---------------------------------------------------------------------------

INSERT INTO scenarios
    (created_by_user_id, title, difficulty, learning_goal, status)
SELECT
    user_id,
    'API authentication fails after deployment',
    'intermediate',
    'Trace authentication evidence systematically before changing application code.',
    'active'
FROM users
WHERE email = 'maya.reviewer@firstcommit.local';

INSERT INTO scenarios
    (created_by_user_id, title, difficulty, learning_goal, status)
SELECT
    user_id,
    'Dashboard loads but live data is missing',
    'beginner',
    'Separate interface rendering problems from API and data-source problems.',
    'active'
FROM users
WHERE email = 'maya.reviewer@firstcommit.local';

INSERT INTO scenarios
    (created_by_user_id, title, difficulty, learning_goal, status)
SELECT
    user_id,
    'Database write works locally but fails in integration',
    'advanced',
    'Follow database evidence from application request to relational-integrity failure.',
    'active'
FROM users
WHERE email = 'theo.reviewer@firstcommit.local';

-- ---------------------------------------------------------------------------
-- EVIDENCE ITEMS
-- ---------------------------------------------------------------------------

-- Scenario 1
INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Browser / HTTP', 'Network response',
       'GET /api/profile returns HTTP 401 after deployment.', 1
FROM scenarios
WHERE title = 'API authentication fails after deployment';

INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Deployment configuration', 'Environment comparison',
       'Authentication audience differs between local and deployed environments.', 2
FROM scenarios
WHERE title = 'API authentication fails after deployment';

INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Backend', 'Application log',
       'Token validation log reports an audience mismatch.', 3
FROM scenarios
WHERE title = 'API authentication fails after deployment';

-- Scenario 2
INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Frontend', 'Browser console',
       'Dashboard renders with no JavaScript error.', 1
FROM scenarios
WHERE title = 'Dashboard loads but live data is missing';

INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'API', 'Network response',
       'GET /api/scenarios returns HTTP 200 with an empty array.', 2
FROM scenarios
WHERE title = 'Dashboard loads but live data is missing';

INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Database', 'Query result',
       'Active scenario rows exist in the database.', 3
FROM scenarios
WHERE title = 'Dashboard loads but live data is missing';

-- Scenario 3
INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Application', 'Error log',
       'Insert request reaches the database but the transaction is rolled back.', 1
FROM scenarios
WHERE title = 'Database write works locally but fails in integration';

INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Database', 'Constraint error',
       'Foreign key constraint fails for the referenced scenario identifier.', 2
FROM scenarios
WHERE title = 'Database write works locally but fails in integration';

INSERT INTO evidence_items
    (scenario_id, system_layer, evidence_type, content_reference, sequence_no)
SELECT scenario_id, 'Integration data', 'Reference check',
       'The scenario identifier used by the request does not exist in the integration database.', 3
FROM scenarios
WHERE title = 'Database write works locally but fails in integration';

-- ---------------------------------------------------------------------------
-- CAUSE OPTIONS
-- ---------------------------------------------------------------------------

-- Scenario 1
INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Expired authentication token', 0
FROM scenarios WHERE title = 'API authentication fails after deployment';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Incorrect deployed API URL', 0
FROM scenarios WHERE title = 'API authentication fails after deployment';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Authentication audience configuration mismatch', 1
FROM scenarios WHERE title = 'API authentication fails after deployment';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Database service unavailable', 0
FROM scenarios WHERE title = 'API authentication fails after deployment';

-- Scenario 2
INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Dashboard CSS hides the records', 0
FROM scenarios WHERE title = 'Dashboard loads but live data is missing';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Frontend state never receives the API result', 0
FROM scenarios WHERE title = 'Dashboard loads but live data is missing';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'API status filter excludes the active records', 1
FROM scenarios WHERE title = 'Dashboard loads but live data is missing';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Database service is offline', 0
FROM scenarios WHERE title = 'Dashboard loads but live data is missing';

-- Scenario 3
INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Integration database has a missing parent record', 1
FROM scenarios WHERE title = 'Database write works locally but fails in integration';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Network connection times out', 0
FROM scenarios WHERE title = 'Database write works locally but fails in integration';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Database connection is read-only', 0
FROM scenarios WHERE title = 'Database write works locally but fails in integration';

INSERT INTO cause_options (scenario_id, description, is_root_cause)
SELECT scenario_id, 'Insert statement contains malformed SQL', 0
FROM scenarios WHERE title = 'Database write works locally but fails in integration';

-- ---------------------------------------------------------------------------
-- ATTEMPTS
-- ---------------------------------------------------------------------------

-- Reviewed attempt for Scenario 1
INSERT INTO attempts
    (user_id, scenario_id, started_at, completed_at, status, submitted_reasoning)
SELECT
    u.user_id,
    s.scenario_id,
    '2026-08-12 09:10:00',
    '2026-08-12 09:48:00',
    'reviewed',
    'The deployed authentication audience does not match the audience expected by token validation.'
FROM users u
JOIN scenarios s
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment';

-- Submitted attempt for Scenario 2
INSERT INTO attempts
    (user_id, scenario_id, started_at, completed_at, status, submitted_reasoning)
SELECT
    u.user_id,
    s.scenario_id,
    '2026-08-13 13:20:00',
    '2026-08-13 13:55:00',
    'submitted',
    'The interface and database are healthy; the API filter excludes records that should be returned.'
FROM users u
JOIN scenarios s
WHERE u.email = 'aisha.learner@firstcommit.local'
  AND s.title = 'Dashboard loads but live data is missing';

-- In-progress attempt for Scenario 3
INSERT INTO attempts
    (user_id, scenario_id, started_at, status)
SELECT
    u.user_id,
    s.scenario_id,
    '2026-08-14 15:05:00',
    'in_progress'
FROM users u
JOIN scenarios s
WHERE u.email = 'daniel.learner@firstcommit.local'
  AND s.title = 'Database write works locally but fails in integration';

-- ---------------------------------------------------------------------------
-- INVESTIGATION STEPS
-- ---------------------------------------------------------------------------

-- Lebo / Scenario 1
INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 1,
    'Inspect the failing network request',
    'The deployed profile request returns HTTP 401.',
    'A 401 points to authentication before database behaviour, so inspect authentication configuration next.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 1
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment';

INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 2,
    'Compare local and deployed authentication settings',
    'The configured audience differs between the two environments.',
    'The configuration difference is a candidate cause; inspect backend validation logs for confirming evidence.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 2
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment';

INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 3,
    'Inspect token validation logs',
    'The backend explicitly reports an authentication audience mismatch.',
    'The log confirms the configuration mismatch and supports the final reasoning.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 3
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment';

-- Aisha / Scenario 2
INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 1,
    'Check the browser console',
    'The dashboard renders without a JavaScript error.',
    'The visible page is healthy enough to inspect the data request next.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 1
WHERE u.email = 'aisha.learner@firstcommit.local'
  AND s.title = 'Dashboard loads but live data is missing';

INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 2,
    'Inspect the scenarios API response',
    'The request succeeds but returns an empty list.',
    'Because transport works, compare the API result with the records stored in the database.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 2
WHERE u.email = 'aisha.learner@firstcommit.local'
  AND s.title = 'Dashboard loads but live data is missing';

INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 3,
    'Compare the API result with database rows',
    'Active scenario records exist even though the API returns none.',
    'The mismatch supports investigating API-side filtering rather than the frontend or database service.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 3
WHERE u.email = 'aisha.learner@firstcommit.local'
  AND s.title = 'Dashboard loads but live data is missing';

-- Daniel / Scenario 3 (still in progress)
INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 1,
    'Inspect the integration insert error',
    'The request reaches the database but the transaction rolls back.',
    'Inspect the database error to determine whether the failure is connection, syntax or integrity related.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 1
WHERE u.email = 'daniel.learner@firstcommit.local'
  AND s.title = 'Database write works locally but fails in integration';

INSERT INTO investigation_steps
    (attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step)
SELECT
    a.attempt_id, e.evidence_id, 2,
    'Inspect the database constraint message',
    'The database reports a foreign key constraint failure.',
    'Check whether the parent identifier exists in the integration dataset before changing the SQL.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN evidence_items e ON e.scenario_id = s.scenario_id AND e.sequence_no = 2
WHERE u.email = 'daniel.learner@firstcommit.local'
  AND s.title = 'Database write works locally but fails in integration';

-- ---------------------------------------------------------------------------
-- CAUSE ASSESSMENTS
-- ---------------------------------------------------------------------------

-- Lebo
INSERT INTO cause_assessments (attempt_id, cause_id, assessment_status, reasoning)
SELECT a.attempt_id, c.cause_id, 'eliminated',
       'The token is current and works in the local environment.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN cause_options c ON c.scenario_id = s.scenario_id
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment'
  AND c.description = 'Expired authentication token';

INSERT INTO cause_assessments (attempt_id, cause_id, assessment_status, reasoning)
SELECT a.attempt_id, c.cause_id, 'supported',
       'Configuration and backend log evidence both point to the same audience mismatch.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN cause_options c ON c.scenario_id = s.scenario_id
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment'
  AND c.description = 'Authentication audience configuration mismatch';

INSERT INTO cause_assessments (attempt_id, cause_id, assessment_status, reasoning)
SELECT a.attempt_id, c.cause_id, 'eliminated',
       'The request reaches the backend and fails before database access is relevant.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN cause_options c ON c.scenario_id = s.scenario_id
WHERE u.email = 'lebo.learner@firstcommit.local'
  AND s.title = 'API authentication fails after deployment'
  AND c.description = 'Database service unavailable';

-- Aisha
INSERT INTO cause_assessments (attempt_id, cause_id, assessment_status, reasoning)
SELECT a.attempt_id, c.cause_id, 'eliminated',
       'The dashboard is visible and there is no console evidence of a rendering failure.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN cause_options c ON c.scenario_id = s.scenario_id
WHERE u.email = 'aisha.learner@firstcommit.local'
  AND s.title = 'Dashboard loads but live data is missing'
  AND c.description = 'Dashboard CSS hides the records';

INSERT INTO cause_assessments (attempt_id, cause_id, assessment_status, reasoning)
SELECT a.attempt_id, c.cause_id, 'supported',
       'The database contains active rows while the API returns an empty result set.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN cause_options c ON c.scenario_id = s.scenario_id
WHERE u.email = 'aisha.learner@firstcommit.local'
  AND s.title = 'Dashboard loads but live data is missing'
  AND c.description = 'API status filter excludes the active records';

-- Daniel
INSERT INTO cause_assessments (attempt_id, cause_id, assessment_status, reasoning)
SELECT a.attempt_id, c.cause_id, 'considering',
       'The foreign key error makes missing parent data the strongest current hypothesis.'
FROM attempts a
JOIN users u ON u.user_id = a.user_id
JOIN scenarios s ON s.scenario_id = a.scenario_id
JOIN cause_options c ON c.scenario_id = s.scenario_id
WHERE u.email = 'daniel.learner@firstcommit.local'
  AND s.title = 'Database write works locally but fails in integration'
  AND c.description = 'Integration database has a missing parent record';

-- ---------------------------------------------------------------------------
-- FEEDBACK
-- ---------------------------------------------------------------------------

INSERT INTO feedback (attempt_id, reviewer_id, feedback_text, created_at)
SELECT
    a.attempt_id,
    r.user_id,
    'Strong evidence chain. You eliminated unrelated database behaviour before changing authentication code.',
    '2026-08-12 10:05:00'
FROM attempts a
JOIN users l ON l.user_id = a.user_id
JOIN users r ON r.email = 'maya.reviewer@firstcommit.local'
WHERE l.email = 'lebo.learner@firstcommit.local';

COMMIT;
