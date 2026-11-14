# Database Schema & Data Architecture — Solavanta Careers

## 1. Overview
The Solavanta Careers platform utilizes a **normalized, hardened PostgreSQL database** hosted via Supabase.

All tables are strictly protected by **PostgreSQL Row-Level Security (RLS)** and atomic Remote Procedure Calls (RPCs):
- Public visitors can submit contact inquiries and job applications through hardened validation gates.
- Public visitors cannot read any candidate applications, resumes, or internal evaluation notes.
- Only authenticated users with an authorized `admin` or `recruiter` role can view applications, update statuses, manage vacancies, and download candidate resumes.

---

## 2. Entity-Relationship Diagram

```mermaid
erDiagram
    PROFILES ||--o{ APPLICATIONS : "reviews"
    PROFILES ||--o{ JOBS : "creates/manages"
    JOBS ||--o{ APPLICATIONS : "contains"
    CANDIDATES ||--o{ APPLICATIONS : "submits"
    APPLICATIONS ||--o{ APPLICATION_STATUS_HISTORY : "tracks"
    
    PROFILES {
        uuid id PK "References auth.users.id"
        text full_name
        text email UK
        text role "super_admin or recruiter"
        timestamp created_at
        timestamp updated_at
    }

    JOBS {
        uuid id PK
        text title
        text slug UK
        text department
        text location "Explicit (no hardcoded default)"
        text employment_type
        text salary_range
        text experience_level
        text summary
        text description_markdown
        text requirements_markdown
        text status "published, draft, archived"
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }

    CANDIDATES {
        uuid id PK
        text full_name
        text email UK
        text phone
        text linkedin_url
        text current_location
        text visa_status "Nullable (optional)"
        timestamp created_at
        timestamp updated_at
    }

    APPLICATIONS {
        uuid id PK
        uuid job_id FK
        uuid candidate_id FK
        text resume_storage_path "Path matching regex pattern"
        text cover_note
        text status "new, reviewing, shortlisted, interviewing, rejected, hired"
        text internal_notes "Staff only (NULL on insert)"
        timestamp applied_at
        timestamp updated_at
    }

    APPLICATION_STATUS_HISTORY {
        uuid id PK
        uuid application_id FK
        text previous_status
        text new_status
        uuid changed_by FK
        text notes
        timestamp changed_at
    }

    CONTACT_MESSAGES {
        uuid id PK
        text name
        text email
        text phone
        text subject
        text message
        text source_page
        text status "new, contacted, resolved"
        timestamp created_at
        timestamp resolved_at
    }
```

---

## 3. Data Integrity & Validation Constraints

To prevent malformed or malicious data injection, every column has strict database-level check constraints:
* **Email Constraints**: `email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'` prevents invalid email syntax.
* **String Bounds**: `char_length(name) BETWEEN 2 AND 150`, `char_length(message) BETWEEN 5 AND 4000` prevents database buffer bloat.
* **Slug Constraints**: `slug ~* '^[a-z0-9]+(?:-[a-z0-9]+)*$'` guarantees clean URL slugs for search engine optimization.
* **Resume Path Regex**: `resume_storage_path ~* '^resumes/[a-f0-9-]+/[a-f0-9-]+_[a-zA-Z0-9_-]+\.(pdf|docx)$'` ensures resumes strictly follow structured, non-arbitrary paths.

---

## 4. Application Submission via Atomic Stored Procedure (`submit_candidate_application`)
Rather than relying on uncoordinated direct client `INSERT` calls, applications are processed atomically in a single PostgreSQL transaction:
1. Verifies that the specified `job_id` exists and is actively `published`.
2. Verifies that the resume path matches the approved bucket format.
3. Inserts or finds the candidate by unique email.
4. Enforces that the candidate has not already applied for this specific job (`uq_candidate_job`).
5. Inserts the application strictly with `status = 'new'` and `internal_notes = NULL`.

Anonymous users have zero direct `INSERT` permissions on `candidates` or `applications` tables, rendering client-side tampering impossible.
