export interface UsageData {
  datetime: string;
  value: number;
}

export interface InsightResult {
  average: number;
  peak: number;
  peakDate: string;
  anomalies: UsageData[];
  trend: 'up' | 'down' | 'stable';
  forecastedTotal: number;
}

/**
 * Detects anomalies using a simple Z-Score method.
 * A Z-score > 2 usually indicates an outlier (usage > 2 standard deviations from mean).
 */
export function detectAnomalies(data: UsageData[], threshold = 2) {
  if (data.length < 3) return [];

  const values = data.map(d => d.value);
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const squareDiffs = values.map(v => Math.pow(v - mean, 2));
  const avgSquareDiff = squareDiffs.reduce((a, b) => a + b, 0) / squareDiffs.length;
  const stdDev = Math.sqrt(avgSquareDiff);

  return data.filter(d => {
    const zScore = stdDev === 0 ? 0 : Math.abs(d.value - mean) / stdDev;
    return zScore > threshold;
  });
}

/**
 * Calculates a simple linear trend and forecast for the month.
 */
export function calculateInsights(data: UsageData[]): InsightResult {
  if (data.length === 0) {
    return { average: 0, peak: 0, peakDate: '', anomalies: [], trend: 'stable', forecastedTotal: 0 };
  }

  const values = data.map(d => d.value);
  const average = values.reduce((a, b) => a + b, 0) / values.length;
  
  let peak = -1;
  let peakDate = '';
  data.forEach(d => {
    if (d.value > peak) {
      peak = d.value;
      peakDate = d.datetime;
    }
  });

  const anomalies = detectAnomalies(data);

  // Trend: compare first half to second half
  const mid = Math.floor(values.length / 2);
  const firstHalfAvg = values.slice(0, mid).reduce((a, b) => a + b, 0) / mid;
  const secondHalfAvg = values.slice(mid).reduce((a, b) => a + b, 0) / (values.length - mid);
  
  let trend: 'up' | 'down' | 'stable' = 'stable';
  const diff = (secondHalfAvg - firstHalfAvg) / (firstHalfAvg || 1);
  if (diff > 0.1) trend = 'up';
  else if (diff < -0.1) trend = 'down';

  // Simple forecast: (Average daily * remaining days in month)
  // For MVP, we'll just return (avg * 30) as a "Monthly Projection"
  const forecastedTotal = average * 30;

  return {
    average,
    peak,
    peakDate,
    anomalies,
    trend,
    forecastedTotal
  };
}
