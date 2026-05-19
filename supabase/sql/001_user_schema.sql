begin;

-- 1) Role type for app users
do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'app_user_role'
      and n.nspname = 'public'
  ) then
    create type public.app_user_role as enum ('student', 'alumni');
  end if;
end
$$;

-- 2) Main user profile table (1:1 with auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  full_name text not null check (char_length(trim(full_name)) between 2 and 120),
  role public.app_user_role not null default 'student',
  department text,
  batch text,
  avatar_url text,
  bio text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Case-insensitive unique email
create unique index if not exists profiles_email_lower_uidx
  on public.profiles (lower(email));

-- Useful indexes for directory/search
create index if not exists profiles_role_idx
  on public.profiles (role);

create index if not exists profiles_department_idx
  on public.profiles (department);

create index if not exists profiles_batch_idx
  on public.profiles (batch);

create index if not exists profiles_created_at_idx
  on public.profiles (created_at desc);

-- 3) Auto-update updated_at
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_set_updated_at on public.profiles;
create trigger trg_profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- 4) Auto-create profile after Supabase Auth user creation
--    Works for magic link / OTP sign-in flows.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role public.app_user_role;
  v_full_name text;
begin
  v_full_name := nullif(trim(coalesce(new.raw_user_meta_data ->> 'full_name', '')), '');
  if v_full_name is null then
    v_full_name := split_part(new.email, '@', 1);
  end if;

  v_role := case lower(coalesce(new.raw_user_meta_data ->> 'role', 'student'))
    when 'alumni' then 'alumni'
    else 'student'
  end;

  insert into public.profiles (
    id,
    email,
    full_name,
    role,
    department,
    batch,
    avatar_url
  )
  values (
    new.id,
    lower(new.email),
    v_full_name,
    v_role,
    nullif(trim(coalesce(new.raw_user_meta_data ->> 'department', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data ->> 'batch', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data ->> 'avatar_url', '')), '')
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = excluded.full_name,
        role = excluded.role,
        department = coalesce(excluded.department, public.profiles.department),
        batch = coalesce(excluded.batch, public.profiles.batch),
        avatar_url = coalesce(excluded.avatar_url, public.profiles.avatar_url),
        updated_at = now();

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

-- 5) Row-Level Security
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated"
on public.profiles
for select
to authenticated
using (true);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- 6) Grants
grant usage on schema public to authenticated;
grant select, insert, update on table public.profiles to authenticated;

commit;
