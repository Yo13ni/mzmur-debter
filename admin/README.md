# Admin API (NestJS + raw PostgreSQL)

Backend for መዝሙር ደብተር: public poem catalog + submission queue, seeded admin auth only.

## Stack

- NestJS
- PostgreSQL via `pg` (no ORM)
- SQL files in `migrations/`
- JWT login for seeded admin only (no student auth)

## Setup

```bash
cd admin
cp .env.example .env
# edit DATABASE_URL, JWT_SECRET, ADMIN_EMAIL, ADMIN_PASSWORD

# Local Postgres (this machine uses a user-space cluster on 5433 by default)
# Start once per reboot if needed:
#   export PATH=/usr/lib/postgresql/16/bin:$PATH
#   export PGDATA=../.pgdata
#   pg_ctl -D "$PGDATA" -l "$PGDATA/logfile" -o "-p 5433 -k /tmp" start
#   createdb -h 127.0.0.1 -p 5433 -U postgres mzmur   # once

# Or point DATABASE_URL at your system Postgres (often port 5432).

npm install
npm run migrate
npm run seed
npm run start:dev
```

API base: `http://127.0.0.1:3000/api`

## Admin UI (React)

```bash
cd admin-web
npm install
npm run dev
```

Open http://127.0.0.1:5173 — login with `ADMIN_EMAIL` / `ADMIN_PASSWORD` from `.env`.
See `admin-web/README.md`.

Flutter (Chrome / desktop) uses that URL by default. When you deploy:

```bash
flutter run --dart-define=API_BASE_URL=https://YOUR-API.onrender.com/api
```


## Migrations

| File | Purpose |
|------|---------|
| `migrations/001_init.sql` | `admins`, `categories`, `poems`, `submissions` |
| `migrations/002_seed_categories.sql` | Liturgical categories from the Flutter app |
| `migrations/003_add_export_categories.sql` | Extra categories (ንግስ, ወረብ, ቤተክርስቲያን, ሰርግ) for DBs that already ran 002 |

Runner tracks applied files in `schema_migrations`.

```bash
npm run migrate
```

Admin user + mock poems (one per export category from `data/poems_seed.json`) are seeded from env / JSON:

```bash
npm run seed
```

## Endpoints

### Public (Flutter)

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/categories` | List categories |
| GET | `/api/poems?categoryId=&q=` | Published hymns |
| GET | `/api/poems/:id` | Poem detail |
| POST | `/api/submissions` | Write = verification request |

### Admin (Bearer JWT)

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/auth/login` | `{ "email", "password" }` |
| GET | `/api/admin/submissions?status=PENDING` | Queue |
| GET | `/api/admin/submissions/:id` | Detail |
| PATCH | `/api/admin/submissions/:id/approve` | Optional title/content/categoryId edits → publishes poem |
| PATCH | `/api/admin/submissions/:id/reject` | Optional `adminNote`, `status` REJECTED \| NEEDS_CHANGES |
| POST/PATCH/DELETE | `/api/admin/poems` | Direct poem CRUD |
| POST/PATCH/DELETE | `/api/admin/categories` | Category CRUD |

## Approve flow

1. App `POST /api/submissions` → `PENDING`
2. Admin `PATCH .../approve` → inserts into `poems`, sets submission `APPROVED`
3. App `GET /api/poems` only returns published rows

## Example login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@mzmur.local","password":"change-me-admin-password"}'
```
