-- ═══════════════════════════════════════════════
-- Migration 008: Create admin user
-- ═══════════════════════════════════════════════
-- Run 007_admin_enum.sql FIRST, then this one.
-- Email:    alumniadmin@gmail.com
-- Password: 87654321
-- ═══════════════════════════════════════════════

begin;

create extension if not exists pgcrypto with schema extensions;

do $$
declare
  v_user_id uuid;
  v_exists  int;
begin
  select count(*) into v_exists
  from auth.users
  where email = 'alumniadmin@gmail.com';

  if v_exists = 0 then
    v_user_id := gen_random_uuid();

    insert into auth.users (
      instance_id,       id,              aud,
      role,              email,           encrypted_password,
      email_confirmed_at, confirmation_sent_at,
      raw_app_meta_data, raw_user_meta_data,
      created_at,        updated_at
    )
    values (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      'authenticated',
      'authenticated',
      'alumniadmin@gmail.com',
      extensions.crypt('87654321', extensions.gen_salt('bf', 10)),
      now(),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Admin","role":"admin","department":"Admin","batch":"N/A"}',
      now(),
      now()
    );

    raise notice 'Admin user created: alumniadmin@gmail.com (id: %)', v_user_id;
  else
    raise notice 'Admin user already exists — skipping.';
  end if;
end;
$$;

commit;
