from flask import Flask, render_template

from database import (
    get_attempt_overview,
    get_dashboard_metrics,
    get_scenario_overview,
)


app = Flask(__name__)


@app.route("/")
def index():
    """Render the read-only FirstCommit Data Studio dashboard."""
    return render_template(
        "index.html",
        metrics=get_dashboard_metrics(),
        scenarios=get_scenario_overview(),
        attempts=get_attempt_overview(),
    )
@app.route("/health")
def health():
    """
    Lightweight service health check.

    Used by the deployment platform to confirm that
    the Flask application process is responding.
    """
    return {
        "status": "ok",
        "service": "FirstCommit Data Studio",
    }, 200


@app.route("/ready")
def ready():
    """
    Readiness check for the application and SQLite data layer.

    This performs a real read-only database query before
    reporting that the service is ready.
    """
    try:
        metrics = get_dashboard_metrics()

        return {
            "status": "ready",
            "database": "ok",
            "active_scenarios": metrics["active_scenarios"],
        }, 200

    except Exception:
        return {
            "status": "not_ready",
            "database": "unavailable",
        }, 503

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)
