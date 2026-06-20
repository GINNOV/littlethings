import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useXSettings } from "@/app/hooks/settings/useXSettings";
import { useSettingsContext } from "@/app/hooks/settings/useSettingsContext";

vi.mock("@/app/hooks/settings/useSettingsContext");

describe("useXSettings", () => {
  const mockSetMessage = vi.fn();
  const mockSetForm = vi.fn();
  const mockSetSaving = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(useSettingsContext).mockReturnValue({
      form: { xUsername: "testuser" },
      setMessage: mockSetMessage,
      setForm: mockSetForm,
      setSaving: mockSetSaving,
    } as any);
    global.fetch = vi.fn();
  });

  it("should look up user ID", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, userId: "12345" }),
    } as any);

    const { result } = renderHook(() => useXSettings());

    await act(async () => {
      await result.current.lookupUserId();
    });

    expect(fetch).toHaveBeenCalledWith("/api/x/user-lookup", expect.anything());
    expect(mockSetForm).toHaveBeenCalled();
    expect(result.current.lookupMessage).toContain("12345");
  });

  it("should run X diagnostics", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, probes: {} }),
    } as any);

    const { result } = renderHook(() => useXSettings());

    await act(async () => {
      await result.current.runXDiagnostics();
    });

    expect(fetch).toHaveBeenCalledWith("/api/x/diagnostics", expect.anything());
    expect(result.current.xDiagnosticResult).toBeDefined();
  });

  it("should clear OAuth", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true }),
    } as any);

    const { result } = renderHook(() => useXSettings());

    await act(async () => {
      await result.current.clearOAuth();
    });

    expect(fetch).toHaveBeenCalledWith("/api/settings", expect.anything());
    expect(mockSetMessage).toHaveBeenCalledWith(expect.stringContaining("cleared"));
  });
});
