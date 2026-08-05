import { prisma } from "@/lib/db";
import type { Prisma } from "@prisma/client";

export type AppSettings = {
  xBearerToken?: string | null; xUserId?: string | null; xApiBase?: string | null; xClientId?: string | null; xClientSecret?: string | null; xRedirectUri?: string | null;
  xAccessToken?: string | null; xRefreshToken?: string | null; xTokenExpiresAt?: Date | null; xScope?: string | null; xTokenType?: string | null;
  ytClientId?: string | null; ytClientSecret?: string | null; ytRedirectUri?: string | null; ytAccessToken?: string | null; ytRefreshToken?: string | null; ytTokenExpiresAt?: Date | null; ytScope?: string | null; ytTokenType?: string | null;
  llmBaseUrl?: string | null; llmApiKey?: string | null; llmModel?: string | null;
  llmEmbeddingModel?: string | null; llmEmbeddingBaseUrl?: string | null;
  llmSystemPrompt?: string | null; llmPrompt?: string | null; llmConcurrency?: number | null; llmMaxTokens?: number | null;
  llmContextWindow?: number | null; llmResponseLimit?: number | null; llmThinkingEnabled?: boolean | null;
  monthlyCap?: number | null; ytMonthlyCap?: number | null; enrichBatchSize?: number | null; logLlmPayloads?: boolean | null; targetLanguage?: string | null;
  soundOnComplete?: boolean | null; soundOnError?: boolean | null; lastBookmarkId?: string | null; lastSyncedAt?: Date | null;
};

const clean = (v?: any) => (typeof v === "string" ? (v.trim().length ? v.trim() : null) : v);

export async function getSettings() {
  return (await prisma.settings.upsert({ where: { id: "default" }, update: {}, create: { id: "default" } })) as AppSettings & { id: string };
}

function buildUpdate(input: AppSettings): Prisma.SettingsUpdateInput {
  const up: Prisma.SettingsUpdateInput = {};
  const entries = Object.entries(input) as [keyof AppSettings, any][];
  
  for (const [k, v] of entries) {
    if (["llmConcurrency", "llmMaxTokens", "llmContextWindow", "llmResponseLimit", "monthlyCap", "ytMonthlyCap", "enrichBatchSize"].includes(k)) {
      (up as any)[k] = v ?? 0;
    } else if (["soundOnComplete", "soundOnError", "logLlmPayloads", "llmThinkingEnabled"].includes(k)) {
      (up as any)[k] = !!v;
    } else if (["lastSyncedAt", "xTokenExpiresAt", "ytTokenExpiresAt"].includes(k)) {
      (up as any)[k] = v ? new Date(v) : null;
    } else {
      (up as any)[k] = clean(v);
    }
  }
  return up;
}

export async function updateSettings(input: AppSettings) {
  const up = buildUpdate(input);
  const data: Prisma.SettingsCreateInput = {
    id: "default",
    ...up,
    targetLanguage: (up.targetLanguage as string) || "English",
  } as any;

  return prisma.settings.upsert({
    where: { id: "default" },
    update: up,
    create: data,
  });
}

function currentMonthKey(date = new Date(), source: "x" | "yt" = "x") {
  const m = String(date.getMonth() + 1).padStart(2, "0");
  return `${date.getFullYear()}-${m}:${source}`;
}

export async function getUsageMonth(date = new Date(), source: "x" | "yt" = "x") {
  const id = currentMonthKey(date, source);
  const month = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
  return prisma.usageMonth.upsert({ where: { id }, update: {}, create: { id, month, source } });
}

export async function incrementUsage(count: number, source: "x" | "yt" = "x") {
  const id = currentMonthKey(new Date(), source);
  const month = `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, "0")}`;
  return prisma.usageMonth.upsert({ where: { id }, update: { usedBookmarks: { increment: count } }, create: { id, month, source, usedBookmarks: count } });
}
