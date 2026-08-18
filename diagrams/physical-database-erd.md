# FirstCommit — Physical Database ERD

This ERD is the **Project 02 physical relational model**.

It carries forward the eight conceptual entities from Project 01 and adds implementation details required by a working database. The most visible refinement is `SCENARIOS.created_by_user_id`, which records the reviewer responsible for creating the scenario.

```mermaid
erDiagram
    USERS ||--o{ SCENARIOS : creates
    USERS ||--o{ ATTEMPTS : makes
    USERS ||--o{ FEEDBACK : writes

    SCENARIOS ||--o{ EVIDENCE_ITEMS : contains
    SCENARIOS ||--o{ CAUSE_OPTIONS : defines
    SCENARIOS ||--o{ ATTEMPTS : attempted_in

    ATTEMPTS ||--o{ INVESTIGATION_STEPS : records
    EVIDENCE_ITEMS ||--o{ INVESTIGATION_STEPS : referenced_by

    ATTEMPTS ||--o{ CAUSE_ASSESSMENTS : evaluates
    CAUSE_OPTIONS ||--o{ CAUSE_ASSESSMENTS : assessed_as

    ATTEMPTS ||--o{ FEEDBACK : receives

    USERS {
        INTEGER user_id PK
        TEXT display_name
        TEXT email UK
        TEXT role
        TEXT account_status
        TEXT created_at
    }

    SCENARIOS {
        INTEGER scenario_id PK
        INTEGER created_by_user_id FK
        TEXT title
        TEXT difficulty
        TEXT learning_goal
        TEXT status
        TEXT created_at
        TEXT updated_at
    }

    EVIDENCE_ITEMS {
        INTEGER evidence_id PK
        INTEGER scenario_id FK
        TEXT system_layer
        TEXT evidence_type
        TEXT content_reference
        INTEGER sequence_no
        TEXT created_at
    }

    ATTEMPTS {
        INTEGER attempt_id PK
        INTEGER user_id FK
        INTEGER scenario_id FK
        TEXT started_at
        TEXT completed_at
        TEXT status
        TEXT submitted_reasoning
    }

    INVESTIGATION_STEPS {
        INTEGER step_id PK
        INTEGER attempt_id FK
        INTEGER evidence_id FK
        INTEGER sequence_no
        TEXT action_taken
        TEXT observation
        TEXT reason_for_next_step
        TEXT created_at
    }

    CAUSE_OPTIONS {
        INTEGER cause_id PK
        INTEGER scenario_id FK
        TEXT description
        INTEGER is_root_cause
        TEXT created_at
    }

    CAUSE_ASSESSMENTS {
        INTEGER assessment_id PK
        INTEGER attempt_id FK
        INTEGER cause_id FK
        TEXT assessment_status
        TEXT reasoning
        TEXT assessed_at
    }

    FEEDBACK {
        INTEGER feedback_id PK
        INTEGER attempt_id FK
        INTEGER reviewer_id FK
        TEXT feedback_text
        TEXT created_at
    }
```
