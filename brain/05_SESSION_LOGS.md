# Ledger — Session Logs
> Append a new entry at the end of every session. Do not edit past entries.

---

## Session 1 — 2026-04-24
**Goal:** Initial build — full project scaffold, DB schema, all HTML pages

**Done:**
- Created project structure: brain files, CLAUDE.md, .gitignore, build.sh, config.template.js, _headers
- Applied initial schema migration (profiles, categories, transactions, budget_targets, savings_goals) with full RLS
- Built index.html (marketing landing)
- Built login.html (email/password + Google OAuth)
- Built confirm.html (email verification)
- Built account.html (full 6-tab dashboard: Dashboard, Transactions, Budgets, Analytics, Goals, Settings)
- Created GitHub repo and pushed initial commit

**Decisions made:**
- Free tool, no payments
- All browser-side writes via anon key + RLS (no Edge Functions needed)
- Google OAuth supported but requires manual Google Cloud setup
- Chart.js 4 from CDN for charts

**Gaps / next steps:**
- Connect Cloudflare Pages to GitHub repo
- Set up Google OAuth in Supabase Auth settings
- Configure domain + SITE_URL
- Add Resend SMTP (optional)
