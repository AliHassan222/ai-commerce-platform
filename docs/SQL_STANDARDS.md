# SQL Standards

## 1. Purpose

This document defines the approved SQL standards for the AI Commerce Platform. It provides a consistent baseline for schema design, migrations, helper functions, RLS implementation, indexing, constraints, auditing, and performance before SQL development begins.

## 2. SQL Naming Conventions

### Tables

- use lowercase snake_case
- use plural nouns for entity tables
- use clear domain names that match approved architecture and schema documents
- avoid abbreviations unless they are already established and unambiguous

Examples:

- `profiles`
- `product_variants`
- `order_items`

### Columns

- use lowercase snake_case
- choose explicit, descriptive names
- primary keys should use `id`
- foreign keys should use `<referenced_table_singular>_id`
- timestamps should use consistent names such as `created_at`, `updated_at`, `deleted_at`, and `placed_at`
- boolean fields should read naturally, such as `is_primary` or `is_default_shipping`

Examples:

- `profile_id`
- `vendor_id`
- `currency_code`

### Indexes

- use prefix `idx_`
- use table name followed by indexed column or purpose
- use deterministic names for multi-column indexes

Examples:

- `idx_products_category_id`
- `idx_orders_status`
- `idx_cart_items_variant_id`

### Constraints

- use descriptive names with table context
- prefer suffixes that reflect constraint type
- check constraints should use `_check`
- unique constraints should use `_unique` or a similarly explicit business-safe naming pattern

Examples:

- `products_status_check`
- `inventory_reserved_not_exceed_on_hand_check`
- `cart_items_unique_product_per_cart`

### Foreign Keys

- use `<table>_<column>_fkey` when explicitly naming them
- keep foreign key names deterministic and aligned with PostgreSQL conventions

Examples:

- `products_vendor_id_fkey`
- `orders_profile_id_fkey`

### Functions

- use lowercase snake_case
- name functions after the question or action they represent
- helper functions should be concise, reusable, and semantically clear

Examples:

- `current_profile_id()`
- `has_permission(permission_code text)`
- `set_updated_at()`

### Triggers

- use descriptive names beginning with the purpose
- prefer patterns like `set_updated_at_<table>`

Examples:

- `set_updated_at_products`
- `set_updated_at_orders`

### Views

- use lowercase snake_case
- name views after the dataset or projection they expose
- if a view is internal-only or security-focused, make the purpose explicit in the name

Examples:

- `admin_order_summary`
- `public_catalog_products`

## 3. Migration Standards

- use forward-only migrations
- never modify approved historical migrations
- each migration should have one clear primary responsibility
- migration names should be sequential and descriptive
- schema changes must be traceable to approved documentation
- include indexes, constraints, and comments when they materially improve maintainability
- avoid bundling unrelated schema changes into a single migration
- use follow-up corrective migrations instead of rewriting history

Recommended migration discipline:

- schema foundation changes in one migration
- extension or feature-area additions in a later migration
- corrections or compatibility adjustments in dedicated follow-up migrations

## 4. Function Standards

### Helper Functions

- helper functions should be designed for reuse across RLS and approved workflows
- keep helpers focused on one responsibility
- avoid embedding broad business orchestration in low-level helpers
- helper names should align with approved helper-function design documents

### Security Definer Guidance

- use `SECURITY DEFINER` only when there is a clear and approved need
- prefer least-privilege behavior even for elevated functions
- review all `SECURITY DEFINER` usage carefully because it can bypass normal caller restrictions
- document why elevated execution is required before implementation

### Stable vs Volatile Guidance

- use the most restrictive correct volatility classification
- prefer `STABLE` for lookup-style helpers when appropriate
- use `VOLATILE` only when function behavior truly depends on changing state or side effects
- avoid careless volatility declarations because they affect planner behavior and policy performance

## Trigger Function Standards

- keep trigger functions focused on a single responsibility
- avoid business workflow orchestration inside triggers
- prefer explicit backend workflows for complex operations
- trigger functions should be idempotent where possible
- document all non-obvious trigger behavior

## 5. RLS Standards

- deny by default
- enable access only where explicitly approved
- use helper functions to centralize identity, ownership, and permission logic
- avoid duplicated logic across policies
- standardize on `current_profile_id()` for ownership resolution
- use permission helpers such as `has_permission()` for internal elevated access
- keep policies fail-closed when helper resolution fails
- keep high-risk multi-step workflows outside direct client-side table writes
- align all policy behavior with the approved RLS design documents before implementation

## 6. Index Standards

- add indexes for foreign keys and commonly filtered columns
- add indexes for columns used in ownership, status, lookup, and ordering queries
- use composite indexes when query patterns justify them
- avoid speculative indexing without a clear access pattern
- review index usefulness as schema and query behavior evolve
- ensure index names remain deterministic and descriptive

Typical index targets:

- foreign key columns
- status columns
- lookup identifiers such as `slug`, `sku`, or `order_number`
- time-based query fields such as `created_at` or `placed_at`

## 7. Constraint Standards

- use constraints to protect business-critical invariants at the database layer
- prefer explicit `CHECK`, `UNIQUE`, `NOT NULL`, and foreign key constraints where appropriate
- ensure constraints are readable and named clearly
- keep constraint rules aligned with approved schema and API behavior
- use nullable compatibility only when intentionally required by approved rollout decisions

Examples of constraint use:

- non-negative numeric values
- valid enumerated status values
- uniqueness of business identifiers
- foreign key integrity

## 8. Audit Standards

- privileged or sensitive actions must be auditable
- audit-relevant schema and workflow changes should align with `audit_logs` design
- audit data should be append-oriented and resistant to casual mutation
- direct client writes to audit logs must not be allowed
- internal role changes, support-sensitive access, order-state changes, and high-risk operational actions should be logged through approved workflows

## 9. Documentation Standards

- add comments to complex functions
- add comments to non-obvious constraints
- add comments to business-critical columns
- document security-sensitive helper functions
- avoid redundant comments that repeat the code

## 10. Performance Guidelines

- design schema and helpers with common query paths in mind
- keep frequently used helper functions lightweight
- avoid unnecessary joins in RLS helper logic
- use indexes to support common ownership, status, and lookup filters
- avoid redundant constraints or indexes that add write overhead without practical value
- prefer clarity first, then optimize based on known access patterns and approved workload expectations
- review policy and helper performance carefully because RLS runs on protected access paths

## 11. Definition of Done

SQL standards are complete only when:

- naming conventions are defined
- migration standards are defined
- function standards are defined
- RLS standards are defined
- index standards are defined
- constraint standards are defined
- audit standards are defined
- performance guidance is defined
- the standards remain aligned with approved architecture, auth, schema, and RLS strategy

## Decision Summary

- SQL must remain migration-driven, forward-only, and traceable
- names should be explicit, deterministic, and snake_case-based
- helper functions should be reusable and security-conscious
- RLS logic should be centralized through approved helper patterns
- indexes and constraints should support correctness first and performance second
- auditing and performance must be considered from the start, not added later
