'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import axios from 'axios';
import { useRouter, usePathname } from 'next/navigation';
import { checkAuthConfig, logout as logoutAction } from '@/app/settings/actions';

interface FlumeToken {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

interface FlumeUser {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
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
  logout: () => Promise<void>;
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
  const router = useRouter();
  const pathname = usePathname();

  const logout = async () => {
    await logoutAction();
    setToken(null);
    setUser(null);
    setDevices([]);
    setSelectedDevice(null);
    localStorage.removeItem('flume_refresh_token');
    router.push('/login');
  };

  const login = async () => {
    setIsLoading(true);
    setError(null);
    try {
      // Skip auth check for login and documentation pages
      const isPublicPath = pathname === '/login' || pathname.startsWith('/docs');
      
      const authStatus = await checkAuthConfig();
      
      if (!authStatus.hasConfig) {
        if (!isPublicPath) {
          router.push('/login');
        }
        setIsLoading(false);
        return;
      }

      const response = await axios.post('/api/flume/auth');
      
      if (response.data.error) {
        throw new Error(response.data.details || response.data.error);
      }

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

      setUser(devicesResponse.data.user);
      setDevices(devicesResponse.data.devices);
      if (Array.isArray(devicesResponse.data.devices) && devicesResponse.data.devices.length > 0) {
        setSelectedDevice(devicesResponse.data.devices[0]);
      }
    } catch (err: unknown) {
      const axiosError = err as { response?: { data?: { error?: string, details?: any } } };
      console.error('Login failed:', axiosError);
      
      const errorMsg = axiosError.response?.data?.details?.error_description || 
                      axiosError.response?.data?.error || 
                      (err instanceof Error ? err.message : 'Failed to authenticate with Flume');
      
      setError(errorMsg);
      
      if (pathname !== '/login' && !pathname.startsWith('/docs')) {
        router.push('/login');
      }
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    login();
  }, [pathname]);

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
        logout,
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
