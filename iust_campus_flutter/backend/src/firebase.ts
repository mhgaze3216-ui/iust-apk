import 'dotenv/config';
import { readFileSync } from 'node:fs';
import { App, cert, initializeApp } from 'firebase-admin/app';
import { getStorage, Storage } from 'firebase-admin/storage';
import { randomUUID } from 'node:crypto';
import { Readable } from 'node:stream';
import { pipeline } from 'node:stream/promises';

const bucketName = process.env.FIREBASE_STORAGE_BUCKET?.trim();
let firebaseApp: App | undefined;
let storage: Storage | undefined;

const serviceAccount = () => {
  const accountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (accountJson) {
    return cert(JSON.parse(accountJson));
  }

  const accountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (accountPath) {
    return cert(JSON.parse(readFileSync(accountPath, 'utf8')));
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
  const individualCredentialsProvided = Boolean(projectId || clientEmail || privateKey);
  if (projectId && clientEmail && privateKey) {
    return cert({ projectId, clientEmail, privateKey });
  }
  if (individualCredentialsProvided) {
    throw new Error('FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY must be configured together.');
  }

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return undefined;
  }

  return undefined;
};

if (bucketName) {
  const credential = serviceAccount();
  firebaseApp = initializeApp({
    ...(credential ? { credential } : {}),
    storageBucket: bucketName,
  });
  storage = getStorage(firebaseApp);
}

export class StorageConfigurationError extends Error {
  constructor() {
    super('Firebase Storage is not configured.');
    this.name = 'StorageConfigurationError';
  }
}

export class StorageObjectNotFoundError extends Error {
  constructor() {
    super('The requested file does not exist in storage.');
    this.name = 'StorageObjectNotFoundError';
  }
}

export type UploadedObject = {
  storageKey: string;
  signedUrl: string;
  expiresAt: string;
};

const getBucket = () => {
  if (!storage || !bucketName) throw new StorageConfigurationError();
  return storage.bucket(bucketName);
};

export async function uploadFile(
  ownerId: string,
  originalName: string,
  contentType: string,
  buffer: Buffer,
): Promise<UploadedObject> {
  const bucket = getBucket();
  const safeName = originalName.replace(/[^a-zA-Z0-9._-]/g, '_').slice(-120) || 'upload';
  const storageKey = `uploads/${ownerId}/${randomUUID()}-${safeName}`;
  const file = bucket.file(storageKey);

  try {
    await pipeline(
      Readable.from([buffer]),
      file.createWriteStream({
        resumable: false,
        metadata: {
          contentType,
          cacheControl: 'private, max-age=0, no-transform',
        },
      }),
    );
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
    const [signedUrl] = await file.getSignedUrl({ action: 'read', expires: expiresAt });
    return { storageKey, signedUrl, expiresAt: expiresAt.toISOString() };
  } catch (error) {
    try {
      await file.delete({ ignoreNotFound: true });
    } catch (cleanupError) {
      console.error('Failed to clean up an uploaded file after the upload failed:', cleanupError);
    }
    throw error;
  }
}

export async function createDownloadUrl(storageKey: string): Promise<UploadedObject> {
  const file = getBucket().file(storageKey);
  const [exists] = await file.exists();
  if (!exists) throw new StorageObjectNotFoundError();
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000);
  const [signedUrl] = await file.getSignedUrl({ action: 'read', expires: expiresAt });
  return { storageKey, signedUrl, expiresAt: expiresAt.toISOString() };
}

export async function getStoredFileMetadata(storageKey: string) {
  const file = getBucket().file(storageKey);
  const [exists] = await file.exists();
  if (!exists) throw new StorageObjectNotFoundError();
  const [metadata] = await file.getMetadata();
  return {
    contentType: metadata.contentType ?? 'application/octet-stream',
    fileSizeBytes: Number(metadata.size ?? 0),
  };
}

export async function deleteUploadedFile(storageKey: string): Promise<void> {
  await getBucket().file(storageKey).delete({ ignoreNotFound: true });
}

export const isFirebaseStorageConfigured = Boolean(firebaseApp && storage);
