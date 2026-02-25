'use client';

import React from 'react';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from 'recharts';

interface BreakdownData {
  name: string;
  value: number;
  color: string;
}

interface BreakdownChartProps {
  data: BreakdownData[];
  unit: string;
}

export function BreakdownChart({ data, unit }: BreakdownChartProps) {
  if (!data || data.length === 0 || data.every(d => d.value === 0)) {
    return (
      <div className="h-64 flex items-center justify-center border border-dashed border-zinc-200 rounded-lg text-zinc-400 text-sm">
        No category breakdown data available for this period.
      </div>
    );
  }

  // Filter out zero values for better visualization
  const filteredData = data.filter(d => d.value > 0);

  return (
    <div className="h-80 w-full mt-4">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={filteredData}
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={80}
            paddingAngle={5}
            dataKey="value"
          >
            {filteredData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
          <Tooltip 
            formatter={(value: number) => [`${value.toFixed(1)} ${unit}`, 'Usage']}
            contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
          />
          <Legend 
            verticalAlign="bottom" 
            height={36} 
            iconType="circle"
            formatter={(value) => <span className="text-sm text-zinc-600 dark:text-zinc-400">{value}</span>}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
