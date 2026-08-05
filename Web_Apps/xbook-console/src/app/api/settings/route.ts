import { NextResponse } from "next/server";
import { z } from "zod";
import { getSettings, updateSettings } from "@/lib/settings";
import { MAX_LLM_CONCURRENCY } from "@/lib/llm-limits";

const schema = z.object({
  xBearerToken: z.string().optional().nullable(),
  xUserId: z.string().optional().nullable(),
  xApiBase: z.string().optional().nullable(),
  xClientId: z.string().optional().nullable(),
  xClientSecret: z.string().optional().nullable(),
  xRedirectUri: z.string().optional().nullable(),
  xAccessToken: z.string().optional().nullable(),
  xRefreshToken: z.string().optional().nullable(),
  xTokenExpiresAt: z.string().optional().nullable(),
  xScope: z.string().optional().nullable(),
  xTokenType: z.string().optional().nullable(),
  ytClientId: z.string().optional().nullable(),
  ytClientSecret: z.string().optional().nullable(),
  ytRedirectUri: z.string().optional().nullable(),
  ytAccessToken: z.string().optional().nullable(),
  ytRefreshToken: z.string().optional().nullable(),
  ytTokenExpiresAt: z.string().optional().nullable(),
  ytScope: z.string().optional().nullable(),
  ytTokenType: z.string().optional().nullable(),
  llmBaseUrl: z.string().optional().nullable(),
  llmApiKey: z.string().optional().nullable(),
  llmModel: z.string().optional().nullable(),
  llmEmbeddingModel: z.string().optional().nullable(),
  llmEmbeddingBaseUrl: z.string().optional().nullable(),
  llmSystemPrompt: z.string().optional().nullable(),
  llmPrompt: z.string().optional().nullable(),
  llmConcurrency: z.coerce.number().int().min(1).max(MAX_LLM_CONCURRENCY).optional(),
  llmMaxTokens: z.coerce.number().int().min(1).max(512000).optional(),
  llmContextWindow: z.coerce.number().int().min(1).max(1000000).optional(),
  llmResponseLimit: z.coerce.number().int().min(0).max(128000).optional(),
  llmThinkingEnabled: z.boolean().optional().nullable(),
  monthlyCap: z.coerce.number().int().min(1).max(10000).optional(),
  ytMonthlyCap: z.coerce.number().int().min(1).max(10000).optional(),
  enrichBatchSize: z.coerce.number().int().min(1).max(200).optional(),
  targetLanguage: z.string().optional().nullable(),
  logLlmPayloads: z.boolean().optional().nullable(),
  soundOnComplete: z.boolean().optional().nullable(),
  soundOnError: z.boolean().optional().nullable(),
  lastBookmarkId: z.string().optional().nullable(),
});

export async function GET() {
  const settings = await getSettings();
  return NextResponse.json({
    ok: true,
    settings,
  });
}

export async function POST(request: Request) {
  const body = await request.json();
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    const error = parsed.error.issues[0]?.message || "Validation failed";
    const path = parsed.error.issues[0]?.path.join(".");
    return NextResponse.json(
      { ok: false, error: `${path}: ${error}` },
      { status: 400 }
    );
  }

  const payload = {
    ...parsed.data,
    xTokenExpiresAt: parsed.data.xTokenExpiresAt
      ? new Date(parsed.data.xTokenExpiresAt)
      : null,
    ytTokenExpiresAt: parsed.data.ytTokenExpiresAt
      ? new Date(parsed.data.ytTokenExpiresAt)
      : null,
  };

  try {
    const updated = await updateSettings(payload);
    return NextResponse.json({ ok: true, settings: updated });
  } catch (error) {
    console.error("Failed to update settings:", error);
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}
