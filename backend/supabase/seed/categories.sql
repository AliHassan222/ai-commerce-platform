-- Foundational category seed data for Phase 1.
-- Deterministic and replay-safe through ON CONFLICT handling.

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
