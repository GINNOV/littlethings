import { NextResponse } from "next/server";
import { getSettings } from "@/lib/settings";

const DEFAULT_API_BASE = "https://api.x.com/2";

async function readResponse(res: Response) {
  const text = await res.text();
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

export async function GET() {
  const settings = await getSettings();
  const apiBase = settings.xApiBase || DEFAULT_API_BASE;
  const accessToken = settings.xAccessToken || null;
  const fallbackUserId = settings.xUserId || null;

  const summary = {
    hasAccessToken: Boolean(accessToken),
    hasRefreshToken: Boolean(settings.xRefreshToken),
    hasBearerToken: Boolean(settings.xBearerToken),
    userId: fallbackUserId,
    tokenExpiresAt: settings.xTokenExpiresAt?.toISOString() ?? null,
    scope: settings.xScope ?? null,
    apiBase,
  };

  if (!accessToken) {
    return NextResponse.json({
      ok: false,
      summary,
      error: "No X OAuth access token is currently stored.",
    });
  }

  let resolvedUserId = fallbackUserId;
  let meResult: unknown = null;
  let bookmarksResult: unknown = null;

  try {
    const meRes = await fetch(`${apiBase}/users/me?user.fields=id,name,username`, {
      headers: { Authorization: `Bearer ${accessToken}` },
      cache: "no-store",
    });
    meResult = {
      status: meRes.status,
      ok: meRes.ok,
      body: await readResponse(meRes),
    };

    if (meRes.ok && typeof meResult === "object" && meResult && "body" in meResult) {
      const body = (meResult as { body?: { data?: { id?: string } } }).body;
      if (body?.data?.id) {
        resolvedUserId = body.data.id;
      }
    }

    if (resolvedUserId) {
      const bookmarksUrl = new URL(`${apiBase}/users/${resolvedUserId}/bookmarks`);
      bookmarksUrl.searchParams.set("max_results", "5");
      bookmarksUrl.searchParams.set("tweet.fields", "created_at");

      const bookmarksRes = await fetch(bookmarksUrl, {
        headers: { Authorization: `Bearer ${accessToken}` },
        cache: "no-store",
      });
      bookmarksResult = {
        status: bookmarksRes.status,
        ok: bookmarksRes.ok,
        body: await readResponse(bookmarksRes),
      };
    } else {
      bookmarksResult = {
        status: null,
        ok: false,
        body: "Skipped bookmark probe because no user ID could be resolved.",
      };
    }

    return NextResponse.json({
      ok:
        Boolean((meResult as { ok?: boolean } | null)?.ok) &&
        Boolean((bookmarksResult as { ok?: boolean } | null)?.ok),
      summary: {
        ...summary,
        userId: resolvedUserId,
      },
      probes: {
        me: meResult,
        bookmarks: bookmarksResult,
      },
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        summary: {
          ...summary,
          userId: resolvedUserId,
        },
        probes: {
          me: meResult,
          bookmarks: bookmarksResult,
        },
        error: error instanceof Error ? error.message : "X diagnostics failed",
      },
      { status: 500 }
    );
  }
}
