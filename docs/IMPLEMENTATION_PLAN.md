# Implementation Plan

## Purpose

This document translates the approved architecture into a phased execution plan for the AI Commerce Platform. It is designed to reduce delivery risk, keep scope controlled, and allow incremental validation before broader feature expansion.

## Approved Stack

- Mobile application: Flutter
- Admin dashboard: Next.js
- Backend platform: Supabase
- Database: Supabase PostgreSQL
- Authentication: Supabase Auth
- File storage: Supabase Storage
- Notifications: Firebase Cloud Messaging
- Testing: Playwright, Postman/Newman, Flutter tests

## Delivery Principles

- Build the platform in thin, testable vertical slices
- Finalize data and access control before UI-heavy work
- Keep admin workflows ahead of customer app workflows
- Enforce API and schema contracts before scaling feature breadth
- Validate each phase before starting the next

## Target Monorepo Layout

```text
/
|-- apps/
|   |-- mobile-app/
|   `-- admin-dashboard/
|-- backend/
|   |-- supabase/
|   |-- integrations/
|   `-- policies/
|-- docs/
|-- tests/
|-- packages/
|-- infra/
`-- scripts/
```

## Phase 1: Supabase Setup and Database Schema

### Goal

Establish the backend foundation, database structure, and environment conventions.

### Scope

- Create Supabase project setup conventions for local, staging, and production
- Define initial PostgreSQL schema for users, roles, categories, products, variants, carts, orders, payments, and audit logs
- Plan SQL migration strategy and seed data approach
- Define storage buckets for product media and platform assets
- Define environment variable and secret management rules

### Deliverables

- Supabase environment plan
- SQL migration roadmap
- Approved schema and relationship model
- Storage bucket design
- Role and policy design inputs for Phase 2

### Exit Criteria

- Schema approved
- Core tables and naming conventions finalized
- Migration sequence documented
- Environment strategy approved

## Phase 2: Auth and Roles

### Goal

Implement secure authentication and authorization foundations.

### Scope

- Configure Supabase Auth for customer and admin users
- Define user profile model and role assignments
- Design RBAC model for super admin, admin, merchandiser, support, and operations roles
- Define row-level security strategy for sensitive tables
- Document session handling and protected route expectations for mobile and admin

### Deliverables

- Auth flow definitions
- RBAC matrix
- Row-level security policy plan
- Admin access model

### Exit Criteria

- Roles and permissions approved
- Auth journeys mapped
- RLS strategy finalized for MVP tables

## Phase 3: Product and Category Backend

### Goal

Prepare the backend catalog domain for admin management and customer consumption.

### Scope

- Finalize product, category, brand, variant, image, and attribute models
- Define backend APIs, views, or edge functions for catalog reads and writes
- Define validation rules for product creation and publishing
- Document image upload flow using Supabase Storage
- Define search and filtering strategy for MVP

### Deliverables

- Catalog backend design
- Category hierarchy rules
- Product lifecycle states
- Media storage flow
- Catalog API contract refinements

### Exit Criteria

- Product and category contracts approved
- Admin catalog use cases fully covered
- Backend data flow ready for dashboard implementation

## Phase 4: Admin Dashboard MVP

### Goal

Deliver the first operational interface for internal teams.

### Scope

- Build the Next.js admin dashboard architecture
- Define route structure and auth-protected layouts
- Implement MVP screens for login, dashboard home, categories, products, and product media
- Define admin form behavior, validation, error handling, and audit expectations
- Document dashboard integration points with Supabase

### Deliverables

- Admin navigation map
- MVP screen list
- Admin workflow specification
- Dashboard-to-backend integration plan

### Exit Criteria

- Admin MVP scope approved
- Product and category management flows validated
- Dashboard acceptance criteria signed off

## Phase 5: Mobile App MVP

### Goal

Deliver the first customer-facing mobile commerce experience.

### Scope

- Define Flutter application architecture and state management direction
- Implement authentication, home, category listing, product detail, and cart foundation planning
- Define mobile navigation, session flow, and API consumption model
- Map push notification entry points and app lifecycle considerations

### Deliverables

- Mobile information architecture
- MVP screen map
- API consumption plan
- Push notification integration plan

### Exit Criteria

- Mobile MVP scope approved
- Customer journey coverage confirmed
- Integration boundaries with Supabase documented

## Phase 6: Orders and Checkout

### Goal

Add transactional commerce capabilities to the platform.

### Scope

- Define cart-to-checkout workflow
- Define order placement, order item snapshots, payment state, and order status model
- Plan payment provider integration boundaries
- Define customer order history and admin order visibility
- Define confirmation and status notification flows

### Deliverables

- Checkout workflow specification
- Order lifecycle model
- Payment orchestration plan
- Notification trigger matrix

### Exit Criteria

- Order and checkout contracts approved
- Payment integration approach agreed
- Operational status model finalized

## Phase 7: Testing

### Goal

Formalize automated quality gates for the stack.

### Scope

- Plan Playwright coverage for the Next.js admin dashboard
- Plan Postman collections and Newman execution for API regression
- Plan Flutter unit, widget, and integration tests
- Define smoke, regression, and release gates
- Define staging validation checklists

### Deliverables

- Cross-platform test plan
- Tool ownership and execution model
- CI quality gate definition
- Release validation checklist

### Exit Criteria

- Test strategy mapped to delivery phases
- MVP quality gates approved
- Regression scope defined

## Phase 8: APK and Deployment

### Goal

Prepare the platform for distributable builds and controlled releases.

### Scope

- Define Android APK or App Bundle release process
- Define Next.js deployment target and environment promotion model
- Finalize Supabase environment and secret rollout process
- Define notification credentials management for Firebase Cloud Messaging
- Define rollback, monitoring, and post-release verification expectations

### Deliverables

- Release pipeline plan
- Deployment checklist
- Secrets and environment matrix
- Production readiness checklist

### Exit Criteria

- Release process approved
- Deployment dependencies identified
- Production go-live criteria documented

## Cross-Phase Dependencies

- Phase 2 depends on Phase 1 schema and user model decisions
- Phase 3 depends on Phase 1 data model and Phase 2 access rules
- Phase 4 depends on Phase 2 auth and Phase 3 catalog contracts
- Phase 5 depends on Phase 2 auth and Phase 3 catalog contracts
- Phase 6 depends on Phases 3, 4, and 5 for product and cart readiness
- Phase 7 spans all prior phases and should begin with the first implementation work
- Phase 8 depends on stable outcomes from Phases 4 through 7

## Suggested Execution Order

1. Complete Phase 1 and Phase 2 before any UI implementation begins.
2. Start Phase 3 immediately after auth and policy design stabilizes.
3. Build Phase 4 before Phase 5 so internal teams can manage catalog data early.
4. Deliver Phase 5 after admin workflows can support real product content.
5. Add Phase 6 once browsing and cart foundations are stable.
6. Run Phase 7 continuously, not only at the end.
7. Prepare Phase 8 before final MVP release.

## Planning Notes

- Supabase significantly reduces custom backend infrastructure needs, but schema design, RLS, and integration discipline remain critical.
- The `backend/` folder should be retained even with Supabase because it will hold migrations, edge functions, policies, integration adapters, and backend operational assets.
- AI commerce features should be introduced after the core MVP is stable unless there is a specific high-priority business requirement to pull them earlier.
