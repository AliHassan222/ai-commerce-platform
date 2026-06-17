-- Foundational product seed data for Phase 1.
-- Deterministic and replay-safe through ON CONFLICT handling.
-- Includes active, draft, and soft-deleted records for admin and RLS testing.

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
