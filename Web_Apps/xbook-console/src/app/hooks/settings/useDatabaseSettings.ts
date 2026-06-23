"use client";

import { useState, useEffect } from "react";
import { useSettingsContext } from "./useSettingsContext";

export type BackupInfo = {
  filename: string;
  size: number;
  createdAt: string;
};

export function useDatabaseSettings() {
  const { setMessage } = useSettingsContext();
  const [backups, setBackups] = useState<BackupInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [creating, setCreating] = useState(false);
  const [restoring, setRestoring] = useState(false);
  const [clearing, setClearing] = useState(false);

  const fetchBackups = async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/settings/database/backups");
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to fetch backups");
      setBackups(json.backups || []);
    } catch (error) {
      console.error("Failed to fetch database backups:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBackups();
  }, []);

  const createLocalBackup = async (customName?: string) => {
    setCreating(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/database/backups", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ customName }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to create backup");
      setMessage(`Backup created: ${json.filename}`);
      fetchBackups();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to create backup");
    } finally {
      setCreating(false);
    }
  };

  const deleteLocalBackup = async (filename: string) => {
    setMessage(null);
    try {
      const res = await fetch("/api/settings/database/backups", {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filename }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to delete backup");
      setMessage(`Deleted backup: ${filename}`);
      fetchBackups();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to delete backup");
    }
  };

  const restoreLocalBackup = async (filename: string) => {
    setRestoring(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/database/restore", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ filename }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to restore backup");
      setMessage(`Database successfully restored to ${filename}. Please reload the application page.`);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to restore backup");
    } finally {
      setRestoring(false);
    }
  };

  const restoreFromUpload = async (file: File) => {
    setRestoring(true);
    setMessage(null);
    try {
      const formData = new FormData();
      formData.append("file", file);

      const res = await fetch("/api/settings/database/restore", {
        method: "POST",
        body: formData,
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to upload and restore backup");
      setMessage("Database successfully restored from uploaded file. Please reload the application page.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to restore backup");
    } finally {
      setRestoring(false);
    }
  };

  const clearData = async () => {
    setClearing(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/database/clear", {
        method: "POST",
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Failed to clear database");
      setMessage("All database content (bookmarks, folders, and logs) has been cleared. Settings were preserved.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Failed to clear database");
    } finally {
      setClearing(false);
    }
  };

  return {
    backups,
    loading,
    creating,
    restoring,
    clearing,
    createLocalBackup,
    deleteLocalBackup,
    restoreLocalBackup,
    restoreFromUpload,
    clearData,
    fetchBackups,
  };
}
