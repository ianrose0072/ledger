# Ledger — Current State
> Update this file at the END of every session. Paste alongside 00_PROJECT_BRIEF.md at session start.

## Last updated: 2026-04-24 (session 2)

---

## What's built and working ✅

### Frontend pages
- `index.html` — marketing landing (hero, features, how it works, CTA)
- `login.html` — sign in / sign up (email+password + Google OAuth button); defensive IIFE init; all buttons use addEventListener
- `confirm.html` — email verification handler; uses onAuthStateChange for OAuth PKCE (fixed infinite loading); 15s timeout; 3s countdown redirect
- `account.html` — full dashboard: Dashboard, Transactions, Budgets, Analytics, Goals, Settings tabs

### account.html features
- **Dashboard tab**: account balance (starting balance + all-time transactions), monthly income/expenses, savings rate, spendable-this-month bar, income-vs-expenses bar chart, category donut chart, recent transactions
- **Transactions tab**: full CRUD, filter by type/category/month, search, running totals; current account balance banner with "Edit starting balance" button; **Recurring section** — list, add, edit, delete, pause/resume recurring transactions
- **Budgets tab**: set monthly budget per category, progress bars, total spendable remaining
- **Analytics tab**: period selector (1/3/6/12m), income vs expenses bar chart, category breakdown donut (with empty state), daily spending line chart; refreshes from Supabase on every tab switch
- **Goals tab**: savings goals CRUD, progress bars, add-funds modal, target dates
- **Settings tab**: edit name/currency, manage custom categories, sign out, delete account

### UX improvements (session 2)
- **Enter to save** — pressing Enter in any modal triggers the primary save button
- **Date quick buttons** — Today/Yesterday shortcuts on transaction date field; Today + Clear on goal date
- **Category filter** — transaction modal rebuilds options dynamically on type change (income shows only income cats, expense shows only expense cats); fixed Chrome optgroup hide bug
- **Starting bank balance** — stored in `profiles.bank_balance`; used to compute real account balance across all tabs
- **Analytics donut empty state** — shows message instead of blank canvas when no data

### Database (Supabase — all migrations applied)
- `profiles` — auto-created on signup (handle_new_user trigger); includes `bank_balance numeric(12,2)`
- `categories` — 18 system defaults (income + expense), user custom categories
- `transactions` — full CRUD per user
- `budget_targets` — monthly budget amounts per category
- `savings_goals` — savings goals with progress tracking
- `recurring_transactions` — recurring income/expense templates; auto-processed on page load
- RLS enabled on all 6 tables

### Infrastructure
- `config.js` — committed (publishable key only — safe); `window.LDG` namespace
- Pre-commit hook — blocks JWT tokens, Stripe live keys, GitHub tokens
- **GitHub Pages live** at https://ianrose0072.github.io/ledger (public repo required for free Pages)

---

## Recurring transactions — how it works
1. User adds a recurring template (income or expense) with frequency: weekly / monthly / yearly
2. On every page load, `processRecurring()` checks for templates where `next_date <= today` and `active = true`
3. Creates the actual transaction, then advances `next_date` to next occurrence
4. User can pause/resume or delete recurring templates; past transactions remain

---

## Supabase dashboard — manual steps (already done ✅)
- Site URL → `https://ianrose0072.github.io/ledger`
- Redirect URLs → `https://ianrose0072.github.io/ledger/**`
- Google OAuth → enabled (Google Cloud Console credentials added)

---

## Migrations applied (in order)
| Migration | What it did |
|-----------|------------|
| `20260424000001_initial_schema.sql` | Full schema: profiles, categories (18 defaults), transactions, budget_targets, savings_goals; all RLS; indexes; handle_new_user trigger |
| `20260424000002_delete_user_account_function.sql` | `delete_user_account()` SECURITY DEFINER function |
| (via MCP) `add_bank_balance_to_profiles` | `ALTER TABLE profiles ADD COLUMN bank_balance numeric(12,2) DEFAULT 0` |
| (via MCP) `add_recurring_transactions` | `recurring_transactions` table + RLS + index |

---

## What to work on next (backlog)
- [ ] Create Cloudflare Pages project and connect GitHub repo
- [ ] Configure domain in Cloudflare
- [ ] Configure Resend SMTP for auth emails
- [ ] Add CSV export for transactions
- [ ] Add admin/debug view (optional)
