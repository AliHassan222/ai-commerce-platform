# RLS Policy Design

## Purpose

This document defines the implementation-ready Row Level Security policy design for the AI Commerce Platform before SQL policies are written. It translates the approved RLS strategy, auth rules, helper-function model, and governance constraints into explicit access expectations for every core table.

Implementation status:

- the Phase 1 SQL baseline is implemented in `backend/supabase/migrations/005_rls_foundation.sql`
- category RLS completion is implemented in `backend/supabase/migrations/006_categories_rls.sql`
- catalog-detail RLS completion is implemented in `backend/supabase/migrations/007_catalog_detail_rls.sql`
- current SQL scope covers:
  - `profiles`
  - `addresses`
  - `categories`
  - `products`
  - `product_variants`
  - `product_images`
  - `carts`
  - `cart_items`
  - `orders`
  - `order_items`
  - `wishlists`
  - `wishlist_items`
  - `product_reviews`
  - `notifications`
- intentionally denied direct-write paths remain blocked where protected backend workflows are still required, including direct order creation and notification creation
- support-style admin access without explicit permission mapping remains fail-closed in the current SQL implementation
- automatic `auth.users` to `profiles` creation is implemented separately in `backend/supabase/migrations/008_auth_profile_auto_creation.sql`

## Security Principles

- deny by default
- least privilege
- fail closed
- ownership first
- permission-driven admin access

Additional rules:

- public access must be intentionally granted, never assumed
- customer access must be limited to owned records or approved public data
- Viewer is read-only and only for explicitly permitted internal visibility
- Admin access must be permission-driven rather than broad implicit access
- Super Admin may override where approved, but actions should still remain auditable
- future vendor access must be isolated to vendor-owned data only when vendor workflows are implemented

## Ownership Rules

RLS policy implementation should standardize on approved helper functions.

Primary ownership helpers:

- `current_profile_id()`
- `owns_profile()`
- `owns_cart()`
- `owns_order()`
- `has_permission()`
- `is_verified_email()`
- `current_profile_status()`

Ownership model:

- use `current_profile_id()` for all profile-linked ownership checks
- use `owns_profile(profile_id)` for self-profile boundaries
- use `owns_cart(cart_id)` for cart and cart item visibility
- use `owns_order(order_id)` for order and order item visibility
- use `has_permission(permission_code)` for internal elevated reads and writes
- use `is_verified_email()` for verification-gated actions such as checkout, coupon redemption, and review creation
- use `current_profile_status()` to gate suspended, inactive, or pending-state restrictions where needed

## Public Catalog Rules

Anonymous and customer public-browsing visibility is limited to approved public catalog data only.

Publicly visible resources:

- active, non-deleted categories
- active, non-deleted products intended for storefront browsing
- product images associated with publicly visible products
- published product reviews only

Publicly hidden resources:

- inactive, draft, archived, or soft-deleted categories and products
- internal or unpublished media
- raw inventory
- raw coupons
- private customer or admin data

## Admin Rules

### Permission-Driven Access

- Viewer, Admin, and Super Admin access must be permission-driven wherever possible
- role name alone should not grant broad access when a permission helper can express the rule more precisely
- internal access should prefer `has_permission(permission_code)`

### Role Boundaries

- `Viewer` is read-only and has no create, update, or delete access
- `Admin` has approved operational permissions only
- `Super Admin` has highest internal authority and may access high-risk operations where approved

### Super Admin Overrides

- `Super Admin` may override standard internal boundaries where the design allows it
- override behavior must still remain auditable
- even with override authority, destructive or high-risk operations should follow workflow safeguards

## Verification Rules

Verification-gated restrictions apply even if the user is authenticated.

### Checkout

- customers must have verified email before order-creation workflows proceed
- enforcement must happen in protected backend workflows in addition to RLS-aware design

### Reviews

- customers must have verified email before review creation
- public users may read published reviews only

### Coupon Usage

- coupon validation and redemption require verified email
- customers must not directly read the raw `coupons` table
- coupon application records are workflow artifacts, not customer-managed resources

## Soft Delete Rules

Soft delete awareness is required for approved tables.

### Products

- anonymous and customer reads must exclude `deleted_at` records
- internal access to deleted products must be permission-controlled

### Categories

- anonymous and customer reads must exclude `deleted_at` records
- internal access to deleted categories must be permission-controlled

### Orders

- customer order access must exclude deleted or hidden records
- internal deleted-order visibility must be permission-controlled and auditable

## Audit Requirements

The following actions should require audit logging at the application or protected workflow layer:

- internal user creation
- role promotion or role change
- privileged profile status changes
- product create, update, publish, soft delete, and restore
- category create, update, soft delete, and restore
- inventory adjustments by internal users
- coupon create, update, disable, and correction actions
- order status changes
- support-driven access to sensitive customer data where applicable
- notification dispatch or high-risk notification troubleshooting actions
- any approved direct production intervention

## Storage Access Rules

### product-images bucket

Anonymous:

- read public product images only

Customer:

- same as anonymous

Admin:

- upload/update/delete through approved product-management permissions

Super Admin:

- full access

Future Vendor:

- future own-product scope only

## Service Role Rules

Service-role access bypasses RLS and must be restricted to:

- checkout workflows
- notification dispatch
- admin automation
- audit logging
- future integrations

Service-role credentials must never be exposed to client applications.

## Helper Dependency Matrix

profiles:

- `owns_profile()`

carts:

- `owns_cart()`

cart_items:

- `owns_cart()`

orders:

- `owns_order()`

order_items:

- `owns_order()`

reviews:

- `is_verified_email()`

admin workflows:

- `has_permission()`

## Table Access Design

## 1. profiles

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: own profile only through `owns_profile(id)`
- `INSERT`: no direct client insert; profile creation is trigger or secured backend driven
- `UPDATE`: own limited self-service fields only; no role or privileged status changes
- `DELETE`: no direct delete

### viewer

- `SELECT`: read only if explicitly permitted for internal visibility; sensitive fields should remain restricted where not needed
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: broad internal read through `has_permission()`
- `INSERT`: no routine direct client insert
- `UPDATE`: allowed operational fields only through permission-driven rules
- `DELETE`: no routine direct delete

### super_admin

- `SELECT`: full internal read
- `INSERT`: backend-controlled exceptional cases only
- `UPDATE`: full update where approved
- `DELETE`: backend-controlled only if ever permitted

### future vendor

- `SELECT`: own profile only
- `INSERT`: no direct insert
- `UPDATE`: own limited profile fields only
- `DELETE`: no direct delete

Current SQL note:

- direct client insert remains denied because profile creation is handled by the `auth.users` trigger path
- self-service update keeps `role_id`, `status`, and `email` fixed relative to trusted current values
- this prevents normal customer profile updates from changing `profiles.email`

## 2. roles

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: only if explicitly permitted for internal role visibility
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: no direct access by default
- `UPDATE`: no direct access by default
- `DELETE`: no direct access

### super_admin

- `SELECT`: full read
- `INSERT`: allowed through controlled admin workflows
- `UPDATE`: allowed through controlled admin workflows
- `DELETE`: discouraged; prefer inactive state or controlled governance

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 3. permissions

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: only if explicitly permitted
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: no direct access by default
- `UPDATE`: no direct access by default
- `DELETE`: no direct access

### super_admin

- `SELECT`: full read
- `INSERT`: allowed through controlled admin workflows
- `UPDATE`: allowed through controlled admin workflows
- `DELETE`: controlled only

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 4. role_permissions

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: only if explicitly permitted
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven read where needed for internal visibility
- `INSERT`: no direct access by default
- `UPDATE`: no direct access by default
- `DELETE`: no direct access

### super_admin

- `SELECT`: full read
- `INSERT`: allowed through controlled admin workflows
- `UPDATE`: allowed if mapping metadata ever requires it
- `DELETE`: allowed through controlled admin workflows

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 5. categories

### anonymous

- `SELECT`: active, non-deleted public categories only
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: same as anonymous
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: internal read as permitted, including non-public categories when needed
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven read of all relevant categories
- `INSERT`: allowed with category-management permission
- `UPDATE`: allowed with category-management permission
- `DELETE`: soft delete or restore only where permitted

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: controlled soft delete and restore allowed

### future vendor

- `SELECT`: public category visibility only unless future vendor category tooling is approved
- `INSERT`: no access in MVP
- `UPDATE`: no access in MVP
- `DELETE`: no access in MVP

Current SQL note:

- public and customer reads are implemented through a public `SELECT` policy limited to `status = 'active'` and `deleted_at is null`
- internal reads are implemented through `has_permission('categories.read')`
- insert is implemented through `has_permission('categories.create')`
- update is implemented through `has_permission('categories.update')`, `has_permission('categories.delete')`, or `has_permission('categories.restore')`
- hard delete remains denied because no category `DELETE` policy is implemented

## 6. products

### anonymous

- `SELECT`: active, non-deleted public products only
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: same as anonymous
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: internal read as permitted, including non-public products when needed
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven full internal read
- `INSERT`: allowed with product-management permission
- `UPDATE`: allowed with product-management permission
- `DELETE`: soft delete or restore only where permitted

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: controlled soft delete and restore allowed

### future vendor

- `SELECT`: own vendor products only when vendor scope is activated
- `INSERT`: own vendor products only in future approved workflows
- `UPDATE`: own vendor products only in future approved workflows
- `DELETE`: no access in MVP; future soft-delete only if approved

## 7. product_variants

### anonymous

- `SELECT`: active variants for publicly visible products only
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: same as anonymous
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: internal read as permitted
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: allowed with product-management permission
- `UPDATE`: allowed with product-management permission
- `DELETE`: allowed where approved

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: allowed

### future vendor

- `SELECT`: own product variants only when vendor scope is active
- `INSERT`: own product variants only in future approved workflows
- `UPDATE`: own product variants only in future approved workflows
- `DELETE`: own product variants only if approved in future workflows

Current SQL note:

- public and customer reads are implemented through a public `SELECT` policy limited to active variants whose parent product is active and non-deleted
- internal reads are implemented through `has_permission('products.read')`
- insert is implemented through `has_permission('products.create')`
- update is implemented through `has_permission('products.update')` or `has_permission('products.delete')`
- hard delete remains denied because no variant `DELETE` policy is implemented

## 8. product_images

### anonymous

- `SELECT`: images for publicly visible products only
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: same as anonymous
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: internal read as permitted
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: allowed with product-management permission
- `UPDATE`: allowed with product-management permission
- `DELETE`: allowed with product-management permission

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: allowed

### future vendor

- `SELECT`: own product images only when vendor media scope is activated
- `INSERT`: own product images only in future approved workflows
- `UPDATE`: own product images only in future approved workflows
- `DELETE`: own product images only in future approved workflows

Current SQL note:

- public and customer reads are implemented through a public `SELECT` policy limited to active images whose parent product is active and non-deleted
- internal reads are implemented through `has_permission('products.read')`
- insert is implemented through `has_permission('products.create')` or `has_permission('products.update')`
- update is implemented through `has_permission('products.update')`
- delete is implemented through `has_permission('products.delete')`

## 9. inventory

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no direct raw inventory access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: read only if explicitly permitted for internal operations
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven inventory read
- `INSERT`: allowed with inventory-management permission
- `UPDATE`: allowed with inventory-management permission
- `DELETE`: controlled only if approved

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: allowed where operationally approved

### future vendor

- `SELECT`: own vendor inventory only in future vendor workflows
- `INSERT`: own vendor inventory only in future approved workflows
- `UPDATE`: own vendor inventory only in future approved workflows
- `DELETE`: own vendor inventory only in future approved workflows

## 10. carts

### anonymous

- `SELECT`: no direct anonymous cart read in MVP RLS
- `INSERT`: no direct anonymous insert in standard RLS path
- `UPDATE`: no direct anonymous update
- `DELETE`: no direct anonymous delete

### customer

- `SELECT`: own carts only through `owns_cart(id)` and `current_profile_id()`
- `INSERT`: own authenticated carts only
- `UPDATE`: own carts only
- `DELETE`: own carts only where business rules allow

### viewer

- `SELECT`: no default access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: support visibility only if explicitly permissioned
- `INSERT`: no routine access
- `UPDATE`: no routine access
- `DELETE`: no routine access

### super_admin

- `SELECT`: restricted support visibility only if approved
- `INSERT`: backend support only if needed
- `UPDATE`: backend support only if needed
- `DELETE`: backend support only if needed

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 11. cart_items

### anonymous

- `SELECT`: no direct anonymous access
- `INSERT`: no direct anonymous access
- `UPDATE`: no direct anonymous access
- `DELETE`: no direct anonymous access

### customer

- `SELECT`: only items inside owned carts
- `INSERT`: only into owned carts
- `UPDATE`: only items inside owned carts
- `DELETE`: only items inside owned carts

### viewer

- `SELECT`: no default access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: support visibility only if explicitly permissioned
- `INSERT`: no routine access
- `UPDATE`: no routine access
- `DELETE`: no routine access

### super_admin

- `SELECT`: support visibility only if approved
- `INSERT`: backend support only if needed
- `UPDATE`: backend support only if needed
- `DELETE`: backend support only if needed

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 12. orders

### anonymous

- `SELECT`: no access
- `INSERT`: no direct access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: own non-deleted orders only through `owns_order(id)`
- `INSERT`: no direct table insert; order creation only through checkout workflow and verified-email rules
- `UPDATE`: no unrestricted direct update
- `DELETE`: no direct delete

### viewer

- `SELECT`: read only if explicitly permitted for operational visibility
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven read of order history and state
- `INSERT`: no direct client insert
- `UPDATE`: only approved workflow-driven status or operational updates
- `DELETE`: no routine direct delete; soft-delete only if explicitly approved

### super_admin

- `SELECT`: full internal read
- `INSERT`: backend-controlled exceptional workflows only
- `UPDATE`: full operational update through approved workflows
- `DELETE`: controlled soft-delete only if approved

### future vendor

- `SELECT`: vendor-relevant orders only in future scoped workflows
- `INSERT`: no access
- `UPDATE`: limited future workflow updates only if approved
- `DELETE`: no access

## 13. order_items

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: only items belonging to owned orders
- `INSERT`: no direct insert; created by checkout workflow only
- `UPDATE`: no direct update
- `DELETE`: no direct delete

### viewer

- `SELECT`: read only if explicitly permitted through order visibility
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: no direct client insert
- `UPDATE`: only if approved in protected operational workflows
- `DELETE`: no routine direct delete

### super_admin

- `SELECT`: full read
- `INSERT`: backend-controlled only
- `UPDATE`: backend-controlled operational updates only if needed
- `DELETE`: backend-controlled only if approved

### future vendor

- `SELECT`: vendor-relevant order items only in future workflows
- `INSERT`: no access
- `UPDATE`: limited future workflow updates only if approved
- `DELETE`: no access

## 14. addresses

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: own addresses only through `current_profile_id()`
- `INSERT`: own addresses only
- `UPDATE`: own addresses only
- `DELETE`: own addresses only where business rules allow delete or archive

### viewer

- `SELECT`: no default access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: read-only support visibility only if explicitly permitted
- `INSERT`: limited support-only correction path if approved
- `UPDATE`: limited support-only correction path if approved
- `DELETE`: limited support-only archive path if approved

### super_admin

- `SELECT`: full read
- `INSERT`: allowed where operationally needed
- `UPDATE`: allowed
- `DELETE`: allowed where approved

### future vendor

- `SELECT`: own addresses only in future shared-profile vendor scenarios
- `INSERT`: own addresses only in future approved workflows
- `UPDATE`: own addresses only in future approved workflows
- `DELETE`: own addresses only in future approved workflows

## 15. wishlists

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: own wishlists only through `current_profile_id()`
- `INSERT`: own wishlists only
- `UPDATE`: own wishlists only
- `DELETE`: own wishlists only

### viewer

- `SELECT`: no default access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: read-only support visibility only if explicitly permitted
- `INSERT`: no routine access
- `UPDATE`: no routine access
- `DELETE`: no routine access

### super_admin

- `SELECT`: support visibility only if approved
- `INSERT`: backend support only if needed
- `UPDATE`: backend support only if needed
- `DELETE`: backend support only if needed

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 16. wishlist_items

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: only items in owned wishlists
- `INSERT`: only into owned wishlists
- `UPDATE`: only where business rules require it; otherwise prefer recreate semantics
- `DELETE`: only from owned wishlists

### viewer

- `SELECT`: no default access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: read-only support visibility only if explicitly permitted
- `INSERT`: no routine access
- `UPDATE`: no routine access
- `DELETE`: no routine access

### super_admin

- `SELECT`: support visibility only if approved
- `INSERT`: backend support only if needed
- `UPDATE`: backend support only if needed
- `DELETE`: backend support only if needed

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 17. product_reviews

### anonymous

- `SELECT`: published reviews only
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: own reviews plus published reviews
- `INSERT`: own reviews only and only if `is_verified_email()` is true
- `UPDATE`: own pending reviews only within business rules
- `DELETE`: own reviews only where policy allows delete or hide

### viewer

- `SELECT`: read only if explicitly permitted for internal review visibility
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven moderation visibility
- `INSERT`: no routine access
- `UPDATE`: moderation updates where permitted
- `DELETE`: moderation delete or hide where permitted

### super_admin

- `SELECT`: full read
- `INSERT`: operational-only if needed
- `UPDATE`: full moderation update
- `DELETE`: allowed

### future vendor

- `SELECT`: own product reviews only in future vendor visibility workflows
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 18. notifications

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: own notifications only through `current_profile_id()`
- `INSERT`: no direct client insert
- `UPDATE`: own read-state updates only if supported
- `DELETE`: no direct delete

### viewer

- `SELECT`: no default access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: read-only troubleshooting visibility only if explicitly permitted
- `INSERT`: no direct client insert
- `UPDATE`: no routine direct update
- `DELETE`: no routine direct delete

### super_admin

- `SELECT`: full read where operationally required
- `INSERT`: backend, Edge Function, or service-role only
- `UPDATE`: operational updates only where needed
- `DELETE`: backend-controlled cleanup only if needed

### future vendor

- `SELECT`: own notifications only in future workflows
- `INSERT`: no direct insert
- `UPDATE`: own read-state only in future workflows
- `DELETE`: no direct delete

## 19. coupons

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no direct access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: read only if explicitly permitted
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven coupon read
- `INSERT`: allowed with coupon-management permission
- `UPDATE`: allowed with coupon-management permission
- `DELETE`: no direct hard delete; disable or archive where approved

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: controlled disable, archive, or approved deletion path

### future vendor

- `SELECT`: no access in MVP
- `INSERT`: no access in MVP
- `UPDATE`: no access in MVP
- `DELETE`: no access in MVP

## 20. order_coupons

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: only coupon applications attached to owned orders if exposed at all
- `INSERT`: no direct insert
- `UPDATE`: no direct update
- `DELETE`: no direct delete

### viewer

- `SELECT`: read only if explicitly permitted through internal order visibility
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: no direct client insert
- `UPDATE`: correction workflow only if explicitly approved
- `DELETE`: correction workflow only if explicitly approved

### super_admin

- `SELECT`: full read
- `INSERT`: backend-controlled only
- `UPDATE`: backend-controlled only if needed
- `DELETE`: backend-controlled only if needed

### future vendor

- `SELECT`: vendor-relevant order coupon visibility only if future workflows require it
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 21. audit_logs

### anonymous

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no access
- `INSERT`: no direct access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: no access by default; only if explicitly granted `audit_logs.read`
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven read only
- `INSERT`: backend, Edge Function, or service-role only
- `UPDATE`: no direct client update
- `DELETE`: no direct client delete

### super_admin

- `SELECT`: full read
- `INSERT`: backend, Edge Function, or service-role only
- `UPDATE`: generally immutable; backend-only exceptional correction if ever required
- `DELETE`: backend-only retention or archival path if ever required

### future vendor

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

## 22. vendors

### anonymous

- `SELECT`: no access in MVP unless future public vendor exposure is intentionally approved
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### customer

- `SELECT`: no access
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### viewer

- `SELECT`: read only if explicitly permitted
- `INSERT`: no access
- `UPDATE`: no access
- `DELETE`: no access

### admin

- `SELECT`: permission-driven internal read
- `INSERT`: allowed for internal onboarding only where permitted
- `UPDATE`: allowed where permitted
- `DELETE`: limited suspend or archive actions only if permitted

### super_admin

- `SELECT`: full read
- `INSERT`: allowed
- `UPDATE`: allowed
- `DELETE`: controlled suspend, archive, or approved deletion path

### future vendor

- `SELECT`: own vendor record only
- `INSERT`: future protected onboarding only
- `UPDATE`: own vendor record only through approved future workflows
- `DELETE`: no direct delete

## Definition of Done

RLS design is complete only when every table has documented access rules for every role and the design remains aligned with approved auth, helper, and governance rules.
