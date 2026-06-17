# RLS Test Cases

## Purpose

This document defines the validation cases for the Phase 1 RLS foundation implemented in `005_rls_foundation.sql`, `006_categories_rls.sql`, and `007_catalog_detail_rls.sql`.

## Scope

Tables in current SQL scope:

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

## Public Access

1. anonymous user can read only active, non-deleted categories
2. anonymous user cannot read inactive or soft-deleted categories
1. anonymous user can read only active, non-deleted products
2. anonymous user cannot read draft products
3. anonymous user cannot read soft-deleted products
4. anonymous user can read only active variants whose parent product is active and non-deleted
5. anonymous user cannot read inactive variants
6. anonymous user can read only active product images whose parent product is active and non-deleted
7. anonymous user cannot read inactive product images or images for non-public products
8. anonymous user can read only published reviews
9. anonymous user cannot read profiles, addresses, carts, orders, wishlists, or notifications

## Customer Ownership

1. customer can read only own profile
2. customer can update only own allowed profile fields
3. customer cannot change own `role_id`
4. customer cannot change own `status`
5. customer can read, insert, update, and delete only own addresses
6. customer can read, insert, update, and delete only own carts
7. customer can read, insert, update, and delete only own cart items
8. customer can read only own non-deleted orders
9. customer can read only own order items
10. customer can read, insert, update, and delete only own wishlists
11. customer can read, insert, and delete only own wishlist items
12. customer can read only own notifications

## Verified vs Unverified Users

1. verified customer can create own review with `status = pending`
2. unverified customer cannot create review
3. both verified and unverified customers can browse public products
4. both verified and unverified customers can browse public variants and product images tied to public products
5. direct order creation remains denied regardless of verification state

## Admin Access

1. Admin with `users.read` can read profiles
2. Admin with `categories.read` can read non-public categories if policy permits broader internal view
3. Admin with `categories.create` can insert categories
4. Admin with `categories.update` can update categories
5. Admin with `categories.delete` can soft delete categories through update
6. Admin with `categories.restore` can restore categories through update
2. Admin with `products.read` can read draft and soft-deleted products if policy permits broader internal view
3. Admin with `products.create` can insert products
4. Admin with `products.update` can update products
5. Admin with `products.read` can read all variants and product images
6. Admin with `products.create` can insert variants
7. Admin with `products.create` or `products.update` can insert product images
8. Admin with `products.update` can update variants and product images
9. Admin with `products.delete` can archive variants through update and delete product images
10. Admin with `orders.read_all` can read all orders
11. Admin with review moderation permissions can update and delete reviews as approved

## Viewer Access

1. Viewer with `users.read` can read profiles where policy allows
2. Viewer with `products.read` can read internal product visibility
3. Viewer with `products.read` can read internal variants and product images
4. Viewer with `orders.read_all` can read all orders
5. Viewer with `reviews.read` can read all reviews
6. Viewer cannot create, update, or delete protected records

## Denied Access

1. customer cannot read another customer profile
2. customer cannot read another customer cart or wishlist
3. customer cannot read raw inventory
4. customer cannot read raw coupons
5. customer cannot read audit logs
6. customer cannot insert notifications directly
7. customer cannot insert, update, or delete variants or product images directly
8. anonymous user cannot read private data even when ids are known

## Soft Delete Behavior

1. public category access excludes `deleted_at` rows
1. public product access excludes `deleted_at` records
2. public variant access excludes variants whose parent product is soft-deleted
3. public product image access excludes images whose parent product is soft-deleted
4. customer order access excludes `deleted_at` rows
5. internal product access is broader only through approved permission paths

## Delete Restrictions

1. no role can hard delete categories through direct table `DELETE`
2. category delete behavior is represented only by soft delete through approved `UPDATE` paths
3. no role can hard delete product variants through direct table `DELETE`
4. product variant archive behavior is represented only by approved `UPDATE` paths

## Fail-Closed Checks

1. helper resolution failure denies access
2. missing profile context denies owned-resource access
3. missing permission mapping denies internal elevated access
