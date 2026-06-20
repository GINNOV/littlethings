import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSettings, updateSettings } from "@/lib/settings";

const DEFAULT_API_BASE = "https://api.x.com/2";

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
  const clientId = settings.xClientId ?? process.env.X_CLIENT_ID;
  const clientSecret = settings.xClientSecret ?? process.env.X_CLIENT_SECRET;
  const redirectUri =
    settings.xRedirectUri ??
    process.env.X_REDIRECT_URI ??
    `${origin}/api/x/oauth/callback`;
  const apiBase = settings.xApiBase ?? process.env.X_API_BASE ?? DEFAULT_API_BASE;

  if (!clientId) {
    return NextResponse.json({ ok: false, error: "Missing client ID" }, { status: 400 });
  }

  const tokenUrl = `${apiBase}/oauth2/token`;
  const body = new URLSearchParams({
    grant_type: "authorization_code",
    code,
    client_id: clientId,
    redirect_uri: redirectUri,
    code_verifier: session.codeVerifier,
  });

  const headers: Record<string, string> = {
    "Content-Type": "application/x-www-form-urlencoded",
  };
  if (clientSecret) {
    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
    headers.Authorization = `Basic ${basic}`;
  }

  const tokenRes = await fetch(tokenUrl, {
    method: "POST",
    headers,
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
    xAccessToken: tokenJson.access_token ?? null,
    xRefreshToken: tokenJson.refresh_token ?? null,
    xTokenExpiresAt: expiresAt,
    xScope: tokenJson.scope ?? null,
    xTokenType: tokenJson.token_type ?? null,
  });

  if (tokenJson.access_token) {
    const meRes = await fetch(`${apiBase}/users/me`, {
      headers: { Authorization: `Bearer ${tokenJson.access_token}` },
    });

    if (meRes.ok) {
      const meJson = (await meRes.json()) as { data?: { id?: string } };
      if (meJson.data?.id) {
        await updateSettings({ xUserId: meJson.data.id });
      }
    }
  }

  await prisma.oAuthSession.delete({ where: { state } });

  const redirect = new URL("/settings", origin);
  redirect.searchParams.set("oauth", "success");
  return NextResponse.redirect(redirect);
}
