# Supabase Local Setup

## Purpose

This document defines the local Supabase setup workflow for Phase 1 foundation work.

## Prerequisites

- Supabase CLI installed locally
- Docker Desktop or another supported local container runtime installed and running
- access to this repository
- a terminal with permission to run local Supabase commands

## Supabase CLI Installation

Install the Supabase CLI using an official supported method for your operating system.

After installation, verify it is available:

```bash
supabase --version
```

If the command is not recognized, finish CLI installation before continuing.

## Project Initialization Steps

The repository already uses the approved Supabase workspace:

```text
backend/supabase/
|-- config.toml
|-- migrations/
|-- seed/
|-- functions/
|-- policies/
`-- tests/
```

Initialization steps:

1. Open the repository root.
2. Confirm Docker is running.
3. Move into the Supabase workspace:

```bash
cd backend/supabase
```

4. Confirm the local config file exists:

```bash
ls config.toml
```

5. Start the local Supabase stack:

```bash
supabase start
```

## Local Startup Commands

Start the local stack:

```bash
cd backend/supabase
supabase start
```

Check status:

```bash
supabase status
```

Stop the local stack when needed:

```bash
supabase stop
```

## Local Reset Commands

Replay the local database from migrations:

```bash
cd backend/supabase
supabase db reset
```

This should:

- recreate the local database state
- re-run the approved migration chain
- prepare the database for repeatable validation

## Migration Workflow

Approved current migration order:

1. `001_initial_core_ecommerce_schema.sql`
2. `002_ecommerce_extensions.sql`
3. `003_add_variant_references_to_cart_and_order_items.sql`

Recommended local workflow:

1. Add new forward-only migrations under `backend/supabase/migrations/`.
2. Use local reset to replay the full chain:

```bash
supabase db reset
```

3. Validate schema objects, indexes, and constraints after replay.
4. Do not edit approved historical migrations retroactively.

## Seed Workflow

Phase 1 seed data will live under:

```text
backend/supabase/seed/
```

Recommended local seed workflow:

1. add deterministic seed assets under `seed/`
2. run local reset and seed replay together through the local Supabase workflow
3. validate roles, permissions, categories, products, and coupons after loading

Seed work is separate from P1-T01 and should be implemented during the approved seed tasks.

## Troubleshooting

### Supabase CLI Not Found

Cause:

- CLI is not installed or not on the system path

Resolution:

- install the Supabase CLI
- restart the terminal
- run `supabase --version` again

### Docker Not Running

Cause:

- local Supabase services require containers

Resolution:

- start Docker Desktop or the supported local runtime
- retry `supabase start`

### Local Stack Fails To Start

Cause:

- port conflicts, Docker issues, or corrupted local state

Resolution:

- check port availability
- restart Docker
- run `supabase stop`
- retry `supabase start`

### Migration Replay Fails

Cause:

- migration dependency issue or invalid SQL

Resolution:

- inspect the failing migration
- verify migration order
- fix the new forward migration instead of editing approved historical migrations
- rerun `supabase db reset`

### Config Drift

Cause:

- local configuration differs from approved repository structure

Resolution:

- confirm `backend/supabase/config.toml` exists
- confirm required directories exist:
  - `migrations/`
  - `seed/`
  - `functions/`
  - `policies/`
  - `tests/`

## Validation Notes

- P1-T01 initializes the local project structure and documentation only
- no business logic is implemented here
- no RLS policies are created here
- no Edge Functions are created here
- existing migrations are not modified here
