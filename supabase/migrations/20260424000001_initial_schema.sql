-- Ledger: initial schema
-- profiles (auto-created on signup)
create table if not exists profiles (
  id          uuid        primary key references auth.users on delete cascade,
  email       text        not null,
  full_name   text,
  currency    text        not null default 'USD',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create or replace function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();

create table if not exists categories (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        references profiles(id) on delete cascade,
  name        text        not null,
  type        text        not null check (type in ('income', 'expense', 'both')),
  color       text        not null default '#6366f1',
  is_system   boolean     not null default false,
  created_at  timestamptz not null default now()
);

create table if not exists transactions (
  id           uuid        primary key default gen_random_uuid(),
  user_id      uuid        not null references profiles(id) on delete cascade,
  type         text        not null check (type in ('income', 'expense')),
  amount       numeric(12,2) not null check (amount > 0),
  category_id  uuid        references categories(id) on delete set null,
  description  text        not null,
  date         date        not null default current_date,
  notes        text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table if not exists budget_targets (
  id           uuid        primary key default gen_random_uuid(),
  user_id      uuid        not null references profiles(id) on delete cascade,
  category_id  uuid        references categories(id) on delete cascade,
  period       text        not null,
  amount       numeric(12,2) not null check (amount > 0),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique(user_id, category_id, period)
);

create table if not exists savings_goals (
  id             uuid        primary key default gen_random_uuid(),
  user_id        uuid        not null references profiles(id) on delete cascade,
  name           text        not null,
  target_amount  numeric(12,2) not null check (target_amount > 0),
  current_amount numeric(12,2) not null default 0 check (current_amount >= 0),
  target_date    date,
  description    text,
  color          text        not null default '#10b981',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

alter table profiles       enable row level security;
alter table categories     enable row level security;
alter table transactions   enable row level security;
alter table budget_targets enable row level security;
alter table savings_goals  enable row level security;

create policy "users read own profile"   on profiles for select using (auth.uid() = id);
create policy "users update own profile" on profiles for update using (auth.uid() = id);

create policy "users read categories"
  on categories for select using (user_id is null or auth.uid() = user_id);
create policy "users insert own categories"
  on categories for insert with check (auth.uid() = user_id);
create policy "users update own categories"
  on categories for update using (auth.uid() = user_id and is_system = false);
create policy "users delete own categories"
  on categories for delete using (auth.uid() = user_id and is_system = false);

create policy "users read own transactions"   on transactions for select using (auth.uid() = user_id);
create policy "users insert own transactions" on transactions for insert with check (auth.uid() = user_id);
create policy "users update own transactions" on transactions for update using (auth.uid() = user_id);
create policy "users delete own transactions" on transactions for delete using (auth.uid() = user_id);

create policy "users read own budgets"   on budget_targets for select using (auth.uid() = user_id);
create policy "users insert own budgets" on budget_targets for insert with check (auth.uid() = user_id);
create policy "users update own budgets" on budget_targets for update using (auth.uid() = user_id);
create policy "users delete own budgets" on budget_targets for delete using (auth.uid() = user_id);

create policy "users read own goals"   on savings_goals for select using (auth.uid() = user_id);
create policy "users insert own goals" on savings_goals for insert with check (auth.uid() = user_id);
create policy "users update own goals" on savings_goals for update using (auth.uid() = user_id);
create policy "users delete own goals" on savings_goals for delete using (auth.uid() = user_id);

create index if not exists idx_transactions_user_id       on transactions(user_id);
create index if not exists idx_transactions_date          on transactions(user_id, date);
create index if not exists idx_transactions_type          on transactions(user_id, type);
create index if not exists idx_budget_targets_user_period on budget_targets(user_id, period);
create index if not exists idx_savings_goals_user_id      on savings_goals(user_id);
create index if not exists idx_categories_user_id         on categories(user_id);

insert into categories (user_id, name, type, color, is_system) values
  (null, 'Salary',        'income',  '#10b981', true),
  (null, 'Freelance',     'income',  '#34d399', true),
  (null, 'Investment',    'income',  '#6ee7b7', true),
  (null, 'Side income',   'income',  '#a7f3d0', true),
  (null, 'Gift received', 'income',  '#059669', true),
  (null, 'Other income',  'income',  '#047857', true),
  (null, 'Housing',       'expense', '#ef4444', true),
  (null, 'Food & dining', 'expense', '#f97316', true),
  (null, 'Transportation','expense', '#f59e0b', true),
  (null, 'Utilities',     'expense', '#eab308', true),
  (null, 'Healthcare',    'expense', '#84cc16', true),
  (null, 'Entertainment', 'expense', '#8b5cf6', true),
  (null, 'Shopping',      'expense', '#ec4899', true),
  (null, 'Subscriptions', 'expense', '#06b6d4', true),
  (null, 'Education',     'expense', '#3b82f6', true),
  (null, 'Personal care', 'expense', '#a78bfa', true),
  (null, 'Travel',        'expense', '#fb923c', true),
  (null, 'Other expense', 'expense', '#6b7280', true)
on conflict do nothing;
