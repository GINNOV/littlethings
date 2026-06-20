"use client";

import { useState, useRef } from "react";
import { useSettingsContext } from "./useSettingsContext";

export function useYouTubeSettings() {
  const { form, setForm, setSaving, setMessage, persistSettings } = useSettingsContext();
  
  const [ytTest, setYtTest] = useState<string | null>(null);
  const [testingYt, setTestingYt] = useState(false);
  const [runningYtDiagnostics, setRunningYtDiagnostics] = useState(false);
  const [ytDiagnosticResult, setYtDiagnosticResult] = useState<unknown>(null);
  const [generatingYtUrl, setGeneratingYtUrl] = useState(false);
  const ytJsonInputRef = useRef<HTMLInputElement | null>(null);

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

  const connectYouTubeOAuth = async () => {
    const ok = await persistSettings();
    if (ok) {
      window.location.href = "/api/oauth/youtube/start";
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
    ytTest,
    testingYt,
    runningYtDiagnostics,
    ytDiagnosticResult,
    generatingYtUrl,
    ytJsonInputRef,
    testYt,
    clearYouTubeOAuth,
    connectYouTubeOAuth,
    runYtDiagnostics,
    getYouTubeAuthUrl,
    uploadGoogleClientJson,
  };
}
