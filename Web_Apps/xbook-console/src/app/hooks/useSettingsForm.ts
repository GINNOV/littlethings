"use client";

import { useState, useEffect, useRef } from "react";
import { Settings } from "../components/settings/types";
import { openExternalUrl } from "@/app/lib/tauri";

export function useSettingsForm(initial: Settings, defaultPrompt: string) {
  const [form, setForm] = useState<Settings>(initial);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [xTest, setXTest] = useState<string | null>(null);
  const [ytTest, setYtTest] = useState<string | null>(null);
  const [llmTest, setLlmTest] = useState<string | null>(null);
  const [testingX, setTestingX] = useState(false);
  const [testingYt, setTestingYt] = useState(false);
  const [testingLlm, setTestingLlm] = useState(false);
  const [lookupUsername, setLookupUsername] = useState("");
  const [lookupMessage, setLookupMessage] = useState<string | null>(null);
  const [lookingUp, setLookingUp] = useState(false);
  const [markingLatest, setMarkingLatest] = useState(false);
  const [resettingBaseline, setResettingBaseline] = useState(false);
  const [clearingLogs, setClearingLogs] = useState(false);
  const [syncingEmbeddings, setSyncingEmbeddings] = useState(false);
  const [runningXDiagnostics, setRunningXDiagnostics] = useState(false);
  const [runningYtDiagnostics, setRunningYtDiagnostics] = useState(false);
  const [xDiagnosticResult, setXDiagnosticResult] = useState<unknown>(null);
  const [ytDiagnosticResult, setYtDiagnosticResult] = useState<unknown>(null);
  const [generatingYtUrl, setGeneratingYtUrl] = useState(false);
  const [modelHistory, setModelHistory] = useState<string[]>([]);
  const [showHistory, setShowHistory] = useState(false);
  const ytJsonInputRef = useRef<HTMLInputElement | null>(null);
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

  const updateField =
    (key: keyof Settings) =>
    (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      setForm((prev) => ({ ...prev, [key]: event.target.value }));
    };

  const updateNumberField =
    (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement>) => {
      const value = event.target.value;
      setForm((prev) => ({ ...prev, [key]: value ? Number(value) : null }));
    };

  const updateBooleanField =
    (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement>) => {
      setForm((prev) => ({ ...prev, [key]: event.target.checked }));
    };

  const persistSettings = async () => {
    setSaving(true);
    setMessage(null);
    setXTest(null);
    setYtTest(null);
    setLlmTest(null);
    try {
      const res = await fetch("/api/settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      
      const contentType = res.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        const json = await res.json();
        if (!res.ok) throw new Error(json.error ?? "Save failed");
      } else {
        if (!res.ok) {
          const text = await res.text();
          throw new Error(text || `Save failed with status ${res.status}`);
        }
      }

      if (form.llmModel) {
        const currentModel = form.llmModel.trim();
        const nextHistory = [
          currentModel,
          ...modelHistory.filter((m) => m !== currentModel),
        ].slice(0, 5);
        setModelHistory(nextHistory);
        localStorage.setItem("xbook:llm-model-history", JSON.stringify(nextHistory));
      }

      return true;
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Save failed");
      return false;
    } finally {
      setSaving(false);
    }
  };

  const save = async (event: React.FormEvent) => {
    event.preventDefault();
    const ok = await persistSettings();
    if (ok) setMessage("Settings saved.");
  };

  const clearOAuth = async () => {
    setSaving(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          xAccessToken: "",
          xRefreshToken: "",
          xTokenExpiresAt: null,
          xScope: "",
          xTokenType: "",
        }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Clear failed");
      setForm((prev) => ({
        ...prev,
        xAccessToken: null,
        xRefreshToken: null,
        xTokenExpiresAt: null,
        xScope: null,
        xTokenType: null,
      }));
      setMessage("X OAuth connection cleared.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Clear failed");
    } finally {
      setSaving(false);
    }
  };

  const clearYouTubeOAuth = async () => {
    setSaving(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ytAccessToken: "",
          ytRefreshToken: "",
          ytTokenExpiresAt: null,
          ytScope: "",
          ytTokenType: "",
        }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Clear failed");
      setForm((prev) => ({
        ...prev,
        ytAccessToken: null,
        ytRefreshToken: null,
        ytTokenExpiresAt: null,
        ytScope: null,
        ytTokenType: null,
      }));
      setMessage("YouTube OAuth connection cleared.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Clear failed");
    } finally {
      setSaving(false);
    }
  };

  const connectOAuth = async () => {
    const ok = await persistSettings();
    if (ok) {
      await openExternalUrl("/api/x/oauth/start");
    }
  };

  const connectYouTubeOAuth = async () => {
    const ok = await persistSettings();
    if (ok) {
      await openExternalUrl("/api/oauth/youtube/start");
    }
  };

  const testX = async () => {
    setTestingX(true);
    setXTest(null);
    try {
      const res = await fetch("/api/settings/test", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: "x", ...form }),
      });
      const json = await res.json();
      const errorMessage =
        typeof json.error === "string"
          ? json.error
          : json.error
            ? JSON.stringify(json.error)
            : null;
      if (!res.ok) throw new Error(errorMessage ?? "X test failed");
      setXTest(json.message ?? "X connection ok.");
    } catch (error) {
      setXTest(error instanceof Error ? error.message : "X test failed");
    } finally {
      setTestingX(false);
    }
  };

  const testYt = async () => {
    setTestingYt(true);
    setYtTest(null);
    try {
      const res = await fetch("/api/settings/test", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: "yt", ...form }),
      });
      const json = await res.json();
      const errorMessage =
        typeof json.error === "string"
          ? json.error
          : json.error
            ? JSON.stringify(json.error)
            : null;
      if (!res.ok) throw new Error(errorMessage ?? "YouTube test failed");
      setYtTest(json.message ?? "YouTube connection ok.");
    } catch (error) {
      setYtTest(error instanceof Error ? error.message : "YouTube test failed");
    } finally {
      setTestingYt(false);
    }
  };

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

  const applyLlmPreset = (preset: "lmstudio" | "vllm" | "ollama" | "remote") => {
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
        llmApiKey: "EMPTY",
        llmConcurrency: 4,
        llmEmbeddingBaseUrl: prev.llmEmbeddingBaseUrl || "http://127.0.0.1:11434/v1",
        llmEmbeddingModel: prev.llmEmbeddingModel || "nomic-embed-text",
      }));
      return;
    }

    setForm((prev) => ({
      ...prev,
      llmBaseUrl: "http://192.168.0.69:8000/v1",
      llmApiKey: "EMPTY",
      llmModel: "gemma-4-26b",
      llmConcurrency: 32,
      llmContextWindow: 32768,
      llmEmbeddingBaseUrl: prev.llmEmbeddingBaseUrl || "http://127.0.0.1:11434/v1",
      llmEmbeddingModel: prev.llmEmbeddingModel || "nomic-embed-text",
    }));
  };

  const lookupUserId = async () => {
    setLookingUp(true);
    setLookupMessage(null);
    try {
      const res = await fetch("/api/x/user-lookup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: lookupUsername }),
      });
      const json = await res.json();
      const errorMessage =
        typeof json.error === "string"
          ? json.error
          : json.error
            ? JSON.stringify(json.error)
            : null;
      if (!res.ok) throw new Error(errorMessage ?? "Lookup failed");
      setForm((prev) => ({ ...prev, xUserId: json.userId ?? prev.xUserId }));
      setLookupMessage(
        json.userId ? `Found user ID: ${json.userId}` : "No user ID returned."
      );
    } catch (error) {
      setLookupMessage(error instanceof Error ? error.message : "Lookup failed");
    } finally {
      setLookingUp(false);
    }
  };

  const markLatest = async () => {
    setMarkingLatest(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/mark-latest", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Mark latest failed");
      setMessage("Marked latest X bookmark as the sync baseline.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Mark latest failed");
    } finally {
      setMarkingLatest(false);
    }
  };

  const resetBaseline = async () => {
    setResettingBaseline(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/reset-baseline", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Reset failed");
      setMessage("Sync baseline reset. Next sync will fetch everything.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Reset failed");
    } finally {
      setResettingBaseline(false);
    }
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

  const syncEmbeddings = async () => {
    setSyncingEmbeddings(true);
    setMessage(null);
    try {
      const res = await fetch("/api/bookmarks/embeddings/sync", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Sync failed");
      setMessage(`Started embedding sync. Processed: ${json.updated}, Failed: ${json.failed}`);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Sync failed");
    } finally {
      setSyncingEmbeddings(false);
    }
  };

  const resetPrompt = () => {
    setForm((prev) => ({ ...prev, llmPrompt: defaultPrompt }));
  };

  const runXDiagnostics = async () => {
    setRunningXDiagnostics(true);
    setXDiagnosticResult(null);
    try {
      const res = await fetch("/api/x/diagnostics", {
        method: "GET",
        cache: "no-store",
      });
      const json = await res.json();
      setXDiagnosticResult(json);
    } catch (error) {
      setXDiagnosticResult({
        ok: false,
        error: error instanceof Error ? error.message : "X diagnostics failed",
      });
    } finally {
      setRunningXDiagnostics(false);
    }
  };

  const runYtDiagnostics = async () => {
    setRunningYtDiagnostics(true);
    setYtDiagnosticResult(null);
    try {
      const res = await fetch("/api/youtube/diagnostics", {
        method: "GET",
        cache: "no-store",
      });
      const json = await res.json();
      setYtDiagnosticResult(json);
    } catch (error) {
      setYtDiagnosticResult({
        ok: false,
        error: error instanceof Error ? error.message : "YouTube diagnostics failed",
      });
    } finally {
      setRunningYtDiagnostics(false);
    }
  };

  const getYouTubeAuthUrl = async () => {
    setGeneratingYtUrl(true);
    setMessage(null);
    try {
      const res = await fetch("/api/youtube/oauth/url", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to generate URL");
      return json.url as string;
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to generate URL");
      return null;
    } finally {
      setGeneratingYtUrl(false);
    }
  };

  const uploadGoogleClientJson = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    try {
      const raw = await file.text();
      const parsed = JSON.parse(raw) as {
        web?: {
          client_id?: string;
          client_secret?: string;
          redirect_uris?: string[];
        };
        installed?: {
          client_id?: string;
          client_secret?: string;
          redirect_uris?: string[];
        };
      };
      const config = parsed.web ?? parsed.installed;
      if (!config?.client_id || !config?.client_secret) {
        throw new Error("JSON is missing client_id or client_secret.");
      }
      setForm((prev) => ({
        ...prev,
        ytClientId: config.client_id,
        ytClientSecret: config.client_secret,
        ytRedirectUri: config.redirect_uris?.[0] ?? prev.ytRedirectUri,
      }));
      setMessage("Loaded YouTube OAuth credentials from JSON file.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to read JSON file.");
    } finally {
      event.target.value = "";
    }
  };

  return {
    form,
    setForm,
    saving,
    message,
    xTest,
    ytTest,
    llmTest,
    testingX,
    testingYt,
    testingLlm,
    lookupUsername,
    setLookupUsername,
    lookupMessage,
    lookingUp,
    markingLatest,
    clearingLogs,
    runningXDiagnostics,
    xDiagnosticResult,
    modelHistory,
    showHistory,
    setShowHistory,
    ytJsonInputRef,
    historyRef,
    updateField,
    updateNumberField,
    updateBooleanField,
    save,
    clearOAuth,
    clearYouTubeOAuth,
    connectOAuth,
    connectYouTubeOAuth,
    testX,
    testYt,
    testLlm,
    applyLlmPreset,
    lookupUserId,
    markLatest,
    clearProcessingHistory,
    syncEmbeddings,
    resetPrompt,
    runXDiagnostics,
    runYtDiagnostics,
    uploadGoogleClientJson,
    syncingEmbeddings,
    resetBaseline,
    resettingBaseline,
    runningYtDiagnostics,
    ytDiagnosticResult,
    getYouTubeAuthUrl,
    generatingYtUrl,
  };
}
