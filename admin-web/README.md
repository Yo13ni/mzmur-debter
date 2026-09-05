# Admin Web (React + Tailwind)

Frontend for መዝሙር ደብተር admin: review submissions, manage poems and categories.

## Stack

- React + TypeScript (Vite)
- Tailwind CSS v4
- React Router
- Talks to Nest API at `/api` (proxied in dev)

## Setup

```bash
# Terminal 1 — API (from repo)
cd admin
npm run start:dev

# Terminal 2 — admin UI
cd admin-web
npm install
npm run dev
```

Open http://127.0.0.1:5173

Login with the seeded admin from `admin/.env` (default `admin@mzmur.local`).

## Features

- **Submissions** — filter queue, open detail, edit title/content/category, approve (publish), reject, or mark needs changes
- **Poems** — search, create, edit, delete published hymns
- **Categories** — add, reorder (sort), edit, delete

## API URL

Dev uses Vite proxy → `http://127.0.0.1:3000`.

For a remote API:

```bash
# admin-web/.env
VITE_API_BASE_URL=https://YOUR-API.onrender.com/api
```

## Build

```bash
npm run build
npm run preview
```
