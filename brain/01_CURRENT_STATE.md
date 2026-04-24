# Ledger — Current State
> Update this file at the END of every session. Paste alongside 00_PROJECT_BRIEF.md at session start.

## Last updated: 2026-04-24 (session 1 — initial build)

---

## What's built and working ✅

### Frontend pages
- `index.html` — marketing landing (hero, features, how it works, CTA)
- `login.html` — sign in / sign up (email+password + Google OAuth button)
- `confirm.html` — email verification handler (token_hash, PKCE flows), 5s countdown
- `account.html` — full dashboard: Dashboard, Transactions, Budgets, Analytics, Goals, Settings tabs

### account.html features
- **Dashboard tab**: monthly income/expenses/net stats, spendable-this-month bar, income-vs-expenses bar chart, category donut chart, recent transactions
- **Transactions tab**: full CRUD, filter by type/category/month, search, running totals
- **Budgets tab**: set monthly budget per category, progress bars, total spendable remaining
- **Analytics tab**: 6-month income vs expenses bar chart, category breakdown donut, daily spending line chart, period selector
- **Goals tab**: savings goals CRUD, progress bars, add-funds modal, target dates
- **Settings tab**: edit name/currency, manage custom categories, sign out, delete account

### Database (Supabase — migration applied)
- `profiles` — auto-created on signup (handle_new_user trigger)
- `categories` — 18 system defaults (income + expense), user custom categories
- `transactions` — full CRUD per user
- `budget_targets` — monthly budget amounts per category
- `savings_goals` — savings goals with progress tracking
- RLS enabled on all 5 tables

### Infrastructure
- `build.sh` — generates `config.js` from `.env`
- `config.template.js` — committed placeholder
- `_headers` — Cloudflare Pages security headers (CSP, X-Frame-Options, etc.)
- `.gitignore` — `.env` and `config.js` excluded
- Pre-commit hook — scans for leaked secrets

---

## What's NOT done / known gaps ⚠️
- No Cloudflare Pages project created yet — deploy manually or push to GitHub then connect
- Google OAuth requires manual setup: Google Cloud Console → OAuth credentials → add Supabase callback URL → enable Google provider in Supabase Auth settings
- No domain configured — SITE_URL in .env needs updating when domain is known
- No Resend SMTP configured — auth emails use Supabase default sender for now
- No admin panel
- No CSV export of transactions
- No recurring transactions feature

---

## Migrations applied (in order)
| File | What it did |
|------|------------|
| `20260424000001_initial_schema.sql` | Full schema: profiles, categories (with 18 defaults), transactions, budget_targets, savings_goals; all RLS policies; performance indexes; handle_new_user trigger |

---

## What to work on next (backlog)
- [ ] Create Cloudflare Pages project and connect GitHub repo
- [ ] Configure domain in Cloudflare
- [ ] Set up Google OAuth in Supabase Auth settings
- [ ] Configure Resend SMTP for auth emails
- [ ] Add CSV export for transactions
- [ ] Add recurring transactions
- [ ] Add admin/debug view (optional)
