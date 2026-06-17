# ERD

## Purpose

This document provides a readable entity relationship diagram for the current schema after:

- `001_initial_core_ecommerce_schema.sql`
- `002_ecommerce_extensions.sql`
- `003_add_variant_references_to_cart_and_order_items.sql`

## Entity Relationship Diagram

```mermaid
erDiagram
    ROLES ||--o{ PROFILES : assigns
    ROLES ||--o{ ROLE_PERMISSIONS : grants
    PERMISSIONS ||--o{ ROLE_PERMISSIONS : maps

    PROFILES ||--o{ ADDRESSES : owns
    PROFILES ||--o{ CARTS : owns
    PROFILES ||--o{ ORDERS : places
    PROFILES ||--o{ WISHLISTS : owns
    PROFILES ||--o{ PRODUCT_REVIEWS : writes
    PROFILES ||--o{ NOTIFICATIONS : receives
    PROFILES ||--o{ AUDIT_LOGS : triggers
    PROFILES ||--o| VENDORS : owns
    ADDRESSES ||--o{ ORDERS : shipping_address
    ADDRESSES ||--o{ ORDERS : billing_address

    VENDORS ||--o{ PRODUCTS : supplies
    VENDORS ||--o{ INVENTORY : stocks

    CATEGORIES ||--o{ CATEGORIES : nests
    CATEGORIES ||--o{ PRODUCTS : groups

    PRODUCTS ||--o{ PRODUCT_VARIANTS : has
    PRODUCTS ||--o{ PRODUCT_IMAGES : displays
    PRODUCTS ||--o{ CART_ITEMS : references
    PRODUCTS ||--o{ ORDER_ITEMS : snapshots
    PRODUCTS ||--o{ WISHLIST_ITEMS : saves
    PRODUCTS ||--o{ PRODUCT_REVIEWS : receives

    PRODUCT_VARIANTS ||--o{ CART_ITEMS : selected
    PRODUCT_VARIANTS ||--o{ ORDER_ITEMS : purchased
    PRODUCT_VARIANTS ||--o{ INVENTORY : tracks
    PRODUCT_VARIANTS ||--o{ WISHLIST_ITEMS : saves
    PRODUCT_VARIANTS ||--o{ PRODUCT_REVIEWS : scopes

    CARTS ||--o{ CART_ITEMS : contains
    CARTS ||--o| ORDERS : converts_to

    ORDERS ||--o{ ORDER_ITEMS : contains
    ORDERS ||--o{ ORDER_COUPONS : applies
    COUPONS ||--o{ ORDER_COUPONS : redeems

    WISHLISTS ||--o{ WISHLIST_ITEMS : contains
```

## Relationship Notes

- `profiles` extends `auth.users` and acts as the operational user record.
- `products` is still the main catalog and commerce reference in MVP.
- `product_variants` now support cart and order item references, while `variant_id` remains nullable for backward compatibility.
- `inventory` is already variant-based.
- `vendors` is introduced now for future multi-vendor expansion, but order and cart ownership remain platform-centric in the current schema.
- `product_images.image_url` references the Supabase Storage `product-images` bucket.

## Implementation Warning

`variant_id` is now available in both `cart_items` and `order_items`, but remains nullable for backward compatibility.

Application and checkout validation should require `variant_id` whenever a product has variants.
