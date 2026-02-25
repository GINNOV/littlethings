import { NextResponse } from 'next/server';
import type { FlumeUsageQuery } from '@/lib/flume';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const authHeader = request.headers.get('Authorization');
  const accessToken = authHeader?.replace('Bearer ', '');
  
  const userId = searchParams.get('userId');
  const deviceId = searchParams.get('deviceId');
  const since = searchParams.get('since');
  const until = searchParams.get('until');
  const bucket = searchParams.get('bucket') || 'DAY';
  const bucketMap: Record<string, string> = {
    '1h': 'HR',
    DAY: 'DAY',
    MON: 'MON',
    '1d': 'DAY',
    '1M': 'MON',
  };
  const normalizedBucket = bucketMap[bucket] || bucket;
  const unit = (searchParams.get('unit') as 'GALLONS' | 'LITERS') || 'GALLONS';
  const typesParam = searchParams.get('types');
  
  const types = typesParam
    ? typesParam
        .split(',')
        .map((t) => t.trim())
        .filter(Boolean)
    : null;

  console.log('[Usage Route] Params:', { userId, deviceId, since, until, bucket: normalizedBucket, unit, types });

  if (!accessToken) {
    return NextResponse.json({ error: 'Missing access token' }, { status: 401 });
  }

  if (!userId || !deviceId || !since || !until) {
    return NextResponse.json({ error: 'Missing required parameters' }, { status: 400 });
  }

  try {
    const requestId = 'usage_query';
    const baseQuery: FlumeUsageQuery = {
      request_id: requestId,
      bucket: normalizedBucket,
      since_datetime: since.replace('T', ' ').split('.')[0],
      until_datetime: until.replace('T', ' ').split('.')[0],
      unit_of_measure: unit,
      group_multiplier: 1,
    };

    const queryWithTypes =
      types && types.length > 0
        ? { ...baseQuery, types }
        : baseQuery;

    const flumeUrl = `https://api.flumewater.com/users/${userId}/devices/${deviceId}/query`;
    console.log('[Usage Route] Fetching from:', flumeUrl);

    const requestFlume = async (queryPayload: unknown) => {
      const response = await fetch(flumeUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ queries: [queryPayload] }),
      });
      const data = await response.json();
      return { response, data };
    };

    let { response, data } = await requestFlume(queryWithTypes);

    const isTypesValidationError = Boolean(
      response.status === 400 &&
      data?.code === 94 &&
      Array.isArray(data?.detailed) &&
      data.detailed.some((d: { field?: string }) => d?.field === 'types')
    );

    if (isTypesValidationError && queryWithTypes !== baseQuery) {
      console.warn('[Usage Route] Invalid "types" filter. Retrying without types.');
      ({ response, data } = await requestFlume(baseQuery));
    }

    if (!response.ok) {
      console.error('[Usage Route] Flume API Error:', data);
      return NextResponse.json({ 
        error: 'Flume API Usage Error', 
        details: data,
        status: response.status 
      }, { status: 200 });
    }

    // Extract buckets using the request_id
    let resultData = [];
    if (data.data && data.data[0] && data.data[0][requestId]) {
      resultData = data.data[0][requestId];
      if (resultData.length > 0) {
        console.log('[Usage Route] Sample Bucket structure:', JSON.stringify(resultData[0]));
      }
    } else {
      console.warn('[Usage Route] Could not find buckets in response structure:', JSON.stringify(data).slice(0, 200));
    }

    return NextResponse.json({ data: resultData });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('[Usage Route] Fatal Error:', message);
    return NextResponse.json(
      { error: 'Server Exception', details: message },
      { status: 200 }
    );
  }
}
