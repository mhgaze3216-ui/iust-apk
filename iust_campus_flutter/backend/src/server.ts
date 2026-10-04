import 'dotenv/config';
import { createHash, randomBytes } from 'node:crypto';
import cors from 'cors';
import express, { NextFunction, Request, Response } from 'express';
import multer from 'multer';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import jwt, { JwtPayload } from 'jsonwebtoken';
import type { PoolClient } from 'pg';
import { z, ZodError } from 'zod';
import { pool } from './db';
import {
  createDownloadUrl,
  deleteUploadedFile,
  getStoredFileMetadata,
  StorageConfigurationError,
  StorageObjectNotFoundError,
  uploadFile,
} from './firebase';

const roleSchema = z.enum(['student', 'doctor', 'staff', 'admin']);
type Role = z.infer<typeof roleSchema>;
type Principal = { id: string; role: Role; username: string; email: string; fullName: string };
type AuthenticatedRequest = Request & { principal?: Principal };

const requiredEnv = (name: string): string => {
  const value = process.env[name];
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
};

const jwtSecret = requiredEnv('JWT_SECRET');
if (Buffer.byteLength(jwtSecret) < 32) {
  throw new Error('JWT_SECRET must contain at least 32 bytes.');
}

const issuer = process.env.JWT_ISSUER ?? 'iust-campus-api';
const audience = process.env.JWT_AUDIENCE ?? 'iust-campus-client';
const accessTtl = process.env.ACCESS_TOKEN_TTL ?? '15m';
const refreshTtlDays = Number(process.env.REFRESH_TOKEN_TTL_DAYS ?? '30');
if (!Number.isInteger(refreshTtlDays) || refreshTtlDays < 1 || refreshTtlDays > 90) {
  throw new Error('REFRESH_TOKEN_TTL_DAYS must be an integer between 1 and 90.');
}

const app = express();
app.disable('x-powered-by');
app.use(helmet());

const allowedOrigins = (process.env.CORS_ORIGINS ?? '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);
if (process.env.NODE_ENV === 'production' && allowedOrigins.length === 0) {
  console.warn('CORS_ORIGINS is empty; browser-origin requests will not receive CORS permission.');
}
app.use(cors({
  origin(origin, callback) {
    callback(null, !origin || allowedOrigins.includes(origin));
  },
  credentials: false,
}));
app.use(express.json({ limit: '1mb' }));

const acceptedMimeTypes = new Set([
  'application/pdf',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'image/jpeg',
  'image/png',
]);
const uploadLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 30,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many file uploads.' } },
});
const fileUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024, files: 1 },
  fileFilter(_req, file, callback) {
    if (!acceptedMimeTypes.has(file.mimetype)) {
      callback(new HttpError(400, 'Unsupported file type.', 'UNSUPPORTED_FILE_TYPE'));
      return;
    }
    callback(null, true);
  },
});
const receiveSingleFile = fileUpload.single('file');
const validateFileSignature = (file: Express.Multer.File) => {
  const bytes = file.buffer;
  const valid = file.mimetype === 'application/pdf'
    ? bytes.subarray(0, 5).toString('ascii') === '%PDF-'
    : file.mimetype === 'image/png'
      ? bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))
      : file.mimetype === 'image/jpeg'
        ? bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff
        : bytes[0] === 0x50 && bytes[1] === 0x4b && bytes[2] === 0x03 && bytes[3] === 0x04;
  if (!valid) throw new HttpError(400, 'File content does not match its declared type.', 'INVALID_FILE_CONTENT');
};

const asyncRoute = (
  handler: (req: Request, res: Response, next: NextFunction) => Promise<unknown>,
) => (req: Request, res: Response, next: NextFunction) => {
  void handler(req, res, next).catch(next);
};

class HttpError extends Error {
  constructor(readonly status: number, message: string, readonly code: string) {
    super(message);
  }
}

const hashToken = (token: string) => createHash('sha256').update(token).digest('hex');

const makeTokens = (user: Principal) => ({
  accessToken: jwt.sign(
    { role: user.role, username: user.username },
    jwtSecret,
    { subject: user.id, issuer, audience, expiresIn: accessTtl as jwt.SignOptions['expiresIn'], algorithm: 'HS256' },
  ),
  refreshToken: randomBytes(48).toString('base64url'),
});

const issueRefreshSession = async (client: PoolClient, userId: string, token: string) => {
  await client.query(
    `INSERT INTO refresh_sessions (user_id, token_hash, expires_at)
     VALUES ($1, $2, now() + ($3::int * interval '1 day'))`,
    [userId, hashToken(token), refreshTtlDays],
  );
};

const userSelect = `id, username, email, role, status, full_name AS "fullName"`;

const requireAuth = asyncRoute(async (req, res, next) => {
  const authorization = req.header('authorization');
  const match = authorization?.match(/^Bearer ([^\s]+)$/);
  if (!match) throw new HttpError(401, 'A bearer access token is required.', 'UNAUTHENTICATED');

  let claims: JwtPayload;
  try {
    const verified = jwt.verify(match[1], jwtSecret, {
      algorithms: ['HS256'],
      issuer,
      audience,
    });
    if (typeof verified === 'string' || !verified.sub) {
      throw new Error('Invalid token subject.');
    }
    claims = verified;
  } catch {
    throw new HttpError(401, 'The access token is invalid or expired.', 'INVALID_TOKEN');
  }

  const result = await pool.query(
    `SELECT ${userSelect} FROM users WHERE id = $1 AND status = 'active'`,
    [claims.sub],
  );
  const user = result.rows[0] as Principal | undefined;
  if (!user) throw new HttpError(401, 'The account is unavailable.', 'ACCOUNT_UNAVAILABLE');
  (req as AuthenticatedRequest).principal = user;
  next();
});

const requireRoles = (...roles: Role[]) => (req: Request, _res: Response, next: NextFunction) => {
  const principal = (req as AuthenticatedRequest).principal;
  if (!principal) return next(new HttpError(401, 'Authentication is required.', 'UNAUTHENTICATED'));
  if (!roles.includes(principal.role)) {
    return next(new HttpError(403, 'Your role cannot perform this action.', 'FORBIDDEN'));
  }
  next();
};

const principalOf = (req: Request): Principal => {
  const principal = (req as AuthenticatedRequest).principal;
  if (!principal) throw new HttpError(401, 'Authentication is required.', 'UNAUTHENTICATED');
  return principal;
};

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many authentication attempts.' } },
});

const loginBody = z.object({
  username: z.string().trim().min(1).max(120),
  password: z.string().min(1).max(256),
});

app.get('/health', asyncRoute(async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ data: { status: 'ok', database: 'connected' } });
  } catch (error) {
    console.error('Database health check failed:', error);
    res.status(503).json({
      error: { code: 'DATABASE_UNAVAILABLE', message: 'The database is temporarily unavailable.' },
    });
  }
}));

app.post('/api/v1/upload', requireAuth, uploadLimiter, receiveSingleFile, asyncRoute(async (req, res) => {
  const file = req.file;
  if (!file) throw new HttpError(400, 'A multipart file field named "file" is required.', 'FILE_REQUIRED');
  validateFileSignature(file);
  const principal = principalOf(req);
  const uploaded = await uploadFile(principal.id, file.originalname, file.mimetype, file.buffer);
  res.status(201).json({
    data: {
      ...uploaded,
      fileName: file.originalname,
      contentType: file.mimetype,
      fileSizeBytes: file.size,
    },
  });
}));

app.post('/api/v1/auth/login', loginLimiter, asyncRoute(async (req, res) => {
  const body = loginBody.parse(req.body);
  const result = await pool.query(
    `SELECT ${userSelect}, password_hash AS "passwordHash"
     FROM users
     WHERE lower(username) = lower($1) OR lower(email) = lower($1)
     LIMIT 1`,
    [body.username],
  );
  const user = result.rows[0] as (Principal & { passwordHash: string; status: string }) | undefined;
  const passwordMatches = user ? await (await import('bcryptjs')).compare(body.password, user.passwordHash) : false;
  if (!user || user.status !== 'active' || !passwordMatches) {
    throw new HttpError(401, 'Username or password is incorrect.', 'INVALID_CREDENTIALS');
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query('UPDATE users SET last_login_at = now() WHERE id = $1', [user.id]);
    const tokens = makeTokens(user);
    await issueRefreshSession(client, user.id, tokens.refreshToken);
    await client.query('COMMIT');
    res.json({ data: { user: { id: user.id, username: user.username, email: user.email, role: user.role, fullName: user.fullName }, ...tokens, tokenType: 'Bearer', expiresIn: accessTtl } });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/auth/refresh', loginLimiter, asyncRoute(async (req, res) => {
  const { refreshToken } = z.object({ refreshToken: z.string().min(40).max(200) }).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const session = await client.query(
      `SELECT u.${userSelect.split(', ').join(', u.')}, rs.id AS "sessionId"
       FROM refresh_sessions rs
       JOIN users u ON u.id = rs.user_id
       WHERE rs.token_hash = $1 AND rs.revoked_at IS NULL AND rs.expires_at > now()
         AND u.status = 'active'
       FOR UPDATE OF rs`,
      [hashToken(refreshToken)],
    );
    const user = session.rows[0] as (Principal & { sessionId: string }) | undefined;
    if (!user) throw new HttpError(401, 'Refresh token is invalid or expired.', 'INVALID_REFRESH_TOKEN');
    await client.query('UPDATE refresh_sessions SET revoked_at = now() WHERE id = $1', [user.sessionId]);
    const tokens = makeTokens(user);
    await issueRefreshSession(client, user.id, tokens.refreshToken);
    await client.query('COMMIT');
    res.json({ data: { ...tokens, tokenType: 'Bearer', expiresIn: accessTtl } });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/auth/password/forgot', loginLimiter, asyncRoute(async (req) => {
  z.object({ email: z.string().trim().email().max(254) }).parse(req.body);
  throw new HttpError(503, 'Password reset delivery is not configured.', 'EMAIL_NOT_CONFIGURED');
}));

app.post('/api/v1/auth/password/reset', loginLimiter, asyncRoute(async (req, res) => {
  const body = z.object({
    token: z.string().min(32).max(200),
    newPassword: z.string().min(12).max(256),
  }).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const token = await client.query(
      `SELECT id, user_id AS "userId" FROM password_reset_tokens
       WHERE token_hash = $1 AND used_at IS NULL AND expires_at > now()
       FOR UPDATE`,
      [hashToken(body.token)],
    );
    if (!token.rowCount) throw new HttpError(400, 'Password reset token is invalid or expired.', 'INVALID_RESET_TOKEN');
    const passwordHash = await (await import('bcryptjs')).hash(body.newPassword, 12);
    await client.query(
      `UPDATE users SET password_hash = $1, updated_at = now() WHERE id = $2`,
      [passwordHash, token.rows[0].userId],
    );
    await client.query('UPDATE password_reset_tokens SET used_at = now() WHERE id = $1', [token.rows[0].id]);
    await client.query(
      `UPDATE refresh_sessions SET revoked_at = now()
       WHERE user_id = $1 AND revoked_at IS NULL`,
      [token.rows[0].userId],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id)
       VALUES ($1, 'auth.password.reset', 'user', $1)`,
      [token.rows[0].userId],
    );
    await client.query('COMMIT');
    res.status(204).end();
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/auth/logout', requireAuth, asyncRoute(async (req, res) => {
  const { refreshToken } = z.object({ refreshToken: z.string().min(40).max(200) }).parse(req.body);
  await pool.query(
    `UPDATE refresh_sessions SET revoked_at = now()
     WHERE user_id = $1 AND token_hash = $2 AND revoked_at IS NULL`,
    [principalOf(req).id, hashToken(refreshToken)],
  );
  res.status(204).end();
}));

app.post('/api/v1/auth/password/change', requireAuth, asyncRoute(async (req, res) => {
  const { currentPassword, newPassword } = z.object({
    currentPassword: z.string().min(1).max(256),
    newPassword: z.string().min(12).max(256),
  }).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query(
      `SELECT password_hash AS "passwordHash" FROM users WHERE id = $1 AND status = 'active' FOR UPDATE`,
      [principal.id],
    );
    if (!result.rowCount || !(await (await import('bcryptjs')).compare(currentPassword, result.rows[0].passwordHash))) {
      throw new HttpError(400, 'Current password is incorrect.', 'INVALID_CURRENT_PASSWORD');
    }
    const passwordHash = await (await import('bcryptjs')).hash(newPassword, 12);
    await client.query(
      `UPDATE users SET password_hash = $1, updated_at = now() WHERE id = $2`,
      [passwordHash, principal.id],
    );
    await client.query(
      `UPDATE refresh_sessions SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL`,
      [principal.id],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id)
       VALUES ($1, 'auth.password.change', 'user', $1)`,
      [principal.id],
    );
    await client.query('COMMIT');
    res.status(204).end();
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/me', requireAuth, asyncRoute(async (req, res) => {
  const user = principalOf(req);
  res.json({ data: { id: user.id, username: user.username, email: user.email, role: user.role, fullName: user.fullName } });
}));

app.get('/api/v1/me/preferences', requireAuth, asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT preferred_language AS "preferredLanguage",
            notification_preferences AS notifications
     FROM users WHERE id = $1`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows[0] });
}));

app.patch('/api/v1/me/preferences', requireAuth, asyncRoute(async (req, res) => {
  const body = z.object({
    preferredLanguage: z.enum(['ar', 'en']).optional(),
    notifications: z.record(z.string(), z.boolean()).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const result = await pool.query(
    `UPDATE users SET
       preferred_language = COALESCE($1, preferred_language),
       notification_preferences = COALESCE($2::jsonb, notification_preferences),
       updated_at = now()
     WHERE id = $3
     RETURNING preferred_language AS "preferredLanguage",
               notification_preferences AS notifications`,
    [body.preferredLanguage ?? null, body.notifications ? JSON.stringify(body.notifications) : null, principalOf(req).id],
  );
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/public/faculties', asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, code, name_ar AS "nameAr", name_en AS "nameEn", description
     FROM faculties WHERE is_published = true ORDER BY name_ar`,
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/faculties/:facultyId', asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT f.id, f.code, f.name_ar AS "nameAr", f.name_en AS "nameEn", f.description,
       COALESCE(json_agg(json_build_object(
         'id', d.id, 'code', d.code, 'nameAr', d.name_ar, 'nameEn', d.name_en,
         'description', d.description
       )) FILTER (WHERE d.id IS NOT NULL), '[]'::json) AS departments
     FROM faculties f LEFT JOIN departments d ON d.faculty_id = f.id AND d.is_published
     WHERE f.id = $1 AND f.is_published
     GROUP BY f.id`,
    [req.params.facultyId],
  );
  if (!result.rowCount) throw new HttpError(404, 'Faculty not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/public/departments', asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, faculty_id AS "facultyId", code, name_ar AS "nameAr",
            name_en AS "nameEn", description, contact_email AS "contactEmail"
     FROM departments WHERE is_published ORDER BY name_ar`,
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/courses', asyncRoute(async (req, res) => {
  const departmentId = z.string().uuid().optional().parse(req.query.departmentId);
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT DISTINCT c.id, c.code, c.name_ar AS "nameAr", c.name_en AS "nameEn",
            c.credit_hours AS "creditHours", c.department_id AS "departmentId"
     FROM courses c LEFT JOIN course_sections cs ON cs.course_id = c.id
     WHERE ($1::uuid IS NULL OR c.department_id = $1)
       AND ($2::uuid IS NULL OR cs.term_id = $2)
     ORDER BY c.name_ar`,
    [departmentId ?? null, termId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/faqs', asyncRoute(async (req, res) => {
  const category = z.string().trim().max(80).optional().parse(req.query.category);
  const departmentId = z.string().uuid().optional().parse(req.query.departmentId);
  const result = await pool.query(
    `SELECT id, department_id AS "departmentId", category, question, answer
     FROM faqs WHERE is_published = true
       AND ($1::text IS NULL OR category = $1)
       AND ($2::uuid IS NULL OR department_id = $2)
     ORDER BY sort_order, question`,
    [category ?? null, departmentId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/services', asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT id, department_id AS "departmentId", name, description, requirements, fees,
            expected_duration AS "expectedDuration"
     FROM university_services WHERE is_published ORDER BY name`,
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/transactions', asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, department_id AS "departmentId", title, description, requirements,
            documents, fees, expected_duration AS "expectedDuration", steps
     FROM university_transactions WHERE is_published ORDER BY title`,
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/scholarships', asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, title, description, eligibility, deadline,
            document_ids AS "documentIds"
     FROM scholarships WHERE is_published ORDER BY deadline NULLS LAST, title`,
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/documents', asyncRoute(async (req, res) => {
  const category = z.string().trim().max(80).optional().parse(req.query.category);
  const result = await pool.query(
    `SELECT id, title, category, version, content_type AS "contentType",
            created_at AS "createdAt"
     FROM university_documents WHERE is_published
       AND ($1::text IS NULL OR category = $1)
     ORDER BY title`,
    [category ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/documents/:id/download', asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT storage_key AS "storageKey" FROM university_documents
     WHERE id = $1 AND is_published`,
    [z.string().uuid().parse(req.params.id)],
  );
  if (!result.rowCount) throw new HttpError(404, 'Document not found.', 'NOT_FOUND');
  res.json({ data: await createDownloadUrl(result.rows[0].storageKey) });
}));

app.get('/api/v1/public/news', asyncRoute(async (req, res) => {
  const category = z.string().trim().max(80).optional().parse(req.query.category);
  const result = await pool.query(
    `SELECT id, category, title, summary, content, published_at AS "publishedAt"
     FROM news_items
     WHERE status = 'published' AND (publish_at IS NULL OR publish_at <= now())
       AND ($1::text IS NULL OR category = $1)
     ORDER BY published_at DESC NULLS LAST`,
    [category ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/transport/routes', asyncRoute(async (req, res) => {
  const serviceDate = z.string().date().optional().parse(req.query.date);
  const result = await pool.query(
    `SELECT r.id, r.name, r.stops,
       COALESCE(json_agg(json_build_object(
         'id', d.id, 'departsAt', d.departs_at, 'arrivesAt', d.arrives_at, 'status', d.status
       )) FILTER (WHERE d.id IS NOT NULL), '[]'::json) AS departures
     FROM transport_routes r LEFT JOIN transport_departures d
       ON d.route_id = r.id AND ($1::date IS NULL OR d.service_date = $1)
     WHERE r.is_active GROUP BY r.id ORDER BY r.name`,
    [serviceDate ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/maps/buildings', asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT b.id, b.name_ar AS "nameAr", b.code, b.description,
            b.map_asset_url AS "mapAssetUrl", b.map_version AS "mapVersion",
            COALESCE(json_agg(json_build_object(
              'id', f.id, 'nameAr', f.name_ar, 'floorNumber', f.floor_number,
              'mapAssetUrl', f.map_asset_url
            )) FILTER (WHERE f.id IS NOT NULL), '[]'::json) AS floors
     FROM campus_buildings b LEFT JOIN campus_floors f ON f.building_id = b.id
     GROUP BY b.id ORDER BY b.name_ar`,
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/maps/buildings/:buildingId/floors/:floorId/rooms', asyncRoute(async (req, res) => {
  const query = z.string().trim().max(120).optional().parse(req.query.q);
  const result = await pool.query(
    `SELECT r.id, r.room_number AS "roomNumber", r.name_ar AS "nameAr",
            r.type, r.coordinates
     FROM campus_rooms r JOIN campus_floors f ON f.id = r.floor_id
     WHERE f.id = $1 AND f.building_id = $2
       AND ($3::text IS NULL OR r.room_number ILIKE '%' || $3 || '%' OR r.name_ar ILIKE '%' || $3 || '%')
     ORDER BY r.room_number`,
    [req.params.floorId, req.params.buildingId, query ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/public/maps/search', asyncRoute(async (req, res) => {
  const query = z.string().trim().min(1).max(120).parse(req.query.q);
  const result = await pool.query(
    `SELECT b.id AS "buildingId", b.name_ar AS "buildingName", f.id AS "floorId",
            f.name_ar AS "floorName", r.id AS "roomId", r.room_number AS "roomNumber",
            r.name_ar AS "roomName", r.type, r.coordinates
     FROM campus_rooms r JOIN campus_floors f ON f.id = r.floor_id
     JOIN campus_buildings b ON b.id = f.building_id
     WHERE r.room_number ILIKE '%' || $1 || '%' OR r.name_ar ILIKE '%' || $1 || '%'
       OR b.name_ar ILIKE '%' || $1 || '%' OR b.code ILIKE '%' || $1 || '%'
     ORDER BY b.name_ar, f.floor_number, r.room_number LIMIT 100`,
    [query],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT u.id, u.username, u.email, u.full_name AS "fullName",
            sp.university_number AS "universityNumber", sp.admission_year AS "admissionYear",
            sp.academic_year AS "academicYear", sp.academic_status AS "academicStatus",
            f.name_ar AS "facultyName", d.name_ar AS "departmentName"
     FROM users u JOIN student_profiles sp ON sp.user_id = u.id
     LEFT JOIN faculties f ON f.id = sp.faculty_id
     LEFT JOIN departments d ON d.id = sp.department_id
     WHERE u.id = $1`,
    [principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Student profile not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/students/me/courses', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT c.id, c.code, c.name_ar AS "nameAr", c.name_en AS "nameEn",
            c.credit_hours AS "creditHours", cs.id AS "sectionId",
            cs.section_number AS "sectionNumber", t.name_ar AS "termName"
     FROM enrollments e
     JOIN course_sections cs ON cs.id = e.section_id
     JOIN courses c ON c.id = cs.course_id
     JOIN terms t ON t.id = cs.term_id
     WHERE e.student_user_id = $1 AND e.status = 'enrolled'
       AND ($2::uuid IS NULL OR cs.term_id = $2)
     ORDER BY c.name_ar`,
    [principalOf(req).id, termId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/documents', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT id, title, category, file_name AS "fileName", content_type AS "contentType",
       file_size_bytes::int AS "fileSizeBytes", created_at AS "createdAt"
     FROM student_documents WHERE owner_user_id = $1 ORDER BY created_at DESC LIMIT 100`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/documents', requireAuth, requireRoles('student'), uploadLimiter, receiveSingleFile, asyncRoute(async (req, res) => {
  const file = req.file;
  if (!file) throw new HttpError(400, 'A multipart file field named "file" is required.', 'FILE_REQUIRED');
  validateFileSignature(file);
  const { title, category } = z.object({
    title: z.string().trim().min(1).max(180),
    category: z.string().trim().min(1).max(80),
  }).parse(req.body);
  const principal = principalOf(req);
  const uploaded = await uploadFile(principal.id, file.originalname, file.mimetype, file.buffer);
  try {
    const document = await pool.query(
      `INSERT INTO student_documents
         (owner_user_id, title, category, storage_key, file_name, content_type, file_size_bytes)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, title, category, file_name AS "fileName", content_type AS "contentType",
         file_size_bytes::int AS "fileSizeBytes", created_at AS "createdAt"`,
      [principal.id, title, category, uploaded.storageKey, file.originalname, file.mimetype, file.size],
    );
    res.status(201).json({ data: { ...document.rows[0], ...uploaded, fileSizeBytes: file.size } });
  } catch (error) {
    try {
      await deleteUploadedFile(uploaded.storageKey);
    } catch (cleanupError) {
      console.error('Failed to clean up an unlinked student document:', cleanupError);
    }
    throw error;
  }
}));

app.get('/api/v1/students/me/documents/:id/download', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT storage_key AS "storageKey" FROM student_documents
     WHERE id = $1 AND owner_user_id = $2`,
    [z.string().uuid().parse(req.params.id), principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Student document not found.', 'NOT_FOUND');
  res.json({ data: await createDownloadUrl(result.rows[0].storageKey) });
}));

app.get('/api/v1/students/me/grades', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT c.id AS "courseId", c.code, c.name_ar AS "courseName", g.components,
            g.total, g.letter_grade AS "letterGrade", g.published_at AS "publishedAt"
     FROM grades g JOIN enrollments e ON e.id = g.enrollment_id
     JOIN course_sections cs ON cs.id = e.section_id
     JOIN courses c ON c.id = cs.course_id
     WHERE e.student_user_id = $1 AND e.status IN ('enrolled', 'completed')
       AND ($2::uuid IS NULL OR cs.term_id = $2)
       AND (g.published_at IS NOT NULL OR EXISTS (SELECT 1 FROM users u WHERE u.id = $1 AND u.role = 'admin'))
     ORDER BY c.name_ar`,
    [principalOf(req).id, termId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/schedule', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT cs.id AS "sectionId", c.id AS "courseId", c.name_ar AS "courseName",
            cs.room, cs.schedule, u.full_name AS "instructorName"
     FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
     JOIN courses c ON c.id = cs.course_id
     LEFT JOIN users u ON u.id = cs.instructor_user_id
     WHERE e.student_user_id = $1 AND e.status = 'enrolled'
       AND ($2::uuid IS NULL OR cs.term_id = $2)`,
    [principalOf(req).id, termId ?? null],
  );
  const manual = await pool.query(
    `SELECT entry.id AS "scheduleId", NULL::uuid AS "sectionId", c.id AS "courseId",
       c.name_ar AS "courseName", entry.room,
       json_build_array(json_build_object('dayOfWeek', entry.day_of_week,
         'startTime', entry.starts_at, 'endTime', entry.ends_at)) AS schedule,
       NULL::text AS "instructorName", 'manual' AS "entryType"
     FROM student_schedule_entries entry JOIN courses c ON c.id = entry.course_id
     WHERE entry.student_user_id = $1 AND ($2::uuid IS NULL OR entry.term_id = $2)
     ORDER BY entry.day_of_week, entry.starts_at`,
    [principalOf(req).id, termId ?? null],
  );
  res.json({ data: [...result.rows, ...manual.rows] });
}));

app.get('/api/v1/students/me/study-plan', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const studentId = principalOf(req).id;
  const summary = await pool.query(
    `SELECT sp.required_credit_hours AS "requiredCreditHours",
            sp.completed_credit_hours AS "completedCreditHours",
            COALESCE(SUM(c.credit_hours) FILTER (WHERE e.status = 'enrolled'), 0)::int AS "currentRegisteredCreditHours",
            GREATEST(sp.required_credit_hours - sp.completed_credit_hours, 0)::int AS "remainingCreditHours",
            sp.academic_year AS "academicYear"
     FROM student_profiles sp
     LEFT JOIN enrollments e ON e.student_user_id = sp.user_id
     LEFT JOIN course_sections cs ON cs.id = e.section_id
     LEFT JOIN courses c ON c.id = cs.course_id
     WHERE sp.user_id = $1
     GROUP BY sp.user_id`,
    [studentId],
  );
  if (!summary.rowCount) throw new HttpError(404, 'Study plan not found.', 'NOT_FOUND');
  const courses = await pool.query(
    `SELECT spc.id, spc.course_id AS "courseId", c.code AS "courseCode",
            c.name_ar AS "courseName", c.credit_hours AS credits,
            spc.academic_year AS "yearNumber", spc.semester AS "semesterNumber",
            spc.prerequisite_course_ids AS "prerequisiteCourseIds", spc.is_required AS "isRequired",
            EXISTS (
              SELECT 1 FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
              WHERE e.student_user_id = $1 AND cs.course_id = c.id AND e.status = 'completed'
            ) AS completed
     FROM student_profiles student
     JOIN study_plan_courses spc ON spc.department_id = student.department_id
     JOIN courses c ON c.id = spc.course_id
     WHERE student.user_id = $1
     ORDER BY spc.academic_year, spc.semester, c.code`,
    [studentId],
  );
  res.json({ data: { ...summary.rows[0], courses: courses.rows } });
}));

app.get('/api/v1/students/me/exams', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT es.id, es.exam_type AS "examType", es.starts_at AS "startsAt",
            es.ends_at AS "endsAt", es.room, c.id AS "courseId", c.code AS "courseCode",
            c.name_ar AS "courseName", cs.term_id AS "termId"
     FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
     JOIN exam_schedules es ON es.section_id = cs.id AND es.status = 'published'
     JOIN courses c ON c.id = cs.course_id
     WHERE e.student_user_id = $1 AND e.status = 'enrolled'
       AND ($2::uuid IS NULL OR cs.term_id = $2)
     ORDER BY es.starts_at`,
    [principalOf(req).id, termId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/advising', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT ar.id, ar.advisor_user_id AS "advisorUserId", advisor.full_name AS "advisorName",
            ar.subject, ar.message, ar.status, ar.created_at AS "createdAt",
            ar.updated_at AS "updatedAt"
     FROM advising_requests ar JOIN users advisor ON advisor.id = ar.advisor_user_id
     WHERE ar.student_user_id = $1 ORDER BY ar.created_at DESC`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/advising', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({
    advisorUserId: z.string().uuid(),
    subject: z.string().trim().min(3).max(180),
    message: z.string().trim().min(5).max(5000),
  }).parse(req.body);
  const studentId = principalOf(req).id;
  const result = await pool.query(
    `INSERT INTO advising_requests (student_user_id, advisor_user_id, subject, message)
     SELECT sp.user_id, sp.advisor_user_id, $3, $4
     FROM student_profiles sp
     WHERE sp.user_id = $1 AND sp.advisor_user_id = $2
     RETURNING id, advisor_user_id AS "advisorUserId", subject, message, status,
       created_at AS "createdAt"`,
    [studentId, body.advisorUserId, body.subject, body.message],
  );
  if (!result.rowCount) throw new HttpError(403, 'The selected advisor is not assigned to your account.', 'ADVISOR_MISMATCH');
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/students/me/library', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const query = z.string().trim().max(160).optional().parse(req.query.q);
  const result = await pool.query(
    `SELECT lr.id, lr.title, lr.authors, lr.resource_type AS "resourceType",
            lr.url, lr.metadata
     FROM library_references lr
     JOIN student_profiles sp ON sp.user_id = $1
     WHERE lr.is_published AND (lr.faculty_id = sp.faculty_id OR lr.faculty_id = sp.department_id)
       AND ($2::text IS NULL OR lr.title ILIKE '%' || $2 || '%' OR array_to_string(lr.authors, ' ') ILIKE '%' || $2 || '%')
     ORDER BY lr.title LIMIT 200`,
    [principalOf(req).id, query ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/calendar', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT e.id, e.term_id AS "termId", e.title, e.description,
            e.starts_at AS "startsAt", e.ends_at AS "endsAt", e.category,
            t.name_ar AS "termName", t.starts_on AS "termStartsOn", t.ends_on AS "termEndsOn",
            t.registration_opens_at AS "registrationOpensAt",
            t.registration_closes_at AS "registrationClosesAt"
     FROM academic_calendar_events e LEFT JOIN terms t ON t.id = e.term_id
     WHERE e.is_published AND ($1::uuid IS NULL OR e.term_id = $1)
     ORDER BY e.starts_at`,
    [termId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/transport', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const serviceDate = z.string().date().optional().parse(req.query.date);
  const result = await pool.query(
    `SELECT r.id, r.name, r.stops, d.id AS "departureId",
            d.departs_at AS "departsAt", d.arrives_at AS "arrivesAt",
            d.service_date AS "serviceDate", d.status
     FROM transport_routes r LEFT JOIN transport_departures d
       ON d.route_id = r.id AND ($1::date IS NULL OR d.service_date = $1)
     WHERE r.is_active ORDER BY r.name, d.departs_at`,
    [serviceDate ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/registration/offerings', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT cs.id AS "sectionId", cs.section_number AS "sectionNumber",
            cs.capacity, cs.schedule, cs.room, t.id AS "termId", t.name_ar AS "termName",
            t.registration_opens_at AS "registrationOpensAt",
            t.registration_closes_at AS "registrationClosesAt",
            c.id AS "courseId", c.code, c.name_ar AS "courseName",
            c.credit_hours AS "creditHours",
            count(e.id) FILTER (WHERE e.status = 'enrolled')::int AS "enrolledCount",
            (count(e.id) FILTER (WHERE e.status = 'enrolled') < cs.capacity) AS "hasCapacity"
     FROM course_sections cs JOIN courses c ON c.id = cs.course_id
     JOIN terms t ON t.id = cs.term_id
     LEFT JOIN enrollments e ON e.section_id = cs.id
     WHERE ($1::uuid IS NULL OR t.id = $1)
       AND EXISTS (SELECT 1 FROM student_profiles sp
                   WHERE sp.user_id = $2 AND (c.department_id IS NULL OR c.department_id = sp.department_id))
     GROUP BY cs.id, c.id, t.id ORDER BY c.name_ar, cs.section_number`,
    [termId ?? null, principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/registration', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const { sectionId, action } = z.object({
    sectionId: z.string().uuid(),
    action: z.literal('enroll'),
  }).parse(req.body);
  const studentId = principalOf(req).id;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const section = await client.query(
      `SELECT cs.id, cs.capacity, cs.course_id AS "courseId",
              c.department_id AS "courseDepartmentId", cs.term_id AS "termId",
              t.registration_opens_at AS "opensAt", t.registration_closes_at AS "closesAt"
       FROM course_sections cs JOIN terms t ON t.id = cs.term_id
       JOIN courses c ON c.id = cs.course_id
       WHERE cs.id = $1 FOR UPDATE OF cs`,
      [sectionId],
    );
    if (!section.rowCount) throw new HttpError(404, 'Course section not found.', 'NOT_FOUND');
    const offering = section.rows[0];
    const student = await client.query(
      `SELECT department_id AS "departmentId" FROM student_profiles WHERE user_id = $1`,
      [studentId],
    );
    if (!student.rowCount) throw new HttpError(404, 'Student profile not found.', 'NOT_FOUND');
    if (offering.courseDepartmentId && offering.courseDepartmentId !== student.rows[0].departmentId) {
      throw new HttpError(403, 'This course is outside your department.', 'DEPARTMENT_SCOPE');
    }
    if ((offering.opensAt && new Date(offering.opensAt) > new Date()) ||
        (offering.closesAt && new Date(offering.closesAt) < new Date())) {
      throw new HttpError(409, 'Registration is not currently open.', 'REGISTRATION_CLOSED');
    }
    const current = await client.query(
      `SELECT count(*)::int AS count FROM enrollments WHERE section_id = $1 AND status = 'enrolled'`,
      [sectionId],
    );
    const enrollmentStatus = Number(current.rows[0].count) >= Number(offering.capacity) ? 'waitlisted' : 'enrolled';
    const inserted = await client.query(
      `INSERT INTO enrollments (student_user_id, section_id, status)
       VALUES ($1, $2, $3)
       ON CONFLICT (student_user_id, section_id) DO UPDATE
         SET status = EXCLUDED.status, enrolled_at = now()
       WHERE enrollments.status = 'dropped'
       RETURNING id, student_user_id AS "studentId", section_id AS "sectionId",
         status, enrolled_at AS "enrolledAt"`,
      [studentId, sectionId, enrollmentStatus],
    );
    if (!inserted.rowCount) throw new HttpError(409, 'You are already enrolled or waitlisted in this section.', 'ALREADY_ENROLLED');
    await client.query('COMMIT');
    res.status(201).json({ data: inserted.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.delete('/api/v1/students/me/registration/:enrollmentId', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `UPDATE enrollments e SET status = 'dropped'
     FROM course_sections cs JOIN terms t ON t.id = cs.term_id
     WHERE e.id = $1 AND e.student_user_id = $2 AND e.section_id = cs.id
       AND e.status IN ('enrolled', 'waitlisted')
       AND (t.registration_closes_at IS NULL OR t.registration_closes_at >= now())
     RETURNING e.id`,
    [req.params.enrollmentId, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(409, 'Enrollment not found or drop period is closed.', 'DROP_NOT_ALLOWED');
  res.status(204).end();
}));

app.patch('/api/v1/students/me', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({
    phone: z.string().trim().min(5).max(40).nullable().optional(),
    preferredLanguage: z.enum(['ar', 'en']).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const result = await pool.query(
    `UPDATE users SET phone = COALESCE($1, phone),
       preferred_language = COALESCE($2, preferred_language), updated_at = now()
     WHERE id = $3
     RETURNING id, username, email, full_name AS "fullName", phone, preferred_language AS "preferredLanguage"`,
    [body.phone ?? null, body.preferredLanguage ?? null, principalOf(req).id],
  );
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/students/me/tasks', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const status = z.enum(['pending', 'completed']).optional().parse(req.query.status);
  const dueFrom = z.string().datetime().optional().parse(req.query.dueFrom);
  const dueTo = z.string().datetime().optional().parse(req.query.dueTo);
  if (dueFrom && dueTo && new Date(dueTo) < new Date(dueFrom)) {
    throw new HttpError(400, 'dueTo must be on or after dueFrom.', 'VALIDATION_ERROR');
  }
  const result = await pool.query(
    `SELECT t.id, t.student_user_id AS "studentId", t.course_id AS "courseId",
            c.name_ar AS "courseName", t.title, t.description, t.due_at AS "dueAt",
            t.estimated_minutes AS "estimatedMinutes", t.priority, t.status,
            t.completed_at AS "completedAt", t.created_at AS "createdAt"
     FROM tasks t LEFT JOIN courses c ON c.id = t.course_id
     WHERE t.student_user_id = $1 AND ($2::task_status IS NULL OR t.status = $2)
       AND ($3::timestamptz IS NULL OR t.due_at >= $3)
       AND ($4::timestamptz IS NULL OR t.due_at <= $4)
     ORDER BY t.due_at LIMIT 250`,
    [principal.id, status ?? null, dueFrom ?? null, dueTo ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/tasks', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({
    courseId: z.string().uuid().nullable().optional(),
    title: z.string().trim().min(1).max(180),
    description: z.string().trim().max(5000).nullable().optional(),
    dueAt: z.string().datetime(),
    estimatedMinutes: z.number().int().positive().max(1440).default(30),
    priority: z.enum(['low', 'medium', 'high']).default('medium'),
  }).parse(req.body);
  const studentId = principalOf(req).id;
  if (body.courseId) {
    const enrolled = await pool.query(
      `SELECT 1 FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
       WHERE e.student_user_id = $1 AND cs.course_id = $2 AND e.status = 'enrolled' LIMIT 1`,
      [studentId, body.courseId],
    );
    if (!enrolled.rowCount) throw new HttpError(403, 'Tasks can only be linked to an enrolled course.', 'COURSE_NOT_ENROLLED');
  }
  const result = await pool.query(
    `INSERT INTO tasks (student_user_id, course_id, title, description, due_at, estimated_minutes, priority)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING id, student_user_id AS "studentId", course_id AS "courseId", title,
       description, due_at AS "dueAt", estimated_minutes AS "estimatedMinutes",
       priority, status, completed_at AS "completedAt", created_at AS "createdAt"`,
    [studentId, body.courseId ?? null, body.title, body.description ?? null, body.dueAt, body.estimatedMinutes, body.priority],
  );
  res.status(201).json({ data: result.rows[0] });
}));

app.patch('/api/v1/students/me/tasks/:taskId', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({
    courseId: z.string().uuid().nullable().optional(),
    title: z.string().trim().min(1).max(180).optional(),
    description: z.string().trim().max(5000).nullable().optional(),
    dueAt: z.string().datetime().optional(),
    estimatedMinutes: z.number().int().positive().max(1440).optional(),
    priority: z.enum(['low', 'medium', 'high']).optional(),
    status: z.enum(['pending', 'completed']).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const studentId = principalOf(req).id;
  if (body.courseId) {
    const enrolled = await pool.query(
      `SELECT 1 FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
       WHERE e.student_user_id = $1 AND cs.course_id = $2 AND e.status = 'enrolled' LIMIT 1`,
      [studentId, body.courseId],
    );
    if (!enrolled.rowCount) throw new HttpError(403, 'Tasks can only be linked to an enrolled course.', 'COURSE_NOT_ENROLLED');
  }
  const result = await pool.query(
    `UPDATE tasks SET
       course_id = CASE WHEN $1::boolean THEN $2::uuid ELSE course_id END,
       title = COALESCE($3, title),
       description = CASE WHEN $4::boolean THEN $5::text ELSE description END,
       due_at = COALESCE($6::timestamptz, due_at),
       estimated_minutes = COALESCE($7, estimated_minutes),
       priority = COALESCE($8, priority),
       status = COALESCE($9::task_status, status),
       completed_at = CASE WHEN $9 = 'completed' THEN COALESCE(completed_at, now())
                           WHEN $9 = 'pending' THEN NULL ELSE completed_at END,
       updated_at = now()
     WHERE id = $10 AND student_user_id = $11
     RETURNING id, student_user_id AS "studentId", course_id AS "courseId", title,
       description, due_at AS "dueAt", estimated_minutes AS "estimatedMinutes",
       priority, status, completed_at AS "completedAt", created_at AS "createdAt"`,
    [
      body.courseId !== undefined, body.courseId ?? null, body.title ?? null,
      body.description !== undefined, body.description ?? null, body.dueAt ?? null,
      body.estimatedMinutes ?? null, body.priority ?? null, body.status ?? null,
      req.params.taskId, studentId,
    ],
  );
  if (!result.rowCount) throw new HttpError(404, 'Task not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.delete('/api/v1/students/me/tasks/:taskId', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `DELETE FROM tasks WHERE id = $1 AND student_user_id = $2 RETURNING id`,
    [req.params.taskId, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Task not found.', 'NOT_FOUND');
  res.status(204).end();
}));

app.get('/api/v1/students/me/study-sessions', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT id, student_user_id AS "studentId", course_id AS "courseId", task_id AS "taskId",
            focus_minutes AS "focusMinutes", break_minutes AS "breakMinutes",
            started_at AS "startedAt", ended_at AS "endedAt", completed
     FROM study_sessions WHERE student_user_id = $1 ORDER BY started_at DESC LIMIT 200`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/study-sessions', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({
    courseId: z.string().uuid().nullable().optional(),
    taskId: z.string().uuid().nullable().optional(),
    focusMinutes: z.number().int().positive().max(1440),
    breakMinutes: z.number().int().min(0).max(1440).default(0),
    startedAt: z.string().datetime(),
    endedAt: z.string().datetime().nullable().optional(),
    completed: z.boolean().default(false),
  }).parse(req.body);
  const studentId = principalOf(req).id;
  if (body.courseId) {
    const enrolled = await pool.query(
      `SELECT 1 FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
       WHERE e.student_user_id = $1 AND cs.course_id = $2 AND e.status = 'enrolled' LIMIT 1`,
      [studentId, body.courseId],
    );
    if (!enrolled.rowCount) throw new HttpError(403, 'Study sessions can only use an enrolled course.', 'COURSE_NOT_ENROLLED');
  }
  if (body.taskId) {
    const task = await pool.query(
      `SELECT course_id AS "courseId" FROM tasks WHERE id = $1 AND student_user_id = $2`,
      [body.taskId, studentId],
    );
    if (!task.rowCount) throw new HttpError(404, 'Task not found.', 'NOT_FOUND');
    if (task.rows[0].courseId && body.courseId && task.rows[0].courseId !== body.courseId) {
      throw new HttpError(400, 'The task belongs to a different course.', 'TASK_COURSE_MISMATCH');
    }
  }
  if (body.endedAt && new Date(body.endedAt) < new Date(body.startedAt)) {
    throw new HttpError(400, 'Session end time cannot precede its start time.', 'VALIDATION_ERROR');
  }
  const result = await pool.query(
    `INSERT INTO study_sessions
       (student_user_id, course_id, task_id, focus_minutes, break_minutes, started_at, ended_at, completed)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id, student_user_id AS "studentId", course_id AS "courseId", task_id AS "taskId",
       focus_minutes AS "focusMinutes", break_minutes AS "breakMinutes",
       started_at AS "startedAt", ended_at AS "endedAt", completed`,
    [studentId, body.courseId ?? null, body.taskId ?? null, body.focusMinutes, body.breakMinutes, body.startedAt, body.endedAt ?? null, body.completed],
  );
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/doctors/me/courses', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const result = await pool.query(
    `SELECT cs.id AS "sectionId", cs.section_number AS "sectionNumber", cs.room,
            cs.schedule, c.id AS "courseId", c.code, c.name_ar AS "courseName",
            c.credit_hours AS "creditHours", cs.term_id AS "termId",
            (SELECT count(*)::int FROM enrollments e
             WHERE e.section_id = cs.id AND e.status = 'enrolled') AS "studentCount"
     FROM course_sections cs JOIN courses c ON c.id = cs.course_id
     WHERE cs.instructor_user_id = $1 AND ($2::uuid IS NULL OR cs.term_id = $2)
     ORDER BY c.name_ar, cs.section_number`,
    [principalOf(req).id, termId ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/doctors/me/sections/:sectionId/roster', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const doctorId = principalOf(req).id;
  const query = z.string().trim().max(120).optional().parse(req.query.q);
  const result = await pool.query(
    `SELECT u.id, u.full_name AS "fullName", sp.university_number AS "universityNumber",
            u.email
     FROM course_sections cs JOIN enrollments e ON e.section_id = cs.id
     JOIN users u ON u.id = e.student_user_id
     LEFT JOIN student_profiles sp ON sp.user_id = u.id
     WHERE cs.id = $1 AND cs.instructor_user_id = $2 AND e.status = 'enrolled'
       AND ($3::text IS NULL OR u.full_name ILIKE '%' || $3 || '%' OR sp.university_number ILIKE '%' || $3 || '%')
     ORDER BY u.full_name`,
    [req.params.sectionId, doctorId, query ?? null],
  );
  const section = await pool.query(
    `SELECT 1 FROM course_sections WHERE id = $1 AND instructor_user_id = $2`,
    [req.params.sectionId, doctorId],
  );
  if (!section.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
  res.json({ data: result.rows });
}));

app.get('/api/v1/doctors/me/sections/:sectionId/grades', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT u.id AS "studentId", u.full_name AS "studentName",
            g.id AS "gradeId", g.components, g.total, g.letter_grade AS "letterGrade",
            g.published_at AS "publishedAt",
            cs.midterm_weight AS "midtermWeight", cs.coursework_weight AS "courseworkWeight",
            cs.final_weight AS "finalWeight"
     FROM course_sections cs
     JOIN enrollments e ON e.section_id = cs.id AND e.status IN ('enrolled', 'completed')
     JOIN users u ON u.id = e.student_user_id
     LEFT JOIN grades g ON g.enrollment_id = e.id
     WHERE cs.id = $1 AND cs.instructor_user_id = $2
     ORDER BY u.full_name`,
    [req.params.sectionId, principalOf(req).id],
  );
  const section = await pool.query(
    `SELECT 1 FROM course_sections WHERE id = $1 AND instructor_user_id = $2`,
    [req.params.sectionId, principalOf(req).id],
  );
  if (!section.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
  res.json({ data: result.rows });
}));

app.put('/api/v1/doctors/me/sections/:sectionId/grades/:studentId', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    components: z.object({
      midterm: z.number().min(0).max(100).optional(),
      coursework: z.number().min(0).max(100).optional(),
      final: z.number().min(0).max(100).optional(),
    }).strict().refine((components) => Object.keys(components).length > 0),
  }).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const enrollment = await client.query(
      `SELECT e.id AS "enrollmentId", cs.midterm_weight AS "midtermWeight",
              cs.coursework_weight AS "courseworkWeight", cs.final_weight AS "finalWeight"
       FROM course_sections cs JOIN enrollments e ON e.section_id = cs.id
       WHERE cs.id = $1 AND cs.instructor_user_id = $2 AND e.student_user_id = $3
         AND e.status = 'enrolled'
       FOR UPDATE OF e`,
      [req.params.sectionId, principal.id, req.params.studentId],
    );
    if (!enrollment.rowCount) throw new HttpError(404, 'Assigned enrollment not found.', 'NOT_FOUND');
    const weights = enrollment.rows[0];
    const weightedValues = [
      body.components.midterm,
      body.components.coursework,
      body.components.final,
    ];
    const definedWeights = [weights.midtermWeight, weights.courseworkWeight, weights.finalWeight].map(Number);
    if (weightedValues.some((value, index) => value != null && value > definedWeights[index])) {
      throw new HttpError(400, 'A grade component exceeds its configured weight.', 'GRADE_OUT_OF_RANGE');
    }
    const total = weightedValues.every((value) => value != null)
      ? weightedValues.reduce((sum, value) => sum + (value ?? 0), 0)
      : null;
    const existing = await client.query(
      `SELECT id, components, total, published_at AS "publishedAt"
       FROM grades WHERE enrollment_id = $1 FOR UPDATE`,
      [enrollment.rows[0].enrollmentId],
    );
    if (existing.rows[0]?.publishedAt) {
      throw new HttpError(409, 'Published grades are locked.', 'GRADE_PUBLISHED');
    }
    const grade = await client.query(
      `INSERT INTO grades (enrollment_id, components, total, updated_by)
       VALUES ($1, $2::jsonb, $3, $4)
       ON CONFLICT (enrollment_id) DO UPDATE
         SET components = EXCLUDED.components, total = EXCLUDED.total,
             updated_by = EXCLUDED.updated_by, updated_at = now()
       RETURNING id, enrollment_id AS "enrollmentId", components, total, updated_at AS "updatedAt"`,
      [enrollment.rows[0].enrollmentId, JSON.stringify(body.components), total, principal.id],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'grade.update', 'grade', $2, $3::jsonb, $4::jsonb)`,
      [principal.id, grade.rows[0].id, existing.rows[0] ? JSON.stringify(existing.rows[0]) : null, JSON.stringify(grade.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: grade.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/doctors/me/sections/:sectionId/grades/publish', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const section = await client.query(
      `SELECT id FROM course_sections WHERE id = $1 AND instructor_user_id = $2 FOR UPDATE`,
      [req.params.sectionId, principal.id],
    );
    if (!section.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
    const incomplete = await client.query(
      `SELECT count(*)::int AS count FROM enrollments e
       LEFT JOIN grades g ON g.enrollment_id = e.id
       WHERE e.section_id = $1 AND e.status = 'enrolled'
         AND (g.id IS NULL OR g.total IS NULL)`,
      [req.params.sectionId],
    );
    if (incomplete.rows[0].count > 0) {
      throw new HttpError(409, 'Every enrolled student must have a complete grade before publication.', 'GRADES_INCOMPLETE');
    }
    await client.query(
      `UPDATE grades g SET published_at = COALESCE(g.published_at, now()), updated_at = now()
       FROM enrollments e WHERE e.id = g.enrollment_id AND e.section_id = $1 AND e.status = 'enrolled'`,
      [req.params.sectionId],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id)
       VALUES ($1, 'grades.publish', 'course_section', $2)`,
      [principal.id, req.params.sectionId],
    );
    await client.query('COMMIT');
    res.status(204).end();
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/doctors/me/sections/:sectionId/attendance', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT s.id, s.section_id AS "sectionId", s.held_at AS "heldAt", s.room,
            s.finalized_at AS "finalizedAt",
            json_agg(json_build_object('studentId', r.student_user_id, 'status', r.status))
              FILTER (WHERE r.student_user_id IS NOT NULL) AS records
     FROM course_sections cs JOIN attendance_sessions s ON s.section_id = cs.id
     LEFT JOIN attendance_records r ON r.session_id = s.id
     WHERE cs.id = $1 AND cs.instructor_user_id = $2
     GROUP BY s.id ORDER BY s.held_at DESC`,
    [req.params.sectionId, principalOf(req).id],
  );
  const section = await pool.query(
    `SELECT 1 FROM course_sections WHERE id = $1 AND instructor_user_id = $2`,
    [req.params.sectionId, principalOf(req).id],
  );
  if (!section.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/sections/:sectionId/attendance', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({ heldAt: z.string().datetime(), room: z.string().max(80).nullable().optional() }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO attendance_sessions (section_id, held_at, room, created_by)
     SELECT id, $3, $4, $2 FROM course_sections WHERE id = $1 AND instructor_user_id = $2
     RETURNING id, section_id AS "sectionId", held_at AS "heldAt", room, finalized_at AS "finalizedAt"`,
    [req.params.sectionId, principalOf(req).id, body.heldAt, body.room ?? null],
  );
  if (!result.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
  res.status(201).json({ data: result.rows[0] });
}));

app.put('/api/v1/doctors/me/attendance/:sessionId/records', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    records: z.array(z.object({
      studentId: z.string().uuid(),
      status: z.enum(['present', 'late', 'absent', 'excused']),
    })).min(1).max(500),
  }).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const session = await client.query(
      `SELECT s.id, s.section_id AS "sectionId"
       FROM attendance_sessions s JOIN course_sections cs ON cs.id = s.section_id
       WHERE s.id = $1 AND cs.instructor_user_id = $2 AND s.finalized_at IS NULL
       FOR UPDATE OF s`,
      [req.params.sessionId, principal.id],
    );
    if (!session.rowCount) throw new HttpError(404, 'Editable attendance session not found.', 'NOT_FOUND');
    const sectionId = session.rows[0].sectionId;
    for (const record of body.records) {
      const enrollment = await client.query(
        `SELECT 1 FROM enrollments WHERE section_id = $1 AND student_user_id = $2 AND status = 'enrolled'`,
        [sectionId, record.studentId],
      );
      if (!enrollment.rowCount) throw new HttpError(400, 'Attendance includes a student outside this section.', 'INVALID_ROSTER');
      await client.query(
        `INSERT INTO attendance_records (session_id, student_user_id, status)
         VALUES ($1, $2, $3)
         ON CONFLICT (session_id, student_user_id)
         DO UPDATE SET status = EXCLUDED.status, updated_at = now()`,
        [req.params.sessionId, record.studentId, record.status],
      );
    }
    const updated = await client.query(
      `SELECT student_user_id AS "studentId", status
       FROM attendance_records WHERE session_id = $1 ORDER BY student_user_id`,
      [req.params.sessionId],
    );
    await client.query('COMMIT');
    res.json({ data: updated.rows });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/doctors/me/attendance/:sessionId/finalize', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const session = await client.query(
      `SELECT s.id, s.section_id AS "sectionId" FROM attendance_sessions s
       JOIN course_sections cs ON cs.id = s.section_id
       WHERE s.id = $1 AND cs.instructor_user_id = $2 AND s.finalized_at IS NULL
       FOR UPDATE OF s`,
      [req.params.sessionId, principal.id],
    );
    if (!session.rowCount) throw new HttpError(404, 'Editable attendance session not found.', 'NOT_FOUND');
    const incomplete = await client.query(
      `SELECT count(*)::int AS count FROM enrollments e
       LEFT JOIN attendance_records r ON r.session_id = $1 AND r.student_user_id = e.student_user_id
       WHERE e.section_id = $2 AND e.status = 'enrolled' AND r.student_user_id IS NULL`,
      [req.params.sessionId, session.rows[0].sectionId],
    );
    if (incomplete.rows[0].count > 0) {
      throw new HttpError(409, 'Attendance must be recorded for every enrolled student before finalization.', 'ATTENDANCE_INCOMPLETE');
    }
    const result = await client.query(
      `UPDATE attendance_sessions SET finalized_at = now() WHERE id = $1
       RETURNING id, finalized_at AS "finalizedAt"`,
      [req.params.sessionId],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
       VALUES ($1, 'attendance.finalize', 'attendance_session', $2, $3::jsonb)`,
      [principal.id, req.params.sessionId, JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/students/me/feed', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const courseId = z.string().uuid().optional().parse(req.query.courseId);
  const result = await pool.query(
    `SELECT p.id, p.author_user_id AS "studentId", author.full_name AS "studentName",
            p.course_id AS "courseId", c.name_ar AS "courseName", p.title, p.content,
            p.type AS "postType", p.created_at AS "createdAt",
            count(DISTINCT comments.id)::int AS "commentsCount",
            count(DISTINCT reactions.user_id) FILTER (WHERE reactions.is_liked)::int AS "likesCount",
            COALESCE(bool_or(my_reaction.is_liked), false) AS "isLiked",
            COALESCE(bool_or(my_reaction.is_following), false) AS "isFollowed"
     FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
     JOIN feed_posts p ON p.course_id = cs.course_id
     JOIN courses c ON c.id = p.course_id JOIN users author ON author.id = p.author_user_id
     LEFT JOIN feed_comments comments ON comments.post_id = p.id
     LEFT JOIN feed_reactions reactions ON reactions.post_id = p.id
     LEFT JOIN feed_reactions my_reaction ON my_reaction.post_id = p.id AND my_reaction.user_id = $1
     WHERE e.student_user_id = $1 AND e.status = 'enrolled'
       AND ($2::uuid IS NULL OR p.course_id = $2)
     GROUP BY p.id, author.id, c.id ORDER BY p.created_at DESC LIMIT 100`,
    [principal.id, courseId ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/feed', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({
    courseId: z.string().uuid(),
    type: z.enum(['question', 'discussion', 'resource']),
    title: z.string().trim().max(180).nullable().optional(),
    content: z.string().trim().min(1).max(10000),
  }).parse(req.body);
  const studentId = principalOf(req).id;
  const result = await pool.query(
    `INSERT INTO feed_posts (author_user_id, course_id, type, title, content)
     SELECT $1, c.id, $3, $4, $5 FROM courses c
     WHERE c.id = $2 AND EXISTS (
       SELECT 1 FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
       WHERE e.student_user_id = $1 AND cs.course_id = c.id AND e.status = 'enrolled'
     )
     RETURNING id, author_user_id AS "studentId", course_id AS "courseId", type AS "postType",
       title, content, created_at AS "createdAt"`,
    [studentId, body.courseId, body.type, body.title ?? null, body.content],
  );
  if (!result.rowCount) throw new HttpError(403, 'You must be enrolled in the course to post.', 'COURSE_NOT_ENROLLED');
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/students/me/feed/:postId/comments', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT c.id, c.post_id AS "postId", c.author_user_id AS "studentId",
            u.full_name AS "studentName", c.content, c.created_at AS "createdAt"
     FROM feed_comments c JOIN users u ON u.id = c.author_user_id
     WHERE c.post_id = $1 AND EXISTS (
       SELECT 1 FROM feed_posts p JOIN course_sections cs ON cs.course_id = p.course_id
       JOIN enrollments e ON e.section_id = cs.id
       WHERE p.id = c.post_id AND e.student_user_id = $2 AND e.status = 'enrolled'
     ) ORDER BY c.created_at`,
    [req.params.postId, principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/feed/:postId/comments', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const { content } = z.object({ content: z.string().trim().min(1).max(5000) }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO feed_comments (post_id, author_user_id, content)
     SELECT p.id, $2, $3 FROM feed_posts p
     WHERE p.id = $1 AND EXISTS (
       SELECT 1 FROM course_sections cs JOIN enrollments e ON e.section_id = cs.id
       WHERE cs.course_id = p.course_id AND e.student_user_id = $2 AND e.status = 'enrolled'
     )
     RETURNING id, post_id AS "postId", author_user_id AS "studentId", content, created_at AS "createdAt"`,
    [req.params.postId, principalOf(req).id, content],
  );
  if (!result.rowCount) throw new HttpError(404, 'Enrolled-course post not found.', 'NOT_FOUND');
  res.status(201).json({ data: result.rows[0] });
}));

app.put('/api/v1/students/me/feed/:postId/reaction', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({ liked: z.boolean(), following: z.boolean() }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO feed_reactions (post_id, user_id, is_liked, is_following)
     SELECT p.id, $2, $3, $4 FROM feed_posts p
     WHERE p.id = $1 AND EXISTS (
       SELECT 1 FROM course_sections cs JOIN enrollments e ON e.section_id = cs.id
       WHERE cs.course_id = p.course_id AND e.student_user_id = $2 AND e.status = 'enrolled'
     )
     ON CONFLICT (post_id, user_id) DO UPDATE
       SET is_liked = EXCLUDED.is_liked, is_following = EXCLUDED.is_following
     RETURNING post_id AS "postId", is_liked AS liked, is_following AS following`,
    [req.params.postId, principalOf(req).id, body.liked, body.following],
  );
  if (!result.rowCount) throw new HttpError(404, 'Enrolled-course post not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/students/me/doctors', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT DISTINCT u.id AS "doctorId", u.full_name AS "doctorName",
            c.id AS "courseId", c.name_ar AS "courseName"
     FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
     JOIN courses c ON c.id = cs.course_id JOIN users u ON u.id = cs.instructor_user_id
     WHERE e.student_user_id = $1 AND e.status = 'enrolled'
     ORDER BY u.full_name, c.name_ar`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/conversations', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const body = z.object({ doctorId: z.string().uuid(), courseId: z.string().uuid() }).parse(req.body);
  const studentId = principalOf(req).id;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const assignment = await client.query(
      `SELECT 1 FROM course_sections cs
       JOIN enrollments e ON e.section_id = cs.id
       WHERE cs.course_id = $1 AND cs.instructor_user_id = $2
         AND e.student_user_id = $3 AND e.status = 'enrolled' LIMIT 1`,
      [body.courseId, body.doctorId, studentId],
    );
    if (!assignment.rowCount) throw new HttpError(403, 'A shared enrolled course is required to contact this doctor.', 'NOT_AUTHORIZED');
    const conv = await client.query(
      `SELECT c.id FROM conversations c
       JOIN conversation_participants student ON student.conversation_id = c.id AND student.user_id = $1
       JOIN conversation_participants doctor ON doctor.conversation_id = c.id AND doctor.user_id = $2
       WHERE c.course_id = $3 LIMIT 1`,
      [studentId, body.doctorId, body.courseId],
    );
    let conversationId: string;
    if (conv.rowCount) {
      conversationId = conv.rows[0].id;
    } else {
      const created = await client.query(
        `INSERT INTO conversations (course_id) VALUES ($1) RETURNING id`,
        [body.courseId],
      );
      conversationId = created.rows[0].id;
      await client.query(
        `INSERT INTO conversation_participants (conversation_id, user_id) VALUES ($1, $2), ($1, $3)`,
        [conversationId, studentId, body.doctorId],
      );
    }
    await client.query('COMMIT');
    res.status(conv.rowCount ? 200 : 201).json({ data: { id: conversationId, courseId: body.courseId, doctorId: body.doctorId } });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/students/me/conversations', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT c.id, c.course_id AS "courseId", course.name_ar AS "courseName",
            other.id AS "doctorId", other.full_name AS "doctorName",
            c.created_at AS "createdAt",
            (SELECT count(*)::int FROM chat_messages m
             WHERE m.conversation_id = c.id AND m.sender_user_id <> $1
               AND (mine.last_read_at IS NULL OR m.sent_at > mine.last_read_at)) AS "unreadCount"
     FROM conversations c
     JOIN conversation_participants mine ON mine.conversation_id = c.id AND mine.user_id = $1
     JOIN conversation_participants other_participant ON other_participant.conversation_id = c.id AND other_participant.user_id <> $1
     JOIN users other ON other.id = other_participant.user_id
     LEFT JOIN courses course ON course.id = c.course_id
     ORDER BY c.created_at DESC`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/conversations/:id/messages', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT m.id, m.conversation_id AS "conversationId", m.sender_user_id AS "senderUserId",
            u.role AS "senderRole", m.body, m.sent_at AS "sentAt"
     FROM chat_messages m JOIN users u ON u.id = m.sender_user_id
     JOIN conversation_participants p ON p.conversation_id = m.conversation_id AND p.user_id = $2
     WHERE m.conversation_id = $1 ORDER BY m.sent_at`,
    [req.params.id, principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/students/me/conversations/:id/messages', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const { body } = z.object({ body: z.string().trim().min(1).max(10000) }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO chat_messages (conversation_id, sender_user_id, body)
     SELECT p.conversation_id, p.user_id, $3 FROM conversation_participants p
     WHERE p.conversation_id = $1 AND p.user_id = $2
     RETURNING id, conversation_id AS "conversationId", sender_user_id AS "senderUserId",
       body, sent_at AS "sentAt"`,
    [req.params.id, principalOf(req).id, body],
  );
  if (!result.rowCount) throw new HttpError(404, 'Conversation not found.', 'NOT_FOUND');
  res.status(201).json({ data: result.rows[0] });
}));

app.patch('/api/v1/students/me/conversations/:id/read', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `UPDATE conversation_participants SET last_read_at = now()
     WHERE conversation_id = $1 AND user_id = $2 RETURNING last_read_at AS "lastReadAt"`,
    [req.params.id, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Conversation not found.', 'NOT_FOUND');
  res.status(204).end();
}));

app.get('/api/v1/doctors/me/conversations', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT c.id, c.course_id AS "courseId", course.name_ar AS "courseName",
            student.id AS "studentId", student.full_name AS "studentName",
            c.created_at AS "createdAt"
     FROM conversations c
     JOIN conversation_participants mine ON mine.conversation_id = c.id AND mine.user_id = $1
     JOIN conversation_participants other_participant ON other_participant.conversation_id = c.id AND other_participant.user_id <> $1
     JOIN users student ON student.id = other_participant.user_id
     LEFT JOIN courses course ON course.id = c.course_id
     WHERE EXISTS (SELECT 1 FROM course_sections cs
                   WHERE cs.course_id = c.course_id AND cs.instructor_user_id = $1)
     ORDER BY c.created_at DESC`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/doctors/me/conversations/:id/messages', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT m.id, m.conversation_id AS "conversationId", m.sender_user_id AS "senderUserId",
            u.role AS "senderRole", m.body, m.sent_at AS "sentAt"
     FROM chat_messages m JOIN users u ON u.id = m.sender_user_id
     JOIN conversation_participants p ON p.conversation_id = m.conversation_id AND p.user_id = $2
     JOIN conversations c ON c.id = m.conversation_id
     WHERE m.conversation_id = $1 AND EXISTS (
       SELECT 1 FROM course_sections cs
       WHERE cs.course_id = c.course_id AND cs.instructor_user_id = $2
     ) ORDER BY m.sent_at`,
    [req.params.id, principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/conversations/:id/messages', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const { body } = z.object({ body: z.string().trim().min(1).max(10000) }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO chat_messages (conversation_id, sender_user_id, body)
     SELECT p.conversation_id, p.user_id, $3 FROM conversation_participants p
     JOIN conversations c ON c.id = p.conversation_id
     WHERE p.conversation_id = $1 AND p.user_id = $2 AND EXISTS (
       SELECT 1 FROM course_sections cs
       WHERE cs.course_id = c.course_id AND cs.instructor_user_id = $2
     )
     RETURNING id, conversation_id AS "conversationId", sender_user_id AS "senderUserId",
       body, sent_at AS "sentAt"`,
    [req.params.id, principalOf(req).id, body],
  );
  if (!result.rowCount) throw new HttpError(404, 'Conversation not found.', 'NOT_FOUND');
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/requests', requireAuth, asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const status = z.enum(['new', 'in_review', 'waiting_on_user', 'completed', 'rejected', 'cancelled']).optional().parse(req.query.status);
  const departmentId = z.string().uuid().optional().parse(req.query.departmentId);
  const query = z.string().trim().max(120).optional().parse(req.query.q);
  const result = await pool.query(
    `SELECT r.id, r.reference, r.requester_user_id AS "requesterUserId",
       r.department_id AS "departmentId", r.category, r.title, r.description,
       r.priority, r.status, r.created_at AS "createdAt"
     FROM service_requests r WHERE
       ($1::user_role = 'admin' OR r.requester_user_id = $2 OR
        ($1::user_role = 'staff' AND r.department_id =
          (SELECT department_id FROM staff_profiles WHERE user_id = $2
            AND has_staff_permission($2, 'request.review'))))
       AND ($3::request_status IS NULL OR r.status = $3)
       AND ($4::uuid IS NULL OR r.department_id = $4)
       AND ($5::text IS NULL OR r.reference ILIKE '%' || $5 || '%' OR
         r.title ILIKE '%' || $5 || '%' OR r.category ILIKE '%' || $5 || '%')
     ORDER BY r.created_at DESC LIMIT 200`,
    [principal.role, principal.id, status ?? null, departmentId ?? null, query ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/requests', requireAuth, requireRoles('student', 'doctor', 'staff', 'admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    departmentId: z.string().uuid().optional(),
    category: z.string().trim().min(1).max(80),
    title: z.string().trim().min(3).max(180),
    description: z.string().trim().min(5).max(10000),
    priority: z.enum(['low', 'normal', 'high', 'urgent']).default('normal'),
  }).parse(req.body);
  const principal = principalOf(req);
  if (body.departmentId && principal.role !== 'admin') {
    const scope = await pool.query(
      `SELECT CASE $1::user_role
         WHEN 'student' THEN (SELECT department_id FROM student_profiles WHERE user_id = $2)
         WHEN 'doctor' THEN (SELECT department_id FROM doctor_profiles WHERE user_id = $2)
         WHEN 'staff' THEN (SELECT department_id FROM staff_profiles WHERE user_id = $2)
       END AS "departmentId"`,
      [principal.role, principal.id],
    );
    if (scope.rows[0]?.departmentId !== body.departmentId) {
      throw new HttpError(403, 'Requests can only be submitted to your department.', 'DEPARTMENT_SCOPE');
    }
  }
  const result = await pool.query(
    `INSERT INTO service_requests
       (requester_user_id, department_id, category, title, description, priority)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, reference, category, title, description, priority, status, created_at AS "createdAt"`,
    [principal.id, body.departmentId ?? null, body.category, body.title, body.description, body.priority],
  );
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/requests/:id', requireAuth, asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const result = await pool.query(
    `SELECT r.id, r.reference, r.requester_user_id AS "requesterUserId",
            requester.full_name AS "requesterName", requester.role AS "requesterRole",
            r.department_id AS "departmentId", d.name_ar AS department,
            r.assigned_user_id AS "assignedUserId", r.category, r.title, r.description,
            r.priority, r.status, r.admin_note AS "adminNote", r.created_at AS "createdAt",
            r.updated_at AS "updatedAt",
            COALESCE((SELECT json_agg(json_build_object(
              'id', event.id, 'oldStatus', event.old_status, 'newStatus', event.new_status,
              'note', event.note, 'actorUserId', event.actor_user_id, 'createdAt', event.created_at
            ) ORDER BY event.created_at) FROM service_request_events event
              WHERE event.request_id = r.id), '[]'::json) AS timeline,
            COALESCE((SELECT json_agg(json_build_object(
              'id', a.id, 'fileName', a.file_name, 'contentType', a.content_type,
              'fileSizeBytes', a.file_size_bytes
            )) FROM service_request_attachments a WHERE a.request_id = r.id), '[]'::json) AS attachments
     FROM service_requests r JOIN users requester ON requester.id = r.requester_user_id
     LEFT JOIN departments d ON d.id = r.department_id
     WHERE r.id = $1 AND (
       r.requester_user_id = $2 OR $3::user_role = 'admin' OR
       ($3::user_role = 'staff' AND r.department_id = (
         SELECT department_id FROM staff_profiles WHERE user_id = $2
           AND has_staff_permission($3, 'request.review')
       ))
     )`,
    [req.params.id, principal.id, principal.role],
  );
  if (!result.rowCount) throw new HttpError(404, 'Request not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.post('/api/v1/admin/requests/:id/assign', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const { staffUserId } = z.object({ staffUserId: z.string().uuid() }).parse(req.body);
  const principal = principalOf(req);
  const result = await pool.query(
    `UPDATE service_requests r SET assigned_user_id = $1, updated_at = now()
     WHERE r.id = $2 AND (
       $3::user_role = 'admin' OR r.department_id = (
        SELECT department_id FROM staff_profiles WHERE user_id = $4
          AND has_staff_permission($4, 'request.assign')
       )
     ) AND EXISTS (
       SELECT 1 FROM users u
       JOIN staff_profiles sp ON sp.user_id = u.id
       WHERE u.id = $1 AND u.role = 'staff' AND u.status = 'active'
         AND (sp.department_id = r.department_id OR $3::user_role = 'admin')
     )
     RETURNING r.id, r.reference, r.assigned_user_id AS "assignedUserId", r.updated_at AS "updatedAt"`,
    [staffUserId, req.params.id, principal.role, principal.id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Request or eligible staff account not found.', 'NOT_FOUND');
  await pool.query(
    `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
     VALUES ($1, 'request.assign', 'service_request', $2, $3::jsonb)`,
    [principal.id, req.params.id, JSON.stringify(result.rows[0])],
  );
  res.json({ data: result.rows[0] });
}));

app.post('/api/v1/requests/:id/attachments', requireAuth, uploadLimiter, receiveSingleFile, asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const requestId = z.string().uuid().parse(req.params.id);
  const visible = await pool.query(
    `SELECT 1 FROM service_requests r WHERE r.id = $1 AND (
       r.requester_user_id = $2 OR $3::user_role = 'admin' OR
       ($3::user_role = 'staff' AND r.department_id =
         (SELECT department_id FROM staff_profiles WHERE user_id = $2
           AND has_staff_permission($2, 'request.review'))))`,
    [requestId, principal.id, principal.role],
  );
  if (!visible.rowCount) throw new HttpError(404, 'Request not found.', 'NOT_FOUND');
  const file = req.file;
  if (!file) throw new HttpError(400, 'A multipart file field named "file" is required.', 'FILE_REQUIRED');
  validateFileSignature(file);

  const uploaded = await uploadFile(principal.id, file.originalname, file.mimetype, file.buffer);
  try {
    const attachment = await pool.query(
      `INSERT INTO service_request_attachments
         (request_id, storage_key, file_name, content_type, file_size_bytes, uploaded_by)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, request_id AS "requestId", file_name AS "fileName",
         content_type AS "contentType", file_size_bytes::int AS "fileSizeBytes", created_at AS "createdAt"`,
      [requestId, uploaded.storageKey, file.originalname, file.mimetype, file.size, principal.id],
    );
    res.status(201).json({ data: { ...attachment.rows[0], ...uploaded, fileSizeBytes: file.size } });
  } catch (error) {
    try {
      await deleteUploadedFile(uploaded.storageKey);
    } catch (cleanupError) {
      console.error('Failed to clean up an unlinked request attachment:', cleanupError);
    }
    throw error;
  }
}));

app.get('/api/v1/requests/:id/attachments/:attachmentId/download', requireAuth, asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const result = await pool.query(
    `SELECT a.storage_key AS "storageKey"
     FROM service_request_attachments a
     JOIN service_requests r ON r.id = a.request_id
     WHERE a.id = $1 AND r.id = $2 AND (
       r.requester_user_id = $3 OR $4::user_role = 'admin' OR
       ($4::user_role = 'staff' AND r.department_id = (
         SELECT department_id FROM staff_profiles WHERE user_id = $3
           AND has_staff_permission($3, 'request.review')
       ))
     )`,
    [
      z.string().uuid().parse(req.params.attachmentId),
      z.string().uuid().parse(req.params.id),
      principal.id,
      principal.role,
    ],
  );
  if (!result.rowCount) throw new HttpError(404, 'Attachment not found.', 'NOT_FOUND');
  const download = await createDownloadUrl(result.rows[0].storageKey);
  res.json({ data: download });
}));

app.patch('/api/v1/admin/requests/:id/status', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const { status, note } = z.object({
    status: z.enum(['in_review', 'waiting_on_user', 'completed', 'rejected']),
    note: z.string().trim().max(2000).optional(),
  }).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const principal = principalOf(req);
    const before = await client.query(
      `SELECT r.id, r.status
       FROM service_requests r
       WHERE r.id = $1
         AND ($2::user_role = 'admin' OR r.department_id = (
           SELECT department_id FROM staff_profiles WHERE user_id = $3
             AND has_staff_permission($3, 'request.review')
         ))
       FOR UPDATE`,
      [req.params.id, principal.role, principal.id],
    );
    if (!before.rowCount) throw new HttpError(404, 'Request not found.', 'NOT_FOUND');
    const allowed: Record<string, string[]> = {
      new: ['in_review', 'rejected'],
      in_review: ['waiting_on_user', 'completed', 'rejected'],
      waiting_on_user: ['in_review', 'completed', 'rejected'],
      completed: [],
      rejected: [],
      cancelled: [],
    };
    const currentStatus = before.rows[0].status as string;
    if (!allowed[currentStatus]?.includes(status)) {
      throw new HttpError(409, 'This request status transition is not allowed.', 'INVALID_STATUS_TRANSITION');
    }
    const after = await client.query(
      `UPDATE service_requests SET status = $1, admin_note = COALESCE($2, admin_note), updated_at = now()
       WHERE id = $3
       RETURNING id, reference, status, admin_note AS "adminNote", updated_at AS "updatedAt"`,
      [status, note ?? null, req.params.id],
    );
    await client.query(
      `INSERT INTO service_request_events
         (request_id, actor_user_id, old_status, new_status, note)
       VALUES ($1, $2, $3, $4, $5)`,
      [req.params.id, principal.id, currentStatus, status, note ?? ''],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'request.status.update', 'service_request', $2, $3::jsonb, $4::jsonb)`,
      [principalOf(req).id, req.params.id, JSON.stringify(before.rows[0]), JSON.stringify(after.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: after.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/guest/inquiries', loginLimiter, asyncRoute(async (req, res) => {
  const body = z.object({
    name: z.string().trim().min(2).max(160),
    email: z.string().trim().email().max(254).optional(),
    phone: z.string().trim().min(5).max(40).optional(),
    category: z.string().trim().min(1).max(80),
    subject: z.string().trim().min(3).max(180),
    message: z.string().trim().min(5).max(10000),
  }).refine((value) => Boolean(value.email || value.phone), {
    message: 'Provide either an email address or a phone number.',
    path: ['email'],
  }).parse(req.body);
  const trackingSecret = randomBytes(32).toString('base64url');
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const inquiry = await client.query(
      `INSERT INTO guest_inquiries
         (guest_name, email, phone, category, subject, message, tracking_secret_hash)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, reference, status, created_at AS "createdAt"`,
      [body.name, body.email ?? null, body.phone ?? null, body.category, body.subject, body.message, hashToken(trackingSecret)],
    );
    await client.query(
      `INSERT INTO inquiry_messages (inquiry_id, sender_label, is_staff, body)
       VALUES ($1, $2, false, $3)`,
      [inquiry.rows[0].id, body.name, body.message],
    );
    await client.query('COMMIT');
    res.status(201).json({
      data: { ...inquiry.rows[0], trackingSecret },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.post('/api/v1/guest/inquiries/track', loginLimiter, asyncRoute(async (req, res) => {
  const { reference, trackingSecret } = z.object({
    reference: z.string().trim().min(8).max(40),
    trackingSecret: z.string().min(32).max(100),
  }).parse(req.body);
  const result = await pool.query(
    `SELECT id, reference, guest_name AS "guestName", category, subject, status,
            created_at AS "createdAt", updated_at AS "updatedAt"
     FROM guest_inquiries WHERE reference = $1 AND tracking_secret_hash = $2`,
    [reference, hashToken(trackingSecret)],
  );
  if (!result.rowCount) throw new HttpError(404, 'Inquiry not found.', 'NOT_FOUND');
  const messages = await pool.query(
    `SELECT sender_label AS "senderLabel", is_staff AS "isStaff", body,
            created_at AS "createdAt"
     FROM inquiry_messages WHERE inquiry_id = $1 ORDER BY created_at`,
    [result.rows[0].id],
  );
  res.json({ data: { ...result.rows[0], messages: messages.rows } });
}));

app.patch('/api/v1/admin/inquiries/:id/status', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const { status } = z.object({
    status: z.enum(['in_review', 'completed', 'rejected']),
  }).parse(req.body);
  const principal = principalOf(req);
  const result = await pool.query(
    `UPDATE guest_inquiries i SET status = $1, updated_at = now()
     WHERE i.id = $2 AND i.status IN ('new', 'in_review', 'waiting_on_user')
       AND ($3::user_role = 'admin' OR i.assigned_department_id = (
       SELECT department_id FROM staff_profiles WHERE user_id = $3
         AND has_staff_permission($3, 'inquiry.review')
     ))
     RETURNING i.id, i.reference, i.status, i.updated_at AS "updatedAt"`,
    [status, req.params.id, principal.id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Inquiry not found.', 'NOT_FOUND');
  await pool.query(
    `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
     VALUES ($1, 'inquiry.status.update', 'guest_inquiry', $2, $3::jsonb)`,
    [principal.id, req.params.id, JSON.stringify(result.rows[0])],
  );
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/admin/inquiries', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const status = z.enum(['new', 'in_review', 'waiting_on_user', 'completed', 'rejected', 'cancelled']).optional().parse(req.query.status);
  const departmentId = z.string().uuid().optional().parse(req.query.departmentId);
  const result = await pool.query(
    `SELECT id, reference, guest_name AS "guestName", email, phone, category, subject,
            message, status, created_at AS "createdAt"
     FROM guest_inquiries
     WHERE ($1::user_role = 'admin' OR assigned_department_id = (
       SELECT department_id FROM staff_profiles WHERE user_id = $2
         AND has_staff_permission($2, 'inquiry.review')
     ))
       AND ($3::request_status IS NULL OR status = $3)
       AND ($4::uuid IS NULL OR assigned_department_id = $4)
     ORDER BY created_at DESC LIMIT 200`,
    [principal.role, principal.id, status ?? null, departmentId ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/admin/inquiries/:id/messages', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const { body } = z.object({ body: z.string().trim().min(1).max(10000) }).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const principal = principalOf(req);
    const inquiry = await client.query(
      `SELECT id FROM guest_inquiries
       WHERE id = $1 AND status NOT IN ('completed', 'rejected', 'cancelled')
         AND ($2::user_role = 'admin' OR assigned_department_id = (
           SELECT department_id FROM staff_profiles WHERE user_id = $3
             AND has_staff_permission($3, 'inquiry.review')
         ))
       FOR UPDATE`,
      [req.params.id, principal.role, principal.id],
    );
    if (!inquiry.rowCount) throw new HttpError(404, 'Open inquiry not found.', 'NOT_FOUND');
    const message = await client.query(
      `INSERT INTO inquiry_messages (inquiry_id, sender_user_id, sender_label, is_staff, body)
       VALUES ($1, $2, $3, true, $4)
       RETURNING id, inquiry_id AS "inquiryId", sender_label AS "senderLabel", body, created_at AS "createdAt"`,
      [req.params.id, principal.id, principal.fullName, body],
    );
    await client.query(`UPDATE guest_inquiries SET status = 'in_review', updated_at = now() WHERE id = $1`, [req.params.id]);
    await client.query('COMMIT');
    res.status(201).json({ data: message.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/notifications', requireAuth, asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT id, type, title, message, data, read_at AS "readAt", created_at AS "createdAt"
     FROM notifications WHERE recipient_user_id = $1 ORDER BY created_at DESC LIMIT 200`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/doctors/me/notifications', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT id, type, title, message, data, read_at AS "readAt", created_at AS "createdAt"
     FROM notifications WHERE recipient_user_id = $1 ORDER BY created_at DESC LIMIT 200`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/students/me/notifications', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const unreadOnly = z.enum(['true', 'false']).optional().parse(req.query.unreadOnly) === 'true';
  const result = await pool.query(
    `SELECT id, type, title, message, data, read_at AS "readAt", created_at AS "createdAt"
     FROM notifications WHERE recipient_user_id = $1 AND ($2::boolean = false OR read_at IS NULL)
     ORDER BY created_at DESC LIMIT 200`,
    [principalOf(req).id, unreadOnly],
  );
  res.json({ data: result.rows });
}));

app.patch('/api/v1/notifications/:id/read', requireAuth, asyncRoute(async (req, res) => {
  const result = await pool.query(
    `UPDATE notifications SET read_at = COALESCE(read_at, now())
     WHERE id = $1 AND recipient_user_id = $2
     RETURNING id, read_at AS "readAt"`,
    [req.params.id, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Notification not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.patch('/api/v1/students/me/notifications/:notificationId/read', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `UPDATE notifications SET read_at = COALESCE(read_at, now())
     WHERE id = $1 AND recipient_user_id = $2 RETURNING id, read_at AS "readAt"`,
    [req.params.notificationId, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Notification not found.', 'NOT_FOUND');
  res.status(204).end();
}));

app.post('/api/v1/notifications/read-all', requireAuth, asyncRoute(async (req, res) => {
  const result = await pool.query(
    `UPDATE notifications SET read_at = COALESCE(read_at, now())
     WHERE recipient_user_id = $1 AND read_at IS NULL`,
    [principalOf(req).id],
  );
  res.json({ data: { updated: result.rowCount ?? 0 } });
}));

app.get('/api/v1/admin/users', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const query = z.string().trim().max(120).optional().parse(req.query.q);
  const role = roleSchema.optional().parse(req.query.role);
  const status = z.enum(['active', 'disabled', 'locked']).optional().parse(req.query.status);
  const result = await pool.query(
    `SELECT id, username, email, role, status, full_name AS "fullName", created_at AS "createdAt"
     FROM users
     WHERE ($1::text IS NULL OR username ILIKE '%' || $1 || '%' OR email ILIKE '%' || $1 || '%' OR full_name ILIKE '%' || $1 || '%')
       AND ($2::user_role IS NULL OR role = $2)
       AND ($3::account_status IS NULL OR status = $3)
     ORDER BY created_at DESC LIMIT 100`,
    [query ?? null, role ?? null, status ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/admin/users', requireAuth, requireRoles('admin'), asyncRoute(async (req) => {
  z.object({
    username: z.string().trim().min(3).max(120),
    email: z.string().trim().email().max(254),
    fullName: z.string().trim().min(2).max(160),
    role: roleSchema,
    phone: z.string().trim().min(5).max(40).optional(),
  }).parse(req.body);
  throw new HttpError(503, 'Temporary credential delivery is not configured.', 'EMAIL_NOT_CONFIGURED');
}));

app.post('/api/v1/admin/reports', requireAuth, requireRoles('admin'), asyncRoute(async (req) => {
  z.object({
    reportType: z.string().trim().min(1).max(80),
    filters: z.record(z.string(), z.unknown()).default({}),
  }).parse(req.body);
  throw new HttpError(503, 'Report generation and object storage are not configured.', 'REPORTS_NOT_CONFIGURED');
}));
app.get('/api/v1/admin/reports/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req) => {
  z.string().uuid().parse(req.params.id);
  throw new HttpError(503, 'Report generation and object storage are not configured.', 'REPORTS_NOT_CONFIGURED');
}));

app.get('/api/v1/admin/requests', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const status = z.enum(['new', 'in_review', 'waiting_on_user', 'completed', 'rejected', 'cancelled']).optional().parse(req.query.status);
  const departmentId = z.string().uuid().optional().parse(req.query.departmentId);
  const query = z.string().trim().max(120).optional().parse(req.query.q);
  const result = await pool.query(
    `SELECT id, reference, requester_user_id AS "requesterUserId", department_id AS "departmentId",
            category, title, description, priority, status, created_at AS "createdAt"
     FROM service_requests
     WHERE ($1::request_status IS NULL OR status = $1)
       AND ($2::user_role = 'admin' OR department_id = (
         SELECT department_id FROM staff_profiles WHERE user_id = $3
           AND has_staff_permission($3, 'request.review')
       ))
       AND ($4::uuid IS NULL OR department_id = $4)
       AND ($5::text IS NULL OR reference ILIKE '%' || $5 || '%' OR title ILIKE '%' || $5 || '%')
     ORDER BY created_at DESC LIMIT 200`,
    [status ?? null, principal.role, principal.id, departmentId ?? null, query ?? null],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/doctors/me', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT u.id, u.username, u.email, u.full_name AS "fullName", u.phone,
            dp.faculty_id AS "facultyId", dp.department_id AS "departmentId",
            dp.academic_rank AS "academicRank", dp.office, dp.office_hours AS "officeHours"
     FROM users u JOIN doctor_profiles dp ON dp.user_id = u.id WHERE u.id = $1`,
    [principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Doctor profile not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.patch('/api/v1/doctors/me', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    phone: z.string().trim().min(5).max(40).nullable().optional(),
    office: z.string().trim().max(120).nullable().optional(),
    officeHours: z.array(z.object({
      day: z.enum(['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']),
      start: z.string().regex(/^\d{2}:\d{2}$/),
      end: z.string().regex(/^\d{2}:\d{2}$/),
    }).strict()).max(14).refine((hours) => hours.every((slot) => slot.end > slot.start), {
      message: 'Office-hour end times must follow their start times.',
    }).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    if (body.phone !== undefined) {
      await client.query('UPDATE users SET phone = $1, updated_at = now() WHERE id = $2', [body.phone, principal.id]);
    }
    if (body.office !== undefined || body.officeHours !== undefined) {
      const updated = await client.query(
        `UPDATE doctor_profiles SET office = CASE WHEN $1::boolean THEN $2 ELSE office END,
           office_hours = CASE WHEN $3::boolean THEN $4::jsonb ELSE office_hours END
         WHERE user_id = $5`,
        [body.office !== undefined, body.office ?? null, body.officeHours !== undefined,
          body.officeHours ? JSON.stringify(body.officeHours) : null, principal.id],
      );
      if (!updated.rowCount) throw new HttpError(404, 'Doctor profile not found.', 'NOT_FOUND');
    }
    const result = await client.query(
      `SELECT u.id, u.username, u.email, u.full_name AS "fullName", u.phone,
              dp.faculty_id AS "facultyId", dp.department_id AS "departmentId",
              dp.academic_rank AS "academicRank", dp.office, dp.office_hours AS "officeHours"
       FROM users u JOIN doctor_profiles dp ON dp.user_id = u.id WHERE u.id = $1`,
      [principal.id],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/doctors/me/assignments', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const result = await pool.query(
    `SELECT a.id, a.section_id AS "sectionId", c.id AS "courseId", c.code,
            c.name_ar AS "courseName", a.title, a.description, a.due_at AS "dueAt",
            a.max_score AS "maxScore", a.created_at AS "createdAt"
     FROM assignments a JOIN course_sections cs ON cs.id = a.section_id
     JOIN courses c ON c.id = cs.course_id
     WHERE cs.instructor_user_id = $1 ORDER BY a.due_at`,
    [principal.id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/assignments', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    sectionId: z.string().uuid(),
    title: z.string().trim().min(2).max(180),
    description: z.string().trim().max(10000).default(''),
    dueAt: z.string().datetime(),
    maxScore: z.number().positive().max(10000),
  }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO assignments (section_id, created_by, title, description, due_at, max_score)
     SELECT cs.id, $2, $3, $4, $5, $6 FROM course_sections cs
     WHERE cs.id = $1 AND cs.instructor_user_id = $2
     RETURNING id, section_id AS "sectionId", title, description, due_at AS "dueAt",
       max_score AS "maxScore", created_at AS "createdAt"`,
    [body.sectionId, principalOf(req).id, body.title, body.description, body.dueAt, body.maxScore],
  );
  if (!result.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/doctors/me/assignments/:id/submissions', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT s.id, s.assignment_id AS "assignmentId", s.student_user_id AS "studentId",
            u.full_name AS "studentName", s.submitted_at AS "submittedAt", s.score,
            s.feedback, a.max_score AS "maxScore"
     FROM assignment_submissions s JOIN assignments a ON a.id = s.assignment_id
     JOIN course_sections cs ON cs.id = a.section_id
     JOIN users u ON u.id = s.student_user_id
     WHERE a.id = $1 AND cs.instructor_user_id = $2 ORDER BY s.submitted_at`,
    [req.params.id, principalOf(req).id],
  );
  const assignment = await pool.query(
    `SELECT 1 FROM assignments a JOIN course_sections cs ON cs.id = a.section_id
     WHERE a.id = $1 AND cs.instructor_user_id = $2`,
    [req.params.id, principalOf(req).id],
  );
  if (!assignment.rowCount) throw new HttpError(404, 'Assignment not found.', 'NOT_FOUND');
  res.json({ data: result.rows });
}));

app.patch('/api/v1/doctors/me/submissions/:id', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    score: z.number().min(0).optional(),
    feedback: z.string().trim().max(5000).nullable().optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const result = await pool.query(
    `UPDATE assignment_submissions s SET score = COALESCE($1, s.score),
       feedback = CASE WHEN $2::boolean THEN $3 ELSE s.feedback END
     FROM assignments a JOIN course_sections cs ON cs.id = a.section_id
     WHERE s.id = $4 AND s.assignment_id = a.id AND cs.instructor_user_id = $5
       AND ($1::numeric IS NULL OR $1 <= a.max_score)
     RETURNING s.id, s.assignment_id AS "assignmentId", s.student_user_id AS "studentId",
       s.score, s.feedback, s.submitted_at AS "submittedAt"`,
    [body.score ?? null, body.feedback !== undefined, body.feedback ?? null, req.params.id, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Submission not found or score exceeds the assignment maximum.', 'NOT_FOUND');
  await pool.query(
    `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
     VALUES ($1, 'assignment.submission.grade', 'assignment_submission', $2, $3::jsonb)`,
    [principalOf(req).id, req.params.id, JSON.stringify(result.rows[0])],
  );
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/doctors/me/questions', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const courseId = z.string().uuid().optional().parse(req.query.courseId);
  const status = z.enum(['answered', 'unanswered']).optional().parse(req.query.status);
  const result = await pool.query(
    `SELECT q.id, q.section_id AS "sectionId", cs.course_id AS "courseId",
            c.code AS "courseCode", q.student_user_id AS "studentId", u.full_name AS "studentName",
            q.body, q.answer, q.answered_at AS "answeredAt", q.created_at AS "createdAt"
     FROM student_questions q JOIN course_sections cs ON cs.id = q.section_id
     JOIN courses c ON c.id = cs.course_id JOIN users u ON u.id = q.student_user_id
     WHERE cs.instructor_user_id = $1 AND ($2::uuid IS NULL OR cs.course_id = $2)
       AND ($3::text IS NULL OR ($3 = 'answered' AND q.answered_at IS NOT NULL)
          OR ($3 = 'unanswered' AND q.answered_at IS NULL))
     ORDER BY q.created_at DESC LIMIT 200`,
    [principalOf(req).id, courseId ?? null, status ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/questions/:id/answers', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const { body } = z.object({ body: z.string().trim().min(1).max(5000) }).parse(req.body);
  const result = await pool.query(
    `UPDATE student_questions q SET answer = $1, answered_by = $2, answered_at = now()
     FROM course_sections cs
     WHERE q.id = $3 AND q.section_id = cs.id AND cs.instructor_user_id = $2
     RETURNING q.id, q.section_id AS "sectionId", q.student_user_id AS "studentId",
       q.body, q.answer, q.answered_at AS "answeredAt"`,
    [body, principalOf(req).id, req.params.id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Question not found in an assigned section.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/doctors/me/exam-schedules', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT es.id, es.section_id AS "sectionId", c.code AS "courseCode",
            c.name_ar AS "courseName", es.exam_type AS "examType", es.starts_at AS "startsAt",
            es.ends_at AS "endsAt", es.room, es.status
     FROM exam_schedules es JOIN course_sections cs ON cs.id = es.section_id
     JOIN courses c ON c.id = cs.course_id
     WHERE cs.instructor_user_id = $1 ORDER BY es.starts_at`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/exam-schedules', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    sectionId: z.string().uuid(), examType: z.string().trim().min(1).max(80),
    startsAt: z.string().datetime(), endsAt: z.string().datetime(),
    room: z.string().trim().max(80).nullable().optional(),
    status: z.enum(['draft', 'scheduled', 'published']).default('draft'),
  }).refine((value) => new Date(value.endsAt) > new Date(value.startsAt), {
    message: 'Exam end time must be after its start time.',
    path: ['endsAt'],
  }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO exam_schedules (section_id, exam_type, starts_at, ends_at, room, status, created_by)
     SELECT cs.id, $3, $4, $5, $6, $7, $2 FROM course_sections cs
     WHERE cs.id = $1 AND cs.instructor_user_id = $2
     RETURNING id, section_id AS "sectionId", exam_type AS "examType",
       starts_at AS "startsAt", ends_at AS "endsAt", room, status`,
    [body.sectionId, principalOf(req).id, body.examType, body.startsAt, body.endsAt, body.room ?? null, body.status],
  );
  if (!result.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
  res.status(201).json({ data: result.rows[0] });
}));

app.patch('/api/v1/doctors/me/exam-schedules/:id', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const patch = z.object({
    examType: z.string().trim().min(1).max(80).optional(),
    startsAt: z.string().datetime().optional(),
    endsAt: z.string().datetime().optional(),
    room: z.string().trim().max(80).nullable().optional(),
    status: z.enum(['draft', 'scheduled', 'published']).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const current = await client.query(
      `SELECT es.id, es.exam_type AS "examType", es.starts_at AS "startsAt",
              es.ends_at AS "endsAt", es.room, es.status
       FROM exam_schedules es JOIN course_sections cs ON cs.id = es.section_id
       WHERE es.id = $1 AND cs.instructor_user_id = $2 FOR UPDATE OF es`,
      [req.params.id, principalOf(req).id],
    );
    if (!current.rowCount) throw new HttpError(404, 'Exam schedule not found.', 'NOT_FOUND');
    const startsAt = patch.startsAt ?? current.rows[0].startsAt;
    const endsAt = patch.endsAt ?? current.rows[0].endsAt;
    if (new Date(endsAt) <= new Date(startsAt)) {
      throw new HttpError(400, 'Exam end time must be after its start time.', 'VALIDATION_ERROR');
    }
    const result = await client.query(
      `UPDATE exam_schedules SET exam_type = COALESCE($1, exam_type), starts_at = $2,
         ends_at = $3, room = CASE WHEN $4::boolean THEN $5 ELSE room END,
         status = COALESCE($6, status)
       WHERE id = $7 RETURNING id, section_id AS "sectionId", exam_type AS "examType",
         starts_at AS "startsAt", ends_at AS "endsAt", room, status`,
      [patch.examType ?? null, startsAt, endsAt, patch.room !== undefined, patch.room ?? null,
        patch.status ?? null, req.params.id],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'exam_schedule.update', 'exam_schedule', $2, $3::jsonb, $4::jsonb)`,
      [principalOf(req).id, req.params.id, JSON.stringify(current.rows[0]), JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/doctors/me/transport', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const serviceDate = z.string().date().optional().parse(req.query.date);
  const result = await pool.query(
    `SELECT r.id, r.name, r.stops, d.id AS "departureId", d.departs_at AS "departsAt",
            d.arrives_at AS "arrivesAt", d.service_date AS "serviceDate", d.status
     FROM transport_routes r LEFT JOIN transport_departures d
       ON d.route_id = r.id AND ($1::date IS NULL OR d.service_date = $1)
     WHERE r.is_active ORDER BY r.name, d.departs_at`,
    [serviceDate ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/archive/uploads', requireAuth, requireRoles('doctor'), uploadLimiter, receiveSingleFile, asyncRoute(async (req, res) => {
  const file = req.file;
  if (!file) throw new HttpError(400, 'A multipart file field named "file" is required.', 'FILE_REQUIRED');
  validateFileSignature(file);
  const uploaded = await uploadFile(principalOf(req).id, file.originalname, file.mimetype, file.buffer);
  res.status(201).json({
    data: {
      ...uploaded,
      fileName: file.originalname,
      contentType: file.mimetype,
      fileSizeBytes: file.size,
    },
  });
}));
app.get('/api/v1/doctors/me/archive/:id/download', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT storage_key AS "storageKey" FROM archive_documents
     WHERE id = $1 AND owner_user_id = $2 AND storage_key IS NOT NULL`,
    [z.string().uuid().parse(req.params.id), principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Archive document not found.', 'NOT_FOUND');
  res.json({ data: await createDownloadUrl(result.rows[0].storageKey) });
}));
app.get('/api/v1/doctors/me/archive', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const type = z.string().trim().max(80).optional().parse(req.query.type);
  const courseId = z.string().uuid().optional().parse(req.query.courseId);
  const result = await pool.query(
    `SELECT d.id, d.section_id AS "sectionId", d.title, d.document_type AS "documentType",
            d.term_id AS "termId", d.content_type AS "contentType", d.file_size_bytes::int AS "fileSizeBytes",
            d.status, d.notes, d.created_at AS "createdAt"
     FROM archive_documents d LEFT JOIN course_sections cs ON cs.id = d.section_id
     WHERE d.owner_user_id = $1 AND ($2::text IS NULL OR d.document_type = $2)
       AND ($3::uuid IS NULL OR cs.course_id = $3)
     ORDER BY d.created_at DESC LIMIT 100`,
    [principalOf(req).id, type ?? null, courseId ?? null],
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/doctors/me/archive', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    title: z.string().trim().min(1).max(180),
    documentType: z.string().trim().min(1).max(80),
    sectionId: z.string().uuid().nullable().optional(),
    termId: z.string().uuid().nullable().optional(),
    storageKey: z.string().trim().min(1).max(500),
    notes: z.string().trim().max(2000).default(''),
  }).parse(req.body);
  const principal = principalOf(req);
  if (!body.storageKey.startsWith(`uploads/${principal.id}/`)) {
    throw new HttpError(403, 'The uploaded file does not belong to your account.', 'FILE_OWNERSHIP');
  }
  if (body.sectionId) {
    const assigned = await pool.query(
      `SELECT 1 FROM course_sections WHERE id = $1 AND instructor_user_id = $2`,
      [body.sectionId, principal.id],
    );
    if (!assigned.rowCount) throw new HttpError(404, 'Assigned course section not found.', 'NOT_FOUND');
  }
  const metadata = await getStoredFileMetadata(body.storageKey);
  const result = await pool.query(
    `INSERT INTO archive_documents
       (owner_user_id, section_id, title, document_type, term_id, storage_key,
        content_type, file_size_bytes, notes)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING id, section_id AS "sectionId", title, document_type AS "documentType",
       term_id AS "termId", content_type AS "contentType",
       file_size_bytes::int AS "fileSizeBytes", status, notes, created_at AS "createdAt"`,
    [
      principal.id, body.sectionId ?? null, body.title, body.documentType, body.termId ?? null,
      body.storageKey, metadata.contentType, metadata.fileSizeBytes, body.notes,
    ],
  );
  res.status(201).json({ data: result.rows[0] });
}));

const requireAppointmentSlotScope = async (
  principal: Principal,
  departmentId: string,
  client?: PoolClient,
) => {
  if (principal.role === 'admin') return;
  const query = client ? client.query.bind(client) : pool.query.bind(pool);
  const result = await query(
    `SELECT 1 FROM staff_profiles
     WHERE user_id = $1 AND department_id = $2
       AND has_staff_permission($1, 'appointment.manage')`,
    [principal.id, departmentId],
  );
  if (!result.rowCount) throw new HttpError(403, 'Appointment management permission is required for this department.', 'FORBIDDEN');
};

app.get('/api/v1/admin/appointments/slots', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const departmentId = z.string().uuid().optional().parse(req.query.departmentId);
  const date = z.string().date().optional().parse(req.query.date);
  const principal = principalOf(req);
  if (principal.role === 'staff') {
    if (departmentId) await requireAppointmentSlotScope(principal, departmentId);
    else {
      const authorized = await pool.query(
        `SELECT 1 FROM staff_profiles WHERE user_id = $1
          AND has_staff_permission($1, 'appointment.manage')`,
        [principal.id],
      );
      if (!authorized.rowCount) throw new HttpError(403, 'Appointment management permission is required.', 'FORBIDDEN');
    }
  }
  const result = await pool.query(
    `SELECT s.id, s.department_id AS "departmentId", s.starts_at AS "startsAt",
       s.ends_at AS "endsAt", s.capacity, s.is_available AS "isAvailable",
       count(a.id) FILTER (WHERE a.status IN ('pending', 'confirmed'))::int AS "bookedCount"
     FROM appointment_slots s LEFT JOIN appointments a ON a.slot_id = s.id
     WHERE ($1::user_role = 'admin' OR s.department_id =
       (SELECT department_id FROM staff_profiles WHERE user_id = $2))
       AND ($3::uuid IS NULL OR s.department_id = $3)
       AND ($4::date IS NULL OR s.starts_at::date = $4)
     GROUP BY s.id ORDER BY s.starts_at LIMIT 500`,
    [principal.role, principal.id, departmentId ?? null, date ?? null],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/admin/appointments/slots', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    departmentId: z.string().uuid(), startsAt: z.string().datetime(), endsAt: z.string().datetime(),
    capacity: z.number().int().min(1).max(1000).default(1), isAvailable: z.boolean().default(true),
  }).refine((value) => new Date(value.endsAt) > new Date(value.startsAt), {
    message: 'Slot end time must be after its start time.', path: ['endsAt'],
  }).parse(req.body);
  const principal = principalOf(req);
  await requireAppointmentSlotScope(principal, body.departmentId);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query(
      `INSERT INTO appointment_slots (department_id, starts_at, ends_at, capacity, is_available)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (department_id, starts_at, ends_at) DO NOTHING
       RETURNING id, department_id AS "departmentId", starts_at AS "startsAt",
         ends_at AS "endsAt", capacity, is_available AS "isAvailable"`,
      [body.departmentId, body.startsAt, body.endsAt, body.capacity, body.isAvailable],
    );
    if (!result.rowCount) throw new HttpError(409, 'A slot already exists for this department and time.', 'SLOT_EXISTS');
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
       VALUES ($1, 'appointment.slot.create', 'appointment_slot', $2, $3::jsonb)`,
      [principal.id, result.rows[0].id, JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.status(201).json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.patch('/api/v1/admin/appointments/slots/:id', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const slotId = z.string().uuid().parse(req.params.id);
  const body = z.object({
    startsAt: z.string().datetime().optional(), endsAt: z.string().datetime().optional(),
    capacity: z.number().int().min(1).max(1000).optional(), isAvailable: z.boolean().optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  if ((body.startsAt || body.endsAt) &&
      !(body.startsAt && body.endsAt && new Date(body.endsAt) > new Date(body.startsAt))) {
    throw new HttpError(400, 'Rescheduling requires both start and end times.', 'VALIDATION_ERROR');
  }
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const before = await client.query(
      `SELECT id, department_id AS "departmentId", starts_at AS "startsAt",
         ends_at AS "endsAt", capacity, is_available AS "isAvailable"
       FROM appointment_slots WHERE id = $1 FOR UPDATE`,
      [slotId],
    );
    if (!before.rowCount) throw new HttpError(404, 'Appointment slot not found.', 'NOT_FOUND');
    await requireAppointmentSlotScope(principal, before.rows[0].departmentId, client);
    const startsAt = body.startsAt ?? before.rows[0].startsAt;
    const endsAt = body.endsAt ?? before.rows[0].endsAt;
    if (new Date(endsAt) <= new Date(startsAt)) {
      throw new HttpError(400, 'Slot end time must be after its start time.', 'VALIDATION_ERROR');
    }
    const bookings = await client.query(
      `SELECT count(*)::int AS count,
         count(*) FILTER (WHERE status IN ('pending', 'confirmed'))::int AS active_count
       FROM appointments WHERE slot_id = $1`,
      [slotId],
    );
    const capacity = body.capacity ?? Number(before.rows[0].capacity);
    if (capacity < bookings.rows[0].active_count) {
      throw new HttpError(409, 'Capacity cannot be reduced below current bookings.', 'SLOT_CAPACITY_IN_USE');
    }
    if ((new Date(startsAt).getTime() !== new Date(before.rows[0].startsAt).getTime() ||
         new Date(endsAt).getTime() !== new Date(before.rows[0].endsAt).getTime()) &&
        bookings.rows[0].count > 0) {
      throw new HttpError(409, 'A slot with appointment history cannot be rescheduled.', 'SLOT_HAS_APPOINTMENTS');
    }
    const result = await client.query(
      `UPDATE appointment_slots SET starts_at = $1, ends_at = $2, capacity = $3,
         is_available = COALESCE($4, is_available)
       WHERE id = $5
       RETURNING id, department_id AS "departmentId", starts_at AS "startsAt",
         ends_at AS "endsAt", capacity, is_available AS "isAvailable"`,
      [startsAt, endsAt, capacity, body.isAvailable ?? null, slotId],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'appointment.slot.update', 'appointment_slot', $2, $3::jsonb, $4::jsonb)`,
      [principal.id, slotId, JSON.stringify(before.rows[0]), JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.delete('/api/v1/admin/appointments/slots/:id', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const slotId = z.string().uuid().parse(req.params.id);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const before = await client.query(
      `SELECT id, department_id AS "departmentId", starts_at AS "startsAt",
         ends_at AS "endsAt", capacity, is_available AS "isAvailable"
       FROM appointment_slots WHERE id = $1 FOR UPDATE`,
      [slotId],
    );
    if (!before.rowCount) throw new HttpError(404, 'Appointment slot not found.', 'NOT_FOUND');
    await requireAppointmentSlotScope(principal, before.rows[0].departmentId, client);
    const bookings = await client.query('SELECT 1 FROM appointments WHERE slot_id = $1 LIMIT 1', [slotId]);
    if (bookings.rowCount) throw new HttpError(409, 'Slots with appointment history cannot be deleted; mark them unavailable instead.', 'SLOT_HAS_APPOINTMENTS');
    await client.query('DELETE FROM appointment_slots WHERE id = $1', [slotId]);
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data)
       VALUES ($1, 'appointment.slot.delete', 'appointment_slot', $2, $3::jsonb)`,
      [principal.id, slotId, JSON.stringify(before.rows[0])],
    );
    await client.query('COMMIT');
    res.status(204).end();
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/appointments/availability', asyncRoute(async (req, res) => {
  const departmentId = z.string().uuid().parse(req.query.departmentId);
  const date = z.string().date().parse(req.query.date);
  const result = await pool.query(
    `SELECT s.id, s.department_id AS "departmentId", s.starts_at AS "startsAt",
            s.ends_at AS "endsAt", s.capacity, s.capacity - count(a.id)::int AS "remainingCapacity"
     FROM appointment_slots s LEFT JOIN appointments a
       ON a.slot_id = s.id AND a.status IN ('pending', 'confirmed')
     WHERE s.department_id = $1 AND s.is_available AND s.starts_at::date = $2::date
     GROUP BY s.id HAVING count(a.id) < s.capacity ORDER BY s.starts_at`,
    [departmentId, date],
  );
  res.json({ data: result.rows });
}));

app.get('/api/v1/appointments', requireAuth, asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const result = await pool.query(
    `SELECT a.id, a.requester_user_id AS "requesterUserId", a.department_id AS "departmentId",
            d.name_ar AS "departmentName", a.purpose, a.starts_at AS "startsAt",
            a.ends_at AS "endsAt", a.status, a.notes, a.created_at AS "createdAt"
     FROM appointments a JOIN departments d ON d.id = a.department_id
     WHERE a.requester_user_id = $1 OR ($2::user_role IN ('staff', 'admin') AND
       ($2::user_role = 'admin' OR a.department_id =
         (SELECT department_id FROM staff_profiles WHERE user_id = $1
           AND has_staff_permission($1, 'appointment.manage'))))
     ORDER BY a.starts_at DESC LIMIT 200`,
    [principal.id, principal.role],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/appointments', requireAuth, requireRoles('student', 'doctor', 'staff', 'admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    departmentId: z.string().uuid(), purpose: z.string().trim().min(3).max(500),
    startsAt: z.string().datetime(), endsAt: z.string().datetime(),
  }).refine((value) => new Date(value.endsAt) > new Date(value.startsAt), {
    message: 'Appointment end time must be after its start time.', path: ['endsAt'],
  }).parse(req.body);
  const requester = principalOf(req);
  if (requester.role === 'staff') {
    const profile = await pool.query(
      `SELECT department_id AS "departmentId" FROM staff_profiles WHERE user_id = $1`,
      [requester.id],
    );
    if (!profile.rowCount || profile.rows[0].departmentId !== body.departmentId) {
      throw new HttpError(403, 'Staff appointments are limited to your department.', 'DEPARTMENT_SCOPE');
    }
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const slot = await client.query(
      `SELECT s.id, s.capacity FROM appointment_slots s
       WHERE s.department_id = $1 AND s.starts_at = $2 AND s.ends_at = $3 AND s.is_available
       FOR UPDATE`,
      [body.departmentId, body.startsAt, body.endsAt],
    );
    if (!slot.rowCount) throw new HttpError(409, 'No matching appointment slot is available.', 'SLOT_UNAVAILABLE');
    const booked = await client.query(
      `SELECT count(*)::int AS count FROM appointments
       WHERE slot_id = $1 AND status IN ('pending', 'confirmed')`,
      [slot.rows[0].id],
    );
    if (booked.rows[0].count >= slot.rows[0].capacity) throw new HttpError(409, 'Appointment slot is full.', 'SLOT_FULL');
    const result = await client.query(
      `INSERT INTO appointments (requester_user_id, department_id, purpose, starts_at, ends_at, slot_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, department_id AS "departmentId", purpose, starts_at AS "startsAt",
         ends_at AS "endsAt", status`,
      [requester.id, body.departmentId, body.purpose, body.startsAt, body.endsAt, slot.rows[0].id],
    );
    await client.query('COMMIT');
    res.status(201).json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.patch('/api/v1/appointments/:id', requireAuth, asyncRoute(async (req, res) => {
  const body = z.object({
    purpose: z.string().trim().min(3).max(500).optional(),
    startsAt: z.string().datetime().optional(),
    endsAt: z.string().datetime().optional(),
    status: z.enum(['cancelled']).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  if ((body.startsAt || body.endsAt) && !(body.startsAt && body.endsAt && new Date(body.endsAt) > new Date(body.startsAt))) {
    throw new HttpError(400, 'Rescheduling requires a valid start and end time.', 'VALIDATION_ERROR');
  }
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const current = await client.query(
      `SELECT a.id, a.department_id AS "departmentId", a.starts_at AS "startsAt",
              a.ends_at AS "endsAt", a.slot_id AS "slotId"
       FROM appointments a WHERE a.id = $1 AND (a.requester_user_id = $2 OR
         ($3::user_role IN ('staff', 'admin') AND ($3::user_role = 'admin' OR a.department_id =
           (SELECT department_id FROM staff_profiles WHERE user_id = $2
             AND has_staff_permission($2, 'appointment.manage'))))
         AND a.status IN ('pending', 'confirmed') FOR UPDATE`,
      [req.params.id, principal.id, principal.role],
    );
    if (!current.rowCount) throw new HttpError(404, 'Editable appointment not found.', 'NOT_FOUND');
    let slotId = current.rows[0].slotId as string | null;
    if (body.startsAt && body.endsAt) {
      const slot = await client.query(
        `SELECT id, capacity FROM appointment_slots
         WHERE department_id = $1 AND starts_at = $2 AND ends_at = $3 AND is_available FOR UPDATE`,
        [current.rows[0].departmentId, body.startsAt, body.endsAt],
      );
      if (!slot.rowCount) throw new HttpError(409, 'No matching appointment slot is available.', 'SLOT_UNAVAILABLE');
      const booked = await client.query(
        `SELECT count(*)::int AS count FROM appointments
         WHERE slot_id = $1 AND id <> $2 AND status IN ('pending', 'confirmed')`,
        [slot.rows[0].id, req.params.id],
      );
      if (booked.rows[0].count >= slot.rows[0].capacity) throw new HttpError(409, 'Appointment slot is full.', 'SLOT_FULL');
      slotId = slot.rows[0].id;
    }
    const result = await client.query(
      `UPDATE appointments SET purpose = COALESCE($1, purpose),
         starts_at = COALESCE($2, starts_at), ends_at = COALESCE($3, ends_at),
         slot_id = $4, status = COALESCE($5::appointment_status, status)
       WHERE id = $6 RETURNING id, requester_user_id AS "requesterUserId",
         department_id AS "departmentId", purpose, starts_at AS "startsAt",
         ends_at AS "endsAt", status`,
      [body.purpose ?? null, body.startsAt ?? null, body.endsAt ?? null, slotId,
        body.status ?? null, req.params.id],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.delete('/api/v1/appointments/:id', requireAuth, asyncRoute(async (req, res) => {
  const principal = principalOf(req);
  const result = await pool.query(
    `UPDATE appointments a SET status = 'cancelled'
     WHERE a.id = $1 AND (a.requester_user_id = $2 OR
       ($3::user_role IN ('staff', 'admin') AND ($3::user_role = 'admin' OR a.department_id =
         (SELECT department_id FROM staff_profiles WHERE user_id = $2
           AND has_staff_permission($2, 'appointment.manage'))))
       AND a.status IN ('pending', 'confirmed') RETURNING a.id`,
    [req.params.id, principal.id, principal.role],
  );
  if (!result.rowCount) throw new HttpError(404, 'Cancellable appointment not found.', 'NOT_FOUND');
  res.status(204).end();
}));

const faqBody = z.object({
  departmentId: z.string().uuid().nullable().optional(),
  category: z.string().trim().min(1).max(80),
  question: z.string().trim().min(3).max(1000),
  answer: z.string().trim().min(1).max(10000),
  sortOrder: z.number().int().min(0).max(100000).default(0),
  isPublished: z.boolean().default(true),
});
app.get('/api/v1/admin/faqs', requireAuth, requireRoles('admin'), asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, department_id AS "departmentId", category, question, answer,
      sort_order AS "sortOrder", is_published AS "isPublished", updated_at AS "updatedAt"
     FROM faqs ORDER BY sort_order, question`,
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/admin/faqs', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = faqBody.parse(req.body);
  const result = await pool.query(
    `INSERT INTO faqs (department_id, category, question, answer, sort_order, is_published)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, department_id AS "departmentId", category, question, answer,
       sort_order AS "sortOrder", is_published AS "isPublished"`,
    [body.departmentId ?? null, body.category, body.question, body.answer, body.sortOrder, body.isPublished],
  );
  res.status(201).json({ data: result.rows[0] });
}));
app.patch('/api/v1/admin/faqs/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = faqBody.partial().refine((value) => Object.keys(value).length > 0).parse(req.body);
  const current = await pool.query('SELECT * FROM faqs WHERE id = $1', [req.params.id]);
  if (!current.rowCount) throw new HttpError(404, 'FAQ not found.', 'NOT_FOUND');
  const old = current.rows[0];
  const merged = faqBody.parse({
    departmentId: body.departmentId !== undefined ? body.departmentId : old.department_id,
    category: body.category ?? old.category, question: body.question ?? old.question,
    answer: body.answer ?? old.answer, sortOrder: body.sortOrder ?? old.sort_order,
    isPublished: body.isPublished ?? old.is_published,
  });
  const result = await pool.query(
    `UPDATE faqs SET department_id = $1, category = $2, question = $3, answer = $4,
       sort_order = $5, is_published = $6, updated_at = now()
     WHERE id = $7 RETURNING id, department_id AS "departmentId", category, question,
       answer, sort_order AS "sortOrder", is_published AS "isPublished"`,
    [merged.departmentId ?? null, merged.category, merged.question, merged.answer,
      merged.sortOrder, merged.isPublished, req.params.id],
  );
  res.json({ data: result.rows[0] });
}));
app.delete('/api/v1/admin/faqs/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const result = await pool.query('DELETE FROM faqs WHERE id = $1 RETURNING id', [req.params.id]);
  if (!result.rowCount) throw new HttpError(404, 'FAQ not found.', 'NOT_FOUND');
  res.status(204).end();
}));

app.post('/api/v1/admin/documents', requireAuth, requireRoles('admin'), uploadLimiter, receiveSingleFile, asyncRoute(async (req, res) => {
  const file = req.file;
  if (!file) throw new HttpError(400, 'A multipart file field named "file" is required.', 'FILE_REQUIRED');
  validateFileSignature(file);
  const body = z.object({
    title: z.string().trim().min(1).max(180),
    category: z.string().trim().min(1).max(80),
    version: z.string().trim().min(1).max(40),
    isPublished: z.enum(['true', 'false']).optional().transform((value) => value !== 'false'),
  }).parse(req.body);
  const uploaded = await uploadFile(principalOf(req).id, file.originalname, file.mimetype, file.buffer);
  try {
    const document = await pool.query(
      `INSERT INTO university_documents
         (title, category, version, storage_key, content_type, is_published)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, title, category, version, content_type AS "contentType",
         is_published AS "isPublished", created_at AS "createdAt"`,
      [body.title, body.category, body.version, uploaded.storageKey, file.mimetype, body.isPublished],
    );
    res.status(201).json({ data: { ...document.rows[0], ...uploaded } });
  } catch (error) {
    try {
      await deleteUploadedFile(uploaded.storageKey);
    } catch (cleanupError) {
      console.error('Failed to clean up an unlinked university document:', cleanupError);
    }
    throw error;
  }
}));

const newsBody = z.object({
  category: z.string().trim().min(1).max(80),
  title: z.string().trim().min(3).max(180),
  summary: z.string().trim().min(1).max(1000),
  content: z.string().trim().min(1).max(30000),
  status: z.enum(['draft', 'scheduled', 'published', 'archived']).default('draft'),
  publishAt: z.string().datetime().nullable().optional(),
});
app.get('/api/v1/admin/news', requireAuth, requireRoles('admin'), asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, category, title, summary, content, status, publish_at AS "publishAt",
       published_at AS "publishedAt", created_at AS "createdAt" FROM news_items ORDER BY created_at DESC`,
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/admin/news', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = newsBody.parse(req.body);
  if (body.status === 'scheduled') throw new HttpError(503, 'Scheduled publishing is not configured.', 'PUBLISH_SCHEDULER_NOT_CONFIGURED');
  const result = await pool.query(
    `INSERT INTO news_items (author_user_id, category, title, summary, content, status, publish_at, published_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7,
       CASE WHEN $6 = 'published' AND ($7 IS NULL OR $7 <= now()) THEN now() END)
     RETURNING id, category, title, summary, content, status, publish_at AS "publishAt",
       published_at AS "publishedAt"`,
    [principalOf(req).id, body.category, body.title, body.summary, body.content, body.status, body.publishAt ?? null],
  );
  res.status(201).json({ data: result.rows[0] });
}));
app.patch('/api/v1/admin/news/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const patch = newsBody.partial().refine((value) => Object.keys(value).length > 0).parse(req.body);
  const current = await pool.query('SELECT * FROM news_items WHERE id = $1', [req.params.id]);
  if (!current.rowCount) throw new HttpError(404, 'News item not found.', 'NOT_FOUND');
  const old = current.rows[0];
  const body = newsBody.parse({
    category: patch.category ?? old.category, title: patch.title ?? old.title,
    summary: patch.summary ?? old.summary, content: patch.content ?? old.content,
    status: patch.status ?? old.status,
    publishAt: patch.publishAt !== undefined
      ? patch.publishAt
      : old.publish_at instanceof Date ? old.publish_at.toISOString() : old.publish_at,
  });
  if (body.status === 'scheduled') throw new HttpError(503, 'Scheduled publishing is not configured.', 'PUBLISH_SCHEDULER_NOT_CONFIGURED');
  const result = await pool.query(
    `UPDATE news_items SET category = $1, title = $2, summary = $3, content = $4,
       status = $5, publish_at = $6,
       published_at = CASE WHEN $5 = 'published' AND ($6 IS NULL OR $6 <= now())
         THEN COALESCE(published_at, now()) ELSE NULL END
     WHERE id = $7 RETURNING id, category, title, summary, content, status,
       publish_at AS "publishAt", published_at AS "publishedAt"`,
    [body.category, body.title, body.summary, body.content, body.status, body.publishAt ?? null, req.params.id],
  );
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/admin/announcements', requireAuth, requireRoles('admin'), asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, author_user_id AS "authorUserId", title, category, content, audience,
       status, publish_at AS "publishAt", published_at AS "publishedAt", created_at AS "createdAt"
     FROM announcements WHERE section_id IS NULL ORDER BY created_at DESC`,
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/admin/announcements', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    title: z.string().trim().min(3).max(180), category: z.string().trim().min(1).max(80),
    content: z.string().trim().min(1).max(30000),
    audience: z.array(z.enum(['student', 'doctor', 'staff', 'admin'])).min(1).max(4).default(['student', 'doctor', 'staff']),
    status: z.enum(['draft', 'scheduled', 'published', 'archived']).default('draft'),
    publishAt: z.string().datetime().nullable().optional(),
  }).parse(req.body);
  if (body.status === 'scheduled') throw new HttpError(503, 'Scheduled publishing is not configured.', 'PUBLISH_SCHEDULER_NOT_CONFIGURED');
  const result = await pool.query(
    `INSERT INTO announcements (author_user_id, title, category, content, audience, status, publish_at, published_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7,
       CASE WHEN $6 = 'published' AND ($7 IS NULL OR $7 <= now()) THEN now() END)
     RETURNING id, title, category, content, audience, status,
       publish_at AS "publishAt", published_at AS "publishedAt"`,
    [principalOf(req).id, body.title, body.category, body.content, body.audience, body.status, body.publishAt ?? null],
  );
  res.status(201).json({ data: result.rows[0] });
}));
app.patch('/api/v1/admin/announcements/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    title: z.string().trim().min(3).max(180).optional(),
    category: z.string().trim().min(1).max(80).optional(),
    content: z.string().trim().min(1).max(30000).optional(),
    audience: z.array(z.enum(['student', 'doctor', 'staff', 'admin'])).min(1).max(4).optional(),
    status: z.enum(['draft', 'scheduled', 'published', 'archived']).optional(),
    publishAt: z.string().datetime().nullable().optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const current = await pool.query(
    `SELECT status FROM announcements WHERE id = $1 AND section_id IS NULL`,
    [req.params.id],
  );
  if (!current.rowCount) throw new HttpError(404, 'Announcement not found.', 'NOT_FOUND');
  if ((body.status ?? current.rows[0].status) === 'scheduled') {
    throw new HttpError(503, 'Scheduled publishing is not configured.', 'PUBLISH_SCHEDULER_NOT_CONFIGURED');
  }
  const result = await pool.query(
    `UPDATE announcements SET title = COALESCE($1, title), category = COALESCE($2, category),
       content = COALESCE($3, content), audience = COALESCE($4, audience),
       status = COALESCE($5::announcement_status, status),
       publish_at = CASE WHEN $6::boolean THEN $7::timestamptz ELSE publish_at END,
       published_at = CASE WHEN COALESCE($5, status) = 'published'
         AND (CASE WHEN $6::boolean THEN $7::timestamptz ELSE publish_at END IS NULL
           OR CASE WHEN $6::boolean THEN $7::timestamptz ELSE publish_at END <= now())
         THEN COALESCE(published_at, now()) ELSE NULL END,
       updated_at = now()
     WHERE id = $8 AND section_id IS NULL RETURNING id, title, category, content, audience, status,
       publish_at AS "publishAt", published_at AS "publishedAt"`,
    [body.title ?? null, body.category ?? null, body.content ?? null,
      body.audience ?? null, body.status ?? null, body.publishAt !== undefined,
      body.publishAt ?? null, req.params.id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Announcement not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.get('/api/v1/doctors/me/announcements', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT a.id, a.section_id AS "sectionId", cs.course_id AS "courseId",
       c.code AS "courseCode", c.name_ar AS "courseName", cs.section_number AS "sectionNumber",
       a.title, a.category, a.content, a.status, a.publish_at AS "publishAt",
       a.published_at AS "publishedAt", a.created_at AS "createdAt"
     FROM announcements a JOIN course_sections cs ON cs.id = a.section_id
     JOIN courses c ON c.id = cs.course_id
     WHERE cs.instructor_user_id = $1 ORDER BY a.created_at DESC`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.post('/api/v1/doctors/me/announcements', requireAuth, requireRoles('doctor'), asyncRoute(async (req, res) => {
  const body = z.object({
    sectionId: z.string().uuid(),
    title: z.string().trim().min(3).max(180),
    category: z.string().trim().min(1).max(80),
    content: z.string().trim().min(1).max(30000),
    status: z.enum(['draft', 'published']).default('draft'),
  }).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query(
      `INSERT INTO announcements
         (author_user_id, section_id, title, category, content, audience, status, published_at)
       SELECT $2, cs.id, $3, $4, $5, ARRAY['student']::text[], $6,
         CASE WHEN $6 = 'published' THEN now() END
       FROM course_sections cs
       WHERE cs.id = $1 AND cs.instructor_user_id = $2
       RETURNING id, section_id AS "sectionId", title, category, content, audience, status,
         published_at AS "publishedAt", created_at AS "createdAt"`,
      [body.sectionId, principal.id, body.title, body.category, body.content, body.status],
    );
    if (!result.rowCount) throw new HttpError(404, 'Assigned section not found.', 'NOT_FOUND');
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
       VALUES ($1, 'course_announcement.create', 'announcement', $2, $3::jsonb)`,
      [principal.id, result.rows[0].id, JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.status(201).json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/students/me/announcements', requireAuth, requireRoles('student'), asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT DISTINCT a.id, a.section_id AS "sectionId", cs.course_id AS "courseId",
       c.code AS "courseCode", c.name_ar AS "courseName", a.title, a.category, a.content,
       a.published_at AS "publishedAt"
     FROM announcements a JOIN course_sections cs ON cs.id = a.section_id
     JOIN courses c ON c.id = cs.course_id
     JOIN enrollments e ON e.section_id = cs.id AND e.student_user_id = $1
     WHERE e.status = 'enrolled' AND a.status = 'published' AND a.published_at <= now()
     ORDER BY a.published_at DESC`,
    [principalOf(req).id],
  );
  res.json({ data: result.rows });
}));

app.patch('/api/v1/admin/users/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    fullName: z.string().trim().min(2).max(160).optional(),
    email: z.string().trim().email().max(254).optional(),
    phone: z.string().trim().min(5).max(40).nullable().optional(),
    role: roleSchema.optional(),
    status: z.enum(['active', 'disabled', 'locked']).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  if (req.params.id === principalOf(req).id && (body.role && body.role !== 'admin' || body.status && body.status !== 'active')) {
    throw new HttpError(409, 'Administrators cannot demote or disable their own account.', 'SELF_LOCKOUT');
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const before = await client.query(
      `SELECT id, username, email, role, status, full_name AS "fullName", phone
       FROM users WHERE id = $1 FOR UPDATE`,
      [req.params.id],
    );
    if (!before.rowCount) throw new HttpError(404, 'User not found.', 'NOT_FOUND');
    const user = await client.query(
      `UPDATE users SET full_name = COALESCE($1, full_name), email = COALESCE($2, email),
         phone = CASE WHEN $3::boolean THEN $4 ELSE phone END,
         role = COALESCE($5::user_role, role), status = COALESCE($6::account_status, status),
         updated_at = now()
       WHERE id = $7 RETURNING id, username, email, role, status, full_name AS "fullName", phone`,
      [body.fullName ?? null, body.email ?? null, body.phone !== undefined, body.phone ?? null,
        body.role ?? null, body.status ?? null, req.params.id],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'user.update', 'user', $2, $3::jsonb, $4::jsonb)`,
      [principalOf(req).id, req.params.id, JSON.stringify(before.rows[0]), JSON.stringify(user.rows[0])],
    );
    if (body.status && body.status !== 'active') {
      await client.query('UPDATE refresh_sessions SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL', [req.params.id]);
    }
    await client.query('COMMIT');
    res.json({ data: user.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.put('/api/v1/admin/users/:id/permissions', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const permissionSchema = z.enum([
    'request.review', 'request.assign', 'inquiry.review', 'appointment.manage',
    'content.manage', 'transport.manage', 'student.schedule.manage', 'academic_calendar.manage',
  ]);
  const { permissions } = z.object({ permissions: z.array(permissionSchema).max(20) }).parse(req.body);
  const target = await pool.query(
    `UPDATE staff_profiles sp SET permissions = $1
     FROM users u WHERE sp.user_id = u.id AND u.id = $2 AND u.role = 'staff'
     RETURNING sp.user_id AS "userId", sp.permissions`,
    [permissions, req.params.id],
  );
  if (!target.rowCount) throw new HttpError(404, 'Staff account not found.', 'NOT_FOUND');
  await pool.query(
    `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
     VALUES ($1, 'user.permissions.update', 'user', $2, $3::jsonb)`,
    [principalOf(req).id, req.params.id, JSON.stringify({ permissions })],
  );
  res.json({ data: target.rows[0] });
}));

app.get('/api/v1/admin/transport/routes', requireAuth, requireRoles('admin'), asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT r.id, r.name, r.stops, r.is_active AS "isActive",
       COALESCE((SELECT json_agg(json_build_object(
         'id', d.id, 'departsAt', d.departs_at, 'arrivesAt', d.arrives_at,
         'serviceDate', d.service_date, 'status', d.status
       ) ORDER BY d.service_date, d.departs_at)
         FROM transport_departures d WHERE d.route_id = r.id), '[]'::json) AS departures
     FROM transport_routes r ORDER BY r.name`,
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/admin/transport/routes', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const departureSchema = z.object({
    departsAt: z.string().datetime(),
    arrivesAt: z.string().datetime().nullable().optional(),
    serviceDate: z.string().date(),
    status: z.enum(['scheduled', 'delayed', 'cancelled']).default('scheduled'),
  }).refine((value) => !value.arrivesAt || new Date(value.arrivesAt) >= new Date(value.departsAt), {
    message: 'Arrival must not precede departure.', path: ['arrivesAt'],
  });
  const body = z.object({
    name: z.string().trim().min(1).max(160),
    stops: z.array(z.object({
      name: z.string().trim().min(1).max(160),
      latitude: z.number().min(-90).max(90).optional(),
      longitude: z.number().min(-180).max(180).optional(),
    })).max(200),
    isActive: z.boolean().default(true),
    departures: z.array(departureSchema).max(1000).default([]),
  }).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const route = await client.query(
      `INSERT INTO transport_routes (name, stops, is_active) VALUES ($1, $2::jsonb, $3)
       RETURNING id, name, stops, is_active AS "isActive"`,
      [body.name, JSON.stringify(body.stops), body.isActive],
    );
    for (const departure of body.departures) {
      await client.query(
        `INSERT INTO transport_departures (route_id, departs_at, arrives_at, service_date, status)
         VALUES ($1, $2, $3, $4, $5)`,
        [route.rows[0].id, departure.departsAt, departure.arrivesAt ?? null, departure.serviceDate, departure.status],
      );
    }
    await client.query('COMMIT');
    res.status(201).json({ data: { ...route.rows[0], departures: body.departures } });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));
app.patch('/api/v1/admin/transport/routes/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const departureSchema = z.object({
    departsAt: z.string().datetime(),
    arrivesAt: z.string().datetime().nullable().optional(),
    serviceDate: z.string().date(),
    status: z.enum(['scheduled', 'delayed', 'cancelled']).default('scheduled'),
  }).refine((value) => !value.arrivesAt || new Date(value.arrivesAt) >= new Date(value.departsAt), {
    message: 'Arrival must not precede departure.', path: ['arrivesAt'],
  });
  const body = z.object({
    name: z.string().trim().min(1).max(160).optional(),
    stops: z.array(z.object({
      name: z.string().trim().min(1).max(160),
      latitude: z.number().min(-90).max(90).optional(),
      longitude: z.number().min(-180).max(180).optional(),
    })).max(200).optional(),
    isActive: z.boolean().optional(),
    departures: z.array(departureSchema).max(1000).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query(
      `UPDATE transport_routes SET name = COALESCE($1, name),
         stops = COALESCE($2::jsonb, stops), is_active = COALESCE($3, is_active)
       WHERE id = $4 RETURNING id, name, stops, is_active AS "isActive"`,
      [body.name ?? null, body.stops ? JSON.stringify(body.stops) : null, body.isActive ?? null, req.params.id],
    );
    if (!result.rowCount) throw new HttpError(404, 'Transport route not found.', 'NOT_FOUND');
    if (body.departures !== undefined) {
      await client.query('DELETE FROM transport_departures WHERE route_id = $1', [req.params.id]);
      for (const departure of body.departures) {
        await client.query(
          `INSERT INTO transport_departures (route_id, departs_at, arrives_at, service_date, status)
           VALUES ($1, $2, $3, $4, $5)`,
          [req.params.id, departure.departsAt, departure.arrivesAt ?? null, departure.serviceDate, departure.status],
        );
      }
    }
    const departures = body.departures ?? (await client.query(
      `SELECT id, departs_at AS "departsAt", arrives_at AS "arrivesAt",
         service_date AS "serviceDate", status FROM transport_departures
       WHERE route_id = $1 ORDER BY service_date, departs_at`,
      [req.params.id],
    )).rows;
    await client.query('COMMIT');
    res.json({ data: { ...result.rows[0], departures } });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/admin/academic-calendar', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().optional().parse(req.query.termId);
  const principal = principalOf(req);
  const result = await pool.query(
    `SELECT e.id, e.term_id AS "termId", t.name_ar AS "termName",
       t.starts_on AS "termStartsOn", t.ends_on AS "termEndsOn",
       t.registration_opens_at AS "registrationOpensAt",
       t.registration_closes_at AS "registrationClosesAt",
       e.title, e.description, e.starts_at AS "startsAt", e.ends_at AS "endsAt",
       e.category, e.is_published AS "isPublished"
     FROM academic_calendar_events e LEFT JOIN terms t ON t.id = e.term_id
     WHERE ($1::uuid IS NULL OR e.term_id = $1)
       AND ($2::user_role = 'admin' OR EXISTS (
         SELECT 1 FROM staff_profiles sp
         WHERE sp.user_id = $3 AND has_staff_permission($3, 'academic_calendar.manage')))
     ORDER BY e.starts_at`,
    [termId ?? null, principal.role, principal.id],
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/admin/academic-calendar', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    termId: z.string().uuid().nullable().optional(),
    title: z.string().trim().min(1).max(180), description: z.string().trim().max(5000).default(''),
    startsAt: z.string().datetime(), endsAt: z.string().datetime().nullable().optional(),
    category: z.string().trim().min(1).max(80), isPublished: z.boolean().default(true),
  }).refine((value) => !value.endsAt || new Date(value.endsAt) >= new Date(value.startsAt), {
    message: 'Event end must not precede its start.', path: ['endsAt'],
  }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO academic_calendar_events (term_id, title, description, starts_at, ends_at, category, is_published)
     SELECT $1, $2, $3, $4, $5, $6, $7
     WHERE $8::user_role = 'admin' OR EXISTS (
       SELECT 1 FROM staff_profiles WHERE user_id = $9
         AND has_staff_permission($9, 'academic_calendar.manage'))
     RETURNING id, term_id AS "termId", title, description, starts_at AS "startsAt",
       ends_at AS "endsAt", category, is_published AS "isPublished"`,
    [body.termId ?? null, body.title, body.description, body.startsAt, body.endsAt ?? null,
      body.category, body.isPublished, principalOf(req).role, principalOf(req).id],
  );
  if (!result.rowCount) throw new HttpError(403, 'Staff department scope does not permit this event.', 'FORBIDDEN');
  res.status(201).json({ data: result.rows[0] });
}));

app.get('/api/v1/admin/academic-calendar/terms/:termId', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().parse(req.params.termId);
  const principal = principalOf(req);
  const result = await pool.query(
    `SELECT t.id, t.name_ar AS "nameAr", t.name_en AS "nameEn", t.starts_on AS "startsOn",
       t.ends_on AS "endsOn", t.registration_opens_at AS "registrationOpensAt",
       t.registration_closes_at AS "registrationClosesAt", t.is_current AS "isCurrent"
     FROM terms t WHERE t.id = $1 AND
       ($2::user_role = 'admin' OR has_staff_permission($3, 'academic_calendar.manage'))`,
    [termId, principal.role, principal.id],
  );
  if (!result.rowCount) throw new HttpError(404, 'Term not found or access denied.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.put('/api/v1/admin/academic-calendar/terms/:termId', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const termId = z.string().uuid().parse(req.params.termId);
  const body = z.object({
    registrationOpensAt: z.string().datetime().nullable(),
    registrationClosesAt: z.string().datetime().nullable(),
  }).refine((value) => !value.registrationOpensAt || !value.registrationClosesAt ||
    new Date(value.registrationOpensAt) <= new Date(value.registrationClosesAt), {
    message: 'Registration opening must not follow closing.',
    path: ['registrationClosesAt'],
  }).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const before = await client.query(
      `SELECT id, registration_opens_at AS "registrationOpensAt",
         registration_closes_at AS "registrationClosesAt"
       FROM terms WHERE id = $1
         AND ($2::user_role = 'admin' OR has_staff_permission($3, 'academic_calendar.manage'))
       FOR UPDATE`,
      [termId, principal.role, principal.id],
    );
    if (!before.rowCount) throw new HttpError(404, 'Term not found or access denied.', 'NOT_FOUND');
    const result = await client.query(
      `UPDATE terms SET registration_opens_at = $1, registration_closes_at = $2
       WHERE id = $3 RETURNING id, name_ar AS "nameAr", name_en AS "nameEn",
         starts_on AS "startsOn", ends_on AS "endsOn",
         registration_opens_at AS "registrationOpensAt",
         registration_closes_at AS "registrationClosesAt", is_current AS "isCurrent"`,
      [body.registrationOpensAt, body.registrationClosesAt, termId],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'academic_calendar.registration_dates.update', 'term', $2, $3::jsonb, $4::jsonb)`,
      [principal.id, termId, JSON.stringify(before.rows[0]), JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/admin/maintenance', requireAuth, requireRoles('admin'), asyncRoute(async (_req, res) => {
  const result = await pool.query(
    `SELECT id, title, description, starts_at AS "startsAt", ends_at AS "endsAt",
       status, created_at AS "createdAt" FROM maintenance_windows ORDER BY starts_at DESC`,
  );
  res.json({ data: result.rows });
}));
app.post('/api/v1/admin/maintenance', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    title: z.string().trim().min(3).max(180), description: z.string().trim().max(5000).default(''),
    startsAt: z.string().datetime(), endsAt: z.string().datetime(),
    status: z.enum(['scheduled', 'in_progress', 'completed', 'cancelled']).default('scheduled'),
  }).refine((value) => new Date(value.endsAt) > new Date(value.startsAt), {
    message: 'Maintenance end time must be after its start time.', path: ['endsAt'],
  }).parse(req.body);
  const result = await pool.query(
    `INSERT INTO maintenance_windows (title, description, starts_at, ends_at, status, created_by)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, title, description, starts_at AS "startsAt", ends_at AS "endsAt", status`,
    [body.title, body.description, body.startsAt, body.endsAt, body.status, principalOf(req).id],
  );
  res.status(201).json({ data: result.rows[0] });
}));
app.patch('/api/v1/admin/maintenance/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const body = z.object({
    title: z.string().trim().min(3).max(180).optional(),
    description: z.string().trim().max(5000).optional(),
    startsAt: z.string().datetime().optional(), endsAt: z.string().datetime().optional(),
    status: z.enum(['scheduled', 'in_progress', 'completed', 'cancelled']).optional(),
  }).refine((value) => Object.keys(value).length > 0).parse(req.body);
  const current = await pool.query('SELECT * FROM maintenance_windows WHERE id = $1', [req.params.id]);
  if (!current.rowCount) throw new HttpError(404, 'Maintenance window not found.', 'NOT_FOUND');
  const old = current.rows[0];
  const startsAt = body.startsAt ?? old.starts_at;
  const endsAt = body.endsAt ?? old.ends_at;
  if (new Date(endsAt) <= new Date(startsAt)) throw new HttpError(400, 'Maintenance end time must be after its start time.', 'VALIDATION_ERROR');
  const result = await pool.query(
    `UPDATE maintenance_windows SET title = COALESCE($1, title), description = COALESCE($2, description),
       starts_at = $3, ends_at = $4, status = COALESCE($5, status)
     WHERE id = $6 RETURNING id, title, description, starts_at AS "startsAt", ends_at AS "endsAt", status`,
    [body.title ?? null, body.description ?? null, startsAt, endsAt, body.status ?? null, req.params.id],
  );
  res.json({ data: result.rows[0] });
}));
app.delete('/api/v1/admin/maintenance/:id', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const result = await pool.query('DELETE FROM maintenance_windows WHERE id = $1 RETURNING id', [req.params.id]);
  if (!result.rowCount) throw new HttpError(404, 'Maintenance window not found.', 'NOT_FOUND');
  res.status(204).end();
}));

app.get('/api/v1/admin/system/health', requireAuth, requireRoles('admin'), asyncRoute(async (_req, res) => {
  const db = await pool.query('SELECT 1 AS ok');
  res.json({ data: { status: 'ok', database: db.rowCount ? 'ok' : 'unavailable', checkedAt: new Date().toISOString() } });
}));
app.get('/api/v1/admin/system/events', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const severity = z.enum(['info', 'warning', 'error', 'critical']).optional().parse(req.query.severity);
  const result = await pool.query(
    `SELECT id, severity, source, message, metadata, created_at AS "createdAt"
     FROM system_events WHERE ($1::text IS NULL OR severity = $1)
     ORDER BY created_at DESC LIMIT 200`,
    [severity ?? null],
  );
  res.json({ data: result.rows });
}));
app.get('/api/v1/admin/audit-events', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const entityType = z.string().trim().max(80).optional().parse(req.query.entityType);
  const entityId = z.string().uuid().optional().parse(req.query.entityId);
  const result = await pool.query(
    `SELECT id, actor_user_id AS "actorUserId", action, entity_type AS "entityType",
       entity_id AS "entityId", before_data AS "beforeData", after_data AS "afterData",
       ip_address AS "ipAddress", created_at AS "createdAt"
     FROM audit_events WHERE ($1::text IS NULL OR entity_type = $1)
       AND ($2::uuid IS NULL OR entity_id = $2)
     ORDER BY created_at DESC LIMIT 200`,
    [entityType ?? null, entityId ?? null],
  );
  res.json({ data: result.rows });
}));

const policyPermissionSchema = z.enum([
  'request.review', 'request.assign', 'inquiry.review', 'appointment.manage',
  'content.manage', 'transport.manage', 'student.schedule.manage', 'academic_calendar.manage',
]);
app.get('/api/v1/admin/roles/:role/permissions', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const role = roleSchema.parse(req.params.role);
  const result = await pool.query(
    `SELECT role, permissions, updated_by AS "updatedBy", updated_at AS "updatedAt"
     FROM role_permission_policies WHERE role = $1`,
    [role],
  );
  if (!result.rowCount) throw new HttpError(404, 'Role permission policy not found.', 'NOT_FOUND');
  res.json({ data: result.rows[0] });
}));

app.put('/api/v1/admin/roles/:role/permissions', requireAuth, requireRoles('admin'), asyncRoute(async (req, res) => {
  const role = roleSchema.parse(req.params.role);
  const { permissions } = z.object({
    permissions: z.array(policyPermissionSchema).max(8).refine(
      (values) => new Set(values).size === values.length,
      'Permission keys must be unique.',
    ),
  }).parse(req.body);
  const principal = principalOf(req);
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const before = await client.query(
      `SELECT role, permissions, updated_by AS "updatedBy", updated_at AS "updatedAt"
       FROM role_permission_policies WHERE role = $1 FOR UPDATE`,
      [role],
    );
    if (!before.rowCount) throw new HttpError(404, 'Role permission policy not found.', 'NOT_FOUND');
    const after = await client.query(
      `UPDATE role_permission_policies SET permissions = $1, updated_by = $2, updated_at = now()
       WHERE role = $3
       RETURNING role, permissions, updated_by AS "updatedBy", updated_at AS "updatedAt"`,
      [permissions, principal.id, role],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, before_data, after_data)
       VALUES ($1, 'role.permissions.update', 'role_permission_policy', $2::jsonb, $3::jsonb)`,
      [principal.id, JSON.stringify(before.rows[0]), JSON.stringify(after.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: after.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.get('/api/v1/admin/students/:studentId/schedule', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const studentId = z.string().uuid().parse(req.params.studentId);
  const principal = principalOf(req);
  const authorized = await pool.query(
    `SELECT 1 FROM student_profiles sp
     WHERE sp.user_id = $1 AND ($2::user_role = 'admin' OR EXISTS (
       SELECT 1 FROM staff_profiles staff
       WHERE staff.user_id = $3 AND staff.department_id = sp.department_id
         AND has_staff_permission($3, 'student.schedule.manage')))`,
    [studentId, principal.role, principal.id],
  );
  if (!authorized.rowCount) throw new HttpError(404, 'Student not found in your permitted department.', 'NOT_FOUND');
  const result = await pool.query(
    `SELECT cs.id AS "sectionId", c.id AS "courseId", c.code AS "courseCode",
            c.name_ar AS "courseName", cs.section_number AS "sectionNumber",
            cs.room, cs.schedule, t.id AS "termId", t.name_ar AS "termName",
            instructor.full_name AS "instructorName"
     FROM enrollments e JOIN course_sections cs ON cs.id = e.section_id
     JOIN courses c ON c.id = cs.course_id JOIN terms t ON t.id = cs.term_id
     LEFT JOIN users instructor ON instructor.id = cs.instructor_user_id
     WHERE e.student_user_id = $1 AND e.status = 'enrolled'
     ORDER BY t.starts_on DESC, c.code`,
    [studentId],
  );
  const overrides = await pool.query(
    `SELECT NULL::uuid AS "sectionId", entry.course_id AS "courseId", c.code AS "courseCode",
       c.name_ar AS "courseName", NULL::text AS "sectionNumber", entry.room,
       json_build_array(json_build_object('dayOfWeek', entry.day_of_week,
         'startTime', entry.starts_at, 'endTime', entry.ends_at)) AS schedule,
       NULL::text AS "instructorName", entry.id AS "scheduleId", entry.term_id AS "termId",
       t.name_ar AS "termName", 'manual' AS "entryType"
     FROM student_schedule_entries entry JOIN courses c ON c.id = entry.course_id
     JOIN terms t ON t.id = entry.term_id
     WHERE entry.student_user_id = $1 ORDER BY t.starts_on DESC, entry.day_of_week, entry.starts_at`,
    [studentId],
  );
  res.json({ data: [...result.rows, ...overrides.rows] });
}));

const hasScheduleScope = async (principal: Principal, studentId: string): Promise<boolean> => {
  const result = await pool.query(
    `SELECT 1 FROM student_profiles sp
     WHERE sp.user_id = $1 AND ($2::user_role = 'admin' OR EXISTS (
       SELECT 1 FROM staff_profiles staff
       WHERE staff.user_id = $3 AND staff.department_id = sp.department_id
         AND has_staff_permission($3, 'student.schedule.manage')))`,
    [studentId, principal.role, principal.id],
  );
  return Boolean(result.rowCount);
};

const scheduleEntryFields = z.object({
  courseId: z.string().uuid(),
  termId: z.string().uuid(),
  dayOfWeek: z.number().int().min(0).max(6),
  startTime: z.string().regex(/^(?:[01]\d|2[0-3]):[0-5]\d$/),
  endTime: z.string().regex(/^(?:[01]\d|2[0-3]):[0-5]\d$/),
  room: z.string().trim().min(1).max(120),
});
const scheduleEntryBody = scheduleEntryFields.refine((value) => value.endTime > value.startTime, {
  message: 'Schedule end time must follow its start time.',
  path: ['endTime'],
});

const validateScheduleEntryScope = async (
  client: PoolClient,
  studentId: string,
  courseId: string,
  termId: string,
) => {
  const result = await client.query(
    `SELECT sp.department_id AS "studentDepartmentId", c.department_id AS "courseDepartmentId"
     FROM student_profiles sp CROSS JOIN courses c
     WHERE sp.user_id = $1 AND c.id = $2 AND EXISTS (SELECT 1 FROM terms WHERE id = $3)`,
    [studentId, courseId, termId],
  );
  if (!result.rowCount) throw new HttpError(404, 'Student, course, or term not found.', 'NOT_FOUND');
  if (result.rows[0].courseDepartmentId &&
      result.rows[0].courseDepartmentId !== result.rows[0].studentDepartmentId) {
    throw new HttpError(403, 'Course is outside the student department.', 'DEPARTMENT_SCOPE');
  }
};

app.post('/api/v1/admin/students/:studentId/schedule', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const studentId = z.string().uuid().parse(req.params.studentId);
  const body = scheduleEntryBody.parse(req.body);
  const principal = principalOf(req);
  if (!await hasScheduleScope(principal, studentId)) {
    throw new HttpError(404, 'Student not found in your permitted department.', 'NOT_FOUND');
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const lockedStudent = await client.query(
      `SELECT user_id FROM student_profiles WHERE user_id = $1 FOR UPDATE`,
      [studentId],
    );
    if (!lockedStudent.rowCount) throw new HttpError(404, 'Student profile not found.', 'NOT_FOUND');
    await validateScheduleEntryScope(client, studentId, body.courseId, body.termId);
    const conflict = await client.query(
      `SELECT 1 FROM student_schedule_entries
       WHERE student_user_id = $1 AND term_id = $2 AND day_of_week = $3
         AND starts_at < $5::time AND ends_at > $4::time LIMIT 1`,
      [studentId, body.termId, body.dayOfWeek, body.startTime, body.endTime],
    );
    if (conflict.rowCount) throw new HttpError(409, 'This entry overlaps another manually scheduled event.', 'SCHEDULE_CONFLICT');
    const result = await client.query(
      `INSERT INTO student_schedule_entries
         (student_user_id, course_id, term_id, day_of_week, starts_at, ends_at, room, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING id, student_user_id AS "studentId", course_id AS "courseId",
         term_id AS "termId", day_of_week AS "dayOfWeek", starts_at AS "startTime",
         ends_at AS "endTime", room`,
      [studentId, body.courseId, body.termId, body.dayOfWeek, body.startTime, body.endTime, body.room, principal.id],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, after_data)
       VALUES ($1, 'student.schedule.create', 'student_schedule_entry', $2, $3::jsonb)`,
      [principal.id, result.rows[0].id, JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.status(201).json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.patch('/api/v1/admin/students/:studentId/schedule/:scheduleId', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const studentId = z.string().uuid().parse(req.params.studentId);
  const scheduleId = z.string().uuid().parse(req.params.scheduleId);
  const patch = scheduleEntryFields.partial().refine((value) => Object.keys(value).length > 0).parse(req.body);
  const principal = principalOf(req);
  if (!await hasScheduleScope(principal, studentId)) {
    throw new HttpError(404, 'Student not found in your permitted department.', 'NOT_FOUND');
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const lockedStudent = await client.query(
      `SELECT user_id FROM student_profiles WHERE user_id = $1 FOR UPDATE`,
      [studentId],
    );
    if (!lockedStudent.rowCount) throw new HttpError(404, 'Student profile not found.', 'NOT_FOUND');
    const before = await client.query(
      `SELECT id, course_id AS "courseId", term_id AS "termId",
         day_of_week AS "dayOfWeek", starts_at AS "startTime", ends_at AS "endTime", room
       FROM student_schedule_entries WHERE id = $1 AND student_user_id = $2 FOR UPDATE`,
      [scheduleId, studentId],
    );
    if (!before.rowCount) throw new HttpError(404, 'Schedule entry not found.', 'NOT_FOUND');
    const merged = scheduleEntryBody.parse({
      courseId: patch.courseId ?? before.rows[0].courseId,
      termId: patch.termId ?? before.rows[0].termId,
      dayOfWeek: patch.dayOfWeek ?? before.rows[0].dayOfWeek,
      startTime: patch.startTime ?? before.rows[0].startTime,
      endTime: patch.endTime ?? before.rows[0].endTime,
      room: patch.room ?? before.rows[0].room,
    });
    await validateScheduleEntryScope(client, studentId, merged.courseId, merged.termId);
    const conflict = await client.query(
      `SELECT 1 FROM student_schedule_entries
       WHERE student_user_id = $1 AND id <> $2 AND term_id = $3 AND day_of_week = $4
         AND starts_at < $6::time AND ends_at > $5::time LIMIT 1`,
      [studentId, scheduleId, merged.termId, merged.dayOfWeek, merged.startTime, merged.endTime],
    );
    if (conflict.rowCount) throw new HttpError(409, 'This entry overlaps another manually scheduled event.', 'SCHEDULE_CONFLICT');
    const result = await client.query(
      `UPDATE student_schedule_entries SET course_id = $1, term_id = $2, day_of_week = $3,
         starts_at = $4, ends_at = $5, room = $6, updated_at = now()
       WHERE id = $7 AND student_user_id = $8
       RETURNING id, student_user_id AS "studentId", course_id AS "courseId",
         term_id AS "termId", day_of_week AS "dayOfWeek", starts_at AS "startTime",
         ends_at AS "endTime", room`,
      [merged.courseId, merged.termId, merged.dayOfWeek, merged.startTime, merged.endTime,
        merged.room, scheduleId, studentId],
    );
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data, after_data)
       VALUES ($1, 'student.schedule.update', 'student_schedule_entry', $2, $3::jsonb, $4::jsonb)`,
      [principal.id, scheduleId, JSON.stringify(before.rows[0]), JSON.stringify(result.rows[0])],
    );
    await client.query('COMMIT');
    res.json({ data: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.delete('/api/v1/admin/students/:studentId/schedule/:scheduleId', requireAuth, requireRoles('staff', 'admin'), asyncRoute(async (req, res) => {
  const studentId = z.string().uuid().parse(req.params.studentId);
  const scheduleId = z.string().uuid().parse(req.params.scheduleId);
  const principal = principalOf(req);
  if (!await hasScheduleScope(principal, studentId)) {
    throw new HttpError(404, 'Student not found in your permitted department.', 'NOT_FOUND');
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const deleted = await client.query(
      `DELETE FROM student_schedule_entries WHERE id = $1 AND student_user_id = $2
       RETURNING id, student_user_id AS "studentId", course_id AS "courseId",
         term_id AS "termId", day_of_week AS "dayOfWeek", starts_at AS "startTime",
         ends_at AS "endTime", room`,
      [scheduleId, studentId],
    );
    if (!deleted.rowCount) throw new HttpError(404, 'Schedule entry not found.', 'NOT_FOUND');
    await client.query(
      `INSERT INTO audit_events (actor_user_id, action, entity_type, entity_id, before_data)
       VALUES ($1, 'student.schedule.delete', 'student_schedule_entry', $2, $3::jsonb)`,
      [principal.id, scheduleId, JSON.stringify(deleted.rows[0])],
    );
    await client.query('COMMIT');
    res.status(204).end();
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}));

app.use((_req, _res, next) => next(new HttpError(404, 'Route not found.', 'NOT_FOUND')));

app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
  if (error instanceof ZodError) {
    res.status(400).json({
      error: { code: 'VALIDATION_ERROR', message: 'Request validation failed.', details: error.issues },
    });
    return;
  }
  if (error instanceof HttpError) {
    res.status(error.status).json({ error: { code: error.code, message: error.message } });
    return;
  }
  if (error instanceof StorageConfigurationError) {
    res.status(503).json({
      error: { code: 'STORAGE_NOT_CONFIGURED', message: 'Firebase Storage is not configured.' },
    });
    return;
  }
  if (error instanceof StorageObjectNotFoundError) {
    res.status(404).json({ error: { code: 'FILE_NOT_FOUND', message: error.message } });
    return;
  }
  if (error instanceof multer.MulterError) {
    const tooLarge = error.code === 'LIMIT_FILE_SIZE';
    res.status(tooLarge ? 413 : 400).json({
      error: {
        code: tooLarge ? 'FILE_TOO_LARGE' : 'UPLOAD_ERROR',
        message: tooLarge ? 'Maximum upload size is 10 MB.' : 'File upload could not be processed.',
      },
    });
    return;
  }
  console.error('Unhandled request error:', error);
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'An unexpected server error occurred.' } });
});

const port = Number(process.env.PORT ?? '3000');
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error('PORT must be a valid TCP port.');
}

const server = app.listen(port, () => {
  console.log(`IUST Campus API listening on port ${port}`);
});

const shutdown = async () => {
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
};
process.on('SIGINT', () => void shutdown());
process.on('SIGTERM', () => void shutdown());
