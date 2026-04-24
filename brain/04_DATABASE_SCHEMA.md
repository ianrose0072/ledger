# Ledger — Database Schema
> Paste this only when writing migrations or debugging DB issues.

## Tables

### profiles
```sql
id            uuid        PK → references auth.users ON DELETE CASCADE
email         text        not null
full_name     text
currency      text        not null default 'USD'
bank_balance  numeric(12,2) not null default 0   -- user's starting balance before first transaction
created_at    timestamptz not null default now()
updated_at    timestamptz not null default now()
```
Auto-created by `handle_new_user` trigger on `auth.users` insert.

### categories
```sql
id          uuid        PK default gen_random_uuid()
user_id     uuid        → profiles(id) ON DELETE CASCADE — null = system category
name        text        not null
type        text        not null  -- 'income' | 'expense' | 'both'
color       text        not null default '#6366f1'
is_system   boolean     not null default false
created_at  timestamptz not null default now()
```
18 system categories inserted at migration time (user_id = null, is_system = true).

### transactions
```sql
id           uuid        PK default gen_random_uuid()
user_id      uuid        not null → profiles(id) ON DELETE CASCADE
type         text        not null  -- 'income' | 'expense'
amount       numeric(12,2) not null  -- always positive; type determines direction
category_id  uuid        → categories(id) ON DELETE SET NULL
description  text        not null
date         date        not null default current_date
notes        text
created_at   timestamptz not null default now()
updated_at   timestamptz not null default now()
```

### budget_targets
```sql
id           uuid        PK default gen_random_uuid()
user_id      uuid        not null → profiles(id) ON DELETE CASCADE
category_id  uuid        → categories(id) ON DELETE CASCADE
period       text        not null  -- 'YYYY-MM'
amount       numeric(12,2) not null  -- monthly budget for this category
created_at   timestamptz not null default now()
updated_at   timestamptz not null default now()
UNIQUE(user_id, category_id, period)
```

### savings_goals
```sql
id             uuid        PK default gen_random_uuid()
user_id        uuid        not null → profiles(id) ON DELETE CASCADE
name           text        not null
target_amount  numeric(12,2) not null
current_amount numeric(12,2) not null default 0
target_date    date        -- optional
description    text
color          text        not null default '#10b981'
created_at     timestamptz not null default now()
updated_at     timestamptz not null default now()
```

### recurring_budget_templates
```sql
id          uuid        PK default gen_random_uuid()
user_id     uuid        NOT NULL → profiles(id) ON DELETE CASCADE
category_id uuid        → categories(id) ON DELETE CASCADE
amount      numeric(12,2) NOT NULL  -- monthly amount to auto-apply
active      boolean     NOT NULL default true
created_at  timestamptz NOT NULL default now()
updated_at  timestamptz NOT NULL default now()
UNIQUE(user_id, category_id)
```
Auto-applied on page load: for the current month, any active template whose category has no `budget_targets` row gets one inserted.

### recurring_transactions
```sql
id           uuid        PK default gen_random_uuid()
user_id      uuid        not null → profiles(id) ON DELETE CASCADE
type         text        not null  -- 'income' | 'expense'
amount       numeric(12,2) not null
category_id  uuid        → categories(id) ON DELETE SET NULL
description  text        not null
notes        text
frequency    text        not null  -- 'weekly' | 'monthly' | 'yearly'
next_date    date        not null  -- date of next auto-creation
active       boolean     not null default true
created_at   timestamptz not null default now()
updated_at   timestamptz not null default now()
```
Auto-processed on page load: any active template with `next_date <= today` creates a transaction and advances `next_date`.

---

## Row Level Security (all tables have RLS enabled)

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| profiles | own row (auth.uid() = id) | trigger only | own row | blocked |
| categories | system (user_id IS NULL) + own | own user_id | own, non-system | own, non-system |
| transactions | own rows | own user_id | own rows | own rows |
| budget_targets | own rows | own user_id | own rows | own rows |
| savings_goals | own rows | own user_id | own rows | own rows |
| recurring_transactions | own rows | own user_id | own rows | own rows |
| recurring_budget_templates | own rows | own user_id | own rows | own rows |

---

## Indexes
- `idx_transactions_user_id` on `transactions(user_id)`
- `idx_transactions_date` on `transactions(user_id, date)`
- `idx_transactions_type` on `transactions(user_id, type)`
- `idx_budget_targets_user_period` on `budget_targets(user_id, period)`
- `idx_savings_goals_user_id` on `savings_goals(user_id)`
- `idx_categories_user_id` on `categories(user_id)`
- `idx_recurring_user_active` on `recurring_transactions(user_id, active, next_date)`
- `idx_recurring_budgets_user` on `recurring_budget_templates(user_id, active)`

---

## Key trigger
`handle_new_user` — fires on INSERT to `auth.users`; inserts row in `profiles` with id, email, full_name from metadata.

---

## Migration rule
**Append-only.** Never edit existing migration files. Always create a new file with the next timestamp.

Migrations applied (in order):
1. `20260424000001_initial_schema.sql` — base schema
2. `20260424000002_delete_user_account_function.sql` — `delete_user_account()` RPC
3. MCP: `add_bank_balance_to_profiles` — adds `bank_balance` column to profiles
4. MCP: `add_recurring_transactions` — `recurring_transactions` table + RLS + index
5. MCP: `add_recurring_budget_templates` — `recurring_budget_templates` table + RLS + index

---

## Auth flow
1. User lands on `login.html`
2. Signs up (email+password or Google OAuth) → Supabase sends verification email
3. Email link → `confirm.html` → uses `onAuthStateChange` for OAuth, `verifyOtp` for email
4. On success → redirect to `account.html` after 3s countdown
5. Every protected page → check session on load, redirect to `login.html` if none
6. Sign out → `supabase.auth.signOut()` → redirect to `index.html`

### Supabase auth configuration (already set ✅)
- **Site URL:** `https://ianrose0072.github.io/ledger`
- **Redirect URLs:** `https://ianrose0072.github.io/ledger/**`
- **Google OAuth:** enabled
