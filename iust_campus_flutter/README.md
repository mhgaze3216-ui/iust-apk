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

## Deploy the backend to Render

The repository includes a root-level [`render.yaml`](./render.yaml) Blueprint.
It builds the API using `backend\Dockerfile` and creates a managed Render
PostgreSQL database in the same region. The Blueprint connects the API through
the database's private `DATABASE_URL`, sets a generated `JWT_SECRET`, and
configures `/health` as the service health check. Render supplies `PORT`
automatically; the Express server listens on it. Render does not run
`docker-compose.yml`: the database is a Render-managed Postgres service, not a
Postgres container.

### 1. Push the project to GitHub

Create an empty GitHub repository (do not initialize it with a README, license,
or `.gitignore`). In PowerShell, from the project root:

```powershell
git init
git branch -M main
git status --short
```

Before staging, confirm no `.env`, Firebase service-account JSON, or other
credentials appear in `git status`. The backend ignore rules exclude those
files. Then commit and push, replacing the URL with your GitHub repository:

```powershell
git add .
git status --short
git commit -m "Prepare IUST Campus app for Render deployment"
git remote add origin https://github.com/<GITHUB_USER>/<REPOSITORY>.git
git push -u origin main
```

If this folder is already a Git repository, skip `git init`; inspect `git
status` and the current remote before adding or replacing one.

### 2. Deploy with the Render Blueprint

1. Sign in at [Render](https://dashboard.render.com), connect your GitHub
   account, and select **New > Blueprint**.
2. Select the repository and `main` branch. Render discovers `render.yaml` in
   the repository root.
3. When prompted for `CORS_ORIGINS`, enter the exact browser origin(s) that
   will call the API, comma-separated, including scheme and port where
   relevant. For native Android/iOS Flutter apps, browser CORS does not apply;
   do not use `*` as a substitute for an origin allowlist.
4. Review and deploy. Render creates the database and Docker web service; the
   Blueprint connects them using the internal database URL. The API will be
   available at `https://<service-name>.onrender.com`.

`NODE_ENV=production`, the generated JWT secret, and the database URL are set
by the Blueprint. Do not set a fixed `PORT`: Render assigns it and the Express
server reads `process.env.PORT`. For manual service creation instead, choose a
Docker Web Service, set the Dockerfile path to `backend/Dockerfile`, Docker
context to `backend`, and health check path to `/health`. Create a Render
PostgreSQL instance in the same region and set `DATABASE_URL` on the web
service to its **Internal Database URL**; also set `NODE_ENV=production`, a
random `JWT_SECRET` (at least 32 bytes), and `CORS_ORIGINS`. Alternatively,
for a native Node service, set **Root Directory** to `backend`, build command
to `npm ci && npm run build`, and start command to `npm start`.

### 3. Initialize the Render database

Render does not automatically run this repository's SQL scripts when it
creates a PostgreSQL service. After the database is available, open its
**Connect** menu and copy the **External Database URL**. From the repository
root, use that URL locally (not the internal URL, which is for services running
inside Render):

```powershell
$env:PGSSLMODE = "require"
$env:RENDER_DATABASE_URL = Read-Host "Paste the Render External Database URL"
psql "$env:RENDER_DATABASE_URL" -v ON_ERROR_STOP=1 -f .\backend\schema.sql
if ($LASTEXITCODE -ne 0) { throw "schema.sql failed; stop and fix the SQL error before continuing." }
psql "$env:RENDER_DATABASE_URL" -v ON_ERROR_STOP=1 -f .\backend\migrations\001_student_documents.sql
if ($LASTEXITCODE -ne 0) { throw "Student documents migration failed." }
Remove-Item Env:RENDER_DATABASE_URL
Remove-Item Env:PGSSLMODE
```

Install PostgreSQL command-line tools first if `psql` is not available. Run
these scripts once on a new database only: `schema.sql` is an initial schema
and is not idempotent. Keep the external URL private; never commit it or put it
in shell history. The Blueprint wires the API to the internal URL, so no
database password needs to be added to Git or hard-coded in `render.yaml`.

### 4. Point Flutter at Render

Use the service's HTTPS URL and include `/api/v1`:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://<service-name>.onrender.com/api/v1
```

Install the resulting `build\app\outputs\flutter-apk\app-release.apk` on
devices. Test the API first with
`https://<service-name>.onrender.com/health`. Free Render web services can
spin down after inactivity, so the first request after idle may take around a
minute. Render's free PostgreSQL databases are temporary: they expire 30 days
after creation and have a 1 GB storage limit. This free configuration is for
testing/hobby use, not durable production data; upgrade or migrate before the
expiry deadline and keep backups outside a free database. See Render's current
[free instance limits](https://render.com/docs/free),
[Blueprint instructions](https://render.com/docs/infrastructure-as-code), and
[PostgreSQL connection guidance](https://render.com/docs/postgresql-creating-connecting).

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
