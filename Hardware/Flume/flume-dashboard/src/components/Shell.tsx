'use client';

import React from 'react';
import { Sidebar } from './Sidebar';
import { useFlume } from './FlumeContext';

export function Shell({ children }: { children: React.ReactNode }) {
  const { isLoading, error, login } = useFlume();

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-white dark:bg-black">
        <div className="animate-pulse text-blue-600 font-medium">Loading Flume data...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex h-screen flex-col items-center justify-center bg-white dark:bg-black p-4">
        <div className="text-red-500 font-medium mb-4">{error}</div>
        <button
          onClick={() => login()}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
        >
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white dark:bg-black">
      <Sidebar />
      <main className="pl-64 min-h-screen">
        <div className="max-w-6xl mx-auto p-8">
          {children}
        </div>
      </main>
    </div>
  );
}
