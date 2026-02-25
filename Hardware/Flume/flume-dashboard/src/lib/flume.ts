import axios from 'axios';

const FLUME_BASE_URL = 'https://api.flumewater.com';

export interface FlumeTokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

export interface FlumeDevice {
  id: string;
  name: string;
  type: number;
  location_id: string;
}

export interface FlumeUser {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
}

export interface FlumeDeviceListResponse {
  data: Array<{
    id: string;
    user_id: number;
    name: string;
    type: number;
    location_id: string;
  }>;
}

export interface FlumeUsageQuery {
  request_id: string;
  bucket: string;
  since_datetime: string;
  until_datetime: string;
  unit_of_measure: 'GALLONS' | 'LITERS';
  group_multiplier?: number;
  types?: string[];
}

export interface FlumeUsageResponse {
  data: Array<{
    request_id: string;
    buckets: Array<{
      datetime: string;
      value: number;
    }>;
  }>;
}

export class FlumeClient {
  private clientId: string;
  private clientSecret: string;
  private username?: string;
  private password?: string;

  constructor() {
    this.clientId = process.env.FLUME_CLIENT_ID || '';
    this.clientSecret = process.env.FLUME_CLIENT_SECRET || '';
    this.username = process.env.FLUME_USERNAME;
    this.password = process.env.FLUME_PASSWORD;

    if (!this.clientId || !this.clientSecret) {
      console.warn('Flume credentials missing in environment variables');
    }
  }

  async getAccessToken(): Promise<FlumeTokenResponse> {
    if (!this.username || !this.password) {
      throw new Error('Username or password missing');
    }

    const response = await axios.post(`${FLUME_BASE_URL}/oauth/token`, {
      grant_type: 'password',
      username: this.username,
      password: this.password,
      client_id: this.clientId,
      client_secret: this.clientSecret,
    });

    console.log('[FlumeClient] /oauth/token Raw Response:', JSON.stringify(response.data, null, 2));
    
    // If the response follows the standard envelope { success: true, data: [...] }
    if (response.data.data && Array.isArray(response.data.data)) {
      return response.data.data[0];
    }
    
    return response.data;
  }

  async refreshAccessToken(refreshToken: string): Promise<FlumeTokenResponse> {
    const response = await axios.post<FlumeTokenResponse>(`${FLUME_BASE_URL}/oauth/token`, {
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: this.clientId,
      client_secret: this.clientSecret,
    });

    return response.data;
  }

  async getDevices(accessToken: string, userId: number): Promise<FlumeDevice[]> {
    const response = await axios.get<FlumeDeviceListResponse>(
      `${FLUME_BASE_URL}/users/${userId}/devices`,
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );
    return response.data.data;
  }

  async getUserInfo(accessToken: string): Promise<FlumeUser> {
    try {
      const response = await axios.get<{ data: FlumeUser[] }>(`${FLUME_BASE_URL}/me`, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });
      
      console.log('Flume /me Raw Response:', JSON.stringify(response.data, null, 2));
      
      if (!response.data || !response.data.data || response.data.data.length === 0) {
        console.error('Flume API returned empty user data:', response.data);
        throw new Error('No user data found in Flume response');
      }

      return response.data.data[0];
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      const axiosError = error as { response?: { data?: unknown } };
      console.error('getUserInfo Error Detail:', axiosError.response?.data || message);
      throw error;
    }
  }

  async getUsage(
    accessToken: string,
    userId: number,
    deviceId: string,
    queries: FlumeUsageQuery[]
  ): Promise<FlumeUsageResponse> {
    const response = await axios.post<FlumeUsageResponse>(
      `${FLUME_BASE_URL}/users/${userId}/devices/${deviceId}/query`,
      { queries },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );
    return response.data;
  }
}

export const flumeClient = new FlumeClient();
