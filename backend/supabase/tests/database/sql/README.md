# Database SQL Tests

## Purpose

This directory contains executable Phase 1 database tests for the local Supabase foundation.

## Test Approach

- plain SQL scripts with transactional setup and assertion blocks
- no pgTAP dependency is required
- each script starts a transaction and ends with `ROLLBACK` so local test data does not persist
- scripts are designed to run after `supabase db reset`

## Files

- `helper_functions.test.sql`
- `rls_public_access.test.sql`
- `rls_customer_ownership.test.sql`
- `rbac_permissions.test.sql`
- `seed_validation.test.sql`
- `auth_profile_creation.test.sql`

## Run Order

1. `helper_functions.test.sql`
2. `rls_public_access.test.sql`
3. `rls_customer_ownership.test.sql`
4. `rbac_permissions.test.sql`
5. `seed_validation.test.sql`
6. `auth_profile_creation.test.sql`

## Local Run Commands

Run from `backend/supabase` after resetting the local stack:

```powershell
cmd /c supabase db reset
cmd /c "supabase db shell < tests\database\sql\helper_functions.test.sql"
cmd /c "supabase db shell < tests\database\sql\rls_public_access.test.sql"
cmd /c "supabase db shell < tests\database\sql\rls_customer_ownership.test.sql"
cmd /c "supabase db shell < tests\database\sql\rbac_permissions.test.sql"
cmd /c "supabase db shell < tests\database\sql\seed_validation.test.sql"
cmd /c "supabase db shell < tests\database\sql\auth_profile_creation.test.sql"
```

If a script finishes without an error, that test script passes.

## Coverage Summary

- helper function resolution and fail-closed behavior
- anonymous public catalog visibility
- customer ownership boundaries and denied cross-user access
- RBAC role and permission mappings
- deterministic seed presence and seed-state expectations
- `auth.users` to `public.profiles` auto-creation and profile email drift protection
