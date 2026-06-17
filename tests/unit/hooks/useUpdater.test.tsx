import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useUpdater } from "@/app/hooks/useUpdater";

// Mock the Tauri APIs
const mockCheck = vi.fn();
const mockInvoke = vi.fn();

vi.mock("@tauri-apps/plugin-updater", () => ({
  check: () => mockCheck(),
}));

vi.mock("@tauri-apps/api/core", () => ({
  invoke: (cmd: string, args?: any) => mockInvoke(cmd, args),
}));

describe("useUpdater", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.useFakeTimers();
    // Reset window properties
    if (global.window) {
      delete (global.window as any).__TAURI_INTERNALS__;
    } else {
      (global as any).window = {};
    }
    global.confirm = vi.fn();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("should do nothing if not running in Tauri", async () => {
    const { result } = renderHook(() => useUpdater());
    
    act(() => {
      vi.advanceTimersByTime(5000);
    });

    expect(mockCheck).not.toHaveBeenCalled();
    expect(result.current.updateAvailable).toBe(false);
  });

  it("should check for updates if running in Tauri", async () => {
    // Mock running in Tauri
    (global.window as any).__TAURI_INTERNALS__ = {};
    mockCheck.mockResolvedValueOnce(null); // No update

    const { result } = renderHook(() => useUpdater());

    await act(async () => {
      vi.advanceTimersByTime(5000);
    });

    expect(mockCheck).toHaveBeenCalled();
    expect(result.current.updateAvailable).toBe(false);
  });

  it("should trigger update install if update is found and confirmed", async () => {
    (global.window as any).__TAURI_INTERNALS__ = {};
    const mockDownloadAndInstall = vi.fn();
    mockCheck.mockResolvedValueOnce({
      version: "1.1.0",
      downloadAndInstall: mockDownloadAndInstall,
    });
    vi.mocked(global.confirm).mockReturnValueOnce(true); // User clicks confirm

    const { result } = renderHook(() => useUpdater());

    await act(async () => {
      vi.advanceTimersByTime(5000);
    });

    expect(mockCheck).toHaveBeenCalled();
    expect(global.confirm).toHaveBeenCalled();
    expect(mockDownloadAndInstall).toHaveBeenCalled();
    expect(mockInvoke).toHaveBeenCalledWith("relaunch_app", undefined);
    expect(result.current.updateAvailable).toBe(true);
  });
});
