begin;
// lisa updates
create table if not exists public.announcements (
  id bigserial primary key,
  title text not null check (char_length(trim(title)) between 3 and 180),
  details text not null check (char_length(trim(details)) >= 5),
  event_location text,
  event_date date,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists announcements_created_at_idx
  on public.announcements (created_at desc);

create index if not exists announcements_event_date_idx
  on public.announcements (event_date);

alter table public.announcements enable row level security;

drop policy if exists "announcements_select_authenticated" on public.announcements;
create policy "announcements_select_authenticated"
on public.announcements
for select
to authenticated
using (true);

drop policy if exists "announcements_insert_owner" on public.announcements;
create policy "announcements_insert_owner"
on public.announcements
for insert
to authenticated
with check (auth.uid() = created_by);

drop policy if exists "announcements_update_owner" on public.announcements;
create policy "announcements_update_owner"
on public.announcements
for update
to authenticated
using (auth.uid() = created_by)
with check (auth.uid() = created_by);

drop policy if exists "announcements_delete_owner" on public.announcements;
create policy "announcements_delete_owner"
on public.announcements
for delete
to authenticated
using (auth.uid() = created_by);

grant select, insert, update, delete on table public.announcements to authenticated;
grant usage, select on sequence public.announcements_id_seq to authenticated;

commit;
