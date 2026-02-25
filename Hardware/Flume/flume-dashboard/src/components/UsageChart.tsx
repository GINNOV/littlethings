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
import { format, parseISO } from 'date-fns';

interface UsageChartProps {
  data: Array<{
    datetime: string;
    value: number;
  }>;
  unit: string;
}

export function UsageChart({ data, unit }: UsageChartProps) {
  if (!data || data.length === 0) {
    return (
      <div className="h-64 flex items-center justify-center border border-dashed border-zinc-200 rounded-lg text-zinc-400">
        No data available for this period
      </div>
    );
  }

  const chartData = data.map((d) => ({
    ...d,
    formattedDate: format(parseISO(d.datetime), 'MMM dd'),
    displayValue: d.value,
  }));

  return (
    <div className="h-80 w-full mt-4">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
          <XAxis
            dataKey="formattedDate"
            axisLine={false}
            tickLine={false}
            tick={{ fontSize: 12, fill: '#888' }}
            dy={10}
          />
          <YAxis
            axisLine={false}
            tickLine={false}
            tick={{ fontSize: 12, fill: '#888' }}
            tickFormatter={(value) => `${value}`}
          />
          <Tooltip
            cursor={{ fill: '#f8f8f8' }}
            contentStyle={{
              borderRadius: '8px',
              border: 'none',
              boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
            }}
            formatter={(value: number) => [`${value} ${unit}`, 'Usage']}
          />
          <Bar dataKey="displayValue" radius={[4, 4, 0, 0]}>
            {chartData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill="#3b82f6" />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
