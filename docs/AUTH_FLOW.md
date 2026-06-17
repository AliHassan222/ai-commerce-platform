# Auth Flow

## Purpose

This document defines the authentication lifecycle for the AI Commerce Platform using Supabase Auth.

## Actors

- Guest user
- Registered customer
- Internal admin user
- Future vendor user

## Auth Principles

- Supabase Auth is the identity provider
- `profiles` is the application-level user record
- Email-based authentication is the MVP default
- Role and access checks happen after identity is established
- Sensitive flows must be auditable

## Register

### Goal

Allow a new customer to create an account.

### Flow

1. Guest submits email, password, and optional profile data.
2. Supabase Auth creates the identity record.
3. Application creates or completes the `profiles` record linked to `auth.users.id`.
4. Default role is assigned as `Customer`.
5. User is marked `pending` until verification or activation rules are satisfied.
6. Verification email is sent.

### Profile Auto-Creation Trigger

Supabase should create the `profiles` record automatically after a new `auth.users` record is created.

Recommended implementation options:

- a database trigger on `auth.users`
- a secured server-side function invoked immediately after successful auth signup

Default values:

- default role: `Customer`
- default status: `pending` or `active` depending on the approved email verification policy

### Expected Controls

- email uniqueness
- password strength validation
- rate limiting
- bot and abuse protection

## Login

### Goal

Authenticate a customer or internal user securely.

### Flow

1. User submits email and password.
2. Supabase Auth validates credentials.
3. Session is issued with access token and refresh token.
4. Application loads the related `profiles` record.
5. Role and status checks determine the allowed application area.

### Expected Controls

- throttling for failed attempts
- blocked access for suspended or inactive profiles
- audit logging for sign-in events

## Forgot Password

### Goal

Allow a user to recover access safely.

### Flow

1. User submits their email address.
2. System sends password reset instructions through Supabase Auth.
3. User follows the reset link.
4. User sets a new password.
5. Existing sessions may be revoked based on security policy.

### Expected Controls

- do not reveal whether the email exists
- expire reset links
- audit password reset requests and completions

## Email Verification

### Goal

Confirm user ownership of the email address.

### Flow

1. Verification email is sent at registration or email-change events.
2. User clicks the verification link.
3. Supabase marks the email as verified.
4. Application updates the profile status if verification is part of activation.

### Business Rules

- customer accounts can be created before verification
- unverified customers can browse products before verification
- unverified customers cannot place orders until verification completes
- unverified customers cannot submit reviews until verification completes
- unverified customers cannot use coupons until verification completes
- internal admin and future vendor onboarding may require stricter verification and approval

## Guest Cart Merge

### Goal

Preserve guest shopping activity when a guest registers or logs in.

### Flow

1. Guest user authenticates through register or login.
2. System checks for an active guest cart.
3. System checks for an existing active authenticated cart for the profile.
4. If both carts exist, merge guest items into the authenticated cart.
5. If the same product or variant exists in both carts, increase quantity instead of duplicating the line.
6. Recalculate cart totals after merge.
7. Mark the guest cart as `converted` or `merged` based on final business status naming.
8. Audit the merge event for traceability.
9. Continue the session using the authenticated active cart.

### Merge Rules

- merge only active guest carts
- do not keep duplicate product or variant lines after merge
- preserve latest valid pricing through recalculation rather than trusting stale guest totals
- if no authenticated cart exists, convert the guest cart into the authenticated cart
- if inventory validation fails during merge, flag affected lines for user review

## Logout

### Goal

End the current authenticated session cleanly.

### Flow

1. User triggers logout from mobile or admin UI.
2. Current Supabase session is cleared.
3. Local application state and cached protected data are removed.
4. User returns to guest or login state.

### Expected Controls

- explicit logout on shared devices
- token cleanup on both admin and mobile clients

## Session Refresh

### Goal

Maintain secure long-lived sessions without repeated login prompts.

### Flow

1. Access token expires.
2. Client uses refresh token through Supabase session management.
3. New access token is issued if refresh token is valid.
4. Application reloads protected data as needed.

### Expected Controls

- handle expired or revoked refresh tokens gracefully
- force re-login when profile status changes to suspended or inactive
- audit unexpected token refresh failures for internal users

## Role-Aware Routing

### Customer

- access customer-facing mobile experiences
- restricted to own account, cart, orders, addresses, reviews, notifications, and wishlists
- product browsing is allowed before email verification
- order placement, review submission, and coupon usage require verified email

### Viewer

- access read-only internal dashboard views
- no create, update, delete, or moderation actions

### Admin

- access operational dashboard features
- allowed to manage approved business resources within assigned permissions

### Super Admin

- access all internal platform areas
- allowed to manage roles, permissions, and high-risk actions

### Vendor

- future-only role
- should be limited to vendor-owned catalog, inventory, orders, and reports

## Admin User Creation Rule

Internal users must not self-register through the public app.

Applies to:

- `Super Admin`
- `Admin`
- `Viewer`

Required rule:

- internal users must be created directly by a `Super Admin` or promoted to their internal role only by a `Super Admin` through the Admin Dashboard

Operational implication:

- public registration always creates a `Customer` account only
- role elevation from customer to internal user must be audited
- internal onboarding should use protected admin workflows rather than public auth entry points

## Failure and Edge Cases

- missing `profiles` record after successful auth should trigger controlled recovery or support workflow
- suspended users must be blocked even if authentication succeeds
- deleted or inactive internal users must lose dashboard access immediately
- guest cart merge behavior should be defined when a guest logs in

## Audit Recommendations

Log these auth events:

- registration started
- registration completed
- email verified
- login success
- login failure
- forgot password requested
- password reset completed
- logout
- suspicious session or token failures
