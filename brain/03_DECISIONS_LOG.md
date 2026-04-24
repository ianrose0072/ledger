# Ledger — Decisions Log
> Paste this only when changing architecture or needing "why" context.

## Stack decisions
- **Vanilla JS** — no framework; zero bundle size; no build pipeline needed for JS
- **Chart.js 4** — simplest chart library with good docs; loaded from CDN; no install required
- **No payments** — Ledger is a free tool; no Stripe integration
- **No Edge Functions initially** — all data operations use the anon key + RLS from the browser; no server-side logic required
- **Public config via build step** — `config.js` generated from `.env`; Cloudflare Pages runs `bash build.sh` on deploy
- **`service_role` never in browser** — all Supabase writes use the anon key; RLS enforces user isolation

## Product decisions
- **Free, no plans** — budget tracking is a free feature; no subscription required
- **System categories are shared** — `user_id = null` categories visible to all users; users can add custom ones
- **Currency stored on profile** — single currency per user; affects all formatting; default USD
- **Transactions are immutable-ish** — users can edit/delete; no audit log for now
- **Budgets are per-month per-category** — period stored as `'YYYY-MM'` string; one budget row per combo
- **Goals track manually** — users increment `current_amount` themselves; no automatic linkage to transactions

## Auth decisions
- **Google OAuth supported** — `supabase.auth.signInWithOAuth({ provider: 'google' })` — requires manual Google Cloud setup (see backlog)
- **Email verification** via Supabase default SMTP initially; can add Resend later
- **confirm.html handles both flows** — `token_hash` (standard email link) and `code` (PKCE OAuth exchange)
- **Protected pages redirect to login** — check session on every page load; no tokens stored in JS vars

## Security decisions
- **RLS on all 5 tables** — users see only their own rows; system categories use `user_id IS NULL OR auth.uid() = user_id`
- **No admin page** — no admin role or server-side role checks needed yet; add if multi-tenancy required
- **Pre-commit hook** — blocks commits containing likely secret patterns
- **`_headers` for Cloudflare Pages** — CSP, X-Frame-Options, nosniff, Referrer-Policy, Permissions-Policy, COOP
- **No `console.log` of sensitive data** in production

## Infrastructure decisions
- **Cloudflare Pages** auto-deploys on push to main
- **Migrations are append-only** — always create new file; never edit existing
