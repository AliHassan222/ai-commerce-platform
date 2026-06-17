# RBAC Test Cases

## Purpose

This document defines role-and-permission validation cases for the seeded Phase 1 RBAC foundation.

## Roles Covered

- `Super Admin`
- `Admin`
- `Viewer`
- `Customer`
- `Vendor`

## Super Admin

1. has all seeded permissions
2. can resolve all role-based helper checks positively where applicable
3. can read all internal RBAC-protected datasets in current RLS scope
4. can perform privileged review moderation actions

## Admin

1. has all seeded `products.*` permissions in Phase 1 scope
2. has all seeded `categories.*` permissions, including `categories.restore`
3. has `orders.read_all`
4. has `orders.update_status`
5. has `reviews.read`, `reviews.moderate`, `reviews.hide`, and `reviews.delete`
6. does not have `users.manage_roles` unless explicitly added later

## Viewer

1. has `users.read`
2. has `products.read`
3. has `categories.read`
4. has `orders.read_all`
5. has `reviews.read`
6. does not have write, delete, publish, moderation, or role-management permissions

## Customer

1. has no internal permissions
2. relies on ownership and public access rules instead of RBAC grants
3. cannot pass internal `has_permission()` checks

## Vendor

1. exists as seeded inactive future role
2. has no assigned permissions in current Phase 1 seed foundation
3. must not gain internal access through current RLS or RBAC behavior

## Cross-Role Validation

1. role ids map correctly from `profiles.role_id`
2. role codes normalize correctly in helper output
3. inactive or missing roles fail closed
4. permission inheritance is controlled only by `role_permissions`
