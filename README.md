# AI Commerce Platform

Production-grade AI Commerce Platform initialized as a documentation-first monorepo.

This repository is currently in the planning and architecture phase. The focus is on defining product scope, target architecture, approved technology choices, data design, API boundaries, and delivery phases before application code is introduced.

## Objectives

- Build a scalable multi-tenant commerce platform with AI-assisted merchandising, search, support, and operations.
- Support storefront, admin, and internal operations use cases from a shared platform foundation.
- Establish clear domain boundaries, contracts, and delivery standards before implementation starts.
- Enable iterative delivery with strong testing, observability, and security from day one.

## Current Phase

The repository intentionally contains architecture and planning documentation only.

Included deliverables:

- Product user stories
- Initial database schema design
- API specification baseline
- System architecture guidance
- Test strategy for production readiness
- Implementation plan and delivery phases

## Project Status

- Current status: planning and architecture review
- No application code has started yet

## Approved Technology Stack

- Mobile App: Flutter
- Admin Dashboard: Next.js
- Backend Platform: Supabase
- Database: Supabase PostgreSQL
- Authentication: Supabase Auth
- File Storage: Supabase Storage
- Notifications: Firebase Cloud Messaging
- Testing: Playwright, Postman/Newman, Flutter tests

## Current Repository Structure

```text
/
|-- apps/
|-- backend/
|-- docs/
|-- tests/
`-- README.md
```

## Recommended Monorepo Architecture

The current top-level structure is a good start, but the best production-ready evolution is:

```text
/
|-- apps/
|   |-- mobile-app/          # Flutter mobile commerce application
|   `-- admin-dashboard/     # Next.js admin and operations console
|-- backend/
|   |-- supabase/            # SQL migrations, RLS, seed data, edge functions
|   |-- integrations/        # FCM, payment, shipping, and external adapters
|   `-- policies/            # Auth, RBAC, security, and API policy docs
|-- docs/                    # Product, architecture, API, QA documents
|-- tests/
|   |-- contract/
|   |-- integration/
|   |-- e2e/
|   |-- performance/
|   `-- security/
|-- infra/                   # IaC, environments, deployment templates
|-- packages/                # Shared packages and contracts
|   |-- shared-types/
|   |-- api-contracts/
|   |-- ui-tokens/
|   `-- tooling-config/
|-- scripts/                 # Automation and developer workflows
`-- README.md
```

## Why This Monorepo Shape

- Keeps user-facing applications isolated while enabling shared packages.
- Keeps Supabase assets, policies, and integrations organized in a backend workspace.
- Supports clear separation between product apps, backend configuration, and shared contracts.
- Centralizes contracts, testing, and infrastructure for consistent delivery.
- Reduces duplication across mobile, web, database, and operational tooling.

## Architecture Direction

- Frontend: Flutter mobile app and Next.js admin dashboard in `apps/`.
- Backend: Supabase for PostgreSQL, Auth, Storage, database policies, and edge functions.
- Integrations: FCM for push notifications and external providers for payments and shipping.
- Data: Supabase PostgreSQL as the primary transactional store with storage buckets for media assets.
- AI: AI-assisted features integrated through controlled backend workflows and auditable service boundaries.
- Quality: automated contract, integration, end-to-end, performance, and security testing in `tests/`.

## MVP Scope

### Admin Dashboard MVP

- Secure internal authentication and role-aware access
- Category management
- Product management
- Product media management
- Basic order visibility and operational status handling

### Mobile App MVP

- Customer registration and login
- Product browsing and category navigation
- Product details
- Cart management
- Basic order history and notifications foundation

### Backend MVP

- Supabase Auth integration
- Profiles, roles, and authorization foundation
- Core ecommerce schema and migrations
- Catalog, cart, order, review, wishlist, notification, and coupon foundations
- Row-level security implementation for MVP resources

## Out of Scope for MVP

- Online payments
- Multi-vendor seller portal
- AI recommendations
- Loyalty points
- Multi-language
- Multi-currency
- Live chat

## Documentation Index

- [Architecture](./docs/ARCHITECTURE.md)
- [User Stories](./docs/USER_STORIES.md)
- [Database Schema](./docs/DATABASE_SCHEMA.md)
- [API Spec](./docs/API_SPEC.md)
- [Test Strategy](./docs/TEST_STRATEGY.md)
- [Implementation Plan](./docs/IMPLEMENTATION_PLAN.md)

## Development Phases

### Phase 1: Supabase Setup and Database Schema

- Provision Supabase project structure
- Define PostgreSQL schema, migrations, and seed strategy
- Configure storage buckets and environment structure

### Phase 2: Auth and Roles

- Implement Supabase Auth flows
- Define user roles and access policies
- Apply row-level security and admin authorization rules

### Phase 3: Product and Category Backend

- Build catalog tables, relationships, and policies
- Expose product and category APIs or edge functions
- Prepare media storage and admin data flows

### Phase 4: Admin Dashboard MVP

- Build Next.js admin authentication and protected routes
- Implement category and product management screens
- Add operational visibility for core catalog workflows

### Phase 5: Mobile App MVP

- Build Flutter authentication, browsing, and product detail flows
- Implement category navigation and cart foundation
- Integrate with approved backend contracts

### Phase 6: Orders and Checkout

- Add cart finalization, checkout, and order creation
- Integrate payment workflow and order history
- Connect notifications and operational status updates

### Phase 7: Testing

- Add Playwright end-to-end coverage for admin flows
- Add Postman/Newman API regression coverage
- Add Flutter unit, widget, and integration tests

### Phase 8: APK and Deployment

- Prepare Android APK or App Bundle generation
- Finalize admin deployment pipeline
- Configure production environments, secrets, and release checks

## Local Development Setup

The project is still in planning, so the commands below are placeholders and will be finalized once application scaffolding begins.

### Admin Dashboard Commands

```bash
# Placeholder
cd apps/admin-dashboard
npm install
npm run dev
```

### Flutter Commands

```bash
# Placeholder
cd apps/mobile-app
flutter pub get
flutter run
```

### Supabase Commands

```bash
# Placeholder
cd backend/supabase
supabase start
supabase db reset
supabase migration up
```

## Environment Files

- `.env.local`
- `.env`
- Supabase environment files for local, staging, and production configuration

Important note:

- secrets, tokens, private keys, and service credentials must never be committed to the repository
- environment files should be managed through secure local setup and deployment secrets management

## Recommended Next Steps

1. Approve the final architecture and implementation plan.
2. Confirm exact MVP scope for admin and mobile releases.
3. Finalize Supabase project conventions, naming, and environment strategy.
4. Prepare repository scaffolding for Phase 1.
5. Start implementation only after the planning documents are approved.
