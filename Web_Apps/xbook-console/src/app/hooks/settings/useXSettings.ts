"use client";

import { useState } from "react";
import { useSettingsContext } from "./useSettingsContext";
import { openExternalUrl } from "@/app/lib/tauri";

export function useXSettings() {
  const { form, setForm, setSaving, setMessage, persistSettings } = useSettingsContext();
  
  const [xTest, setXTest] = useState<string | null>(null);
  const [testingX, setTestingX] = useState(false);
  const [lookupUsername, setLookupUsername] = useState("");
  const [lookupMessage, setLookupMessage] = useState<string | null>(null);
  const [lookingUp, setLookingUp] = useState(false);
  const [runningXDiagnostics, setRunningXDiagnostics] = useState(false);
  const [xDiagnosticResult, setXDiagnosticResult] = useState<unknown>(null);

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

  const connectOAuth = async () => {
    const ok = await persistSettings();
    if (ok) {
      await openExternalUrl("/api/x/oauth/start");
    }
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

  return {
    xTest,
    testingX,
    lookupUsername,
    setLookupUsername,
    lookupMessage,
    lookingUp,
    runningXDiagnostics,
    xDiagnosticResult,
    testX,
    clearOAuth,
    connectOAuth,
    lookupUserId,
    runXDiagnostics,
  };
}
