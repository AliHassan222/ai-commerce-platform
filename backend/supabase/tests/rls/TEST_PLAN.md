# RLS Test Plan

## Purpose

This document defines the validation scope for the Phase 1 RLS implementation introduced in `005_rls_foundation.sql`.

## Covered Tables

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

## Test Categories

### Public Access Tests

- anonymous users can read only active, non-deleted products
- anonymous users cannot read profiles, addresses, carts, orders, wishlists, notifications, inventory, coupons, or audit logs
- anonymous users can read only published reviews

### Customer Ownership Tests

- customer can read and update own profile within allowed self-service boundaries
- customer cannot change own `role_id` or privileged `status`
- customer can manage only own addresses
- customer can manage only own carts and cart items
- customer can read only own non-deleted orders and own order items
- customer can manage only own wishlists and wishlist items
- customer can read only own notifications
- customer can create reviews only for own profile and only when verified

### Verification Tests

- unverified customer cannot insert into `product_reviews`
- verified customer can insert pending review rows
- direct customer order creation remains denied

### Internal Permission Tests

- Viewer/Admin/Super Admin with `products.read` can read non-public products
- users with `orders.read_all` can read all orders and order items
- users with `reviews.read` can read all reviews
- users with review moderation permissions can update or delete reviews as allowed
- users with `users.read` can read profile rows

### Denied Access Tests

- customer cannot read another customer’s records
- customer cannot read raw inventory or raw coupons
- customer cannot directly insert orders or notifications
- customer cannot update another user’s wishlist, cart, or address
- internal users without matching permission codes are denied

### Soft Delete Tests

- public product access excludes `deleted_at` rows
- customer order access excludes `deleted_at` rows
- internal read policies allow broader visibility only through explicit permissions

## Required Test Data

- active verified customer
- active unverified customer
- suspended or inactive customer
- Viewer, Admin, and Super Admin internal profiles with seeded permissions
- owned and unowned carts
- owned and unowned orders
- public and non-public products
- published and pending reviews

## Execution Notes

- run after migrations `001` through `005`
- validate using deterministic seed data
- confirm all policies fail closed when helper resolution fails or user context is missing
- add automated SQL assertions or integration tests in a later implementation task
