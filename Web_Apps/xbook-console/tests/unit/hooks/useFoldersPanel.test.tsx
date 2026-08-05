import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useFoldersPanel } from "@/app/hooks/useFoldersPanel";

function mockJsonResponse(body: unknown, init: { ok?: boolean; status?: number } = {}) {
  const text = JSON.stringify(body);
  return {
    ok: init.ok ?? true,
    status: init.status ?? (init.ok === false ? 500 : 200),
    statusText: init.ok === false ? "Error" : "OK",
    text: async () => text,
    json: async () => body,
  } as any;
}

describe("useFoldersPanel", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    global.fetch = vi.fn();
    // Mock window.location.reload
    Object.defineProperty(window, "location", {
      configurable: true,
      value: { reload: vi.fn() },
    });
  });

  it("should sync folders", async () => {
    vi.mocked(fetch).mockResolvedValueOnce(mockJsonResponse({ ok: true, total: 5 }));

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.syncFolders();
    });

    expect(fetch).toHaveBeenCalledWith("/api/folders/sync", { method: "POST" });
    expect(window.location.reload).toHaveBeenCalled();
  });

  it("should import a folder", async () => {
    vi.mocked(fetch).mockResolvedValueOnce(
      mockJsonResponse({ ok: true, imported: 10, refreshed: 2, pagesFetched: 1 })
    );

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.importFolder("f1");
    });

    expect(fetch).toHaveBeenCalledWith("/api/folders/import?folderId=f1", { method: "POST" });
    expect(result.current.msg?.text).toContain("Imported 10");
  });

  it("should process a folder", async () => {
    vi.mocked(fetch).mockResolvedValueOnce(
      mockJsonResponse({ ok: true, processed: 0, updated: 0, errors: [], remaining: 0, finished: true })
    );

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.processFolder("f1");
    });

    expect(fetch).toHaveBeenCalledWith(expect.stringContaining("/api/enrich"), { method: "POST" });
  });

  it("should handle sync failure", async () => {
    vi.mocked(fetch).mockResolvedValueOnce(
      mockJsonResponse({ error: "Sync failed" }, { ok: false, status: 500 })
    );

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.syncFolders();
    });

    expect(result.current.msg?.isError).toBe(true);
    expect(result.current.msg?.text).toBe("Sync failed");
  });

  it("should handle import failure", async () => {
    vi.mocked(fetch).mockResolvedValueOnce(
      mockJsonResponse({ error: "Import failed" }, { ok: false, status: 500 })
    );

    const { result } = renderHook(() => useFoldersPanel([]));

    await act(async () => {
      await result.current.importFolder("f1");
    });

    expect(result.current.msg?.isError).toBe(true);
    expect(result.current.msg?.text).toBe("Import failed");
  });

  it("should import all folders", async () => {
    vi.mocked(fetch).mockResolvedValue(
      mockJsonResponse({ ok: true, imported: 5 })
    );

    const { result } = renderHook(() =>
      useFoldersPanel([
        { id: "f1", name: "One" },
        { id: "f2", name: "Two" },
      ])
    );

    await act(async () => {
      await result.current.importAllFolders();
    });

    expect(fetch).toHaveBeenCalledTimes(2);
    expect(result.current.msg?.text).toContain("Imported all");
  });
});
