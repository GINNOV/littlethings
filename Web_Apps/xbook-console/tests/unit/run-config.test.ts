import { describe, it, expect } from "vitest";
import {
  buildEmbeddingRunConfig,
  buildEnrichmentRunConfig,
  formatLlmEndpoint,
  formatRunConfig,
  parseRunConfig,
  resolveRunConfig,
  runConfigParts,
} from "@/lib/run-config";

describe("formatLlmEndpoint", () => {
  it("labels common local presets", () => {
    expect(formatLlmEndpoint("http://127.0.0.1:1234/v1")).toBe("LM Studio");
    expect(formatLlmEndpoint("http://localhost:11434/v1")).toBe("Ollama");
    expect(formatLlmEndpoint("http://127.0.0.1:8000/v1")).toBe("vLLM (local)");
  });

  it("shows remote host:port", () => {
    expect(formatLlmEndpoint("http://192.168.0.69:8000/v1")).toBe("192.168.0.69:8000");
  });
});

describe("runConfigParts", () => {
  it("returns ordered chips for horizontal layout", () => {
    expect(
      runConfigParts({
        model: "qwen2.5-32b",
        baseUrl: "http://192.168.0.69:8000/v1",
        concurrency: 8,
        batchSize: 50,
        batchIndex: 3,
        totalBatches: 12,
        maxTokens: 4000,
      }).map((p) => p.label)
    ).toEqual(["qwen2.5-32b", "192.168.0.69:8000", "×8", "3/12", "size 50", "4k tok"]);
  });

  it("shows batch size even for single-batch runs", () => {
    expect(
      runConfigParts({
        model: "gemma",
        baseUrl: "http://127.0.0.1:1234/v1",
        batchSize: 50,
        batchIndex: 1,
        totalBatches: 1,
      }).map((p) => p.label)
    ).toEqual(["gemma", "LM Studio", "1/1", "size 50"]);
  });

  it("hides 0/1 progress noise for not-yet-started single batch", () => {
    expect(
      runConfigParts({
        model: "gemma",
        baseUrl: "http://127.0.0.1:1234/v1",
        batchSize: 50,
        batchIndex: 0,
        totalBatches: 1,
      }).map((p) => p.label)
    ).toEqual(["gemma", "LM Studio", "size 50"]);
  });
});

describe("formatRunConfig", () => {
  it("joins model, machine, and knobs", () => {
    expect(
      formatRunConfig({
        model: "qwen2.5-32b",
        baseUrl: "http://192.168.0.69:8000/v1",
        concurrency: 8,
        batchSize: 50,
        batchIndex: 3,
        totalBatches: 12,
        maxTokens: 4000,
        thinking: false,
      })
    ).toBe("qwen2.5-32b · 192.168.0.69:8000 · ×8 · 3/12 · size 50 · 4k tok");
  });

  it("flags thinking when enabled", () => {
    expect(
      formatRunConfig({
        model: "qwen",
        baseUrl: "http://127.0.0.1:1234/v1",
        thinking: true,
      })
    ).toBe("qwen · LM Studio · thinking");
  });

  it("formats embedding-only config", () => {
    expect(
      formatRunConfig({
        embeddingModel: "nomic-embed-text",
        embeddingBaseUrl: "http://127.0.0.1:11434/v1",
        baseUrl: "http://127.0.0.1:11434/v1",
      })
    ).toBe("nomic-embed-text · Ollama");
  });
});

describe("buildEnrichmentRunConfig", () => {
  it("snapshots settings and knobs", () => {
    const cfg = buildEnrichmentRunConfig(
      {
        llmModel: "gemma-3",
        llmBaseUrl: "http://127.0.0.1:1234/v1",
        llmMaxTokens: 2500,
        llmThinkingEnabled: false,
      },
      { concurrency: 4, batchSize: 25, batchIndex: 0, totalBatches: 8 }
    );
    expect(cfg).toMatchObject({
      model: "gemma-3",
      baseUrl: "http://127.0.0.1:1234/v1",
      concurrency: 4,
      batchSize: 25,
      batchIndex: 0,
      totalBatches: 8,
      maxTokens: 2500,
      thinking: false,
    });
  });
});

describe("buildEmbeddingRunConfig", () => {
  it("prefers dedicated embedding base URL", () => {
    const cfg = buildEmbeddingRunConfig({
      llmBaseUrl: "http://192.168.0.69:8000/v1",
      llmEmbeddingBaseUrl: "http://127.0.0.1:11434/v1",
      llmEmbeddingModel: "nomic-embed-text",
    });
    expect(cfg.embeddingModel).toBe("nomic-embed-text");
    expect(cfg.baseUrl).toBe("http://127.0.0.1:11434/v1");
    expect(cfg.model).toBeUndefined();
  });
});

describe("resolveRunConfig", () => {
  it("prefers stored configJson", () => {
    const json = JSON.stringify({ model: "stored", baseUrl: "http://localhost:1234/v1", concurrency: 2 });
    expect(
      resolveRunConfig({
        configJson: json,
        llmModel: "from-log",
        llmBaseUrl: "http://localhost:9999/v1",
      })
    ).toMatchObject({ model: "stored", concurrency: 2 });
  });

  it("falls back to first LLM log for legacy runs", () => {
    expect(
      resolveRunConfig({
        configJson: null,
        llmModel: "legacy-model",
        llmBaseUrl: "http://127.0.0.1:11434/v1",
      })
    ).toMatchObject({ model: "legacy-model", baseUrl: "http://127.0.0.1:11434/v1" });
  });

  it("parses invalid JSON as empty then still merges LLM log", () => {
    expect(parseRunConfig("not-json")).toBeNull();
    expect(
      resolveRunConfig({ configJson: "{bad", llmModel: "m", llmBaseUrl: null })
    ).toMatchObject({ model: "m", baseUrl: null });
  });

  it("recovers batch progress from notes when config lacks it", () => {
    expect(
      resolveRunConfig({
        configJson: JSON.stringify({ model: "m", baseUrl: "http://localhost:1234/v1", batchSize: 50 }),
        notes: "X enrich all · batch 4 of 22 · completed",
      })
    ).toMatchObject({
      model: "m",
      batchSize: 50,
      batchIndex: 4,
      totalBatches: 22,
    });
  });
});
