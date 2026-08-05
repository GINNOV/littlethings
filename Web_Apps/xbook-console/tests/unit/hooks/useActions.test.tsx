import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useActions } from "@/app/hooks/useActions";

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
    vi.mocked(fetch).mockResolvedValueOnce(mockJsonResponse({ ok: true, imported: 5 }));

    const { result } = renderHook(() => useActions("x", 50));

    await act(async () => {
      await result.current.runImport();
    });

    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining("/api/import?source=x"),
      expect.objectContaining({ method: "POST" })
    );
    expect(result.current.message).toContain("Imported 5");
  });

  it("should run enrich", async () => {
    vi.mocked(fetch).mockResolvedValueOnce(
      mockJsonResponse({
        ok: true,
        processed: 1,
        updated: 1,
        remaining: 0,
        finished: true,
        errors: [],
      })
    );

    const { result } = renderHook(() => useActions("yt", 200));

    await act(async () => {
      await result.current.runEnrich(false);
    });

    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining("/api/enrich?source=yt"),
      expect.objectContaining({ method: "POST" })
    );
    expect(result.current.message).toContain("Enriched 1/1");
  });

  it("should surface empty responses clearly instead of opaque JSON errors", async () => {
    vi.mocked(fetch).mockResolvedValue({
      ok: true,
      status: 200,
      statusText: "OK",
      text: async () => "",
      json: async () => {
        throw new Error("Unexpected end of JSON input");
      },
    } as any);

    const { result } = renderHook(() => useActions("x", 50));

    await act(async () => {
      await result.current.runImport();
    });

    expect(result.current.message).toMatch(/Empty response|timed out/i);
    expect(result.current.message).not.toMatch(/Unexpected end of JSON input/);
  });

  it("should continue multi-batch enrich while remaining > 0", async () => {
    vi.mocked(fetch)
      .mockResolvedValueOnce(
        mockJsonResponse({
          ok: true,
          runId: "r1",
          processed: 2,
          updated: 2,
          remaining: 3,
          finished: false,
          errors: [],
          batch: 1,
          batches: 2,
        })
      )
      .mockResolvedValueOnce(
        mockJsonResponse({
          ok: true,
          runId: "r1",
          processed: 3,
          updated: 3,
          remaining: 0,
          finished: true,
          errors: [],
          batch: 2,
          batches: 2,
        })
      );

    const { result } = renderHook(() => useActions("x", 50));

    await act(async () => {
      await result.current.runEnrich(true);
    });

    expect(fetch).toHaveBeenCalledTimes(2);
    expect(result.current.message).toContain("Enriched 5/5");
    expect(result.current.message).toContain("Remaining: 0");
  });
});
