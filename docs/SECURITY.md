# Security Architecture & Data Protection — Solavanta Careers

## 1. Security Philosophy & Threat Model
Solavanta Careers is a commercial career placement platform handling candidate identities, CVs, telephone numbers, and employment histories.

Our security model follows the **Principle of Defense in Depth**:
* **Database Layer**: Hardened Row-Level Security (RLS) policies, atomic stored procedures with explicit empty `search_path = ''` and fully-qualified identifiers, and column check constraints.
* **Storage Layer**: A strictly private storage bucket (`resumes`) rejecting arbitrary file paths, enforcing 5MB size limits, and permitting only `.pdf` and `.docx` MIME extensions matching canonical regex. Access is granted solely through time-limited (60-second) cryptographic Signed URLs.
* **Application Layer**: Zero exposure of Service Role keys in frontend code; input sanitization against Cross-Site Scripting (XSS); honeypot protection against spam bots.
* **Administrative Layer**: Secure, out-of-band bootstrapping for the initial Super Administrator with zero public self-registration.

---

## 2. Table-by-Table Permission Matrix

| Database Object | `PUBLIC` / `anon` | `authenticated` (Candidate) | `recruiter` (Staff) | `super_admin` (Executive) |
| :--- | :--- | :--- | :--- | :--- |
| **`profiles`** | **Blocked** (0 access) | Read Own Profile only | Read All Staff Profiles | Full CRUD on All Profiles |
| **`jobs`** | Read `published` only | Read `published` only | Full CRUD on All Jobs | Full CRUD on All Jobs |
| **`candidates`** | **Blocked** (Direct access) | Read Own Record (Phase 4) | Read / Update Candidates | Full CRUD on Candidates |
| **`applications`** | **Blocked** (Direct access) | Read Own Status (Phase 4) | Read / Update Status | Full CRUD on Applications |
| **`application_status_history`** | **Blocked** (0 access) | **Blocked** (0 access) | Read-Only Audit Log | Read-Only Audit Log |
| **`contact_messages`** | **Insert `new` only** | **Insert `new` only** | Read / Update Status | Full CRUD on Inquiries |
| **`resumes` Bucket** | **Insert canonical path only** | **Insert canonical path only** | Read via Signed URL (60s) | Full CRUD / Cleanup |
| **`submit_candidate_application`** | **Execute** (Atomic RPC) | **Execute** (Atomic RPC) | **Execute** | **Execute** |
| **`is_admin()`, `is_super_admin()`** | **Blocked** (Revoked) | **Execute** (Evaluates role) | **Execute** | **Execute** |

---

## 3. Resume Content Validation, Malware Scanning & Abandoned Upload Cleanup

### 1. Multi-Layer File Validation
Client-supplied MIME types and file extensions can be spoofed. In production:
* **Storage Gateway**: Rejects files not matching extension `.pdf` or `.docx` and canonical path regex.
* **Database Verification**: `submit_candidate_application` checks `SELECT 1 FROM storage.objects WHERE bucket_id = 'resumes' AND name = p_resume_storage_path`.
* **Content Inspection (Phase 6)**: Prior to recruiter review, an automated Supabase Database Webhook or Edge Function inspects the file's binary magic bytes:
  - PDF: `%PDF-` (`0x25 0x50 0x44 0x46`)
  - DOCX: `PK\x03\x04` (`0x50 0x4B 0x03 0x04`)

### 2. Malware Scanning Architecture
* Recruiter downloads are served via signed URLs that force the `Content-Disposition: attachment` header, ensuring files are downloaded rather than executed inside the administrator's browser context.
* For enterprise compliance, uploads can be routed through an asynchronous scanning service (e.g., ClamAV or VirusTotal API) triggered on object creation.

### 3. Abandoned Upload Cleanup
If a visitor uploads a resume file but abandons the form before submitting, a scheduled cleanup script removes unlinked files:
```sql
-- Scheduled query identifies abandoned resumes older than 24 hours
DELETE FROM storage.objects
WHERE bucket_id = 'resumes'
  AND created_at < NOW() - INTERVAL '24 hours'
  AND name NOT IN (SELECT resume_storage_path FROM public.applications);
```

---

## 4. Secure First Administrator Bootstrap & Recovery Procedure

### Step-by-Step Secure Bootstrap:
1. **Invite Account**:
   - The project owner logs into the Supabase Dashboard $\to$ **Authentication $\to$ Users $\to$ Invite User**.
   - Enter the authorized administrator email (e.g., `admin@solavantacareers.com`).
2. **Elevate to Super Admin**:
   - In Supabase SQL Editor (which has root `postgres` privileges), run:
     ```sql
     INSERT INTO public.profiles (id, full_name, email, role)
     SELECT id, 'Executive Administrator', email, 'super_admin'
     FROM auth.users
     WHERE email = 'admin@solavantacareers.com'
     ON CONFLICT (id) DO UPDATE SET role = 'super_admin';
     ```
3. **Emergency Account Recovery**:
   - If an administrator loses their credentials, password reset emails can be triggered exclusively by the project owner via Supabase Dashboard. Public password resets for admin tiers require out-of-band email verification.

---

## 5. Security Testing Checklist & Expected Results

| Test Case | Tool / Method | Execution Command / Request | Expected Result |
| :--- | :--- | :--- | :--- |
| **1. Candidate Overwrite Attempt** | Anonymous REST / cURL | Submit application with Alice's email and Bob's phone number | **PASS**: Application links to Alice, but Alice's existing phone number is NOT overwritten. |
| **2. Status Tampering Attempt** | Anonymous REST / cURL | Submit application with payload `{"status": "hired"}` | **PASS**: Direct insert rejected by RLS (403 Forbidden). Status forced to `'new'`. |
| **3. Fake Resume Path Injection** | Anonymous RPC call | Call `submit_candidate_application` with a non-existent storage path | **PASS**: Database rejects call with error `P0003: Resume file was not found in private storage`. |
| **4. Arbitrary Storage Upload** | Anonymous REST / cURL | Attempt upload to `resumes/malicious.exe` or `resumes/system/exploit.pdf` | **PASS**: Rejected by Storage RLS (violates canonical path regex). |
| **5. Contact Message Resolution Tampering** | Anonymous REST / cURL | Submit message with `{"status": "resolved", "resolved_at": "2026-01-01"}` | **PASS**: Rejected by RLS policy (`WITH CHECK (status = 'new' AND resolved_at IS NULL)`). |
| **6. Unauthenticated Admin Query** | Anonymous REST / cURL | `GET /rest/v1/applications` with Anon Key | **PASS**: HTTP 200 OK with `[]` (Empty array returned; 0 records leaked). |
| **7. Privilege Function Execution** | Anonymous REST / cURL | Call `public.is_admin()` with Anon Key | **PASS**: HTTP 403 Forbidden (Execution revoked from PUBLIC). |

---

## 6. Client Data Residency & Hosting Location Consultation

* **Recommendation**: While London, UK (`eu-west-2`) is optimal for UK job placement operations and UK GDPR compliance, **the client must confirm their business data residency policy** prior to provisioning the production Supabase project.
* **Alternative Regions Available**:
  - `eu-west-1` (Ireland / EU GDPR)
  - `ap-south-1` (Mumbai / India DPDP Act)
  - `eu-central-1` (Frankfurt)
* The client will select their required region during initial Supabase organization setup.
