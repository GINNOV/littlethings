'use client';

import React from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
} from 'recharts';
import { format, parseISO, isValid } from 'date-fns';

interface UsageChartProps {
  data: Array<{
    datetime: string;
    value: number;
  }>;
  unit: string;
  granularity?: string;
}

export function UsageChart({ data, unit, granularity = 'DAY' }: UsageChartProps) {
  // Guard against missing or malformed data
  if (!data || !Array.isArray(data) || data.length === 0) {
    return (
      <div className="h-full flex items-center justify-center border-2 border-dashed border-zinc-100 dark:border-zinc-800 rounded-3xl text-zinc-400 font-bold italic">
        Awaiting fresh data...
      </div>
    );
  }

  const chartData = data.map((d) => {
    // Basic validation of d.datetime
    if (typeof d.datetime !== 'string') {
      return { ...d, formattedDate: 'Invalid', displayValue: d.value || 0 };
    }

    // Handle Flume's space instead of T in datetime string
    const isoString = d.datetime.includes(' ') ? d.datetime.replace(' ', 'T') : d.datetime;
    const date = parseISO(isoString);
    
    let label = 'Unknown';
    if (isValid(date)) {
      if (granularity === 'HR' || granularity === '1h') {
        label = format(date, 'MMM dd HH:mm');
      } else if (granularity === 'MON' || granularity === '1M') {
        label = format(date, 'MMM yyyy');
      } else {
        label = format(date, 'MMM dd');
      }
    }

    return {
      ...d,
      formattedDate: label,
      displayValue: typeof d.value === 'number' ? d.value : 0,
    };
  });

  return (
    <div className="h-full w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData} margin={{ top: 10, right: 10, left: 0, bottom: 20 }}>
          <defs>
            <linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#3b82f6" stopOpacity={1} />
              <stop offset="100%" stopColor="#60a5fa" stopOpacity={0.8} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="4 4" vertical={false} stroke="#e2e8f0" className="dark:stroke-zinc-800" />
          <XAxis
            dataKey="formattedDate"
            axisLine={false}
            tickLine={false}
            tick={{ fontSize: 10, fill: '#94a3b8', fontWeight: 600 }}
            dy={10}
            interval="preserveStartEnd"
            minTickGap={20}
          />
          <YAxis
            axisLine={false}
            tickLine={false}
            tick={{ fontSize: 10, fill: '#94a3b8', fontWeight: 600 }}
            tickFormatter={(value) => `${value}`}
            width={40}
          />
          <Tooltip
            cursor={{ fill: 'rgba(59, 130, 246, 0.05)', radius: 8 }}
            content={({ active, payload, label }) => {
              if (active && payload && payload.length) {
                return (
                  <div className="bg-white dark:bg-zinc-800 p-4 rounded-2xl shadow-xl border border-zinc-100 dark:border-zinc-700">
                    <p className="text-xs font-bold text-zinc-400 uppercase tracking-widest mb-1">{label}</p>
                    <p className="text-lg font-black text-blue-600">
                      {Number(payload[0].value).toFixed(2)} <span className="text-xs font-bold text-zinc-400">{unit}</span>
                    </p>
                  </div>
                );
              }
              return null;
            }}
          />
          <Bar 
            dataKey="displayValue" 
            radius={[4, 4, 4, 4]} 
            animationDuration={1000}
            maxBarSize={40}
          >
            {chartData.map((entry, index) => (
              <Cell 
                key={`cell-${index}`} 
                fill="url(#barGradient)" 
                className="hover:opacity-80 transition-opacity cursor-pointer"
              />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
