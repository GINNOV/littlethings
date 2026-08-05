import { describe, it, expect, vi, beforeEach } from "vitest";
import { POST } from "@/app/api/import/route";
import { prisma } from "@/lib/db";
import { getSettings } from "@/lib/settings";

vi.mock("@/lib/db", () => ({
  prisma: {
    importRun: { create: vi.fn().mockResolvedValue({ id: "run-1" }), update: vi.fn() },
    operationRun: { update: vi.fn() },
    bookmarkFolder: { upsert: vi.fn(), findMany: vi.fn().mockResolvedValue([]) },
    bookmark: {
      findMany: vi.fn().mockResolvedValue([]),
      upsert: vi.fn(),
      create: vi.fn().mockResolvedValue({}),
      update: vi.fn().mockResolvedValue({}),
      updateMany: vi.fn().mockResolvedValue({ count: 0 }),
    },
    settings: { findUnique: vi.fn() },
    usageMonth: { findUnique: vi.fn().mockResolvedValue({ usedBookmarks: 0 }) },
  },
}));

vi.mock("@/lib/processing", () => ({
  createOperationRun: vi.fn().mockResolvedValue({ id: "op-1" }),
  logProcessingEvent: vi.fn(),
  updateOperationRun: vi.fn(),
  getActiveRun: vi.fn().mockResolvedValue(null),
  incrementOperationRun: vi.fn(),
}));

vi.mock("@/lib/settings", () => ({
  getSettings: vi.fn(),
  getUsageMonth: vi.fn().mockResolvedValue({ usedBookmarks: 0 }),
  updateSettings: vi.fn(),
  incrementUsage: vi.fn(),
}));

// Mock global fetch
global.fetch = vi.fn();

describe("X Deep Folder Sync Integration", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // No lastBookmarkId → deep folder scan runs (first/full sync path).
    const mockSettings = {
      monthlyCap: 1000,
      xAccessToken: "valid-token",
      xUserId: "user-123",
      xApiBase: "https://api.x.com/2",
      lastBookmarkId: null,
    };
    (prisma.settings.findUnique as any).mockResolvedValue(mockSettings);
    (vi.mocked(getSettings) as any).mockResolvedValue(mockSettings);
  });

  it("should discover folders and fetch bookmarks with correct URL parameters", async () => {
    // 1. Mock Folder Discovery call
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: [{ id: "f1", name: "Tech" }] }),
    } as any);

    // 2. Mock Folder Content call (IDs ONLY)
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: [{ id: "t1" }], meta: {} }),
    } as any);

    // 3. Mock Hydration call (/tweets)
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: [{ id: "t1", text: "tech content" }] }),
    } as any);

    // 4. Mock Global Sync call
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: [{ id: "t2", text: "global content" }], meta: {} }),
    } as any);

    const req = new Request("http://localhost/api/import?source=x");
    const res = await POST(req);
    const json = await res.json();

    if (!json.ok) {
      // Surface API error in assertion message for easier debugging
      throw new Error(`import failed: ${JSON.stringify(json)}`);
    }
    expect(json.ok).toBe(true);
    expect(json.fetched).toBe(2);

    // CRITICAL: Verify the folder list call DOES NOT have forbidden parameters
    const folderListCall = new URL(vi.mocked(fetch).mock.calls[1][0] as string);
    expect(folderListCall.pathname).toContain("/bookmarks/folders/f1");
    expect(folderListCall.searchParams.has("tweet.fields")).toBe(false);
    expect(folderListCall.searchParams.has("max_results")).toBe(false);

    // CRITICAL: Verify the hydration call DOES have parameters
    const hydrationCall = new URL(vi.mocked(fetch).mock.calls[2][0] as string);
    expect(hydrationCall.pathname).toContain("/2/tweets");
    expect(hydrationCall.searchParams.has("tweet.fields")).toBe(true);

    // CRITICAL: Verify the global sync call DOES have parameters
    const globalSyncCall = new URL(vi.mocked(fetch).mock.calls[3][0] as string);
    expect(globalSyncCall.pathname).toContain("/user-123/bookmarks");
    expect(globalSyncCall.searchParams.has("tweet.fields")).toBe(true);
    expect(globalSyncCall.searchParams.has("max_results")).toBe(true);
  });

  it("delta sync links folder membership for known tweets without re-hydrating them", async () => {
    const mockSettings = {
      monthlyCap: 1000,
      xAccessToken: "valid-token",
      xUserId: "user-123",
      xApiBase: "https://api.x.com/2",
      lastBookmarkId: "baseline-tweet",
    };
    (prisma.settings.findUnique as any).mockResolvedValue(mockSettings);
    (vi.mocked(getSettings) as any).mockResolvedValue(mockSettings);

    (prisma.bookmark.findMany as any)
      .mockResolvedValueOnce([{ id: "known-in-library" }, { id: "baseline-tweet" }])
      .mockResolvedValueOnce([]); // existing among import candidates

    vi.mocked(prisma.bookmark.updateMany).mockResolvedValue({ count: 1 } as any);

    // 1) Folder discovery
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: [{ id: "f1", name: "Tech" }] }),
    } as any);
    // 2) Folder ID list (known tweet only — no /tweets hydration)
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({ data: [{ id: "known-in-library" }], meta: {} }),
    } as any);
    // 3) Global delta
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        data: [
          { id: "new-tweet", text: "brand new" },
          { id: "baseline-tweet", text: "already have" },
        ],
        meta: {},
      }),
    } as any);

    const req = new Request("http://localhost/api/import?source=x");
    const res = await POST(req);
    const json = await res.json();

    if (!json.ok) throw new Error(`import failed: ${JSON.stringify(json)}`);
    expect(json.imported).toBe(1);

    // No /2/tweets hydration for known-in-library
    const paths = vi.mocked(fetch).mock.calls.map((c) => new URL(c[0] as string).pathname);
    expect(paths.some((p) => p.includes("/2/tweets"))).toBe(false);
    expect(prisma.bookmark.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ id: { in: ["known-in-library"] } }),
        data: { folderId: "f1" },
      })
    );
    expect(prisma.bookmark.upsert).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: "new-tweet" } })
    );
  });
});
