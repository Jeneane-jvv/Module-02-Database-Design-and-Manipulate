-- FirstCommit Data Layer — data-only SQLite export
-- Generated directly from database/firstcommit.db
-- Import into an EMPTY schema created from database/schema.sql.

PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

-- users (5 rows)
INSERT INTO users (user_id, display_name, email, role, account_status, created_at) VALUES (1, 'Maya Reviewer', 'maya.reviewer@firstcommit.local', 'reviewer', 'active', '2026-08-16 22:14:41');
INSERT INTO users (user_id, display_name, email, role, account_status, created_at) VALUES (2, 'Theo Reviewer', 'theo.reviewer@firstcommit.local', 'reviewer', 'active', '2026-08-16 22:14:41');
INSERT INTO users (user_id, display_name, email, role, account_status, created_at) VALUES (3, 'Lebo Learner', 'lebo.learner@firstcommit.local', 'learner', 'active', '2026-08-16 22:14:41');
INSERT INTO users (user_id, display_name, email, role, account_status, created_at) VALUES (4, 'Aisha Learner', 'aisha.learner@firstcommit.local', 'learner', 'active', '2026-08-16 22:14:41');
INSERT INTO users (user_id, display_name, email, role, account_status, created_at) VALUES (5, 'Daniel Learner', 'daniel.learner@firstcommit.local', 'learner', 'active', '2026-08-16 22:14:41');

-- scenarios (3 rows)
INSERT INTO scenarios (scenario_id, created_by_user_id, title, difficulty, learning_goal, status, created_at, updated_at) VALUES (1, 1, 'API authentication fails after deployment', 'intermediate', 'Trace authentication evidence systematically before changing application code.', 'active', '2026-08-16 22:14:41', '2026-08-16 22:14:41');
INSERT INTO scenarios (scenario_id, created_by_user_id, title, difficulty, learning_goal, status, created_at, updated_at) VALUES (2, 1, 'Dashboard loads but live data is missing', 'beginner', 'Separate interface rendering problems from API and data-source problems.', 'active', '2026-08-16 22:14:41', '2026-08-16 22:14:41');
INSERT INTO scenarios (scenario_id, created_by_user_id, title, difficulty, learning_goal, status, created_at, updated_at) VALUES (3, 2, 'Database write works locally but fails in integration', 'advanced', 'Follow database evidence from application request to relational-integrity failure.', 'active', '2026-08-16 22:14:41', '2026-08-16 22:14:41');

-- evidence_items (9 rows)
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (1, 1, 'Browser / HTTP', 'Network response', 'GET /api/profile returns HTTP 401 after deployment.', 1, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (2, 1, 'Deployment configuration', 'Environment comparison', 'Authentication audience differs between local and deployed environments.', 2, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (3, 1, 'Backend', 'Application log', 'Token validation log reports an audience mismatch.', 3, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (4, 2, 'Frontend', 'Browser console', 'Dashboard renders with no JavaScript error.', 1, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (5, 2, 'API', 'Network response', 'GET /api/scenarios returns HTTP 200 with an empty array.', 2, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (6, 2, 'Database', 'Query result', 'Active scenario rows exist in the database.', 3, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (7, 3, 'Application', 'Error log', 'Insert request reaches the database but the transaction is rolled back.', 1, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (8, 3, 'Database', 'Constraint error', 'Foreign key constraint fails for the referenced scenario identifier.', 2, '2026-08-16 22:14:41');
INSERT INTO evidence_items (evidence_id, scenario_id, system_layer, evidence_type, content_reference, sequence_no, created_at) VALUES (9, 3, 'Integration data', 'Reference check', 'The scenario identifier used by the request does not exist in the integration database.', 3, '2026-08-16 22:14:41');

-- cause_options (12 rows)
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (1, 1, 'Expired authentication token', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (2, 1, 'Incorrect deployed API URL', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (3, 1, 'Authentication audience configuration mismatch', 1, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (4, 1, 'Database service unavailable', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (5, 2, 'Dashboard CSS hides the records', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (6, 2, 'Frontend state never receives the API result', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (7, 2, 'API status filter excludes the active records', 1, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (8, 2, 'Database service is offline', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (9, 3, 'Integration database has a missing parent record', 1, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (10, 3, 'Network connection times out', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (11, 3, 'Database connection is read-only', 0, '2026-08-16 22:14:41');
INSERT INTO cause_options (cause_id, scenario_id, description, is_root_cause, created_at) VALUES (12, 3, 'Insert statement contains malformed SQL', 0, '2026-08-16 22:14:41');

-- attempts (3 rows)
INSERT INTO attempts (attempt_id, user_id, scenario_id, started_at, completed_at, status, submitted_reasoning) VALUES (1, 3, 1, '2026-08-12 09:10:00', '2026-08-12 09:48:00', 'reviewed', 'The deployed authentication audience does not match the audience expected by token validation.');
INSERT INTO attempts (attempt_id, user_id, scenario_id, started_at, completed_at, status, submitted_reasoning) VALUES (2, 4, 2, '2026-08-13 13:20:00', '2026-08-13 13:55:00', 'submitted', 'The interface and database are healthy; the API filter excludes records that should be returned.');
INSERT INTO attempts (attempt_id, user_id, scenario_id, started_at, completed_at, status, submitted_reasoning) VALUES (3, 5, 3, '2026-08-14 15:05:00', NULL, 'in_progress', NULL);

-- investigation_steps (8 rows)
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (1, 1, 1, 1, 'Inspect the failing network request', 'The deployed profile request returns HTTP 401.', 'A 401 points to authentication before database behaviour, so inspect authentication configuration next.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (2, 1, 2, 2, 'Compare local and deployed authentication settings', 'The configured audience differs between the two environments.', 'The configuration difference is a candidate cause; inspect backend validation logs for confirming evidence.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (3, 1, 3, 3, 'Inspect token validation logs', 'The backend explicitly reports an authentication audience mismatch.', 'The log confirms the configuration mismatch and supports the final reasoning.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (4, 2, 4, 1, 'Check the browser console', 'The dashboard renders without a JavaScript error.', 'The visible page is healthy enough to inspect the data request next.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (5, 2, 5, 2, 'Inspect the scenarios API response', 'The request succeeds but returns an empty list.', 'Because transport works, compare the API result with the records stored in the database.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (6, 2, 6, 3, 'Compare the API result with database rows', 'Active scenario records exist even though the API returns none.', 'The mismatch supports investigating API-side filtering rather than the frontend or database service.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (7, 3, 7, 1, 'Inspect the integration insert error', 'The request reaches the database but the transaction rolls back.', 'Inspect the database error to determine whether the failure is connection, syntax or integrity related.', '2026-08-16 22:14:41');
INSERT INTO investigation_steps (step_id, attempt_id, evidence_id, sequence_no, action_taken, observation, reason_for_next_step, created_at) VALUES (8, 3, 8, 2, 'Inspect the database constraint message', 'The database reports a foreign key constraint failure.', 'Check whether the parent identifier exists in the integration dataset before changing the SQL.', '2026-08-16 22:14:41');

-- cause_assessments (6 rows)
INSERT INTO cause_assessments (assessment_id, attempt_id, cause_id, assessment_status, reasoning, assessed_at) VALUES (1, 1, 1, 'eliminated', 'The token is current and works in the local environment.', '2026-08-16 22:14:41');
INSERT INTO cause_assessments (assessment_id, attempt_id, cause_id, assessment_status, reasoning, assessed_at) VALUES (2, 1, 3, 'supported', 'Configuration and backend log evidence both point to the same audience mismatch.', '2026-08-16 22:14:41');
INSERT INTO cause_assessments (assessment_id, attempt_id, cause_id, assessment_status, reasoning, assessed_at) VALUES (3, 1, 4, 'eliminated', 'The request reaches the backend and fails before database access is relevant.', '2026-08-16 22:14:41');
INSERT INTO cause_assessments (assessment_id, attempt_id, cause_id, assessment_status, reasoning, assessed_at) VALUES (4, 2, 5, 'eliminated', 'The dashboard is visible and there is no console evidence of a rendering failure.', '2026-08-16 22:14:41');
INSERT INTO cause_assessments (assessment_id, attempt_id, cause_id, assessment_status, reasoning, assessed_at) VALUES (5, 2, 7, 'supported', 'The database contains active rows while the API returns an empty result set.', '2026-08-16 22:14:41');
INSERT INTO cause_assessments (assessment_id, attempt_id, cause_id, assessment_status, reasoning, assessed_at) VALUES (6, 3, 9, 'considering', 'The foreign key error makes missing parent data the strongest current hypothesis.', '2026-08-16 22:14:41');

-- feedback (1 rows)
INSERT INTO feedback (feedback_id, attempt_id, reviewer_id, feedback_text, created_at) VALUES (1, 1, 1, 'Strong evidence chain. You eliminated unrelated database behaviour before changing authentication code.', '2026-08-12 10:05:00');

COMMIT;
