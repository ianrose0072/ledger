# Ledger — File Map
> Paste this only when actively working on specific files.

## Frontend Pages

| File | What it does | Key edit targets |
|------|-------------|-----------------|
| `index.html` | Marketing landing | `#hero`, `#features`, `#how-it-works`, `#cta` sections |
| `login.html` | Sign in + sign up | `handleSignIn()`, `handleSignUp()`, `signInWithGoogle()`, tab toggle |
| `confirm.html` | Email verification | `verifyOtp` success block, countdown var, redirect href |
| `account.html` | Full budget dashboard | `state`, `loadData()`, `renderDashboard/Transactions/Budgets/Analytics/Goals/Settings()`, chart functions |

---

## account.html — JS architecture
| Function | Purpose |
|----------|---------|
| `init()` | Auth check, session guard, load data, render dashboard |
| `loadData()` | Parallel fetch: profile, categories, transactions, budgets, goals |
| `switchTab(tab)` | Show/hide tab panels, active state |
| `renderDashboard()` | Monthly stats, spendable bar, charts, recent transactions |
| `renderTransactions()` | Transaction list + filters |
| `renderBudgets()` | Budget progress per category for selected month |
| `renderAnalytics()` | 3 charts + stats summary |
| `renderGoals()` | Savings goal cards |
| `renderSettings()` | Profile form, custom categories, danger zone |
| `openModal(type, data)` | Opens add/edit modal for transactions and goals |
| `saveTransaction(data)` | Insert or update transaction |
| `deleteTransaction(id)` | Delete + re-render |
| `setBudget(catId, period, amount)` | Upsert budget_target |
| `saveGoal(data)` / `deleteGoal(id)` / `addFundsToGoal(id, amount)` | Goals CRUD |
| `formatCurrency(n)` | `Intl.NumberFormat` using profile currency |
| `getCurrentMonth()` | Returns `'YYYY-MM'` string |

---

## Config & Build

| File | Purpose |
|------|---------|
| `config.template.js` | Committed — edit to add new public vars |
| `build.sh` | Generates `config.js` from `.env` |
| `.env` | All secrets — gitignored |
| `_headers` | Cloudflare Pages security headers |
| `CLAUDE.md` | Session instructions (this project) |

---

## Database Migrations (`supabase/migrations/`)
**Append-only — never edit existing files.**

| File | What it created |
|------|----------------|
| `20260424000001_initial_schema.sql` | Full initial schema + RLS + system categories + trigger |
