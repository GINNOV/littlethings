import { NextResponse } from "next/server";
import { z } from "zod";
import { getSettings } from "@/lib/settings";

const schema = z.object({
  username: z.string().min(1),
});

export async function POST(request: Request) {
  const body = await request.json();
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { ok: false, error: parsed.error.flatten() },
      { status: 400 }
    );
  }

  const settings = await getSettings();
  const token = settings.xAccessToken || settings.xBearerToken;
  const apiBase = settings.xApiBase || "https://api.x.com/2";

  if (!token) {
    return NextResponse.json(
      { ok: false, error: "Missing X access or bearer token." },
      { status: 400 }
    );
  }

  const username = parsed.data.username.replace(/^@/, "");
  const url = new URL(`${apiBase}/users/by/username/${username}`);
  url.searchParams.set("user.fields", "id,name,username");

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (!res.ok) {
    const text = await res.text();
    return NextResponse.json(
      { ok: false, error: `X API error ${res.status}: ${text}` },
      { status: 400 }
    );
  }

  const json = (await res.json()) as { data?: { id?: string; username?: string } };

  return NextResponse.json({
    ok: true,
    userId: json.data?.id ?? null,
    username: json.data?.username ?? username,
  });
}
