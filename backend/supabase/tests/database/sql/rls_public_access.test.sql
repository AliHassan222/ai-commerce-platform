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
where id = '11000000-0000-0000-0000-000000000001'::uuid;

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
  '11000000-0000-0000-0000-000000000001'::uuid,
  'authenticated',
  'authenticated',
  'public.review.owner@example.test',
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

insert into public.product_variants (
  id,
  product_id,
  sku,
  name,
  option_values,
  price_amount,
  currency_code,
  status
)
values
  (
    '41000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    'PUB-VAR-ACTIVE',
    'Public Active Variant',
    '{"color":"black"}'::jsonb,
    799.00,
    'USD',
    'active'
  ),
  (
    '41000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    'PUB-VAR-INACTIVE',
    'Public Inactive Variant',
    '{"color":"silver"}'::jsonb,
    799.00,
    'USD',
    'inactive'
  ),
  (
    '41000000-0000-0000-0000-000000000003'::uuid,
    (select id from public.products where slug = 'prototype-smart-display'),
    'DRAFT-PARENT-VAR',
    'Draft Parent Variant',
    '{"color":"white"}'::jsonb,
    249.00,
    'USD',
    'active'
  );

insert into public.product_images (
  id,
  product_id,
  image_url,
  alt_text,
  is_primary,
  sort_order,
  status
)
values
  (
    '42000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    'https://example.test/images/nova-x-1.jpg',
    'Public active image',
    true,
    1,
    'active'
  ),
  (
    '42000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    'https://example.test/images/nova-x-2.jpg',
    'Public inactive image',
    false,
    2,
    'inactive'
  ),
  (
    '42000000-0000-0000-0000-000000000003'::uuid,
    (select id from public.products where slug = 'prototype-smart-display'),
    'https://example.test/images/prototype-1.jpg',
    'Draft parent image',
    true,
    1,
    'active'
  );

insert into public.product_reviews (
  id,
  product_id,
  profile_id,
  rating,
  title,
  review_text,
  status,
  is_verified_purchase
)
values
  (
    '43000000-0000-0000-0000-000000000001'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    '11000000-0000-0000-0000-000000000001'::uuid,
    5,
    'Published review',
    'Visible to public readers.',
    'published',
    true
  ),
  (
    '43000000-0000-0000-0000-000000000002'::uuid,
    (select id from public.products where slug = 'nova-x-smartphone'),
    '11000000-0000-0000-0000-000000000001'::uuid,
    4,
    'Pending review',
    'Hidden from public readers.',
    'pending',
    false
  );

set local role anon;
select set_config('request.jwt.claim.role', 'anon', true);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'electronics'),
  'Anonymous users should see active public categories'
);

select pg_temp.assert_true(
  exists (select 1 from public.products where slug = 'nova-x-smartphone'),
  'Anonymous users should see active public products'
);

select pg_temp.assert_true(
  not exists (select 1 from public.products where slug = 'prototype-smart-display'),
  'Anonymous users should not see draft products'
);

select pg_temp.assert_true(
  not exists (select 1 from public.products where slug = 'legacy-smart-camera'),
  'Anonymous users should not see soft-deleted products'
);

select pg_temp.assert_true(
  exists (select 1 from public.product_variants where id = '41000000-0000-0000-0000-000000000001'::uuid),
  'Anonymous users should see active variants for public products'
);

select pg_temp.assert_true(
  not exists (select 1 from public.product_variants where id = '41000000-0000-0000-0000-000000000002'::uuid),
  'Anonymous users should not see inactive variants'
);

select pg_temp.assert_true(
  not exists (select 1 from public.product_variants where id = '41000000-0000-0000-0000-000000000003'::uuid),
  'Anonymous users should not see variants for non-public parent products'
);

select pg_temp.assert_true(
  exists (select 1 from public.product_images where id = '42000000-0000-0000-0000-000000000001'::uuid),
  'Anonymous users should see active product images for public products'
);

select pg_temp.assert_true(
  not exists (select 1 from public.product_images where id = '42000000-0000-0000-0000-000000000002'::uuid),
  'Anonymous users should not see inactive product images'
);

select pg_temp.assert_true(
  not exists (select 1 from public.product_images where id = '42000000-0000-0000-0000-000000000003'::uuid),
  'Anonymous users should not see images for non-public parent products'
);

select pg_temp.assert_true(
  exists (select 1 from public.product_reviews where id = '43000000-0000-0000-0000-000000000001'::uuid),
  'Anonymous users should see published reviews'
);

select pg_temp.assert_true(
  not exists (select 1 from public.product_reviews where id = '43000000-0000-0000-0000-000000000002'::uuid),
  'Anonymous users should not see pending reviews'
);

reset role;
set local role authenticated;
select set_config('request.jwt.claim.role', 'authenticated', true);
select set_config('request.jwt.claim.sub', '11000000-0000-0000-0000-000000000001', true);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'electronics'),
  'Authenticated customers should see public categories'
);

select pg_temp.assert_true(
  exists (select 1 from public.products where slug = 'nova-x-smartphone'),
  'Authenticated customers should see public products'
);

select pg_temp.assert_true(
  exists (select 1 from public.product_variants where id = '41000000-0000-0000-0000-000000000001'::uuid),
  'Authenticated customers should see public variants'
);

select pg_temp.assert_true(
  exists (select 1 from public.product_images where id = '42000000-0000-0000-0000-000000000001'::uuid),
  'Authenticated customers should see public images'
);

rollback;
