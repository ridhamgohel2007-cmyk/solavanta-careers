-- ==============================================================================
-- SOLAVANTA CAREERS — PRODUCTION DATABASE SCHEMA & HARDENED SECURITY
-- Phase 3 Security Remediation (Final Hardened Release)
-- Database Engine: PostgreSQL 15+ (Supabase)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. TABLE DEFINITIONS (WITH STRICT DATA INTEGRITY CONSTRAINTS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Table 1: profiles
-- Internal administrative staff accounts (recruiters & super administrators)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL CHECK (char_length(trim(full_name)) >= 2 AND char_length(full_name) <= 150),
    email TEXT NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    role TEXT NOT NULL DEFAULT 'recruiter' CHECK (role IN ('super_admin', 'recruiter')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now())
);

COMMENT ON TABLE public.profiles IS 'Internal staff and recruiter accounts mapped directly to auth.users.';

-- ------------------------------------------------------------------------------
-- Table 2: jobs
-- Career opportunities displayed on the public site and managed in admin
-- Note: Location has no hardcoded default; it must be explicitly defined per vacancy.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL CHECK (char_length(trim(title)) >= 3 AND char_length(title) <= 200),
    slug TEXT NOT NULL UNIQUE CHECK (slug ~* '^[a-z0-9]+(?:-[a-z0-9]+)*$' AND char_length(slug) <= 220),
    department TEXT NOT NULL CHECK (char_length(trim(department)) >= 2 AND char_length(department) <= 100),
    location TEXT NOT NULL CHECK (char_length(trim(location)) >= 2 AND char_length(location) <= 150),
    employment_type TEXT NOT NULL CHECK (employment_type IN ('Full-time', 'Part-time', 'Contract', 'Internship')),
    salary_range TEXT CHECK (salary_range IS NULL OR char_length(salary_range) <= 100),
    experience_level TEXT CHECK (experience_level IS NULL OR char_length(experience_level) <= 100),
    summary TEXT NOT NULL CHECK (char_length(trim(summary)) >= 10 AND char_length(summary) <= 500),
    description_markdown TEXT NOT NULL CHECK (char_length(trim(description_markdown)) >= 20),
    requirements_markdown TEXT NOT NULL CHECK (char_length(trim(requirements_markdown)) >= 20),
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now())
);

COMMENT ON TABLE public.jobs IS 'Public and internal career vacancies with status lifecycle.';

-- ------------------------------------------------------------------------------
-- Table 3: candidates
-- Normalized applicant identity registry (prevents duplicate profile drift)
-- Note: visa_status is optional (nullable) so domestic candidates are not forced into invalid fields.
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.candidates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL CHECK (char_length(trim(full_name)) >= 2 AND char_length(full_name) <= 150),
    email TEXT NOT NULL UNIQUE CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    phone TEXT NOT NULL CHECK (char_length(trim(phone)) >= 7 AND char_length(phone) <= 30),
    linkedin_url TEXT CHECK (linkedin_url IS NULL OR linkedin_url ~* '^https?://(www\.)?linkedin\.com/.*'),
    current_location TEXT CHECK (current_location IS NULL OR char_length(current_location) <= 150),
    visa_status TEXT CHECK (visa_status IS NULL OR char_length(visa_status) <= 100),
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now())
);

COMMENT ON TABLE public.candidates IS 'Protected applicant records with email format, length validation, and verification flag.';

-- ------------------------------------------------------------------------------
-- Table 4: applications
-- Connects a candidate to a job opening with resume path and recruitment status
-- Note: resume_storage_path format is canonical: <job_uuid>/<candidate_uuid>_<random_hex>.<pdf|docx>
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES public.jobs(id) ON DELETE RESTRICT,
    candidate_id UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    resume_storage_path TEXT NOT NULL CHECK (
        resume_storage_path ~* '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}_[a-zA-Z0-9_-]+\.(pdf|docx)$'
    ),
    cover_note TEXT CHECK (cover_note IS NULL OR char_length(cover_note) <= 3000),
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'reviewing', 'shortlisted', 'interviewing', 'rejected', 'hired')),
    internal_notes TEXT,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now()),
    CONSTRAINT uq_candidate_job UNIQUE (candidate_id, job_id)
);

COMMENT ON TABLE public.applications IS 'Candidate applications linked to vacancies with validated storage path regex.';

-- ------------------------------------------------------------------------------
-- Table 5: application_status_history
-- Immutable audit log tracking candidate progression through recruitment pipeline
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.application_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
    previous_status TEXT NOT NULL,
    new_status TEXT NOT NULL,
    changed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT CHECK (notes IS NULL OR char_length(notes) <= 1000),
    changed_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now())
);

COMMENT ON TABLE public.application_status_history IS 'Immutable audit log of all candidate status transitions.';

-- ------------------------------------------------------------------------------
-- Table 6: contact_messages
-- Public contact and consultation inquiries submitted across site pages
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.contact_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL CHECK (char_length(trim(name)) >= 2 AND char_length(name) <= 150),
    email TEXT NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    phone TEXT CHECK (phone IS NULL OR (char_length(trim(phone)) >= 7 AND char_length(phone) <= 30)),
    subject TEXT CHECK (subject IS NULL OR char_length(subject) <= 200),
    message TEXT NOT NULL CHECK (char_length(trim(message)) >= 5 AND char_length(message) <= 4000),
    source_page TEXT NOT NULL DEFAULT 'index' CHECK (source_page IN ('index', 'why-solvanta', 'placement-plan', 'refer-and-earn', 'hire-talent', 'resources', 'other')),
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'resolved')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT pg_catalog.timezone('utc'::text, pg_catalog.now()),
    resolved_at TIMESTAMPTZ
);

COMMENT ON TABLE public.contact_messages IS 'Public inquiries with input length, status lock, and email regex constraints.';

-- ==============================================================================
-- 3. PERFORMANCE INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_jobs_status_slug ON public.jobs(status, slug);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON public.jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_candidates_email ON public.candidates(email);
CREATE INDEX IF NOT EXISTS idx_applications_job_id ON public.applications(job_id);
CREATE INDEX IF NOT EXISTS idx_applications_candidate_id ON public.applications(candidate_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON public.applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_applied_at ON public.applications(applied_at DESC);
CREATE INDEX IF NOT EXISTS idx_status_history_app_id ON public.application_status_history(application_id);
CREATE INDEX IF NOT EXISTS idx_contact_messages_status ON public.contact_messages(status);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created_at ON public.contact_messages(created_at DESC);

-- ==============================================================================
-- 4. HARDENED DATABASE FUNCTIONS (EMPTY SEARCH_PATH & QUALIFIED IDENTIFIERS)
-- ==============================================================================

-- 4.1 Updated At Timestamp Trigger (Does NOT require SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = pg_catalog.timezone('utc'::text, pg_catalog.now());
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER update_profiles_modtime
    BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_jobs_modtime
    BEFORE UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_candidates_modtime
    BEFORE UPDATE ON public.candidates FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_applications_modtime
    BEFORE UPDATE ON public.applications FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 4.2 Status Audit Trigger (SECURITY DEFINER with empty search_path)
CREATE OR REPLACE FUNCTION public.log_application_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    IF (OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO public.application_status_history (
            application_id,
            previous_status,
            new_status,
            changed_by,
            notes
        ) VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            auth.uid(),
            'Status transition recorded via Solavanta admin portal'
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER track_application_status
    AFTER UPDATE OF status ON public.applications
    FOR EACH ROW EXECUTE FUNCTION public.log_application_status_change();

-- 4.3 Role Verification Helper Functions (Strictly for authenticated users)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid()
        AND role IN ('super_admin', 'recruiter')
    );
$$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid()
        AND role = 'super_admin'
    );
$$;

-- 4.4 Atomic Candidate Application Submission (RPC Endpoint)
-- REMEDIATED:
-- 1. Overwrite Protection: Does NOT overwrite existing candidate contact info on email conflict!
-- 2. Storage Existence Check: Verifies that the uploaded resume object genuinely exists in storage.objects.
-- 3. Duplicate Application Safety: Raises structured error without exposing candidate private details.
-- 4. Hardcoded Status: Forces status = 'new' and internal_notes = NULL.
CREATE OR REPLACE FUNCTION public.submit_candidate_application(
    p_job_id UUID,
    p_full_name TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_linkedin_url TEXT DEFAULT NULL,
    p_current_location TEXT DEFAULT NULL,
    p_visa_status TEXT DEFAULT NULL,
    p_resume_storage_path TEXT DEFAULT '',
    p_cover_note TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_candidate_id UUID;
    v_application_id UUID;
    v_job_status TEXT;
    v_clean_email TEXT;
    v_resume_exists BOOLEAN;
BEGIN
    v_clean_email := pg_catalog.lower(pg_catalog.trim(p_email));

    -- 1. Validate Target Job: must exist and be actively published
    SELECT status INTO v_job_status
    FROM public.jobs
    WHERE id = p_job_id;

    IF v_job_status IS NULL OR v_job_status != 'published' THEN
        RAISE EXCEPTION 'Target job vacancy is not currently open for applications.' USING ERRCODE = 'P0001';
    END IF;

    -- 2. Validate Canonical Resume Storage Path Format: <job_id>/<candidate_id>_<random>.<pdf|docx>
    IF p_resume_storage_path !~* '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}_[a-zA-Z0-9_-]+\.(pdf|docx)$' THEN
        RAISE EXCEPTION 'Invalid resume storage path format or unauthorized extension.' USING ERRCODE = 'P0002';
    END IF;

    -- 3. Verify Resume Object Actually Exists in storage.objects (Prevents forged/phantom paths)
    SELECT EXISTS (
        SELECT 1 FROM storage.objects
        WHERE bucket_id = 'resumes'
        AND name = p_resume_storage_path
    ) INTO v_resume_exists;

    IF NOT v_resume_exists THEN
        RAISE EXCEPTION 'Resume file was not found in private storage. Please re-upload your document.' USING ERRCODE = 'P0003';
    END IF;

    -- 4. Identity Protection: Look up existing candidate or create new one without overwriting!
    SELECT id INTO v_candidate_id
    FROM public.candidates
    WHERE email = v_clean_email;

    IF v_candidate_id IS NULL THEN
        -- New candidate: Insert full profile
        INSERT INTO public.candidates (
            full_name,
            email,
            phone,
            linkedin_url,
            current_location,
            visa_status,
            is_verified
        ) VALUES (
            pg_catalog.trim(p_full_name),
            v_clean_email,
            pg_catalog.trim(p_phone),
            pg_catalog.trim(p_linkedin_url),
            pg_catalog.trim(p_current_location),
            pg_catalog.trim(p_visa_status),
            false
        )
        RETURNING id INTO v_candidate_id;
    END IF;
    -- Note: If candidate already exists, we do NOT overwrite their verified phone or details.
    -- Profile updates require email-authenticated sessions in Phase 4.

    -- 5. Duplicate Application Check: Prevent duplicate submissions to the same job
    IF EXISTS (
        SELECT 1 FROM public.applications 
        WHERE candidate_id = v_candidate_id AND job_id = p_job_id
    ) THEN
        RAISE EXCEPTION 'An application for this position has already been submitted under this email.' USING ERRCODE = 'P0004';
    END IF;

    -- 6. Insert Application Record strictly with status = 'new' and internal_notes = NULL
    INSERT INTO public.applications (
        job_id,
        candidate_id,
        resume_storage_path,
        cover_note,
        status,
        internal_notes
    ) VALUES (
        p_job_id,
        v_candidate_id,
        p_resume_storage_path,
        pg_catalog.trim(p_cover_note),
        'new',
        NULL
    )
    RETURNING id INTO v_application_id;

    RETURN v_application_id;
END;
$$;

-- ==============================================================================
-- 5. PERMISSIONS & PRIVILEGE HARDENING
-- Explicitly revoke public defaults and grant minimal required privileges
-- ==============================================================================

-- Revoke all default privileges from public on all tables and functions
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

-- Grant execution of role checking strictly to authenticated users (never anon)
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;

-- Grant execution of application submission to anonymous and authenticated visitors
GRANT EXECUTE ON FUNCTION public.submit_candidate_application TO anon, authenticated;

-- Grant base table access needed for RLS policy enforcement
GRANT SELECT ON public.jobs TO anon, authenticated;
GRANT ALL ON public.jobs TO authenticated;

GRANT ALL ON public.profiles TO authenticated;

GRANT ALL ON public.candidates TO authenticated;

GRANT ALL ON public.applications TO authenticated;

GRANT SELECT ON public.application_status_history TO authenticated;

GRANT INSERT ON public.contact_messages TO anon, authenticated;
GRANT ALL ON public.contact_messages TO authenticated;

-- ==============================================================================
-- 6. ROW-LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 6.1 profiles policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Staff can view staff profiles"
    ON public.profiles FOR SELECT TO authenticated
    USING (public.is_admin());

CREATE POLICY "Super admins can manage staff profiles"
    ON public.profiles FOR ALL TO authenticated
    USING (public.is_super_admin())
    WITH CHECK (public.is_super_admin());

-- ------------------------------------------------------------------------------
-- 6.2 jobs policies
-- ------------------------------------------------------------------------------
CREATE POLICY "Public can view published jobs"
    ON public.jobs FOR SELECT TO anon, authenticated
    USING (status = 'published');

CREATE POLICY "Admins can view all jobs"
    ON public.jobs FOR SELECT TO authenticated
    USING (public.is_admin());

CREATE POLICY "Admins can manage jobs"
    ON public.jobs FOR ALL TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- 6.3 candidates policies
-- Zero direct public SELECT, INSERT, UPDATE, or DELETE access.
-- Candidate inserts occur strictly within submit_candidate_application.
-- ------------------------------------------------------------------------------
CREATE POLICY "Admins can view and manage candidates"
    ON public.candidates FOR ALL TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- 6.4 applications policies
-- Zero direct public SELECT, INSERT, UPDATE, or DELETE access.
-- Application inserts occur strictly within submit_candidate_application.
-- ------------------------------------------------------------------------------
CREATE POLICY "Admins can view and manage applications"
    ON public.applications FOR ALL TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- 6.5 application_status_history policies
-- Immutable audit log: Staff read-only; inserts handled by trigger only
-- ------------------------------------------------------------------------------
CREATE POLICY "Admins can view status history"
    ON public.application_status_history FOR SELECT TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- 6.6 contact_messages policies
-- Public can submit, but CANNOT set status to anything other than 'new', and CANNOT set resolved_at.
-- ------------------------------------------------------------------------------
CREATE POLICY "Public can submit contact messages"
    ON public.contact_messages FOR INSERT TO anon, authenticated
    WITH CHECK (
        status = 'new' 
        AND resolved_at IS NULL
    );

CREATE POLICY "Admins can view and manage contact messages"
    ON public.contact_messages FOR ALL TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ==============================================================================
-- 7. STORAGE BUCKET CONFIGURATION & POLICIES (Private Resumes)
-- Canonical Path Format: <job_uuid>/<candidate_uuid>_<random_hex>.<pdf|docx>
-- ==============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'resumes',
    'resumes',
    false, -- STRICTLY PRIVATE: No direct public access
    5242880, -- 5 MB limit
    ARRAY['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
)
ON CONFLICT (id) DO UPDATE SET
    public = false,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];

-- Policy: Restrict resume uploads strictly to the canonical path with approved extensions
CREATE POLICY "Public candidates can upload structured resume"
    ON storage.objects FOR INSERT TO anon, authenticated
    WITH CHECK (
        bucket_id = 'resumes'
        AND (LOWER(storage.extension(name)) IN ('pdf', 'docx'))
        AND (name ~* '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}_[a-zA-Z0-9_-]+\.(pdf|docx)$')
    );

-- Policy: Only authenticated staff can view/download resumes
CREATE POLICY "Admins can view uploaded resumes"
    ON storage.objects FOR SELECT TO authenticated
    USING (bucket_id = 'resumes' AND public.is_admin());

-- Policy: Super admins can delete/clean up resumes
CREATE POLICY "Admins can delete resumes"
    ON storage.objects FOR DELETE TO authenticated
    USING (bucket_id = 'resumes' AND public.is_admin());
