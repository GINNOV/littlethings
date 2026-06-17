import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useYouTubeSettings } from "@/app/hooks/settings/useYouTubeSettings";
import { useSettingsContext } from "@/app/hooks/settings/useSettingsContext";

vi.mock("@/app/hooks/settings/useSettingsContext");

describe("useYouTubeSettings", () => {
  const mockSetMessage = vi.fn();
  const mockSetForm = vi.fn();
  const mockSetSaving = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(useSettingsContext).mockReturnValue({
      form: { ytClientId: "yt-123" },
      setMessage: mockSetMessage,
      setForm: mockSetForm,
      setSaving: mockSetSaving,
    } as any);
    global.fetch = vi.fn();
  });

  it("should run YouTube diagnostics", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true }),
    } as any);

    const { result } = renderHook(() => useYouTubeSettings());

    await act(async () => {
      await result.current.runYtDiagnostics();
    });

    expect(fetch).toHaveBeenCalledWith("/api/youtube/diagnostics", expect.anything());
    expect(result.current.ytDiagnosticResult).toBeDefined();
  });

  it("should get YouTube auth URL", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, url: "https://auth.google.com" }),
    } as any);

    const { result } = renderHook(() => useYouTubeSettings());

    let url: string | null = null;
    await act(async () => {
      url = await result.current.getYouTubeAuthUrl();
    });

    expect(url).toBe("https://auth.google.com");
    expect(fetch).toHaveBeenCalledWith("/api/youtube/oauth/url", expect.anything());
  });

  it("should clear YouTube OAuth", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true }),
    } as any);

    const { result } = renderHook(() => useYouTubeSettings());

    await act(async () => {
      await result.current.clearYouTubeOAuth();
    });

    expect(fetch).toHaveBeenCalledWith("/api/settings", expect.anything());
    expect(mockSetMessage).toHaveBeenCalledWith(expect.stringContaining("cleared"));
  });
});
