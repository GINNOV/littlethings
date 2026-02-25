import { NextResponse } from 'next/server';
import { flumeClient } from '@/lib/flume';

export async function POST(request: Request) {
  try {
    let refreshToken = null;
    try {
      const body = await request.json();
      refreshToken = body?.refreshToken;
    } catch (e) {
      // Body is empty or not JSON, proceed with normal login
    }

    let tokenData;
    if (refreshToken) {
      tokenData = await flumeClient.refreshAccessToken(refreshToken);
    } else {
      tokenData = await flumeClient.getAccessToken();
    }

    console.log('[Auth Route] Token received from Flume. Access Token length:', tokenData.access_token?.length);
    if (tokenData.access_token && tokenData.access_token.length < 20) {
      console.error('[Auth Route] Warning: Access token looks suspiciously short:', tokenData.access_token);
    }

    return NextResponse.json(tokenData);
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    const axiosError = error as { response?: { data?: unknown } };
    console.error('Flume Auth Error:', axiosError.response?.data || message);
    return NextResponse.json(
      { error: 'Authentication failed', details: axiosError.response?.data || message },
      { status: 500 }
    );
  }
}
