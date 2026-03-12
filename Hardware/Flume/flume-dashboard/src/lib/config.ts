import 'server-only';
import { cookies } from 'next/headers';
import crypto from 'crypto';

const ALGORITHM = 'aes-256-cbc';
const ENCRYPTION_KEY = process.env.FLUME_CONFIG_SECRET 
  ? crypto.scryptSync(process.env.FLUME_CONFIG_SECRET, 'salt', 32)
  : crypto.scryptSync('default-secret-change-me', 'salt', 32);

const IV_LENGTH = 16;

export interface FlumeConfig {
  clientId: string;
  clientSecret: string;
  username: string;
  password?: string;
}

function encrypt(text: string): string {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, Buffer.from(ENCRYPTION_KEY), iv);
  let encrypted = cipher.update(text);
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return iv.toString('hex') + ':' + encrypted.toString('hex');
}

function decrypt(text: string): string {
  const textParts = text.split(':');
  const iv = Buffer.from(textParts.shift()!, 'hex');
  const encryptedText = Buffer.from(textParts.join(':'), 'hex');
  const decipher = crypto.createDecipheriv(ALGORITHM, Buffer.from(ENCRYPTION_KEY), iv);
  let decrypted = decipher.update(encryptedText);
  decrypted = Buffer.concat([decrypted, decipher.final()]);
  return decrypted.toString();
}

export async function getStoredConfig(): Promise<FlumeConfig | null> {
  const cookieStore = await cookies();
  const configCookie = cookieStore.get('flume_config');

  if (!configCookie) return null;

  try {
    const decrypted = decrypt(configCookie.value);
    return JSON.parse(decrypted);
  } catch (e) {
    console.error('Failed to decrypt flume config', e);
    return null;
  }
}

export async function saveConfig(config: FlumeConfig) {
  const cookieStore = await cookies();
  const encrypted = encrypt(JSON.stringify(config));
  
  cookieStore.set('flume_config', encrypted, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 60 * 60 * 24 * 365, // 1 year
    path: '/',
  });
}

export async function clearConfig() {
  const cookieStore = await cookies();
  cookieStore.delete('flume_config');
}
