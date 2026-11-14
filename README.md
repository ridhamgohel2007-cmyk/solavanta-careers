# Solavanta Careers — Commercial Web Platform

[![Production Status](https://img.shields.io/badge/Status-Phase%202%20Complete-success.svg)](#development-phases)
[![Architecture](https://img.shields.io/badge/Stack-HTML5%20%7C%20Supabase%20%7C%20Vercel-blue.svg)](docs/PROJECT_ARCHITECTURE.md)
[![Database](https://img.shields.io/badge/Database-PostgreSQL%20%28RLS%29-indigo.svg)](docs/DATABASE_SCHEMA.md)
[![Security](https://img.shields.io/badge/Security-UK%20GDPR%20%7C%20DPDP-green.svg)](docs/SECURITY.md)

**Solavanta Careers** is a commercial tech career acceleration and placement platform headquartered in Canary Wharf, London. The platform helps ambitious international graduates, engineers, and data professionals secure high-paying UK tech roles through 1:1 senior mentorship, real industry project experience, and salary negotiation strategy.

---

## 🧭 Public Website Structure

The platform includes 7 core public pages:
1. **[Home](index.html)** — Brand hero, statistics counter, student success arch, placement tracks, and consultation intake.
2. **[Why Solavanta](why-solvanta.html)** — Differentiators, consultancy comparison matrix, and leadership team.
3. **[Placement Plan](placement-plan.html)** — 12 UK placement roadmaps, salary benchmarks, and guarantee terms.
4. **[Resources & Playbooks](resources.html)** — 7 UK tech career playbooks, Skilled Worker visa insights, and ATS resume advice.
5. **[Success Stories](success-stories.html)** — Verified candidate placements, salary packages, and career breakthrough reviews.
6. **[Refer & Earn £500](refer-and-earn.html)** — Referral incentive program and candidate recommendation intake.
7. **[Hire Talent](hire-talent.html)** — Employer portal for hiring pre-vetted international tech talent.

---

## 🛠 Technology Stack

* **Frontend**: Semantic HTML5, CSS3, JavaScript (ES6+), Bootstrap 5.2.3, Swiper 11, Google Fonts (`Space Grotesk` & `Inter`).
* **Backend Services**: [Supabase](https://supabase.com) (PostgreSQL, Supabase Auth, Row-Level Security, Private Storage).
* **Hosting**: [Vercel](https://vercel.com) Edge CDN with automated HTTPS and clean routing.
* **Security**: PostgreSQL Row-Level Security (RLS), encrypted JWT sessions, temporary signed URLs for CVs.

---

## 📚 Project Documentation

Detailed architecture, database, security, and deployment documentation is maintained in the [`docs/`](docs/) directory:

| Document | Description |
| :--- | :--- |
| **[`docs/PROJECT_ARCHITECTURE.md`](docs/PROJECT_ARCHITECTURE.md)** | System architecture, component relationships, data flow diagrams, and tech stack rationale. |
| **[`docs/DATABASE_SCHEMA.md`](docs/DATABASE_SCHEMA.md)** | Normalized PostgreSQL tables, foreign keys, constraints, and query indexes. |
| **[`docs/SECURITY.md`](docs/SECURITY.md)** | Row-Level Security (RLS) policies, private storage rules, secret hygiene, and privacy compliance. |
| **[`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)** | Step-by-step instructions for Supabase provisioning, Vercel deployments, and DNS configuration. |
| **[`docs/CLIENT_HANDOVER.md`](docs/CLIENT_HANDOVER.md)** | Ownership guidelines, credential management, administrative access, and routine maintenance. |
| **[`docs/DEVELOPMENT_PROGRESS.md`](docs/DEVELOPMENT_PROGRESS.md)** | 14-phase development status log and progress tracking. |

---

## 🚀 Local Development Setup

To run the project locally on your machine:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ridhamgohel2007-cmyk/solavanta-careers.git
   cd solavanta-careers
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your local or test Supabase credentials
   ```

3. **Start local HTTP preview server**:
   ```bash
   python server.py
   # Or run: python -m http.server 8080
   ```

4. **Open in browser**:
   Visit `http://localhost:8080` in your web browser.

---

## 🔒 Security & Data Protection
* Environment secrets must never be committed to Git. `.gitignore` is pre-configured to block all `.env` files.
* Resumes and candidate personal data are strictly isolated in private storage with time-limited signed access.
* Commercial data, client credentials, and domain ownership remain exclusively in client control.
