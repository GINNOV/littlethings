import { NextResponse } from 'next/server';
import { flumeClient, FlumeUsageQuery } from '@/lib/flume';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const authHeader = request.headers.get('Authorization');
  const accessToken = authHeader?.replace('Bearer ', '');
  
  const userId = searchParams.get('userId');
  const deviceId = searchParams.get('deviceId');
  const since = searchParams.get('since');
  const until = searchParams.get('until');
  let bucket = searchParams.get('bucket') || 'DAY';
  const unit = (searchParams.get('unit') as 'GALLONS' | 'LITERS') || 'GALLONS';

  // Map common bucket names to Flume's expected values
  const bucketMap: { [key: string]: string } = {
    '1h': 'HR',
    'DAY': 'DAY',
    'MON': 'MON',
    '1d': 'DAY',
    '1M': 'MON'
  };
  bucket = bucketMap[bucket] || bucket;

  console.log('[Usage Route] Params:', { userId, deviceId, since, until, bucket, unit });

  if (!accessToken) {
    return NextResponse.json({ error: 'Missing access token' }, { status: 401 });
  }

  if (!userId || !deviceId || !since || !until) {
    return NextResponse.json({ error: 'Missing required parameters' }, { status: 400 });
  }

  try {
    const requestId = 'usage_query';
    const queries = [
      {
        request_id: requestId,
        bucket,
        since_datetime: since.replace('T', ' ').split('.')[0], // Flume prefers YYYY-MM-DD HH:MM:SS
        until_datetime: until.replace('T', ' ').split('.')[0],
        unit_of_measure: unit,
        group_multiplier: 1,
      },
    ];

    const flumeUrl = `https://api.flumewater.com/users/${userId}/devices/${deviceId}/query`;
    console.log('[Usage Route] Fetching from:', flumeUrl);

    const response = await fetch(flumeUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ queries }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('[Usage Route] Flume API Error:', data);
      return NextResponse.json({ 
        error: 'Flume API Usage Error', 
        details: data,
        status: response.status 
      }, { status: 200 });
    }

    // Extract buckets using the request_id
    // Response looks like: { data: [ { "usage_query": [ {datetime, value}, ... ] } ] }
    let buckets = [];
    if (data.data && data.data[0] && data.data[0][requestId]) {
      buckets = data.data[0][requestId];
    } else {
      console.warn('[Usage Route] Could not find buckets in response structure:', JSON.stringify(data).slice(0, 200));
    }

    return NextResponse.json({ data: buckets });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('[Usage Route] Fatal Error:', message);
    return NextResponse.json(
      { error: 'Server Exception', details: message },
      { status: 200 }
    );
  }
}
