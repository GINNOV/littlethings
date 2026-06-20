export function getFilterUrl(currentParams: any, next: Record<string, string | boolean | null>) {
  const params = new URLSearchParams({ ...currentParams, ...next });
  Object.keys(next).forEach(k => {
    if (next[k] === null || next[k] === false) params.delete(k);
  });
  return `/processing?${params.toString()}`;
}
