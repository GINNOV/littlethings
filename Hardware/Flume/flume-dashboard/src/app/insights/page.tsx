'use client';

import React from 'react';
import { Shell } from '@/components/Shell';

export default function InsightsPage() {
  return (
    <Shell>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">Insights & Alerts</h2>
        <p className="text-zinc-500">Anomaly detection and usage notifications</p>
      </div>

      <div className="grid grid-cols-1 gap-6">
        <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Recent Alerts</h3>
          <div className="flex flex-col items-center justify-center py-12 text-zinc-400">
            <svg className="w-12 h-12 mb-4 opacity-20" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <p>No active alerts detected</p>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Usage Anomalies</h3>
          <p className="text-sm text-zinc-500 mb-6">We analyze your historical data to find unusual patterns.</p>
          
          <div className="space-y-4">
            <div className="p-4 bg-zinc-50 rounded-lg dark:bg-zinc-800 border border-zinc-100 dark:border-zinc-700">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-zinc-900 dark:text-zinc-50">Leak Detection</span>
                <span className="px-2 py-0.5 text-xs font-semibold bg-green-100 text-green-700 rounded-full dark:bg-green-900/30 dark:text-green-400">Normal</span>
              </div>
              <p className="text-xs text-zinc-500 mt-1">No continuous flow detected in the last 24 hours.</p>
            </div>

            <div className="p-4 bg-zinc-50 rounded-lg dark:bg-zinc-800 border border-zinc-100 dark:border-zinc-700 opacity-50">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-zinc-900 dark:text-zinc-50">Unusual Daily Total</span>
                <span className="px-2 py-0.5 text-xs font-semibold bg-zinc-200 text-zinc-600 rounded-full dark:bg-zinc-700 dark:text-zinc-400">Processing</span>
              </div>
              <p className="text-xs text-zinc-500 mt-1">Analyzing baseline for comparison.</p>
            </div>
          </div>
        </div>
      </div>
    </Shell>
  );
}
