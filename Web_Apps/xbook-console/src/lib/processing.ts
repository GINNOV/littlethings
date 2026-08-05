import { prisma } from "@/lib/db";
import { processingEvents } from "@/lib/signals";

type RunStatus =
  | "queued"
  | "running"
  | "completed"
  | "failed"
  | "stopped";

type EventStatus =
  | "queued"
  | "fetching"
  | "sent_to_llm"
  | "completed"
  | "failed"
  | "skipped"
  | "stopped"
  | "retrying";

const preview = (value?: string | null, max = 500) => {
  const normalized = (value ?? "").replace(/\s+/g, " ").trim();
  if (!normalized) return null;
  return normalized.length > max ? `${normalized.slice(0, max - 3)}...` : normalized;
};

const stringify = (value: unknown) => {
  if (value === undefined || value === null) return null;
  try {
    return JSON.stringify(value);
  } catch {
    return null;
  }
};

export async function createOperationRun(input: {
  type: string;
  source?: string | null;
  status?: RunStatus;
  total?: number;
  notes?: string | null;
}) {
  const run = await prisma.operationRun.create({
    data: {
      type: input.type,
      source: input.source ?? null,
      status: input.status ?? "running",
      total: input.total ?? 0,
      notes: input.notes ?? null,
    },
  });
  processingEvents.emit("run_created", run);
  return run;
}

export async function updateOperationRun(
  runId: string | null | undefined,
  input: {
    status?: RunStatus;
    total?: number;
    processed?: number;
    updated?: number;
    failed?: number;
    skipped?: number;
    notes?: string | null;
    finish?: boolean;
  }
) {
  if (!runId) return null;
  const run = await prisma.operationRun.update({
    where: { id: runId },
    data: {
      ...(input.status ? { status: input.status } : {}),
      ...(input.total !== undefined ? { total: input.total } : {}),
      ...(input.processed !== undefined ? { processed: input.processed } : {}),
      ...(input.updated !== undefined ? { updated: input.updated } : {}),
      ...(input.failed !== undefined ? { failed: input.failed } : {}),
      ...(input.skipped !== undefined ? { skipped: input.skipped } : {}),
      ...(input.notes !== undefined ? { notes: input.notes } : {}),
      ...(input.finish ? { finishedAt: new Date() } : {}),
    },
  });
  processingEvents.emit("run_updated", run);
  return run;
}

export async function incrementOperationRun(
  runId: string | null | undefined,
  input: {
    status?: RunStatus;
    processed?: number;
    updated?: number;
    failed?: number;
    skipped?: number;
    notes?: string | null;
    finish?: boolean;
  }
) {
  if (!runId) return null;
  const run = await prisma.operationRun.update({
    where: { id: runId },
    data: {
      ...(input.status ? { status: input.status } : {}),
      ...(input.processed !== undefined ? { processed: { increment: input.processed } } : {}),
      ...(input.updated !== undefined ? { updated: { increment: input.updated } } : {}),
      ...(input.failed !== undefined ? { failed: { increment: input.failed } } : {}),
      ...(input.skipped !== undefined ? { skipped: { increment: input.skipped } } : {}),
      ...(input.notes !== undefined ? { notes: input.notes } : {}),
      ...(input.finish ? { finishedAt: new Date() } : {}),
    },
  });
  processingEvents.emit("run_updated", run);
  return run;
}

export async function logProcessingEvent(input: {
  runId?: string | null;
  bookmarkId?: string | null;
  type: string;
  status: EventStatus;
  message?: string | null;
  metadata?: unknown;
}) {
  if (!input.runId) return null;
  try {
    const event = await prisma.processingEvent.create({
      data: {
        runId: input.runId,
        bookmarkId: input.bookmarkId ?? null,
        type: input.type,
        status: input.status,
        message: input.message ?? null,
        metadataJson: stringify(input.metadata),
      },
    });
    processingEvents.emit("event_logged", event);
    return event;
  } catch (error) {
    // Handle foreign key violation (e.g. run deleted while processing)
    if (error instanceof Error && (error as { code?: string }).code === "P2003") {
      return null;
    }
    throw error;
  }
}

export async function logLlmRequest(input: {
  runId?: string | null;
  bookmarkId?: string | null;
  model?: string | null;
  baseUrl?: string | null;
  prompt?: string | null;
  response?: string | null;
  parsed?: unknown;
  durationMs?: number | null;
  tokenUsage?: unknown;
  error?: string | null;
  includePayloads?: boolean;
}) {
  const includePayloads = input.includePayloads ?? true;
  try {
    return await prisma.llmRequestLog.create({
      data: {
        runId: input.runId ?? null,
        bookmarkId: input.bookmarkId ?? null,
        model: input.model ?? null,
        baseUrl: input.baseUrl ? safeBaseUrl(input.baseUrl) : null,
        promptPreview: preview(input.prompt),
        prompt: includePayloads ? input.prompt ?? null : null,
        responsePreview: preview(input.response),
        response: includePayloads ? input.response ?? null : null,
        parsedJson: stringify(input.parsed),
        durationMs: input.durationMs ?? null,
        tokenUsageJson: stringify(input.tokenUsage),
        error: input.error ?? null,
      },
    });
  } catch (error) {
    if (error instanceof Error && (error as { code?: string }).code === "P2003") {
      return null;
    }
    throw error;
  }
}

function safeBaseUrl(value: string) {
  try {
    const url = new URL(value);
    return `${url.protocol}//${url.host}${url.pathname === "/" ? "" : url.pathname}`;
  } catch {
    return value;
  }
}

export async function clearProcessingLogs() {
  const inactiveRunIds = (await prisma.operationRun.findMany({
    where: { status: { in: ["completed", "failed", "stopped"] } },
    select: { id: true }
  })).map(r => r.id);

  if (inactiveRunIds.length === 0) return;

  await prisma.processingEvent.deleteMany({
    where: { runId: { in: inactiveRunIds } }
  });
  await prisma.llmRequestLog.deleteMany({
    where: { runId: { in: inactiveRunIds } }
  });
  await prisma.operationRun.deleteMany({
    where: { id: { in: inactiveRunIds } }
  });
}

export async function clearProcessingLogsForRunIds(runIds: string[]) {
  if (!runIds.length) return { deletedRuns: 0 };

  await prisma.processingEvent.deleteMany({
    where: { runId: { in: runIds } },
  });
  await prisma.llmRequestLog.deleteMany({
    where: { runId: { in: runIds } },
  });
  await prisma.operationRun.deleteMany({
    where: { id: { in: runIds } },
  });

  return { deletedRuns: runIds.length };
}

export async function getActiveRun(source?: string | null) {
  return prisma.operationRun.findFirst({
    where: {
      status: { in: ["queued", "running"] },
      ...(source ? { source } : {}),
    },
  });
}

export async function getProcessingSummary(source?: string | null) {
  const since = new Date();
  since.setHours(0, 0, 0, 0);

  const filter = source ? { source } : {};

  const [activeOperations, itemsSummaryToday, totalItems, pendingEnrichment, lastLlm] =
    await Promise.all([
      prisma.operationRun.count({
        where: { 
          status: { in: ["queued", "running"] },
          ...filter
        },
      }),
      prisma.operationRun.aggregate({
        where: { 
          startedAt: { gte: since },
          ...filter
        },
        _sum: {
          updated: true,
          failed: true,
        },
      }),
      prisma.bookmark.count({
        where: filter,
      }),
      prisma.bookmark.count({
        where: {
          ...filter,
          AND: [
            { OR: [{ summary: null }, { summary: "" }] },
            { OR: [{ category: null }, { category: "" }] },
          ],
        },
      }),
      prisma.llmRequestLog.findFirst({
        where: source ? { run: { source } } : {},
        orderBy: { createdAt: "desc" },
        select: { durationMs: true, createdAt: true, error: true },
      }),
    ]);

  return {
    activeOperations,
    completedToday: itemsSummaryToday._sum.updated ?? 0,
    failedToday: itemsSummaryToday._sum.failed ?? 0,
    totalItems,
    totalEnriched: totalItems - pendingEnrichment,
    pendingEnrichment,
    lastLlm,
  };
}
