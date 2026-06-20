import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSettings } from "@/lib/settings";
import {
  generateCodeChallenge,
  generateCodeVerifier,
  generateState,
} from "@/lib/pkce";

const DEFAULT_SCOPE = ["https://www.googleapis.com/auth/youtube.readonly"];

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const settings = await getSettings();
    const origin = new URL(request.url).origin;
    
    // We use settings from the database OR the ones provided in the form body
    const clientId = body.ytClientId || settings.ytClientId || process.env.YT_CLIENT_ID;
    const redirectUri =
      body.ytRedirectUri ||
      settings.ytRedirectUri ||
      process.env.YT_REDIRECT_URI ||
      `${origin}/api/oauth/youtube/callback`;

    if (!clientId) {
      return NextResponse.json({ ok: false, error: "Missing YouTube client ID." }, { status: 400 });
    }

    const state = generateState();
    const codeVerifier = generateCodeVerifier();
    const codeChallenge = generateCodeChallenge(codeVerifier);

    await prisma.oAuthSession.create({
      data: { state, codeVerifier },
    });

    const authUrl = new URL("https://accounts.google.com/o/oauth2/v2/auth");
    authUrl.searchParams.set("response_type", "code");
    authUrl.searchParams.set("client_id", clientId);
    authUrl.searchParams.set("redirect_uri", redirectUri);
    authUrl.searchParams.set("scope", DEFAULT_SCOPE.join(" "));
    authUrl.searchParams.set("state", state);
    authUrl.searchParams.set("code_challenge", codeChallenge);
    authUrl.searchParams.set("code_challenge_method", "S256");
    authUrl.searchParams.set("access_type", "offline");
    authUrl.searchParams.set("prompt", "consent");

    return NextResponse.json({ ok: true, url: authUrl.toString() });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Failed to generate URL" },
      { status: 500 }
    );
  }
}
