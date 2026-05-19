-- ═══════════════════════════════════════════════
-- Migration 010: Chat messages table
-- ═══════════════════════════════════════════════

begin;

-- 1) Messages table
create table if not exists public.messages (
  id bigserial primary key,
  sender_id uuid not null references auth.users (id) on delete cascade,
  receiver_id uuid not null references auth.users (id) on delete cascade,
  content text not null check (char_length(trim(content)) >= 1),
  created_at timestamptz not null default now()
);

-- 2) Indexes
create index if not exists messages_sender_receiver_idx
  on public.messages (sender_id, receiver_id);
create index if not exists messages_receiver_sender_idx
  on public.messages (receiver_id, sender_id);
create index if not exists messages_created_at_idx
  on public.messages (created_at desc);

-- 3) RLS
alter table public.messages enable row level security;

drop policy if exists "messages_select_participant" on public.messages;
create policy "messages_select_participant"
  on public.messages
  for select
  to authenticated
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "messages_insert_own" on public.messages;
create policy "messages_insert_own"
  on public.messages
  for insert
  to authenticated
  with check (auth.uid() = sender_id);

-- No update/delete policy (messages are immutable for now)

-- 4) Grants
grant select, insert on table public.messages to authenticated;
grant usage, select on sequence public.messages_id_seq to authenticated;

-- 5) Enable realtime (run this separately if needed)
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table messages;
  end if;
end;
$$;

commit;
