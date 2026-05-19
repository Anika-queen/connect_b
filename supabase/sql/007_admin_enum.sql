-- ═══════════════════════════════════════════════
-- Migration 007: Add admin role to enum + trigger
-- ═══════════════════════════════════════════════
-- Run this FIRST, then run 008_admin_user.sql
-- ═══════════════════════════════════════════════

begin;

-- 1) Add 'admin' to the role enum
alter type public.app_user_role add value if not exists 'admin';

-- 2) Update the auto-profile trigger to handle 'admin' role
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
    when 'admin'  then 'admin'
    else 'student'
  end;

  insert into public.profiles (
    id, email, full_name, role, department, batch, avatar_url
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

commit;
