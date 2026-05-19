begin;

create table if not exists public.jobs (
  id bigserial primary key,
  title text not null check (char_length(trim(title)) between 3 and 180),
  company text not null check (char_length(trim(company)) between 2 and 120),
  location text,
  details text,
  deadline date,
  application_url text,
  posted_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists jobs_created_at_idx
  on public.jobs (created_at desc);

create index if not exists jobs_deadline_idx
  on public.jobs (deadline);

alter table public.jobs enable row level security;

drop policy if exists "jobs_select_authenticated" on public.jobs;
create policy "jobs_select_authenticated"
on public.jobs
for select
to authenticated
using (true);

drop policy if exists "jobs_insert_owner" on public.jobs;
create policy "jobs_insert_owner"
on public.jobs
for insert
to authenticated
with check (auth.uid() = posted_by);

drop policy if exists "jobs_update_owner" on public.jobs;
create policy "jobs_update_owner"
on public.jobs
for update
to authenticated
using (auth.uid() = posted_by)
with check (auth.uid() = posted_by);

drop policy if exists "jobs_delete_owner" on public.jobs;
create policy "jobs_delete_owner"
on public.jobs
for delete
to authenticated
using (auth.uid() = posted_by);

grant select, insert, update, delete on table public.jobs to authenticated;
grant usage, select on sequence public.jobs_id_seq to authenticated;

commit;
