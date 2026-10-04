# IUST Campus API starter

TypeScript, Express, PostgreSQL REST API for the IUST Campus Flutter app. The Flutter repositories use this API instead of local demo repositories. `docs/API.md` inventories implemented handlers and explicitly lists integrations and workflows that remain unavailable; this starter still needs authoritative university data, provider integrations, and database-backed contract testing before production use.

## Requirements

- Node.js 20+
- Docker Desktop with Docker Compose (recommended), or PostgreSQL 14+
- `psql` command-line client for applying `schema.sql`

## Environment variables

Copy `.env.example` to `.env` and configure:

The API uses `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` for
PostgreSQL. `DATABASE_URL` is retained only as a backward-compatible
alternative when the individual host/user/name settings are unset.
Configure either the complete `DB_*` connection or `DATABASE_URL`; `DB_*`
settings take precedence if both are present.
The `DATABASE_URL` row below documents the legacy alternative; configure that
or the `DB_*` connection variables, not both.

| Variable | Required | Purpose |
|---|---:|---|
| `DATABASE_URL` | Yes | PostgreSQL connection string, e.g. `postgresql://iust_app:password@localhost:5432/iust_campus` |
| `DB_HOST`, `DB_USER`, `DB_NAME` | Required unless using `DATABASE_URL` | PostgreSQL host and database identity |
| `DB_PORT`, `DB_PASSWORD`, `DB_SSL` | No | Port defaults to `5432`; SSL can require TLS with certificate verification |
| `FIREBASE_STORAGE_BUCKET` | Uploads required | Firebase Storage bucket name |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Uploads required | Service-account JSON path; alternatively use `FIREBASE_SERVICE_ACCOUNT_JSON`, project/client/private-key variables, or ADC |
| `JWT_SECRET` | Yes | Unique signing secret, minimum 32 bytes; use a stronger random value in production |
| `PORT` | No | HTTP listen port; defaults to `3000` |
| `NODE_ENV` | No | Runtime environment; set to `production` for production checks |
| `JWT_ISSUER`, `JWT_AUDIENCE` | No | JWT validation claims; default to the IUST API/client identifiers |
| `ACCESS_TOKEN_TTL` | No | JWT lifetime; defaults to `15m` |
| `REFRESH_TOKEN_TTL_DAYS` | No | Refresh-session lifetime; defaults to `30` and is capped at 90 |
| `CORS_ORIGINS` | Production required | Comma-separated exact browser origins; production rejects an empty value |
| `SEED_ADMIN_USERNAME`, `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, `SEED_ADMIN_NAME` | Seed command only | Credentials and display name for the first administrator |

Generate a local secret with PowerShell:

```powershell
node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"
```

Never commit `.env` or use development secrets outside a local environment.

## Run with Docker Compose

From the `backend\` directory, copy `.env.example` to `.env`, then replace
`DB_PASSWORD` and `JWT_SECRET` with private, unique values:

```powershell
Copy-Item .\.env.example .\.env
docker compose up --build
```

On a new database volume, Compose starts PostgreSQL and runs `schema.sql`
followed by `migrations\001_student_documents.sql`. The API waits for the
PostgreSQL health check before starting. The API health endpoint is
`http://localhost:3000/health`; PostgreSQL is exposed on port 5432.
Database state persists in the `postgres_data` volume. Stop with `Ctrl+C` or
`docker compose down`; both options retain the database data.

The initialization scripts run only when PostgreSQL initializes an empty
volume. Apply later schema changes with the appropriate migration.

## Run without Docker

1. Create a PostgreSQL database and role, then execute `schema.sql` from the backend directory, for example:

   ```powershell

   psql "postgresql://iust_app:your-password@localhost:5432/iust_campus" -f .\schema.sql
   ```

   For an existing database created before student document uploads were added,
   apply `migrations\001_student_documents.sql` once using `psql -f`.

2. Copy `.env.example` to `.env`, set `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, and a unique `JWT_SECRET`; configure `CORS_ORIGINS` for trusted web origins. `DATABASE_URL` remains supported when the individual `DB_*` settings are unset.
3. To enable uploads, create a Firebase Storage bucket and a service account with object read/write permissions. Keep its JSON outside source control and configure `FIREBASE_STORAGE_BUCKET` plus `FIREBASE_SERVICE_ACCOUNT_PATH` (or one of the credential alternatives in the environment table).
4. Install and build:

   ```powershell
   npm install
   npm run build
   ```

5. Create the first admin through environment variables (do not use demo credentials):

   ```powershell
   $env:SEED_ADMIN_USERNAME = "..."
   $env:SEED_ADMIN_EMAIL = "..."
   $env:SEED_ADMIN_PASSWORD = "..."
   $env:SEED_ADMIN_NAME = "..."
   npm run seed:admin
   ```

6. Start the API:

   ```powershell
   npm run dev
   ```

   `GET http://localhost:3000/health` checks PostgreSQL and returns `{"data":{"status":"ok","database":"connected"}}`.

## Connect Flutter

From the Flutter project root, run the app with a compile-time API base URL
that includes `/api/v1`:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

Use `http://10.0.2.2:3000/api/v1` from an Android emulator, `localhost` from
Flutter web or an iOS simulator, or the development machine's LAN IP from a
physical device. For Flutter web, add the actual web origin (including scheme
and port) to `CORS_ORIGINS` and restart the server. The app defaults to the deployed Railway API
`https://iust-apk-production.up.railway.app/api/v1` when `API_BASE_URL` is
omitted. Pass the localhost define above only when you want to target your
local backend.

## Security and operations notes

- Guests are anonymous and can only call public/read-only endpoints and the rate-limited inquiry-creation operation; they are not a JWT role.
- Login returns a short-lived JWT access token and an opaque rotating refresh token. The server stores only a SHA-256 hash of each refresh token. Store client tokens in platform-secure storage; never put secrets in source control.
- Passwords are verified using bcrypt. The admin seed hashes the initial password with cost 12 and refuses duplicate accounts.
- Resource ownership is derived from the authenticated user. Do not add client-controlled owner IDs to write requests.
- `helmet`, strict configured CORS, request body limits, validation, and authentication throttling are enabled. Production must use HTTPS, a managed secret store, backups, observability, explicit CORS origins, and migration tooling.
- `schema.sql` is an initial schema, not a migration runner. Use versioned migrations and review schema changes before production.
- Authenticated uploads accept one `file` multipart field, are limited to 10 MB and PDF, DOCX, XLSX, JPEG, or PNG, and stream to a private Firebase Storage bucket. The API returns a signed read URL that expires after 15 minutes. Do not expose bucket credentials or make sensitive buckets public.
- `POST /api/v1/upload` stages an owned object; request attachments and student documents upload and persist metadata in one authenticated operation. Doctor archive files are staged first, then registered with their returned `storageKey`. Apply `migrations/001_student_documents.sql` to existing databases before enabling student document routes.
- Only the initial administrator seed is automated. Student, doctor, and staff identities must be provisioned from the university's trusted identity/academic source; do not import the Flutter demo accounts.
- Password-reset initiation needs a trusted email-delivery integration and currently returns `503 EMAIL_NOT_CONFIGURED`; reset-token consumption is implemented for a token provisioned by a trusted external process.
