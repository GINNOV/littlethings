'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { UsageChart } from '@/components/UsageChart';
import axios from 'axios';
import { subDays, startOfDay, endOfDay } from 'date-fns';

export default function Home() {
  const { token, user, selectedDevice } = useFlume();
  const [dailyUsage, setDailyUsage] = useState<Array<{datetime: string, value: number}>>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchDailyUsage = useCallback(async () => {
    if (!token || !user || !selectedDevice) return;
    
    setIsLoading(true);
    setError(null);
    try {
      const until = endOfDay(new Date()).toISOString();
      const since = startOfDay(subDays(new Date(), 14)).toISOString();
      
      const response = await axios.get('/api/flume/usage', {
        headers: {
          Authorization: `Bearer ${token?.access_token}`,
        },
        params: {
          userId: user?.id,
          deviceId: selectedDevice?.id,
          since,
          until,
          bucket: 'DAY',
          unit: 'GALLONS',
        },
      });
      
      if (response.data.error) {
        throw new Error(`${response.data.error}: ${JSON.stringify(response.data.details)}`);
      }
      
      const buckets = response.data.data;
      setDailyUsage(buckets);
    } catch (err: unknown) {
      console.error('Failed to fetch usage:', err);
      setError('Could not load usage data');
    } finally {
      setIsLoading(false);
    }
  }, [token, user, selectedDevice]);

  useEffect(() => {
    fetchDailyUsage();
  }, [fetchDailyUsage]);

  const todayUsage = (dailyUsage && dailyUsage.length > 0)
    ? dailyUsage[dailyUsage.length - 1].value 
    : 0;
  
  const totalPeriodUsage = dailyUsage ? dailyUsage.reduce((acc, curr) => acc + (curr.value || 0), 0) : 0;

  return (
    <Shell>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">Dashboard</h2>
        <p className="text-zinc-500">Overview of your water usage</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-sm font-medium text-zinc-500 mb-1">Today&apos;s Usage</h3>
          <p className="text-3xl font-bold text-blue-600">{todayUsage.toFixed(1)} <span className="text-sm font-normal text-zinc-400">gal</span></p>
        </div>
        <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-sm font-medium text-zinc-500 mb-1">Last 14 Days</h3>
          <p className="text-3xl font-bold text-zinc-900 dark:text-zinc-50">{totalPeriodUsage.toFixed(0)} <span className="text-sm font-normal text-zinc-400">gal</span></p>
        </div>
        <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-sm font-medium text-zinc-500 mb-1">Status</h3>
          <div className="flex items-center gap-2 mt-1">
            <div className="w-2 h-2 rounded-full bg-green-500"></div>
            <p className="text-lg font-semibold text-zinc-900 dark:text-zinc-50">Monitoring</p>
          </div>
        </div>
      </div>

      <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50">Usage History (Last 14 Days)</h3>
          <button 
            onClick={fetchDailyUsage}
            className="text-sm text-blue-600 font-medium hover:underline"
          >
            Refresh
          </button>
        </div>
        
        {isLoading ? (
          <div className="h-80 flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : error ? (
          <div className="h-80 flex items-center justify-center text-red-500">{error}</div>
        ) : (
          <UsageChart data={dailyUsage} unit="gal" />
        )}
      </div>
    </Shell>
  );
}
