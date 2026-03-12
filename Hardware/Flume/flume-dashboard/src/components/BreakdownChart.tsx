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
      <div className="h-full flex items-center justify-center border-2 border-dashed border-zinc-100 dark:border-zinc-800 rounded-[2rem] text-zinc-400 font-bold italic p-8 text-center">
        No categorization data detected for this device.
      </div>
    );
  }

  const filteredData = data.filter(d => d.value > 0);

  return (
    <div className="h-full w-full">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={filteredData}
            cx="50%"
            cy="50%"
            innerRadius={70}
            outerRadius={95}
            paddingAngle={8}
            dataKey="value"
            animationDuration={1800}
            stroke="none"
          >
            {filteredData.map((entry, index) => (
              <Cell 
                key={`cell-${index}`} 
                fill={entry.color} 
                className="hover:opacity-80 transition-opacity cursor-pointer outline-none" 
              />
            ))}
          </Pie>
          <Tooltip 
            content={({ active, payload }) => {
              if (active && payload && payload.length) {
                const data = payload[0].payload as BreakdownData;
                return (
                  <div className="bg-white dark:bg-zinc-800 p-4 rounded-2xl shadow-xl border border-zinc-100 dark:border-zinc-700">
                    <div className="flex items-center gap-2 mb-1">
                      <div className="w-2 h-2 rounded-full" style={{ backgroundColor: data.color }}></div>
                      <p className="text-xs font-bold text-zinc-400 uppercase tracking-widest">{data.name}</p>
                    </div>
                    <p className="text-lg font-black text-zinc-900 dark:text-zinc-50">
                      {data.value.toFixed(1)} <span className="text-xs font-bold text-zinc-400">{unit}</span>
                    </p>
                  </div>
                );
              }
              return null;
            }}
          />
          <Legend 
            verticalAlign="bottom" 
            align="center"
            iconType="circle"
            iconSize={8}
            wrapperStyle={{ paddingTop: '20px' }}
            formatter={(value) => <span className="text-[11px] font-bold text-zinc-500 uppercase tracking-wider">{value}</span>}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
