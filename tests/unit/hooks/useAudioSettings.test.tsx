import { describe, it, expect, vi } from "vitest";
import { renderHook } from "@testing-library/react";
import { useAudioSettings } from "@/app/hooks/settings/useAudioSettings";
import { useSettingsContext } from "@/app/hooks/settings/useSettingsContext";

vi.mock("@/app/hooks/settings/useSettingsContext");

describe("useAudioSettings", () => {
  it("should return form and updateBooleanField from context", () => {
    const mockContext = {
      form: { soundOnComplete: true },
      updateBooleanField: vi.fn(),
    };
    vi.mocked(useSettingsContext).mockReturnValue(mockContext as any);

    const { result } = renderHook(() => useAudioSettings());

    expect(result.current.form).toEqual(mockContext.form);
    expect(result.current.updateBooleanField).toBe(mockContext.updateBooleanField);
  });
});
