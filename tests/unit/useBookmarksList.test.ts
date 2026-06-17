import { describe, it, expect, vi, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useBookmarksList, Bookmark } from "@/app/hooks/useBookmarksList";

global.fetch = vi.fn();

const mockBookmarks: Bookmark[] = [
  {
    id: "1", source: "x", tweetUrl: "https://x.com/1", text: "test 1", summary: "sum 1", category: "AI", tags: "a,b",
    authorUsername: "user1", importedAt: "2026-04-24T00:00:00Z", createdAt: "2026-04-24T00:00:00Z", summarizedAt: "2026-04-24T00:00:00Z",
    editedAt: null, readAt: null,
  },
];

describe("useBookmarksList hook", () => {
  beforeEach(() => { vi.clearAllMocks(); });

  it("should initialize with items", () => {
    const { result } = renderHook(() => useBookmarksList(mockBookmarks));
    expect(result.current.items).toEqual(mockBookmarks);
  });

  it("should toggle read state", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({ ok: true, json: async () => ({ bookmark: { ...mockBookmarks[0], readAt: "now" } }) } as any);
    const { result } = renderHook(() => useBookmarksList(mockBookmarks));
    await act(async () => { await result.current.toggleRead(mockBookmarks[0]); });
    expect(fetch).toHaveBeenCalledWith("/api/bookmarks/read", expect.anything());
    expect(result.current.items[0].readAt).toBe("now");
  });

  it("should handle translation", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({ ok: true, json: async () => ({ translatedText: "Hola" }) } as any);
    const { result } = renderHook(() => useBookmarksList(mockBookmarks));
    await act(async () => { await result.current.translate("1"); });
    expect(result.current.translatedText).toBe("Hola");
  });

  it("should reprocess bookmark", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({ ok: true, json: async () => ({ bookmark: { ...mockBookmarks[0], summary: "new" } }) } as any);
    const { result } = renderHook(() => useBookmarksList(mockBookmarks));
    await act(async () => { await result.current.reprocess("1"); });
    expect(fetch).toHaveBeenCalledWith("/api/enrich/one?bookmarkId=1", { method: "POST" });
    expect(result.current.items[0].summary).toBe("new");
  });

  it("should save edit", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({ ok: true, json: async () => ({ bookmark: { ...mockBookmarks[0], summary: "edit" } }) } as any);
    const { result } = renderHook(() => useBookmarksList(mockBookmarks));
    act(() => { result.current.openEdit(mockBookmarks[0]); });
    act(() => { result.current.setEditing({ ...result.current.editing!, summary: "edit" }); });
    await act(async () => { await result.current.saveEdit(); });
    expect(fetch).toHaveBeenCalledWith("/api/enrich/edit", expect.anything());
    expect(result.current.items[0].summary).toBe("edit");
  });

  it("should handle failures", async () => {
    vi.mocked(fetch).mockResolvedValueOnce({ ok: false, json: async () => ({ error: "fail" }) } as any);
    const { result } = renderHook(() => useBookmarksList(mockBookmarks));
    await act(async () => { await result.current.reprocess("1"); });
    expect(result.current.message).toBe("fail");
  });
});
