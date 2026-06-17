# RLS Plan

## Purpose

This document defines the Row Level Security design for the AI Commerce Platform before SQL policies are implemented.

## Core Principles

- deny by default
- grant minimum necessary access
- enforce ownership at the database layer
- route multi-step or privileged workflows through Edge Functions or protected server-side actions
- keep public browsing separated from private ownership and internal administration

## Identity Mapping Strategy

The intended MVP identity model is:

- `profiles.id = auth.users.id`

This means profile ownership can be resolved directly from the authenticated Supabase user id when the schema and triggers are implemented correctly.

Implementation guidance:

- if `profiles.id` always equals `auth.users.id`, ownership checks can safely use the authenticated user id directly
- if this mapping is ever changed, indirect, or made more complex in future phases, all ownership checks must use a helper such as `current_profile_id()`

Recommended rule:

- standardize on helper-based ownership checks in SQL policy implementation even if the ids currently match, because this reduces future migration risk and keeps policy logic consistent

Ownership standard:

- all SQL RLS ownership checks should use `current_profile_id()`
- do not hardcode direct comparisons such as `table.profile_id = auth.uid()` in final SQL policies

## Global Access Rules

- public or guest users can read only active, non-deleted catalog data
- public or guest users can read:
  - `categories`
  - `products`
  - `product_images`
  - active `product_variants`
  - published `product_reviews`
- public or guest users must not read:
  - `inventory`
  - `carts`
  - `cart_items`
  - `orders`
  - `order_items`
  - `addresses`
  - `profiles`
  - `coupons`
  - `audit_logs`
- customers can access only their own private records
- customers cannot directly read the raw `coupons` table
- customers cannot directly read raw `inventory`
- admin and super admin access must still be permission-controlled through RBAC
- viewer is read-only and must not access sensitive private fields unless explicitly allowed
- vendor access is future scoped and must be limited to vendor-owned data only
- public and customer access must exclude `deleted_at` records
- admin access to deleted records must be permission-controlled

## Viewer Access Boundaries

Viewer is an internal read-only role intended for operational visibility without mutation authority.

Viewer can read when explicitly permitted:

- categories
- products
- product_images
- product_variants
- inventory
- orders
- order_items
- users or profiles through restricted internal views
- product_reviews
- coupons
- reports and operational summaries
- audit_logs if explicitly granted

Viewer cannot:

- create, update, delete, publish, approve, suspend, refund, or moderate records
- access secrets, tokens, credentials, or service-role data
- access customer-private data unless there is an intentional internal support or reporting requirement
- directly manage roles, permissions, vendor onboarding, notifications dispatch, or inventory mutation

Viewer private-data rule:

- Viewer must not access sensitive private fields unless intentionally allowed by business policy and permission design
- any Viewer access to profiles, addresses, notifications, or wishlists should be treated as exceptional rather than default

## profiles

SELECT:
- public or guest: no access
- customer: own profile only
- viewer: read allowed user fields only when explicitly permitted
- admin: broad read based on RBAC
- super admin: full read
- vendor: own profile only

INSERT:
- public or guest: no direct insert
- customer: no direct insert from client if profile auto-creation is trigger or backend driven
- admin: no routine direct insert from client
- super admin: backend-controlled only for exceptional workflows
- vendor: no direct insert

UPDATE:
- customer: own profile, limited self-service fields only
- viewer: no update
- admin: allowed operational fields by RBAC
- super admin: full update
- vendor: own limited profile fields only in future

DELETE:
- public/customer/viewer/admin/vendor: no direct delete
- super admin: backend-controlled only if ever permitted

Special Rules:
- `role_id` and privileged `status` changes must never be customer editable
- profile creation should happen automatically after `auth.users` creation
- suspended or inactive profiles should be blocked from protected flows
- ownership checks in SQL policy implementation should use `current_profile_id()`

## roles

SELECT:
- public or guest: no access
- customer: no access
- viewer: read if explicitly permitted for internal visibility
- admin: read by RBAC
- super admin: full read
- vendor: no access

INSERT:
- super admin or backend only

UPDATE:
- super admin only

DELETE:
- super admin only, preferably avoided in favor of inactive state

Special Rules:
- roles are internal authorization records
- direct client mutation should be avoided outside tightly controlled admin workflows

## permissions

SELECT:
- public or guest: no access
- customer: no access
- viewer: read if explicitly permitted
- admin: read by RBAC
- super admin: full read
- vendor: no access

INSERT:
- super admin or backend only

UPDATE:
- super admin only

DELETE:
- super admin only, preferably avoided in favor of inactive state

Special Rules:
- permissions should be stable internal control records

## role_permissions

SELECT:
- public or guest: no access
- customer: no access
- viewer: read only if explicitly permitted
- admin: read by RBAC when needed
- super admin: full read
- vendor: no access

INSERT:
- super admin or backend only

UPDATE:
- super admin only

DELETE:
- super admin only

Special Rules:
- role-to-permission mapping should never be client-managed by non-super-admin roles

## addresses

SELECT:
- public or guest: no access
- customer: own addresses only
- viewer: no default access
- admin: read only when support workflows explicitly require it
- super admin: full read
- vendor: own addresses only in future if shared profile model applies

INSERT:
- customer: own addresses only
- admin: allowed only through approved support workflows
- super admin: allowed

UPDATE:
- customer: own addresses only
- viewer: no access
- admin: limited support updates only
- super admin: full update
- vendor: own only in future

DELETE:
- customer: own addresses only if business rules allow delete or archive
- admin: limited support archive only
- super admin: allowed

Special Rules:
- ownership checks in SQL policy implementation should use `current_profile_id()`
- address access should never cross account boundaries
- admin support visibility, if enabled, should be read-only and justified by explicit support permissions
- viewer should not have default access to raw address records

## categories

SELECT:
- public or guest: active, non-deleted categories only
- customer: same as public
- viewer: read all categories needed for internal visibility
- admin: read all categories by RBAC
- super admin: full read
- vendor: public catalog visibility only unless future vendor management is introduced

INSERT:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: no access

UPDATE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: full update
- vendor: no access

DELETE:
- public/customer/viewer/vendor: no access
- admin: permission-controlled soft delete only
- super admin: allowed soft delete and restore

Special Rules:
- public and customer reads must exclude `deleted_at is not null`
- draft or inactive internal-only category states must not leak into public responses

## products

SELECT:
- public or guest: active, non-deleted products only
- customer: same as public
- viewer: read product records by RBAC
- admin: read all by RBAC
- super admin: full read
- vendor: future access to own `vendor_id` products only

INSERT:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: future vendor-owned insert only

UPDATE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: full update
- vendor: future vendor-owned update only

DELETE:
- public/customer/viewer: no access
- admin: permission-controlled soft delete only
- super admin: allowed soft delete and restore
- vendor: no access in MVP

Special Rules:
- public and customer reads must exclude `deleted_at is not null`
- direct public access must expose only active publishable products
- future vendor access must be restricted by `vendor_id`

## product_images

SELECT:
- public or guest: images for readable active, non-deleted products only
- customer: same as public
- viewer: read by RBAC
- admin: read all by RBAC
- super admin: full read
- vendor: future own-product images only

INSERT:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: future own-product insert only

UPDATE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: full update
- vendor: future own-product update only

DELETE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: future own-product delete only

Special Rules:
- image visibility should inherit product visibility
- orphaned or inactive media must not be publicly exposed

## product_variants

SELECT:
- public or guest: active variants for readable active, non-deleted products only
- customer: same as public
- viewer: read by RBAC
- admin: read all by RBAC
- super admin: full read
- vendor: future own-product variants only

INSERT:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: future own-product variant insert only

UPDATE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: full update
- vendor: future own-product update only

DELETE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: future own-product delete only

Special Rules:
- public access should not expose inactive variants
- variant visibility should inherit product visibility

## inventory

SELECT:
- public or guest: no access
- customer: no direct access
- viewer: read only if explicitly permitted for internal operations
- admin: read by RBAC
- super admin: full read
- vendor: future own inventory only

INSERT:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: allowed
- vendor: future own inventory insert only

UPDATE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: full update
- vendor: future own inventory update only

DELETE:
- public/customer/viewer: no access
- admin: controlled by RBAC
- super admin: allowed
- vendor: future own inventory delete only if business rules allow

Special Rules:
- customers cannot directly read raw inventory
- product APIs may expose availability summary only
- inventory changes should typically happen through protected workflows

## vendors

SELECT:
- public or guest: no direct access in MVP unless a future public vendor profile is intentionally exposed
- customer: no access
- viewer: read by RBAC if permitted
- admin: read by RBAC
- super admin: full read
- vendor: future own vendor record only

INSERT:
- public/customer/viewer: no access
- admin: allowed for internal onboarding by RBAC
- super admin: allowed
- vendor: future self-onboarding only through protected workflow

UPDATE:
- public/customer/viewer: no access
- admin: allowed by RBAC
- super admin: full update
- vendor: future own vendor update only

DELETE:
- public/customer/viewer/vendor: no direct access
- admin: limited suspend or archive only if permitted
- super admin: allowed

Special Rules:
- vendor management should remain backend or admin controlled until marketplace phase

## carts

SELECT:
- public or guest: no direct public read
- customer: own carts only
- viewer: no default access
- admin: no default broad access, support access only if explicitly approved
- super admin: restricted support visibility only
- vendor: no access

INSERT:
- customer: own authenticated cart only
- guest: guest cart handling should use secure backend flow if direct anonymous ownership is unsafe
- admin/viewer/vendor: no direct insert
- super admin: backend support only

UPDATE:
- customer: own carts only
- guest: backend-controlled where necessary
- admin: no routine direct update
- super admin: support path only

DELETE:
- customer: own carts only if business rules allow
- admin/viewer/vendor: no access
- super admin: support path only

Special Rules:
- authenticated ownership is based on `carts.profile_id = auth.uid()`
- ownership checks in SQL policy implementation should use `current_profile_id()`
- guest cart operations should be routed through secure backend logic if RLS cannot safely express guest ownership
- merged or converted cart state should not become visible across users

## cart_items

SELECT:
- public or guest: no direct access
- customer: only items belonging to own carts
- viewer: no default access
- admin: support visibility only if explicitly approved
- super admin: support path only
- vendor: no access

INSERT:
- customer: only into own carts
- guest: backend-controlled if guest cart is supported anonymously
- admin/viewer/vendor: no direct insert
- super admin: support path only

UPDATE:
- customer: only items in own carts
- admin/viewer/vendor: no direct update
- super admin: support path only

DELETE:
- customer: only items in own carts
- admin/viewer/vendor: no direct delete
- super admin: support path only

Special Rules:
- access must derive from the parent cart ownership rule
- do not trust client-submitted cart identifiers without ownership checks

## orders

SELECT:
- public or guest: no access
- customer: own orders only, excluding records hidden by business rules
- viewer: read all by RBAC if intentionally allowed
- admin: read all by RBAC
- super admin: full read
- vendor: future vendor-relevant orders only

INSERT:
- public/customer: no direct table insert from client
- order creation must happen only through checkout Edge Function or protected backend workflow
- viewer: no access
- admin: no direct client insert
- super admin: backend-controlled only
- vendor: no direct insert

UPDATE:
- customer: no unrestricted direct update
- admin: only allowed operational status changes through protected workflow
- super admin: full operational update through protected workflow
- viewer/vendor: no direct update in MVP

DELETE:
- public/customer/viewer/vendor: no direct delete
- admin: permission-controlled soft delete or archive only if explicitly allowed
- super admin: controlled soft delete only

Special Rules:
- public and customer access must exclude `deleted_at is not null`
- unverified customers must not be allowed to place new orders
- order state changes must be server-side validated

## order_items

SELECT:
- public or guest: no access
- customer: only line items belonging to own orders
- viewer: read by internal order visibility rules
- admin: read by RBAC
- super admin: full read
- vendor: future vendor-relevant order items only

INSERT:
- no direct client insert
- created only as part of protected order creation workflow

UPDATE:
- no direct customer update
- admin and super admin only through protected operational workflow if needed

DELETE:
- no direct client delete
- backend-controlled only if ever required

Special Rules:
- access must derive from parent order ownership or privileged internal access
- orphaned line items must never be directly exposed

## wishlists

SELECT:
- public or guest: no access
- customer: own wishlists only
- viewer: no default access
- admin: no routine access unless explicitly approved for support
- super admin: support path only
- vendor: no access

INSERT:
- customer: own wishlists only
- admin/viewer/vendor: no direct insert
- super admin: support path only

UPDATE:
- customer: own wishlists only
- admin/viewer/vendor: no direct update
- super admin: support path only

DELETE:
- customer: own wishlists only
- admin/viewer/vendor: no direct delete
- super admin: support path only

Special Rules:
- ownership is based on `wishlists.profile_id = auth.uid()`
- ownership checks in SQL policy implementation should use `current_profile_id()`
- admin support visibility, if enabled, should be read-only and limited to explicit support use cases
- viewer should not have default access to wishlists

## wishlist_items

SELECT:
- public or guest: no access
- customer: only items in own wishlists
- viewer: no default access
- admin: no routine access unless support workflow explicitly needs it
- super admin: support path only
- vendor: no access

INSERT:
- customer: only into own wishlists
- admin/viewer/vendor: no direct insert
- super admin: support path only

UPDATE:
- customer: limited only if business rules require updates; otherwise prefer delete and recreate semantics
- admin/viewer/vendor: no direct update
- super admin: support path only

DELETE:
- customer: only from own wishlists
- admin/viewer/vendor: no direct delete
- super admin: support path only

Special Rules:
- access must derive from the parent wishlist ownership rule

## notifications

SELECT:
- public or guest: no access
- customer: own notifications only
- viewer: no default access
- admin: limited operational read only if explicitly permitted
- super admin: full read
- vendor: future own notifications only

INSERT:
- no direct client insert
- backend, Edge Function, or service-role only

UPDATE:
- customer: own read-state updates only if supported
- admin: no routine direct update
- super admin: allowed where operationally required
- vendor: future own read-state only

DELETE:
- public/customer/viewer/admin/vendor: no direct delete
- super admin: backend-controlled cleanup only if needed

Special Rules:
- notification creation and dispatch must remain backend-controlled
- admin support visibility, if enabled, should be read-only and limited to troubleshooting or customer support workflows
- viewer should not have default access to private notifications

## product_reviews

SELECT:
- public or guest: published reviews only
- customer: own reviews plus published reviews
- viewer: read all by RBAC
- admin: read all by RBAC
- super admin: full read
- vendor: future read for own product reviews only

INSERT:
- customer: own reviews only
- public or guest: no access
- viewer: no access
- admin/super admin: operational creation only if needed
- vendor: no direct insert

UPDATE:
- customer: own pending reviews only within business rules
- admin: moderation updates by RBAC
- super admin: full moderation update
- viewer/vendor: no direct update

DELETE:
- customer: own review delete or hide only if business rules allow
- admin: moderation delete or hide by RBAC
- super admin: allowed
- viewer/vendor/public: no access

Special Rules:
- unverified customers must not be allowed to submit reviews
- moderation status must not be customer-editable after leaving `pending`

## coupons

SELECT:
- public or guest: no access
- customer: no direct access
- viewer: read by RBAC only if intentionally permitted
- admin: read by RBAC
- super admin: full read
- vendor: no access in MVP

INSERT:
- public/customer/viewer/vendor: no access
- admin: allowed by RBAC
- super admin: allowed

UPDATE:
- public/customer/viewer/vendor: no access
- admin: allowed by RBAC
- super admin: full update

DELETE:
- public/customer/viewer/vendor: no direct delete
- admin: disable or archive by RBAC
- super admin: allowed

Special Rules:
- customers cannot directly read coupons table
- coupon validation must happen only through checkout Edge Function or protected backend workflow

## order_coupons

SELECT:
- public or guest: no access
- customer: only coupon applications belonging to own orders if exposed at all
- viewer: read by RBAC
- admin: read by RBAC
- super admin: full read
- vendor: future vendor-relevant order coupon visibility only if needed

INSERT:
- no direct client insert
- created only during protected checkout workflow

UPDATE:
- no routine direct client update
- backend-controlled only if correction workflow exists

DELETE:
- no direct client delete
- backend-controlled only

Special Rules:
- coupon application records are transactional artifacts of checkout, not customer-managed resources

## audit_logs

SELECT:
- public or guest: no access
- customer: no access
- viewer: no access by default
- viewer: may read only if explicitly granted `audit_logs.read` through RBAC permissions
- admin: read by RBAC
- super admin: full read
- vendor: no access in MVP

INSERT:
- backend, Edge Function, or service-role only
- no direct client insert

UPDATE:
- no direct client update
- generally immutable; backend-only exceptional correction if ever required

DELETE:
- no direct client delete
- backend-only retention or archival process if ever required

Special Rules:
- audit logs must never be publicly exposed
- inserts must be backend or service-role only
- direct client update or delete must not be allowed

## Admin Support Visibility Rules

These rules apply when internal support workflows require limited access to customer-private data.

### addresses

- admin may have read-only access only when an explicit support permission exists
- admin must not broadly browse addresses without operational justification
- admin write access should be avoided except for tightly controlled support correction workflows

### notifications

- admin may have read-only access only when troubleshooting delivery or support issues
- admin must not directly dispatch notifications through table writes from the client
- delivery creation and state changes remain backend-controlled

### orders

- admin may have read-only access to customer orders when an explicit support permission exists
- admin may investigate order history and order state
- admin must not impersonate customer actions
- order modifications must still follow workflow permissions and status transition rules
- support visibility should be audited

### wishlists

- admin may have read-only visibility only if customer support workflows require it
- admin should not mutate customer wishlists directly in normal operation
- support visibility should be intentionally permissioned rather than broadly available

## Storage Security

Storage security must complement database RLS because product media lives outside ordinary table row access.

### product-images bucket

Recommended bucket purpose:

- store product images and approved catalog media assets

### Public Read Rules

- public read is allowed only for approved product media intended for storefront or mobile display
- storage object visibility should align with product and image publish state
- unpublished or internal-only media must not be exposed publicly

### Admin Upload Rules

- admin uploads must be authenticated
- upload, replace, and delete actions should require RBAC-backed admin permissions
- media writes should preferably happen through protected workflows or signed upload patterns rather than unrestricted client storage access

### Future Vendor Upload Rules

- future vendor uploads must be restricted to vendor-owned media paths only
- vendors must not access or overwrite platform-owned or other vendors’ assets
- vendor upload permissions should be enforced through path conventions, RBAC, and storage policies together

## Security Gaps

- field-level protection is still required for sensitive columns such as `profiles.role_id` and status fields
- guest cart ownership cannot be safely modeled with simple user-based RLS alone
- coupon application, checkout, and order creation require protected backend workflows beyond raw RLS
- admin support access boundaries need exact permission mapping before SQL implementation
- vendor-scoped access is future-state and not yet backed by final business workflows
- storage security policies still need to be formally translated into bucket and object-level rules

## RLS Implementation Risks

- mixing direct client writes with complex business rules may create policy drift
- overly complex role logic inside many policies can become hard to maintain and test
- soft delete filtering may be inconsistently applied if helper functions are not standardized
- support and admin visibility can accidentally exceed least-privilege intent
- inventory and checkout logic may leak sensitive state if availability exposure is not carefully abstracted

## Recommended Helper Functions

- `current_profile_id()` to map auth user to profile identity
- `current_role_name()` to resolve the effective role
- `has_permission(permission_code text)` for RBAC checks
- `is_verified_email()` to enforce verification-gated actions
- `owns_cart(cart_id uuid)` for cart ownership checks
- `owns_order(order_id uuid)` for order ownership checks
- `owns_wishlist(wishlist_id uuid)` for wishlist ownership checks
- `can_view_deleted_catalog()` for permission-controlled deleted-record access
- `is_vendor_owner(vendor_id uuid)` for future vendor-scoped access

## Readiness Score

94/100

The design is now highly ready for SQL policy drafting. The table-by-table access model, RBAC assumptions, support visibility boundaries, storage security direction, and ownership standardization are all mature enough for implementation. The remaining work is mainly execution detail: translating this design into correct SQL policies, helper functions, and controlled backend workflows for checkout, guest cart handling, and future vendor scope.
