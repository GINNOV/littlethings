import { describe, it, expect, vi, beforeEach } from "vitest";
import { POST } from "@/app/api/enrich/route";
import { prisma } from "@/lib/db";
import * as llm from "@/lib/llm";

vi.mock("@/lib/db", () => ({
  prisma: {
    bookmark: {
      count: vi.fn(),
      findMany: vi.fn(),
      update: vi.fn(),
    },
    settings: {
      findUnique: vi.fn(),
    },
    operationRun: {
      create: vi.fn(),
      findUnique: vi.fn(),
      update: vi.fn(),
    },
  },
}));

vi.mock("@/lib/processing", () => ({
  createOperationRun: vi.fn().mockResolvedValue({ id: "run-1", status: "running" }),
  logProcessingEvent: vi.fn().mockResolvedValue({}),
  updateOperationRun: vi.fn().mockResolvedValue({}),
  incrementOperationRun: vi.fn().mockResolvedValue({}),
  getActiveRun: vi.fn().mockResolvedValue(null),
}));

vi.mock("@/lib/llm", () => ({
  summarizeBookmark: vi.fn(),
  validateModelAvailability: vi.fn().mockResolvedValue(true),
}));

describe("Enrich API Route Resiliency", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    (prisma.settings.findUnique as any).mockResolvedValue({ enrichBatchSize: 50, llmConcurrency: 1 });
  });

  it("should increment failure count and not stop on individual errors", async () => {
    const mockBookmarks = [
      { id: "b1", source: "x", text: "fail me" },
      { id: "b2", source: "x", text: "success" }
    ];

    (prisma.bookmark.count as any).mockResolvedValue(2);
    (prisma.bookmark.findMany as any)
      .mockResolvedValueOnce(mockBookmarks)
      .mockResolvedValueOnce([]); // Second loop returns empty to break

    // First call fails, second succeeds
    (llm.summarizeBookmark as any)
      .mockRejectedValueOnce(new Error("LLM Error"))
      .mockResolvedValueOnce({ summary: "Done", category: "Tech" });

    const req = new Request("http://localhost/api/enrich?source=x&full=true");
    const res = await POST(req);
    const json = await res.json();

    expect(json.ok).toBe(true);
    expect(json.processed).toBe(2);
    
    // Verify b1 failure increment
    expect(prisma.bookmark.update).toHaveBeenCalledWith(expect.objectContaining({
      where: { id: "b1" },
      data: expect.objectContaining({ enrichmentFailures: { increment: 1 } })
    }));

    // Verify b2 success reset
    expect(prisma.bookmark.update).toHaveBeenCalledWith(expect.objectContaining({
      where: { id: "b2" },
      data: expect.objectContaining({ enrichmentFailures: 0 })
    }));
  });

  it("should skip items that have reached 3 failures", async () => {
    // This is tested via the 'where' clause in the findMany call
    (prisma.bookmark.count as any).mockResolvedValue(0);
    (prisma.bookmark.findMany as any).mockResolvedValue([]);

    const req = new Request("http://localhost/api/enrich?source=x");
    await POST(req);

    expect(prisma.bookmark.findMany).toHaveBeenCalledWith(expect.objectContaining({
      where: expect.objectContaining({
        enrichmentFailures: { lt: 3 }
      })
    }));
  });

  it("should NOT skip items that have reached 3 failures when full is true", async () => {
    (prisma.bookmark.count as any).mockResolvedValue(0);
    (prisma.bookmark.findMany as any).mockResolvedValue([]);

    const req = new Request("http://localhost/api/enrich?source=x&full=true");
    await POST(req);

    expect(prisma.bookmark.findMany).toHaveBeenCalledWith(expect.objectContaining({
      where: expect.not.objectContaining({
        enrichmentFailures: expect.anything()
      })
    }));
  });

  it("should not revive a stopped run when client multi-batch reuses runId", async () => {
    (prisma.operationRun.findUnique as any).mockResolvedValue({
      id: "run-stopped",
      status: "stopped",
      total: 10,
    });

    const req = new Request(
      "http://localhost/api/enrich?source=x&full=true&runId=run-stopped"
    );
    const res = await POST(req);
    const json = await res.json();

    expect(res.status).toBe(409);
    expect(json.stopped).toBe(true);
    expect(json.ok).toBe(false);
    expect(prisma.operationRun.update).not.toHaveBeenCalled();
  });
});
