import { prisma } from "@/lib/db";

async function findRuns(where: any) {
  return prisma.operationRun.findMany({ where, orderBy: { startedAt: "desc" }, take: 50, include: { _count: { select: { events: true, llmRequests: true } } } });
}

async function findSelected(id: string) {
  return prisma.operationRun.findUnique({ where: { id }, include: { events: { orderBy: { createdAt: "asc" }, include: { bookmark: { select: { id: true, source: true, tweetUrl: true, text: true, summary: true, category: true, tags: true, authorUsername: true, folder: { select: { id: true, name: true } } } } } }, llmRequests: { orderBy: { createdAt: "asc" }, include: { bookmark: { select: { id: true, source: true, tweetUrl: true, summary: true, category: true, text: true, authorUsername: true } } } } } });
}

export async function getProcessingData(p: any) {
  const status = p?.status || "", source = p?.source || "", errorsOnly = p?.errorsOnly === "true";
  const where = { ...(status && { status }), ...(source && { source }), ...(p?.type && { type: p.type }), ...(errorsOnly && { OR: [{ failed: { gt: 0 } }, { status: { in: ["failed", "stopped"] } }] }) };
  const [runs, selectedRun] = await Promise.all([findRuns(where), p?.runId ? findSelected(p.runId) : null]);
  return { runs, selectedRun, status, source, errorsOnly };
}

export function buildFilterHref(p: any) {
  return (next: any) => {
    const params = new URLSearchParams({ ...p, ...next });
    Object.keys(next).forEach(k => { if (next[k] === null || next[k] === false) params.delete(k); });
    return `/processing?${params.toString()}`;
  };
}
