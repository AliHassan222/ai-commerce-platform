# Environment Strategy

## Purpose

This document defines the approved environment strategy for the AI Commerce Platform across local, development, staging, and production. It aligns Supabase, authentication, storage, testing, and deployment expectations before implementation begins.

## Environment Principles

- each environment must have a clear purpose and isolation boundary
- Supabase projects should map cleanly to environment stages
- secrets must remain outside source control
- schema changes must move through approved migrations only
- environment promotion must follow validation and approval gates
- production must remain the most restricted environment

## 1. Local Environment

### Purpose

- support individual developer workflows
- enable schema, helper-function, RLS, seed, and storage experimentation
- provide a disposable environment for repeatable resets

### Database Strategy

- use local Supabase containers and local PostgreSQL services managed by the Supabase CLI
- replay the approved migration chain through `supabase db reset`
- use deterministic local seed data only
- treat local data as disposable and non-authoritative

### Auth Configuration

- enable the same MVP auth mode planned for shared environments
- support email/password auth for local testing
- allow controlled local verification testing without weakening production policies
- validate profile auto-creation behavior locally before promotion

### Storage Configuration

- use a local `product-images` bucket equivalent
- validate public-read and admin-upload expectations safely in local development
- do not use real production assets

### Secrets Management

- use local-only environment files and developer machine configuration
- never commit local secrets, service-role keys, or tokens
- rotate any accidentally exposed local secrets immediately

### Deployment Expectations

- no formal deployment process required
- developers may reset and replay the environment freely
- local setup must remain reproducible from repository documentation

### Testing Expectations

- migration replay testing
- helper-function testing
- RLS policy testing
- seed data validation
- storage access checks

### Allowed Users

- repository developers
- platform engineers
- architects validating implementation behavior

## 2. Development Environment

### Purpose

- provide the first shared integration environment
- validate backend behavior shared across developers, admin, and mobile implementation
- verify migration, seed, auth, and policy behavior in a persistent shared context

### Database Strategy

- use a dedicated shared Supabase project for `dev`
- apply only approved forward migrations
- keep test and sample data controlled and auditable
- avoid ad hoc manual schema changes

### Auth Configuration

- enable MVP customer auth behavior
- validate internal-user restrictions and customer-only public registration
- use non-production email, recovery, and onboarding settings appropriate for shared testing

### Storage Configuration

- create the shared `product-images` bucket
- validate admin upload workflows and approved public-read behavior
- use non-production media assets only

### Secrets Management

- store secrets in the platform’s secure secret manager or environment configuration
- restrict service-role and admin credentials to authorized team members
- never mirror dev secrets into public docs or committed files

### Deployment Expectations

- frequent deployment allowed
- all changes must still come through reviewed migrations, documented setup, and approved workflows
- dev may be refreshed when necessary, but changes should remain traceable

### Testing Expectations

- integration testing
- API and Edge Function testing when later tasks introduce them
- shared RLS validation
- smoke testing after migration or auth changes

### Allowed Users

- developers
- QA
- architects and tech leads
- limited internal stakeholders if explicitly approved

## 3. Staging Environment

### Purpose

- provide production-like release validation
- confirm schema, RLS, seed, storage, and auth behavior before production rollout
- act as the primary pre-release verification target

### Database Strategy

- use a dedicated Supabase project for `staging`
- mirror production schema and migration order closely
- use release-candidate data only
- avoid experimental schema or manual fixes that bypass migrations

### Auth Configuration

- mirror production auth rules as closely as practical
- validate email verification gating, internal user restrictions, and session behavior
- ensure customer and admin access boundaries match production intent

### Storage Configuration

- configure `product-images` with production-like rules
- validate object access, upload controls, and path conventions
- use sanitized non-production media assets

### Secrets Management

- use staging-specific secrets separate from production
- tightly limit access to service-role keys and privileged credentials
- maintain documented rotation and access ownership

### Deployment Expectations

- deploy only tested and review-approved changes
- require migration validation before release candidate promotion
- avoid untracked environment drift

### Testing Expectations

- regression suite execution
- critical-path testing
- security validation
- release smoke testing

### Allowed Users

- developers needing release validation
- QA
- release managers
- limited product and business reviewers if approved

## 4. Production Environment

### Purpose

- run live customer and internal business operations
- serve as the authoritative environment for real platform data
- prioritize security, stability, auditability, and controlled change management

### Database Strategy

- use a dedicated production Supabase project only
- allow schema changes only through approved, reviewed migrations
- prohibit manual schema edits outside emergency procedures and governance approval
- require backups, auditability, and rollback planning before high-risk releases

### Auth Configuration

- enforce final MVP auth rules
- enable customer email verification policy as approved
- prohibit public self-registration for internal roles
- require strict admin and Super Admin onboarding controls

### Storage Configuration

- use production `product-images` bucket with locked-down write rules
- expose only approved public assets
- ensure object lifecycle and cleanup are auditable

### Secrets Management

- manage secrets only through secure production secret stores
- restrict access to a minimal set of authorized operators
- rotate production secrets under formal operational control
- never place production secrets in source control, shared documents, or local machines unless explicitly required and approved

### Deployment Expectations

- use deliberate, auditable release processes
- require approved migrations, validation evidence, and rollback preparation
- minimize direct production access
- all production interventions must be traceable

### Testing Expectations

- no exploratory or destructive testing in production
- production validation is limited to safe smoke checks and operational health verification
- release confidence must come from local, dev, and staging validation first

### Allowed Users

- authorized production operators
- authorized backend or platform engineers
- tightly limited admin users with approved business need
- no unrestricted developer access by default

## Environment Promotion Flow

Approved promotion path:

- `local -> dev -> staging -> production`

Promotion expectations:

- local proves correctness of migrations, seeds, helpers, and policy logic
- dev proves shared integration readiness
- staging proves release readiness under production-like conditions
- production receives only approved, validated changes

Promotion rules:

- do not skip environment stages for normal releases
- do not promote undocumented schema or access-control changes
- promotion evidence should include test results and validation notes for the changed scope

## Environment Variables Strategy

### Public Variables

Public variables are safe for client exposure and may include:

- public Supabase URL
- public anon key
- non-sensitive feature flags intended for clients

Rules:

- public variables must still be environment-specific
- public does not mean uncontrolled; values should still be documented and managed carefully

### Private Variables

Private variables are server-only configuration values such as:

- internal API URLs
- service configuration not intended for clients
- operational toggles for backend workflows

Rules:

- private variables must not be embedded in client bundles
- access should be limited to trusted server-side workflows

### Secret Variables

Secret variables include:

- Supabase service-role keys
- database admin credentials
- JWT secrets or signing-related configuration
- third-party provider credentials

Rules:

- secrets must never be committed
- secrets must be stored in secure environment management systems only
- secrets must be rotated if exposure is suspected
- local development must use separate non-production secrets

## Supabase Environment Mapping

Recommended mapping:

- `local` -> developer-local Supabase instance managed through CLI and containers
- `dev` -> shared Supabase development project
- `staging` -> dedicated Supabase staging project
- `production` -> dedicated Supabase production project

Mapping rules:

- each shared environment should use a separate Supabase project
- do not reuse production projects for staging or dev validation
- auth, storage, database, and Edge Function configuration should stay aligned per environment
- environment naming should be consistent across repository docs, Supabase dashboards, and deployment pipelines

## Safety Rules

- no testing in production beyond safe smoke or health verification
- no production secrets in source control
- no direct schema changes outside migrations
- production access must be restricted to approved operators only
- no ad hoc policy bypasses for auth, RLS, or storage security
- no environment should contain undocumented configuration drift

## Definition of Ready

An environment is ready for use only when:

- its purpose and ownership are clearly defined
- required secrets are provisioned securely
- Supabase project mapping is established
- auth configuration matches the approved phase requirements
- storage configuration matches approved access rules
- migration workflow is available and documented
- validation or testing expectations are agreed for that environment
- allowed users and access restrictions are defined

## Decision Summary

- `local` is disposable and focused on repeatable implementation validation
- `dev` is the first shared integration environment
- `staging` is production-like and release-focused
- `production` is tightly restricted and change-controlled
- each shared environment should map to its own Supabase project
- secrets must stay out of source control in every environment
- promotion must follow `local -> dev -> staging -> production`
