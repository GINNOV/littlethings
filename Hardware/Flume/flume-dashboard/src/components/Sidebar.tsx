'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useFlume } from './FlumeContext';
import { UserAvatar } from './UserAvatar';
import { 
  LayoutDashboard, 
  History, 
  Lightbulb, 
  Settings, 
  FileText, 
  LogOut,
  Droplets,
  X,
  User
} from 'lucide-react';

interface SidebarProps {
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
}

export function Sidebar({ isOpen, setIsOpen }: SidebarProps) {
  const pathname = usePathname();
  const { user, devices, selectedDevice, setSelectedDevice, logout } = useFlume();

  const navItems = [
    { name: 'Dashboard', href: '/', icon: LayoutDashboard },
    { name: 'History', href: '/history', icon: History },
    { name: 'Insights', href: '/insights', icon: Lightbulb },
    { name: 'Profile', href: '/profile', icon: User },
    { name: 'Settings', href: '/settings', icon: Settings },
    { name: 'Documentation', href: '/docs/usage-guide', icon: FileText },
  ];

  const sidebarClasses = `
    fixed inset-y-0 left-0 z-50 w-64 bg-white border-r border-zinc-200 
    dark:bg-zinc-900 dark:border-zinc-800 transition-transform duration-300 ease-in-out lg:translate-x-0
    ${isOpen ? 'translate-x-0' : '-translate-x-full'}
  `;

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 z-40 bg-zinc-900/50 lg:hidden"
          onClick={() => setIsOpen(false)}
        />
      )}

      <aside className={sidebarClasses}>
        <div className="flex flex-col h-full p-6">
          <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-2">
              <div className="p-1.5 bg-blue-600 rounded-lg">
                <Droplets className="w-5 h-5 text-white" />
              </div>
              <h1 className="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-blue-400">
                Flume Dash
              </h1>
            </div>
            <button 
              className="lg:hidden p-1 text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-md"
              onClick={() => setIsOpen(false)}
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {user && (
            <Link 
              href="/profile" 
              onClick={() => setIsOpen(false)}
              className="mb-8 p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded-2xl border border-zinc-100 dark:border-zinc-800 flex items-center gap-3 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors group"
            >
              <UserAvatar firstName={user.first_name} lastName={user.last_name} size="sm" />
              <div className="flex-1 overflow-hidden">
                <p className="text-sm font-bold text-zinc-900 dark:text-zinc-100 truncate group-hover:text-blue-600 transition-colors">
                  {user.first_name} {user.last_name}
                </p>
                <p className="text-[10px] text-zinc-400 uppercase font-bold tracking-widest truncate">View Profile</p>
              </div>
            </Link>
          )}

          <nav className="space-y-1.5 flex-1">
            {navItems.map((item) => {
              const isActive = pathname === item.href;
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setIsOpen(false)}
                  className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${
                    isActive
                      ? 'bg-blue-50 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400 shadow-sm shadow-blue-500/10'
                      : 'text-zinc-600 hover:bg-zinc-50 dark:text-zinc-400 dark:hover:bg-zinc-800'
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? 'text-blue-600 dark:text-blue-400' : 'text-zinc-400'}`} />
                  {item.name}
                </Link>
              );
            })}
          </nav>

          <div className="mt-auto space-y-6">
            <div>
              <h3 className="text-xs font-bold text-zinc-400 uppercase tracking-widest mb-3 px-1">
                Selected Device
              </h3>
              {devices.length > 0 ? (
                <select
                  className="w-full bg-zinc-50 border border-zinc-200 rounded-xl px-3 py-2.5 text-sm text-zinc-900 focus:ring-2 focus:ring-blue-500 outline-none dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-100"
                  value={selectedDevice?.id || ''}
                  onChange={(e) => {
                    const device = devices.find((d) => d.id === e.target.value);
                    if (device) setSelectedDevice(device);
                  }}
                >
                  {devices.map((device) => (
                    <option key={device.id} value={device.id}>
                      {device.name}
                    </option>
                  ))}
                </select>
              ) : (
                <div className="text-sm text-zinc-400 italic px-1">
                  Searching for devices...
                </div>
              )}
            </div>

            <button
              onClick={() => logout()}
              className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-900/20 transition-all"
            >
              <LogOut className="w-4 h-4" />
              Sign Out
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
