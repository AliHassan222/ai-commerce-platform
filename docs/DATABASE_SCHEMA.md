# Database Schema

## Purpose

This document defines the current AI Commerce Platform schema across:

- `001_initial_core_ecommerce_schema.sql`
- `002_ecommerce_extensions.sql`
- `003_add_variant_references_to_cart_and_order_items.sql`
- `004_helper_functions.sql`
- `005_rls_foundation.sql`
- `006_categories_rls.sql`
- `007_catalog_detail_rls.sql`
- `008_auth_profile_auto_creation.sql`

It reflects the approved MVP foundation plus the new ecommerce extension entities added in V2.

## Database Strategy

- Primary transactional database: Supabase PostgreSQL
- Authentication source: Supabase Auth with `profiles.id` linked to `auth.users.id`
- Storage: Supabase Storage
- API and policy enforcement: handled separately from the schema layer

The database is the source of truth for identity, catalog, pricing snapshots, carts, orders, reviews, wishlists, notifications, and audit history.

## Core Domain Entities

### Identity and Access

- `profiles`
- `roles`
- `permissions`
- `role_permissions`
- `addresses`

### Catalog and Vendor

- `vendors`
- `categories`
- `products`
- `product_variants`
- `product_images`
- `inventory`

### Commerce

- `carts`
- `cart_items`
- `coupons`
- `orders`
- `order_items`
- `order_coupons`
- `wishlists`
- `wishlist_items`

### Engagement and Platform

- `product_reviews`
- `notifications`
- `audit_logs`

## Shared Helper Functions

The migration `004_helper_functions.sql` introduces reusable SQL helper functions designed for future RLS and protected workflow reuse.

Implemented helper functions:

- identity helpers:
  - `current_profile_id()`
  - `current_user_email()`
  - `is_verified_email()`
- role helpers:
  - `current_role_id()`
  - `current_role_code()`
  - `current_profile_status()`
- permission helper:
  - `has_permission(permission_code text)`
- ownership helpers:
  - `owns_profile(target_profile_id uuid)`
  - `owns_cart(target_cart_id uuid)`
  - `owns_order(target_order_id uuid)`

Design intent:

- centralize identity, role, permission, and ownership logic
- support lightweight, reusable future RLS policies
- fail closed when identity resolution fails

## Row Level Security Foundation

The migration `005_rls_foundation.sql` enables the first Phase 1 RLS baseline on:

- `profiles`
- `addresses`
- `products`
- `carts`
- `cart_items`
- `orders`
- `order_items`
- `wishlists`
- `wishlist_items`
- `product_reviews`
- `notifications`

Implementation notes:

- RLS is explicitly enabled table by table
- access is deny-by-default unless a policy grants it
- public catalog access is currently limited to active, non-deleted `products`
- published `product_reviews` are publicly readable
- direct customer access to raw inventory, raw coupons, audit logs, and notification creation remains blocked
- direct order creation remains blocked pending protected checkout workflow implementation

The migration `006_categories_rls.sql` completes the public category RLS gap by adding:

- public read access for active, non-deleted categories
- customer read access through the same public policy path
- permission-driven internal read access for users with `categories.read`
- permission-driven insert access for users with `categories.create`
- permission-driven update access for users with `categories.update`
- soft delete and restore through update policies backed by `categories.delete` and `categories.restore`

Important note:

- hard delete remains denied because no `DELETE` policy is created for `public.categories`

The migration `007_catalog_detail_rls.sql` completes the remaining catalog-detail RLS baseline by adding:

- public read access for active `product_variants` whose parent `products` row is active and non-deleted
- customer read access through the same public policy path
- permission-driven internal read access for users with `products.read`
- permission-driven insert access for users with `products.create`
- permission-driven update access for users with `products.update`
- archive-style variant status updates through the same internal update path, including `products.delete` holders
- public read access for active `product_images` whose parent `products` row is active and non-deleted
- permission-driven image insert access for users with `products.create` or `products.update`
- permission-driven image update access for users with `products.update`
- permission-driven image delete access for users with `products.delete`

Important notes:

- `product_variants` has no direct `DELETE` policy in the current SQL baseline, so hard delete remains denied
- `product_images` supports direct delete only for internal users with `products.delete`

The migration `008_auth_profile_auto_creation.sql` completes the approved auth profile bootstrap baseline by adding:

- a secure trigger function that runs after `auth.users` insert
- automatic creation or repair of the matching `public.profiles` row
- deterministic default role assignment to active `Customer`
- deterministic default status assignment to `pending`
- self-service email drift protection in the `profiles` RLS update policy

Important notes:

- `profiles.id` remains equal to `auth.users.id`
- `profiles.email` is sourced from trusted `auth.users.email` during auto-creation
- normal self-service profile updates cannot change `profiles.email`

## Seed Foundation

The Phase 1 seed foundation under `backend/supabase/seed/` provides deterministic baseline data for:

- roles
- permissions
- role-to-permission mappings
- documented non-production user personas
- core categories
- core products

Seed intent:

- support helper-function testing
- support RLS testing
- support ownership testing
- support permission testing
- support admin workflow testing

Included baseline roles:

- `Super Admin`
- `Admin`
- `Viewer`
- `Customer`
- `Vendor`

Included baseline categories:

- `Electronics`
- `Mobiles`
- `Laptops`
- `Fashion`
- `Home & Kitchen`

Included product coverage:

- active public products
- draft internal-only product
- soft-deleted product

## Table Overview

### profiles

Operational user profile table extending Supabase Auth.

Key columns:

- `id` references `auth.users.id`
- `role_id` references `roles.id`
- `email`
- `status`

Current auth/bootstrap behavior:

- `008_auth_profile_auto_creation.sql` creates a matching `profiles` row automatically after `auth.users` insert
- the default role is `Customer`
- the default profile status is `pending`
- the profile email is copied from trusted auth state

### roles

Defines internal or platform roles such as admin, merchandiser, support, and customer.

### permissions

Defines permission codes used by role-based access control.

### role_permissions

Join table connecting roles to permissions.

### addresses

Stores customer billing and shipping addresses.

Key relationship:

- many addresses belong to one profile

### vendors

Prepares the platform for future multi-vendor support.

Key columns:

- `owner_profile_id` references `profiles.id`
- `slug`
- `status`

### categories

Hierarchical product organization table.

Key columns:

- `parent_id` self-references `categories.id`
- `slug`
- `status`
- `deleted_at` for soft deletes

### products

Top-level catalog entity used for browsing and product content.

Key columns:

- `vendor_id` references `vendors.id`
- `category_id` references `categories.id`
- `created_by` and `updated_by` reference `profiles.id`
- `sku`
- `status`
- `deleted_at`

Important note:

- the MVP foundation still keeps `sku` and `price_amount` on `products`
- V2 introduces `product_variants` for future purchasable-unit expansion

### product_variants

Variant-level purchasable units for size, color, or other option combinations.

Key columns:

- `product_id` references `products.id`
- `sku`
- `option_values`
- `price_amount`
- `status`

### product_images

Stores product media records.

Current relationship:

- images belong to products

### inventory

Tracks stock at the variant level.

Key columns:

- `variant_id` references `product_variants.id`
- `vendor_id` references `vendors.id`
- `location_code`
- `quantity_on_hand`
- `quantity_reserved`

Availability rule:

- available inventory = `quantity_on_hand - quantity_reserved`

### carts

Stores active or historical shopping carts for guest and authenticated users.

### cart_items

Stores cart line items.

Current relationships:

- `product_id` references `products.id`
- `variant_id` references `product_variants.id`

Important note:

- `variant_id` remains nullable for backward compatibility
- application and checkout validation should require `variant_id` when the product has variants

### coupons

Stores discount definitions and redemption rules.

Key columns:

- `code`
- `discount_type`
- `discount_value`
- `minimum_order_amount`
- `usage_limit`
- `usage_count`
- `starts_at`
- `ends_at`
- `status`

### orders

Stores order headers and commercial totals.

Key columns:

- `profile_id`
- `cart_id`
- `shipping_address_id`
- `billing_address_id`
- `order_number`
- `status`
- `payment_status`
- `fulfillment_status`
- `deleted_at`

### order_items

Stores line-item snapshots for orders.

Current relationships:

- `product_id` references `products.id`
- `variant_id` references `product_variants.id`

Business intent:

- preserve historical product name, SKU, pricing, and totals even if the product later changes
- keep `variant_id` nullable for backward compatibility while requiring it at application and checkout validation level when the purchased product uses variants

### order_coupons

Stores applied coupon snapshots per order.

Key columns:

- `order_id` references `orders.id`
- `coupon_id` references `coupons.id`
- `coupon_code`
- `discount_amount`

### wishlists

Stores user-owned wishlist containers.

Key columns:

- `profile_id` references `profiles.id`
- `is_default`
- `status`

### wishlist_items

Stores items saved inside wishlists.

Key relationships:

- `wishlist_id` references `wishlists.id`
- `product_id` references `products.id`
- `variant_id` references `product_variants.id`

### product_reviews

Stores user-submitted product reviews and moderation state.

Key relationships:

- `product_id` references `products.id`
- `variant_id` references `product_variants.id`
- `profile_id` references `profiles.id`

Key business fields:

- `rating`
- `status`
- `is_verified_purchase`

### notifications

Stores outbound or in-app user notifications.

Key columns:

- `profile_id`
- `channel`
- `type`
- `status`
- `sent_at`
- `read_at`

### audit_logs

Stores security and operational audit events.

## Relationships

### Identity

- one `role` can be assigned to many `profiles`
- one `role` can map to many `permissions` through `role_permissions`
- one `profile` can have many `addresses`
- one `profile` can own many `wishlists`
- one `profile` can receive many `notifications`
- one `profile` can write many `product_reviews`
- one `profile` can create many `orders`
- one `profile` can trigger many `audit_logs`
- one `profile` can optionally own many `vendors`

### Catalog

- one `category` can have many child categories
- one `category` can contain many `products`
- one `vendor` can supply many `products`
- one `product` can have many `product_variants`
- one `product` can have many `product_images`
- one `product` can appear in many `cart_items`
- one `product` can appear in many `order_items`
- one `product` can appear in many `wishlist_items`
- one `product` can have many `product_reviews`
- one `product_variant` can have many `inventory` records
- one `product_variant` can appear in many `cart_items`
- one `product_variant` can appear in many `order_items`
- one `product_variant` can appear in many `wishlist_items`
- one `product_variant` can appear in many `product_reviews`

### Commerce

- one `cart` can contain many `cart_items`
- one `order` can contain many `order_items`
- one `order` can have many `order_coupons`
- one `coupon` can be applied to many `orders` through `order_coupons`
- one `wishlist` can contain many `wishlist_items`

## Soft Delete Rules

Soft delete support exists on:

- `categories.deleted_at`
- `products.deleted_at`
- `orders.deleted_at`

Business rule:

- soft-deleted rows must be hidden from normal application queries unless an admin or privileged operational filter explicitly includes them

## Constraints and Indexes

The V2 and follow-up migrations add:

- foreign keys for all new extension tables
- nullable variant references for `cart_items` and `order_items`
- reusable helper functions for identity, role, permission, and ownership checks
- Phase 1 RLS enablement and policies for selected customer and catalog tables
- status constraints for vendors, variants, inventory, coupons, notifications, wishlists, and reviews
- amount and quantity validation checks
- uniqueness on vendor slug, variant SKU, coupon code, and wishlist item combinations
- indexes for foreign keys, status lookups, soft-delete filters, and common lookup fields

## Business Rules

- each profile has one primary role in the current MVP schema
- products remain the main catalog record
- product variants are introduced for future variant-aware commerce flows
- cart and order items remain product-linked but now also support nullable `variant_id`
- coupons support percentage, fixed amount, and free shipping
- reviews support moderation states and verified purchase flags
- notifications support `push`, `email`, `sms`, and `in_app`
- inventory cannot reserve more stock than exists on hand

## Multi-Vendor Support

The schema is prepared for future marketplace support without forcing it into the current MVP flow.

Current support includes:

- `vendors` as a first-class entity
- `products.vendor_id`
- `inventory.vendor_id`
- `vendors.owner_profile_id`

This allows a future transition toward:

- vendor-owned catalogs
- vendor-level stock ownership
- vendor onboarding workflows
- vendor analytics and settlements

Not yet implemented in the current migrations:

- vendor-level order partitioning
- vendor-level cart line ownership
- vendor settlement ledgers
- vendor payout workflows
