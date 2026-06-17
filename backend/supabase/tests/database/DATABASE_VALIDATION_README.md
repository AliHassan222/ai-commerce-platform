# Database Validation Foundation

## Purpose

This directory contains the Phase 1 database validation foundation, including executable SQL tests and supporting validation documents.

## Files

- `HELPER_FUNCTION_TEST_CASES.md`
- `RLS_TEST_CASES.md`
- `RBAC_TEST_CASES.md`
- `SEED_VALIDATION_CHECKLIST.md`
- `sql/README.md`
- `sql/helper_functions.test.sql`
- `sql/rls_public_access.test.sql`
- `sql/rls_customer_ownership.test.sql`
- `sql/rbac_permissions.test.sql`
- `sql/seed_validation.test.sql`
- `sql/auth_profile_creation.test.sql`

## Validation Scope

The database validation foundation covers:

- approved migrations through `008_auth_profile_auto_creation.sql`
- approved helper functions from `004_helper_functions.sql`
- approved Phase 1 RLS baseline, category RLS completion, and catalog-detail RLS completion
- approved seed foundation for roles, permissions, categories, products, and personas
- approved auth profile auto-creation trigger behavior

## Goals

- confirm helper functions behave correctly
- confirm RLS policies enforce public, ownership, and internal access boundaries
- confirm RBAC seed mappings align with the approved permission matrix
- confirm seed data remains deterministic and replay-safe
- confirm `auth.users` inserts create matching `public.profiles` rows with approved defaults

## Recommended Validation Order

1. replay migrations in order
2. apply seed foundation
3. run executable SQL tests under `sql/`
4. validate helper function outputs
5. validate RBAC seed mappings
6. validate RLS behavior by role and persona
7. confirm replay safety and deterministic seed outcomes

## Current Gaps To Expect

- checkout-specific database validation remains limited because direct order creation is intentionally blocked pending protected backend workflows
- notification dispatch behavior is out of scope because dispatch logic is not implemented
- support-style admin access without explicit permission mapping remains intentionally fail-closed
- executable tests currently target the approved Phase 1 database scope and not later application or Edge Function workflows

## Exit Criteria

Database validation is ready for application development only when:

- helper functions pass expected behavior checks
- RLS policies pass public, ownership, internal access, and denied-access checks
- RBAC mappings match the approved seed design
- seed validation checklist passes
- auth profile auto-creation checks pass
- no unexpected access leaks or replay inconsistencies are found
