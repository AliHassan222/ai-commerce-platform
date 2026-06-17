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
  exists (select 1 from public.roles where name = 'Super Admin' and status = 'active'),
  'Super Admin role should exist and be active'
);

select pg_temp.assert_true(
  exists (select 1 from public.roles where name = 'Admin' and status = 'active'),
  'Admin role should exist and be active'
);

select pg_temp.assert_true(
  exists (select 1 from public.roles where name = 'Viewer' and status = 'active'),
  'Viewer role should exist and be active'
);

select pg_temp.assert_true(
  exists (select 1 from public.roles where name = 'Customer' and status = 'active'),
  'Customer role should exist and be active'
);

select pg_temp.assert_true(
  exists (select 1 from public.roles where name = 'Vendor' and status = 'inactive'),
  'Vendor role should exist and remain inactive for future scope'
);

select pg_temp.assert_true(
  (
    select count(*)
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    where r.name = 'Super Admin'
  ) = (
    select count(*)
    from public.permissions
    where status = 'active'
  ),
  'Super Admin should have every active seeded permission'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Admin'
      and p.code = 'products.read'
  ),
  'Admin should have products.read'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Admin'
      and p.code = 'categories.restore'
  ),
  'Admin should have categories.restore'
);

select pg_temp.assert_true(
  not exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Admin'
      and p.code = 'users.manage_roles'
  ),
  'Admin should not have users.manage_roles'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Viewer'
      and p.code = 'users.read'
  ),
  'Viewer should have users.read'
);

select pg_temp.assert_true(
  exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Viewer'
      and p.code = 'orders.read_all'
  ),
  'Viewer should have orders.read_all'
);

select pg_temp.assert_true(
  not exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    join public.permissions p on p.id = rp.permission_id
    where r.name = 'Viewer'
      and p.code in (
        'products.create',
        'products.update',
        'products.delete',
        'categories.create',
        'categories.update',
        'categories.delete',
        'users.manage_roles'
      )
  ),
  'Viewer should remain read-only in permission mappings'
);

select pg_temp.assert_true(
  not exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    where r.name = 'Customer'
  ),
  'Customer should have no internal permissions'
);

select pg_temp.assert_true(
  not exists (
    select 1
    from public.role_permissions rp
    join public.roles r on r.id = rp.role_id
    where r.name = 'Vendor'
  ),
  'Vendor should have no permissions while future-scoped'
);

rollback;
