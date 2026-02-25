'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { UsageChart } from '@/components/UsageChart';
import { BreakdownChart } from '@/components/BreakdownChart';
import axios from 'axios';
import { subDays, startOfDay, endOfDay } from 'date-fns';

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
      // Flume appliance disaggregation is only guaranteed through the end of the previous day.
      const until = endOfDay(subDays(new Date(), 1)).toISOString();
      const since = startOfDay(subDays(new Date(), 30)).toISOString();
      
      // Flume docs: appliance types are uppercase constants.
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

      // Fallback: If categorized query fails, try a standard query and look for types in the response
      if (response.data.error || !response.data.data || response.data.data.length === 0) {
        console.warn('Categorized breakdown failed, trying fallback standard query');
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
        console.error('All breakdown attempts failed');
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
          // Check for keys in the bucket object directly
          const allPotentialKeys = [...applianceTypes, 'indoor', 'outdoor', 'water'];
          allPotentialKeys.forEach(key => {
            if (bucket[key] !== undefined) {
              hasCategorizedData = true;
              const normalizedKey = normalizeTypeKey(key);
              totals[normalizedKey] = (totals[normalizedKey] || 0) + Number(bucket[key]);
            }
          });

          // Check if there is a 'types' object inside the bucket
          if (bucket.types && typeof bucket.types === 'object') {
            if (Array.isArray(bucket.types)) {
              bucket.types.forEach((item: unknown) => {
                if (item && typeof item === 'object' && 'type' in item && 'value' in item) {
                  hasCategorizedData = true;
                  const typeKey = normalizeTypeKey(String((item as { type: unknown }).type));
                  totals[typeKey] = (totals[typeKey] || 0) + Number((item as { value: unknown }).value);
                }
              });
            } else {
              Object.entries(bucket.types as Record<string, unknown>).forEach(([typeKey, rawValue]) => {
                hasCategorizedData = true;
                const normalizedKey = normalizeTypeKey(typeKey);
                totals[normalizedKey] = (totals[normalizedKey] || 0) + Number(rawValue);
              });
            }
          }

          if (!hasCategorizedData && typeof bucket.value === 'number') {
            totals.uncategorized = (totals.uncategorized || 0) + bucket.value;
          }
        });

        const colors: {[key: string]: string} = {
          'outdoor': '#3d8ea1',
          'indoor': '#83d1e2',
          'shower': '#b0effb',
          'toilet': '#a0b9a6',
          'clothes_washer': '#742d1e',
          'dishwasher': '#d88c6e',
          'faucet': '#94a3b8',
          'irrigation': '#3d8ea1',
          'uncategorized': '#64748b',
        };

        const hasCategorizedValues = Object.entries(totals).some(
          ([key, value]) => key !== 'uncategorized' && value > 0
        );

        if (!hasCategorizedValues) {
          setBreakdownData([]);
          return;
        }

        const finalBreakdown = Object.keys(totals)
          .map(key => ({
            name: key.charAt(0).toUpperCase() + key.slice(1).replace('_', ' '),
            value: totals[key],
            color: colors[key] || colors[key.toLowerCase()] || '#cbd5e1'
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

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
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

        <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Usage Breakdown</h3>
          {isBreakdownLoading ? (
            <div className="h-80 flex items-center justify-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            </div>
          ) : (
            <BreakdownChart data={breakdownData} unit="gal" />
          )}
        </div>
      </div>
    </Shell>
  );
}
