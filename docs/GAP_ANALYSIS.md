# Admin Dashboard Gap Analysis

## Purpose

This document compares the uploaded Stitch admin dashboard prototype against the approved AI Commerce Platform documentation and identifies the gaps that must be addressed before converting the prototype into a Next.js admin dashboard.

Sources reviewed:

- `e:\omnichannel_ai_enterprise_admin.html`
- `docs/USER_STORIES.md`
- `docs/DATABASE_SCHEMA.md`
- `docs/ERD.md`
- `docs/ROLES_PERMISSION_MATRIX.md`

## Prototype Summary

The Stitch prototype establishes a strong visual baseline for the internal admin experience. It includes a polished admin shell, KPI dashboard, catalog list, product creation form, category overview, order list, order detail, customer list, customer detail, reports, settings, notifications, and login screen.

The prototype is suitable as the official visual baseline, but it is not yet a complete functional page map for the approved platform. It currently favors broad executive and merchandising views over detailed RBAC, inventory, variant, moderation, audit, and workflow screens required by the schema and permission model.

## Existing Screens

Current routes in the prototype:

- `/` dashboard
- `/products` product list
- `/products/create` create product
- `/categories` category management
- `/orders` order list
- `/orders/detail` order detail
- `/customers` customer list
- `/customers/detail` customer detail
- `/reports` reports and insights
- `/settings` global settings
- `/notifications` notification center
- `/login` admin login

Current shared UI shell:

- sidebar navigation
- top header
- global search field
- notification shortcut
- user identity area
- logout link
- AI insights shortcut

## Existing Strengths

- The admin shell is visually coherent and conversion-ready.
- The dashboard covers executive-level KPIs such as revenue, orders, active customers, and conversion rate.
- Product management has a clear list and create flow foundation.
- Orders have list and detail foundations with fulfillment-style actions.
- Customers have list and detail foundations for support workflows.
- Reports and notifications establish a direction for AI-assisted operations.
- Settings includes a placeholder for role-related configuration.

## Missing Screens

### Identity and RBAC

- internal user management screen
- internal user create/invite screen
- internal user detail screen
- customer profile status management screen
- role management screen
- permission matrix screen
- role assignment and promotion workflow
- suspended/inactive user review screen
- audit log screen

Why this matters:

- `USER_STORIES.md` requires role-based access control and auditable permission checks.
- `DATABASE_SCHEMA.md` includes `profiles`, `roles`, `permissions`, `role_permissions`, and `audit_logs`.
- `ROLES_PERMISSION_MATRIX.md` defines Super Admin, Admin, Viewer, Customer, and future Vendor boundaries.

### Catalog and Merchandising

- product detail/edit screen separate from create product
- product publish/unpublish workflow
- product archive/restore workflow
- product image management screen
- product variant management screen
- product pricing by variant
- product SKU management by variant
- category create/edit screen
- category hierarchy management screen
- category archive/restore workflow
- soft-deleted catalog review screen

Why this matters:

- `DATABASE_SCHEMA.md` includes `products`, `product_variants`, `product_images`, `categories`, and soft-delete fields.
- `USER_STORIES.md` requires product variants, images, attributes, activation, archiving, and traceability.
- The prototype currently has only a simplified product form and category card grid.

### Inventory

- inventory list screen
- inventory detail screen
- inventory adjustment workflow
- low-stock and zero-stock views
- variant-level stock management
- inventory by location code
- reserved vs on-hand inventory visibility

Why this matters:

- `DATABASE_SCHEMA.md` models inventory at the `product_variants` level.
- `ERD.md` shows `product_variants` to `inventory` as a core relationship.
- Current prototype shows a stock column but no real inventory workflow.

### Orders and Fulfillment

- order status transition workflow
- payment status visibility
- fulfillment status visibility
- order cancellation workflow
- refund workflow placeholder
- order export workflow
- order soft-delete or hidden-order review screen
- order coupon application visibility

Why this matters:

- `DATABASE_SCHEMA.md` includes `orders`, `order_items`, `order_coupons`, status fields, payment status, fulfillment status, and soft delete.
- `ROLES_PERMISSION_MATRIX.md` includes `orders.update_status`, `orders.cancel`, `orders.refund`, and `orders.export`.

### Reviews and Moderation

- product review list
- review detail screen
- review moderation workflow
- hide review workflow
- delete review workflow
- published vs pending review filters

Why this matters:

- `DATABASE_SCHEMA.md` includes `product_reviews`.
- `ROLES_PERMISSION_MATRIX.md` includes `reviews.read`, `reviews.moderate`, `reviews.hide`, and `reviews.delete`.
- `USER_STORIES.md` requires support and operational visibility.

### Coupons and Promotions

- coupon list screen
- coupon create/edit screen
- coupon disable/archive workflow
- coupon usage and eligibility review
- order coupon history view

Why this matters:

- `DATABASE_SCHEMA.md` includes `coupons` and `order_coupons`.
- `ROLES_PERMISSION_MATRIX.md` defines coupon permissions.
- Coupon usage is part of the approved commerce model even though raw customer access remains restricted.

### Vendors

- vendor list screen
- vendor detail screen
- vendor onboarding placeholder
- vendor approve/suspend workflow
- future vendor-owned catalog scope view

Why this matters:

- `DATABASE_SCHEMA.md` includes `vendors`.
- `ROLES_PERMISSION_MATRIX.md` defines vendor permissions and future vendor scope.
- Vendor is future scope, so these do not block MVP admin conversion, but navigation should reserve the information architecture cleanly.

### Customer Operations

- customer address management view
- customer order history section with full order linking
- customer review history
- customer notification history
- customer status change workflow
- support notes or audit-linked support activity placeholder

Why this matters:

- `DATABASE_SCHEMA.md` includes `addresses`, `orders`, `product_reviews`, and `notifications`.
- `USER_STORIES.md` requires support agents to view customer and order context with restricted and auditable access.

### Notifications

- notification dispatch history
- notification status filters
- failed notification troubleshooting
- channel-specific notification views

Why this matters:

- `DATABASE_SCHEMA.md` includes notification channel, type, status, sent, and read fields.
- Current prototype shows notification cards but not operational notification management.

## Missing Components

- RBAC-aware navigation gating
- permission-aware action buttons
- role/status badges for users
- profile status controls
- audit event timeline
- soft-delete and restore controls
- publish state controls
- variant editor table
- product image uploader and image ordering UI
- inventory adjustment drawer or modal
- order status timeline
- fulfillment action panel
- payment status panel
- review moderation queue
- coupon rule builder
- category tree editor
- destructive-action confirmation modal
- empty, loading, error, and access-denied states
- reusable data table with filters, sorting, pagination, and bulk actions
- global search results page
- record detail activity feed

## Missing Workflows

- internal user invitation and role assignment
- Super Admin role promotion
- Admin user operational updates
- Viewer read-only internal access
- product create, edit, publish, archive, and restore
- variant create, edit, activate, and archive
- image upload, update, reorder, and delete
- category create, update, archive, and restore
- inventory adjustment with audit trail
- order status update
- review moderation, hide, and delete
- coupon create, update, disable, and usage review
- customer suspension and reactivation
- audit log filtering and investigation
- notification troubleshooting

## Missing RBAC Screens

Required RBAC screens:

- `/admin/users`
- `/admin/users/new`
- `/admin/users/[id]`
- `/admin/roles`
- `/admin/roles/[id]`
- `/admin/permissions`
- `/admin/audit-logs`

Required RBAC behaviors:

- Super Admin can manage roles and role assignments.
- Admin can perform operational catalog, order, review, and user updates within approved permissions.
- Viewer can read approved internal data but cannot write.
- Customer has no access to the admin dashboard.
- Vendor remains inactive and future-scoped.

## Missing Product Variant Management

The prototype does not yet model the approved variant system.

Required variant capabilities:

- variant list inside product detail
- variant create/edit form
- variant SKU field
- variant option values editor
- variant price field
- variant status field
- variant-linked cart/order visibility
- variant-linked inventory summary

Recommended product detail tabs:

- Overview
- Variants
- Images
- Inventory
- Reviews
- Activity

## Missing Inventory Workflows

The prototype shows stock as a table column but does not support the approved inventory model.

Required inventory capabilities:

- inventory by variant
- quantity on hand
- quantity reserved
- available inventory calculation
- location code
- low-stock filter
- zero-stock filter
- adjustment workflow
- audit trail for internal adjustments

Inventory should not be exposed as public customer-facing raw data.

## Documentation Alignment Findings

### Aligned

- Admin dashboard, products, orders, customers, reports, notifications, and settings align with the high-level user stories.
- The product list and create flow partially align with catalog management.
- Order detail partially aligns with fulfillment management.
- Customer detail partially aligns with support operations.
- Login aligns with internal identity entry.

### Partially Aligned

- Settings includes a Roles tab label, but no actual role or permission management.
- Product creation includes pricing and SKU, but does not include variants, images, categories, vendor, publish controls, or inventory.
- Categories exist as cards, but hierarchy, create, edit, archive, and restore are missing.
- Orders show status and fulfillment actions, but do not model payment, fulfillment status transitions, coupons, refunds, or audit history.
- Reports exist visually but are not mapped to `reports.read` or `reports.export`.

### Not Yet Represented

- `roles`
- `permissions`
- `role_permissions`
- `addresses`
- `product_variants`
- `product_images`
- `inventory`
- `coupons`
- `order_coupons`
- `wishlists`
- `wishlist_items`
- `product_reviews` moderation
- `audit_logs`
- `vendors`

## Recommended Page Map

### Core Admin

- `/admin`
- `/admin/login`
- `/admin/search`
- `/admin/notifications`
- `/admin/reports`
- `/admin/settings`

### Catalog

- `/admin/products`
- `/admin/products/new`
- `/admin/products/[productId]`
- `/admin/products/[productId]/edit`
- `/admin/products/[productId]/variants`
- `/admin/products/[productId]/images`
- `/admin/products/[productId]/inventory`
- `/admin/categories`
- `/admin/categories/new`
- `/admin/categories/[categoryId]/edit`
- `/admin/catalog/deleted`

### Inventory

- `/admin/inventory`
- `/admin/inventory/adjustments`
- `/admin/inventory/low-stock`
- `/admin/inventory/zero-stock`

### Orders

- `/admin/orders`
- `/admin/orders/[orderId]`
- `/admin/orders/[orderId]/timeline`
- `/admin/orders/[orderId]/coupons`
- `/admin/orders/export`

### Customers

- `/admin/customers`
- `/admin/customers/[profileId]`
- `/admin/customers/[profileId]/addresses`
- `/admin/customers/[profileId]/orders`
- `/admin/customers/[profileId]/notifications`
- `/admin/customers/[profileId]/reviews`

### Reviews

- `/admin/reviews`
- `/admin/reviews/pending`
- `/admin/reviews/[reviewId]`

### Coupons

- `/admin/coupons`
- `/admin/coupons/new`
- `/admin/coupons/[couponId]/edit`

### RBAC and Governance

- `/admin/users`
- `/admin/users/new`
- `/admin/users/[profileId]`
- `/admin/roles`
- `/admin/roles/[roleId]`
- `/admin/permissions`
- `/admin/audit-logs`

### Future Vendor Scope

- `/admin/vendors`
- `/admin/vendors/[vendorId]`
- `/admin/vendors/[vendorId]/products`
- `/admin/vendors/[vendorId]/inventory`

## Recommended Navigation Structure

Primary navigation:

- Dashboard
- Catalog
- Inventory
- Orders
- Customers
- Reviews
- Coupons
- Reports
- Notifications
- Governance
- Settings

Catalog submenu:

- Products
- Categories
- Deleted Catalog

Inventory submenu:

- Stock Overview
- Low Stock
- Zero Stock
- Adjustments

Governance submenu:

- Users
- Roles
- Permissions
- Audit Logs

Future submenu:

- Vendors

RBAC navigation rules:

- Super Admin sees all admin navigation, including Governance and Settings.
- Admin sees operational sections allowed by assigned permissions.
- Viewer sees read-only operational sections only.
- Customer should never enter the admin dashboard.
- Vendor navigation should remain hidden until future vendor scope is activated.

## Conversion Risks

### High

- RBAC is not yet reflected in navigation or page actions.
- Variant and inventory management are missing despite being core schema entities.
- Audit logs are missing despite being required for sensitive actions.
- Product create/edit does not cover enough schema fields to support real catalog operations.

### Medium

- Category management is visual-only and does not support hierarchy or lifecycle actions.
- Order management lacks full status, payment, fulfillment, coupon, and audit workflows.
- Review moderation and coupon management are absent.
- Settings screen combines unrelated operational concerns without permission-aware routing.

### Low

- Some prototype labels use terms not present in approved docs, such as Store Owner and Sales Channels.
- Mock customer and product data does not match seeded fixtures.
- The route names should be normalized under `/admin` during Next.js conversion.

## Readiness Score For Conversion To Next.js

Readiness score: 72/100

Rationale:

- The visual system, layout shell, and primary admin flow patterns are strong enough to begin conversion.
- The current route map is incomplete for the approved platform.
- Conversion should start with layout, authentication guard, RBAC-aware navigation, and the existing dashboard/catalog/order/customer shells.
- Detailed product variants, inventory, RBAC, audit logs, reviews, and coupons should be added to the page map before the admin dashboard is considered functionally complete.

## Recommended Next Step

Before generating Next.js code, approve the expanded admin page map and RBAC-aware navigation structure in this document.

Once approved, the first implementation task should be:

P2-T01 - Next.js Admin Shell and RBAC-Aware Route Map

This task should convert the Stitch visual baseline into a Next.js admin shell with protected routes, layout components, route groups, and permission-aware navigation placeholders.
