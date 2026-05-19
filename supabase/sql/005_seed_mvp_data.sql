begin;

insert into public.jobs (title, company, location, details, deadline, application_url)
select
  'Software Engineer Intern',
  'TechNova Ltd',
  'Dhaka, Bangladesh',
  'Flutter + backend intern role for final-year students.',
  (current_date + interval '12 days')::date,
  'https://example.com/jobs/technova-intern'
where not exists (
  select 1 from public.jobs where title = 'Software Engineer Intern'
);

insert into public.jobs (title, company, location, details, deadline, application_url)
select
  'Graduate Trainee Engineer',
  'FinEdge Solutions',
  'Remote',
  'Entry-level trainee role for engineering graduates.',
  (current_date + interval '20 days')::date,
  'https://example.com/jobs/finedge-gte'
where not exists (
  select 1 from public.jobs where title = 'Graduate Trainee Engineer'
);

insert into public.announcements (title, details, event_location, event_date)
select
  'Alumni Meet 2026',
  'Registration open for yearly alumni networking event.',
  'BAUST Campus',
  (current_date + interval '15 days')::date
where not exists (
  select 1 from public.announcements where title = 'Alumni Meet 2026'
);

insert into public.announcements (title, details, event_location, event_date)
select
  'CV Building Workshop',
  'Career cell workshop on ATS-friendly resume writing.',
  'Seminar Hall 2',
  (current_date + interval '7 days')::date
where not exists (
  select 1 from public.announcements where title = 'CV Building Workshop'
);

commit;
