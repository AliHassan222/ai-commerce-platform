# Constitution

## Purpose

This constitution defines the non-negotiable rules for work in this repository.

## Core Rules

### Documentation First

- implementation must follow approved documentation
- no feature should begin from assumption when a source-of-truth document exists

### Architecture First

- all implementation must follow the approved architecture
- direct deviations from architecture require explicit approval

### No Database Changes Without Migration

- every schema change must be introduced through a new migration
- historical approved migrations must not be edited retroactively

### No API Changes Without API Spec Update

- no endpoint, payload, response, or workflow change is allowed without updating `docs/API_SPEC.md`

### No RLS Changes Without RLS Plan Update

- no policy implementation or access-control change is allowed without alignment to `docs/RLS_PLAN.md`

### No Breaking Schema Changes Without Approval

- breaking changes to schema, ownership, identity, or workflow contracts require explicit approval before implementation

### No Secrets in Repository

- secrets, private keys, tokens, credentials, and service-role values must never be committed

### Every Feature Must Include Tests

- every implemented feature must include appropriate automated tests
- missing tests must be treated as incomplete work

### Every Task Must Summarize Changed Files

- every completed task must include a clear summary of changed files and what changed in them

### Follow Approved Architecture at All Times

- Supabase, Flutter, Next.js, RLS, Edge Functions, and the approved access model are the required implementation baseline
- do not replace or bypass approved platform decisions without approval

### No Direct Database Access For Sensitive Business Operations

- checkout
- order creation
- coupon redemption
- payment workflows
- notification dispatch

must execute through approved backend workflows
(Edge Functions or protected server-side actions)

and must not rely solely on direct client database writes.

### No Manual Production Changes

- production database changes must be applied through approved migrations only
- production configuration changes must be documented
- direct manual fixes in production must be audited and justified
- emergency production changes must be followed by repository updates to eliminate configuration drift

## Operational Rules

- checkout and order creation must use protected backend workflows
- admin high-risk operations must use protected backend workflows
- guest cart merge must not rely only on direct client-side logic
- ownership checks in RLS should standardize on helper-based profile resolution
- public reads must exclude soft-deleted catalog records

## Governance Rule

- when documents conflict, implementation must stop until the conflict is resolved and the source of truth is updated
