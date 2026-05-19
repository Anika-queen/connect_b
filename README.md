# BAUST Connect (Beginner MVP)

Flutter + Supabase app for student-alumni networking.

## Implemented MVP Features

- Secure authentication with Supabase (signup, login, email verification flow)
- Role selection on signup (`Student` / `Alumni`)
- Profile metadata capture at signup (`full_name`, `department`, `batch`)
- University email enforcement in signup (`@baust.edu.bd`)
- Home dashboard with live counts
- Alumni directory with search + quick filters (batch/company/country)
- Jobs list with apply link + save/unsave bookmark
- Read-only announcements list
- Profile edit page (full name, department, batch, company, country, expertise)

## Tech Stack

- Flutter (Material 3)
- Supabase Auth + PostgreSQL
- `flutter_dotenv` for environment config

## Environment Setup

Create `.env` in project root:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Run:

```bash
flutter pub get
flutter run
```

## Supabase SQL Migration Order

Run files in order:

1. `supabase/sql/001_user_schema.sql`
2. `supabase/sql/002_profiles_mvp_extensions.sql`
3. `supabase/sql/003_jobs_schema.sql`
4. `supabase/sql/004_announcements_schema.sql`
5. `supabase/sql/005_seed_mvp_data.sql` (optional sample data)
6. `supabase/sql/006_saved_jobs_schema.sql`

## Current Scope Boundaries

Not in beginner MVP yet:

- Connect request workflow
- In-app chat
- Push notifications
- Admin panel / alumni verification workflow
- Bookmark/save jobs
