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

  it("delta sync with baseline skips folder re-scan and does not re-hydrate known tweets", async () => {
    const mockSettings = {
      monthlyCap: 1000,
      xAccessToken: "valid-token",
      xUserId: "user-123",
      xApiBase: "https://api.x.com/2",
      lastBookmarkId: "baseline-tweet",
    };
    (prisma.settings.findUnique as any).mockResolvedValue(mockSettings);
    (vi.mocked(getSettings) as any).mockResolvedValue(mockSettings);

    // Library already has the baseline tweet
    (prisma.bookmark.findMany as any)
      .mockResolvedValueOnce([{ id: "baseline-tweet" }]) // existing X ids
      .mockResolvedValueOnce([]); // existing among candidates

    // Only global bookmarks call (no folder discovery)
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
    expect(json.fetched).toBe(1);

    // Single X API call = global bookmarks only (no folders, no /tweets hydration of known ids)
    expect(vi.mocked(fetch)).toHaveBeenCalledTimes(1);
    const globalCall = new URL(vi.mocked(fetch).mock.calls[0][0] as string);
    expect(globalCall.pathname).toContain("/user-123/bookmarks");
    expect(prisma.bookmark.upsert).toHaveBeenCalledTimes(1);
    expect(prisma.bookmark.upsert).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: "new-tweet" } })
    );
  });
});
