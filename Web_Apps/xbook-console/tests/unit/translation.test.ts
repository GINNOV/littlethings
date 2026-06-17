import { describe, it, expect, vi, beforeEach } from "vitest";
import { getSettings } from "@/lib/settings";

const mockCreate = vi.fn();

vi.mock("openai", () => {
  return {
    default: function() {
      return {
        chat: {
          completions: {
            create: mockCreate,
          },
        },
      };
    },
  };
});

vi.mock("@/lib/settings", () => ({
  getSettings: vi.fn(),
}));

vi.mock("@/lib/processing", () => ({
  logLlmRequest: vi.fn(),
  logProcessingEvent: vi.fn(),
}));

import { translateText } from "@/lib/llm";

describe("translation lib", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(getSettings).mockResolvedValue({
      llmModel: "test-model",
      llmBaseUrl: "http://localhost:1234/v1",
      llmApiKey: "test-key",
    } as any);
  });

  it("should call OpenAI with correct prompt and return translated text", async () => {
    mockCreate.mockResolvedValue({
      choices: [{ message: { content: "Translated text" } }],
      usage: { total_tokens: 10, prompt_tokens: 5, completion_tokens: 5 },
    });

    const result = await translateText({
      text: "Original text",
      targetLanguage: "Spanish",
    });

    expect(result).toBe("Translated text");
    expect(mockCreate).toHaveBeenCalledWith(
      expect.objectContaining({
        messages: [
          {
            role: "system",
            content: expect.any(String),
          },
          {
            role: "user",
            content: expect.stringContaining("Translate the following text into Spanish"),
          },
        ],
      }),
      expect.any(Object)
    );
  });

  it("should throw error if LLM returns empty response", async () => {
    mockCreate.mockResolvedValue({
      choices: [{ message: { content: "" } }],
    });

    await expect(
      translateText({
        text: "Original text",
        targetLanguage: "Spanish",
      })
    ).rejects.toThrow("LLM returned an empty response for translation.");
  });
});
