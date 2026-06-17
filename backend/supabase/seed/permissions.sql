-- Foundational permission seed data for Phase 1.
-- Deterministic and replay-safe through ON CONFLICT handling.

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
