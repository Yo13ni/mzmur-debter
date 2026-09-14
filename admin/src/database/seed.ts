import * as fs from 'fs';
import * as path from 'path';
import { Pool } from 'pg';
import * as bcrypt from 'bcryptjs';
import * as dotenv from 'dotenv';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

type SeedPoem = {
  title: string;
  content: string;
  category: string;
};

async function seedAdmin(pool: Pool): Promise<void> {
  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;
  const name = process.env.ADMIN_NAME || 'Admin';

  if (!email || !password) {
    throw new Error('ADMIN_EMAIL and ADMIN_PASSWORD are required');
  }

  const existing = await pool.query(
    'SELECT id FROM admins WHERE email = $1',
    [email],
  );

  if (existing.rows.length > 0) {
    console.log(`Admin already exists: ${email}`);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 12);
  await pool.query(
    `INSERT INTO admins (email, password_hash, name, role)
     VALUES ($1, $2, $3, 'super_admin')`,
    [email, passwordHash, name],
  );

  console.log(`Seeded admin: ${email}`);
}

async function seedPoems(pool: Pool): Promise<void> {
  const dataPath = path.resolve(__dirname, '../../data/poems_seed.json');
  if (!fs.existsSync(dataPath)) {
    console.log(`No poem seed file at ${dataPath}, skipping poems`);
    return;
  }

  const poems = JSON.parse(fs.readFileSync(dataPath, 'utf8')) as SeedPoem[];
  const { rows: cats } = await pool.query<{ id: string; name: string }>(
    'SELECT id, name FROM categories',
  );
  const byName = new Map(cats.map((c) => [c.name, c.id]));

  let inserted = 0;
  let skipped = 0;

  for (const poem of poems) {
    const categoryId = byName.get(poem.category);
    if (!categoryId) {
      throw new Error(`Unknown category in seed data: ${poem.category}`);
    }

    const result = await pool.query(
      `INSERT INTO poems (title, content, category_id)
       SELECT $1, $2, $3
       WHERE NOT EXISTS (
         SELECT 1 FROM poems WHERE title = $1 AND category_id = $3
       )`,
      [poem.title, poem.content, categoryId],
    );

    if (result.rowCount && result.rowCount > 0) {
      inserted += 1;
    } else {
      skipped += 1;
    }
  }

  console.log(`Seeded poems: ${inserted} inserted, ${skipped} already present`);
}

async function seed(): Promise<void> {
  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) throw new Error('DATABASE_URL is required');

  const pool = new Pool({ connectionString });

  try {
    await seedAdmin(pool);
    await seedPoems(pool);
  } finally {
    await pool.end();
  }
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
