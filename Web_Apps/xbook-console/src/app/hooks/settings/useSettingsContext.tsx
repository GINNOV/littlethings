"use client";

import React, { createContext, useContext, useState, useEffect, useCallback } from "react";
import { Settings } from "../../components/settings/types";

type SettingsContextType = {
  form: Settings;
  setForm: React.Dispatch<React.SetStateAction<Settings>>;
  saving: boolean;
  setSaving: (v: boolean) => void;
  message: string | null;
  setMessage: (v: string | null) => void;
  updateField: (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  updateNumberField: (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement>) => void;
  updateBooleanField: (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement>) => void;
  persistSettings: (newForm?: Settings) => Promise<boolean>;
  defaultPrompt: string;
  isDirty: boolean;
};

const SettingsContext = createContext<SettingsContextType | null>(null);

export function useSettingsContext() {
  const context = useContext(SettingsContext);
  if (!context) {
    throw new Error("useSettingsContext must be used within a SettingsProvider");
  }
  return context;
}

export function SettingsProvider({
  children,
  initial,
  defaultPrompt,
}: {
  children: React.ReactNode;
  initial: Settings;
  defaultPrompt: string;
}) {
  const [form, setForm] = useState<Settings>(initial);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [isDirty, setIsDirty] = useState(false);

  // Fix: sync initial prop to state
  useEffect(() => {
    setForm(initial);
    setIsDirty(false);
  }, [initial]);

  const updateField = useCallback(
    (key: keyof Settings) =>
      (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        setForm((prev) => ({ ...prev, [key]: event.target.value }));
        setIsDirty(true);
      },
    []
  );

  const updateNumberField = useCallback(
    (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement>) => {
      const value = event.target.value;
      setForm((prev) => ({ ...prev, [key]: value ? Number(value) : null }));
      setIsDirty(true);
    },
    []
  );

  const updateBooleanField = useCallback(
    (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement>) => {
      setForm((prev) => ({ ...prev, [key]: event.target.checked }));
      setIsDirty(true);
    },
    []
  );

  const persistSettings = async (newForm?: Settings) => {
    const dataToSave = newForm || form;
    setSaving(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(dataToSave),
      });

      const contentType = res.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        const json = await res.json();
        if (!res.ok) {
          const err = typeof json.error === "string" ? json.error : JSON.stringify(json.error);
          throw new Error(err ?? "Save failed");
        }
      } else {
        if (!res.ok) {
          const text = await res.text();
          throw new Error(text || `Save failed with status ${res.status}`);
        }
      }

      setIsDirty(false);
      return true;
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Save failed");
      return false;
    } finally {
      setSaving(false);
    }
  };

  return (
    <SettingsContext.Provider
      value={{
        form,
        setForm,
        saving,
        setSaving,
        message,
        setMessage,
        updateField,
        updateNumberField,
        updateBooleanField,
        persistSettings,
        defaultPrompt,
        isDirty,
      }}
    >
      {children}
    </SettingsContext.Provider>
  );
}
