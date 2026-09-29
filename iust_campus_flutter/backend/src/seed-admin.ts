import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { pool } from './db';

const required = (name: string) => {
  const value = process.env[name];
  if (!value) throw new Error(`${name} must be set before creating the initial administrator.`);
  return value;
};

const username = required('SEED_ADMIN_USERNAME').trim().toLowerCase();
const email = required('SEED_ADMIN_EMAIL').trim().toLowerCase();
const password = required('SEED_ADMIN_PASSWORD');
const fullName = required('SEED_ADMIN_NAME').trim();

if (password.length < 12) {
  throw new Error('SEED_ADMIN_PASSWORD must contain at least 12 characters.');
}

async function seedAdmin() {
  try {
    const existing = await pool.query(
      `SELECT 1 FROM users WHERE lower(username) = $1 OR lower(email) = $2`,
      [username, email],
    );
    if (existing.rowCount) throw new Error('An account with this username or email already exists.');

    const passwordHash = await bcrypt.hash(password, 12);
    const inserted = await pool.query(
      `INSERT INTO users (username, email, password_hash, role, full_name)
       VALUES ($1, $2, $3, 'admin', $4)
       RETURNING id, username, email, role`,
      [username, email, passwordHash, fullName],
    );
    console.log('Created administrator:', inserted.rows[0]);
  } finally {
    await pool.end();
  }
}

void seedAdmin().catch((error: unknown) => {
  console.error('Administrator seed failed:', error);
  process.exitCode = 1;
});
