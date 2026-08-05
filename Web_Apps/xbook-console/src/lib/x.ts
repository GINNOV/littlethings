import { z } from "zod";
import { getSettings, updateSettings } from "@/lib/settings";

const envSchema = z.object({
  X_BEARER_TOKEN: z.string().min(1).optional(),
  X_USER_ID: z.string().min(1).optional(),
  X_API_BASE: z.string().url().optional(),
  X_CLIENT_ID: z.string().min(1).optional(),
  X_CLIENT_SECRET: z.string().min(1).optional(),
});

const cleanEnv = (value?: string) => {
  if (!value) return undefined;
  const trimmed = value.trim();
  return trimmed.length ? trimmed : undefined;
};

type Tweet = {
  id: string; text?: string; author_id?: string; created_at?: string; lang?: string;
  public_metrics?: { like_count?: number; reply_count?: number; retweet_count?: number; quote_count?: number; };
  entities?: { urls?: Array<{ expanded_url?: string }>; };
  attachments?: { media_keys?: string[]; };
};

type User = { id: string; name?: string; username?: string; };

type Media = {
  media_key: string; type: "video" | "photo" | "animated_gif"; alt_text?: string;
  variants?: Array<{ bit_rate?: number; content_type?: string; url?: string; }>;
};

type BookmarkResponse = {
  data?: Tweet[];
  includes?: { users?: User[]; media?: Media[]; };
  meta?: { next_token?: string; result_count?: number };
};

export type BookmarkItem = {
  id: string; tweetUrl: string; title?: string; text?: string;
  authorName?: string; authorUsername?: string; createdAt?: Date;
  likeCount?: number; replyCount?: number; retweetCount?: number; quoteCount?: number;
  lang?: string; folderId?: string; folderName?: string;
  externalUrls?: string[]; mediaDescription?: string; mediaJson?: string; rawJson: string;
};

type AuthContext = { token: string; userId: string; apiBase: string; };

const DEFAULT_API_BASE = "https://api.x.com/2";
const X_OAUTH_REQUIRED_MESSAGE = "X bookmark sync requires an OAuth 2.0 user access token. Connect X OAuth in Settings.";
const X_CLIENT_ENROLLMENT_MESSAGE = "X API access was denied by X. Reconnect X OAuth.";

function formatXApiError(status: number, body: string) {
  const isEnrolledError = body.includes("\"reason\":\"client-not-enrolled\"") ||
    body.includes("\"title\":\"Client Forbidden\"");
  if (status === 403 && isEnrolledError) return X_CLIENT_ENROLLMENT_MESSAGE;
  return `X API error ${status}: ${body}`;
}

async function updateTokens(json: any, refreshToken: string) {
  const expiresAt = json.expires_in ? new Date(Date.now() + json.expires_in * 1000) : null;
  await updateSettings({
    xAccessToken: json.access_token ?? null,
    xRefreshToken: json.refresh_token ?? refreshToken,
    xTokenExpiresAt: expiresAt,
    xScope: json.scope ?? null,
    xTokenType: json.token_type ?? null,
  });
  if (!json.access_token) throw new Error("Token refresh did not return an access token.");
  return json.access_token;
}

async function refreshAccessToken(input: {
  apiBase: string; clientId: string; clientSecret?: string | null; refreshToken: string;
}) {
  const body = new URLSearchParams({ grant_type: "refresh_token", client_id: input.clientId, refresh_token: input.refreshToken });
  const headers: Record<string, string> = { "Content-Type": "application/x-www-form-urlencoded" };
  if (input.clientSecret) {
    const basic = Buffer.from(`${input.clientId}:${input.clientSecret}`).toString("base64");
    headers.Authorization = `Basic ${basic}`;
  }
  const res = await fetch(`${input.apiBase}/oauth2/token`, { method: "POST", headers, body, cache: "no-store" });
  if (!res.ok) throw new Error(`Token refresh failed: ${await res.text()}`);
  return updateTokens(await res.json(), input.refreshToken);
}

async function getRawAuthData() {
  const env = envSchema.parse({
    X_BEARER_TOKEN: cleanEnv(process.env.X_BEARER_TOKEN),
    X_USER_ID: cleanEnv(process.env.X_USER_ID),
    X_API_BASE: cleanEnv(process.env.X_API_BASE),
    X_CLIENT_ID: cleanEnv(process.env.X_CLIENT_ID),
    X_CLIENT_SECRET: cleanEnv(process.env.X_CLIENT_SECRET),
  });
  return { env, settings: await getSettings() };
}

async function refreshIfNeeded(apiBase: string, env: any, settings: any) {
  const accessToken = settings.xAccessToken ?? null;
  const expiresAt = settings.xTokenExpiresAt ? new Date(settings.xTokenExpiresAt) : null;
  const isExpiringSoon = expiresAt && Date.now() >= expiresAt.getTime() - 2 * 60 * 1000;
  const canRefresh = accessToken && isExpiringSoon && settings.xRefreshToken && (settings.xClientId ?? env.X_CLIENT_ID);
  if (canRefresh) {
    return refreshAccessToken({
      apiBase,
      clientId: settings.xClientId ?? env.X_CLIENT_ID ?? "",
      clientSecret: settings.xClientSecret ?? env.X_CLIENT_SECRET ?? null,
      refreshToken: settings.xRefreshToken ?? "",
    });
  }
  return accessToken;
}

async function lookupUserIdIfNeeded(apiBase: string, token: string, currentUserId: string | null) {
  if (currentUserId) return currentUserId;
  const meRes = await fetch(`${apiBase}/users/me`, { headers: { Authorization: `Bearer ${token}` }, cache: "no-store" });
  if (meRes.ok) {
    const meJson = (await meRes.json()) as { data?: { id?: string } };
    if (meJson.data?.id) {
      await updateSettings({ xUserId: meJson.data.id });
      return meJson.data.id;
    }
  }
  return null;
}

export async function getAuthContext(): Promise<AuthContext> {
  const { env, settings } = await getRawAuthData();
  const apiBase = settings.xApiBase ?? env.X_API_BASE ?? DEFAULT_API_BASE;
  const accessToken = await refreshIfNeeded(apiBase, env, settings);
  if (!accessToken && settings.xBearerToken) throw new Error(X_OAUTH_REQUIRED_MESSAGE);
  const userId = await lookupUserIdIfNeeded(apiBase, accessToken!, settings.xUserId ?? env.X_USER_ID ?? null);
  if (!accessToken || !userId) throw new Error("Missing X credentials.");
  return { token: accessToken, userId, apiBase };
}

function buildBookmarkUrl(baseUrl: string, userId: string, folderId?: string) {
  if (folderId) return new URL(`${baseUrl}/users/${userId}/bookmarks/folders/${folderId}`);
  return new URL(`${baseUrl}/users/${userId}/bookmarks`);
}

function getMediaData(tweet: Tweet, mediaByKey: Map<string, Media>) {
  const mediaItems = (tweet.attachments?.media_keys ?? []).map((key) => mediaByKey.get(key)).filter(Boolean) as Media[];
  const mediaDescription = mediaItems.map((m) => m.alt_text).filter(Boolean).join("\n");
  return { mediaItems, mediaDescription };
}

function extractTweetData(tweet: Tweet, usersById: Map<string, User>, mediaByKey: Map<string, Media>, folderId?: string, folderName?: string) {
  const author = tweet.author_id ? usersById.get(tweet.author_id) : undefined;
  const urls = (tweet.entities?.urls ?? []).map((e) => e.expanded_url).filter((e): e is string => Boolean(e));
  const { mediaItems, mediaDescription } = getMediaData(tweet, mediaByKey);
  return {
    id: tweet.id, tweetUrl: `https://x.com/i/web/status/${tweet.id}`, title: undefined, text: tweet.text,
    authorName: author?.name, authorUsername: author?.username,
    createdAt: tweet.created_at ? new Date(tweet.created_at) : undefined,
    likeCount: tweet.public_metrics?.like_count, replyCount: tweet.public_metrics?.reply_count,
    retweetCount: tweet.public_metrics?.retweet_count, quoteCount: tweet.public_metrics?.quote_count,
    lang: tweet.lang, folderId, folderName, externalUrls: urls,
    mediaDescription: mediaDescription || undefined, mediaJson: mediaItems.length ? JSON.stringify(mediaItems) : undefined,
    rawJson: JSON.stringify(tweet),
  } satisfies BookmarkItem;
}

function mapBookmarkItemsFromResponse(input: { json: BookmarkResponse; folderId?: string; folderName?: string; preferredOrder?: string[]; }) {
  const usersById = new Map<string, User>();
  for (const user of input.json.includes?.users ?? []) usersById.set(user.id, user);
  const mediaByKey = new Map<string, Media>();
  for (const m of input.json.includes?.media ?? []) mediaByKey.set(m.media_key, m);

  const mapped = (input.json.data ?? []).map((tweet) => extractTweetData(tweet, usersById, mediaByKey, input.folderId, input.folderName));
  if (!input.preferredOrder?.length) return mapped;

  const byId = new Map(mapped.map((item) => [item.id, item]));
  return input.preferredOrder.map((id) => byId.get(id)).filter((item): item is NonNullable<typeof item> => Boolean(item));
}

async function lookupTweetsByIds(input: { apiBase: string; token: string; ids: string[]; folderId?: string; folderName?: string; }) {
  if (!input.ids.length) return [];
  const url = new URL(`${input.apiBase}/tweets`);
  url.searchParams.set("ids", input.ids.join(","));
  applyBaseQueryParams(url);
  const res = await fetch(url, { headers: { Authorization: `Bearer ${input.token}` }, cache: "no-store" });
  if (!res.ok) throw new Error(formatXApiError(res.status, await res.text()));
  return mapBookmarkItemsFromResponse({ json: (await res.json()) as BookmarkResponse, folderId: input.folderId, folderName: input.folderName, preferredOrder: input.ids });
}

type FetchOptions = { maxPages?: number; maxTotal?: number; folderId?: string; folderName?: string; stopBeforeIds?: Set<string>; skipExisting?: boolean; };

async function fetchPage(url: string, token: string) {
  const res = await fetch(url, { headers: { Authorization: `Bearer ${token}` }, cache: "no-store" });
  if (!res.ok) throw new Error(formatXApiError(res.status, await res.text()));
  return (await res.json()) as BookmarkResponse;
}

function applyBaseQueryParams(url: URL) {
  url.searchParams.set("tweet.fields", "created_at,lang,public_metrics,entities,author_id,attachments");
  url.searchParams.set("expansions", "author_id,attachments.media_keys");
  url.searchParams.set("user.fields", "name,username");
  url.searchParams.set("media.fields", "alt_text,type,variants,duration_ms,preview_image_url");
}

function filterNewItems<T extends { id: string }>(items: T[], stopBeforeIds: Set<string> | undefined, skipExisting: boolean, remaining: number) {
  const result: T[] = [];
  let stopped = false;
  for (const item of items) {
    if (result.length >= remaining) break;
    if (stopBeforeIds?.has(item.id)) {
      if (skipExisting) continue;
      stopped = true;
      break;
    }
    result.push(item);
  }
  return { result, stopped };
}

async function processFolderPage(apiBase: string, token: string, json: BookmarkResponse, folderId: string, folderName: string | undefined, options: any, remaining: number) {
  const rawIds = (json.data ?? []).map(i => i.id).filter(Boolean) as string[];
  const { result: newIds, stopped } = filterNewItems(rawIds.map(id => ({ id })), options.stopBeforeIds, options.skipExisting, remaining);
  if (newIds.length === 0) return { items: [], stopped, pages: 1, pageIds: rawIds };
  const hydrated = await lookupTweetsByIds({ apiBase, token, ids: newIds.map(i => i.id), folderId, folderName });
  return { items: hydrated, stopped, pages: 2, pageIds: rawIds };
}

async function processStandardPage(json: BookmarkResponse, folderId: string | undefined, folderName: string | undefined, options: any, remaining: number) {
  const mapped = mapBookmarkItemsFromResponse({ json, folderId, folderName });
  const { result: newItems, stopped } = filterNewItems(mapped, options.stopBeforeIds, options.skipExisting, remaining);
  return { items: newItems, stopped, pages: 1 };
}

export async function fetchBookmarksWithMeta(options: FetchOptions = {}) {
  const { token, userId, apiBase } = await getAuthContext();
  const { maxPages = 50, maxTotal, folderId, folderName } = options;
  const allItems: BookmarkItem[] = [];
  const membershipIds: string[] = [];
  let nextToken: string | undefined;
  let remaining = maxTotal ?? Number.POSITIVE_INFINITY;
  let pagesFetched = 0;
  let stoppedAtExisting = false;

  for (let page = 0; page < maxPages; page++) {
    if (remaining <= 0 || stoppedAtExisting) break;
    const url = buildBookmarkUrl(apiBase, userId, folderId);
    
    if (!folderId) {
      // Global bookmarks list supports hydration fields and max_results
      applyBaseQueryParams(url);
      url.searchParams.set("max_results", String(Math.min(100, remaining)));
    }
    // Folder-specific bookmarks endpoint ONLY returns IDs and DOES NOT support hydration fields or max_results.
    // We hydrate them later in lookupTweetsByIds.
    
    if (nextToken) url.searchParams.set("pagination_token", nextToken);

    const json = await fetchPage(url.toString(), token);
    const pageResult = folderId 
      ? await processFolderPage(apiBase, token, json, folderId, folderName, options, remaining)
      : await processStandardPage(json, folderId, folderName, options, remaining);
    
    if (folderId && "pageIds" in pageResult && pageResult.pageIds) {
      membershipIds.push(...pageResult.pageIds);
    }

    allItems.push(...pageResult.items);
    remaining -= pageResult.items.length;
    pagesFetched += pageResult.pages;
    stoppedAtExisting = pageResult.stopped;
    nextToken = json.meta?.next_token;
    if (!nextToken) break;
  }
  return { items: allItems, pagesFetched, stoppedAtExisting, membershipIds };
}

export async function fetchBookmarks(options: FetchOptions = {}) {
  return (await fetchBookmarksWithMeta(options)).items;
}

/**
 * Walk an X bookmark folder: list all member IDs (cheap), and only hydrate tweets that are
 * not yet in `knownIds`. Callers can UPDATE folderId for known IDs without tweet re-reads.
 */
export async function fetchFolderDelta(options: {
  folderId: string;
  folderName?: string;
  knownIds: Set<string>;
  /** Cap on newly hydrated tweets only; membership IDs are always fully listed. */
  maxNew?: number;
  maxPages?: number;
}) {
  const { token, userId, apiBase } = await getAuthContext();
  const maxPages = options.maxPages ?? 50;
  let hydrateBudget = options.maxNew ?? Number.POSITIVE_INFINITY;
  const membershipIds: string[] = [];
  const newItems: BookmarkItem[] = [];
  let nextToken: string | undefined;
  let pagesFetched = 0;

  for (let page = 0; page < maxPages; page++) {
    const url = buildBookmarkUrl(apiBase, userId, options.folderId);
    if (nextToken) url.searchParams.set("pagination_token", nextToken);

    const json = await fetchPage(url.toString(), token);
    pagesFetched += 1;
    const rawIds = (json.data ?? []).map((i) => i.id).filter(Boolean) as string[];
    membershipIds.push(...rawIds);

    const unknownIds = rawIds.filter((id) => !options.knownIds.has(id));
    if (unknownIds.length > 0 && hydrateBudget > 0) {
      const batch = unknownIds.slice(0, Math.min(unknownIds.length, hydrateBudget, 100));
      if (batch.length > 0) {
        const hydrated = await lookupTweetsByIds({
          apiBase,
          token,
          ids: batch,
          folderId: options.folderId,
          folderName: options.folderName,
        });
        newItems.push(...hydrated);
        hydrateBudget -= batch.length;
        pagesFetched += 1;
      }
    }

    nextToken = json.meta?.next_token;
    if (!nextToken) break;
  }

  return { newItems, membershipIds, pagesFetched };
}

export async function fetchBookmarkFolders() {
  const { token, userId, apiBase } = await getAuthContext();
  const url = new URL(`${apiBase}/users/${userId}/bookmarks/folders`);
  const res = await fetch(url, { headers: { Authorization: `Bearer ${token}` }, cache: "no-store" });
  if (!res.ok) throw new Error(formatXApiError(res.status, await res.text()));
  return ((await res.json()) as { data?: Array<{ id: string; name?: string }> }).data ?? [];
}

type XUsageResponse = {
  data?: { balance?: number; remaining_balance?: number; credits?: number; tweet_count?: number; used_tweets?: number; usage?: number; cap_per_month?: number; monthly_limit?: number; limit?: number; cost_per_tweet?: number; price_per_tweet?: number; rate?: number; };
  balance?: number; price?: number;
};

function extractUsageStats(resJson: XUsageResponse) {
  const data = (resJson.data || resJson) as Record<string, any>;
  const balance = (resJson.data ? resJson.data.balance : resJson.balance) ?? data.remaining_balance ?? data.credits;
  const tweet_count = data.tweet_count ?? data.used_tweets ?? data.usage;
  const cap_per_month = data.cap_per_month ?? data.monthly_limit ?? data.limit;
  const cost_per_unit = data.cost_per_tweet ?? data.price_per_tweet ?? data.rate ?? resJson.price;
  return { cap_per_month: cap_per_month?.toString(), tweet_count: tweet_count?.toString(), balance: balance, cost_per_unit: cost_per_unit };
}

export async function fetchXUsage() {
  const { token, apiBase } = await getAuthContext();
  const paths = ["/usage/tweets", "/usage", "/user/usage"];
  for (const path of paths) {
    try {
      const res = await fetch(`${apiBase}${path}`, { headers: { Authorization: `Bearer ${token}` }, cache: "no-store" });
      if (res.ok) return { data: extractUsageStats((await res.json()) as XUsageResponse) };
    } catch { continue; }
  }
  return null;
}

export { X_OAUTH_REQUIRED_MESSAGE, X_CLIENT_ENROLLMENT_MESSAGE, formatXApiError };
