# Deployment Guide — Solavanta Careers

## 1. Overview
The Solavanta Careers platform utilizes a cloud-native, serverless deployment model:
* **Frontend Hosting**: Vercel (Global Edge Network)
* **Backend & Database**: Supabase (Cloud PostgreSQL + Auth + Storage)
* **DNS & Domain**: Client-owned domain registrar (e.g., Cloudflare, GoDaddy, Namecheap)

This architecture requires zero server maintenance, patches itself automatically, and scales seamlessly.

---

## 2. Setting Up the Supabase Project (Phase 3 Preparation)
*(Note: As per project rules, this will be executed by the client/developer when Phase 3 begins).*

1. Go to [https://supabase.com](https://supabase.com) and sign in using the client's corporate account.
2. Click **New Project**:
   - Organization: Solavanta Careers
   - Project Name: `solavanta-careers-prod`
   - Database Password: Store securely in a password manager (e.g., Bitwarden or 1Password).
   - Region: `London, UK (eu-west-2)` for lowest latency and UK data residency.
3. Once provisioned, navigate to **Project Settings $\to$ API**:
   - Copy the **Project URL** (`SUPABASE_URL`).
   - Copy the **anon / public** key (`SUPABASE_ANON_KEY`).
4. In the **Storage** section, create a bucket named `resumes` and ensure **Public Bucket** is unchecked (`Private`).

---

## 3. Deploying to Vercel (Staging & Production)

1. Sign in to [https://vercel.com](https://vercel.com) using the authorized GitHub account.
2. Click **Add New... $\to$ Project**.
3. Import the `solavanta-careers` repository.
4. Framework Preset: **Other** (Static HTML).
5. In **Environment Variables**, add:
   - `SUPABASE_URL` = `https://your-project.supabase.co`
   - `SUPABASE_ANON_KEY` = `your-anon-key`
6. Click **Deploy**. Vercel will build and assign an immediate preview URL (e.g., `solavanta-careers.vercel.app`).

---

## 4. Custom Domain & DNS Configuration

Once staging verification is approved by the client:
1. In Vercel Project Settings $\to$ **Domains**, enter the client's domain: `solavantacareers.com` (and `www.solavantacareers.com`).
2. Vercel will provide the DNS records to configure at the client's domain registrar:
   - **A Record**: Point `@` to Vercel IP `76.76.21.21`
   - **CNAME Record**: Point `www` to `cname.vercel-dns.com`
3. SSL certificates are provisioned automatically within minutes of DNS propagation.

---

## 5. Backup & Disaster Recovery Procedures
* **Automated Daily Backups**: Managed automatically by Supabase on all production projects.
* **Manual Snapshot**: Before major schema updates, an administrator can export a complete SQL dump from Supabase Dashboard $\to$ **Database $\to$ Backups**.
* **Frontend Rollback**: Because every commit triggers an immutable Vercel deployment, any production release can be rolled back to the previous deployment in a single click in the Vercel dashboard.
