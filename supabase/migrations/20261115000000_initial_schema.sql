-- ==============================================================================
-- SOLAVANTA CAREERS — PRODUCTION DATABASE SCHEMA & SECURITY POLICIES
-- Phase 3: Initial Normalized Schema Migration
-- Database Engine: PostgreSQL 15+ (Supabase)
-- ==============================================================================

-- 1. EXTENSIONS
-- Ensure cryptographic UUID generation is available
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. TABLE DEFINITIONS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Table 1: profiles
-- Extends Supabase auth.users for internal administrative staff (recruiters & admins)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL DEFAULT 'recruiter' CHECK (role IN ('super_admin', 'recruiter')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

COMMENT ON TABLE public.profiles IS 'Internal staff and recruiter accounts mapped to Supabase Auth.';

-- ------------------------------------------------------------------------------
-- Table 2: jobs
-- Stores published, draft, and archived job listings displayed on the public site
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    department TEXT NOT NULL,
    location TEXT NOT NULL DEFAULT 'London, UK (Hybrid)',
    employment_type TEXT NOT NULL DEFAULT 'Full-time' CHECK (employment_type IN ('Full-time', 'Part-time', 'Contract', 'Internship')),
    salary_range TEXT,
    experience_level TEXT,
    summary TEXT NOT NULL,
    description_markdown TEXT NOT NULL,
    requirements_markdown TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

COMMENT ON TABLE public.jobs IS 'Public and internal career opportunities with full descriptions and status.';

-- ------------------------------------------------------------------------------
-- Table 3: candidates
-- Central applicant identity table (prevents duplicated records across applications)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.candidates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    linkedin_url TEXT,
    current_location TEXT,
    visa_status TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

COMMENT ON TABLE public.candidates IS 'Protected candidate contact records and demographic info.';

-- ------------------------------------------------------------------------------
-- Table 4: applications
-- Connects a candidate to a specific job opening with resume storage reference
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES public.jobs(id) ON DELETE RESTRICT,
    candidate_id UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    resume_storage_path TEXT NOT NULL,
    cover_note TEXT,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'reviewing', 'shortlisted', 'interviewing', 'rejected', 'hired')),
    internal_notes TEXT,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT uq_candidate_job UNIQUE (candidate_id, job_id)
);

COMMENT ON TABLE public.applications IS 'Candidate applications tied to specific vacancies with workflow status.';

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
    notes TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

COMMENT ON TABLE public.application_status_history IS 'Immutable audit log of all candidate status transitions.';

-- ------------------------------------------------------------------------------
-- Table 6: contact_messages
-- Unified inbox for inquiries across all 7 pages (General, Hire, Referral, etc.)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.contact_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    subject TEXT,
    message TEXT NOT NULL,
    source_page TEXT NOT NULL DEFAULT 'index' CHECK (source_page IN ('index', 'why-solvanta', 'placement-plan', 'refer-and-earn', 'hire-talent', 'resources', 'other')),
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'resolved')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    resolved_at TIMESTAMPTZ
);

COMMENT ON TABLE public.contact_messages IS 'Public contact and consultation requests submitted from all site forms.';

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
-- 4. AUTOMATIC TIMESTAMP UPDATE TRIGGER
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_profiles_modtime
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_jobs_modtime
    BEFORE UPDATE ON public.jobs
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_candidates_modtime
    BEFORE UPDATE ON public.candidates
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE OR REPLACE TRIGGER update_applications_modtime
    BEFORE UPDATE ON public.applications
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 5. AUTOMATIC APPLICATION STATUS AUDIT TRIGGER
-- Automatically records a log in application_status_history when status changes
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.log_application_status_change()
RETURNS TRIGGER AS $$
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
            'Status updated via Solavanta admin portal'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER track_application_status
    AFTER UPDATE OF status ON public.applications
    FOR EACH ROW EXECUTE FUNCTION public.log_application_status_change();

-- ==============================================================================
-- 6. SECURITY: HELPER FUNCTION FOR ROLE-BASED ACCESS
-- Fast, cached security definer function to verify administrative authorization
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid()
        AND role IN ('super_admin', 'recruiter')
    );
$$;

-- ==============================================================================
-- 7. SECURITY: ROW-LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on every single table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.application_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- Policies for: profiles
-- ------------------------------------------------------------------------------
-- Authenticated users can view their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

-- Admins can view all staff profiles
CREATE POLICY "Admins can view all profiles"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (public.is_admin());

-- Only super_admins can insert or update staff profiles
CREATE POLICY "Super admins can manage profiles"
    ON public.profiles FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'super_admin'
        )
    );

-- ------------------------------------------------------------------------------
-- Policies for: jobs
-- ------------------------------------------------------------------------------
-- The public (visitors) can ONLY view published jobs
CREATE POLICY "Public can view published jobs"
    ON public.jobs FOR SELECT
    TO anon, authenticated
    USING (status = 'published');

-- Admins can view ALL jobs (including drafts and archived)
CREATE POLICY "Admins can view all jobs"
    ON public.jobs FOR SELECT
    TO authenticated
    USING (public.is_admin());

-- Admins can create, update, and manage jobs
CREATE POLICY "Admins can manage jobs"
    ON public.jobs FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- Policies for: candidates
-- ------------------------------------------------------------------------------
-- Public visitors can register as a candidate during application
CREATE POLICY "Public can register as candidate"
    ON public.candidates FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Candidates cannot be viewed by the public; only by authorized staff
CREATE POLICY "Admins can view and manage candidates"
    ON public.candidates FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- Policies for: applications
-- ------------------------------------------------------------------------------
-- Public job seekers can submit an application
CREATE POLICY "Public can submit applications"
    ON public.applications FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Applications can only be viewed and reviewed by authorized staff
CREATE POLICY "Admins can view and manage applications"
    ON public.applications FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ------------------------------------------------------------------------------
-- Policies for: application_status_history
-- ------------------------------------------------------------------------------
-- Audit logs are strictly viewable by authorized staff
CREATE POLICY "Admins can view status history"
    ON public.application_status_history FOR SELECT
    TO authenticated
    USING (public.is_admin());

-- ------------------------------------------------------------------------------
-- Policies for: contact_messages
-- ------------------------------------------------------------------------------
-- Any visitor can submit a contact message
CREATE POLICY "Public can submit contact messages"
    ON public.contact_messages FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Only authorized staff can read and manage customer inquiries
CREATE POLICY "Admins can view and manage contact messages"
    ON public.contact_messages FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- ==============================================================================
-- 8. STORAGE BUCKET CONFIGURATION (Resumes)
-- Creates the private 'resumes' bucket and configures security policies
-- ==============================================================================

-- Create private bucket for resumes if storage schema exists
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'resumes',
    'resumes',
    false, -- STRICTLY PRIVATE: No direct public access
    5242880, -- 5 MB max file size
    ARRAY['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
)
ON CONFLICT (id) DO UPDATE SET
    public = false,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['application/pdf', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];

-- Policy: Anyone (job applicant) can upload a resume to the resumes bucket
CREATE POLICY "Public candidates can upload resumes"
    ON storage.objects FOR INSERT
    TO anon, authenticated
    WITH CHECK (bucket_id = 'resumes');

-- Policy: Only authenticated staff can view/download resumes
CREATE POLICY "Admins can view uploaded resumes"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (bucket_id = 'resumes' AND public.is_admin());
