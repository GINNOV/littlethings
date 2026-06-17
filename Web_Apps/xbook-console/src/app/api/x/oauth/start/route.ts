import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSettings } from "@/lib/settings";
import {
  generateCodeChallenge,
  generateCodeVerifier,
  generateState,
} from "@/lib/pkce";

const DEFAULT_SCOPE = [
  "tweet.read",
  "users.read",
  "bookmark.read",
  "offline.access",
];

export async function GET(request: Request) {
  const settings = await getSettings();
  const origin = new URL(request.url).origin;
  const clientId = settings.xClientId ?? process.env.X_CLIENT_ID;
  const redirectUri =
    settings.xRedirectUri ??
    process.env.X_REDIRECT_URI ??
    `${origin}/api/x/oauth/callback`;

  if (!clientId) {
    const url = new URL("/settings", origin);
    url.searchParams.set("error", "missing_client_id");
    return NextResponse.redirect(url);
  }

  const state = generateState();
  const codeVerifier = generateCodeVerifier();
  const codeChallenge = generateCodeChallenge(codeVerifier);

  await prisma.oAuthSession.create({
    data: { state, codeVerifier },
  });

  const authUrl = new URL("https://x.com/i/oauth2/authorize");
  authUrl.searchParams.set("response_type", "code");
  authUrl.searchParams.set("client_id", clientId);
  authUrl.searchParams.set("redirect_uri", redirectUri);
  authUrl.searchParams.set("scope", DEFAULT_SCOPE.join(" "));
  authUrl.searchParams.set("state", state);
  authUrl.searchParams.set("code_challenge", codeChallenge);
  authUrl.searchParams.set("code_challenge_method", "S256");

  return NextResponse.redirect(authUrl);
}
