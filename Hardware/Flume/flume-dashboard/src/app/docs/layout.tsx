'use client';

import React from 'react';
import { Shell } from '@/components/Shell';

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  return (
    <Shell>
      <div className="max-w-4xl mx-auto">
        {children}
      </div>
    </Shell>
  );
}
