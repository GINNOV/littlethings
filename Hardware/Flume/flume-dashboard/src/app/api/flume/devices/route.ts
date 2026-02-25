import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const authHeader = request.headers.get('Authorization');
  console.log('[Devices Route] Received Auth Header length:', authHeader?.length);
  const accessToken = authHeader?.replace('Bearer ', '');

  if (!accessToken) {
    console.error('[Devices Route] Missing access token');
    return NextResponse.json({ error: 'Missing access token' }, { status: 401 });
  }

  try {
    console.log('[Devices Route] Attempting to fetch user info...');
    const userRes = await fetch('https://api.flumewater.com/me', {
      headers: { Authorization: `Bearer ${accessToken}` }
    });

    const userDataRaw = await userRes.json();
    console.log('[Devices Route] User data received:', JSON.stringify(userDataRaw).slice(0, 100) + '...');

    if (!userRes.ok) {
      return NextResponse.json({ 
        error: 'Flume API User Error', 
        details: userDataRaw,
        status: userRes.status 
      }, { status: 200 }); // Return 200 so we can see the body in the client
    }

    console.log('[Devices Route] Attempting to fetch devices...');
    const devicesRes = await fetch('https://api.flumewater.com/me/devices', {
      headers: { Authorization: `Bearer ${accessToken}` }
    });

    const devicesDataRaw = await devicesRes.json();
    console.log('[Devices Route] Devices data received:', JSON.stringify(devicesDataRaw).slice(0, 100) + '...');

    if (!devicesRes.ok) {
      return NextResponse.json({ 
        error: 'Flume API Devices Error', 
        details: devicesDataRaw,
        status: devicesRes.status 
      }, { status: 200 });
    }

    const user = userDataRaw.data?.[0] || userDataRaw.data || userDataRaw;
    
    // Attempt to find devices in multiple possible locations
    let rawDevices = [];
    if (Array.isArray(devicesDataRaw.data)) {
      rawDevices = devicesDataRaw.data;
    } else if (Array.isArray(devicesDataRaw)) {
      rawDevices = devicesDataRaw;
    } else if (user && Array.isArray(user.devices)) {
      rawDevices = user.devices;
    }

    console.log('[Devices Route] Raw Device Keys:', rawDevices[0] ? Object.keys(rawDevices[0]) : 'No devices');
    if (rawDevices[0]) {
      console.log('[Devices Route] First Raw Device:', JSON.stringify(rawDevices[0]));
    }

    // Map to a consistent format
    const devices = rawDevices.map((d: any) => ({
      id: d.id || d.device_id,
      name: d.name || d.device_name || `Device ${String(d.id || d.device_id || '').slice(-4)}`,
      type: d.type,
      location_id: d.location_id
    }));

    if (devices[0]) {
      console.log('[Devices Route] First Mapped Device:', JSON.stringify(devices[0]));
    }

    console.log('[Devices Route] Extracted User:', JSON.stringify(user).slice(0, 100));
    console.log('[Devices Route] Final Devices Count:', devices.length);

    return NextResponse.json({ user, devices });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('[Devices Route] Fatal Catch:', message);
    return NextResponse.json(
      { error: 'Server Exception', details: message },
      { status: 200 } // Still return 200 to see the message
    );
  }
}
