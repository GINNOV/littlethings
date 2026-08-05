import type { AppSettings } from "@/lib/settings";

/** Snapshot of LLM / run knobs stored on OperationRun.configJson. */
export type OperationRunConfig = {
  model?: string | null;
  baseUrl?: string | null;
  concurrency?: number | null;
  /** Items per page (cap). */
  batchSize?: number | null;
  /** 1-based current/completed batch index (0 = not started). */
  batchIndex?: number | null;
  /** Planned batches for this run (ceil(total / batchSize)). */
  totalBatches?: number | null;
  maxTokens?: number | null;
  thinking?: boolean | null;
  embeddingModel?: string | null;
  embeddingBaseUrl?: string | null;
};

function cleanEnv(v?: string | null) {
  const t = typeof v === "string" ? v.trim() : "";
  return t || null;
}

function stripTrailingSlash(url: string) {
  return url.replace(/\/+$/, "");
}

/** Safe host:port (or preset label) for display — never credentials. */
export function formatLlmEndpoint(baseUrl?: string | null): string | null {
  if (!baseUrl?.trim()) return null;
  try {
    const url = new URL(baseUrl.trim());
    const host = url.hostname;
    const port = url.port || (url.protocol === "https:" ? "443" : url.protocol === "http:" ? "80" : "");
    const local =
      host === "localhost" ||
      host === "127.0.0.1" ||
      host === "::1" ||
      host === "[::1]";

    if (local) {
      if (port === "1234") return "LM Studio";
      if (port === "11434") return "Ollama";
      if (port === "8000") return "vLLM (local)";
      return port ? `localhost:${port}` : "localhost";
    }

    // Common remote vLLM default in this app's presets
    if (port === "8000") return `${host}:8000`;
    return port && port !== "80" && port !== "443" ? `${host}:${port}` : host;
  } catch {
    return stripTrailingSlash(baseUrl.trim());
  }
}

export function parseRunConfig(configJson?: string | null): OperationRunConfig | null {
  if (!configJson?.trim()) return null;
  try {
    const parsed = JSON.parse(configJson) as OperationRunConfig;
    if (!parsed || typeof parsed !== "object") return null;
    return parsed;
  } catch {
    return null;
  }
}

export type RunConfigPart = {
  key: string;
  label: string;
  /** Optional hover detail (full URL, raw model id, etc.). */
  title?: string;
};

/** Discrete display chips for horizontal layouts. */
export function runConfigParts(config?: OperationRunConfig | null): RunConfigPart[] {
  if (!config) return [];
  const parts: RunConfigPart[] = [];

  const chatModel = config.model?.trim();
  const embedModel = config.embeddingModel?.trim();
  if (chatModel) {
    parts.push({ key: "model", label: chatModel, title: `Model: ${chatModel}` });
  } else if (embedModel) {
    parts.push({ key: "model", label: embedModel, title: `Embedding model: ${embedModel}` });
  }

  const endpoint =
    formatLlmEndpoint(config.baseUrl) ??
    (!chatModel ? formatLlmEndpoint(config.embeddingBaseUrl) : null);
  if (endpoint) {
    parts.push({
      key: "host",
      label: endpoint,
      title: config.baseUrl || config.embeddingBaseUrl || endpoint,
    });
  }

  if (config.concurrency != null && Number.isFinite(config.concurrency) && config.concurrency > 0) {
    parts.push({
      key: "concurrency",
      label: `×${config.concurrency}`,
      title: `Concurrency: ${config.concurrency}`,
    });
  }

  const batchIndex =
    config.batchIndex != null && Number.isFinite(config.batchIndex) ? Number(config.batchIndex) : null;
  const totalBatches =
    config.totalBatches != null && Number.isFinite(config.totalBatches) && config.totalBatches > 0
      ? Number(config.totalBatches)
      : null;
  // Show progress whenever multi-batch, or once a batch has started.
  if (totalBatches != null && (totalBatches > 1 || (batchIndex != null && batchIndex > 0))) {
    const current = Math.max(0, batchIndex ?? 0);
    const label = current > 0 ? `${current}/${totalBatches}` : `0/${totalBatches}`;
    parts.push({
      key: "batchProgress",
      label,
      title:
        current > 0
          ? `Batch ${current} of ${totalBatches}`
          : `0 of ${totalBatches} batches started`,
    });
  }

  if (config.batchSize != null && Number.isFinite(config.batchSize) && config.batchSize > 0) {
    parts.push({
      key: "batchSize",
      label: `size ${config.batchSize}`,
      title: `Batch size (cap): ${config.batchSize} items per batch`,
    });
  }
  if (config.maxTokens != null && Number.isFinite(config.maxTokens) && config.maxTokens > 0) {
    const t = config.maxTokens;
    const label = t >= 1000 && t % 1000 === 0 ? `${t / 1000}k tok` : `${t} tok`;
    parts.push({ key: "tokens", label, title: `Max tokens: ${t}` });
  }
  if (config.thinking) {
    parts.push({ key: "thinking", label: "thinking", title: "LLM thinking enabled" });
  }

  // Separate embed target only when chat model is present (enrichment runs).
  if (chatModel && embedModel) {
    const sameHost =
      !config.embeddingBaseUrl ||
      !config.baseUrl ||
      stripTrailingSlash(config.embeddingBaseUrl) === stripTrailingSlash(config.baseUrl);
    if (sameHost) {
      parts.push({ key: "embed", label: `embed ${embedModel}`, title: `Embedding: ${embedModel}` });
    } else {
      const embedHost = formatLlmEndpoint(config.embeddingBaseUrl);
      const label = embedHost ? `embed ${embedModel} @ ${embedHost}` : `embed ${embedModel}`;
      parts.push({
        key: "embed",
        label,
        title: config.embeddingBaseUrl || label,
      });
    }
  }

  return parts;
}

/**
 * Compact single-line form, e.g.
 * "qwen2.5 · 192.168.0.69:8000 · ×8 · batch 50 · 4k tok"
 */
export function formatRunConfig(config?: OperationRunConfig | null): string | null {
  const parts = runConfigParts(config);
  return parts.length > 0 ? parts.map((p) => p.label).join(" · ") : null;
}

/** Build enrichment-run snapshot from settings + effective knobs. */
export function buildEnrichmentRunConfig(
  settings: AppSettings | null | undefined,
  knobs: {
    concurrency: number;
    batchSize: number;
    batchIndex?: number;
    totalBatches?: number;
  }
): OperationRunConfig {
  const envModel = cleanEnv(process.env.OPENAI_MODEL);
  const envBase = cleanEnv(process.env.OPENAI_BASE_URL);
  return {
    model: cleanEnv(settings?.llmModel) ?? envModel,
    baseUrl: cleanEnv(settings?.llmBaseUrl) ?? envBase ?? "http://localhost:1234/v1",
    concurrency: knobs.concurrency,
    batchSize: knobs.batchSize,
    batchIndex: knobs.batchIndex ?? 0,
    totalBatches: knobs.totalBatches ?? 1,
    maxTokens: settings?.llmMaxTokens ?? null,
    thinking: !!settings?.llmThinkingEnabled,
  };
}

/** Pull "batch N of M" from legacy notes when configJson lacks progress. */
export function parseBatchProgressFromNotes(notes?: string | null): {
  batchIndex?: number;
  totalBatches?: number;
} {
  if (!notes?.trim()) return {};
  const m = notes.match(/batch\s+(\d+)\s+of\s+(\d+)/i);
  if (!m) return {};
  const batchIndex = Number(m[1]);
  const totalBatches = Number(m[2]);
  if (!Number.isFinite(batchIndex) || !Number.isFinite(totalBatches)) return {};
  return { batchIndex, totalBatches };
}

/** Merge a partial config into existing configJson. */
export function mergeRunConfigJson(
  configJson: string | null | undefined,
  patch: Partial<OperationRunConfig>
): string {
  const base = parseRunConfig(configJson) ?? {};
  return JSON.stringify({ ...base, ...patch });
}

/** Build embedding-sync snapshot. */
export function buildEmbeddingRunConfig(
  settings: AppSettings | null | undefined
): OperationRunConfig {
  const envBase = cleanEnv(process.env.OPENAI_BASE_URL);
  const chatBase = cleanEnv(settings?.llmBaseUrl) ?? envBase ?? "http://localhost:1234/v1";
  const embedBase = cleanEnv(settings?.llmEmbeddingBaseUrl) ?? chatBase;
  return {
    embeddingModel: cleanEnv(settings?.llmEmbeddingModel),
    embeddingBaseUrl: embedBase,
    // Drive host display via embeddingBaseUrl when model is unset.
    baseUrl: embedBase,
  };
}

/** Merge stored config with a first LLM log row (legacy runs without configJson). */
export function resolveRunConfig(input: {
  configJson?: string | null;
  llmModel?: string | null;
  llmBaseUrl?: string | null;
  notes?: string | null;
}): OperationRunConfig | null {
  const stored = parseRunConfig(input.configJson);
  const fromNotes = parseBatchProgressFromNotes(input.notes);
  const hasStored = !!(stored?.model || stored?.baseUrl || stored?.embeddingModel || stored?.batchSize);
  const hasLlm = !!(input.llmModel || input.llmBaseUrl);
  const hasNotesBatch = fromNotes.batchIndex != null || fromNotes.totalBatches != null;

  if (!hasStored && !hasLlm && !hasNotesBatch) return stored;

  return {
    ...(stored ?? {}),
    model: stored?.model ?? input.llmModel ?? null,
    baseUrl: stored?.baseUrl ?? input.llmBaseUrl ?? null,
    // Prefer live configJson batch progress; fall back to notes for older runs.
    batchIndex: stored?.batchIndex ?? fromNotes.batchIndex ?? null,
    totalBatches: stored?.totalBatches ?? fromNotes.totalBatches ?? null,
  };
}

export function serializeRunConfig(config: OperationRunConfig | null | undefined): string | null {
  if (!config) return null;
  try {
    return JSON.stringify(config);
  } catch {
    return null;
  }
}
