-- 003_add_export_categories.sql
-- Categories present in the Flutter app / poems export but missing from early 002 seeds.
-- Safe to re-run: ON CONFLICT DO NOTHING.

INSERT INTO categories (name, sort_order) VALUES
  ('የንግስ መዝሙራት', 16),
  ('ወረብ', 17),
  ('የቤተክርስቲያን መዝሙራት', 18),
  ('የሰርግ መዝሙራት', 19)
ON CONFLICT (name) DO NOTHING;
