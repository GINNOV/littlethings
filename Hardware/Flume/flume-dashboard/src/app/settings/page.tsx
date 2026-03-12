'use client';

import React, { useEffect, useState } from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { getEnvStatus, updateFlumeConfig, resetFlumeConfig } from './actions';

export default function SettingsPage() {
  const { user, selectedDevice, token, login } = useFlume();
  const [envStatus, setEnvStatus] = useState<any>({});
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);

  useEffect(() => {
    refreshStatus();
  }, []);

  const refreshStatus = () => {
    getEnvStatus().then(setEnvStatus);
  };

  const handleSave = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSaving(true);
    setSaveError(null);
    
    const formData = new FormData(e.currentTarget);
    const result = await updateFlumeConfig(formData);
    
    if (result.success) {
      setIsEditing(false);
      refreshStatus();
      await login(); // Re-authenticate with new creds
    } else {
      setSaveError(result.error || 'Failed to save configuration');
    }
    setIsSaving(false);
  };

  const handleReset = async () => {
    if (confirm('Are you sure you want to reset to environment variable defaults?')) {
      await resetFlumeConfig();
      refreshStatus();
      await login();
    }
  };

  return (
    <Shell>
      <div className="mb-8 flex justify-between items-end">
        <div>
          <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">Settings</h2>
          <p className="text-zinc-500">Manage your dashboard preferences and account</p>
        </div>
        {envStatus.isCustom && (
          <button 
            onClick={handleReset}
            className="text-xs text-red-500 hover:underline font-medium"
          >
            Reset to Environment Defaults
          </button>
        )}
      </div>

      <div className="space-y-6">
        {/* ... existing units section ... */}
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
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50">
              Environment Configuration 
              {envStatus.isCustom && <span className="ml-2 text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full dark:bg-blue-900/40 dark:text-blue-200">Custom</span>}
            </h3>
            {!isEditing && (
              <button 
                onClick={() => setIsEditing(true)}
                className="text-sm text-blue-600 hover:underline font-medium"
              >
                Edit Credentials
              </button>
            )}
          </div>

          {isEditing ? (
            <form onSubmit={handleSave} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-1">
                  <label className="text-xs font-semibold text-zinc-400 uppercase">Client ID</label>
                  <input name="clientId" type="text" required className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="Flume Client ID" />
                </div>
                <div className="space-y-1">
                  <label className="text-xs font-semibold text-zinc-400 uppercase">Client Secret</label>
                  <input name="clientSecret" type="password" required className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="Flume Client Secret" />
                </div>
                <div className="space-y-1">
                  <label className="text-xs font-semibold text-zinc-400 uppercase">Username (Email)</label>
                  <input name="username" type="email" required className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="your@email.com" />
                </div>
                <div className="space-y-1">
                  <label className="text-xs font-semibold text-zinc-400 uppercase">Password</label>
                  <input name="password" type="password" required className="w-full bg-zinc-50 border border-zinc-200 rounded-md px-3 py-2 text-sm dark:bg-zinc-800 dark:border-zinc-700" placeholder="Flume Password" />
                </div>
              </div>
              
              {saveError && <p className="text-xs text-red-500 font-medium">{saveError}</p>}
              
              <div className="flex gap-3 pt-2">
                <button 
                  type="submit" 
                  disabled={isSaving}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium disabled:opacity-50"
                >
                  {isSaving ? 'Verifying...' : 'Save Configuration'}
                </button>
                <button 
                  type="button" 
                  onClick={() => { setIsEditing(false); setSaveError(null); }}
                  className="px-4 py-2 bg-zinc-100 text-zinc-600 rounded-md text-sm font-medium hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-400"
                >
                  Cancel
                </button>
              </div>
            </form>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">Flume Client ID</label>
                <p className="text-sm font-mono text-zinc-900 dark:text-zinc-50 font-medium">
                  {envStatus.FLUME_CLIENT_ID || 'Loading...'}
                </p>
              </div>
              <div>
                <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">Flume Client Secret</label>
                <p className="text-sm font-mono text-zinc-900 dark:text-zinc-50 font-medium">
                  {envStatus.FLUME_CLIENT_SECRET || 'Loading...'}
                </p>
              </div>
              <div>
                <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">Flume Username</label>
                <p className="text-sm text-zinc-900 dark:text-zinc-50 font-medium">
                  {envStatus.FLUME_USERNAME || 'Loading...'}
                </p>
              </div>
              <div>
                <label className="block text-xs font-semibold text-zinc-400 uppercase mb-1">Flume Password</label>
                <p className="text-sm text-zinc-900 dark:text-zinc-50 font-medium">
                  {envStatus.FLUME_PASSWORD || 'Loading...'}
                </p>
              </div>
            </div>
          )}
          
          <p className="mt-4 text-xs text-zinc-500 italic">
            These values are loaded from your {envStatus.isCustom ? 'custom secure settings' : 'environment variables'}. 
            Values are masked for security.
          </p>
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
              <p className="text-sm font-mono text-zinc-900 dark:text-zinc-50 font-medium">
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
