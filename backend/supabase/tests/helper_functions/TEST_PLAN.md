# Helper Functions Test Plan

## Purpose

This document defines the planned validation scope for helper functions introduced in `004_helper_functions.sql`.

## Scope

Functions under test:

- `current_profile_id()`
- `current_user_email()`
- `is_verified_email()`
- `current_role_id()`
- `current_role_code()`
- `current_profile_status()`
- `has_permission(permission_code text)`
- `owns_profile(target_profile_id uuid)`
- `owns_cart(target_cart_id uuid)`
- `owns_order(target_order_id uuid)`

## Test Categories

### Authentication Context Tests

- authenticated user resolves own profile id
- unauthenticated execution fails closed
- authenticated user resolves trusted email
- verified and unverified email states return correct boolean values

### Role Resolution Tests

- current role id resolves correctly from seeded profile
- current role code returns normalized expected value
- current profile status returns `pending`, `active`, `suspended`, and `inactive` correctly

### Permission Tests

- active permission returns `true`
- missing permission returns `false`
- inactive role or inactive permission returns `false`
- unauthenticated access returns `false`

### Ownership Tests

- `owns_profile()` returns `true` for self and `false` for other profiles
- `owns_cart()` returns `true` for owned carts and `false` for unowned carts
- `owns_order()` returns `true` for owned orders and `false` for unowned orders
- ownership helpers fail closed for `null`, invalid, or unauthenticated contexts

### RLS Reuse Readiness Tests

- helper functions execute successfully before RLS is enabled
- helper functions remain side-effect free
- helper functions are lightweight enough for repeated RLS evaluation

## Seed Dependencies

Required test fixtures:

- active customer profile
- unverified customer profile
- suspended or inactive profile
- active Admin, Viewer, and Super Admin role assignments
- permission mappings for positive and negative `has_permission()` tests
- owned and unowned carts
- owned and unowned orders

## Expected Validation Method

- run migration replay in a clean local environment
- seed deterministic identities, roles, permissions, carts, and orders
- validate helper output with direct SQL assertions or automated database test scripts in a later task

## Out of Scope

- RLS policy enforcement tests
- Edge Function behavior
- trigger behavior
- production environment validation
