import { describe, it, expect, vi, beforeEach } from "vitest";
import { fetchBookmarks, fetchXUsage } from "@/lib/x";
import { getSettings, updateSettings } from "@/lib/settings";

vi.mock("@/lib/settings", () => ({
  getSettings: vi.fn(),
  updateSettings: vi.fn(),
}));

global.fetch = vi.fn();

describe("x lib", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(getSettings).mockResolvedValue({
      xAccessToken: "valid-token",
      xUserId: "user-123",
      xApiBase: "https://api.x.com/2",
    } as any);
  });

  it("should fetch bookmarks and hydrate them", async () => {
    // Mock bookmark list response
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        data: [{ id: "tweet-1", text: "hello" }],
        meta: { next_token: null },
      }),
    } as any);

    const items = await fetchBookmarks();

    expect(items).toHaveLength(1);
    expect(items[0].id).toBe("tweet-1");
    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining("/users/user-123/bookmarks"),
      expect.objectContaining({ cache: "no-store" })
    );

    // Verify global bookmarks list HAS hydration parameters
    const callUrl = new URL((vi.mocked(fetch).mock.calls[0][0] as string));
    expect(callUrl.searchParams.has("tweet.fields")).toBe(true);
    expect(callUrl.searchParams.has("max_results")).toBe(true);
  });

  it("should fetch folder bookmarks WITHOUT forbidden parameters", async () => {
    // Mock folder list response (returns IDs)
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        data: [{ id: "tweet-1" }],
        meta: { next_token: null },
      }),
    } as any);

    // Mock hydration call (/tweets)
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        data: [{ id: "tweet-1", text: "folder tweet" }],
      }),
    } as any);

    await fetchBookmarks({ folderId: "folder-456" });

    // Verify folder list request does NOT have hydration fields or max_results
    const folderListCall = new URL((vi.mocked(fetch).mock.calls[0][0] as string));
    expect(folderListCall.pathname).toContain("/bookmarks/folders/folder-456");
    expect(folderListCall.searchParams.has("tweet.fields")).toBe(false);
    expect(folderListCall.searchParams.has("expansions")).toBe(false);
    expect(folderListCall.searchParams.has("max_results")).toBe(false);

    // Verify hydration request (/tweets) DOES have hydration fields
    const hydrationCall = new URL((vi.mocked(fetch).mock.calls[1][0] as string));
    expect(hydrationCall.pathname).toContain("/2/tweets");
    expect(hydrationCall.searchParams.get("ids")).toBe("tweet-1");
    expect(hydrationCall.searchParams.has("tweet.fields")).toBe(true);
    expect(hydrationCall.searchParams.has("max_results")).toBe(false); // /tweets doesn't support max_results
  });

  it("should fetch usage", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        data: {
          tweet_count: 100,
          cap_per_month: 1000,
        },
      }),
    } as any);

    const usage = await fetchXUsage();

    expect(usage?.data.tweet_count).toBe("100");
    expect(usage?.data.cap_per_month).toBe("1000");
  });

  it("should refresh token if expired", async () => {
    const now = Date.now();
    vi.mocked(getSettings).mockResolvedValue({
      xAccessToken: "expired-token",
      xRefreshToken: "refresh-123",
      xTokenExpiresAt: new Date(now - 10000), // Expired
      xClientId: "client-id",
      xUserId: "user-123",
    } as any);

    // Mock token refresh call
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        access_token: "new-token",
        expires_in: 3600,
      }),
    } as any);

    // Mock subsequent bookmarks call
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        data: [],
      }),
    } as any);

    await fetchBookmarks();

    expect(updateSettings).toHaveBeenCalledWith(
      expect.objectContaining({
        xAccessToken: "new-token",
      })
    );
  });
});
