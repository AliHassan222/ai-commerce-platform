begin;

create or replace function pg_temp.assert_true(condition boolean, message text)
returns void
language plpgsql
as $$
begin
  if not coalesce(condition, false) then
    raise exception '%', message;
  end if;
end;
$$;

delete from auth.users
where id = '13000000-0000-0000-0000-000000000001'::uuid;

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
)
values (
  '00000000-0000-0000-0000-000000000000'::uuid,
  '13000000-0000-0000-0000-000000000001'::uuid,
  'authenticated',
  'authenticated',
  'auth.profile.trigger@example.test',
  '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
  null,
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  timezone('utc', now()),
  timezone('utc', now()),
  '',
  '',
  '',
  ''
);

select pg_temp.assert_true(
  exists (select 1 from public.profiles where id = '13000000-0000-0000-0000-000000000001'::uuid),
  'Auth insert should create a matching public.profiles row'
);

select pg_temp.assert_true(
  (
    select role_id
    from public.profiles
    where id = '13000000-0000-0000-0000-000000000001'::uuid
  ) = (
    select id
    from public.roles
    where name = 'Customer'
  ),
  'Auto-created profile should default to the Customer role'
);

select pg_temp.assert_true(
  (
    select status
    from public.profiles
    where id = '13000000-0000-0000-0000-000000000001'::uuid
  ) = 'pending',
  'Auto-created profile should default to pending status'
);

select pg_temp.assert_true(
  (
    select email
    from public.profiles
    where id = '13000000-0000-0000-0000-000000000001'::uuid
  ) = (
    select email
    from auth.users
    where id = '13000000-0000-0000-0000-000000000001'::uuid
  ),
  'Auto-created profile email should match auth.users.email'
);

set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '13000000-0000-0000-0000-000000000001', true);

update public.profiles
set first_name = 'Allowed'
where id = '13000000-0000-0000-0000-000000000001'::uuid;

select pg_temp.assert_true(
  (
    select first_name
    from public.profiles
    where id = '13000000-0000-0000-0000-000000000001'::uuid
  ) = 'Allowed',
  'Normal self-service profile fields should still be updatable'
);

do $$
begin
  begin
    update public.profiles
    set email = 'drifted.email@example.test'
    where id = '13000000-0000-0000-0000-000000000001'::uuid;

    raise exception 'Self-service profile update should not be able to change profiles.email';
  exception
    when insufficient_privilege or sqlstate '42501' then
      null;
  end;
end;
$$;

select pg_temp.assert_true(
  (
    select email
    from public.profiles
    where id = '13000000-0000-0000-0000-000000000001'::uuid
  ) = 'auth.profile.trigger@example.test',
  'profiles.email should remain aligned after blocked self-service update'
);

rollback;
