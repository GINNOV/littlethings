import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSettings, updateSettings } from "@/lib/settings";

const GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const origin = url.origin;
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const error = url.searchParams.get("error");

  if (error) {
    const redirect = new URL("/settings", origin);
    redirect.searchParams.set("error", error);
    return NextResponse.redirect(redirect);
  }

  if (!code || !state) {
    return NextResponse.json({ ok: false, error: "Missing code/state" }, { status: 400 });
  }

  const session = await prisma.oAuthSession.findUnique({ where: { state } });
  if (!session) {
    return NextResponse.json({ ok: false, error: "Invalid state" }, { status: 400 });
  }

  const settings = await getSettings();
  const clientId = settings.ytClientId ?? process.env.YT_CLIENT_ID;
  const clientSecret = settings.ytClientSecret ?? process.env.YT_CLIENT_SECRET;
  const redirectUri =
    settings.ytRedirectUri ??
    process.env.YT_REDIRECT_URI ??
    `${origin}/api/oauth/youtube/callback`;

  if (!clientId || !clientSecret) {
    await prisma.oAuthSession.delete({ where: { state } });
    return NextResponse.json(
      { ok: false, error: "Missing YouTube client ID/client secret." },
      { status: 400 }
    );
  }

  const body = new URLSearchParams({
    code,
    client_id: clientId,
    client_secret: clientSecret,
    redirect_uri: redirectUri,
    grant_type: "authorization_code",
    code_verifier: session.codeVerifier,
  });

  const tokenRes = await fetch(GOOGLE_TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });

  if (!tokenRes.ok) {
    const text = await tokenRes.text();
    await prisma.oAuthSession.delete({ where: { state } });
    return NextResponse.json(
      { ok: false, error: `Token exchange failed: ${text}` },
      { status: 400 }
    );
  }

  const tokenJson = (await tokenRes.json()) as {
    access_token?: string;
    refresh_token?: string;
    expires_in?: number;
    scope?: string;
    token_type?: string;
  };

  const expiresAt = tokenJson.expires_in
    ? new Date(Date.now() + tokenJson.expires_in * 1000)
    : null;

  await updateSettings({
    ytAccessToken: tokenJson.access_token ?? null,
    ytRefreshToken: tokenJson.refresh_token ?? null,
    ytTokenExpiresAt: expiresAt,
    ytScope: tokenJson.scope ?? null,
    ytTokenType: tokenJson.token_type ?? null,
  });

  await prisma.oAuthSession.delete({ where: { state } });

  const redirect = new URL("/settings", origin);
  redirect.searchParams.set("oauth", "youtube_success");
  return NextResponse.redirect(redirect);
}
