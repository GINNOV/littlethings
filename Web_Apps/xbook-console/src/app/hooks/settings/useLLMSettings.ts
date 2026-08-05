"use client";

import { useState, useEffect, useRef } from "react";
import { useSettingsContext } from "./useSettingsContext";

export function useLLMSettings() {
  const { form, setForm, setMessage, defaultPrompt } = useSettingsContext();
  
  const [llmTest, setLlmTest] = useState<string | null>(null);
  const [testingLlm, setTestingLlm] = useState(false);
  const [clearingLogs, setClearingLogs] = useState(false);
  const [modelHistory, setModelHistory] = useState<string[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  const [fetchingModels, setFetchingModels] = useState(false);
  const historyRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const raw = localStorage.getItem("xbook:llm-model-history");
    if (raw) {
      try {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) setModelHistory(parsed);
      } catch (e) {
        console.error("Failed to parse model history", e);
      }
    }
  }, []);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (historyRef.current && !historyRef.current.contains(event.target as Node)) {
        setShowHistory(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const testLlm = async () => {
    setTestingLlm(true);
    setLlmTest(null);
    try {
      const res = await fetch("/api/settings/test", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: "llm", ...form }),
      });
      const json = await res.json();
      const errorMessage =
        typeof json.error === "string"
          ? json.error
          : json.error
            ? JSON.stringify(json.error)
            : null;
      if (!res.ok) throw new Error(errorMessage ?? "LLM test failed");
      setLlmTest(json.message ?? "LLM connection ok.");
    } catch (error) {
      setLlmTest(error instanceof Error ? error.message : "LLM test failed");
    } finally {
      setTestingLlm(false);
    }
  };

  const applyLlmPreset = (preset: "lmstudio" | "mlx" | "vllm" | "ollama") => {
    if (preset === "ollama") {
      setForm((prev) => ({
        ...prev,
        llmBaseUrl: "http://127.0.0.1:11434/v1",
        llmApiKey: "ollama",
        llmConcurrency: 1,
        llmEmbeddingBaseUrl: "http://127.0.0.1:11434/v1",
        llmEmbeddingModel: prev.llmEmbeddingModel || "nomic-embed-text",
      }));
      return;
    }

    if (preset === "lmstudio") {
      setForm((prev) => ({
        ...prev,
        llmBaseUrl: "http://127.0.0.1:1234/v1",
        llmApiKey: "lm-studio",
        llmConcurrency: 1,
      }));
      return;
    }

    if (preset === "vllm") {
      setForm((prev) => ({
        ...prev,
        llmBaseUrl: "http://127.0.0.1:8000/v1",
        llmApiKey: "vllm",
        llmConcurrency: 1,
        // vLLM chat servers often lack /v1/embeddings — default embeddings to local Ollama.
        llmEmbeddingBaseUrl: prev.llmEmbeddingBaseUrl || "http://127.0.0.1:11434/v1",
        llmEmbeddingModel: prev.llmEmbeddingModel || "nomic-embed-text",
      }));
      return;
    }

    setForm((prev) => ({
      ...prev,
      llmModel: "qwen/qwen2.5-coder-14b",
      llmConcurrency: 1,
    }));
  };

  const clearProcessingHistory = async () => {
    setClearingLogs(true);
    setMessage(null);
    try {
      const res = await fetch("/api/processing/clear", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Clear failed");
      setMessage("Processing history cleared.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Clear failed");
    } finally {
      setClearingLogs(false);
    }
  };

  const resetPrompt = () => {
    setForm((prev) => ({ ...prev, llmPrompt: defaultPrompt }));
  };

  const cleanupStuckJobs = async () => {
    setLlmTest(null);
    try {
      const res = await fetch("/api/processing/runs/cleanup", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Cleanup failed");
      setLlmTest(json.message);
    } catch (error) {
      setLlmTest(error instanceof Error ? error.message : "Cleanup failed");
    }
  };

  const fetchModels = async () => {
    setFetchingModels(true);
    setLlmTest(null);
    try {
      const res = await fetch("/api/settings/models", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ baseUrl: form.llmBaseUrl, apiKey: form.llmApiKey }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to fetch models");
      if (json.models?.length > 0) {
        setModelHistory((prev) => Array.from(new Set([...json.models, ...prev])).slice(0, 10));
        setShowHistory(true);
        setLlmTest(`Found ${json.models.length} models on server.`);
      }
    } catch (error) {
      setLlmTest(error instanceof Error ? error.message : "Fetch models failed");
    } finally {
      setFetchingModels(false);
    }
  };

  return {
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
  };
}
