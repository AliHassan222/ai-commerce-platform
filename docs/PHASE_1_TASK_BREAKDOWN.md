# Phase 1 Task Breakdown

## Purpose

This document breaks Phase 1 into executable implementation tasks. It is intended to serve as the execution backlog for the Supabase Foundation phase.

## Task List

## P1-T01

Task ID:

- `P1-T01`

Description:

- initialize the Supabase project structure for local development and confirm the repository layout under `backend/supabase/` is ready for migrations, policies, seed data, and functions

Dependencies:

- approved architecture
- approved Phase 1 implementation guide

Estimated Complexity:

- Low

Testing Checkpoints:

- local Supabase project initializes successfully
- required directories and config files are recognized by tooling
- local reset workflow is callable

Expected Deliverables:

- working local Supabase initialization
- repository-aligned Supabase project structure
- initial local configuration validation

## P1-T02

Task ID:

- `P1-T02`

Description:

- define and document environment configuration for local, dev, staging, and production, including secrets handling and deployment expectations

Dependencies:

- `P1-T01`

Estimated Complexity:

- Medium

Testing Checkpoints:

- environment variables required for Supabase are identified
- local configuration loads without missing required values
- no secrets are committed to the repository

Expected Deliverables:

- environment configuration matrix
- local environment setup guidance
- secure secret handling baseline

## P1-T03

Task ID:

- `P1-T03`

Description:

- configure Supabase Auth for MVP requirements, including email/password sign-in, email verification behavior, and internal-user restrictions

Dependencies:

- `P1-T01`
- `P1-T02`

Estimated Complexity:

- Medium

Testing Checkpoints:

- email/password auth is enabled
- email verification behavior matches approved rules
- public registration is customer-only
- internal users cannot self-register through public flows

Expected Deliverables:

- MVP auth configuration
- verified-email gating baseline
- internal-user creation restrictions configured

## P1-T04

Task ID:

- `P1-T04`

Description:

- execute the base schema migration `001_initial_core_ecommerce_schema.sql`

Dependencies:

- `P1-T01`
- `P1-T02`

Estimated Complexity:

- Medium

Testing Checkpoints:

- migration executes successfully
- foundational tables exist
- base constraints and indexes exist
- `profiles.id` mapping expectation remains valid

Expected Deliverables:

- base ecommerce schema applied
- validated foundational database objects

## P1-T05

Task ID:

- `P1-T05`

Description:

- execute the extension schema migration `002_ecommerce_extensions.sql`

Dependencies:

- `P1-T04`

Estimated Complexity:

- Medium

Testing Checkpoints:

- extension migration executes successfully
- `vendors`, `product_variants`, `inventory`, `coupons`, `notifications`, `wishlists`, and `product_reviews` exist
- soft-delete columns exist on `categories`, `products`, and `orders`

Expected Deliverables:

- extension schema applied
- validated extension tables and relationships

## P1-T06

Task ID:

- `P1-T06`

Description:

- execute the follow-up migration `003_add_variant_references_to_cart_and_order_items.sql`

Dependencies:

- `P1-T05`

Estimated Complexity:

- Low

Testing Checkpoints:

- migration executes successfully
- `cart_items.variant_id` exists
- `order_items.variant_id` exists
- variant reference indexes exist
- nullable compatibility is preserved

Expected Deliverables:

- variant references added to cart and order line items
- validated supporting indexes and comments

## P1-T07

Task ID:

- `P1-T07`

Description:

- implement `current_profile_id()` and validate identity resolution for RLS ownership checks

Dependencies:

- `P1-T04`

Estimated Complexity:

- Medium

Testing Checkpoints:

- helper returns current operational profile id correctly
- authenticated and unauthenticated behavior is validated
- helper is safe for repeated RLS use

Expected Deliverables:

- implemented `current_profile_id()`
- helper tests and validation notes

## P1-T08

Task ID:

- `P1-T08`

Description:

- implement `current_role_name()` and `has_permission(permission_code text)` for RBAC-aware access checks

Dependencies:

- `P1-T07`
- `P1-T11`

Estimated Complexity:

- Medium

Testing Checkpoints:

- role resolution works correctly for seeded roles
- permission checks return expected results
- admin, viewer, and super admin behavior is validated

Expected Deliverables:

- implemented RBAC helper functions
- helper tests for role and permission resolution

## P1-T09

Task ID:

- `P1-T09`

Description:

- implement `is_verified_email()` for verification-gated workflows

Dependencies:

- `P1-T03`
- `P1-T07`

Estimated Complexity:

- Medium

Testing Checkpoints:

- verified and unverified accounts are distinguished correctly
- helper behavior matches approved auth rules

Expected Deliverables:

- implemented email verification helper
- tests covering verified and unverified cases

## P1-T10

Task ID:

- `P1-T10`

Description:

- implement ownership helpers:
  - `owns_cart(cart_id uuid)`
  - `owns_order(order_id uuid)`
  - `owns_wishlist(wishlist_id uuid)`
  - `can_view_deleted_catalog()`
  - `is_vendor_owner(vendor_id uuid)`

Dependencies:

- `P1-T07`
- `P1-T08`
- `P1-T09`
- `P1-T05`
- `P1-T06`

Estimated Complexity:

- High

Testing Checkpoints:

- ownership checks reject unrelated resources
- deleted catalog visibility is permission-controlled
- vendor helper behaves safely in future-scoped scenarios

Expected Deliverables:

- implemented ownership and visibility helpers
- helper tests across customer, viewer, admin, super admin, and vendor scenarios

## P1-T11

Task ID:

- `P1-T11`

Description:

- implement foundational seed data for roles, permissions, and role-permission mappings

Dependencies:

- `P1-T04`

Estimated Complexity:

- Medium

Testing Checkpoints:

- all required roles are created
- permissions match the approved permission matrix
- role-permission mappings validate expected access baselines

Expected Deliverables:

- seeded roles
- seeded permissions
- seeded role-permission mappings

## P1-T12

Task ID:

- `P1-T12`

Description:

- implement secure bootstrap for the default Super Admin and define the recovery-aware seed process

Dependencies:

- `P1-T11`
- `P1-T03`

Estimated Complexity:

- High

Testing Checkpoints:

- Super Admin bootstrap works without hardcoded secrets
- public registration does not create internal roles
- recovery assumptions are documented and validated procedurally

Expected Deliverables:

- secure Super Admin bootstrap flow
- auditable admin bootstrap guidance

## P1-T13

Task ID:

- `P1-T13`

Description:

- seed deterministic sample categories, products, and coupons for development and validation

Dependencies:

- `P1-T05`
- `P1-T06`

Estimated Complexity:

- Medium

Testing Checkpoints:

- sample categories load correctly
- sample products cover active and non-public states
- sample coupons cover active, expired, and ineligible states

Expected Deliverables:

- seeded sample catalog
- seeded sample coupons
- deterministic validation dataset

## P1-T14

Task ID:

- `P1-T14`

Description:

- implement RLS for `profiles`

Dependencies:

- `P1-T07`
- `P1-T08`
- `P1-T09`
- `P1-T11`

Estimated Complexity:

- High

Testing Checkpoints:

- customers can read only own profile
- privileged fields are protected
- admin, viewer, and super admin read boundaries are validated

Expected Deliverables:

- `profiles` RLS policies
- profile ownership and RBAC test coverage

## P1-T15

Task ID:

- `P1-T15`

Description:

- implement RLS for `addresses`

Dependencies:

- `P1-T14`

Estimated Complexity:

- Medium

Testing Checkpoints:

- customers can access only own addresses
- viewer has no default access
- admin support visibility is read-only and permission-gated

Expected Deliverables:

- `addresses` RLS policies
- address ownership tests

## P1-T16

Task ID:

- `P1-T16`

Description:

- implement RLS for catalog visibility on `products`, and supporting public-read alignment for categories, product images, product variants, and published reviews as needed for MVP catalog access

Dependencies:

- `P1-T08`
- `P1-T10`
- `P1-T13`

Estimated Complexity:

- High

Testing Checkpoints:

- public reads expose only active, non-deleted catalog records
- deleted and inactive catalog states are hidden
- internal deleted-record visibility is permission-controlled

Expected Deliverables:

- catalog visibility policy set
- public vs internal catalog access validation

## P1-T17

Task ID:

- `P1-T17`

Description:

- implement RLS for `carts` and `cart_items`

Dependencies:

- `P1-T10`
- `P1-T16`

Estimated Complexity:

- High

Testing Checkpoints:

- customers can access only own carts and cart items
- cart item access is derived from parent cart ownership
- guest cart logic remains backend-safe and not overexposed through direct anonymous access

Expected Deliverables:

- `carts` RLS policies
- `cart_items` RLS policies
- cart ownership tests

## P1-T18

Task ID:

- `P1-T18`

Description:

- implement RLS for `orders` and `order_items`

Dependencies:

- `P1-T09`
- `P1-T10`
- `P1-T17`

Estimated Complexity:

- High

Testing Checkpoints:

- customers can read only own orders and order items
- unverified users cannot create orders through approved workflows
- support visibility and internal read boundaries are validated

Expected Deliverables:

- `orders` RLS policies
- `order_items` RLS policies
- order ownership and internal access tests

## P1-T19

Task ID:

- `P1-T19`

Description:

- implement RLS for `wishlists` and `notifications`

Dependencies:

- `P1-T10`
- `P1-T17`

Estimated Complexity:

- Medium

Testing Checkpoints:

- customers can access only own wishlists and wishlist contents
- customers can read only own notifications
- clients cannot directly create notifications

Expected Deliverables:

- `wishlists` RLS policies
- `wishlist_items` RLS policies
- `notifications` RLS policies

## P1-T20

Task ID:

- `P1-T20`

Description:

- implement RLS for `product_reviews`

Dependencies:

- `P1-T09`
- `P1-T16`

Estimated Complexity:

- Medium

Testing Checkpoints:

- public can read only published reviews
- customers can manage only own pending reviews
- unverified customers cannot submit reviews
- moderation paths are permission-controlled

Expected Deliverables:

- `product_reviews` RLS policies
- review visibility and moderation tests

## P1-T21

Task ID:

- `P1-T21`

Description:

- configure Supabase Storage for the `product-images` bucket and align storage access with approved security rules

Dependencies:

- `P1-T01`
- `P1-T02`
- `P1-T16`

Estimated Complexity:

- Medium

Testing Checkpoints:

- public can read approved product media only
- customers cannot upload directly
- admin upload path is authenticated and permission-controlled
- storage rules align with database RBAC expectations

Expected Deliverables:

- configured `product-images` bucket
- storage access configuration
- storage security validation results

## P1-T22

Task ID:

- `P1-T22`

Description:

- execute Phase 1 validation and testing across migrations, helpers, RLS, seed data, and storage

Dependencies:

- `P1-T04`
- `P1-T05`
- `P1-T06`
- `P1-T07`
- `P1-T08`
- `P1-T09`
- `P1-T10`
- `P1-T11`
- `P1-T12`
- `P1-T13`
- `P1-T14`
- `P1-T15`
- `P1-T16`
- `P1-T17`
- `P1-T18`
- `P1-T19`
- `P1-T20`
- `P1-T21`

Estimated Complexity:

- High

Testing Checkpoints:

- migration testing passes
- helper function testing passes
- RLS testing passes
- seed data validation passes
- security validation passes

Expected Deliverables:

- Phase 1 validation report
- passing Phase 1 test results
- implementation readiness for Phase 2

## Suggested Execution Sequence

1. `P1-T01` through `P1-T03`
2. `P1-T04` through `P1-T06`
3. `P1-T11` through `P1-T13`
4. `P1-T07` through `P1-T10`
5. `P1-T14` through `P1-T20`
6. `P1-T21`
7. `P1-T22`

## Completion Rule

Phase 1 is not complete until all critical tasks are implemented, validated, and their tests are passing.
