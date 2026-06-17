import { describe, it, expect, vi, beforeEach } from "vitest";
import { fetchYouTubeBookmarks } from "@/lib/youtube";
import { getSettings } from "@/lib/settings";

vi.mock("@/lib/settings", () => ({
  getSettings: vi.fn(),
  updateSettings: vi.fn(),
}));

global.fetch = vi.fn();

describe("youtube lib", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.mocked(getSettings).mockResolvedValue({
      ytAccessToken: "valid-yt-token",
    } as any);
  });

  it("should fetch youtube bookmarks from playlists", async () => {
    // 1. Mock playlists fetch
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        items: [
          {
            id: "pl-1",
            snippet: { title: "My Playlist" },
            contentDetails: { itemCount: 1 },
          },
        ],
      }),
    } as any);

    // 2. Mock playlist items fetch
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: async () => ({
        items: [
          {
            snippet: {
              resourceId: { videoId: "vid-1" },
              title: "YT Video",
              description: "A cool video",
              publishedAt: "2026-04-24T00:00:00Z",
              channelTitle: "Cool Channel",
            },
          },
        ],
      }),
    } as any);

    const items = await fetchYouTubeBookmarks();

    expect(items).toHaveLength(1);
    expect(items[0].id).toBe("yt:pl-1:vid-1");
    expect(items[0].title).toBe("YT Video");
  });
});
