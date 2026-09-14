-- 004_add_admin_role.sql
-- Admins can create other admins. The first (seeded) admin is 'super_admin' and
-- may add more accounts; everyone else defaults to 'admin'.

ALTER TABLE admins ADD COLUMN IF NOT EXISTS
  role TEXT NOT NULL DEFAULT 'admin';

-- The only account(s) existing before this migration are original/seed admins.
UPDATE admins SET role = 'super_admin';