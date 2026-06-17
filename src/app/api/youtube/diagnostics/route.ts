import { NextResponse } from "next/server";
import { getSettings } from "@/lib/settings";

export const dynamic = "force-dynamic";

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
  const accessToken = settings.ytAccessToken || null;
  const refreshToken = settings.ytRefreshToken || null;
  const expiresAt = settings.ytTokenExpiresAt?.toISOString() ?? null;

  const summary = {
    hasAccessToken: Boolean(accessToken),
    hasRefreshToken: Boolean(refreshToken),
    hasClientId: Boolean(settings.ytClientId || process.env.YT_CLIENT_ID),
    hasClientSecret: Boolean(settings.ytClientSecret || process.env.YT_CLIENT_SECRET),
    tokenExpiresAt: expiresAt,
    scope: settings.ytScope ?? null,
  };

  if (!accessToken) {
    return NextResponse.json({
      ok: false,
      summary,
      error: "No YouTube OAuth access token is currently stored.",
    });
  }

  try {
    // Try to fetch channel info as a probe
    const res = await fetch(
      "https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true",
      {
        headers: { Authorization: `Bearer ${accessToken}` },
        cache: "no-store",
      }
    );

    const body = await readResponse(res);

    return NextResponse.json({
      ok: res.ok,
      summary,
      probe: {
        status: res.status,
        ok: res.ok,
        body,
      },
    });
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        summary,
        error: error instanceof Error ? error.message : "YouTube diagnostics failed",
      },
      { status: 500 }
    );
  }
}
