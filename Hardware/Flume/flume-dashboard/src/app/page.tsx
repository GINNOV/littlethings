'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { UsageChart } from '@/components/UsageChart';
import { BreakdownChart } from '@/components/BreakdownChart';
import axios from 'axios';
import { subDays, startOfDay, endOfDay, format } from 'date-fns';
import { 
  Droplets, 
  Calendar, 
  Activity, 
  RefreshCw,
  TrendingUp,
  PieChart as PieChartIcon
} from 'lucide-react';

interface BreakdownItem {
  name: string;
  value: number;
  color: string;
}

export default function Home() {
  const { token, user, selectedDevice } = useFlume();
  const [dailyUsage, setDailyUsage] = useState<Array<{datetime: string, value: number}>>([]);
  const [breakdownData, setBreakdownData] = useState<BreakdownItem[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isBreakdownLoading, setIsBreakdownLoading] = useState(false);
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

  const fetchBreakdown = useCallback(async () => {
    if (!token || !user || !selectedDevice) return;
    
    setIsBreakdownLoading(true);
    try {
      const until = endOfDay(subDays(new Date(), 1)).toISOString();
      const since = startOfDay(subDays(new Date(), 30)).toISOString();
      const applianceTypes = ['ALL', 'OUTDOOR', 'IRRIGATION', 'INDOOR', 'SHOWER', 'TOILET', 'CLOTHES_WASHER', 'DISH_WASHER', 'FAUCET', 'LEAK'];
      
      let response = await axios.get('/api/flume/usage', {
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
          types: applianceTypes.join(','),
        },
      });

      if (response.data.error || !response.data.data || response.data.data.length === 0) {
        response = await axios.get('/api/flume/usage', {
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
      }

      if (response.data.error) {
        setBreakdownData([]);
        return;
      }

      const rawBuckets = response.data.data;
      if (Array.isArray(rawBuckets)) {
        const totals: {[key: string]: number} = {};
        const normalizeTypeKey = (key: string) => {
          const normalized = key.toLowerCase().trim();
          const aliases: Record<string, string> = {
            faucets: 'faucet',
            toilets: 'toilet',
            showers: 'shower',
            leaks: 'leak',
          };
          return aliases[normalized] || normalized;
        };
        
        rawBuckets.forEach((bucket: Record<string, unknown>) => {
          let hasCategorizedData = false;
          const allPotentialKeys = [...applianceTypes, 'indoor', 'outdoor', 'water'];
          allPotentialKeys.forEach(key => {
            if (bucket[key] !== undefined) {
              hasCategorizedData = true;
              const normalizedKey = normalizeTypeKey(key);
              totals[normalizedKey] = (totals[normalizedKey] || 0) + Number(bucket[key]);
            }
          });

          if (bucket.types && typeof bucket.types === 'object') {
            Object.entries(bucket.types as Record<string, unknown>).forEach(([typeKey, rawValue]) => {
              hasCategorizedData = true;
              const normalizedKey = normalizeTypeKey(typeKey);
              totals[normalizedKey] = (totals[normalizedKey] || 0) + Number(rawValue);
            });
          }

          if (!hasCategorizedData && typeof bucket.value === 'number') {
            totals.uncategorized = (totals.uncategorized || 0) + bucket.value;
          }
        });

        const colors: {[key: string]: string} = {
          'outdoor': '#3b82f6',
          'indoor': '#60a5fa',
          'shower': '#93c5fd',
          'toilet': '#bfdbfe',
          'clothes_washer': '#1d4ed8',
          'dishwasher': '#2563eb',
          'faucet': '#94a3b8',
          'irrigation': '#1e40af',
          'uncategorized': '#cbd5e1',
        };

        const finalBreakdown = Object.keys(totals)
          .map(key => ({
            name: key.charAt(0).toUpperCase() + key.slice(1).replace('_', ' '),
            value: totals[key],
            color: colors[key] || '#cbd5e1'
          }))
          .filter(item => item.value > 0 && item.name !== 'Uncategorized')
          .sort((a, b) => b.value - a.value);

        setBreakdownData(finalBreakdown);
      }
    } catch (err) {
      console.error('Failed to fetch breakdown:', err);
      setBreakdownData([]);
    } finally {
      setIsBreakdownLoading(false);
    }
  }, [token, user, selectedDevice]);

  useEffect(() => {
    fetchDailyUsage();
    fetchBreakdown();
  }, [fetchDailyUsage, fetchBreakdown]);

  const todayUsage = (dailyUsage && dailyUsage.length > 0)
    ? dailyUsage[dailyUsage.length - 1].value 
    : 0;
  
  const totalPeriodUsage = dailyUsage ? dailyUsage.reduce((acc, curr) => acc + (curr.value || 0), 0) : 0;

  return (
    <Shell>
      <div className="mb-8 flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="text-3xl font-extrabold text-zinc-900 dark:text-zinc-50 tracking-tight">Water Dashboard</h2>
          <p className="text-zinc-500 font-medium">Insights for {selectedDevice?.name || 'your home'}</p>
        </div>
        <div className="flex items-center gap-2 text-sm font-semibold text-zinc-400 bg-white dark:bg-zinc-900 px-4 py-2 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
          <Calendar className="w-4 h-4" />
          {format(new Date(), 'MMMM d, yyyy')}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
        <div className="relative overflow-hidden bg-white p-6 rounded-3xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800 group hover:border-blue-500/30 transition-all duration-300">
          <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
            <Droplets className="w-16 h-16 text-blue-600" />
          </div>
          <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-widest mb-2">Today&apos;s Usage</h3>
          <div className="flex items-baseline gap-2">
            <p className="text-4xl font-black text-blue-600 tracking-tighter">{todayUsage.toFixed(1)}</p>
            <span className="text-lg font-bold text-zinc-400 tracking-tight">gallons</span>
          </div>
          <div className="mt-4 flex items-center gap-2 text-xs font-bold text-green-600 bg-green-50 dark:bg-green-900/20 w-fit px-2.5 py-1 rounded-full">
            <TrendingUp className="w-3 h-3" />
            Live tracking
          </div>
        </div>

        <div className="relative overflow-hidden bg-white p-6 rounded-3xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800 group hover:border-blue-500/30 transition-all duration-300">
          <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
            <Activity className="w-16 h-16 text-zinc-600 dark:text-zinc-100" />
          </div>
          <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-widest mb-2">Last 14 Days</h3>
          <div className="flex items-baseline gap-2">
            <p className="text-4xl font-black text-zinc-900 dark:text-zinc-100 tracking-tighter">{totalPeriodUsage.toFixed(0)}</p>
            <span className="text-lg font-bold text-zinc-400 tracking-tight">gallons</span>
          </div>
          <p className="mt-4 text-xs font-bold text-zinc-500">Avg: {(totalPeriodUsage / 14).toFixed(1)} gal/day</p>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800 group hover:border-blue-500/30 transition-all duration-300 flex flex-col justify-between">
          <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-widest mb-2">System Status</h3>
          <div className="flex items-center gap-4 bg-zinc-50 dark:bg-zinc-800/50 p-4 rounded-2xl border border-zinc-100 dark:border-zinc-800">
            <div className="relative">
              <div className="w-4 h-4 rounded-full bg-green-500 animate-ping absolute inset-0 opacity-40"></div>
              <div className="w-4 h-4 rounded-full bg-green-500 relative z-10"></div>
            </div>
            <div>
              <p className="text-lg font-black text-zinc-900 dark:text-zinc-50 leading-tight">Connected</p>
              <p className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Flume Bridge Active</p>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
        <div className="lg:col-span-2 bg-white p-8 rounded-[2rem] border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-50 dark:bg-blue-900/20 rounded-xl">
                <TrendingUp className="w-5 h-5 text-blue-600" />
              </div>
              <h3 className="text-xl font-bold text-zinc-900 dark:text-zinc-50 tracking-tight">Consumption Trends</h3>
            </div>
            <button 
              onClick={fetchDailyUsage}
              disabled={isLoading}
              className="p-2 hover:bg-zinc-50 dark:hover:bg-zinc-800 rounded-xl transition-all active:rotate-180 duration-500 group"
            >
              <RefreshCw className={`w-5 h-5 text-zinc-400 group-hover:text-blue-600 ${isLoading ? 'animate-spin' : ''}`} />
            </button>
          </div>
          
          <div className="h-80">
            {isLoading ? (
              <div className="h-full flex flex-col items-center justify-center gap-3">
                <div className="w-12 h-1 bg-zinc-100 dark:bg-zinc-800 rounded-full overflow-hidden">
                  <div className="w-1/2 h-full bg-blue-600 rounded-full animate-loader"></div>
                </div>
                <p className="text-xs font-bold text-zinc-400 uppercase tracking-widest">Loading trends...</p>
              </div>
            ) : error ? (
              <div className="h-full flex items-center justify-center text-red-500 font-bold italic">{error}</div>
            ) : (
              <UsageChart data={dailyUsage} unit="gal" granularity="DAY" />
            )}
          </div>
        </div>

        <div className="bg-white p-8 rounded-[2rem] border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800 flex flex-col">
          <div className="flex items-center gap-3 mb-8">
            <div className="p-2 bg-purple-50 dark:bg-purple-900/20 rounded-xl">
              <PieChartIcon className="w-5 h-5 text-purple-600" />
            </div>
            <h3 className="text-xl font-bold text-zinc-900 dark:text-zinc-50 tracking-tight">Appliance Mix</h3>
          </div>
          
          <div className="flex-1 min-h-[320px]">
            {isBreakdownLoading ? (
              <div className="h-full flex items-center justify-center">
                <div className="animate-pulse flex flex-col items-center gap-4">
                  <div className="w-32 h-32 rounded-full border-8 border-zinc-100 dark:border-zinc-800 border-t-purple-500 animate-spin"></div>
                  <p className="text-xs font-bold text-zinc-400 uppercase tracking-widest">Analyzing usage...</p>
                </div>
              </div>
            ) : (
              <BreakdownChart data={breakdownData} unit="gal" />
            )}
          </div>
          
          <div className="mt-6 p-4 bg-zinc-50 dark:bg-zinc-800/30 rounded-2xl border border-zinc-100 dark:border-zinc-800">
            <p className="text-xs text-zinc-500 font-medium leading-relaxed">
              Based on the last 30 days of appliance disaggregation from your Flume Smart Water Monitor.
            </p>
          </div>
        </div>
      </div>
    </Shell>
  );
}
