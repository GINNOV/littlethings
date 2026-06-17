import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useUsageSettings } from "@/app/hooks/settings/useUsageSettings";
import { useSettingsContext } from "@/app/hooks/settings/useSettingsContext";

vi.mock("@/app/hooks/settings/useSettingsContext");

describe("useUsageSettings", () => {
  const mockSetMessage = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(useSettingsContext).mockReturnValue({
      setMessage: mockSetMessage,
    } as any);
    global.fetch = vi.fn();
  });

  it("should mark latest bookmark as baseline", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true }),
    } as any);

    const { result } = renderHook(() => useUsageSettings());

    await act(async () => {
      await result.current.markLatest();
    });

    expect(fetch).toHaveBeenCalledWith("/api/settings/mark-latest", { method: "POST" });
    expect(mockSetMessage).toHaveBeenCalledWith(expect.stringContaining("baseline"));
  });

  it("should reset sync baseline", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true }),
    } as any);

    const { result } = renderHook(() => useUsageSettings());

    await act(async () => {
      await result.current.resetBaseline();
    });

    expect(fetch).toHaveBeenCalledWith("/api/settings/reset-baseline", { method: "POST" });
    expect(mockSetMessage).toHaveBeenCalledWith(expect.stringContaining("reset"));
  });

  it("should sync missing embeddings", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, updated: 5, failed: 0 }),
    } as any);

    const { result } = renderHook(() => useUsageSettings());

    await act(async () => {
      await result.current.syncEmbeddings();
    });

    expect(fetch).toHaveBeenCalledWith("/api/bookmarks/embeddings/sync", { method: "POST" });
    expect(mockSetMessage).toHaveBeenCalledWith(expect.stringContaining("Processed: 5"));
  });
});
