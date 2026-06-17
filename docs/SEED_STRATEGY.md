# Seed Strategy

## Purpose

This document defines the approved seed data strategy for the AI Commerce Platform. It establishes how foundational, test, and non-production reference data should be created, replayed, and validated during implementation.

## 1. Seed Objectives

- provide deterministic baseline data for development and testing
- support repeatable database reset and replay workflows
- bootstrap the minimum access-control and catalog data needed for Phase 1 and early MVP development
- prevent environment drift caused by manual data setup
- ensure non-production environments can be validated consistently
- avoid unsafe or unrealistic production seeding practices

## 2. Foundational Seeds

Foundational seeds must be created first because other application and test data depends on them.

### Roles

Seed the approved role set:

- `Super Admin`
- `Admin`
- `Viewer`
- `Customer`
- `Vendor`

Rules:

- role names must remain stable and consistent with approved documentation
- role seed values must be deterministic
- production use of roles must align with RBAC and RLS implementation

### Permissions

Seed permissions aligned with the approved permission matrix, including at minimum:

- product permissions
- category permissions
- order permissions
- user permissions
- vendor permissions
- review permissions
- coupon permissions
- report permissions
- audit log read permission where approved

Rules:

- permission codes should be stable and version-safe
- permission naming should follow the approved `<resource>.<action>` convention
- permissions must not depend on environment-specific random generation

### Role Permissions

Seed role-to-permission mappings for the approved roles.

Rules:

- `Super Admin` receives the full approved permission set
- `Admin` receives the approved operational subset
- `Viewer` receives read-only internal visibility permissions only
- `Customer` remains minimal and should not receive internal management permissions
- `Vendor` remains future-safe and limited until vendor workflows are implemented

## 3. Super Admin Bootstrap Strategy

The initial `Super Admin` account must be bootstrapped through a controlled process.

Rules:

- do not hardcode production credentials in the repository
- bootstrap identity values must come from secure environment-managed inputs or a controlled setup workflow
- bootstrap must be auditable
- public registration must never create a `Super Admin`
- recovery from loss of the initial `Super Admin` must require direct platform-owner or database intervention through an approved recovery process

Recommended strategy:

- seed roles and permissions normally
- create the first `Super Admin` only through a secure bootstrap step that references environment-controlled identity values
- separate bootstrap identity setup from general sample seed execution

## 4. Customer Test Accounts

Customer test accounts may be seeded for non-production environments only.

Rules:

- customer test accounts must be deterministic
- account purpose and identity should be obvious, such as verified and unverified test users
- test accounts should support auth, cart, review, and order-flow validation
- test accounts must not contain real personal data
- production must not receive sample customer accounts

Recommended account coverage:

- active verified customer
- active unverified customer
- suspended customer for access-control testing if needed

## 5. Admin Test Accounts

Admin test accounts may be seeded for non-production environments only when needed for access and workflow validation.

Rules:

- test internal accounts must be deterministic
- include at least one account for `Admin` and one for `Viewer` if shared-environment validation requires it
- internal test accounts must be clearly marked as non-production fixtures
- internal test accounts must never be created through public registration paths
- production should use controlled onboarding, not sample admin identities

Recommended coverage:

- one `Admin` test account
- one `Viewer` test account
- optional recovery-safe `Super Admin` bootstrap only through controlled setup, not general sample data

## 6. Catalog Seed Strategy

Catalog seeds should provide enough breadth to validate browsing, admin management, inventory, and variant-aware workflows.

### Categories

Seed deterministic category structures that support:

- top-level categories
- nested categories where applicable
- active categories for public browsing
- inactive or archived cases only when needed for admin or RLS validation

### Products

Seed products that cover:

- active public products
- draft or inactive products for admin visibility testing
- products with and without variants
- media-ready products that align with future storage testing

### Variants

Seed product variants to validate:

- variant-aware cart and checkout behavior
- nullable `variant_id` backward compatibility
- products where `variant_id` must be selected because variants exist

### Inventory

Seed inventory records that support:

- in-stock scenarios
- low-stock scenarios
- inactive or unavailable inventory scenarios for operational validation

Rules for catalog seeding:

- all catalog seeds must be deterministic
- sample catalog data must be sufficient for RLS and API tests
- public-facing seed visibility must align with approved catalog status rules
- no production sample catalog data should be inserted automatically unless explicitly approved and operationally justified

## 7. Coupon Seed Strategy

Coupon seeds should cover the primary policy and validation scenarios required for testing.

Recommended seeded coupon cases:

- active valid coupon
- expired coupon
- inactive coupon
- coupon with usage limit behavior
- coupon with eligibility restriction behavior if modeled in the schema

Rules:

- coupon seeds must be deterministic
- coupon sample data should support checkout validation testing
- customers must still not read the raw `coupons` table directly
- production should not receive sample promotional data by default

## 8. Environment-Specific Seed Rules

### local

Purpose:

- support repeatable developer workflows and automated local validation

Rules:

- allow full deterministic sample seeds
- include foundational roles, permissions, internal test accounts, customer test accounts, sample catalog, sample coupons, and supporting data needed for local testing
- local seed replay should work through resettable workflows

### dev

Purpose:

- support shared integration and team testing

Rules:

- use controlled deterministic seeds only
- include only the data needed for shared integration workflows
- keep internal and customer test accounts clearly labeled
- allow catalog and coupon fixtures needed for API and UI testing

### staging

Purpose:

- support release-candidate validation in a production-like environment

Rules:

- use sanitized deterministic data only
- avoid excessive sample clutter
- include only the accounts and catalog coverage needed for release testing
- keep data sets stable enough for regression comparisons

### production

Purpose:

- support live business operations

Rules:

- no sample customer, admin, catalog, coupon, or test-order data
- foundational RBAC reference data may be inserted through approved operational setup
- `Super Admin` bootstrap must be controlled and auditable
- any production seed action must be intentional, minimal, documented, and non-demo in nature

## 9. Seed Replay Strategy

Seed replay must be deterministic and repeatable.

Rules:

- replay must produce the same intended data set each time in resettable environments
- seeds must be compatible with migration replay order
- seed execution should be automated as part of reset or setup workflows where appropriate
- replay should avoid duplicate logical records by using stable identifiers or safe idempotent patterns where needed
- failures in seed replay must be fixed in source artifacts, not worked around by manual edits

Expected behavior:

- local reset and replay should rebuild a known-good baseline
- dev refresh workflows should be controlled and documented
- staging replay should preserve release-validation consistency

### Seed Versioning

- seed data should evolve through version-controlled artifacts
- changes to foundational seed structures should be reviewed
- seed updates must remain compatible with migration history
- seed changes affecting tests should be documented

## 10. Test Data Strategy

Seed data must directly support automated testing.

Required characteristics:

- deterministic values
- predictable relationships
- coverage for positive and negative scenarios
- no real personal data
- compatibility with migration, RLS, API, auth, and UI tests

Recommended test data coverage:

- verified and unverified customer scenarios
- Viewer, Admin, and Super Admin access scenarios
- active and non-public catalog states
- variant and non-variant product cases
- in-stock and constrained inventory cases
- valid and invalid coupon scenarios

Testing rules:

- no feature should depend on manually created hidden test data
- test fixtures should remain stable across replay
- seed design should support smoke, critical-path, and regression suites

### Edge Case Coverage

Seed data should include:

- product with zero inventory
- product with soft delete state
- category with no products
- cart containing multiple variants
- order in each major status
- user with no addresses
- user with multiple addresses

## 11. Definition of Done

Seed strategy is complete only when:

- foundational seeds are defined
- role and permission relationships are clearly documented
- `Super Admin` bootstrap is defined securely
- non-production customer and admin test-account strategy is defined
- catalog and coupon seed coverage is defined
- environment-specific seed rules are documented
- replay expectations are documented
- seed strategy supports automated testing
- no production sample data is required by default

## Decision Summary

- seeds must be deterministic and replayable
- foundational RBAC data comes first
- `Super Admin` bootstrap must be secure and separate from casual sample seeding
- customer and admin test accounts are non-production only
- catalog, variant, inventory, and coupon seeds must support both feature work and automated tests
- production must not receive sample data by default
