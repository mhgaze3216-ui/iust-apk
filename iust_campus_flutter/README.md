# IUST Campus Flutter

Arabic/RTL Flutter campus app with a local TypeScript/Express/PostgreSQL API in
[`backend/`](./backend/).

## Requirements

- Flutter SDK (use `flutter --version` and the project's Android/iOS toolchain)
- Docker Desktop with Docker Compose (recommended)
- Node.js 20+ and PostgreSQL 14+ with `psql` available on `PATH` when running without Docker

## Start the backend with Docker Compose

The Compose setup starts PostgreSQL and the API. On the first database
initialization, PostgreSQL runs `backend\schema.sql` followed by
`backend\migrations\001_student_documents.sql`. Both services have health
checks, and the API waits for PostgreSQL to report healthy.

From the repository root, prepare the backend environment file:

```powershell
Copy-Item .\backend\.env.example .\backend\.env
```

Edit `backend\.env` and set a private `DB_PASSWORD` and a unique `JWT_SECRET`.
Then start the services:

```powershell
Set-Location .\backend
docker compose up --build
```

The API is available at `http://localhost:3000`; check
`http://localhost:3000/health`. PostgreSQL data is stored in the persistent
`postgres_data` Docker volume. The SQL initialization scripts run only when
that volume is first created. For Firebase-backed file uploads, also configure
the Firebase bucket and credentials in `backend\.env`.

Stop the containers with `Ctrl+C`, or run `docker compose down` from `backend\`
to stop and remove the containers while retaining database data.

## Start the backend without Docker

1. Start PostgreSQL and create a database named `iust_campus` and a database
   user with access to it.
2. From the repository root, apply the initial schema:

   ```powershell
   psql "postgresql://iust_app:YOUR_LOCAL_DB_PASSWORD@localhost:5432/iust_campus" -f .\backend\schema.sql
   ```

   Replace the example user/password with your local PostgreSQL credentials.
   `schema.sql` is an initial schema, not a migration runner.
   For an existing database, apply `backend\migrations\001_student_documents.sql`
   before using the student document endpoints.
3. Create `backend\.env` from `backend\.env.example`. Set the PostgreSQL settings, a unique JWT secret, and trusted browser CORS origins:

   ```dotenv
   NODE_ENV=development
   PORT=3000
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=iust_app
   DB_PASSWORD=your-local-password
   DB_NAME=iust_campus
   DB_SSL=false
   # DATABASE_URL is only used if the DB_* host/user/name fields are unset.
   DATABASE_URL=postgresql://iust_app:YOUR_LOCAL_DB_PASSWORD@localhost:5432/iust_campus
   JWT_SECRET=PASTE_A_RANDOM_SECRET_HERE
   JWT_ISSUER=iust-campus-api
   JWT_AUDIENCE=iust-campus-client
   ACCESS_TOKEN_TTL=15m
   REFRESH_TOKEN_TTL_DAYS=30
   CORS_ORIGINS=http://localhost:5000,http://localhost:8080
   ```

   Generate a unique development `JWT_SECRET` (at least 32 bytes) in
   PowerShell with:

   ```powershell
   node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"
   ```

   The `DB_*` values take precedence over the legacy `DATABASE_URL` setting.
   Configure `FIREBASE_STORAGE_BUCKET` and a service account using
   `FIREBASE_SERVICE_ACCOUNT_PATH` (or another supported method from
   `backend\.env.example`) to enable file uploads. Keep `.env` private and
   never commit production credentials. Optional
   `SEED_ADMIN_USERNAME`, `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, and
   `SEED_ADMIN_NAME` values are read by the admin seed command only.
4. Install and start the API:

   ```powershell
   Set-Location .\backend
   npm install
   npm run dev
   ```

   The API listens on `http://localhost:3000`; check it at
   `http://localhost:3000/health`.

## Start Flutter against the API

In a second terminal at the repository root:

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

`API_BASE_URL` is a compile-time Flutter setting; it must include `/api/v1`.
The app defaults to the deployed Railway API
`https://iust-apk-production.up.railway.app/api/v1` when this define is omitted.
To run against a local backend, keep the explicit localhost override shown
above.
Choose a host reachable from the app's runtime:

- Flutter web or an iOS simulator: `http://localhost:3000/api/v1`
- Android emulator: `http://10.0.2.2:3000/api/v1`
- Physical device: use the development computer's LAN IP, for example
  `http://192.168.1.20:3000/api/v1`, and allow port 3000 through the local
  firewall.

For a custom Flutter web origin, add that exact origin to `CORS_ORIGINS` in
`backend\.env`, then restart the backend. Keep the API URL and origins on
trusted local/development networks; use HTTPS and secure managed secrets for
non-local deployments.

## Build Flutter against the deployed Railway API

The production API base URL is
`https://iust-apk-production.up.railway.app/api/v1`. The Flutter client uses
this by default. To explicitly build a release APK against that server:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://iust-apk-production.up.railway.app/api/v1
```

The APK is written to `build\app\outputs\flutter-apk\app-release.apk`. Verify
the service is reachable at
`https://iust-apk-production.up.railway.app/health`. To override the production
target for local development, pass the localhost or emulator URL shown in the
local setup section above.

## Initial accounts and implementation status

To create the first administrator, set the four `SEED_ADMIN_*` variables in
the backend environment and run `npm run seed:admin` from `backend\`. Student,
doctor, and staff identities and academic records must come from a trusted
university source; Flutter demo credentials are not backend accounts.

The Flutter repositories are connected to the API, and role shells load their
data asynchronously with retry states. The backend implements the core routes
documented in [`backend/docs/API.md`](./backend/docs/API.md); provider-dependent
workflows and database-backed contract testing remain outstanding and are
called out there. PostgreSQL must be running and the schema loaded before
authenticated or database-backed API operations can succeed.
