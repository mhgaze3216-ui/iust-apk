import 'dotenv/config';
import { Pool, PoolConfig } from 'pg';

const getPoolConfig = (): PoolConfig => {
  const connectionString = process.env.DATABASE_URL;
  const host = process.env.DB_HOST;
  const user = process.env.DB_USER;
  const database = process.env.DB_NAME;

  if (host || user || database) {
    if (!host || !user || !database) {
      throw new Error('DB_HOST, DB_USER, and DB_NAME must all be configured.');
    }

    const port = Number(process.env.DB_PORT ?? '5432');
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
      throw new Error('DB_PORT must be an integer between 1 and 65535.');
    }
    const sslSetting = process.env.DB_SSL;
    if (sslSetting && sslSetting !== 'true' && sslSetting !== 'false') {
      throw new Error('DB_SSL must be either true or false.');
    }

    return {
      host,
      port,
      user,
      password: process.env.DB_PASSWORD ?? '',
      database,
      ssl: sslSetting === 'true' ? { rejectUnauthorized: true } : undefined,
      application_name: 'iust-campus-api',
    };
  }

  if (!connectionString) {
    throw new Error('Configure DB_HOST/DB_USER/DB_NAME or DATABASE_URL.');
  }

  return { connectionString, application_name: 'iust-campus-api' };
};

export const pool = new Pool(getPoolConfig());

pool.on('error', (error) => {
  console.error('Unexpected PostgreSQL pool error:', error);
});
