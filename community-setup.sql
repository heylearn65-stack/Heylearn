-- HeyLearn Community: run this once in Supabase -> SQL Editor
create table if not exists profiles(
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (username ~ '^[a-z0-9_]{3,20}$'),
  level text default 'basic',
  xp int default 0,
  streak int default 0,
  words int default 0,
  updated_at timestamptz default now()
);
create table if not exists follows(
  follower uuid references profiles(id) on delete cascade,
  following uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key(follower, following),
  check (follower <> following)
);
alter table profiles enable row level security;
alter table follows enable row level security;
create policy "profiles readable" on profiles for select to authenticated using (true);
create policy "own profile insert" on profiles for insert to authenticated with check (auth.uid() = id);
create policy "own profile update" on profiles for update to authenticated using (auth.uid() = id);
create policy "own profile delete" on profiles for delete to authenticated using (auth.uid() = id);
create policy "follows readable" on follows for select to authenticated using (true);
create policy "follow as self" on follows for insert to authenticated with check (auth.uid() = follower);
create policy "unfollow as self" on follows for delete to authenticated using (auth.uid() = follower);
