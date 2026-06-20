import { getSettings } from "@/lib/settings";

export const DEFAULT_PROMPT = [
  "You are an expert research analyst and knowledge curator. Your goal is to transform social media bookmarks and video transcripts into a high-value personal knowledge base.",
  "", "OUTPUT FORMAT:", "Return ONLY a valid, compact JSON object. No markdown, no code fences, no preamble.",
  "{", "  \"summary\": \"string\",", "  \"category\": \"string\",", "  \"tags\": [\"string\"]", "}", "",
  "SUMMARY GUIDELINES (3-6 sentences):", "1. THE CONTEXT: Identify exactly what this is.", "2. THE CORE INSIGHT: Extract the primary nugget of wisdom.", "3. THE EVIDENCE/TRADEOFFS: Mention a specific example.", "4. THE UTILITY: Explicitly state who this is for.", "",
  "MEDIA CONTEXT:", "If the provided text is sparse, use the Author's identity and the 'Media Description' to infer what is happening.", "",
  "CATEGORIZATION:", "Choose the most specific label: AI, Tech, Business, Design, Science, Finance, Health, Career, Productivity, News, Culture, Politics, Education, Entertainment, Music, Shopping, or Other.", "",
  "TAGGING:", "Provide 3-5 high-signal, searchable keywords.", "",
  "CONTEXTUAL INTELLIGENCE:", "- If a YouTube transcript is provided, prioritize the speaker's unique thesis.", "- Use the 'Folder' name to infer intent.", "- If content is sparse, return empty summary and 'Other' category.", "",
  "TRANSLATION:", "If not in English, you MUST translate core insights and summary into fluent English. JSON values MUST always be in English.", "",
  "REASONING MODEL INSTRUCTION:", "If you are a reasoning model, keep your internal thought process concise and focused entirely on extracting the JSON fields.",
].join("\n");

export const DEFAULT_SYSTEM_PROMPT = [
  "/no_think",
  "Return only compact valid JSON. Do not include markdown, prose, explanations, or reasoning."
].join("\n");

function mapXDetails(s: any) {
  return { hasAccessToken: !!s.xAccessToken, hasRefreshToken: !!s.xRefreshToken, hasBearerToken: !!s.xBearerToken, userId: s.xUserId ?? null, tokenExpiresAt: s.xTokenExpiresAt?.toISOString() ?? null, scope: s.xScope ?? null, apiBase: s.xApiBase ?? "https://api.x.com/2" };
}

function mapInitialState(s: any) {
  return {
    ...s,
    xTokenExpiresAt: s.xTokenExpiresAt?.toISOString() ?? null,
    ytTokenExpiresAt: s.ytTokenExpiresAt?.toISOString() ?? null,
    monthlyCap: s.monthlyCap ?? 100, ytMonthlyCap: s.ytMonthlyCap ?? 100,
    llmSystemPrompt: s.llmSystemPrompt ?? DEFAULT_SYSTEM_PROMPT,
    llmContextWindow: s.llmContextWindow ?? 128000,
    llmResponseLimit: s.llmResponseLimit ?? 2000,
    llmThinkingEnabled: s.llmThinkingEnabled ?? false,
    llmPrompt: s.llmPrompt ?? null, enrichBatchSize: s.enrichBatchSize ?? 25,
    llmConcurrency: s.llmConcurrency ?? 1, llmMaxTokens: s.llmMaxTokens ?? 4000,
    logLlmPayloads: s.logLlmPayloads ?? true, soundOnComplete: s.soundOnComplete ?? false, soundOnError: s.soundOnError ?? false
  };
}

export async function getSettingsPageData() {
  const s = await getSettings();
  return { dia: mapXDetails(s), init: mapInitialState(s) };
}
