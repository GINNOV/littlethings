import { z } from "zod";
import { getSettings, updateSettings } from "@/lib/settings";

const envSchema = z.object({ YT_CLIENT_ID: z.string().min(1).optional(), YT_CLIENT_SECRET: z.string().min(1).optional() });
const cleanEnv = (v?: string) => (v?.trim().length ? v.trim() : undefined);
type YtAuthContext = { accessToken: string };
export type YouTubePlaylist = { id: string; title?: string; itemCount?: number };
const GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";

export type YouTubeBookmark = {
  id: string; tweetUrl: string; title?: string; text?: string;
  authorName?: string; authorUsername?: string; createdAt?: Date;
  likeCount?: number; replyCount?: number; retweetCount?: number; quoteCount?: number;
  lang?: string; folderId?: string; folderName?: string;
  externalUrls?: string[]; mediaDescription?: string; mediaJson?: string; rawJson: string;
};

async function handleRefreshError(text: string) {
  if (text.toLowerCase().includes("invalid_grant")) {
    await updateSettings({ ytAccessToken: null, ytRefreshToken: null, ytTokenExpiresAt: null, ytScope: null, ytTokenType: null });
    throw new Error("YouTube authorization expired. Reconnect in Settings.");
  }
  throw new Error(`YouTube token refresh failed: ${text}`);
}

async function refreshAccessToken(input: { clientId: string; clientSecret: string; refreshToken: string; }) {
  const body = new URLSearchParams({ client_id: input.clientId, client_secret: input.clientSecret, refresh_token: input.refreshToken, grant_type: "refresh_token" });
  const res = await fetch(GOOGLE_TOKEN_URL, { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body });
  if (!res.ok) await handleRefreshError(await res.text());
  const json = (await res.json()) as { access_token?: string; expires_in?: number; scope?: string; token_type?: string; };
  const expiresAt = json.expires_in ? new Date(Date.now() + json.expires_in * 1000) : null;
  await updateSettings({ ytAccessToken: json.access_token ?? null, ytTokenExpiresAt: expiresAt, ytScope: json.scope ?? null, ytTokenType: json.token_type ?? null });
  if (!json.access_token) throw new Error("YouTube refresh did not return a token.");
  return json.access_token;
}

async function getAuthContext(): Promise<YtAuthContext> {
  const env = envSchema.parse({ YT_CLIENT_ID: cleanEnv(process.env.YT_CLIENT_ID), YT_CLIENT_SECRET: cleanEnv(process.env.YT_CLIENT_SECRET) });
  const settings = await getSettings();
  let token = settings.ytAccessToken ?? null;
  const expiresAt = settings.ytTokenExpiresAt ? new Date(settings.ytTokenExpiresAt) : null;
  const shouldRefresh = token && settings.ytRefreshToken && expiresAt && (Date.now() >= expiresAt.getTime() - 120000) && (settings.ytClientId ?? env.YT_CLIENT_ID) && (settings.ytClientSecret ?? env.YT_CLIENT_SECRET);
  if (shouldRefresh) {
    token = await refreshAccessToken({ clientId: settings.ytClientId ?? env.YT_CLIENT_ID ?? "", clientSecret: settings.ytClientSecret ?? env.YT_CLIENT_SECRET ?? "", refreshToken: settings.ytRefreshToken ?? "" });
  }
  if (!token) throw new Error("Missing YouTube credentials.");
  return { accessToken: token };
}

async function fetchWithAuth(url: URL, accessToken: string) {
  const res = await fetch(url, { headers: { Authorization: `Bearer ${accessToken}` } });
  if (res.ok) return res.json() as Promise<Record<string, any>>;
  const text = await res.text();
  if (res.status === 403 && (text.toLowerCase().includes("quotaexceeded") || text.toLowerCase().includes("dailylimitexceeded"))) {
    const error = new Error("YouTube API quota reached.");
    (error as any).code = "YOUTUBE_QUOTA";
    throw error;
  }
  throw new Error(`YouTube API error ${res.status}: ${text}`);
}

async function fetchAllPlaylists(accessToken: string): Promise<YouTubePlaylist[]> {
  const playlists: YouTubePlaylist[] = [];
  let pageToken: string | undefined;
  while (true) {
    const url = new URL("https://www.googleapis.com/youtube/v3/playlists");
    url.searchParams.set("part", "snippet,contentDetails");
    url.searchParams.set("mine", "true");
    url.searchParams.set("maxResults", "50");
    if (pageToken) url.searchParams.set("pageToken", pageToken);
    const json = (await fetchWithAuth(url, accessToken)) as any;
    for (const item of json.items ?? []) {
      if (item.id) playlists.push({ id: item.id, title: item.snippet?.title, itemCount: item.contentDetails?.itemCount ?? 0 });
    }
    if (!json.nextPageToken) break;
    pageToken = json.nextPageToken;
  }
  return playlists;
}

export async function fetchYouTubePlaylists() {
  const { accessToken } = await getAuthContext();
  return fetchAllPlaylists(accessToken);
}

function mapItem(entry: any, playlist: YouTubePlaylist) {
  const snip = entry.snippet;
  const vid = snip?.resourceId?.videoId;
  if (!vid) return null;
  const url = `https://www.youtube.com/watch?v=${vid}`;
  const txt = snip?.title && snip?.description ? `${snip.title}\n\n${snip.description}` : (snip?.title || snip?.description);
  return {
    id: `yt:${playlist.id}:${vid}`, tweetUrl: url, title: snip?.title, text: txt,
    authorName: snip?.channelTitle, authorUsername: snip?.channelTitle,
    createdAt: snip?.publishedAt ? new Date(snip.publishedAt) : undefined,
    folderId: `yt:pl:${playlist.id}`, folderName: playlist.title, externalUrls: [url],
    rawJson: JSON.stringify({ playlistId: playlist.id, playlistTitle: playlist.title, item: entry }),
  } satisfies YouTubeBookmark;
}

async function fetchPlaylistPage(playlistId: string, token: string, size: number, pageToken?: string) {
  const url = new URL("https://www.googleapis.com/youtube/v3/playlistItems");
  url.searchParams.set("part", "snippet");
  url.searchParams.set("playlistId", playlistId);
  url.searchParams.set("maxResults", String(size));
  if (pageToken) url.searchParams.set("pageToken", pageToken);
  return (await fetchWithAuth(url, token)) as any;
}

export async function fetchYouTubeBookmarks(input?: { maxTotal?: number }) {
  const { accessToken } = await getAuthContext();
  const playlists = await fetchAllPlaylists(accessToken);
  const max = input?.maxTotal ?? Number.POSITIVE_INFINITY;
  const items: YouTubeBookmark[] = [];
  for (const pl of playlists) {
    if (items.length >= max) break;
    let pt: string | undefined;
    while (items.length < max) {
      const json = await fetchPlaylistPage(pl.id, accessToken, Math.min(50, max - items.length), pt);
      for (const entry of json.items ?? []) {
        const item = mapItem(entry, pl);
        if (item && items.length < max) items.push(item);
      }
      if (!json.nextPageToken) break;
      pt = json.nextPageToken;
    }
  }
  return items;
}
