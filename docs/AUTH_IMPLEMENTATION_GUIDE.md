# Auth Implementation Guide

## Purpose

This document defines the implementation strategy for Supabase Auth in Phase 1. It translates the approved authentication, authorization, and governance decisions into an implementation-ready plan without introducing code.

Implementation status:

- automatic `auth.users` to `public.profiles` creation is implemented in `backend/supabase/migrations/008_auth_profile_auto_creation.sql`
- default public-registration role assignment is implemented as `Customer`
- default public-registration profile status is implemented as `pending`
- normal self-service profile updates are now prevented from changing `profiles.email`

## 1. Authentication Overview

### Identity Provider

- Supabase Auth is the approved identity provider
- Supabase Auth owns authentication credentials, sessions, and email verification state
- application authorization must happen after identity is established

### Profile Model

- `profiles` is the application-level user record
- the intended MVP identity mapping is `profiles.id = auth.users.id`
- `profiles` stores operational user fields such as role, status, and customer profile data
- profile ownership and access enforcement must align with the approved RLS strategy

### Role Model

- role assignment is modeled through `roles`, `permissions`, and `role_permissions`
- effective user role is linked through `profiles.role_id`
- approved roles are:
  - `Super Admin`
  - `Admin`
  - `Viewer`
  - `Customer`
  - `Vendor` as future scope
- public registration creates `Customer` accounts only

### User Lifecycle

Approved high-level lifecycle:

1. user registers through Supabase Auth
2. identity record is created in `auth.users`
3. `profiles` record is created automatically
4. default role and status are assigned
5. email verification occurs according to policy
6. user logs in and receives session tokens
7. application loads profile and role context
8. access is allowed or denied based on role, status, and verification state

## 2. Registration Flow

### Customer Registration

- public registration is available for customers only
- user submits email, password, and optional profile fields
- Supabase Auth creates the identity record
- the platform creates the matching `profiles` row
- default role is assigned as `Customer`
- default status is assigned as `pending` or `active` based on final email verification policy
- verification email is sent

### Email Verification

- registration should trigger the standard Supabase verification email flow
- verified state must come from trusted auth data, not client input
- verification status influences whether restricted customer actions are allowed

### Profile Creation

- profile creation must happen automatically after `auth.users` creation
- profile creation must not rely on the client performing a second trusted write
- if profile creation fails, registration handling must surface a controlled recovery path

Current SQL implementation:

- an `AFTER INSERT` trigger on `auth.users` executes a secured database function
- the function creates or repairs the matching `public.profiles` row using `profiles.id = auth.users.id`
- the function copies trusted `auth.users.email` into `profiles.email`
- the function assigns the active `Customer` role and `pending` status

### Default Role Assignment

- default role for public registration is always `Customer`
- no public path may assign `Admin`, `Viewer`, `Super Admin`, or `Vendor`

### Default Status Assignment

- default status should be `pending` when email verification gates activation
- default status may be `active` only if the approved verification policy allows it
- restricted actions must still be blocked until verified email state is confirmed

Current SQL implementation:

- default status is implemented as `pending`

### Registration Sequence Flow

1. guest user submits registration form
2. client calls Supabase Auth signup
3. Supabase creates `auth.users` identity
4. profile auto-creation workflow creates `profiles` row
5. default `Customer` role is assigned
6. default status is assigned
7. verification email is issued
8. audit event is recorded
9. user continues into verification-pending or active-auth state depending on policy

## 3. Login Flow

### Authentication

- user submits email and password
- Supabase Auth validates credentials
- on success, Supabase issues access and refresh tokens

### Profile Loading

- application loads the related `profiles` record after authentication
- profile must be loaded before protected areas are made available
- missing profile records must trigger controlled failure handling

### Role Loading

- role context is derived from `profiles.role_id`
- permission-aware workflows may resolve effective access through the RBAC tables

### Access Validation

- application validates:
  - profile exists
  - profile status is allowed
  - role is allowed for the requested area
  - email verification is sufficient for the attempted action
- customer and admin routing must diverge after role evaluation

### Login Sequence Flow

1. user submits login form
2. client calls Supabase Auth sign-in
3. Supabase validates credentials
4. Supabase returns session tokens
5. application loads `profiles` record
6. application resolves role and status
7. application checks verification and access rules
8. user is routed to the correct experience or blocked with a controlled error
9. audit event is recorded

## 4. Profile Auto-Creation Strategy

### Target Tables

- source identity table: `auth.users`
- application profile table: `public.profiles`

### Preferred Implementation Approach

Preferred strategy:

- use a database trigger or secured database-side automation to create `profiles` immediately after `auth.users` creation

Alternative strategy:

- use a secured server-side creation workflow only if the database-trigger approach cannot safely satisfy platform constraints

### Why Trigger-Driven Creation Is Preferred

- it keeps identity-to-profile creation close to the source of truth
- it reduces the risk of partial signup states where `auth.users` exists but `profiles` does not
- it avoids trusting the client to complete a privileged application record
- it aligns with the approved requirement that profile creation be automatic

### Trigger Strategy Requirements

- create `profiles.id` from `auth.users.id`
- set default role to `Customer`
- set default status to `pending` or `active` based on approved policy
- copy approved safe fields such as email into `profiles`
- fail safely and observably if profile creation cannot complete

Current SQL implementation:

- the trigger function is conflict-safe through `ON CONFLICT (id)`
- the function raises a controlled error if the required active `Customer` role cannot be resolved

### Secure Server-Side Alternative Requirements

- must run in a trusted backend context only
- must not expose role or status assignment to the client
- must still guarantee strong consistency between `auth.users` and `profiles`

## 5. Email Verification Rules

### Verification Process

- Supabase sends verification email during registration or email-change workflows
- user verifies ownership through the Supabase-managed link
- verified state must be read from trusted auth state

### Restricted Actions Before Verification

Customers may browse products before verification, but must not:

- place orders
- use coupons
- submit reviews

### Order Placement Restrictions

- checkout and order creation must confirm verified email state before proceeding
- this must be enforced in protected backend workflows, not UI checks alone

### Coupon Restrictions

- coupon validation and redemption must require verified email state
- customers must not read the raw `coupons` table directly

### Review Restrictions

- review submission must require verified email state
- review access rules must still follow approved RLS and moderation rules

## 6. Internal User Strategy

### Roles Covered

- `Super Admin`
- `Admin`
- `Viewer`

### Registration Rules

- internal users must not self-register through the public app
- public registration always creates a `Customer` account only
- internal accounts must be created through approved protected admin workflows

### Creation Rules

- only `Super Admin` may create or promote internal users through the Admin Dashboard
- internal onboarding must be auditable
- internal identity creation must not rely on public signup paths

### Role Promotion Rules

- promotion from `Customer` to `Viewer`, `Admin`, or `Super Admin` must be performed only by `Super Admin`
- role changes must be logged
- role updates must align with the approved role and permission matrix

### Access Boundaries

- `Viewer` is read-only and intentionally limited
- `Admin` has operational permissions based on RBAC
- `Super Admin` has the highest authority and controls high-risk platform actions

## 7. Session Strategy

### Access Token

- access tokens are used for authenticated requests
- clients must treat them as short-lived session credentials
- protected API and database access must validate them on every request path

### Refresh Token

- refresh tokens maintain longer-lived sessions through Supabase session management
- refresh behavior must remain inside trusted session flows, not custom insecure client workarounds

### Logout Behavior

- logout must revoke or clear the active session through Supabase Auth
- clients must remove protected local state and cached sensitive data
- logout should return the user to a guest or login-ready state

### Session Expiration Handling

- clients should attempt normal session refresh through Supabase
- if refresh fails or session is revoked, clients must require re-authentication
- if profile status changes to suspended or inactive, access must be blocked even if the auth session still exists

### Multi Device Session Rules

- users may have multiple active sessions across trusted devices
- administrators may revoke active sessions when required
- password reset should invalidate existing sessions when security policy requires
- suspicious account activity may trigger forced re-authentication
- session behavior must remain consistent across mobile app and admin dashboard

## 8. Auth Security Controls

### Brute-Force Protection

- throttle repeated failed login attempts
- monitor repeated failures from the same account or source
- use provider and application controls where available

### Rate Limiting

- rate limit registration
- rate limit login attempts
- rate limit forgot-password requests
- rate limit verification resend or similar abuse-prone flows

### Password Policy

- require strong password standards at registration and reset time
- keep password rules documented and consistently enforced
- do not weaken production password policy for convenience

### Audit Logging

Audit these events at minimum:

- registration started
- registration completed
- email verified
- login success
- login failure
- forgot password requested
- password reset completed
- logout
- role promotion
- internal user creation
- suspicious auth events

### Suspicious Login Handling

- log abnormal repeated failures
- flag suspicious token or refresh behavior
- block suspended or inactive users from proceeding after auth success
- keep investigation and support actions auditable

### Account Lockout Strategy

- repeated failed login attempts should trigger temporary lockout or additional verification controls
- lockout duration should increase progressively for repeated abuse
- lockout events must be audited
- account recovery must go through controlled support or verified reset workflows
- lockout rules must not reveal whether an email exists in the system

## 9. Auth Testing Plan

### Registration Tests

- successful customer registration
- duplicate email rejection
- invalid password or validation rejection
- profile auto-creation success
- public registration cannot create internal roles

### Login Tests

- successful login for active customer
- invalid credentials rejection
- suspended or inactive profile blocked after auth
- missing profile record handled safely

### Email Verification Tests

- verification email flow completes successfully
- unverified customer can browse
- unverified customer cannot place orders
- unverified customer cannot redeem coupons
- unverified customer cannot submit reviews

### Role Tests

- customer role is assigned by default
- internal users cannot self-register
- only `Super Admin` can promote internal users
- Viewer, Admin, and Super Admin routing behaves as expected

### Session Tests

- access token usage on protected requests
- refresh token session renewal
- logout clears session access
- expired or revoked session forces re-login

### Authorization Tests

- role-aware access gating for admin and customer areas
- RBAC checks for internal users
- restricted workflows fail safely when verification or status is insufficient

## 10. Definition of Done

Authentication is complete only when:

- registration works
- profile creation works
- email verification works
- default role assignment works
- default status assignment works
- internal user restrictions work
- role promotion rules work
- session handling works
- auth tests pass

## Risks and Implementation Notes

- profile auto-creation failure could leave orphaned auth identities if not handled carefully
- identity mapping must remain consistent with `profiles.id = auth.users.id`
- role escalation risk exists if internal-user creation is not tightly controlled
- verification-gated actions must be enforced in backend workflows, not just client UI
- missing audit coverage would weaken traceability for sensitive auth events
- session handling must account for suspended or inactive profiles after successful authentication
- `profiles.email` must remain controlled by trusted auth or backend flows, not ordinary self-service profile updates

## Decision Summary

- Supabase Auth remains the sole identity provider
- `profiles` is the operational user record and should be created automatically from `auth.users`
- public registration creates `Customer` only
- internal users are created or promoted only by `Super Admin` through approved workflows
- unverified customers may browse but cannot order, use coupons, or submit reviews
- auth is not complete until registration, verification, role assignment, restrictions, and session behavior are all tested
