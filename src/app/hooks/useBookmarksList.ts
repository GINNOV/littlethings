"use client";

import { useState, useEffect } from "react";

export type Bookmark = {
  id: string;
  source: string;
  tweetUrl: string;
  rawJson?: string | null;
  text: string | null;
  folderName?: string | null;
  summary: string | null;
  category: string | null;
  tags: string | null;
  authorUsername: string | null;
  importedAt: string | null;
  createdAt: string | null;
  summarizedAt: string | null;
  editedAt: string | null;
  readAt: string | null;
  error?: string | null;
  similarity?: number;
};

export type EditState = {
  id: string;
  summary: string;
  category: string;
  tags: string;
} | null;

export function useBookmarksList(initial: Bookmark[]) {
  const [items, setItems] = useState<Bookmark[]>(initial);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [editing, setEditing] = useState<EditState>(null);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [translatedText, setTranslatedText] = useState<string | null>(null);
  const [isTranslating, setIsTranslating] = useState(false);

  useEffect(() => {
    setItems(initial);
  }, [initial]);

  useEffect(() => {
    setTranslatedText(null);
  }, [selectedId]);

  const translate = async (id: string) => {
    setIsTranslating(true);
    setTranslatedText(null);
    setMessage(null);
    try {
      const res = await fetch(`/api/bookmarks/translate?bookmarkId=${id}`, { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Translation failed");
      setTranslatedText(json.translatedText);
      setMessage("Translation completed.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Translation failed");
    } finally {
      setIsTranslating(false);
    }
  };

  const reprocess = async (id: string) => {
    setBusyId(id);
    setMessage(null);
    try {
      const res = await fetch(`/api/enrich/one?bookmarkId=${id}`, { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Reprocess failed");
      const updated = json.bookmark as Bookmark;
      setItems((prev) =>
        prev.map((item) => (item.id === id ? { ...item, ...updated } : item))
      );
      setSelectedId(id);
      setMessage("Reprocessed bookmark.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Reprocess failed");
    } finally {
      setBusyId(null);
    }
  };

  const toggleRead = async (bookmark: Bookmark) => {
    setBusyId(bookmark.id);
    setMessage(null);
    try {
      const res = await fetch("/api/bookmarks/read", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ bookmarkId: bookmark.id, read: !bookmark.readAt }),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Update failed");
      const updated = json.bookmark as Bookmark;
      setItems((prev) =>
        prev.map((item) => (item.id === updated.id ? { ...item, ...updated } : item))
      );
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Update failed");
    } finally {
      setBusyId(null);
    }
  };

  const openEdit = (bookmark: Bookmark) => {
    setEditing({
      id: bookmark.id,
      summary: bookmark.summary ?? "",
      category: bookmark.category ?? "",
      tags: bookmark.tags ?? "",
    });
  };

  const closeEdit = () => setEditing(null);

  const saveEdit = async () => {
    if (!editing) return;
    setBusyId(editing.id);
    setMessage(null);
    try {
      const res = await fetch("/api/enrich/edit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(editing),
      });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Update failed");
      const updated = json.bookmark as Bookmark;
      setItems((prev) =>
        prev.map((item) => (item.id === updated.id ? { ...item, ...updated } : item))
      );
      setMessage("Enrichment updated.");
      setEditing(null);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Update failed");
    } finally {
      setBusyId(null);
    }
  };

  const selected = selectedId ? (items.find((item) => item.id === selectedId) ?? null) : null;

  return {
    items,
    setItems,
    busyId,
    message,
    editing,
    setEditing,
    selectedId,
    setSelectedId,
    translatedText,
    isTranslating,
    translate,
    reprocess,
    toggleRead,
    openEdit,
    closeEdit,
    saveEdit,
    selected,
  };
}
