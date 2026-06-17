-- Phase 1 documented seed personas only.
-- This file intentionally does not create auth.users records or real passwords.
-- Use these examples as placeholders for controlled non-production setup.

-- Active verified customer
-- auth email placeholder: customer.verified@example.test
-- profile role: Customer
-- profile status: active
-- email verification: verified

-- Active unverified customer
-- auth email placeholder: customer.unverified@example.test
-- profile role: Customer
-- profile status: pending or active based on environment policy
-- email verification: not verified

-- Suspended customer
-- auth email placeholder: customer.suspended@example.test
-- profile role: Customer
-- profile status: suspended
-- email verification: verified

-- Viewer
-- auth email placeholder: viewer.internal@example.test
-- profile role: Viewer
-- profile status: active
-- email verification: verified

-- Admin
-- auth email placeholder: admin.internal@example.test
-- profile role: Admin
-- profile status: active
-- email verification: verified

-- Super Admin
-- auth email placeholder: superadmin.internal@example.test
-- profile role: Super Admin
-- profile status: active
-- email verification: verified

-- Important:
-- - Do not store real passwords in repository seed files.
-- - Do not create auth users through raw seed SQL in this file.
-- - Create non-production auth identities through approved local or environment setup workflows.
