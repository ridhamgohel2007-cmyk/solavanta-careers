# Security Architecture & Data Protection — Solavanta Careers

## 1. Security Philosophy
Solavanta Careers is a commercial career accelerator handling sensitive candidate data, contact numbers, and employment histories. 

Our security model follows the **Principle of Least Privilege**:
* Public internet visitors are given the minimum permission necessary to view public content and submit their own applications.
* Sensitive tables cannot be read, altered, or listed by unauthenticated users.
* Security policies are enforced at the database layer (PostgreSQL Row-Level Security), which means client-side code manipulation cannot bypass access controls.

---

## 2. Authentication Architecture
* **Admin Login**: All administrative routes (`/admin/`) require an authenticated session powered by **Supabase Auth**.
* **Zero Public Admin Registration**: Public visitor sign-ups are restricted to the candidate tier. Admin accounts cannot be created by public visitors; they must be invited or provisioned directly by an existing Super Administrator.
* **Token Storage**: Authentication tokens (JWTs) are handled securely using HttpOnly-capable cookies or modern browser storage with short expiration periods and automatic cryptographic refresh.
* **Brute-Force Protection**: Supabase Auth enforces automatic rate-limiting and temporary IP lockouts on repeated failed password attempts.

---

## 3. Database Row-Level Security (RLS) Policies

Row-Level Security (RLS) is PostgreSQL's built-in security firewall. Every table has RLS enabled by default:

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE application_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
```

### Policy Summary Table:
| Table | Operation | Target Role | Policy Rule / Explanation |
| :--- | :--- | :--- | :--- |
| `jobs` | `SELECT` | `anon, authenticated` | Public can only view jobs where `status = 'published'`. |
| `jobs` | `ALL` | `admin` | Only users with an admin profile can insert, update, or archive jobs. |
| `candidates` | `INSERT` | `anon` | Any visitor can create their own candidate record during application. |
| `candidates` | `SELECT` | `admin` | Only administrators can view candidate lists and contact details. |
| `applications` | `INSERT` | `anon` | Public job seekers can insert a new application linked to a valid job. |
| `applications` | `SELECT, UPDATE` | `admin` | Only administrators can read applications or update their status. |
| `contact_messages` | `INSERT` | `anon` | Public visitors can submit contact and consultation inquiries. |
| `contact_messages` | `SELECT, UPDATE` | `admin` | Only administrators can read inquiries or mark them as resolved. |

---

## 4. Resume & Document Upload Security
Resumes contain highly confidential Personal Identifiable Information (PII).

### Private Storage Bucket Rules:
1. **No Public Bucket Access**: The `resumes` storage bucket in Supabase is marked **Private** (`public = false`). Direct public URLs return HTTP 403 Forbidden.
2. **File Validation on Upload**:
   - Allowed MIME types: `application/pdf`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document` (.docx).
   - Maximum file size: **5 MB**.
   - Filenames are cryptographically hashed upon upload (e.g., `candidate_id/uuid_timestamp.pdf`) to prevent directory traversal attacks or filename spoofing.
3. **Signed Temporary URLs**:
   - When an administrator views a candidate's resume in the dashboard, the application requests a **Temporary Signed URL** from Supabase.
   - The signed URL contains a cryptographic signature valid for only **60 seconds**, expiring immediately afterward.

---

## 5. Input Validation, Sanitization & Anti-Spam
* **SQL Injection Prevention**: All database interactions use Supabase's parameterized API queries. Raw string interpolation in SQL statements is strictly prohibited.
* **XSS (Cross-Site Scripting) Prevention**: User inputs rendered on the screen (such as candidate names or messages in the admin view) are safely escaped using `textContent` / text nodes rather than `innerHTML`.
* **Honeypot Anti-Spam**: Contact forms include a hidden field (`<input name="_website_url" style="display:none" tabindex="-1" autocomplete="off">`). Human visitors never see or fill this field; automated spam bots routinely fill it, allowing the system to silently reject spam without user annoyance.

---

## 6. Privacy & Legal Compliance (UK GDPR & India DPDP)
* **Explicit Consent**: Public intake forms include a required consent checkbox acknowledging that submitted details are stored for career placement purposes.
* **Data Minimization**: Only contact data directly relevant to hiring evaluations is requested.
* **Right to Erasure**: Admin dashboard architecture supports candidate data deletion upon verified request.
* **No Real Candidate Data in Development**: Only mock placeholder records are permitted during testing; real client candidate data will never be entered on development branches.
