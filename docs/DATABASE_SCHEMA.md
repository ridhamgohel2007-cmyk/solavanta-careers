# Database Schema & Data Architecture — Solavanta Careers

## 1. Overview
The Solavanta Careers platform utilizes a **normalized, hardened PostgreSQL database** hosted via Supabase.

All tables are strictly protected by **PostgreSQL Row-Level Security (RLS)**, explicit privilege revocations, and atomic Remote Procedure Calls (RPCs):
- Public visitors submit contact inquiries and job applications through hardened validation gates.
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
        boolean is_verified "Email verification flag"
        timestamp created_at
        timestamp updated_at
    }

    APPLICATIONS {
        uuid id PK
        uuid job_id FK
        uuid candidate_id FK
        text resume_storage_path "Canonical format: job_id/candidate_id_random.ext"
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

## 3. Canonical Storage Path Symmetrical Definition

To eliminate path drift, the resume storage path is canonically defined relative to the private `resumes` bucket:

$$\text{Canonical Path Format} = \underbrace{\text{job\_uuid}}_{36\text{ chars}} \,/\, \underbrace{\text{candidate\_uuid}}_{36\text{ chars}} \text{\_} \underbrace{\text{random\_hex}}_{\text{unique}} \text{.} \underbrace{\text{(pdf}|\text{docx)}}_{\text{extension}}$$

* **Database Constraint** on `applications.resume_storage_path`:
  `CHECK (resume_storage_path ~* '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}_[a-zA-Z0-9_-]+\.(pdf|docx)$')`
* **Storage RLS Policy** on `storage.objects.name`:
  `CHECK (bucket_id = 'resumes' AND name ~* '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}_[a-zA-Z0-9_-]+\.(pdf|docx)$')`
* **Stored Procedure Verification**:
  Inside `submit_candidate_application`, before inserting the application, the procedure verifies:
  `SELECT EXISTS (SELECT 1 FROM storage.objects WHERE bucket_id = 'resumes' AND name = p_resume_storage_path)`
  If the file was not genuinely uploaded, the application is rejected immediately.

---

## 4. Candidate Identity Protection Workflow

1. **No Anonymous Overwrites**: When an application is submitted, if a candidate with the supplied email already exists:
   - The system attaches the application to that existing candidate ID.
   - The existing candidate's phone, name, and profile details **remain unchanged**.
   - Anonymous visitors cannot alter another candidate's personal contact record.
2. **Duplicate Prevention**: If the candidate has already applied to that exact job vacancy, the database raises an error (`P0004`) preventing duplicate submissions.
3. **Profile Modification**: Updating personal contact records will require candidate email authentication (OTP / Magic Link) in Phase 4.
