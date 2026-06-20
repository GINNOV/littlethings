import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useActions } from "@/app/hooks/useActions";

describe("useActions", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    global.fetch = vi.fn();
    // Mock sessionStorage
    global.sessionStorage = {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
      length: 0,
      key: vi.fn(),
    };
  });

  it("should run import", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, imported: 5 }),
    } as any);

    const { result } = renderHook(() => useActions("x", 50));

    await act(async () => {
      await result.current.runImport();
    });

    expect(fetch).toHaveBeenCalledWith(expect.stringContaining("/api/import?source=x"), { method: "POST" });
    expect(result.current.message).toContain("Imported 5");
  });

  it("should run enrich", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, processed: 1, updated: 1, errors: [] }),
    } as any);

    const { result } = renderHook(() => useActions("yt", 200));

    await act(async () => {
      await result.current.runEnrich(false);
    });

    expect(fetch).toHaveBeenCalledWith(expect.stringContaining("/api/enrich?source=yt"), { method: "POST" });
    expect(result.current.message).toContain("Enriched 1/1");
  });
});
