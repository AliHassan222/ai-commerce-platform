# Test Strategy

## Purpose

This document defines the quality strategy for the AI Commerce Platform before implementation begins.

## Quality Objectives

- Prevent regressions in core commerce flows
- Verify API contracts and business rules early
- Protect security-sensitive workflows
- Ensure AI-assisted features are safe, observable, and measurable
- Support confident and frequent releases
- Treat testing as a system-wide responsibility, not a frontend-only activity

## Completion Rule

No feature is considered complete unless its appropriate tests are added and passing.

Critical workflows must include:

- happy path coverage
- validation failure coverage
- authorization failure coverage
- edge case coverage

## Test Pyramid

### Unit Tests

Scope:

- Pure business rules
- Pricing calculations
- Promotion logic
- Validation utilities
- Authorization policies

Goal:

- Fast feedback
- High coverage of deterministic logic

### Integration Tests

Scope:

- Database repositories
- Cache interactions
- Event publishing/consumption
- External service adapters with mocks or sandboxes

Goal:

- Verify component collaboration and persistence correctness

### Database Tests

Scope:

- migrations
- constraints
- indexes
- RLS policies
- helper functions
- seed data

Goal:

- verify the database behaves as the approved source of truth for schema, ownership, constraints, and security

Current Phase 1 implementation baseline:

- executable SQL database tests live under `backend/supabase/tests/database/sql/`
- the Phase 1 database suite uses plain SQL assertion scripts rather than pgTAP
- scripts are expected to run against the local Supabase runtime after `supabase db reset`

### Contract Tests

Scope:

- API request/response schemas
- Inter-service contracts
- Webhook payload handling

Goal:

- Prevent consumer/provider drift across apps and services

### API and Edge Function Tests

Scope:

- auth
- cart
- checkout
- orders
- coupons
- admin workflows
- error responses

Goal:

- verify protected backend workflows, response contracts, and business logic outside the UI layer

### End-to-End Tests

Scope:

- Registration and login
- Product discovery
- Cart management
- Checkout and order confirmation
- Admin product management

Goal:

- Protect the highest-value production user journeys

### Admin Dashboard Tests

Scope:

- Playwright end-to-end coverage
- role-based access
- product management
- order status updates

Goal:

- protect the internal operational workflows that manage the platform

### Mobile App Tests

Scope:

- Flutter unit tests
- widget tests
- integration tests

Goal:

- validate customer-facing logic, UI behavior, and mobile integration flows

### Performance Tests

Scope:

- Catalog listing under load
- Search latency
- Checkout throughput
- Order placement concurrency
- AI endpoint response times and fallback behavior

Goal:

- Validate scalability assumptions before production traffic

### Security Tests

Scope:

- Authentication and authorization paths
- Input validation and injection resistance
- Rate limiting
- Secret exposure checks
- Dependency vulnerability scanning

Goal:

- Reduce exploitable weaknesses before release

Required coverage:

- ownership access
- RBAC
- forbidden access
- sensitive data protection

## AI Feature Test Strategy

AI capabilities require additional controls beyond traditional software tests.

Required coverage:

- Prompt and policy regression tests
- Response safety validation
- Hallucination-risk checks on catalog-grounded answers
- Fallback behavior when model providers fail or time out
- Cost and latency monitoring validation

## Recommended Test Repository Layout

```text
tests/
|-- contract/
|-- database/
|-- integration/
|-- e2e/
|-- performance/
`-- security/
```

## Entry Criteria for Implementation

Before coding begins, the team should agree on:

- critical user journeys to protect with end-to-end tests
- API contract ownership
- minimum coverage thresholds
- environment strategy for integration and staging tests
- release quality gates in CI/CD

## Release Quality Gates

Minimum recommended gates:

- All unit and integration tests pass
- Database tests pass for schema, helper functions, and RLS-sensitive changes
- Contract tests pass for changed APIs
- End-to-end smoke tests pass in staging
- Security scan results reviewed
- No unresolved critical defects
- Observability checks present for new features

## Regression Strategy

### Smoke Suite

- fast checks for environment health and core login, catalog, and order visibility flows

### Critical Path Suite

- checkout
- auth
- catalog management
- order status handling
- ownership and permission enforcement

### Release Regression Suite

- broader pre-release suite covering database behavior, APIs, admin flows, mobile flows, and security-sensitive scenarios

## Test Data Strategy

- Use seeded, deterministic data for integration and end-to-end scenarios
- Separate synthetic test data from production data completely
- Provide fixtures for catalog, pricing, and inventory edge cases
- Mask or avoid all real personal data in non-production environments
- Use the Phase 1 seed foundation for helper-function, RLS, ownership, permission, and admin-workflow validation
- Keep role, permission, category, and product seed artifacts replayable and version-controlled

## Non-Functional Coverage

The strategy must also validate:

- resilience and retry behavior
- idempotency of payment and order workflows
- concurrency behavior around inventory reservation
- graceful degradation of AI features
- auditability of admin actions

## Seed-Supported Coverage

Phase 1 seed data should explicitly support:

- helper function testing
- RLS testing
- ownership testing
- permission testing
- admin workflow testing

Required seeded personas and catalog states should include:

- active verified customer
- active unverified customer
- suspended customer
- Viewer
- Admin
- Super Admin
- active public products
- draft product
- soft-deleted product

Phase 1 executable database test coverage should include:

- helper functions
- anonymous public access
- customer ownership boundaries
- RBAC permission mappings
- seed validation
- auth profile auto-creation behavior

## Suggested Ownership Model

- Engineers own unit and integration coverage
- QA owns end-to-end quality design and release validation
- Architects and tech leads own contract integrity and non-functional standards
- Product and business stakeholders validate acceptance criteria and UAT

## Initial Risks to Watch

- inventory race conditions during checkout
- pricing inconsistencies across services
- permission leaks in admin endpoints
- brittle AI behavior without grounded retrieval
- insufficient test data realism for commerce edge cases
