import { describe, it, expect } from "vitest";
import {
  formatRunOutcome,
  formatRunTitle,
  formatRunType,
  formatRunSource,
} from "@/app/lib/formatters";

describe("formatRunType", () => {
  it("returns type label without source", () => {
    expect(formatRunType("enrichment_batch")).toBe("Enrichment batch");
    expect(formatRunType("enrichment_full_reprocess")).toBe("Force reprocess all");
  });
});

describe("formatRunTitle", () => {
  it("includes X or YouTube for enrichment batches", () => {
    expect(formatRunTitle("enrichment_batch", "x")).toBe("Enrichment batch · X");
    expect(formatRunTitle("enrichment_batch", "yt")).toBe("Enrichment batch · YouTube");
  });

  it("labels full force reprocess clearly (not as a 500-item batch)", () => {
    expect(formatRunTitle("enrichment_full_reprocess", "x")).toBe("Force reprocess all · X");
    expect(formatRunTitle("enrichment_full", "yt")).toBe("Enrich all · YouTube");
  });

  it("formats other sources", () => {
    expect(formatRunSource("system")).toBe("System");
    expect(formatRunTitle("embedding_sync", "system")).toBe("Embedding sync · System");
  });
});

describe("formatRunOutcome", () => {
  it("shows updated and failed for a completed enrichment-style run", () => {
    expect(
      formatRunOutcome({
        status: "completed",
        total: 50,
        processed: 20,
        updated: 18,
        failed: 2,
        skipped: 0,
        notes: "Completed.",
      })
    ).toBe("18 updated · 2 failed");
  });

  it("shows progress and failures while running", () => {
    expect(
      formatRunOutcome({
        status: "running",
        total: 50,
        processed: 12,
        updated: 11,
        failed: 1,
        skipped: 0,
      })
    ).toBe("12/50 processed · 11 updated · 1 failed");
  });

  it("shows progress when only totals exist (queued)", () => {
    expect(
      formatRunOutcome({
        status: "queued",
        total: 50,
        processed: 0,
        updated: 0,
        failed: 0,
      })
    ).toBe("0/50 processed");
  });

  it("includes skipped when non-zero", () => {
    expect(
      formatRunOutcome({
        status: "completed",
        total: 10,
        processed: 10,
        updated: 8,
        failed: 0,
        skipped: 2,
      })
    ).toBe("8 updated · 2 skipped");
  });

  it("falls back to notes when counters are zero", () => {
    expect(
      formatRunOutcome({
        status: "completed",
        total: 0,
        processed: 0,
        updated: 0,
        failed: 0,
        notes: "Completed.",
      })
    ).toBe("Completed.");
  });

  it("falls back to No details when empty", () => {
    expect(
      formatRunOutcome({
        status: "completed",
        notes: null,
      })
    ).toBe("No details");
  });

  it("shows processed only when no updated/failed but processed > 0", () => {
    expect(
      formatRunOutcome({
        status: "completed",
        total: 0,
        processed: 5,
        updated: 0,
        failed: 0,
      })
    ).toBe("5 processed");
  });
});
