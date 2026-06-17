# Seed Validation Checklist

## Purpose

This checklist defines what must be verified after replaying the Phase 1 seed foundation.

## Roles

- `Super Admin` exists and is `active`
- `Admin` exists and is `active`
- `Viewer` exists and is `active`
- `Customer` exists and is `active`
- `Vendor` exists and is `inactive`

## Permissions

- all required user permissions exist
- all required product permissions exist
- all required order permissions exist
- all required review permissions exist
- all required category permissions exist
- `categories.restore` exists and is active

## Role Mappings

- `Super Admin` is mapped to all seeded permissions
- `Admin` is mapped to product, category, order, and review permissions as approved
- `Viewer` is mapped only to read-oriented permissions
- `Customer` has no internal permission mappings
- `Vendor` has no current permission mappings

## Personas

- documented active verified customer placeholder exists
- documented active unverified customer placeholder exists
- documented suspended customer placeholder exists
- documented Viewer placeholder exists
- documented Admin placeholder exists
- documented Super Admin placeholder exists
- no real passwords are stored
- no real `auth.users` records are created by seed SQL

## Categories

- `Electronics` exists
- `Mobiles` exists and is nested under `Electronics`
- `Laptops` exists and is nested under `Electronics`
- `Fashion` exists
- `Home & Kitchen` exists

## Products

- active product set exists
- at least one draft product exists
- at least one soft-deleted product exists
- soft-deleted product uses deterministic timestamp `2026-01-01 00:00:00+00`
- product slugs remain unique and stable

## Replay Safety

- seed replay does not create duplicate roles
- seed replay does not create duplicate permissions
- seed replay does not create duplicate role-permission mappings
- seed replay does not create duplicate categories
- seed replay does not create duplicate products

## Testing Readiness

- seed data is sufficient for helper-function testing
- seed data is sufficient for RLS testing
- seed data is sufficient for ownership testing
- seed data is sufficient for permission testing
- seed data is sufficient for admin workflow testing
