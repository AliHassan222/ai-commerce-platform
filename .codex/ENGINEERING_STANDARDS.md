# Engineering Standards

## Purpose

This document defines implementation standards for all future work in this repository. It must be followed together with the approved project documents and constitution.

## Flutter Standards

- build the mobile app in `apps/mobile-app`
- keep presentation, state, domain, and data layers clearly separated
- use typed models matching approved API contracts
- centralize auth, session, and request handling
- avoid direct business-rule duplication in UI widgets
- gate protected flows such as checkout, reviews, and coupons based on verified email and backend responses
- write unit, widget, and integration tests for meaningful user flows

## Next.js Standards

- build the admin app in `apps/admin-dashboard`
- protect all internal routes with role-aware access checks
- keep admin-sensitive actions behind protected server-side workflows or Edge Function calls
- use consistent API clients and typed contracts
- avoid embedding authorization decisions only in the UI
- support operational auditability for high-risk actions

## Supabase Standards

- keep database changes migration-driven only
- use Supabase Auth as the single identity provider
- use `profiles` as the operational user record
- use RLS for ownership and row access
- use Edge Functions for privileged, multi-step, or integration-heavy workflows
- use service-role access only in trusted backend contexts
- use Supabase Storage only through approved bucket and path rules

## SQL Migration Standards

- every database change must use a new forward-only migration
- never edit historical approved migrations after they are established
- name migrations clearly and sequentially
- include constraints, indexes, and comments where they materially improve maintainability
- preserve backward compatibility where required by phased rollout decisions
- do not introduce breaking schema changes without approval

## RLS Standards

- deny by default
- prefer helper-function-based ownership checks such as `current_profile_id()`
- use permission helpers for RBAC-sensitive policy decisions
- keep public access limited to active, non-deleted catalog data and published reviews
- do not expose raw inventory, coupons, or audit logs to customers
- route checkout, guest cart merge, coupon validation, and notification dispatch through protected backend workflows
- never rely on UI restrictions alone for access control

## API Standards

- keep `docs/API_SPEC.md` as the contract source of truth
- use consistent response and error envelopes
- keep endpoint naming resource-oriented
- use `/api/v1` for current external APIs
- do not introduce undocumented endpoints
- do not change request or response contracts without updating the API spec first
- keep admin and customer routes clearly separated

## Testing Standards

- testing applies to the entire system, not only frontend
- every feature must include tests
- no feature is complete unless its tests are added and passing
- use Flutter tests for mobile behavior
- use Playwright for admin end-to-end coverage
- use Postman/Newman for API regression coverage
- add focused tests for auth, checkout, permissions, and state transitions
- add contract tests when changing API behavior
- do not treat manual testing as a substitute for automated regression coverage
- critical workflows must include:
  - happy path
  - validation failure
  - authorization failure
  - edge cases

### System-Wide Testing Layers

#### Database Tests

- migrations
- constraints
- indexes
- RLS policies
- helper functions
- seed data

#### API and Edge Function Tests

- auth
- cart
- checkout
- orders
- coupons
- admin workflows
- error responses

#### Admin Dashboard Tests

- Playwright end-to-end coverage
- role-based access
- product management
- order status updates

#### Mobile App Tests

- Flutter unit tests
- widget tests
- integration tests

#### Security Tests

- ownership access
- RBAC
- forbidden access
- sensitive data protection

#### Regression Tests

- smoke suite
- critical path suite
- release regression suite

## Error Handling Standards

- return standardized success and error envelopes
- use structured error codes
- keep messages safe for users and detailed logs internal
- include correlation IDs through request and workflow chains
- distinguish validation, auth, permission, inventory, payment, and unexpected failures
- ensure async workflow failures do not corrupt core transactions

## Security Standards

- no secrets in the repository
- use environment files and deployment secret managers only
- protect high-risk admin actions with RBAC and backend validation
- audit privileged actions and sensitive workflow transitions
- block unverified customers from order placement, coupon usage, and review submission
- do not cache sensitive private customer data in shared layers
- keep storage access aligned with bucket and object security rules

## Naming Conventions

- folders: lowercase kebab-case where appropriate
- database tables and columns: lowercase snake_case
- API resources: lowercase plural paths
- permission names: `<resource>.<action>`
- status values: explicit, stable, and documented
- migrations: sequential and descriptive

## Folder Structure Standards

- `apps/` for client applications
- `backend/supabase/` for migrations, policies, seed assets, and functions
- `docs/` for approved planning, architecture, API, auth, and security documents
- `tests/` for automated quality assets
- `packages/` for shared types, contracts, UI tokens, and tooling config
- `infra/` for environment and deployment automation
- `.codex/` for project memory, governance, and permanent implementation rules
