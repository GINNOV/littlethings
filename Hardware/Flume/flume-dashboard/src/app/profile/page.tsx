'use client';

import React from 'react';
import { Shell } from '@/components/Shell';
import { useFlume } from '@/components/FlumeContext';
import { UserAvatar } from '@/components/UserAvatar';
import { Mail, User as UserIcon, Shield, ExternalLink } from 'lucide-react';

export default function ProfilePage() {
  const { user } = useFlume();

  if (!user) {
    return (
      <Shell>
        <div className="flex flex-col items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mb-4"></div>
          <p className="text-zinc-500">Loading profile data...</p>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <div className="mb-8">
        <h2 className="text-3xl font-extrabold text-zinc-900 dark:text-zinc-50 tracking-tight">My Profile</h2>
        <p className="text-zinc-500 font-medium">Personal details and account security</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Column: Summary Card */}
        <div className="lg:col-span-1">
          <div className="bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-zinc-200 dark:border-zinc-800 p-8 shadow-xl shadow-zinc-200/20 dark:shadow-none flex flex-col items-center text-center">
            <div className="relative mb-6">
              <UserAvatar firstName={user.first_name} lastName={user.last_name} size="xl" />
              <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-green-500 border-4 border-white dark:border-zinc-900 rounded-full"></div>
            </div>
            <h3 className="text-2xl font-black text-zinc-900 dark:text-zinc-50 tracking-tight">
              {user.first_name} {user.last_name}
            </h3>
            <p className="text-zinc-500 font-medium mb-6">{user.email}</p>
            
            <div className="w-full pt-6 border-t border-zinc-100 dark:border-zinc-800 space-y-4">
              <div className="flex justify-between text-sm">
                <span className="text-zinc-400 font-bold uppercase tracking-widest text-[10px]">User ID</span>
                <span className="text-zinc-900 dark:text-zinc-50 font-mono font-bold">#{user.id}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-zinc-400 font-bold uppercase tracking-widest text-[10px]">Membership</span>
                <span className="text-blue-600 font-bold">Standard</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Detailed Info */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-zinc-200 dark:border-zinc-800 p-8 shadow-sm">
            <h4 className="text-lg font-bold text-zinc-900 dark:text-zinc-50 mb-6 flex items-center gap-2">
              <UserIcon className="w-5 h-5 text-blue-600" />
              Personal Information
            </h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">First Name</label>
                <div className="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-100 dark:border-zinc-800 font-medium text-zinc-900 dark:text-zinc-100">
                  {user.first_name}
                </div>
              </div>
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">Last Name</label>
                <div className="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-100 dark:border-zinc-800 font-medium text-zinc-900 dark:text-zinc-100">
                  {user.last_name}
                </div>
              </div>
              <div className="md:col-span-2 space-y-1">
                <label className="text-[10px] font-bold text-zinc-400 uppercase tracking-widest">Email Address</label>
                <div className="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-100 dark:border-zinc-800 font-medium text-zinc-900 dark:text-zinc-100 flex items-center justify-between">
                  {user.email}
                  <Mail className="w-4 h-4 text-zinc-400" />
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white dark:bg-zinc-900 rounded-[2.5rem] border border-zinc-200 dark:border-zinc-800 p-8 shadow-sm">
            <h4 className="text-lg font-bold text-zinc-900 dark:text-zinc-50 mb-6 flex items-center gap-2">
              <Shield className="w-5 h-5 text-green-600" />
              Account Security
            </h4>
            
            <div className="space-y-4">
              <p className="text-sm text-zinc-500 leading-relaxed">
                Your account is managed through the official Flume platform. To update your password or personal details, please use the Flume portal.
              </p>
              <a 
                href="https://portal.flumewater.com" 
                target="_blank" 
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 px-6 py-3 bg-zinc-900 dark:bg-zinc-100 text-white dark:text-zinc-900 rounded-2xl text-sm font-bold hover:scale-[1.02] active:scale-95 transition-all shadow-lg"
              >
                Go to Flume Portal
                <ExternalLink className="w-4 h-4" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </Shell>
  );
}
