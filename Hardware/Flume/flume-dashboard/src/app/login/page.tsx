'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { updateFlumeConfig } from '../settings/actions';
import { useFlume } from '@/components/FlumeContext';

export default function LoginPage() {
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();
  const { login } = useFlume();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSaving(true);
    setError(null);

    const formData = new FormData(e.currentTarget);
    const result = await updateFlumeConfig(formData);

    if (result.success) {
      await login(); // Refresh context
      router.push('/');
    } else {
      setError(result.error || 'Failed to authenticate with Flume');
    }
    setIsSaving(false);
  };

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-black flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white dark:bg-zinc-900 rounded-2xl shadow-xl border border-zinc-200 dark:border-zinc-800 p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-blue-600 mb-2">Flume Dash</h1>
          <p className="text-zinc-500">Connect your Flume account to get started</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1">
            <label className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">Client ID</label>
            <input 
              name="clientId" 
              type="text" 
              required 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-lg px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all dark:bg-zinc-800 dark:border-zinc-700" 
              placeholder="Your Flume Client ID" 
            />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">Client Secret</label>
            <input 
              name="clientSecret" 
              type="password" 
              required 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-lg px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all dark:bg-zinc-800 dark:border-zinc-700" 
              placeholder="Your Flume Client Secret" 
            />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">Email (Flume Username)</label>
            <input 
              name="username" 
              type="email" 
              required 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-lg px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all dark:bg-zinc-800 dark:border-zinc-700" 
              placeholder="your@email.com" 
            />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-semibold text-zinc-400 uppercase tracking-wider">Password</label>
            <input 
              name="password" 
              type="password" 
              required 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-lg px-4 py-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all dark:bg-zinc-800 dark:border-zinc-700" 
              placeholder="Your Flume Password" 
            />
          </div>

          {error && (
            <div className="p-3 bg-red-50 border border-red-100 rounded-lg text-xs text-red-600 font-medium dark:bg-red-900/20 dark:border-red-900/40">
              {error}
            </div>
          )}

          <button 
            type="submit" 
            disabled={isSaving}
            className="w-full bg-blue-600 text-white rounded-lg py-3 text-sm font-semibold hover:bg-blue-700 active:scale-[0.98] transition-all disabled:opacity-50 mt-4 shadow-lg shadow-blue-500/20"
          >
            {isSaving ? 'Verifying...' : 'Connect to Flume'}
          </button>
        </form>

        <div className="mt-8 pt-6 border-t border-zinc-100 dark:border-zinc-800 text-center">
          <p className="text-xs text-zinc-500">
            Need help finding your credentials? 
            <a href="/docs/usage-guide#retrieving-your-flume-api-secrets" className="text-blue-600 hover:underline ml-1">View Guide</a>
          </p>
        </div>
      </div>
    </div>
  );
}
