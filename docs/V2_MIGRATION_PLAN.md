# V2 Migration Plan

## Purpose

This document outlines the planned second-stage schema migration needed to evolve the initial Phase 1 schema into the refactored variant-aware, coupon-ready, multi-vendor-capable model.

## Scope

V2 introduces:

- `vendors`
- `product_variants`
- `inventory`
- `coupons`
- `order_coupons`
- `notifications`
- `wishlists`
- `wishlist_items`
- `product_reviews`
- soft delete support on `categories`, `products`, and `orders`
- variant and vendor references for cart and order line items

## Migration Objectives

- move from product-level purchasing toward variant-level purchasing
- support future marketplace expansion with minimal table redesign later
- add customer engagement and retention features without changing the core identity model
- preserve backward compatibility through staged data backfills

## Recommended Migration Order

1. Add `vendors`.
2. Add `deleted_at` to `categories`, `products`, and `orders`.
3. Create `product_variants`.
4. Create `inventory`.
5. Alter `product_images` to support optional `variant_id`.
6. Alter `cart_items` to add `variant_id` and `vendor_id`.
7. Alter `order_items` to add `variant_id`, `vendor_id`, and `variant_name`.
8. Create `coupons`.
9. Create `order_coupons`.
10. Create `wishlists`.
11. Create `wishlist_items`.
12. Create `product_reviews`.
13. Create `notifications`.
14. Backfill default variants for existing products if live data exists.
15. Add new indexes and validation constraints after data backfill.

## Data Backfill Strategy

If the system already contains live product, cart, or order data:

- create one default variant per existing product
- map existing cart items to the new default variant
- map existing order items to the new default variant while preserving historical snapshot fields
- set `vendor_id` to null for platform-owned inventory until vendor onboarding is introduced

## Risk Areas

- migrating product-level line items to variant-level references
- ensuring unique SKU rules between old product SKUs and new variant SKUs
- handling legacy carts during rollout
- avoiding coupon over-redemption during concurrent checkout flows
- keeping soft-deleted catalog entities hidden from customer-facing queries

## Non-Goals

- row-level security policies
- auth workflow implementation
- frontend or mobile application changes
- payment and shipment schema expansion
