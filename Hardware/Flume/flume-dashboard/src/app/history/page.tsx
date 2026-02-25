'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { UsageChart } from '@/components/UsageChart';
import axios from 'axios';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';

export default function HistoryPage() {
  const { token, user, selectedDevice } = useFlume();
  const [usageData, setUsageData] = useState<Array<{datetime: string, value: number}>>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [startDate, setStartDate] = useState(format(subDays(new Date(), 30), 'yyyy-MM-dd'));
  const [endDate, setEndDate] = useState(format(new Date(), 'yyyy-MM-dd'));
  const [granularity, setGranularity] = useState('DAY');

  const fetchUsage = useCallback(async () => {
    if (!token || !user || !selectedDevice) return;

    setIsLoading(true);
    setError(null);
    try {
      const since = startOfDay(new Date(startDate)).toISOString();
      const until = endOfDay(new Date(endDate)).toISOString();
      
      const response = await axios.get('/api/flume/usage', {
        headers: {
          Authorization: `Bearer ${token?.access_token}`,
        },
        params: {
          userId: user?.id,
          deviceId: selectedDevice?.id,
          since,
          until,
          bucket: granularity,
          unit: 'GALLONS',
        },
      });
      
      if (response.data.error) {
        throw new Error(`${response.data.error}: ${JSON.stringify(response.data.details)}`);
      }
      
      const buckets = response.data.data;
      setUsageData(buckets);
    } catch (err: unknown) {
      console.error('Failed to fetch usage:', err);
      setError('Could not load usage data. Check your date range and API limits.');
    } finally {
      setIsLoading(false);
    }
  }, [token, user, selectedDevice, startDate, endDate, granularity]);

  useEffect(() => {
    fetchUsage();
  }, [fetchUsage]);

  return (
    <Shell>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">Historical Explorer</h2>
        <p className="text-zinc-500">Analyze your water usage over time</p>
      </div>

      <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800 mb-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
          <div>
            <label className="block text-xs font-semibold text-zinc-400 uppercase mb-2">From</label>
            <input 
              type="date" 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-zinc-400 uppercase mb-2">To</label>
            <input 
              type="date" 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-zinc-400 uppercase mb-2">Granularity</label>
            <select 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700"
              value={granularity}
              onChange={(e) => setGranularity(e.target.value)}
            >
              <option value="1h">Hourly</option>
              <option value="DAY">Daily</option>
              <option value="MON">Monthly</option>
            </select>
          </div>
          <div>
            <button 
              onClick={fetchUsage}
              className="w-full bg-blue-600 text-white rounded-md px-4 py-2 text-sm font-medium hover:bg-blue-700 transition-colors"
            >
              Update View
            </button>
          </div>
        </div>
      </div>

      <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50">Usage Patterns</h3>
          <div className="text-sm text-zinc-500">
            Total for period: <span className="font-bold text-zinc-900 dark:text-zinc-50">{usageData ? usageData.reduce((acc, curr) => acc + (curr.value || 0), 0).toFixed(1) : '0.0'} gal</span>
          </div>
        </div>
        
        {isLoading ? (
          <div className="h-80 flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : error ? (
          <div className="h-80 flex items-center justify-center text-red-500">{error}</div>
        ) : (
          <UsageChart data={usageData} unit="gal" />
        )}
      </div>
    </Shell>
  );
}
