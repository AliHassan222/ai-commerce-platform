# Roles Permission Matrix

## Purpose

This document defines the authorization model for the AI Commerce Platform at the business level before SQL policies and application guards are implemented.

## Role Hierarchy

From highest to lowest authority:

1. Super Admin
2. Admin
3. Viewer
4. Customer
5. Vendor (future scoped role, not active in MVP)

## Role Definitions

### Super Admin

Full platform control across configuration, users, catalog, orders, reports, and future vendor management.

### Admin

Operational management role for day-to-day platform administration without unrestricted system ownership.

### Viewer

Read-only internal role for monitoring products, categories, orders, users, reports, and reviews.

### Customer

End-user role for self-service commerce actions limited to their own account and shopping activity.

### Vendor

Future marketplace role for managing only vendor-owned catalog, inventory, and order visibility.

## Permission Naming Convention

Permission pattern:

- `<resource>.<action>`

Examples:

- `products.read`
- `orders.update_status`
- `users.manage_roles`

## Permission Catalog

### Products

- `products.read`
- `products.create`
- `products.update`
- `products.delete`
- `products.publish`
- `products.restore`

### Categories

- `categories.read`
- `categories.create`
- `categories.update`
- `categories.delete`
- `categories.restore`

### Orders

- `orders.read`
- `orders.read_all`
- `orders.update_status`
- `orders.cancel`
- `orders.refund`
- `orders.export`

### Users

- `users.read`
- `users.create`
- `users.update`
- `users.disable`
- `users.manage_roles`

### Vendors

- `vendors.read`
- `vendors.create`
- `vendors.update`
- `vendors.approve`
- `vendors.suspend`

### Reviews

- `reviews.read`
- `reviews.moderate`
- `reviews.hide`
- `reviews.delete`

### Coupons

- `coupons.read`
- `coupons.create`
- `coupons.update`
- `coupons.disable`

### Reports

- `reports.read`
- `reports.export`

## Matrix

| Permission | Super Admin | Admin | Viewer | Customer | Vendor |
|---|---|---|---|---|---|
| `products.read` | Yes | Yes | Yes | Yes | Yes |
| `products.create` | Yes | Yes | No | No | Future scoped |
| `products.update` | Yes | Yes | No | No | Future scoped |
| `products.delete` | Yes | Limited | No | No | No |
| `products.publish` | Yes | Yes | No | No | Future scoped |
| `products.restore` | Yes | Yes | No | No | No |
| `categories.read` | Yes | Yes | Yes | Yes | Yes |
| `categories.create` | Yes | Yes | No | No | No |
| `categories.update` | Yes | Yes | No | No | No |
| `categories.delete` | Yes | Limited | No | No | No |
| `categories.restore` | Yes | Yes | No | No | No |
| `orders.read` | Yes | Yes | Yes | Own only | Future scoped |
| `orders.read_all` | Yes | Yes | Yes | No | No |
| `orders.update_status` | Yes | Yes | No | No | Future scoped |
| `orders.cancel` | Yes | Yes | No | Own only by business rule | Future scoped |
| `orders.refund` | Yes | Limited | No | No | No |
| `orders.export` | Yes | Yes | No | No | Future scoped limited |
| `users.read` | Yes | Yes | Yes | Own only | No |
| `users.create` | Yes | Limited | No | Self-register only | No |
| `users.update` | Yes | Yes | No | Own only | Own only future |
| `users.disable` | Yes | Limited | No | No | No |
| `users.manage_roles` | Yes | No | No | No | No |
| `vendors.read` | Yes | Yes | Yes | No | Own only future |
| `vendors.create` | Yes | Yes | No | No | Self-onboarding future |
| `vendors.update` | Yes | Yes | No | No | Own only future |
| `vendors.approve` | Yes | Limited | No | No | No |
| `vendors.suspend` | Yes | Limited | No | No | No |
| `reviews.read` | Yes | Yes | Yes | Yes | Future scoped |
| `reviews.moderate` | Yes | Yes | No | No | No |
| `reviews.hide` | Yes | Yes | No | No | Future scoped limited |
| `reviews.delete` | Yes | Limited | No | Own only before moderation rule | No |
| `coupons.read` | Yes | Yes | Yes | Applied result only | Future scoped limited |
| `coupons.create` | Yes | Yes | No | No | No |
| `coupons.update` | Yes | Yes | No | No | No |
| `coupons.disable` | Yes | Yes | No | No | No |
| `reports.read` | Yes | Yes | Yes | No | Future scoped limited |
| `reports.export` | Yes | Yes | No | No | Future scoped limited |

## Interpretation Notes

- `Yes` means full access within the resource boundary.
- `Limited` means allowed, but should be narrowed by workflow rules, approval rules, or entity state.
- `Own only` means access is restricted to records owned by the authenticated user.
- `Future scoped` means the permission exists conceptually but will later be constrained to vendor-owned records only.

## Recommended MVP Role Assignment

- Internal platform owner: `Super Admin`
- Operations and merchandising team: `Admin`
- Read-only business stakeholders: `Viewer`
- End users: `Customer`
- Marketplace sellers: `Vendor` in a future phase only

## Implementation Guidance

- Store role assignment on `profiles.role_id` for the current MVP.
- Back permission checks with a role-to-permission lookup using `roles`, `permissions`, and `role_permissions`.
- Enforce sensitive actions in both application logic and database policy layers.
- Keep destructive permissions narrower than read and update permissions.
