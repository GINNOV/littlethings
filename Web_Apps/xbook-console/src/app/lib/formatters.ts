export const formatDate = (v: any) => v ? new Date(v).toLocaleString() : "Not finished";
export const formatDateShort = (v: any) => v ? new Date(v).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: '2-digit' }) : "-";
export const formatTime = (v: any) => v ? new Date(v).toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' }) : "-";

export const statusClass = (s: string) => {
  if (s === "completed") return "text-primary";
  if (["failed", "stopped"].includes(s)) return "text-error";
  return "text-secondary";
};
