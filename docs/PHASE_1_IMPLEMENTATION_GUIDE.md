# Phase 1 Implementation Guide

## 1. Phase Objective

### Goals

- establish the Supabase backend foundation for the platform
- create a repeatable environment and migration workflow
- implement the first secure identity and ownership helpers
- implement the MVP RLS baseline for approved tables
- prepare seed data required for internal and customer flows

### Scope

- Supabase project setup
- environment setup and configuration strategy
- execution of approved schema migrations
- implementation planning for helper functions
- implementation order for RLS policies
- foundational storage setup
- seed data definition and validation
- Phase 1 testing and rollback readiness

### Deliverables

- working Supabase project configuration for all target environments
- executed migration chain in the approved order
- approved helper function implementation roadmap translated into implementation tasks
- initial RLS rollout for MVP tables
- configured `product-images` bucket
- foundational seed data for roles, permissions, admin bootstrap, categories, products, and coupons
- passing Phase 1 test suite for migrations, helper functions, RLS, seed data, and security checks

### Success Criteria

- Supabase project is created and reachable in local, dev, staging, and production contexts
- all approved migrations execute successfully in order
- helper functions are implemented and validated
- RLS is enabled and validated on the planned MVP tables
- storage bucket configuration matches approved security rules
- seed data loads successfully and passes validation checks
- Phase 1 test suite passes

## 2. Supabase Project Setup

### Project Creation Steps

1. Create the Supabase project for the first shared environment.
2. Define project naming convention for all environments.
3. Initialize local Supabase configuration under `backend/supabase/`.
4. Verify PostgreSQL, Auth, Storage, and Edge Functions are enabled.
5. Configure environment-specific connection and service credentials outside the repository.
6. Confirm migration execution and local reset workflows.

### Required Services

- PostgreSQL database
- Supabase Auth
- Supabase Storage
- Edge Functions
- environment-specific secrets and project configuration

### Environment Variables

Minimum categories of environment configuration:

- Supabase project URL
- Supabase anon key
- Supabase service role key
- database connection values for migration and administration workflows
- storage bucket configuration values if needed by implementation tooling
- Firebase Cloud Messaging credentials placeholders for later phases

Rules:

- secrets must never be committed
- local values should live in local-only environment files
- staging and production secrets must be managed through secure deployment secret storage

### Authentication Configuration

- enable email/password authentication for MVP
- configure email verification behavior according to approved auth rules
- ensure `profiles` auto-creation is implemented by database trigger or secured backend workflow
- default role must be `Customer`
- default status must be `pending` or `active` depending on verification policy
- internal users must not self-register through the public app

### Storage Configuration

- create the `product-images` bucket
- configure public read only for approved storefront-ready media
- keep upload and mutation paths restricted to approved admin workflows
- document vendor-scoped path rules as future-only, not active in MVP

## 3. Environment Strategy

### local

Purpose:

- developer setup, schema iteration, helper-function development, RLS development, and seed validation

Configuration:

- local Supabase stack
- local environment files only
- deterministic local seed data
- resettable database state

Deployment Expectations:

- developers can reset and replay migrations freely
- local environment is disposable and must not contain real production data

### dev

Purpose:

- shared integration environment for backend and admin/mobile contract validation

Configuration:

- shared Supabase project
- controlled seed data
- initial integration-ready auth, storage, and RLS configuration

Deployment Expectations:

- changes are deployed frequently
- schema and policy changes must still come through approved migrations and controlled rollout

### staging

Purpose:

- production-like validation for release readiness

Configuration:

- production-like settings
- near-final RLS, seed, storage, and auth configuration
- release candidate test data only

Deployment Expectations:

- only validated migration chains and tested seeds should be promoted here
- smoke, regression, and security validation should run here before release

### production

Purpose:

- live customer and internal business operations

Configuration:

- locked-down secrets and credentials
- production-grade storage, auth, and RLS configuration
- minimal and carefully controlled seed/bootstrap data

Deployment Expectations:

- migration rollout must be deliberate and reversible
- seed and support actions must be auditable
- no ad hoc schema changes

## 4. Migration Execution Plan

### Execution Order

1. `001_initial_core_ecommerce_schema.sql`
2. `002_ecommerce_extensions.sql`
3. `003_add_variant_references_to_cart_and_order_items.sql`

### Dependencies

#### `001_initial_core_ecommerce_schema.sql`

- must run first
- creates the foundational tables, timestamps function, and base indexes
- establishes `profiles`, catalog core, carts, orders, and audit tables

#### `002_ecommerce_extensions.sql`

- depends on base tables from `001`
- adds `vendors`, `product_variants`, `inventory`, `coupons`, `order_coupons`, `notifications`, `wishlists`, `wishlist_items`, `product_reviews`
- adds soft-delete support to `categories`, `products`, and `orders`

#### `003_add_variant_references_to_cart_and_order_items.sql`

- depends on `product_variants` from `002`
- adds nullable `variant_id` to `cart_items` and `order_items`
- adds supporting indexes and documentation comments

### Validation Checkpoints

After `001`:

- verify all base tables exist
- verify `profiles.id` maps to `auth.users.id`
- verify base constraints and indexes exist
- verify timestamp trigger function exists

After `002`:

- verify extension tables exist
- verify `deleted_at` fields exist on `categories`, `products`, and `orders`
- verify `vendors`, `product_variants`, and `inventory` foreign keys are valid
- verify indexes and triggers exist for added tables

After `003`:

- verify `cart_items.variant_id` exists
- verify `order_items.variant_id` exists
- verify both new indexes exist
- verify nullable behavior is preserved

### Rollback Considerations

- historical migrations must not be edited retroactively
- failed local or dev migration runs should use environment reset and replay
- staging and production rollback should prefer:
  - restoring from backup when required
  - rolling forward with corrective migrations when safer than destructive rollback
- RLS or seed failures should be isolated from schema rollback where possible

## 5. Helper Functions Roadmap

### `current_profile_id()`

Purpose:

- resolve the operational profile id for the authenticated user

Dependencies:

- `profiles`
- `auth.users`

Security Considerations:

- must return only the current authenticated profile
- should be safe to use broadly across RLS policies

### `current_role_name()`

Purpose:

- resolve the effective role name for the current profile

Dependencies:

- `profiles`
- `roles`

Security Considerations:

- must not allow spoofing of role resolution
- should be deterministic and read-only

### `has_permission(permission_code text)`

Purpose:

- evaluate whether the current profile has a specific RBAC permission

Dependencies:

- `profiles`
- `roles`
- `permissions`
- `role_permissions`

Security Considerations:

- must remain side-effect free
- should become the standard RBAC helper for admin-sensitive RLS rules

### `is_verified_email()`

Purpose:

- enforce verification-gated actions such as checkout, coupon usage, and review submission

Dependencies:

- Supabase Auth email verification state
- `profiles` status rules as needed

Security Considerations:

- must read trusted verification state only
- should not be derived from client-submitted values

### `owns_cart(cart_id uuid)`

Purpose:

- determine whether the current profile owns a cart

Dependencies:

- `carts`
- `current_profile_id()`

Security Considerations:

- must support strict ownership checks
- guest-cart logic must still remain backend-controlled where needed

### `owns_order(order_id uuid)`

Purpose:

- determine whether the current profile owns an order

Dependencies:

- `orders`
- `current_profile_id()`

Security Considerations:

- must exclude access to unrelated orders
- should work cleanly with soft-delete-aware policy logic

### `owns_wishlist(wishlist_id uuid)`

Purpose:

- determine whether the current profile owns a wishlist

Dependencies:

- `wishlists`
- `current_profile_id()`

Security Considerations:

- must be used for both wishlist and wishlist item policy enforcement

### `can_view_deleted_catalog()`

Purpose:

- control permission-based access to deleted catalog records

Dependencies:

- role and permission helpers
- `products`
- `categories`

Security Considerations:

- should be limited to explicitly permitted internal roles
- must not leak deleted catalog data publicly

### `is_vendor_owner(vendor_id uuid)`

Purpose:

- prepare future vendor-scoped access checks

Dependencies:

- `vendors`
- `profiles`
- `current_profile_id()`

Security Considerations:

- future-scoped only for MVP
- should not be activated broadly until vendor workflows are approved

## 6. RLS Implementation Order

### Order

1. `profiles`
2. `addresses`
3. `products`
4. `carts`
5. `cart_items`
6. `orders`
7. `order_items`
8. `wishlists`
9. `notifications`
10. `product_reviews`

### `profiles`

Select policies:

- self-read for customer and vendor profile ownership
- internal read by role and permission

Insert policies:

- usually backend or trigger driven only

Update policies:

- self-service limited updates
- internal privileged updates by RBAC

Delete policies:

- generally disallowed

Validation strategy:

- verify customer cannot edit role or privileged status
- verify admin and super admin boundaries

### `addresses`

Select policies:

- own addresses only
- explicit admin support read if permitted

Insert policies:

- own addresses only

Update policies:

- own addresses only
- limited support correction path if intentionally allowed

Delete policies:

- own delete or archive only by business rules

Validation strategy:

- verify no cross-account address access
- verify viewer has no default access

### `products`

Select policies:

- public active, non-deleted read
- internal broader read by RBAC

Insert policies:

- admin and super admin only

Update policies:

- admin and super admin by RBAC

Delete policies:

- soft delete and restore only through permission-controlled rules

Validation strategy:

- verify public exclusion of deleted and inactive products
- verify internal deleted-record access is permission-controlled

### `carts`

Select policies:

- own carts only

Insert policies:

- own authenticated carts only

Update policies:

- own carts only

Delete policies:

- own carts only where allowed

Validation strategy:

- verify ownership through `current_profile_id()`
- verify guest cart logic is not exposed through unsafe anonymous access

### `cart_items`

Select policies:

- items only within owned carts

Insert policies:

- only into owned carts

Update policies:

- only within owned carts

Delete policies:

- only within owned carts

Validation strategy:

- verify derived ownership through parent cart
- verify variant-aware item handling remains safe

### `orders`

Select policies:

- own orders for customers
- RBAC-based internal read for Viewer, Admin, and Super Admin

Insert policies:

- no direct client insert
- backend checkout workflow only

Update policies:

- protected workflow only for status transitions

Delete policies:

- no direct customer delete
- internal soft-delete only if explicitly allowed

Validation strategy:

- verify unverified customers cannot create orders
- verify support visibility and internal read boundaries

### `order_items`

Select policies:

- items only through owned orders or permitted internal access

Insert policies:

- backend order creation only

Update policies:

- protected internal workflow only

Delete policies:

- backend-controlled only

Validation strategy:

- verify no orphaned order item visibility
- verify parent-order ownership derivation

### `wishlists`

Select policies:

- own wishlists only

Insert policies:

- own wishlists only

Update policies:

- own wishlists only

Delete policies:

- own wishlists only

Validation strategy:

- verify support visibility is not broad by default

### `notifications`

Select policies:

- own notifications only
- internal troubleshooting read only if explicitly permitted

Insert policies:

- backend, Edge Function, or service-role only

Update policies:

- own read-state updates only if supported

Delete policies:

- no direct customer delete

Validation strategy:

- verify customer can only read own notifications
- verify client cannot directly create notifications

### `product_reviews`

Select policies:

- public published reviews only
- customer own reviews plus published reviews
- internal moderation visibility by RBAC

Insert policies:

- own review only
- verified email required

Update policies:

- own pending reviews only
- internal moderation updates by RBAC

Delete policies:

- customer own delete or hide only if permitted
- admin moderation delete or hide by RBAC

Validation strategy:

- verify unverified customers cannot submit reviews
- verify moderation states cannot be bypassed

## 7. Seed Data Plan

### Required Seed Groups

- roles
- permissions
- role_permissions
- default super admin
- sample categories
- sample products
- sample coupons

### Roles

Seed:

- Super Admin
- Admin
- Viewer
- Customer
- Vendor

### Permissions

Seed permissions aligned with approved matrix, including:

- product permissions
- category permissions
- order permissions
- user permissions
- vendor permissions
- review permissions
- coupon permissions
- report permissions
- audit log read if required

### Role Permissions

- assign full platform permissions to Super Admin
- assign operational permissions to Admin
- assign read-only internal visibility permissions to Viewer
- keep Customer and Vendor minimal and future-safe

### Default Super Admin

- create only through secure bootstrap process
- do not hardcode unsafe credentials in repository
- use environment-driven bootstrap values for first setup

### Super Admin Recovery Strategy

- define a documented recovery process if the initial Super Admin account is lost
- recovery must require direct database or platform owner intervention
- recovery actions must be auditable
- recovery must not rely on public registration flows
- emergency recovery procedures should be documented separately from normal admin onboarding

### Sample Categories

- create deterministic sample categories for testing catalog and RLS

### Sample Products

- create sample products with variants and media-ready references
- include active and non-public states for policy testing

### Sample Coupons

- create test coupons covering active, expired, and ineligible scenarios

## 8. Storage Setup Plan

### product-images Bucket

- create `product-images` bucket
- use it for approved product media only

### Access Rules

- public read only for approved media intended for storefront or mobile display
- no unrestricted public write access

### Upload Permissions

- admin uploads only in MVP
- use authenticated and permission-controlled upload workflows
- prefer signed or protected upload patterns over broad direct write access

### Storage RLS Strategy

- anonymous users may read only public product images
- customers cannot upload directly to `product-images`
- admins upload through authenticated and permission-controlled workflows
- storage policies must align with database RBAC rules
- storage access must be tested as part of Phase 1 security validation

### Naming Conventions

- use deterministic, collision-safe path conventions
- include stable path grouping by entity or upload context
- keep names compatible with future vendor-scoped path partitioning

### Lifecycle Considerations

- plan for replace, archive, and cleanup workflows
- avoid orphaned files when product images are removed or replaced
- keep storage visibility aligned with product and image publish state

## 9. Testing Plan For Phase 1

### Migration Testing

- verify migrations execute in approved order
- verify schema objects, constraints, indexes, and comments exist
- verify repeatable local reset and replay behavior

### Helper Function Testing

- test each helper function for correct ownership and permission resolution
- test authenticated, unauthenticated, and role-specific paths

### RLS Testing

- validate public access rules
- validate customer ownership boundaries
- validate Viewer, Admin, and Super Admin access differences
- validate denied access for forbidden scenarios

### Seed Data Validation

- verify roles and permissions load correctly
- verify role-to-permission mappings are accurate
- verify bootstrap super admin logic works safely
- verify sample catalog and coupon data satisfy approved scenarios

### Security Validation

- verify unverified customers cannot order, review, or redeem coupons
- verify raw inventory and raw coupons are not customer-readable
- verify audit logs are protected
- verify storage access matches approved bucket rules

## 10. Risks

### Migration Risks

- ordering mistakes across the three approved migrations
- hidden dependency assumptions between variants and order/cart lines
- environment drift between local, dev, staging, and production

### RLS Risks

- policy overexposure for internal roles
- ownership errors if helper functions are inconsistent
- guest cart logic becoming unsafe if pushed into direct anonymous access

### Identity Mapping Risks

- mismatch between `auth.users.id` and `profiles.id` if triggers or profile creation logic are incorrect
- role bootstrap failure blocking access-control enforcement

### Seed Data Risks

- unsafe handling of initial super admin credentials
- role-permission mismatches causing broken admin access
- insufficiently realistic sample data reducing test quality

## 11. Rollback Strategy

### Failed Migrations

- local and dev: reset and replay migration chain
- staging and production: prefer controlled corrective migrations or restore from backup when necessary
- never edit historical approved migrations after rollout

### Failed RLS Rollout

- deploy RLS in planned order
- validate each table group before proceeding
- if a policy blocks legitimate access, pause rollout and apply corrective migration or policy update rather than improvising direct bypasses

### Failed Seed Deployment

- keep seed operations deterministic and repeatable
- separate bootstrap secrets from repository data
- if seed fails, fix seed source and rerun rather than patching data manually without audit

## 12. Definition of Done

Phase 1 is complete only when:

- migrations executed
- helper functions implemented
- RLS implemented
- storage configured
- seed data loaded
- tests passing

## Execution Notes

- do not introduce undocumented schema or policy changes during implementation
- do not use direct client database writes for checkout, order creation, coupon redemption, payment workflows, or notification dispatch
- if implementation findings conflict with approved documentation, stop and update the source of truth before continuing
