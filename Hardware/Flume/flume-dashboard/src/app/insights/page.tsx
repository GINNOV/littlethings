'use client';

import React, { useEffect, useState, useCallback } from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { calculateInsights, InsightResult } from '@/lib/analytics';
import axios from 'axios';
import { subDays, startOfDay, endOfDay, format, parseISO } from 'date-fns';

export default function InsightsPage() {
  const { token, user, selectedDevice } = useFlume();
  const [insights, setInsights] = useState<InsightResult | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchInsights = useCallback(async () => {
    if (!token || !user || !selectedDevice) return;

    setIsLoading(true);
    setError(null);
    try {
      const since = startOfDay(subDays(new Date(), 30)).toISOString();
      const until = endOfDay(new Date()).toISOString();
      
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
        throw new Error(response.data.error);
      }
      
      const buckets = response.data.data;
      const results = calculateInsights(buckets);
      setInsights(results);
    } catch (err: unknown) {
      console.error('Failed to fetch insights:', err);
      setError('Could not calculate insights. Check your data connection.');
    } finally {
      setIsLoading(false);
    }
  }, [token, user, selectedDevice]);

  useEffect(() => {
    fetchInsights();
  }, [fetchInsights]);

  return (
    <Shell>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">Usage Insights (ML Beta)</h2>
        <p className="text-zinc-500">Automated pattern detection and forecasting</p>
      </div>

      {isLoading ? (
        <div className="py-20 text-center text-blue-600 animate-pulse font-medium">
          Analyzing your water patterns...
        </div>
      ) : error ? (
        <div className="p-6 bg-red-50 text-red-600 rounded-xl border border-red-100 mb-8">
          {error}
        </div>
      ) : insights ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
            <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Statistical Anomalies</h3>
            {insights.anomalies.length > 0 ? (
              <div className="space-y-3">
                {insights.anomalies.map((a, i) => (
                  <div key={i} className="flex items-center justify-between p-3 bg-amber-50 dark:bg-amber-900/20 border border-amber-100 dark:border-amber-900/30 rounded-lg">
                    <div>
                      <p className="text-sm font-bold text-amber-900 dark:text-amber-200">{format(parseISO(a.datetime), 'EEEE, MMM do')}</p>
                      <p className="text-xs text-amber-700 dark:text-amber-400">Usage was {(a.value / insights.average).toFixed(1)}x higher than normal</p>
                    </div>
                    <span className="text-lg font-bold text-amber-600">{a.value.toFixed(0)} gal</span>
                  </div>
                ))}
              </div>
            ) : (
              <div className="py-8 text-center text-zinc-400 border border-dashed border-zinc-100 rounded-lg">
                No statistical anomalies detected in the last 30 days.
              </div>
            )}
          </div>

          <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
            <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Trend Analysis</h3>
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <span className="text-zinc-500">30-Day Velocity</span>
                <span className={`px-2 py-1 rounded text-xs font-bold uppercase ${
                  insights.trend === 'up' ? 'bg-red-100 text-red-700' : 
                  insights.trend === 'down' ? 'bg-green-100 text-green-700' : 'bg-zinc-100 text-zinc-600'
                }`}>
                  {insights.trend}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-zinc-500">Daily Average</span>
                <span className="font-bold text-zinc-900 dark:text-zinc-50">{insights.average.toFixed(1)} gal</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-zinc-500">30-Day Projected Total</span>
                <span className="font-bold text-blue-600">{insights.forecastedTotal.toFixed(0)} gal</span>
              </div>
              <div className="flex items-center justify-between border-t border-zinc-100 pt-4 mt-4">
                <span className="text-zinc-500">Peak Usage ({format(parseISO(insights.peakDate), 'MMM d')})</span>
                <span className="font-bold text-zinc-900 dark:text-zinc-50">{insights.peak.toFixed(0)} gal</span>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className="py-20 text-center text-zinc-400">
          Select a device to see insights.
        </div>
      )}
    </Shell>
  );
}
