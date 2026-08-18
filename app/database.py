from pathlib import Path
import sqlite3


# ---------------------------------------------------------
# FirstCommit Data Studio
# Project 02 — Database Design and Manipulation
#
# Controlled, read-only access to the validated SQLite
# database used by the local portfolio dashboard.
# ---------------------------------------------------------


BASE_DIR = Path(__file__).resolve().parent.parent
DATABASE_PATH = BASE_DIR / "database" / "firstcommit.db"


def get_connection() -> sqlite3.Connection:
    """Open the validated FirstCommit database in read-only mode."""
    if not DATABASE_PATH.exists():
        raise FileNotFoundError(
            f"FirstCommit database was not found at: {DATABASE_PATH}"
        )

    database_uri = f"{DATABASE_PATH.as_uri()}?mode=ro"
    connection = sqlite3.connect(database_uri, uri=True)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA query_only = ON;")
    return connection


def get_dashboard_metrics() -> sqlite3.Row:
    """Return the core database-derived metrics used by the dashboard."""
    query = """
        SELECT
            (SELECT COUNT(*) FROM scenarios WHERE status = 'active') AS active_scenarios,
            (SELECT COUNT(*) FROM evidence_items) AS evidence_items,
            (SELECT COUNT(*) FROM attempts) AS attempts,
            (SELECT COUNT(*) FROM investigation_steps) AS investigation_steps,
            (SELECT COUNT(*) FROM cause_assessments) AS cause_assessments,
            (SELECT COUNT(*) FROM feedback) AS feedback_records;
    """

    with get_connection() as connection:
        return connection.execute(query).fetchone()


def get_scenario_overview() -> list[sqlite3.Row]:
    """Return scenario, creator, evidence and attempt information."""
    query = """
        SELECT
            s.scenario_id,
            s.title,
            s.difficulty,
            s.status,
            u.display_name AS created_by,
            COUNT(DISTINCT e.evidence_id) AS evidence_count,
            COUNT(DISTINCT a.attempt_id) AS attempt_count
        FROM scenarios AS s
        JOIN users AS u
            ON u.user_id = s.created_by_user_id
        LEFT JOIN evidence_items AS e
            ON e.scenario_id = s.scenario_id
        LEFT JOIN attempts AS a
            ON a.scenario_id = s.scenario_id
        GROUP BY
            s.scenario_id,
            s.title,
            s.difficulty,
            s.status,
            u.display_name
        ORDER BY
            CASE s.difficulty
                WHEN 'beginner' THEN 1
                WHEN 'intermediate' THEN 2
                ELSE 3
            END,
            s.title;
    """

    with get_connection() as connection:
        return connection.execute(query).fetchall()


def get_attempt_overview() -> list[sqlite3.Row]:
    """Return the current learner-attempt overview for the dashboard."""
    query = """
        SELECT
            a.attempt_id,
            u.display_name AS learner,
            s.title AS scenario,
            a.status,
            a.started_at,
            a.completed_at
        FROM attempts AS a
        JOIN users AS u
            ON u.user_id = a.user_id
        JOIN scenarios AS s
            ON s.scenario_id = a.scenario_id
        ORDER BY a.started_at DESC;
    """

    with get_connection() as connection:
        return connection.execute(query).fetchall()


if __name__ == "__main__":
    metrics = get_dashboard_metrics()

    print("FirstCommit database connection: OK")
    print(f"Database: {DATABASE_PATH}")
    print(f"Active scenarios: {metrics['active_scenarios']}")
    print(f"Evidence items: {metrics['evidence_items']}")
    print(f"Attempts: {metrics['attempts']}")
    print(f"Investigation steps: {metrics['investigation_steps']}")
    print(f"Cause assessments: {metrics['cause_assessments']}")
    print(f"Feedback records: {metrics['feedback_records']}")
