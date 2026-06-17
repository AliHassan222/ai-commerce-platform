# Helper Function Test Cases

## Purpose

This document defines the database-level validation cases for approved helper functions before application development begins.

## Functions Covered

- `current_profile_id()`
- `current_user_email()`
- `is_verified_email()`
- `current_role_id()`
- `current_role_code()`
- `current_profile_status()`
- `has_permission(permission_code text)`
- `owns_profile(target_profile_id uuid)`
- `owns_cart(target_cart_id uuid)`
- `owns_order(target_order_id uuid)`

## Identity Helper Cases

### `current_profile_id()`

1. authenticated user with valid profile returns matching `profiles.id`
2. unauthenticated execution returns `null`
3. authenticated user with missing profile fails closed

### `current_user_email()`

1. authenticated user returns trusted auth email
2. unauthenticated execution returns `null`
3. value comes from auth context, not client-submitted profile data

### `is_verified_email()`

1. verified user returns `true`
2. unverified user returns `false`
3. unauthenticated execution returns `false`
4. missing auth identity fails closed to `false`

## Role Helper Cases

### `current_role_id()`

1. active customer returns correct role id
2. active admin returns correct role id
3. unauthenticated execution returns `null`
4. missing profile returns `null`

### `current_role_code()`

1. `Super Admin` resolves to `super_admin`
2. `Admin` resolves to `admin`
3. `Viewer` resolves to `viewer`
4. `Customer` resolves to `customer`
5. unauthenticated execution returns `null`

### `current_profile_status()`

1. active profile returns `active`
2. pending profile returns `pending`
3. suspended profile returns `suspended`
4. inactive profile returns `inactive`
5. unauthenticated execution returns `null`

## Permission Helper Cases

### `has_permission()`

1. `Super Admin` returns `true` for seeded internal permissions
2. `Admin` returns `true` for product and category management permissions
3. `Viewer` returns `true` for read-only seeded permissions and `false` for write permissions
4. `Customer` returns `false` for all internal permissions
5. inactive role or inactive permission returns `false`
6. unauthenticated execution returns `false`
7. unknown permission code returns `false`

## Ownership Helper Cases

### `owns_profile()`

1. own profile id returns `true`
2. another user profile id returns `false`
3. unauthenticated execution returns `false`

### `owns_cart()`

1. owned cart returns `true`
2. unowned cart returns `false`
3. invalid cart id returns `false`
4. unauthenticated execution returns `false`

### `owns_order()`

1. owned order returns `true`
2. unowned order returns `false`
3. invalid order id returns `false`
4. unauthenticated execution returns `false`

## Security Expectations

- all helpers fail closed
- no helper expands unauthenticated access
- permission and ownership helpers must not rely on client-submitted identity assumptions
- helper results must remain consistent with seeded roles and personas
