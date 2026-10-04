-- HeyLearn Community upgrade: weekly league + friend duels.
-- Run this once in Supabase -> SQL Editor (after community-setup.sql).
alter table profiles add column if not exists week_xp int default 0;
alter table profiles add column if not exists week_start text default '';

create table if not exists duels(
  id uuid primary key default gen_random_uuid(),
  a uuid not null references profiles(id) on delete cascade,
  b uuid not null references profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','active')),
  a_base int default 0,
  b_base int default 0,
  days int default 3,
  ends_at timestamptz,
  created_at timestamptz default now(),
  check (a <> b)
);
alter table duels enable row level security;
create policy "duel read" on duels for select to authenticated using (auth.uid() = a or auth.uid() = b);
create policy "duel create" on duels for insert to authenticated with check (auth.uid() = a);
create policy "duel respond" on duels for update to authenticated using (auth.uid() = a or auth.uid() = b);
create policy "duel delete" on duels for delete to authenticated using (auth.uid() = a or auth.uid() = b);

-- Privacy: let each learner choose whether to appear in the public Weekly League.
alter table profiles add column if not exists public boolean default true;
