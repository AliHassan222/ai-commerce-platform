# Seed Foundation

## Purpose

This directory contains the approved Phase 1 seed foundation for roles, permissions, role mappings, documented user personas, categories, and products.

## Files

- `roles.sql`
- `permissions.sql`
- `role_permissions.sql`
- `users.sql`
- `categories.sql`
- `products.sql`

## Execution Order

1. `roles.sql`
2. `permissions.sql`
3. `role_permissions.sql`
4. `users.sql`
5. `categories.sql`
6. `products.sql`

## Notes

- seed files are deterministic and intended for replayable non-production setup
- `users.sql` is documentation-only and does not create `auth.users` records
- no real passwords or production identities should be stored here
- product seed data includes active, draft, and soft-deleted records for RLS and admin testing
- customer role intentionally receives no internal permissions in this seed foundation
