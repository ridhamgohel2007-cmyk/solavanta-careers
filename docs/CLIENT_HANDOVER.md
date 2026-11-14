# Client Handover & Ownership Guide — Solavanta Careers

## 1. Principles of Client Ownership
**Solavanta Careers** is a commercial proprietary project. 

The **Client** must maintain sole, uncompromised legal and operational ownership of all digital assets:
1. **GitHub Repository**: The production repository must be owned by the client's GitHub Organization.
2. **Domain Name**: Registered and billed under the client's company name.
3. **Supabase Account**: The client holds the Owner role and billing credentials.
4. **Vercel Hosting**: Owned by the client organization; developers receive Collaborator access.
5. **Customer & Candidate Data**: All PostgreSQL data and stored resumes belong exclusively to the client.

The development team must never hold exclusive administrator access, retain production passwords, or bill hosting under personal developer cards.

---

## 2. Handover Checklist

### Access & Account Checklist:
- [ ] GitHub Organization created; production repository set to **Private**.
- [ ] Client invited as Owner; 2-Factor Authentication (2FA) enforced.
- [ ] Supabase project transferred to client billing; master database password stored in client vault.
- [ ] Vercel team ownership assigned to client administrator.
- [ ] Domain registrar DNS records verified and locked.

### Documentation Checklist:
- [ ] Architecture documentation delivered ([`PROJECT_ARCHITECTURE.md`](file:///c:/Users/RIDHAM%20GOHEL/Downloads/London%20based%20case/docs/PROJECT_ARCHITECTURE.md)).
- [ ] Database schema and migration scripts delivered ([`DATABASE_SCHEMA.md`](file:///c:/Users/RIDHAM%20GOHEL/Downloads/London%20based%20case/docs/DATABASE_SCHEMA.md)).
- [ ] Security protocols documented ([`SECURITY.md`](file:///c:/Users/RIDHAM%20GOHEL/Downloads/London%20based%20case/docs/SECURITY.md)).
- [ ] Deployment and restoration instructions delivered ([`DEPLOYMENT.md`](file:///c:/Users/RIDHAM%20GOHEL/Downloads/London%20based%20case/docs/DEPLOYMENT.md)).
- [ ] Admin user manual provided explaining application reviews and job publishing.

---

## 3. Routine Administrative Operations

### Adding a New Admin User:
1. Sign in to Supabase Dashboard $\to$ **Authentication $\to$ Users**.
2. Click **Invite User** and enter the team member's corporate email.
3. In the `profiles` table, set their `role` to `'recruiter'` or `'super_admin'`.
4. The user receives an email confirmation link to set their password.

### Revoking Access:
1. In Supabase Dashboard $\to$ **Authentication $\to$ Users**, locate the user and click **Disable User** or **Delete User**.
2. Their active session is revoked immediately across all devices.

### Exporting Candidate Data (CSV / Excel):
* From the Solavanta Admin Dashboard, authorized Super Admins can click **Export to CSV** to download applicant batches for executive meetings or ATS import.
