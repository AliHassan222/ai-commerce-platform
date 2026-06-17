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

select pg_temp.assert_true(
  (
    select count(*)
    from public.roles
    where name in ('Super Admin', 'Admin', 'Viewer', 'Customer', 'Vendor')
  ) = 5,
  'All required seeded roles should exist'
);

select pg_temp.assert_true(
  (
    select count(*)
    from public.permissions
    where code in (
      'users.read',
      'users.update',
      'users.manage_roles',
      'products.read',
      'products.create',
      'products.update',
      'products.publish',
      'products.delete',
      'products.restore',
      'orders.read_all',
      'orders.update_status',
      'reviews.read',
      'reviews.moderate',
      'reviews.hide',
      'reviews.delete',
      'categories.read',
      'categories.create',
      'categories.update',
      'categories.delete',
      'categories.restore'
    )
  ) = 20,
  'All required seeded permissions should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'electronics' and status = 'active'),
  'Electronics category should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'mobiles' and status = 'active'),
  'Mobiles category should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'laptops' and status = 'active'),
  'Laptops category should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'fashion' and status = 'active'),
  'Fashion category should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.categories where slug = 'home-kitchen' and status = 'active'),
  'Home & Kitchen category should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.products where slug = 'nova-x-smartphone' and status = 'active' and deleted_at is null),
  'Active public seed product should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.products where slug = 'aerobook-14' and status = 'active' and deleted_at is null),
  'Additional active seed product should exist'
);

select pg_temp.assert_true(
  exists (select 1 from public.products where slug = 'prototype-smart-display' and status = 'draft' and deleted_at is null),
  'Draft seed product should exist'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.products
    where slug = 'legacy-smart-camera'
      and deleted_at = '2026-01-01 00:00:00+00'::timestamptz
  ),
  'Soft-deleted seed product should exist with deterministic deleted_at'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Admin'
      and p.code = 'orders.update_status'
  ),
  'Admin role should have orders.update_status mapping'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Viewer'
      and p.code = 'reviews.read'
  ),
  'Viewer role should have reviews.read mapping'
);

rollback;
