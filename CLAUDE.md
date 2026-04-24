# Ledger — Claude Code Briefing

## Context system — read this first, then stop
Do not read all project files to gain context. Use the brain folder only.
### Use short 3-6 word sentences, no filler, no preamble. Run tools first, show result, then stop. Drop articles.

### Session START — read in this order:
1. `brain/00_PROJECT_BRIEF.md` — always, every session
2. `brain/01_CURRENT_STATE.md` — always, every session
3. `brain/02_FILE_MAP.md` — only if working on a specific file
4. `brain/03_DECISIONS_LOG.md` — only if changing architecture or need "why" context
5. `brain/04_DATABASE_SCHEMA.md` — only if writing a migration or Edge Function

### Session END — update whichever brain files were affected:

| What happened | Update |
|---------------|--------|
| Every session | `brain/01_CURRENT_STATE.md` + `brain/05_SESSION_LOGS.md` |
| Stack, services, pricing, or conventions changed | `brain/00_PROJECT_BRIEF.md` |
| File added/deleted or constant/limit changed | `brain/02_FILE_MAP.md` |
| Architecture, product, or security decision made | `brain/03_DECISIONS_LOG.md` |
| Migration written or schema changed | `brain/04_DATABASE_SCHEMA.md` |

Commit all brain file updates in the same commit as the code that triggered them.

## Rules
- Never hardcode secrets — `.env` only
- Never use `sudo` for npm operations
- Ask before deleting data or dropping tables
- Run `bash build.sh` after any config change to regenerate `config.js`
- Migrations are append-only — never edit existing, always create new
- Cloudflare Pages auto-deploys on push to main
- RLS enabled on ALL tables — no exceptions
- `service_role` key: Edge Functions only — never in browser or committed to GitHub
