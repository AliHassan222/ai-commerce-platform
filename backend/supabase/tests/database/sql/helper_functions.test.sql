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
where id in (
  '10000000-0000-0000-0000-000000000001'::uuid,
  '10000000-0000-0000-0000-000000000002'::uuid,
  '10000000-0000-0000-0000-000000000003'::uuid,
  '10000000-0000-0000-0000-000000000004'::uuid,
  '10000000-0000-0000-0000-000000000005'::uuid
);

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
values
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '10000000-0000-0000-0000-000000000001'::uuid,
    'authenticated',
    'authenticated',
    'helper.customer.verified@example.test',
    '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
    timezone('utc', now()),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    timezone('utc', now()),
    timezone('utc', now()),
    '',
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '10000000-0000-0000-0000-000000000002'::uuid,
    'authenticated',
    'authenticated',
    'helper.customer.unverified@example.test',
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
  ),
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '10000000-0000-0000-0000-000000000003'::uuid,
    'authenticated',
    'authenticated',
    'helper.admin@example.test',
    '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
    timezone('utc', now()),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    timezone('utc', now()),
    timezone('utc', now()),
    '',
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '10000000-0000-0000-0000-000000000004'::uuid,
    'authenticated',
    'authenticated',
    'helper.superadmin@example.test',
    '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
    timezone('utc', now()),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    timezone('utc', now()),
    timezone('utc', now()),
    '',
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000'::uuid,
    '10000000-0000-0000-0000-000000000005'::uuid,
    'authenticated',
    'authenticated',
    'helper.suspended@example.test',
    '$2a$10$7EqJtq98hPqEX7fNZaFWoO.HXh6n6PvxI6Bfq5lHppZArYrusS4CS',
    timezone('utc', now()),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    timezone('utc', now()),
    timezone('utc', now()),
    '',
    '',
    '',
    ''
  );

update public.profiles
set
  role_id = (select id from public.roles where name = 'Admin'),
  status = 'active'
where id = '10000000-0000-0000-0000-000000000003'::uuid;

update public.profiles
set
  role_id = (select id from public.roles where name = 'Super Admin'),
  status = 'active'
where id = '10000000-0000-0000-0000-000000000004'::uuid;

update public.profiles
set status = 'suspended'
where id = '10000000-0000-0000-0000-000000000005'::uuid;

insert into public.carts (
  id,
  profile_id,
  status,
  currency_code
)
values
  (
    '20000000-0000-0000-0000-000000000001'::uuid,
    '10000000-0000-0000-0000-000000000001'::uuid,
    'active',
    'USD'
  ),
  (
    '20000000-0000-0000-0000-000000000002'::uuid,
    '10000000-0000-0000-0000-000000000002'::uuid,
    'active',
    'USD'
  );

insert into public.orders (
  id,
  profile_id,
  cart_id,
  order_number,
  status,
  payment_status,
  fulfillment_status,
  currency_code,
  subtotal_amount,
  discount_amount,
  tax_amount,
  shipping_amount,
  total_amount
)
values
  (
    '30000000-0000-0000-0000-000000000001'::uuid,
    '10000000-0000-0000-0000-000000000001'::uuid,
    '20000000-0000-0000-0000-000000000001'::uuid,
    'HF-ORDER-001',
    'pending',
    'pending',
    'pending',
    'USD',
    100.00,
    0.00,
    0.00,
    0.00,
    100.00
  ),
  (
    '30000000-0000-0000-0000-000000000002'::uuid,
    '10000000-0000-0000-0000-000000000002'::uuid,
    '20000000-0000-0000-0000-000000000002'::uuid,
    'HF-ORDER-002',
    'pending',
    'pending',
    'pending',
    'USD',
    100.00,
    0.00,
    0.00,
    0.00,
    100.00
  );

create temp table pg_temp.expected_roles (
  admin_role_id uuid,
  super_admin_role_id uuid
);

grant select on table pg_temp.expected_roles to authenticated;
grant select on table pg_temp.expected_roles to anon;

insert into pg_temp.expected_roles (
  admin_role_id,
  super_admin_role_id
)
select
  (select id from public.roles where name = 'Admin'),
  (select id from public.roles where name = 'Super Admin');

set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000003', true);

select pg_temp.assert_true(
  public.current_profile_id() = '10000000-0000-0000-0000-000000000003'::uuid,
  'current_profile_id() should resolve the authenticated profile'
);

select pg_temp.assert_true(
  public.current_user_email() = 'helper.admin@example.test',
  'current_user_email() should resolve trusted auth.users email'
);

select pg_temp.assert_true(
  public.is_verified_email(),
  'is_verified_email() should return true for verified users'
);

select pg_temp.assert_true(
  public.current_role_id() = (select admin_role_id from pg_temp.expected_roles),
  'current_role_id() should resolve the Admin role id'
);

select pg_temp.assert_true(
  public.current_role_code() = 'admin',
  'current_role_code() should normalize the role name'
);

select pg_temp.assert_true(
  public.current_profile_status() = 'active',
  'current_profile_status() should resolve active profile state'
);

select pg_temp.assert_true(
  public.has_permission('products.read'),
  'has_permission() should return true for granted Admin permissions'
);

select pg_temp.assert_true(
  not public.has_permission('users.manage_roles'),
  'has_permission() should return false for ungranted Admin permissions'
);

select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000004', true);

select pg_temp.assert_true(
  public.current_role_code() = 'super_admin',
  'current_role_code() should normalize Super Admin correctly'
);

select pg_temp.assert_true(
  public.has_permission('users.manage_roles'),
  'Super Admin should inherit all seeded permissions'
);

select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', true);

select pg_temp.assert_true(
  public.owns_profile('10000000-0000-0000-0000-000000000001'::uuid),
  'owns_profile() should return true for the current profile'
);

select pg_temp.assert_true(
  not public.owns_profile('10000000-0000-0000-0000-000000000002'::uuid),
  'owns_profile() should return false for another profile'
);

select pg_temp.assert_true(
  public.owns_cart('20000000-0000-0000-0000-000000000001'::uuid),
  'owns_cart() should return true for owned carts'
);

select pg_temp.assert_true(
  not public.owns_cart('20000000-0000-0000-0000-000000000002'::uuid),
  'owns_cart() should return false for unowned carts'
);

select pg_temp.assert_true(
  public.owns_order('30000000-0000-0000-0000-000000000001'::uuid),
  'owns_order() should return true for owned orders'
);

select pg_temp.assert_true(
  not public.owns_order('30000000-0000-0000-0000-000000000002'::uuid),
  'owns_order() should return false for unowned orders'
);

select pg_temp.assert_true(
  not public.has_permission('products.read'),
  'Customer should not have internal product permissions'
);

select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000002', true);

select pg_temp.assert_true(
  not public.is_verified_email(),
  'is_verified_email() should return false for unverified users'
);

select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000005', true);

select pg_temp.assert_true(
  public.current_profile_status() = 'suspended',
  'current_profile_status() should resolve suspended profile state'
);

rollback;
