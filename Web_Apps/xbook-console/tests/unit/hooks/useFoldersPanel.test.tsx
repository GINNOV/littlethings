import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useFoldersPanel } from "@/app/hooks/useFoldersPanel";

describe("useFoldersPanel", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    global.fetch = vi.fn();
    // Mock window.location.reload
    Object.defineProperty(window, 'location', {
      configurable: true,
      value: { reload: vi.fn() },
    });
  });

  it("should sync folders", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, total: 5 }),
    } as any);

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.syncFolders();
    });

    expect(fetch).toHaveBeenCalledWith("/api/folders/sync", { method: "POST" });
    expect(window.location.reload).toHaveBeenCalled();
  });

  it("should import a folder", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, imported: 10, refreshed: 2, pagesFetched: 1 }),
    } as any);

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.importFolder("f1");
    });

    expect(fetch).toHaveBeenCalledWith("/api/folders/import?folderId=f1", { method: "POST" });
    expect(result.current.msg?.text).toContain("Imported 10");
  });

  it("should process a folder", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, processed: 0, updated: 0, errors: [] }),
    } as any);

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.processFolder("f1");
    });

    expect(fetch).toHaveBeenCalledWith(expect.stringContaining("/api/enrich"), { method: "POST" });
  });

  it("should handle sync failure", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: false,
      json: async () => ({ error: "Sync failed" }),
    } as any);

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.syncFolders();
    });

    expect(result.current.msg?.isError).toBe(true);
    expect(result.current.msg?.text).toBe("Sync failed");
  });

  it("should handle import failure", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: false,
      json: async () => ({ error: "Import failed" }),
    } as any);

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.importFolder("f1");
    });

    expect(result.current.msg?.isError).toBe(true);
    expect(result.current.msg?.text).toBe("Import failed");
  });

  it("should import all folders", async () => {
    vi.mocked(fetch).mockResolvedValue({
      ok: true,
      json: async () => ({ ok: true, imported: 5 }),
    } as any);

    const { result } = renderHook(() => useFoldersPanel([{ id: "f1" }, { id: "f2" }]));

    await act(async () => {
      await result.current.importAllFolders();
    });

    expect(fetch).toHaveBeenCalledTimes(2);
    expect(result.current.msg?.text).toContain("Imported all");
  });
});
