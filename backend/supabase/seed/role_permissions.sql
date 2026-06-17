-- Foundational role-permission mappings for Phase 1.
-- Deterministic and replay-safe through ON CONFLICT handling.

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id
from public.roles r
join public.permissions p on true
where r.name = 'Super Admin'
on conflict (role_id, permission_id) do nothing;

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id
from public.roles r
join public.permissions p
  on p.code in (
    'products.read',
    'products.create',
    'products.update',
    'products.publish',
    'products.delete',
    'products.restore',
    'categories.read',
    'categories.create',
    'categories.update',
    'categories.delete',
    'categories.restore',
    'orders.read_all',
    'orders.update_status',
    'reviews.read',
    'reviews.moderate',
    'reviews.hide',
    'reviews.delete'
  )
where r.name = 'Admin'
on conflict (role_id, permission_id) do nothing;

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id
from public.roles r
join public.permissions p
  on p.code in (
    'users.read',
    'products.read',
    'categories.read',
    'orders.read_all',
    'reviews.read'
  )
where r.name = 'Viewer'
on conflict (role_id, permission_id) do nothing;

-- Customer intentionally receives no internal permissions in the Phase 1 foundation.
