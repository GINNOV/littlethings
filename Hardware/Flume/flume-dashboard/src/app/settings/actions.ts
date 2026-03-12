'use server';

import 'server-only';
import { getStoredConfig, saveConfig, clearConfig, FlumeConfig } from '@/lib/config';
import { flumeClient } from '@/lib/flume';
import { revalidatePath } from 'next/cache';

export async function getEnvStatus() {
  const customConfig = await getStoredConfig();
  
  const mask = (str: string | undefined) => {
    if (!str) return 'Not Set';
    if (str.length <= 8) return '********';
    return `${str.substring(0, 4)}••••${str.substring(str.length - 4)}`;
  };

  return {
    FLUME_CLIENT_ID: mask(customConfig?.clientId || process.env.FLUME_CLIENT_ID),
    FLUME_CLIENT_SECRET: mask(customConfig?.clientSecret || process.env.FLUME_CLIENT_SECRET),
    FLUME_USERNAME: (customConfig?.username || process.env.FLUME_USERNAME) 
      ? `${(customConfig?.username || process.env.FLUME_USERNAME)!.substring(0, 3)}••••@••••.com` 
      : 'Not Set',
    FLUME_PASSWORD: (customConfig?.password || process.env.FLUME_PASSWORD) ? '••••••••' : 'Not Set',
    isCustom: !!customConfig,
  };
}

export async function checkAuthConfig() {
  const customConfig = await getStoredConfig();
  const hasEnvConfig = !!(process.env.FLUME_CLIENT_ID && process.env.FLUME_CLIENT_SECRET && process.env.FLUME_USERNAME && process.env.FLUME_PASSWORD);
  return {
    hasConfig: !!customConfig || hasEnvConfig,
    isCustom: !!customConfig,
  };
}

export async function updateFlumeConfig(formData: FormData) {
  const clientId = formData.get('clientId') as string;
  const clientSecret = formData.get('clientSecret') as string;
  const username = formData.get('username') as string;
  const password = formData.get('password') as string;

  if (!clientId || !clientSecret || !username || !password) {
    return { error: 'All fields are required' };
  }

  try {
    // Validate credentials by attempting to get a token
    await flumeClient.getAccessToken({ clientId, clientSecret, username, password });
    
    // If successful, save to cookie
    await saveConfig({ clientId, clientSecret, username, password });
    
    revalidatePath('/settings');
    return { success: true };
  } catch (error: any) {
    console.error('Validation failed:', error.response?.data || error.message);
    return { error: 'Invalid credentials or Flume API error' };
  }
}

export async function resetFlumeConfig() {
  await clearConfig();
  revalidatePath('/');
  revalidatePath('/settings');
  return { success: true };
}

export async function logout() {
  await clearConfig();
  revalidatePath('/');
  return { success: true };
}
