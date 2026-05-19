begin;

create table if not exists public.saved_jobs (
  user_id uuid not null references auth.users (id) on delete cascade,
  job_id bigint not null references public.jobs (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, job_id)
);

create index if not exists saved_jobs_user_created_idx
  on public.saved_jobs (user_id, created_at desc);

alter table public.saved_jobs enable row level security;

drop policy if exists "saved_jobs_select_own" on public.saved_jobs;
create policy "saved_jobs_select_own"
on public.saved_jobs
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "saved_jobs_insert_own" on public.saved_jobs;
create policy "saved_jobs_insert_own"
on public.saved_jobs
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "saved_jobs_delete_own" on public.saved_jobs;
create policy "saved_jobs_delete_own"
on public.saved_jobs
for delete
to authenticated
using (auth.uid() = user_id);

grant select, insert, delete on table public.saved_jobs to authenticated;

commit;
