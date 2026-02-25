'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useFlume } from './FlumeContext';

export function Sidebar() {
  const pathname = usePathname();
  const { user, devices, selectedDevice, setSelectedDevice } = useFlume();

  const navItems = [
    { name: 'Dashboard', href: '/' },
    { name: 'History', href: '/history' },
    { name: 'Insights', href: '/insights' },
    { name: 'Settings', href: '/settings' },
  ];

  return (
    <aside className="fixed left-0 top-0 h-full w-64 bg-zinc-50 border-r border-zinc-200 p-6 dark:bg-zinc-900 dark:border-zinc-800 text-zinc-900 dark:text-zinc-100">
      <div className="mb-8">
        <h1 className="text-xl font-bold text-blue-600">Flume Dash</h1>
        {user && (
          <p className="text-sm text-zinc-500 mt-1">
            Hi, {user.first_name}
          </p>
        )}
      </div>

      <nav className="space-y-1 mb-8">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`block px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-100'
                  : 'text-zinc-600 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-800'
              }`}
            >
              {item.name}
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto">
        <h3 className="text-xs font-semibold text-zinc-400 uppercase tracking-wider mb-2">
          Device
        </h3>
        {devices.length > 0 ? (
          <select
            className="w-full bg-white border border-zinc-200 rounded-md px-3 py-2 text-sm text-zinc-900 dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-100"
            value={selectedDevice?.id || ''}
            onChange={(e) => {
              const device = devices.find((d) => d.id === e.target.value);
              if (device) setSelectedDevice(device);
            }}
          >
            {devices.map((device) => (
              <option key={device.id} value={device.id} className="text-zinc-900 dark:text-zinc-100 bg-white dark:bg-zinc-800">
                {device.name}
              </option>
            ))}
          </select>
        ) : (
          <div className="text-sm text-zinc-500 italic px-1">
            No devices found
          </div>
        )}
      </div>
    </aside>
  );
}
