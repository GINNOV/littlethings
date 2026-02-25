import { NextResponse } from 'next/server';
import { getStoredConfig } from '@/lib/config';

export async function GET(request: Request) {
  const authHeader = request.headers.get('Authorization');
  const accessToken = authHeader?.replace('Bearer ', '');

  if (!accessToken) {
    return NextResponse.json({ error: 'Missing access token' }, { status: 401 });
  }

  try {
    const config = await getStoredConfig();
    const userRes = await fetch('https://api.flumewater.com/me', {
      headers: { Authorization: `Bearer ${accessToken}` }
    });

    const userDataRaw = await userRes.json();

    if (!userRes.ok) {
      return NextResponse.json({ 
        error: 'Flume API User Error', 
        details: userDataRaw,
        status: userRes.status 
      }, { status: 200 });
    }

    const devicesRes = await fetch('https://api.flumewater.com/me/devices', {
      headers: { Authorization: `Bearer ${accessToken}` }
    });

    const devicesDataRaw = await devicesRes.json();

    if (!devicesRes.ok) {
      return NextResponse.json({ 
        error: 'Flume API Devices Error', 
        details: devicesDataRaw,
        status: devicesRes.status 
      }, { status: 200 });
    }

    const apiUser = userDataRaw.data?.[0] || userDataRaw.data || userDataRaw;
    
    // Flume API often uses 'username' for the email, or it might be missing entirely from the /me response.
    // We'll prioritize 'email', then 'username', then fallback to our stored config or env vars.
    const user = {
      ...apiUser,
      email: apiUser.email || apiUser.username || config?.username || process.env.FLUME_USERNAME || ''
    };
    
    // Attempt to find devices in multiple possible locations
    let rawDevices = [];
    if (Array.isArray(devicesDataRaw.data)) {
      rawDevices = devicesDataRaw.data;
    } else if (Array.isArray(devicesDataRaw)) {
      rawDevices = devicesDataRaw;
    } else if (apiUser && Array.isArray(apiUser.devices)) {
      rawDevices = apiUser.devices;
    }

    // Map to a consistent format
    const devices = rawDevices.map((d: any) => ({
      id: d.id || d.device_id,
      name: d.name || d.device_name || `Device ${String(d.id || d.device_id || '').slice(-4)}`,
      type: d.type,
      location_id: d.location_id
    }));

    return NextResponse.json({ user, devices });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json(
      { error: 'Server Exception', details: message },
      { status: 200 }
    );
  }
}
