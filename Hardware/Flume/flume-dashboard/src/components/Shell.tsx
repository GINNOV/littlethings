'use client';

import React, { useState } from 'react';
import { Sidebar } from './Sidebar';
import { useFlume } from './FlumeContext';
import { usePathname } from 'next/navigation';
import { Menu, Droplets } from 'lucide-react';
import { UserAvatar } from './UserAvatar';
import Link from 'next/link';

export function Shell({ children }: { children: React.ReactNode }) {
  const { isLoading, error, login, logout, user } = useFlume();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const pathname = usePathname();
  const isLoginPage = pathname === '/login';

  if (isLoading && !isLoginPage) {
    return (
      <div className="flex h-screen items-center justify-center bg-white dark:bg-black">
        <div className="flex flex-col items-center gap-4">
          <div className="p-3 bg-blue-600 rounded-2xl animate-bounce">
            <Droplets className="w-8 h-8 text-white" />
          </div>
          <div className="text-zinc-500 font-medium animate-pulse">Synchronizing water data...</div>
        </div>
      </div>
    );
  }

  if (isLoginPage) {
    return <>{children}</>;
  }

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-black transition-colors duration-300">
      <Sidebar isOpen={isSidebarOpen} setIsOpen={setIsSidebarOpen} />
      
      <main className="lg:pl-64 min-h-screen flex flex-col">
        {/* Mobile Header */}
        <header className="lg:hidden sticky top-0 z-30 flex items-center justify-between p-4 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-md border-b border-zinc-200 dark:border-zinc-800">
          <div className="flex items-center gap-2">
            <div className="p-1.5 bg-blue-600 rounded-lg">
              <Droplets className="w-5 h-5 text-white" />
            </div>
            <span className="font-bold text-zinc-900 dark:text-zinc-100">Flume Dash</span>
          </div>
          <div className="flex items-center gap-3">
            {user && (
              <Link href="/profile">
                <UserAvatar firstName={user.first_name} lastName={user.last_name} size="sm" />
              </Link>
            )}
            <button 
              onClick={() => setIsSidebarOpen(true)}
              className="p-2 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-xl transition-colors"
            >
              <Menu className="w-6 h-6" />
            </button>
          </div>
        </header>

        <div className="flex-1 max-w-7xl mx-auto p-4 md:p-8 w-full">
          {error && !isLoading && (
            <div className="mb-8 p-5 bg-red-50/50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/30 rounded-2xl text-sm text-red-600 dark:text-red-400 flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div>
                <p className="font-bold mb-0.5 text-base italic">Connection Interrupted</p>
                <p className="opacity-80">{error}</p>
              </div>
              <button 
                onClick={() => login()}
                className="px-5 py-2.5 bg-red-600 text-white rounded-xl text-xs font-bold uppercase tracking-wider hover:bg-red-700 active:scale-95 transition-all shadow-lg shadow-red-500/20"
              >
                Reconnect Now
              </button>
            </div>
          )}
          {children}
        </div>

        <footer className="mt-auto border-t border-zinc-200 dark:border-zinc-800 p-8 text-center text-zinc-500 text-sm bg-white dark:bg-zinc-900/30">
          <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-2">
              <Droplets className="w-4 h-4 text-blue-600" />
              <p className="font-medium">&copy; {new Date().getFullYear()} Flume Dash</p>
            </div>
            <div className="flex flex-wrap justify-center gap-6">
              <button onClick={() => logout()} className="hover:text-red-600 font-medium transition-colors">Sign Out</button>
              <a href="/docs/usage-guide" className="hover:text-blue-600 font-medium transition-colors">Usage Guide</a>
              <a href="https://portal.flumewater.com" target="_blank" rel="noopener noreferrer" className="hover:text-blue-600 font-medium transition-colors">Official Portal</a>
            </div>
          </div>
        </footer>
      </main>
    </div>
  );
}
