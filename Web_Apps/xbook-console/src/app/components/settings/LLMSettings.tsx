"use client";

import { useState } from "react";
import { HelpTooltip, SecretField, SettingsSection, secondaryButtonClass } from "./SharedFields";
import { useLLMSettings } from "../../hooks/settings/useLLMSettings";
import { useSettingsContext } from "../../hooks/settings/useSettingsContext";

export function LLMSettings() {
  const { form, setForm, updateField, updateNumberField, updateBooleanField, defaultPrompt, isDirty } =
    useSettingsContext();
  const {
    llmTest,
    testingLlm,
    clearingLogs,
    modelHistory,
    showHistory,
    setShowHistory,
    historyRef,
    testLlm,
    applyLlmPreset,
    clearProcessingHistory,
    resetPrompt,
    fetchModels,
    fetchingModels,
    cleanupStuckJobs,
  } = useLLMSettings();

  const [showAdvanced, setShowAdvanced] = useState(false);

  return (
    <SettingsSection
      title="AI / LLM"
      description="Essentials get you enriching; open Advanced for prompts, limits, and maintenance."
      defaultOpen
    >
      <div>
        <div className="mt-1 flex flex-wrap items-center gap-3 text-xs text-slate-500">
          <span className="font-semibold text-slate-700">Presets:</span>
          <button
            type="button"
            onClick={() => applyLlmPreset("lmstudio")}
            className="rounded-md border border-black/10 px-3 py-1.5 text-xs font-semibold text-slate-700 transition hover:bg-slate-50 hover:text-emerald-800"
          >
            LM Studio defaults
          </button>
          <button
            type="button"
            onClick={() => applyLlmPreset("ollama")}
            className="rounded-md border border-black/10 px-3 py-1.5 text-xs font-semibold text-slate-700 transition hover:bg-slate-50 hover:text-emerald-800"
          >
            Ollama defaults
          </button>
          <button
            type="button"
            onClick={() => applyLlmPreset("mlx")}
            className="rounded-md border border-black/10 px-3 py-1.5 text-xs font-semibold text-slate-700 transition hover:bg-slate-50 hover:text-emerald-800"
          >
            MLX (Qwen2.5-Coder-14B-Instruct-MLX-4bit)
          </button>
          <button
            type="button"
            onClick={() => applyLlmPreset("vllm")}
            className="rounded-md border border-black/10 px-3 py-1.5 text-xs font-semibold text-slate-700 transition hover:bg-slate-50 hover:text-emerald-800"
          >
            vLLM (Port 8000)
          </button>
        </div>

        <div className="mt-4 grid gap-4 md:grid-cols-6">
          <div className="space-y-2 md:col-span-3">
            <label className="text-sm font-semibold">
              LLM base URL *{" "}
              <HelpTooltip text="The API endpoint for your model server (e.g. LM Studio, vLLM, or OpenAI)." />
            </label>
            <input
              type="text"
              value={form.llmBaseUrl ?? ""}
              onChange={updateField("llmBaseUrl")}
              placeholder="http://127.0.0.1:1234/v1"
              className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
            />
          </div>
          <div className="md:col-span-3">
            <SecretField
              label={
                <>
                  LLM API key{" "}
                  <HelpTooltip text="Authentication key for your API provider. Use 'lm-studio' for local instances." />
                </>
              }
              value={form.llmApiKey}
              onChange={updateField("llmApiKey")}
              placeholder="lm-studio"
            />
          </div>
          <div className="space-y-2 md:col-span-2">
            <label className="text-sm font-semibold">
              LLM model *{" "}
              <HelpTooltip text="The exact model ID loaded in LM Studio or your API provider." />
            </label>
            <div className="relative" ref={historyRef}>
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={form.llmModel ?? ""}
                  onChange={updateField("llmModel")}
                  onFocus={() => setShowHistory(true)}
                  placeholder="qwen2.5-coder-14b"
                  className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
                />
                <button
                  type="button"
                  onClick={fetchModels}
                  disabled={fetchingModels || !form.llmBaseUrl}
                  title="Fetch models from server"
                  className="flex h-11 w-11 items-center justify-center rounded-md border border-black/10 bg-slate-50 transition hover:bg-slate-100 disabled:opacity-50"
                >
                  <svg
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    className={`h-5 w-5 ${fetchingModels ? "animate-spin" : ""}`}
                  >
                    <path
                      fillRule="evenodd"
                      d="M15.312 11.424a5.5 5.5 0 01-9.201 2.466l-.312-.311h2.433a.75.75 0 000-1.5H3.989a.75.75 0 00-.75.75v4.242a.75.75 0 001.5 0v-2.43l.31.31a7 7 0 0011.712-3.138.75.75 0 00-1.449-.39zm1.23-6.242a.75.75 0 00-1.5 0v2.43l-.31-.31a7 7 0 00-11.712 3.138.75.75 0 001.449.39 5.5 5.5 0 019.201-2.466l.312.311h-2.433a.75.75 0 000 1.5H16.01a.75.75 0 00.75-.75V3.75z"
                      clipRule="evenodd"
                    />
                  </svg>
                </button>
              </div>
              {showHistory && modelHistory.length > 0 && (
                <div className="absolute left-0 right-0 top-full z-10 mt-1 max-h-48 overflow-auto rounded-md border border-black/10 bg-white p-1 shadow-lg">
                  <p className="px-2 py-1 text-[10px] font-bold uppercase text-slate-400">Recently used</p>
                  {modelHistory.map((m) => (
                    <button
                      key={m}
                      type="button"
                      onClick={() => {
                        setForm((prev) => ({ ...prev, llmModel: m }));
                        setShowHistory(false);
                      }}
                      className="w-full rounded px-2 py-1.5 text-left text-sm hover:bg-slate-50"
                    >
                      {m}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>
          <div className="space-y-2 md:col-span-2">
            <label className="text-sm font-semibold">
              Embedding model{" "}
              <HelpTooltip text="Model used for semantic search vectors. Use a dedicated embedding model (e.g. nomic-embed-text, text-embedding-3-small). Do not reuse your chat model here." />
            </label>
            <input
              type="text"
              value={form.llmEmbeddingModel ?? ""}
              onChange={updateField("llmEmbeddingModel")}
              placeholder="nomic-embed-text"
              className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
            />
          </div>
          <div className="space-y-2 md:col-span-2">
            <label className="text-sm font-semibold">
              Embedding base URL{" "}
              <HelpTooltip text="Optional. OpenAI-compatible embeddings endpoint. Leave blank to reuse the LLM base URL. Use a separate host when chat is vLLM/MLX and embeddings run on Ollama/LM Studio." />
            </label>
            <input
              type="text"
              value={form.llmEmbeddingBaseUrl ?? ""}
              onChange={updateField("llmEmbeddingBaseUrl")}
              placeholder="http://127.0.0.1:11434/v1"
              className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
            />
          </div>
        </div>

        <div className="mt-4 flex flex-wrap items-center gap-3">
          <button type="button" onClick={testLlm} disabled={testingLlm} className={secondaryButtonClass}>
            {testingLlm ? "Testing LLM…" : "Test LLM connection"}
          </button>
          {isDirty && (
            <span className="flex items-center gap-1.5 rounded-full border border-amber-100 bg-amber-50 px-3 py-1 text-[10px] font-bold uppercase tracking-tight text-amber-700">
              <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-amber-500" />
              Unsaved changes
            </span>
          )}
          {llmTest ? <p className="text-sm text-slate-600">{llmTest}</p> : null}
        </div>

        <div className="mt-6 border-t border-black/5 pt-4">
          <button
            type="button"
            onClick={() => setShowAdvanced((v) => !v)}
            aria-expanded={showAdvanced}
            className="flex items-center gap-2 text-sm font-semibold text-slate-700 transition hover:text-emerald-800"
          >
            <span className="text-[10px] font-bold">{showAdvanced ? "▲" : "▼"}</span>
            {showAdvanced ? "Hide advanced" : "Show advanced"}
            <span className="text-xs font-normal text-slate-500">
              prompts, tokens, concurrency, thinking, logs, maintenance
            </span>
          </button>

          {showAdvanced ? (
            <div className="mt-4 grid gap-4 md:grid-cols-6">
              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-semibold">
                  LLM concurrency{" "}
                  <HelpTooltip text="Number of parallel enrichment requests. Local models perform best with 1." />
                </label>
                <input
                  type="number"
                  min={1}
                  max={6}
                  value={form.llmConcurrency ?? ""}
                  onChange={updateNumberField("llmConcurrency")}
                  placeholder="1"
                  className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
                />
              </div>
              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-semibold">
                  Context window (Input){" "}
                  <HelpTooltip text="Limits the amount of input text sent to the model to prevent 'Context size exceeded' errors. Use tokens (e.g. 128000)." />
                </label>
                <input
                  type="number"
                  min={1000}
                  max={1000000}
                  value={form.llmContextWindow ?? ""}
                  onChange={updateNumberField("llmContextWindow")}
                  placeholder="128000"
                  className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
                />
              </div>
              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-semibold">
                  Limit response length{" "}
                  <HelpTooltip text="Maximum tokens for the generated response. Set to 0 for no limit (model default)." />
                </label>
                <input
                  type="number"
                  min={0}
                  max={128000}
                  value={form.llmResponseLimit ?? ""}
                  onChange={updateNumberField("llmResponseLimit")}
                  placeholder="2000"
                  className={`w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm ${
                    form.llmResponseLimit === 0 ? "font-bold text-emerald-700" : ""
                  }`}
                />
                {form.llmResponseLimit === 0 && (
                  <p className="text-[10px] font-bold uppercase tracking-tight text-emerald-600">
                    No output limit active
                  </p>
                )}
              </div>
              <div className="space-y-2 md:col-span-2">
                <label className="text-sm font-semibold">
                  Target language <HelpTooltip text="The default language for bookmark translations." />
                </label>
                <select
                  value={form.targetLanguage ?? "English"}
                  onChange={(e) => setForm((prev) => ({ ...prev, targetLanguage: e.target.value }))}
                  className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
                >
                  <option value="English">English</option>
                  <option value="Spanish">Spanish</option>
                  <option value="French">French</option>
                  <option value="German">German</option>
                  <option value="Italian">Italian</option>
                  <option value="Portuguese">Portuguese</option>
                  <option value="Russian">Russian</option>
                  <option value="Chinese">Chinese</option>
                  <option value="Japanese">Japanese</option>
                  <option value="Korean">Korean</option>
                </select>
              </div>
              <div className="space-y-2 md:col-span-6">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <label className="text-sm font-semibold">
                    LLM system prompt{" "}
                    <HelpTooltip text="High-level instructions sent to the model to define its persona and output rules." />
                  </label>
                </div>
                <textarea
                  value={form.llmSystemPrompt || ""}
                  onChange={updateField("llmSystemPrompt")}
                  placeholder="System instructions for the model..."
                  className="min-h-[80px] w-full rounded-md border border-black/10 bg-white px-4 py-3 font-mono text-sm"
                />
              </div>
              <div className="space-y-2 md:col-span-6">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <label className="text-sm font-semibold">
                    LLM prompt (advanced){" "}
                    <HelpTooltip text="The detailed template used to guide the enrichment process. Use placeholders carefully." />
                  </label>
                  <button
                    type="button"
                    onClick={resetPrompt}
                    className="rounded-md border border-black/10 px-3 py-1.5 text-xs font-semibold text-slate-700 transition hover:bg-slate-50 hover:text-emerald-800"
                  >
                    Reset prompt to default
                  </button>
                </div>
                <textarea
                  value={form.llmPrompt || ""}
                  onChange={updateField("llmPrompt")}
                  placeholder={defaultPrompt}
                  className="min-h-[240px] w-full rounded-md border border-black/10 bg-white px-4 py-3 font-mono text-sm"
                />
                <p className="text-xs text-slate-500">
                  Customize how your bookmarks are summarized. Click &quot;Reset prompt to default&quot; to restore the Master
                  Researcher template.
                </p>
              </div>
              <label className="flex items-start gap-3 rounded-md border border-black/10 bg-white px-4 py-3 text-sm md:col-span-3">
                <input
                  type="checkbox"
                  checked={form.llmThinkingEnabled ?? false}
                  onChange={updateBooleanField("llmThinkingEnabled")}
                  className="mt-1 h-4 w-4"
                />
                <span>
                  <span className="flex items-center gap-1.5 font-semibold">
                    Enable LLM thinking{" "}
                    <HelpTooltip text="When off, xBook prepends /no_think to the system prompt for models that support it. When on, that instruction is removed." />
                  </span>
                  <span className="block text-xs text-slate-500">
                    Useful for reasoning models, but slower and more likely to exceed response limits.
                  </span>
                </span>
              </label>
              <label className="flex items-start gap-3 rounded-md border border-black/10 bg-white px-4 py-3 text-sm md:col-span-3">
                <input
                  type="checkbox"
                  checked={form.logLlmPayloads ?? true}
                  onChange={updateBooleanField("logLlmPayloads")}
                  className="mt-1 h-4 w-4"
                />
                <span>
                  <span className="flex items-center gap-1.5 font-semibold">
                    Store LLM technical logs{" "}
                    <HelpTooltip text="Retains full prompt and response payloads for debugging in the Processing page." />
                  </span>
                  <span className="block text-xs text-slate-500">
                    Useful for validating model behavior. Turn off to save database space.
                  </span>
                </span>
              </label>
              <div className="flex flex-wrap items-center gap-3 md:col-span-6">
                <button
                  type="button"
                  onClick={cleanupStuckJobs}
                  className={`${secondaryButtonClass} hover:bg-red-50 hover:text-red-700`}
                >
                  Cleanup stuck operations
                </button>
                <button
                  type="button"
                  onClick={clearProcessingHistory}
                  disabled={clearingLogs}
                  className={secondaryButtonClass}
                >
                  {clearingLogs ? "Clearing…" : "Clear processing history"}
                </button>
              </div>
            </div>
          ) : null}
        </div>
      </div>
    </SettingsSection>
  );
}
