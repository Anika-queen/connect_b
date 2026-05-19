begin;

alter table public.profiles
  add column if not exists company text,
  add column if not exists country text,
  add column if not exists expertise text;

create index if not exists profiles_company_idx
  on public.profiles (company);

create index if not exists profiles_country_idx
  on public.profiles (country);

commit;
