import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useLLMSettings } from "@/app/hooks/settings/useLLMSettings";
import { useSettingsContext } from "@/app/hooks/settings/useSettingsContext";

vi.mock("@/app/hooks/settings/useSettingsContext");

describe("useLLMSettings", () => {
  const mockSetMessage = vi.fn();
  const mockSetForm = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(useSettingsContext).mockReturnValue({
      form: { llmModel: "gpt-4o" },
      setMessage: mockSetMessage,
      setForm: mockSetForm,
      defaultPrompt: "Be helpful",
    } as any);
    global.fetch = vi.fn();
  });

  it("should test LLM connection", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true, message: "Response ok" }),
    } as any);

    const { result } = renderHook(() => useLLMSettings());

    await act(async () => {
      await result.current.testLlm();
    });

    expect(fetch).toHaveBeenCalledWith("/api/settings/test", expect.anything());
    expect(result.current.llmTest).toBe("Response ok");
  });

  it("should clear processing history", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ ok: true }),
    } as any);

    const { result } = renderHook(() => useLLMSettings());

    await act(async () => {
      await result.current.clearProcessingHistory();
    });

    expect(fetch).toHaveBeenCalledWith("/api/processing/clear", expect.anything());
    expect(mockSetMessage).toHaveBeenCalledWith(expect.stringContaining("cleared"));
  });

  it("should apply LLM preset", () => {
    const { result } = renderHook(() => useLLMSettings());

    act(() => {
      result.current.applyLlmPreset("lmstudio");
    });

    expect(mockSetForm).toHaveBeenCalled();
  });

  it("should apply Ollama preset", () => {
    const { result } = renderHook(() => useLLMSettings());

    act(() => {
      result.current.applyLlmPreset("ollama");
    });

    expect(mockSetForm).toHaveBeenCalledWith(expect.any(Function));
    
    // Test the state updater function
    const updater = mockSetForm.mock.calls[0][0];
    const newState = updater({ other: "data" });
    expect(newState.llmBaseUrl).toBe("http://127.0.0.1:11434/v1");
    expect(newState.llmApiKey).toBe("ollama");
  });
});
