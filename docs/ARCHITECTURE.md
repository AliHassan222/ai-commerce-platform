# Architecture

## Purpose

This document describes the approved architecture for the AI Commerce Platform after technology selection.

## Approved Stack

- Mobile application: Flutter
- Admin dashboard: Next.js
- Backend platform: Supabase
- Database: Supabase PostgreSQL
- Authentication: Supabase Auth
- File storage: Supabase Storage
- Notifications: Firebase Cloud Messaging
- Testing: Playwright, Postman/Newman, Flutter tests

## Architectural Goals

- Support production-grade commerce workloads
- Enable AI-driven customer and admin experiences
- Maintain strong security, observability, and testability
- Reduce duplication across apps and services
- Preserve flexibility for future multi-tenant expansion
- Optimize for fast MVP delivery with managed backend infrastructure

## Recommended Monorepo Layout

```text
/
|-- apps/
|   |-- mobile-app/
|   `-- admin-dashboard/
|-- backend/
|   |-- supabase/
|   |-- integrations/
|   `-- policies/
|-- packages/
|   |-- shared-types/
|   |-- api-contracts/
|   |-- ui-tokens/
|   `-- tooling-config/
|-- infra/
|-- docs/
`-- tests/
```

## Structure Review

The requested starting structure of `/apps`, `/backend`, `/docs`, and `/tests` remains strong because it separates:

- user-facing applications
- backend platform assets and integrations
- documentation and architecture artifacts
- quality and validation assets

What it is missing for long-term production readiness:

- `packages/` for shared code and contracts
- `infra/` for deployment and environment automation
- `scripts/` for repeatable developer and CI workflows

Recommendation: keep the current four top-level folders and extend the monorepo with `packages/`, `infra/`, and `scripts/` before coding begins.

## Architecture Decision

The platform will use Supabase as the primary backend foundation instead of a custom service mesh for the initial product phases. This is the best fit for the approved stack because it accelerates delivery of:

- PostgreSQL-backed commerce data
- authentication and session management
- storage for media and platform assets
- row-level security for protected access
- edge functions and integration hooks where needed

This choice reduces infrastructure overhead in the MVP phase while keeping room for later extraction of specialized services if scale or business complexity demands it.

## Logical Architecture

### Presentation Layer

- Flutter mobile commerce application
- Next.js admin dashboard

### API Layer

- Supabase APIs for database-backed operations
- Supabase Edge Functions for controlled server-side workflows
- Admin and mobile client access through approved contracts
- Authentication enforcement through Supabase Auth and access policies

## API Access Strategy

The platform should use a hybrid access model that combines direct Supabase client access with protected Edge Function workflows.

### Direct Supabase Client Access

Use direct client access when:

- public catalog browsing requires read-only access to active, non-deleted catalog data
- customer own-data operations can be safely enforced through row-level security
- low-risk read operations do not require sensitive orchestration or privileged business logic

Examples:

- product browsing
- category browsing
- customer profile reads and limited self-updates
- customer address management
- customer wishlist reads and writes
- customer notification reads

### Edge Functions or Server-Side Protected Actions

Use Edge Functions or other protected server-side execution when:

- workflows require multi-step validation
- business logic spans multiple tables or state transitions
- operations involve elevated privileges or service-role credentials
- integrations call third-party providers or inbound webhooks

Required cases:

- checkout and order creation
- guest cart merge
- coupon validation and redemption
- admin high-risk operations
- payments
- shipping
- notifications dispatch
- webhooks

### Access Rules

- Public catalog browsing can use direct Supabase reads protected by RLS.
- Customer own-data operations can use direct Supabase access when RLS is sufficient.
- Checkout and order creation must use Edge Functions.
- Admin high-risk operations must use Edge Functions or server-side protected actions.
- Payments, shipping, notifications, and webhooks must use Edge Functions only.

### Backend Platform Layer

- Supabase PostgreSQL for transactional commerce data
- Supabase Auth for customer and admin identity
- Supabase Storage for product media and uploaded assets
- Row-level security policies for access control
- Edge Functions for privileged workflows and integrations
- Integration adapters for payment, shipping, and notification flows

### Data and Platform Layer

- Supabase PostgreSQL as the source of truth for transactional data
- Supabase Storage for images and documents
- Firebase Cloud Messaging for push notifications
- Optional search indexing layer if catalog scale requires it later
- External payment and shipping integrations at the platform boundary
- Observability stack for logs, metrics, and tracing

## AI Architecture Direction

AI capabilities should remain behind controlled backend workflows rather than being embedded directly in mobile or admin clients. During early phases, AI should be introduced through auditable backend paths that can own:

- recommendation orchestration
- product content enrichment
- shopping assistant interactions
- prompt/version management
- model usage telemetry and safeguards

Benefits:

- central governance for AI prompts, policies, and costs
- easier model replacement and experimentation
- consistent auditing and moderation controls

## Integration Patterns

- Supabase client access for allowed read and write operations
- Edge Functions for privileged workflows and business orchestration
- Webhooks for payment and shipping providers
- Firebase Cloud Messaging for push delivery events
- Shared contracts and schemas published from the monorepo

## Background Processing Strategy

Long-running tasks must not block user-facing requests.

The platform should use Edge Functions and event-driven workflows for asynchronous processing when an operation is slow, integration-heavy, or non-critical to the immediate response.

### Goals

- keep mobile and admin interactions responsive
- reduce request timeout risk
- isolate external provider latency from user-facing flows
- improve retry handling and operational observability

### Required Asynchronous Workloads

- notification dispatch
- email delivery
- AI content generation
- catalog enrichment

### Recommended Pattern

1. User or admin action completes the minimum required synchronous transaction.
2. System records the primary business result, such as order creation or product update.
3. A follow-up event, job record, or backend trigger initiates asynchronous processing.
4. Edge Functions perform the background task independently.
5. Status, retries, failures, and outcomes are logged for monitoring and audit visibility.

### Architectural Rules

- user-facing requests should return once the core transactional action is safely committed
- non-essential follow-up work should execute outside the request-response path
- retryable integration failures should be handled asynchronously
- background workflows should be idempotent where possible
- failures in async work should not corrupt the primary transaction outcome

### Examples

#### Notification Dispatch

- order status changes create a notification event
- Edge Functions deliver push or email notifications asynchronously
- delivery results are written back to notification records

#### Email Delivery

- registration, verification, and password reset emails are queued after the core auth action
- email provider latency should not block the originating user action

#### AI Content Generation

- AI-assisted copy generation should run outside admin save requests when generation is non-essential
- generated results should be reviewed before publishing where required by policy

#### Catalog Enrichment

- bulk enrichment and metadata enhancement should run as background jobs
- admin users should be able to see processing state rather than wait for completion

## Critical Data Flows

### Guest or Customer Browsing Products

1. User opens the mobile app or storefront experience.
2. Client requests product and category data through direct Supabase reads.
3. RLS exposes only active, non-deleted catalog records for public browsing.
4. Pagination, filtering, and search parameters are applied.
5. Product list and product detail data are rendered in the client.

### Customer Checkout and Order Creation

1. Customer reviews cart contents.
2. Client sends checkout request to a protected Edge Function.
3. Edge Function validates authentication, email verification state, cart ownership, pricing, coupon eligibility, and inventory availability.
4. Edge Function recalculates totals and creates the order transactionally.
5. Cart state is updated to converted or completed.
6. Order and order items are persisted.
7. Audit and notification events are emitted.
8. Client receives a standardized success or failure response.

### Admin Product Creation

1. Admin user authenticates and accesses the protected dashboard.
2. Client submits product creation request through a protected admin workflow.
3. Server-side logic or Edge Function validates role, permissions, payload structure, category references, and media references.
4. Product and related records are stored.
5. Audit logs are written.
6. Standardized response is returned to the dashboard.

### Admin Order Status Update

1. Admin opens order details in the dashboard.
2. Client submits a status change request through a protected admin endpoint or Edge Function.
3. Server-side logic validates role, permission, current order state, and allowed transition rules.
4. Order status is updated.
5. Audit log entry is created.
6. Notification workflow is triggered if needed.
7. Response returns updated order state.

### Notification Delivery

1. A business event occurs, such as order creation or status change.
2. Backend workflow or Edge Function creates the notification record.
3. Notification delivery logic resolves the channel, such as push through Firebase Cloud Messaging.
4. Delivery attempt result is stored.
5. User reads the notification later through authenticated direct access or in-app refresh.

## Error Handling Strategy

The platform should use a consistent error model across mobile, admin, Edge Functions, and backend integrations.

### Validation Errors

- triggered by invalid payloads, missing required fields, malformed filters, or invalid state input
- return clear business-safe error messages with field-level details when appropriate

### Auth Errors

- triggered by missing, expired, revoked, or invalid sessions
- must return unauthorized responses without exposing sensitive details

### Permission Errors

- triggered when an authenticated user lacks access to a requested resource or action
- must return forbidden responses and log privileged access failures

### Inventory Errors

- triggered when requested quantity exceeds available stock or inventory changes during checkout
- should return actionable messages that allow the client to refresh the cart or item state

### Payment Errors

- triggered by payment provider failures, authorization failures, or invalid payment state
- should be isolated to protected checkout workflows and logged with provider-safe metadata only

### Unexpected Errors

- triggered by unhandled exceptions, unavailable dependencies, or internal processing failures
- must return generic user-safe responses while preserving detailed internal logs

### Logging and Correlation IDs

- every request should carry or generate a correlation ID
- correlation IDs should flow through client requests, Edge Functions, audit events, and external integration logs
- validation, auth, permission, inventory, payment, and unexpected failures should all be logged with structured metadata

## Caching, Pagination, and Search Strategy

### Pagination

- product listings should use consistent pagination fields such as `page`, `pageSize`, `total`, and `totalPages`
- admin listings should also use pagination for products, orders, users, reviews, and vendors when introduced

### Filters

- category and product queries should support structured filters such as category, status, price range, and search text
- public filters must expose only allowed active data
- admin filters can support broader operational views based on permissions

### Search

- MVP should use basic PostgreSQL search capabilities for product and category retrieval
- simple keyword matching and indexed searchable fields are sufficient for MVP
- a future search indexing layer can be introduced when catalog size or relevance requirements exceed database search performance

### Caching

- cache public catalog and category reads cautiously where beneficial
- avoid caching sensitive customer-specific data such as carts, addresses, orders, tokens, and private notifications in shared layers
- any future caching layer should respect RLS and user isolation boundaries

## API Contract Standards

### Response Shape

All APIs should return a consistent success envelope.

Recommended shape:

```json
{
  "data": {},
  "meta": {
    "requestId": "uuid"
  }
}
```

### Error Shape

All APIs should return a consistent error envelope.

Recommended shape:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": []
  },
  "meta": {
    "requestId": "uuid"
  }
}
```

### Pagination Fields

Paginated responses should include:

- `page`
- `pageSize`
- `total`
- `totalPages`

### Naming Conventions

- use plural resource names for collections
- use lowercase snake_case or clearly standardized field naming at the storage layer
- use consistent JSON field naming across all clients and backend responses
- keep status values explicit and version-safe

### Versioning Plan

- external APIs should begin with `/api/v1`
- backward-compatible changes should remain within the same version
- breaking contract changes should trigger a new version only when necessary

Examples of candidate events:

- `user.registered`
- `product.updated`
- `cart.checked_out`
- `order.placed`
- `payment.captured`
- `shipment.dispatched`

## Security Architecture

- Supabase Auth as the centralized identity layer
- Role-based access control for internal users
- Row-level security on sensitive tables
- Secrets managed outside application code
- Encrypted transport and encrypted-at-rest storage
- Audit logs for privileged actions
- AI moderation and abuse protections
- Dependency and application scanning in CI/CD

## Deployment Strategy

Recommended deployment shape:

1. Deploy the Next.js admin dashboard independently.
2. Release the Flutter mobile application as Android APK or App Bundle first.
3. Manage database, auth, storage, and backend workflows through Supabase environments.
4. Integrate Firebase Cloud Messaging credentials per environment.

This approach minimizes operational complexity while staying aligned with the approved stack.

## Environment Strategy

- `local` for developer workflows
- `dev` for shared integration
- `staging` for production-like validation
- `production` for live traffic

Each environment should use the same schema migration and policy patterns with controlled configuration differences.

## Observability Requirements

- Structured logs with correlation IDs
- Metrics for latency, throughput, errors, and queue depth
- Monitoring for auth, database, storage, and edge-function workflows
- Business KPIs for conversion, cart abandonment, and recommendation usage

## Decision Summary

Best-fit architecture for this phase:

- Monorepo with app, backend, docs, and test workspaces
- Flutter for mobile and Next.js for admin
- Supabase for database, auth, storage, and backend workflows
- Firebase Cloud Messaging for notifications
- Playwright, Postman/Newman, and Flutter tests for quality gates
