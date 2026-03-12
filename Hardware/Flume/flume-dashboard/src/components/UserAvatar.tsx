'use client';

import React from 'react';

interface UserAvatarProps {
  firstName?: string;
  lastName?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

export function UserAvatar({ firstName, lastName, size = 'md', className = '' }: UserAvatarProps) {
  const initials = `${firstName?.[0] || ''}${lastName?.[0] || ''}`.toUpperCase() || '?';
  
  const sizeClasses = {
    sm: 'w-8 h-8 text-xs',
    md: 'w-10 h-10 text-sm',
    lg: 'w-16 h-16 text-xl',
    xl: 'w-24 h-24 text-3xl',
  };

  const bgColors = [
    'bg-blue-500',
    'bg-purple-500',
    'bg-indigo-500',
    'bg-teal-500',
    'bg-emerald-500',
  ];
  
  // Deterministic color based on name
  const colorIndex = firstName ? firstName.length % bgColors.length : 0;
  const bgColor = bgColors[colorIndex];

  return (
    <div className={`flex items-center justify-center rounded-full text-white font-bold shadow-sm ${sizeClasses[size]} ${bgColor} ${className}`}>
      {initials}
    </div>
  );
}
