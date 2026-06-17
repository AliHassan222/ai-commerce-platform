-- Supabase CLI seed entrypoint.
-- This file is plain SQL and preserves the approved deterministic seed order.

-- 1. roles.sql
insert into public.roles (name, description, status)
values
  ('Super Admin', 'Full platform control across internal administration and operations.', 'active'),
  ('Admin', 'Operational management role for day-to-day platform administration.', 'active'),
  ('Viewer', 'Read-only internal role for operational visibility.', 'active'),
  ('Customer', 'End-user role for self-service commerce access.', 'active'),
  ('Vendor', 'Future marketplace seller role scoped to vendor-owned resources.', 'inactive')
on conflict (name) do update
set
  description = excluded.description,
  status = excluded.status;

-- 2. permissions.sql
insert into public.permissions (code, name, description, status)
values
  ('users.read', 'Read Users', 'Read user and profile records where permitted.', 'active'),
  ('users.update', 'Update Users', 'Update user records where permitted.', 'active'),
  ('users.manage_roles', 'Manage User Roles', 'Assign and manage internal roles.', 'active'),

  ('products.read', 'Read Products', 'Read product records, including internal product visibility where permitted.', 'active'),
  ('products.create', 'Create Products', 'Create product records.', 'active'),
  ('products.update', 'Update Products', 'Update product records.', 'active'),
  ('products.publish', 'Publish Products', 'Publish or activate products for storefront visibility.', 'active'),
  ('products.delete', 'Delete Products', 'Soft delete or archive products where approved.', 'active'),
  ('products.restore', 'Restore Products', 'Restore previously soft-deleted or archived products.', 'active'),

  ('orders.read_all', 'Read All Orders', 'Read all customer orders for internal operations.', 'active'),
  ('orders.update_status', 'Update Order Status', 'Update order workflow status through approved internal workflows.', 'active'),

  ('reviews.read', 'Read Reviews', 'Read all product reviews for internal visibility.', 'active'),
  ('reviews.moderate', 'Moderate Reviews', 'Moderate review lifecycle states.', 'active'),
  ('reviews.hide', 'Hide Reviews', 'Hide reviews from public visibility.', 'active'),
  ('reviews.delete', 'Delete Reviews', 'Delete or remove reviews where approved.', 'active'),

  ('categories.read', 'Read Categories', 'Read category records, including internal category visibility where permitted.', 'active'),
  ('categories.create', 'Create Categories', 'Create category records.', 'active'),
  ('categories.update', 'Update Categories', 'Update category records.', 'active'),
  ('categories.delete', 'Delete Categories', 'Soft delete or archive categories where approved.', 'active'),
  ('categories.restore', 'Restore Categories', 'Restore previously soft-deleted or archived categories.', 'active')
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  status = excluded.status;

-- 3. role_permissions.sql
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

-- 4. users.sql
-- Phase 1 documented seed personas only.
-- This section intentionally does not create auth.users records or real passwords.
-- Use these examples as placeholders for controlled non-production setup.

-- Active verified customer
-- auth email placeholder: customer.verified@example.test
-- profile role: Customer
-- profile status: active
-- email verification: verified

-- Active unverified customer
-- auth email placeholder: customer.unverified@example.test
-- profile role: Customer
-- profile status: pending or active based on environment policy
-- email verification: not verified

-- Suspended customer
-- auth email placeholder: customer.suspended@example.test
-- profile role: Customer
-- profile status: suspended
-- email verification: verified

-- Viewer
-- auth email placeholder: viewer.internal@example.test
-- profile role: Viewer
-- profile status: active
-- email verification: verified

-- Admin
-- auth email placeholder: admin.internal@example.test
-- profile role: Admin
-- profile status: active
-- email verification: verified

-- Super Admin
-- auth email placeholder: superadmin.internal@example.test
-- profile role: Super Admin
-- profile status: active
-- email verification: verified

-- Important:
-- - Do not store real passwords in repository seed files.
-- - Do not create auth users through raw seed SQL in this file.
-- - Create non-production auth identities through approved local or environment setup workflows.

-- 5. categories.sql
with root_categories as (
  insert into public.categories (name, slug, description, status, sort_order)
  values
    ('Electronics', 'electronics', 'Consumer electronics and devices.', 'active', 10),
    ('Fashion', 'fashion', 'Clothing, style, and accessories.', 'active', 20),
    ('Home & Kitchen', 'home-kitchen', 'Home appliances and kitchen essentials.', 'active', 30)
  on conflict (slug) do update
  set
    name = excluded.name,
    description = excluded.description,
    status = excluded.status,
    sort_order = excluded.sort_order
  returning id, slug
)
insert into public.categories (parent_id, name, slug, description, status, sort_order)
values
  ((select id from public.categories where slug = 'electronics'), 'Mobiles', 'mobiles', 'Smartphones and mobile accessories.', 'active', 11),
  ((select id from public.categories where slug = 'electronics'), 'Laptops', 'laptops', 'Portable computers and laptop accessories.', 'active', 12)
on conflict (slug) do update
set
  parent_id = excluded.parent_id,
  name = excluded.name,
  description = excluded.description,
  status = excluded.status,
  sort_order = excluded.sort_order;

-- 6. products.sql
insert into public.products (
  category_id,
  sku,
  name,
  slug,
  short_description,
  description,
  price_amount,
  currency_code,
  status,
  ai_enriched,
  deleted_at
)
values
  (
    (select id from public.categories where slug = 'mobiles'),
    'PHONE-001',
    'Nova X Smartphone',
    'nova-x-smartphone',
    'Flagship smartphone for storefront testing.',
    'Active mobile product used for public browsing, cart, and order visibility tests.',
    799.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'mobiles'),
    'PHONE-002',
    'Orbit Mini Smartphone',
    'orbit-mini-smartphone',
    'Compact smartphone test product.',
    'Active mobile product used for category and public catalog testing.',
    499.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'laptops'),
    'LAPTOP-001',
    'AeroBook 14',
    'aerobook-14',
    'Lightweight laptop for active catalog coverage.',
    'Active laptop product used for admin and customer catalog flows.',
    1099.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'laptops'),
    'LAPTOP-002',
    'WorkPro 16',
    'workpro-16',
    'Performance laptop test product.',
    'Active laptop product used for order and review visibility scenarios.',
    1499.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'fashion'),
    'FASHION-001',
    'Classic Denim Jacket',
    'classic-denim-jacket',
    'Active fashion product for storefront testing.',
    'Active apparel item used for category breadth and cart scenarios.',
    89.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'home-kitchen'),
    'HOME-001',
    'ChefMaster Blender',
    'chefmaster-blender',
    'Kitchen appliance product for active catalog coverage.',
    'Active home product used for mixed-category storefront testing.',
    129.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'electronics'),
    'AUDIO-001',
    'Pulse Wireless Earbuds',
    'pulse-wireless-earbuds',
    'Audio accessory product for active catalog coverage.',
    'Active electronics product used for catalog breadth and wishlist scenarios.',
    159.00,
    'USD',
    'active',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'electronics'),
    'DEVICE-DRAFT-001',
    'Prototype Smart Display',
    'prototype-smart-display',
    'Draft-only product for internal visibility testing.',
    'Draft product used to validate that public RLS does not expose non-public catalog items.',
    249.00,
    'USD',
    'draft',
    false,
    null
  ),
  (
    (select id from public.categories where slug = 'electronics'),
    'DEVICE-DEL-001',
    'Legacy Smart Camera',
    'legacy-smart-camera',
    'Soft-deleted product for admin and RLS testing.',
    'Soft-deleted product used to validate deleted catalog filtering behavior.',
    199.00,
    'USD',
    'inactive',
    false,
    '2026-01-01 00:00:00+00'::timestamptz
  )
on conflict (slug) do update
set
  category_id = excluded.category_id,
  sku = excluded.sku,
  name = excluded.name,
  short_description = excluded.short_description,
  description = excluded.description,
  price_amount = excluded.price_amount,
  currency_code = excluded.currency_code,
  status = excluded.status,
  ai_enriched = excluded.ai_enriched,
  deleted_at = excluded.deleted_at;
