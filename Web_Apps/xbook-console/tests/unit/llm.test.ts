import { describe, it, expect, vi, beforeEach } from "vitest";
import { summarizeBookmark, validateModelAvailability } from "@/lib/llm";
import { getSettings } from "@/lib/settings";
import OpenAI from "openai";

type MockOpenAI = OpenAI & {
  chat: {
    completions: {
      create: ReturnType<typeof vi.fn>;
    };
  };
  models: {
    list: ReturnType<typeof vi.fn>;
  };
  embeddings: {
    create: ReturnType<typeof vi.fn>;
  };
};

vi.mock("@/lib/db", () => ({
  prisma: {
    settings: {
      findUnique: vi.fn().mockResolvedValue({
        llmBaseUrl: "http://localhost:1234/v1",
        llmApiKey: "test-key",
        llmModel: "test-model",
        llmSystemPrompt: "test-system",
        llmContextWindow: 1000,
        llmResponseLimit: 100,
        llmMaxTokens: 100,
        logLlmPayloads: true,
      }),
    },
  },
}));

vi.mock("@/lib/settings", () => ({
  getSettings: vi.fn().mockResolvedValue({
    llmBaseUrl: "http://localhost:1234/v1",
    llmApiKey: "test-key",
    llmModel: "test-model",
    llmSystemPrompt: "test-system",
    llmContextWindow: 1000,
    llmResponseLimit: 100,
    llmMaxTokens: 100,
    logLlmPayloads: true,
  }),
}));

vi.mock("@/lib/processing", () => ({
  logLlmRequest: vi.fn().mockResolvedValue({}),
  logProcessingEvent: vi.fn().mockResolvedValue({}),
}));

vi.mock("openai", () => {
  const OpenAI = vi.fn();
  OpenAI.prototype.chat = {
    completions: {
      create: vi.fn(),
    },
  };
  OpenAI.prototype.models = {
    list: vi.fn(),
  };
  OpenAI.prototype.embeddings = {
    create: vi.fn(),
  };
  return { default: OpenAI };
});

describe("LLM Service", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  const defaultSettings = {
    llmBaseUrl: "http://localhost:1234/v1",
    llmApiKey: "test-key",
    llmModel: "test-model",
    llmSystemPrompt: null,
    llmContextWindow: 1000,
    llmResponseLimit: 100,
    llmMaxTokens: 100,
    logLlmPayloads: true,
  };

  it("should add no-think instruction when LLM thinking is disabled", async () => {
    vi.mocked(getSettings)
      .mockResolvedValueOnce({ ...defaultSettings, llmThinkingEnabled: false })
      .mockResolvedValueOnce({ ...defaultSettings, llmThinkingEnabled: false });
    const mockOpenAI = new OpenAI() as MockOpenAI;
    mockOpenAI.chat.completions.create.mockResolvedValue({
      choices: [{ message: { content: '{ "summary": "test", "category": "Tech", "tags": ["a"] }' } }],
      usage: { total_tokens: 10 },
    });
    mockOpenAI.embeddings.create.mockResolvedValue({ data: [{ embedding: [0.1] }] });

    await summarizeBookmark({ text: "test tweet" });

    expect(mockOpenAI.chat.completions.create).toHaveBeenCalledWith(
      expect.objectContaining({
        messages: expect.arrayContaining([
          expect.objectContaining({
            role: "system",
            content: expect.stringContaining("/no_think"),
          }),
        ]),
      }),
      expect.anything()
    );
  });

  it("should omit no-think instruction when LLM thinking is enabled", async () => {
    vi.mocked(getSettings)
      .mockResolvedValueOnce({ ...defaultSettings, llmThinkingEnabled: true })
      .mockResolvedValueOnce({ ...defaultSettings, llmThinkingEnabled: true });
    const mockOpenAI = new OpenAI() as MockOpenAI;
    mockOpenAI.chat.completions.create.mockResolvedValue({
      choices: [{ message: { content: '{ "summary": "test", "category": "Tech", "tags": ["a"] }' } }],
      usage: { total_tokens: 10 },
    });
    mockOpenAI.embeddings.create.mockResolvedValue({ data: [{ embedding: [0.1] }] });

    await summarizeBookmark({ text: "test tweet" });

    expect(mockOpenAI.chat.completions.create).toHaveBeenCalledWith(
      expect.objectContaining({
        messages: expect.arrayContaining([
          expect.objectContaining({
            role: "system",
            content: expect.not.stringContaining("/no_think"),
          }),
        ]),
      }),
      expect.anything()
    );
  });

  it("should extract JSON correctly with extractJson", async () => {
    const mockOpenAI = new OpenAI() as any;
    mockOpenAI.chat.completions.create.mockResolvedValue({
      choices: [{ message: { content: 'Some preamble { "summary": "test", "category": "Tech", "tags": ["a"] } some postamble' } }],
      usage: { total_tokens: 10 },
    });
    mockOpenAI.embeddings.create.mockResolvedValue({ data: [{ embedding: [0.1] }] });
    
    // Testing via summarizeBookmark which calls extractJson internally
    const result = await summarizeBookmark({ text: "test tweet" });
    expect(result.summary).toBe("test");
    expect(result.category).toBe("Tech");
  });

  it("should fail gracefully with malformed JSON", async () => {
    vi.useFakeTimers();
    const mockOpenAI = new OpenAI() as any;
    mockOpenAI.chat.completions.create.mockResolvedValue({
      choices: [{ message: { content: 'No JSON here' } }],
      usage: { total_tokens: 10 },
    });

    const promise = expect(summarizeBookmark({ text: "test tweet" })).rejects.toThrow(/No starting '{' found/);
    await vi.runAllTimersAsync();
    await promise;
    vi.useRealTimers();
  });

  it("should fail gracefully with empty response", async () => {
    vi.useFakeTimers();
    const mockOpenAI = new OpenAI() as any;
    mockOpenAI.chat.completions.create.mockResolvedValue({
      choices: [{ message: { content: '' } }],
      usage: { total_tokens: 0 },
    });

    const promise = expect(summarizeBookmark({ text: "test tweet" })).rejects.toThrow(/LLM returned an empty response/);
    await vi.runAllTimersAsync();
    await promise;
    vi.useRealTimers();
  });

  it("should retry and succeed if the first attempt returns an empty response", async () => {
    vi.useFakeTimers();
    const mockOpenAI = new OpenAI() as any;
    mockOpenAI.chat.completions.create
      .mockResolvedValueOnce({
        choices: [{ message: { content: "" } }],
        usage: { total_tokens: 0 },
      })
      .mockResolvedValueOnce({
        choices: [{ message: { content: '{ "summary": "recovered summary", "category": "Tech", "tags": ["a"] }' } }],
        usage: { total_tokens: 15 },
      });
    mockOpenAI.embeddings.create.mockResolvedValue({ data: [{ embedding: [0.1] }] });

    const promise = summarizeBookmark({ text: "test tweet" });
    await vi.runAllTimersAsync();
    const result = await promise;

    expect(result.summary).toBe("recovered summary");
    expect(mockOpenAI.chat.completions.create).toHaveBeenCalledTimes(2);
    expect(mockOpenAI.chat.completions.create).toHaveBeenLastCalledWith(
      expect.objectContaining({
        max_tokens: 16000
      }),
      expect.anything()
    );
    vi.useRealTimers();
  });

  it("should retry and succeed if the first attempt returns malformed JSON", async () => {
    vi.useFakeTimers();
    const mockOpenAI = new OpenAI() as any;
    mockOpenAI.chat.completions.create
      .mockResolvedValueOnce({
        choices: [{ message: { content: 'No JSON here' } }],
        usage: { total_tokens: 10 },
      })
      .mockResolvedValueOnce({
        choices: [{ message: { content: '{ "summary": "recovered JSON", "category": "Tech", "tags": ["a"] }' } }],
        usage: { total_tokens: 15 },
      });
    mockOpenAI.embeddings.create.mockResolvedValue({ data: [{ embedding: [0.1] }] });

    const promise = summarizeBookmark({ text: "test tweet" });
    await vi.runAllTimersAsync();
    const result = await promise;

    expect(result.summary).toBe("recovered JSON");
    expect(mockOpenAI.chat.completions.create).toHaveBeenCalledTimes(2);
    expect(mockOpenAI.chat.completions.create).toHaveBeenLastCalledWith(
      expect.objectContaining({
        temperature: 0.1,
        max_tokens: 16000
      }),
      expect.anything()
    );
    vi.useRealTimers();
  });

  it("should generalize model validation error messages", async () => {
    const mockOpenAI = new OpenAI() as any;
    mockOpenAI.models.list.mockResolvedValue({
      data: [{ id: "wrong-model" }],
    });

    await expect(validateModelAvailability()).rejects.toThrow(/Model "test-model" is not currently available/);
  });
});
