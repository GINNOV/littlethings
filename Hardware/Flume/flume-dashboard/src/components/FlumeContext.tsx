'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import axios from 'axios';

interface FlumeToken {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

interface FlumeUser {
  id: number;
  first_name: string;
  last_name: string;
}

interface FlumeDevice {
  id: string;
  name: string;
}

interface FlumeContextType {
  token: FlumeToken | null;
  user: FlumeUser | null;
  devices: FlumeDevice[];
  selectedDevice: FlumeDevice | null;
  isLoading: boolean;
  error: string | null;
  login: () => Promise<void>;
  setSelectedDevice: (device: FlumeDevice) => void;
}

const FlumeContext = createContext<FlumeContextType | undefined>(undefined);

export function FlumeProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<FlumeToken | null>(null);
  const [user, setUser] = useState<FlumeUser | null>(null);
  const [devices, setDevices] = useState<FlumeDevice[]>([]);
  const [selectedDevice, setSelectedDevice] = useState<FlumeDevice | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const login = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await axios.post('/api/flume/auth');
      setToken(response.data);
      localStorage.setItem('flume_refresh_token', response.data.refresh_token);
      
      // After login, fetch devices
      const devicesResponse = await axios.get('/api/flume/devices', {
        headers: {
          Authorization: `Bearer ${response.data.access_token}`,
        },
      });

      if (devicesResponse.data.error) {
        throw new Error(`${devicesResponse.data.error}: ${JSON.stringify(devicesResponse.data.details)}`);
      }

      if (!devicesResponse.data.devices) {
        console.error('No devices found in response:', devicesResponse.data);
        throw new Error('No devices found in your Flume account');
      }

      setUser(devicesResponse.data.user);
      setDevices(devicesResponse.data.devices);
      if (Array.isArray(devicesResponse.data.devices) && devicesResponse.data.devices.length > 0) {
        setSelectedDevice(devicesResponse.data.devices[0]);
      }
    } catch (err: unknown) {
      const axiosError = err as { response?: { data?: { error?: string } } };
      console.error('Login failed:', axiosError);
      setError(axiosError.response?.data?.error || 'Failed to authenticate with Flume');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    // Try to auto-login on mount
    login();
  }, []);

  return (
    <FlumeContext.Provider
      value={{
        token,
        user,
        devices,
        selectedDevice,
        isLoading,
        error,
        login,
        setSelectedDevice,
      }}
    >
      {children}
    </FlumeContext.Provider>
  );
}

export function useFlume() {
  const context = useContext(FlumeContext);
  if (context === undefined) {
    throw new Error('useFlume must be used within a FlumeProvider');
  }
  return context;
}
