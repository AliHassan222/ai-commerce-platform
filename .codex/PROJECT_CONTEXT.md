# Project Context

## Project Vision

Build a production-grade AI Commerce Platform with a Flutter mobile customer experience, a Next.js admin dashboard, and a Supabase-powered backend foundation. The platform must be secure, scalable, documentation-driven, and ready to evolve into future multi-vendor and AI-enabled commerce workflows.

## Business Goals

- deliver an MVP ecommerce platform with strong admin and customer foundations
- enable customer browsing, account management, cart, checkout, and order history flows
- enable internal teams to manage catalog, categories, orders, users, reviews, coupons, and reporting
- enforce strong security, role-based access, and row-level ownership from the start
- preserve a clean path toward multi-vendor support, richer search, notifications, and future AI capabilities

## Approved Stack

- Mobile app: Flutter
- Admin dashboard: Next.js
- Backend platform: Supabase
- Database: Supabase PostgreSQL
- Authentication: Supabase Auth
- Storage: Supabase Storage
- Notifications: Firebase Cloud Messaging
- Testing: Playwright, Postman/Newman, Flutter tests

## Architecture Summary

- monorepo structure with `apps/`, `backend/`, `docs/`, `tests/`, and future `packages/`, `infra/`, and `scripts/`
- Flutter mobile app in `apps/mobile-app`
- Next.js admin dashboard in `apps/admin-dashboard`
- Supabase used for PostgreSQL, Auth, Storage, RLS, and Edge Functions
- direct Supabase client access allowed for public catalog reads and safe own-data operations
- Edge Functions required for checkout, guest cart merge, coupon validation, admin high-risk operations, notifications dispatch, and future payments or shipping integrations
- long-running work must use background/event-driven processing and must not block user requests

## Database Summary

Current approved migration chain:

- `001_initial_core_ecommerce_schema.sql`
- `002_ecommerce_extensions.sql`
- `003_add_variant_references_to_cart_and_order_items.sql`

Core domains:

- identity and access: `profiles`, `roles`, `permissions`, `role_permissions`
- catalog: `categories`, `products`, `product_images`, `product_variants`, `inventory`
- commerce: `carts`, `cart_items`, `orders`, `order_items`, `coupons`, `order_coupons`
- customer features: `addresses`, `wishlists`, `wishlist_items`, `product_reviews`, `notifications`
- governance: `audit_logs`
- future marketplace: `vendors`

Important schema rules:

- `profiles.id = auth.users.id` is the intended MVP identity mapping
- `categories`, `products`, and `orders` use `deleted_at` soft deletes
- `variant_id` exists on `cart_items` and `order_items`, but remains nullable for backward compatibility
- when a product has variants, application and checkout validation must require `variant_id`

## Security Model

- Supabase Auth is the system identity provider
- `profiles` is the operational user table
- RBAC is modeled through `roles`, `permissions`, and `role_permissions`
- RLS is deny-by-default
- ownership checks should standardize on helper-based profile resolution such as `current_profile_id()`
- customers can only access their own private records
- public users can read only active, non-deleted catalog data and published reviews
- admin and super admin access must remain permission-controlled
- Viewer is read-only with tightly scoped internal visibility
- Vendor access is future-scoped and limited to vendor-owned data only
- checkout, coupon validation, guest cart merge, and notification dispatch must use protected backend workflows

## API Strategy

- REST over HTTPS
- JSON payloads
- versioning starts at `/api/v1`
- consistent success and error envelopes
- `POST /api/v1/checkout` is the single order-creation workflow
- product browsing, categories, and safe own-data reads can use direct Supabase access where RLS is sufficient
- admin-sensitive and multi-step workflows must use Edge Functions or protected server-side actions

## MVP Scope

Admin Dashboard MVP:

- internal authentication and role-aware access
- category management
- product management
- product media management
- order visibility and status handling

Mobile App MVP:

- customer registration and login
- product browsing and category navigation
- product details
- cart management
- basic order history and notification foundation

Backend MVP:

- schema and migrations
- auth and profiles
- roles and RLS foundation
- catalog, carts, orders, reviews, wishlists, notifications, and coupon foundations

## Out of Scope for MVP

- online payments
- multi-vendor seller portal
- AI recommendations
- loyalty points
- multi-language
- multi-currency
- live chat

## Current Project Status

- design phase complete and approved
- planning, architecture, schema, API, auth, ERD, RLS, and implementation documents are approved
- no application code has started yet
- repository is ready to begin implementation from Phase 1 with documentation as the source of truth

## Current Phase

Phase 0.5 Governance Complete

Next Phase:
Phase 1 - Supabase Foundation

Objectives:

- create Supabase project
- execute migrations
- create helper functions
- implement RLS policies
- seed foundational data

## Future AI Direction

Future AI capabilities may include:

- recommendation engine
- product enrichment
- shopping assistant
- operational AI workflows

All AI features must execute through backend-controlled services and never directly from client applications.
