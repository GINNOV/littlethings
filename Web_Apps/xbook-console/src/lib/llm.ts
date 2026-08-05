import OpenAI from "openai";
import { z } from "zod";
import { getSettings } from "@/lib/settings";
import { logLlmRequest, logProcessingEvent } from "@/lib/processing";

// --- Configuration & Schemas ---

const envSchema = z.object({
  OPENAI_BASE_URL: z.string().url().optional(),
  OPENAI_API_KEY: z.string().min(1).optional(),
  OPENAI_MODEL: z.string().min(1).optional(),
});

const cleanEnv = (value?: string) => {
  if (!value) return undefined;
  const trimmed = value.trim();
  return trimmed.length ? trimmed : undefined;
};

const DEFAULT_SYSTEM_PROMPT = "Return only compact valid JSON. Do not include markdown, prose, explanations, or reasoning.";

function applyThinkingPreference(systemPrompt: string, thinkingEnabled?: boolean | null) {
  const withoutNoThink = systemPrompt
    .split("\n")
    .filter((line) => line.trim() !== "/no_think")
    .join("\n")
    .trim();

  if (thinkingEnabled) {
    return withoutNoThink || DEFAULT_SYSTEM_PROMPT;
  }

  return withoutNoThink.startsWith("/no_think")
    ? withoutNoThink
    : `/no_think\n${withoutNoThink || DEFAULT_SYSTEM_PROMPT}`;
}

const rawResponseSchema = z.object({
  summary: z.string().optional(),
  category: z.string().optional(),
  tags: z.union([z.array(z.string()), z.string()]).optional(),
});

export type Enrichment = {
  summary: string;
  category: string;
  tags?: string[];
  embedding?: number[];
};

export type SummarizeInput = {
  text?: string;
  authorUsername?: string;
  externalUrls?: string[];
  sourceText?: string;
  mediaDescription?: string;
  folderName?: string;
  signal?: AbortSignal;
  processing?: {
    runId?: string | null;
    bookmarkId?: string | null;
  };
};

// --- Prompt Templates ---

const PROMPTS = {
  DEFAULT_ENRICHMENT: [
    "You are an expert research analyst and knowledge curator. Your goal is to transform social media bookmarks and video transcripts into a high-value personal knowledge base.",
    "",
    "OUTPUT FORMAT:",
    "Return ONLY a valid, compact JSON object. No markdown, no code fences, no preamble.",
    "{",
    "  \"summary\": \"string\",",
    "  \"category\": \"string\",",
    "  \"tags\": [\"string\"]",
    "}",
    "",
    "SUMMARY GUIDELINES (3-6 sentences):",
    "1. THE CONTEXT: Identify exactly what this is (e.g., \"A technical deep-dive video into...\", \"A tutorial on...\").",
    "2. THE CORE INSIGHT: Extract the primary 'nugget' of wisdom or the main argument. For videos, prioritize the unique value shared in the content.",
    "3. THE EVIDENCE/TRADEOFFS: Mention a specific example, statistic, or tradeoff discussed in the content/transcript.",
    "4. THE UTILITY: Explicitly state who this is for or how a builder/researcher can apply this information today.",
    "",
    "MEDIA CONTEXT:",
    "For X bookmarks, use the 'Media Description' to infer content if text is sparse.",
    "For YouTube videos, the provided transcript or description is your primary source. Synthesize the speaker's main points.",
    "",
    "CATEGORIZATION:",
    "Choose the most specific label: AI, Tech, Business, Design, Science, Finance, Health, Career, Productivity, News, Culture, Politics, Education, Entertainment, Music, Shopping, or Other.",
    "- Use 'AI' for LLMs, Machine Learning, or Automation.",
    "- Use 'Productivity' for workflows, mental frameworks, or life-hacks.",
    "- Use 'Design' for UI/UX, Architecture, or Aesthetics.",
    "",
    "TAGGING:",
    "Provide 3-5 high-signal, searchable keywords. Prefer specific entities (e.g., \"Next.js\", \"Stable Diffusion\") over generic ones (e.g., \"software\", \"images\").",
    "",
    "CONTEXTUAL INTELLIGENCE:",
    "- If a YouTube transcript or video description is provided, ignore standard intro/outros and 'like/subscribe' calls. Focus entirely on the information density.",
    "- Use the 'Folder' or 'Playlist' name to infer the user's intent for saving this item.",
    "- If the content is genuinely sparse, return an empty summary string and 'Other' category.",
    "",
    "TRANSLATION:",
    "If the source text or transcript is not in English, you MUST translate the core insights and summary into fluent, professional English. The final JSON values for summary, category, and tags MUST always be in English.",
    "",
    "REASONING MODEL INSTRUCTION:",
    "If you are a reasoning model, keep your internal thought process concise and focused entirely on extracting the JSON fields requested above.",
  ].join("\n"),

  TRANSLATION: (targetLanguage: string) => [
    `You are a professional translator. Translate the following text into ${targetLanguage}.`,
    "Maintain the original tone, formatting, and intent.",
    "If the text is already in the target language, return it exactly as is.",
    "Return ONLY the translated text. No preamble, no explanation, no code fences.",
  ].join("\n"),
};

// --- Core API Logic ---

async function getLlmConfig() {
  const env = envSchema.parse({
    OPENAI_BASE_URL: cleanEnv(process.env.OPENAI_BASE_URL),
    OPENAI_API_KEY: cleanEnv(process.env.OPENAI_API_KEY),
    OPENAI_MODEL: cleanEnv(process.env.OPENAI_MODEL),
  });
  const settings = await getSettings();
  const baseUrl = settings.llmBaseUrl ?? env.OPENAI_BASE_URL ?? "http://localhost:1234/v1";
  const apiKey = settings.llmApiKey ?? env.OPENAI_API_KEY ?? "lm-studio";
  const model = settings.llmModel ?? env.OPENAI_MODEL;
  const systemPrompt = applyThinkingPreference(settings.llmSystemPrompt ?? DEFAULT_SYSTEM_PROMPT, settings.llmThinkingEnabled);
  const contextWindow = settings.llmContextWindow ?? 128000;
  const responseLimit = settings.llmResponseLimit ?? 2000;
  const maxTokens = settings.llmMaxTokens ?? 2500;
  const logLlmPayloads = settings.logLlmPayloads ?? true;

  if (!model) {
    throw new Error("Missing LLM model. Set it in Settings or .env.local.");
  }

  const client = new OpenAI({ 
    apiKey, 
    baseURL: baseUrl,
    timeout: 300000, // 300s global timeout (5 minutes)
  });
  return { client, model, baseUrl, maxTokens, contextWindow, responseLimit, logLlmPayloads, customPrompt: settings.llmPrompt, systemPrompt };
}

/** Separate OpenAI-compatible client for embeddings (often a different host/model than chat). */
async function getEmbeddingConfig() {
  const env = envSchema.parse({
    OPENAI_BASE_URL: cleanEnv(process.env.OPENAI_BASE_URL),
    OPENAI_API_KEY: cleanEnv(process.env.OPENAI_API_KEY),
    OPENAI_MODEL: cleanEnv(process.env.OPENAI_MODEL),
  });
  const settings = await getSettings();
  const chatBaseUrl = settings.llmBaseUrl ?? env.OPENAI_BASE_URL ?? "http://localhost:1234/v1";
  const baseUrl =
    cleanEnv(settings.llmEmbeddingBaseUrl ?? undefined) ??
    chatBaseUrl;
  const apiKey = settings.llmApiKey ?? env.OPENAI_API_KEY ?? "lm-studio";
  // Prefer dedicated embedding model; never fall back to a chat model id (usually unsupported).
  const model =
    cleanEnv(settings.llmEmbeddingModel ?? undefined) ??
    cleanEnv(process.env.OPENAI_EMBEDDING_MODEL) ??
    "text-embedding-3-small";

  const client = new OpenAI({
    apiKey,
    baseURL: baseUrl,
    timeout: 60000,
  });
  return { client, model, baseUrl };
}

export async function validateModelAvailability(signal?: AbortSignal) {
  const config = await getLlmConfig();
  try {
    const models = await config.client.models.list({ signal });
    const isLoaded = models.data.some((m) => m.id === config.model);
    if (!isLoaded) {
      throw new Error(`Model error: Model "${config.model}" is not currently available at ${config.baseUrl}. Please check your model server.`);
    }
    return true;
  } catch (error) {
    if (error instanceof Error && error.message.includes("No models loaded")) {
      throw new Error("Model error: No models are currently loaded on the server. Please load a model before starting.");
    }
    throw error;
  }
}

async function callLlm(params: {
  prompt: string;
  temperature: number;
  maxTokens?: number;
  signal?: AbortSignal;
  processing?: { runId?: string | null; bookmarkId?: string | null };
  type?: string;
}) {
  const { prompt, temperature, maxTokens, signal, processing, type = "enrichment" } = params;
  const config = await getLlmConfig();

  await logProcessingEvent({
    runId: processing?.runId,
    bookmarkId: processing?.bookmarkId,
    type: "llm",
    status: "sent_to_llm",
    message: `Sent request to LLM for ${type}.`,
    metadata: { model: config.model, baseUrl: config.baseUrl },
  });

  const startedAt = Date.now();
  let content = "";
  try {
    const finalMaxTokens = maxTokens ?? (config.responseLimit > 0 ? config.responseLimit : undefined);

    const completion = await config.client.chat.completions.create({
      model: config.model,
      messages: [
        { role: "system", content: config.systemPrompt },
        { role: "user", content: prompt }
      ],
      temperature,
      max_tokens: finalMaxTokens,
    }, { signal });

    content = completion.choices[0]?.message?.content ?? "";
    if (!content || !content.trim()) {
      throw new Error(`LLM returned an empty response for ${type}.`);
    }

    return { 
      content, 
      usage: completion.usage, 
      durationMs: Date.now() - startedAt, 
      config,
      prompt
    };
  } catch (error) {
    let message = error instanceof Error ? error.message : "Unknown LLM error";
    if (message.includes("No models loaded")) {
      message = "Model error: No models are currently loaded on the server. Please load your model first.";
    }
    await logLlmRequest({
      runId: processing?.runId,
      bookmarkId: processing?.bookmarkId,
      model: config.model,
      baseUrl: config.baseUrl,
      prompt,
      response: content,
      durationMs: Date.now() - startedAt,
      error: message,
      includePayloads: config.logLlmPayloads,
    });
    throw new Error(message);
  }
}

// --- Public Functions ---

function extractJson(content: string) {
  if (!content || !content.trim()) {
    throw new Error("Model returned an empty response instead of a JSON object.");
  }

  const firstBrace = content.indexOf("{");
  const lastBrace = content.lastIndexOf("}");

  if (firstBrace === -1) {
    throw new Error(`No starting '{' found in model response. Raw: "${content.slice(0, 100)}..."`);
  }

  if (lastBrace === -1 || lastBrace < firstBrace) {
    throw new Error(
      "Model response started a JSON object but never closed it. " +
      "This usually means the 'Limit response length' in Settings is too low for this model's thinking process. " +
      `Raw: "${content.slice(0, 100)}..."`
    );
  }

  const jsonBlock = content.slice(firstBrace, lastBrace + 1);
  try {
    return JSON.parse(jsonBlock);
  } catch (e: any) {
    // If parsing still fails, it might be due to internal malformation
    throw new Error(`JSON structure is invalid: ${e.message}. Attempted to parse: "${jsonBlock.slice(0, 100)}..."`);
  }
}

export async function summarizeBookmark(input: {
  text?: string;
  authorUsername?: string;
  externalUrls?: string[];
  sourceText?: string;
  mediaDescription?: string;
  folderName?: string;
  signal?: AbortSignal;
  processing?: {
    runId?: string | null;
    bookmarkId?: string | null;
  };
}) {
  const config = await getLlmConfig();

  // Use Context Window to slice input (approx 4 chars per token)
  const maxChars = config.contextWindow * 4;
  const textChars = Math.floor(maxChars * 0.4);
  const sourceChars = Math.floor(maxChars * 0.6);

  const promptBody = [
    `Text: ${(input.text ?? "").slice(0, textChars)}`,
    `Folder/Playlist: ${input.folderName ?? ""}`,
    `Author: ${input.authorUsername ?? ""}`,
    `Links: ${(input.externalUrls ?? []).join(", ")}`,
    `Media Description: ${input.mediaDescription ?? ""}`,
    `Linked content (excerpts): ${(input.sourceText ?? "").slice(0, sourceChars)}`,
  ].join("\n");

  const prompt = `${config.customPrompt ?? PROMPTS.DEFAULT_ENRICHMENT}\n\n${promptBody}`;

  const maxAttempts = 3;
  let attempt = 0;
  let lastError: any = null;
  let currentMaxTokens: number | undefined = undefined;
  let currentTemperature = 0.2;

  while (attempt < maxAttempts) {
    attempt++;
    try {
      if (input.signal?.aborted) {
        throw new Error("Operation aborted");
      }

      if (attempt > 1) {
        await logProcessingEvent({
          runId: input.processing?.runId,
          bookmarkId: input.processing?.bookmarkId,
          type: "system",
          status: "retrying",
          message: `Retrying enrichment (Attempt ${attempt}/${maxAttempts}) due to error: ${lastError?.message || "unknown error"}`,
        });
      }

      const result = await callLlm({
        prompt,
        temperature: currentTemperature,
        maxTokens: currentMaxTokens,
        signal: input.signal,
        processing: input.processing,
        type: "enrichment",
      });

      let parsed: any;
      try {
        parsed = extractJson(result.content);
      } catch (e: any) {
        throw new Error(`Failed to parse LLM response: ${e.message}. Raw: "${result.content.slice(0, 150)}..."`);
      }

      const enrichment = normalizeEnrichment(parsed, input);
      enrichment.embedding = await generateEmbedding(
        `${enrichment.summary}\n${enrichment.category}\n${(enrichment.tags || []).join(", ")}`,
        input.signal
      ).catch(() => undefined);

      await logLlmRequest({
        runId: input.processing?.runId,
        bookmarkId: input.processing?.bookmarkId,
        model: result.config.model,
        baseUrl: result.config.baseUrl,
        prompt: result.prompt,
        response: result.content,
        parsed: enrichment,
        durationMs: result.durationMs,
        tokenUsage: result.usage,
        includePayloads: result.config.logLlmPayloads,
      });

      return enrichment;
    } catch (error: any) {
      lastError = error;
      const errMsg = error instanceof Error ? error.message : "Unknown error";

      // If response is empty or cut off, retry with a large max_token limit (16000)
      if (errMsg.includes("empty response") || errMsg.includes("never closed it")) {
        currentMaxTokens = 16000;
      } else if (errMsg.includes("parse LLM response") || errMsg.includes("JSON")) {
        // If JSON parsing fails, try lower temperature and clear token constraints
        currentTemperature = 0.1;
        currentMaxTokens = 16000;
      }

      if (attempt < maxAttempts) {
        const delay = attempt * 1500;
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError || new Error("Failed to summarize bookmark after all attempts");
}

export async function translateText(input: {
  text: string;
  targetLanguage: string;
  signal?: AbortSignal;
  processing?: {
    runId?: string | null;
    bookmarkId?: string | null;
  };
}) {
  const prompt = `${PROMPTS.TRANSLATION(input.targetLanguage)}\n\nTEXT TO TRANSLATE:\n${input.text}`;

  const result = await callLlm({
    prompt,
    temperature: 0.1,
    signal: input.signal,
    processing: input.processing,
    type: "translation"
  });

  const translatedText = result.content.trim();

  await logLlmRequest({
    runId: input.processing?.runId,
    bookmarkId: input.processing?.bookmarkId,
    model: result.config.model,
    baseUrl: result.config.baseUrl,
    prompt: result.prompt,
    response: result.content,
    parsed: { translatedText },
    durationMs: result.durationMs,
    tokenUsage: result.usage,
    includePayloads: result.config.logLlmPayloads,
  });

  return translatedText;
}

export async function generateEmbedding(text: string, signal?: AbortSignal) {
  const config = await getEmbeddingConfig();
  try {
    const response = await config.client.embeddings.create({
      model: config.model,
      input: text.slice(0, 8000),
    }, { signal, timeout: 15000 }); // 15s timeout for embeddings
    const embedding = response.data?.[0]?.embedding;
    if (!embedding?.length) {
      throw new Error("Embedding API returned an empty vector.");
    }
    return embedding;
  } catch (error) {
    const status =
      error && typeof error === "object" && "status" in error
        ? Number((error as { status?: number }).status)
        : undefined;
    const rawMessage = error instanceof Error ? error.message : String(error);
    if (status === 404 || /404/.test(rawMessage)) {
      throw new Error(
        `Embeddings endpoint not found at ${config.baseUrl} (model "${config.model}"). ` +
          `Set Settings → Embedding base URL to an OpenAI-compatible embeddings server ` +
          `(e.g. Ollama at http://127.0.0.1:11434/v1) and Embedding model (e.g. nomic-embed-text).`
      );
    }
    throw new Error(
      `Embedding failed via ${config.baseUrl} model "${config.model}": ${rawMessage}`
    );
  }
}

// --- Internal Helpers ---

function normalizeEnrichment(parsed: any, input: any): Enrichment {
  const raw = rawResponseSchema.parse(parsed);
  const summary = (raw.summary ?? "").trim();
  const context = `${input.folderName ?? ""}\n${input.text ?? ""}\n${input.sourceText ?? ""}`.toLowerCase();
  
  let category = (raw.category ?? "").trim();
  if (!category || /^other$/i.test(category)) {
    if (/\b(shop|shopping|buy|purchase|deal|discount|coupon|sale|amazon|ebay|store|product review|unboxing)\b/.test(context)) {
      category = "Shopping";
    } else if (/\b(music|song|songs|album|playlist|choir|piano|guitar|dj|mix|soundtrack|uplifting)\b/.test(context)) {
      category = "Music";
    } else {
      category = "Other";
    }
  }

  const tags = Array.isArray(raw.tags)
    ? raw.tags.map((tag: string) => tag.trim()).filter(Boolean)
    : typeof raw.tags === "string"
      ? raw.tags.split(",").map((tag: string) => tag.trim()).filter(Boolean)
      : [];

  return {
    summary,
    category,
    tags: tags.length ? tags : undefined,
  };
}
