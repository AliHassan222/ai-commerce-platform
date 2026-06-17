# Helper Functions Design

## 1. Purpose

This document defines the design strategy for shared database helper functions that will support Row Level Security, ownership checks, role resolution, and public catalog visibility. It is documentation only and does not introduce SQL implementation yet.

Implementation status:

- the approved identity, role, permission, and ownership helpers in this document are implemented in `backend/supabase/migrations/004_helper_functions.sql`
- public visibility helpers remain design-only and are not implemented in the current migration

## 2. Design Goals

- provide reusable helpers for future RLS policies
- centralize identity, role, permission, and ownership logic
- reduce duplication across policy definitions
- keep ownership checks aligned with the approved auth and profile model
- support future schema evolution without forcing broad policy rewrites
- make policy behavior easier to test, review, and audit

## 3. Identity Helper Functions

### `current_profile_id()`

Purpose:

- resolve the operational `profiles.id` for the currently authenticated Supabase user

Design intent:

- standardize ownership resolution across RLS policies
- future-proof policies even if direct identity mapping changes later
- avoid embedding repeated identity lookup logic in every policy

Dependencies:

- `auth.users`
- `public.profiles`

Expected behavior:

- return the current authenticated profile id when available
- return `null` or equivalent no-access-safe behavior when unauthenticated
- never resolve another user’s identity

Usage guidance:

- preferred helper for ownership checks across `profiles`, `addresses`, `carts`, `orders`, `wishlists`, `notifications`, and related tables

### `current_user_email()`

Purpose:

- resolve the authenticated user’s trusted email from auth context

Design intent:

- support verification-aware or audit-aware policy and workflow checks
- provide a trusted email source rather than relying on client input

Dependencies:

- Supabase Auth context
- optionally `public.profiles` for consistency validation if needed

Expected behavior:

- return the current authenticated email when available
- return `null` or equivalent safe behavior when unauthenticated
- use trusted auth state as the source of truth

Usage guidance:

- useful for support logic, verification-related checks, and controlled audit or reconciliation scenarios
- should not replace `current_profile_id()` for ownership enforcement

### `is_verified_email()`

Purpose:

- determine whether the current authenticated user has a verified email

Design intent:

- centralize verification-gated access checks
- support approved restrictions on checkout, coupon use, and review submission

Dependencies:

- Supabase Auth verification state
- optionally `public.profiles` if implementation needs profile-aware consistency checks

Expected behavior:

- return `true` only when the current authenticated user has a verified email
- return `false` for unauthenticated, unresolved, or unverified users

Usage guidance:

- checkout
- coupon redemption
- review creation
- verification-gated workflows

## 4. Role Helper Functions

### `current_role_id()`

Purpose:

- resolve the current user’s `profiles.role_id`

Design intent:

- provide stable access to the effective role identifier used by RBAC
- avoid repeating joins from `profiles` to roles inside each policy

Dependencies:

- `public.profiles`

Expected behavior:

- return the current authenticated profile’s role id
- return `null` or equivalent safe behavior if no authenticated role can be resolved

Usage guidance:

- suitable when policies or helpers need role identity rather than role naming

### `current_role_code()`

Purpose:

- resolve the current user’s effective role as a stable logical code or name

Design intent:

- allow policy logic to reason about approved roles such as `super_admin`, `admin`, `viewer`, `customer`, and future `vendor`
- improve readability in policy logic compared with repeated joins

Dependencies:

- `public.profiles`
- `public.roles`

Expected behavior:

- return a stable role code or normalized role name
- return `null` or equivalent safe behavior when no role is resolved

Usage guidance:

- useful for simple role-aware branching
- should be complemented by permission helpers for higher-risk access decisions

### `current_profile_status()`

Purpose:

- resolve current profile status

Design intent:

- provide a shared helper for status-aware access enforcement
- avoid repeating direct profile status lookups in policy logic

Dependencies:

- `public.profiles`

Expected behavior:

- return one of:
  - `pending`
  - `active`
  - `suspended`
  - `inactive`
- return `null` or equivalent safe behavior when no authenticated profile status can be resolved

Usage guidance:

- useful for gating protected areas and workflow access based on profile lifecycle state

## 5. Permission Helper Functions

### `has_permission(permission_code)`

Purpose:

- determine whether the current authenticated profile has a specific permission

Design intent:

- centralize RBAC checks
- avoid hardcoding large role-specific condition trees into every policy
- allow Viewer, Admin, and Super Admin behavior to be permission-driven

Dependencies:

- `public.profiles`
- `public.roles`
- `public.permissions`
- `public.role_permissions`

Expected behavior:

- return `true` only when the current profile has the requested active permission
- return `false` when unauthenticated, unresolved, inactive, or unauthorized
- behave deterministically across environments

Usage guidance:

- preferred for permission-controlled access such as internal reads, deleted-record visibility, support access, and audit-log access
- should be used instead of relying only on raw role name checks for sensitive actions

## 6. Ownership Helper Functions

### `owns_profile(profile_id)`

Purpose:

- determine whether the given `profile_id` belongs to the current authenticated user

Design intent:

- support self-service profile operations and profile-linked access checks

Dependencies:

- `current_profile_id()`

Expected behavior:

- return `true` only when the requested profile matches the current profile
- return `false` for unauthenticated access or mismatched identity

Usage guidance:

- useful for `profiles` self-read and self-update boundaries

### `owns_cart(cart_id)`

Purpose:

- determine whether the given cart belongs to the current authenticated profile

Design intent:

- centralize cart ownership logic for `carts` and `cart_items`
- prevent repeated inline cart ownership queries

Dependencies:

- `current_profile_id()`
- `public.carts`

Expected behavior:

- return `true` only for carts owned by the current profile
- return `false` for guest, unauthenticated, or mismatched access in normal authenticated RLS paths

Usage guidance:

- should be used for `carts` and `cart_items` policies
- guest cart handling remains a backend workflow concern and should not be overexposed through anonymous RLS

### `owns_order(order_id)`

Purpose:

- determine whether the given order belongs to the current authenticated profile

Design intent:

- centralize order ownership checks for `orders`, `order_items`, and order-adjacent records

Dependencies:

- `current_profile_id()`
- `public.orders`

Expected behavior:

- return `true` only for orders owned by the current profile
- return `false` for unrelated, unauthenticated, or invalid access

Usage guidance:

- should be the default ownership helper for customer order visibility
- internal support or admin visibility should use permission-driven helpers instead of ownership helpers

## 7. Public Visibility Helpers

### `is_public_product()`

Purpose:

- encapsulate whether a product row is publicly visible

Design intent:

- make public product visibility consistent across RLS policies and queries
- reduce repeated checks for status, publishability, and soft-delete rules

Dependencies:

- `public.products`
- approved catalog status rules

Expected behavior:

- return `true` only for active, non-deleted, publicly browseable products
- return `false` for draft, inactive, archived, or soft-deleted products

Usage guidance:

- appropriate for public and customer-facing product `SELECT` conditions
- internal access should not depend solely on this helper

### `is_public_category()`

Purpose:

- encapsulate whether a category row is publicly visible

Design intent:

- standardize public category visibility across policies and browse flows

Dependencies:

- `public.categories`
- approved category status rules

Expected behavior:

- return `true` only for active, non-deleted categories intended for public browsing
- return `false` for inactive, archived, or soft-deleted categories

Usage guidance:

- appropriate for public and customer-facing category `SELECT` conditions
- internal access should use broader permission-aware rules where approved

## 8. RLS Usage Guidelines

- prefer helper-based ownership checks over repeating direct comparisons in every policy
- standardize on `current_profile_id()` for profile-linked ownership resolution
- use `has_permission(permission_code)` for internal privileged access
- keep public catalog checks behind public-visibility helpers where practical
- design helpers to fail closed, returning no-access-safe values on unresolved identity
- avoid mixing business workflow orchestration into simple row-visibility helpers
- keep sensitive multi-step operations such as checkout, coupon redemption, and notification dispatch outside direct RLS-only enforcement

## 9. Security Considerations

- helpers must never expand access for unauthenticated users by accident
- helper logic must fail closed when identity or role resolution is missing
- trusted auth context must be the source of identity and email values
- permission helpers must respect active role and permission state
- ownership helpers must not rely on client-submitted ids without authenticated context
- public-visibility helpers must respect soft-delete and status rules consistently
- helper design should minimize policy drift and reduce the risk of inconsistent access checks between tables

### Performance Considerations

- helper functions should avoid unnecessary joins
- frequently used helpers should remain lightweight
- helper design should support efficient RLS evaluation

## 10. Future Helper Functions

Potential future helpers may include:

- `owns_wishlist(wishlist_id)` for wishlist and wishlist item ownership
- `can_view_deleted_catalog()` for permission-controlled deleted-record access
- `is_vendor_owner(vendor_id)` for vendor-scoped future access
- `owns_notification(notification_id)` if notification ownership needs separate encapsulation
- `owns_address(address_id)` if address-linked support workflows need a reusable helper

Future-helper rules:

- add helpers only when they improve reuse, clarity, or security
- avoid creating helpers that hide high-risk workflow logic
- document helper purpose before implementation

## 11. Definition of Done

Helper function design is complete only when:

- identity helpers are defined
- role helpers are defined
- permission helpers are defined
- ownership helpers are defined
- public visibility helpers are defined
- RLS usage guidance is documented
- security considerations are documented
- future helper direction is documented
- the design remains aligned with approved auth and RLS strategy

## Decision Summary

- helper functions will serve as reusable building blocks for future RLS implementation
- `current_profile_id()` is the preferred ownership foundation
- role and permission helpers should separate simple role resolution from RBAC decisions
- ownership helpers should centralize self-access checks for profile-linked resources
- public visibility helpers should standardize catalog exposure rules
- the first approved helper-function implementation is now captured in `004_helper_functions.sql`
