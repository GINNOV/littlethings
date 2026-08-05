import { describe, it, expect, vi, beforeEach } from "vitest";
import { generateEmbedding } from "@/lib/llm";
import { getSettings } from "@/lib/settings";

const mockCreateEmbedding = vi.fn();

vi.mock("openai", () => {
  return {
    default: function() {
      return {
        embeddings: {
          create: mockCreateEmbedding,
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

describe("semantic search lib", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(getSettings).mockResolvedValue({
      llmModel: "chat-model",
      llmEmbeddingModel: "text-embedding-3-small",
      llmBaseUrl: "http://localhost:1234/v1",
      llmApiKey: "test-key",
    } as any);
  });

  it("should call OpenAI with embedding model (not chat model) and return embedding", async () => {
    mockCreateEmbedding.mockResolvedValue({
      data: [{ embedding: [0.1, 0.2, 0.3] }],
    });

    const result = await generateEmbedding("Hello world");

    expect(result).toEqual([0.1, 0.2, 0.3]);
    expect(mockCreateEmbedding).toHaveBeenCalledWith(
      expect.objectContaining({
        model: "text-embedding-3-small",
        input: "Hello world",
      }),
      expect.objectContaining({ timeout: 15000 })
    );
  });

  it("should use dedicated embedding base URL when configured", async () => {
    vi.mocked(getSettings).mockResolvedValue({
      llmModel: "gemma-4-26b",
      llmBaseUrl: "http://192.168.0.69:8000/v1",
      llmEmbeddingModel: "nomic-embed-text",
      llmEmbeddingBaseUrl: "http://127.0.0.1:11434/v1",
      llmApiKey: "test-key",
    } as any);
    mockCreateEmbedding.mockResolvedValue({
      data: [{ embedding: [0.5] }],
    });

    await generateEmbedding("split setup");

    expect(mockCreateEmbedding).toHaveBeenCalledWith(
      expect.objectContaining({
        model: "nomic-embed-text",
        input: "split setup",
      }),
      expect.objectContaining({ timeout: 15000 })
    );
  });

  it("should truncate long text to 8000 characters", async () => {
    mockCreateEmbedding.mockResolvedValue({
      data: [{ embedding: [0.1] }],
    });

    const longText = "a".repeat(10000);
    await generateEmbedding(longText);

    expect(mockCreateEmbedding).toHaveBeenCalledWith(
      expect.objectContaining({
        input: "a".repeat(8000),
      }),
      expect.objectContaining({ timeout: 15000 })
    );
  });
});
