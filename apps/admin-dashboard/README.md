# AI Commerce Admin Dashboard

This app contains the Phase 2 admin dashboard scaffold converted from the approved Stitch prototype visual baseline.

## Stack

- Next.js App Router
- TypeScript
- Tailwind CSS

## Routes

- `/admin`
- `/admin/login`
- `/admin/products`
- `/admin/products/new`
- `/admin/products/[productId]`
- `/admin/categories`
- `/admin/inventory`
- `/admin/orders`
- `/admin/customers`
- `/admin/reviews`
- `/admin/coupons`
- `/admin/reports`
- `/admin/notifications`
- `/admin/users`
- `/admin/roles`
- `/admin/permissions`
- `/admin/audit-logs`
- `/admin/settings`

## Current Scope

- visual admin shell
- sidebar navigation
- top header
- dashboard route
- login route
- protected placeholder routes
- static RBAC-aware navigation metadata for `Super Admin`, `Admin`, and `Viewer`

## Not Yet Implemented

- Supabase Auth
- Supabase data access
- real route protection
- server actions
- business workflows
- production RBAC enforcement
