# API Specification

## Purpose

This document defines the initial API contract direction for the AI Commerce Platform. It is intentionally implementation-agnostic and suitable as the baseline for future OpenAPI documentation.

## API Style

- External style: REST over HTTPS
- Payload format: JSON
- Authentication: OAuth2/JWT for authenticated clients
- Internal communication: REST or gRPC depending on service needs
- Versioning: `/api/v1`

## Design Principles

- Resource-oriented endpoints with clear domain ownership
- Idempotent write operations where applicable
- Consistent pagination, filtering, and error formats
- Explicit separation between public storefront APIs and privileged admin APIs
- Deferred capabilities should remain clearly separated from MVP endpoints

## Standard Response Shape

### Success

```json
{
  "data": {},
  "meta": {
    "requestId": "uuid"
  }
}
```

### Error

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request payload is invalid.",
    "details": []
  },
  "meta": {
    "requestId": "uuid"
  }
}
```

## Authentication Endpoints

### `POST /api/v1/auth/register`

Creates a customer account.

### `POST /api/v1/auth/login`

Authenticates a user and issues tokens.

### `POST /api/v1/auth/logout`

Revokes the current session or token pair.

### `GET /api/v1/auth/me`

Returns the authenticated user profile.

## Catalog Endpoints

### `GET /api/v1/categories`

Returns active category tree or flat list.

Query parameters:

- `parentId`
- `includeInactive` for privileged users only

### `GET /api/v1/products`

Returns paginated product listings.

Query parameters:

- `search`
- `category`
- `brand`
- `minPrice`
- `maxPrice`
- `sort`
- `page`
- `pageSize`

### `GET /api/v1/products/{productId}`

Returns a single product with variants, media, and availability summary.

## Cart Endpoints

### `GET /api/v1/cart`

Returns the active cart for the current session or user.

### `POST /api/v1/cart/items`

Adds an item to cart.

Request example:

```json
{
  "productId": "uuid",
  "variantId": "uuid",
  "quantity": 2
}
```

Validation note:

- If a product has variants, `variantId` is required.
- If a product has no variants, `variantId` may be `null`.

### `PATCH /api/v1/cart/items/{itemId}`

Updates cart item quantity.

### `DELETE /api/v1/cart/items/{itemId}`

Removes an item from cart.

## Checkout and Orders

### `POST /api/v1/checkout`

Validates cart, prices, inventory, shipping, coupon eligibility, email verification state, and order readiness, then creates the order as the single order creation workflow.

### `GET /api/v1/orders`

Returns paginated order history for the authenticated customer.

### `GET /api/v1/orders/{orderId}`

Returns order details and status timeline.

## Address Endpoints

### `GET /api/v1/addresses`

Returns addresses for the authenticated customer.

### `POST /api/v1/addresses`

Creates a new customer address.

### `PATCH /api/v1/addresses/{addressId}`

Updates an owned address.

### `DELETE /api/v1/addresses/{addressId}`

Removes or archives an owned address based on business policy.

## Wishlist Endpoints

### `GET /api/v1/wishlists`

Returns wishlists for the authenticated customer.

### `POST /api/v1/wishlists`

Creates a new wishlist.

### `GET /api/v1/wishlists/{wishlistId}`

Returns a single wishlist with items.

### `POST /api/v1/wishlists/{wishlistId}/items`

Adds an item to a wishlist.

Request example:

```json
{
  "productId": "uuid",
  "variantId": "uuid"
}
```

### `DELETE /api/v1/wishlists/{wishlistId}/items/{itemId}`

Removes an item from a wishlist.

## Notifications Endpoints

### `GET /api/v1/notifications`

Returns notifications for the authenticated customer.

### `PATCH /api/v1/notifications/{notificationId}/read`

Marks a notification as read.

## Reviews Endpoints

### `GET /api/v1/products/{productId}/reviews`

Returns published reviews for a product.

### `POST /api/v1/products/{productId}/reviews`

Creates a review for a product. Verified email required.

### `PATCH /api/v1/reviews/{reviewId}`

Updates an owned pending review when allowed by business rules.

### `DELETE /api/v1/reviews/{reviewId}`

Deletes or hides an owned review when allowed by policy.

## Admin Endpoints

### `GET /api/v1/admin/categories`

Returns categories for administrative management.

### `POST /api/v1/admin/categories`

Creates a category.

### `PATCH /api/v1/admin/categories/{categoryId}`

Updates a category.

### `GET /api/v1/admin/products`

Returns products for administrative management.

### `POST /api/v1/admin/products`

Creates a product.

### `PATCH /api/v1/admin/products/{productId}`

Updates product metadata, lifecycle state, or merchandising fields.

### `GET /api/v1/admin/inventory`

Returns inventory records with operational filters.

### `POST /api/v1/admin/inventory`

Creates an inventory record.

### `PATCH /api/v1/admin/inventory/{inventoryId}`

Updates stock, thresholds, or status where allowed.

### `GET /api/v1/admin/orders`

Returns orders with operational filters.

### `PATCH /api/v1/admin/orders/{orderId}/status`

Updates order workflow status where allowed.

### `GET /api/v1/admin/users`

Returns users for administrative management.

### `POST /api/v1/admin/users`

Creates or invites an internal user through protected admin workflow.

### `PATCH /api/v1/admin/users/{userId}`

Updates allowed administrative user fields.

### `PATCH /api/v1/admin/users/{userId}/role`

Promotes or changes a user role. Super Admin only.

### `GET /api/v1/admin/roles`

Returns role and permission definitions.

### `PATCH /api/v1/admin/roles/{roleId}`

Updates role metadata where applicable.

### `GET /api/v1/admin/coupons`

Returns coupons for administrative management.

### `POST /api/v1/admin/coupons`

Creates a coupon.

### `PATCH /api/v1/admin/coupons/{couponId}`

Updates coupon rules, lifecycle state, or usage controls.

### `GET /api/v1/admin/reports`

Returns administrative reporting datasets or report summaries.

## Order Status Transition Rules

Approved forward order flow:

- `pending -> confirmed -> processing -> shipped -> delivered`

Rules:

- backward transitions are invalid by default
- status transitions must be validated server-side
- cancellation, refund, and exception flows must use explicit business rules rather than bypassing the state machine
- admin or backend workflows must audit every status transition

## Security Requirements

- Enforce HTTPS everywhere.
- Require authentication for user-specific and admin endpoints.
- Apply RBAC for admin operations.
- Validate and sanitize all input.
- Enforce rate limits for auth, search, checkout, and admin-sensitive endpoints.
- Record audit events for privileged writes.

## Non-Functional API Requirements

- P95 latency targets defined per endpoint category.
- Correlation ID included in every request/response path.
- Backward-compatible changes only within a version.
- Contract tests required before endpoint release.

## Error Code Catalog

### Auth Errors

- `AUTH_UNAUTHORIZED`
- `AUTH_INVALID_CREDENTIALS`
- `AUTH_SESSION_EXPIRED`
- `AUTH_EMAIL_NOT_VERIFIED`
- `AUTH_FORBIDDEN`

### User Errors

- `USER_NOT_FOUND`
- `USER_ROLE_INVALID`
- `USER_STATUS_INVALID`
- `USER_PROFILE_MISSING`

### Product Errors

- `PRODUCT_NOT_FOUND`
- `PRODUCT_INACTIVE`
- `PRODUCT_OUT_OF_STOCK`
- `PRODUCT_INVALID_CATEGORY`

### Order Errors

- `ORDER_NOT_FOUND`
- `ORDER_INVALID_STATE`
- `ORDER_INVALID_TRANSITION`
- `ORDER_CART_INVALID`
- `ORDER_CHECKOUT_FAILED`

### Coupon Errors

- `COUPON_NOT_FOUND`
- `COUPON_INACTIVE`
- `COUPON_EXPIRED`
- `COUPON_NOT_ELIGIBLE`
- `COUPON_USAGE_LIMIT_REACHED`

### Payment Errors

- `PAYMENT_REQUIRED`
- `PAYMENT_FAILED`
- `PAYMENT_PROVIDER_ERROR`
- `PAYMENT_STATE_INVALID`

## Future Deliverables

- Full OpenAPI 3.1 definition
- Extended error code catalog and error handling guidelines
- Pagination and filtering conventions
- SDK generation guidelines
