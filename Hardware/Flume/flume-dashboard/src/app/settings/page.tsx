'use client';

import React from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';

export default function SettingsPage() {
  const { user, selectedDevice, token } = useFlume();

  return (
    <Shell>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">Settings</h2>
        <p className="text-zinc-500">Manage your dashboard preferences and account</p>
      </div>

      <div className="space-y-6">
        <section className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Display Units</h3>
          <div className="flex items-center gap-4">
            <button className="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium">
              Gallons (GAL)
            </button>
            <button className="px-4 py-2 bg-zinc-100 text-zinc-600 rounded-md text-sm font-medium hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-400">
              Liters (L)
            </button>
          </div>
          <p className="mt-2 text-sm text-zinc-500 italic">Changing units will update all charts (Coming soon).</p>
        </section>

        <section className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4">Account Status</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">User</label>
              <p className="text-sm text-zinc-900 dark:text-zinc-50 font-medium">
                {user ? `${user.first_name} ${user.last_name}` : 'Not Loaded'}
              </p>
            </div>
            <div>
              <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">Email</label>
              <p className="text-sm text-zinc-900 dark:text-zinc-50 font-medium">
                {user?.email || '••••••••@••••.com'}
              </p>
            </div>
            <div>
              <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">Selected Device ID</label>
              <p className="text-sm text-mono text-zinc-900 dark:text-zinc-50 font-medium">
                {selectedDevice?.id || 'No device selected'}
              </p>
            </div>
            <div>
              <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">API Status</label>
              <div className="flex items-center gap-2 mt-1">
                <div className={`w-2 h-2 rounded-full ${token ? 'bg-green-500' : 'bg-red-500'}`}></div>
                <p className="text-sm font-medium text-zinc-900 dark:text-zinc-50">
                  {token ? 'Connected' : 'Disconnected'}
                </p>
              </div>
            </div>
          </div>
        </section>

        <section className="bg-white p-6 rounded-xl border border-zinc-200 shadow-sm dark:bg-zinc-900 dark:border-zinc-800">
          <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50 mb-4 text-red-600">Danger Zone</h3>
          <button 
            onClick={() => {
              localStorage.removeItem('flume_refresh_token');
              window.location.reload();
            }}
            className="px-4 py-2 border border-red-200 text-red-600 rounded-md text-sm font-medium hover:bg-red-50 dark:border-red-900 dark:hover:bg-red-950 transition-colors"
          >
            Reset Session & Logout
          </button>
        </section>
      </div>
    </Shell>
  );
}
