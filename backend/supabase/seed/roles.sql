-- Foundational role seed data for Phase 1.
-- Deterministic and replay-safe through ON CONFLICT handling.

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
