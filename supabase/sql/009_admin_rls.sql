-- ═══════════════════════════════════════════════
-- Migration 009: Admin RLS policies
-- ═══════════════════════════════════════════════
-- Run this after 007_admin_enum.sql and 008_admin_user.sql
-- ═══════════════════════════════════════════════

begin;

-- 1) Helper: check if current user is admin
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- 2) Admin can manage all announcements
drop policy if exists "announcements_insert_owner" on public.announcements;
create policy "announcements_insert_owner"
on public.announcements
for insert
to authenticated
with check (auth.uid() = created_by or is_admin());

drop policy if exists "announcements_update_owner" on public.announcements;
create policy "announcements_update_owner"
on public.announcements
for update
to authenticated
using (auth.uid() = created_by or is_admin())
with check (auth.uid() = created_by or is_admin());

drop policy if exists "announcements_delete_owner" on public.announcements;
create policy "announcements_delete_owner"
on public.announcements
for delete
to authenticated
using (auth.uid() = created_by or is_admin());

-- 3) Admin can manage all jobs (for future use)
drop policy if exists "jobs_insert_owner" on public.jobs;
create policy "jobs_insert_owner"
on public.jobs
for insert
to authenticated
with check (auth.uid() = posted_by or is_admin());

drop policy if exists "jobs_update_owner" on public.jobs;
create policy "jobs_update_owner"
on public.jobs
for update
to authenticated
using (auth.uid() = posted_by or is_admin())
with check (auth.uid() = posted_by or is_admin());

drop policy if exists "jobs_delete_owner" on public.jobs;
create policy "jobs_delete_owner"
on public.jobs
for delete
to authenticated
using (auth.uid() = posted_by or is_admin());

-- 4) Admin can view all profiles for user management
-- (SELECT is already granted to all authenticated users,
--  this policy allows admin-specific write access)
drop policy if exists "profiles_admin_update" on public.profiles;
create policy "profiles_admin_update"
on public.profiles
for update
to authenticated
using (is_admin())
with check (is_admin());

commit;
