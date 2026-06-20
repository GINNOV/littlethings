import { NextResponse } from "next/server";
import { z } from "zod";
import OpenAI from "openai";
import { getSettings } from "@/lib/settings";
import { X_OAUTH_REQUIRED_MESSAGE, formatXApiError } from "@/lib/x";

const schema = z.object({
  type: z.enum(["x", "yt", "llm"]),
  xBearerToken: z.string().optional().nullable(),
  xUserId: z.string().optional().nullable(),
  xApiBase: z.string().optional().nullable(),
  xAccessToken: z.string().optional().nullable(),
  ytAccessToken: z.string().optional().nullable(),
  llmBaseUrl: z.string().optional().nullable(),
  llmApiKey: z.string().optional().nullable(),
  llmModel: z.string().optional().nullable(),
  llmMaxTokens: z.coerce.number().int().optional().nullable(),
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

  const data = parsed.data;
  const settings = await getSettings();

  try {
    if (data.type === "x") {
      const accessToken = data.xAccessToken || settings.xAccessToken;
      const bearerToken = data.xBearerToken || settings.xBearerToken;
      const userId = data.xUserId || settings.xUserId;
      const apiBase = data.xApiBase || settings.xApiBase || "https://api.x.com/2";

      if (!accessToken && bearerToken) {
        return NextResponse.json(
          { ok: false, error: X_OAUTH_REQUIRED_MESSAGE },
          { status: 400 }
        );
      }

      if (!accessToken || !userId) {
        return NextResponse.json(
          { ok: false, error: "Missing X OAuth access token or user ID." },
          { status: 400 }
        );
      }

      const url = new URL(`${apiBase}/users/${userId}`);
      url.searchParams.set("user.fields", "id,name,username");

      const res = await fetch(url, {
        headers: { Authorization: `Bearer ${accessToken}` },
      });

      if (!res.ok) {
        const text = await res.text();
        return NextResponse.json(
          { ok: false, error: formatXApiError(res.status, text) },
          { status: 400 }
        );
      }

      const json = (await res.json()) as {
        data?: { id?: string; name?: string; username?: string };
      };

      return NextResponse.json({
        ok: true,
        message: `Connected as ${json.data?.username ?? "user"}.`,
      });
    }

    if (data.type === "yt") {
      const token = data.ytAccessToken || settings.ytAccessToken;
      if (!token) {
        return NextResponse.json(
          { ok: false, error: "Missing YouTube access token." },
          { status: 400 }
        );
      }
      const res = await fetch(
        "https://www.googleapis.com/youtube/v3/channels?part=snippet&mine=true&maxResults=1",
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      if (!res.ok) {
        const text = await res.text();
        return NextResponse.json(
          { ok: false, error: `YouTube API error ${res.status}: ${text}` },
          { status: 400 }
        );
      }
      const json = (await res.json()) as {
        items?: Array<{ snippet?: { title?: string } }>;
      };
      return NextResponse.json({
        ok: true,
        message: `Connected as ${json.items?.[0]?.snippet?.title ?? "YouTube account"}.`,
      });
    }

    const model = data.llmModel || settings.llmModel;
    if (!model) {
      return NextResponse.json(
        { ok: false, error: "Missing LLM model." },
        { status: 400 }
      );
    }

    const baseUrl = (data.llmBaseUrl?.trim() || settings.llmBaseUrl || "http://localhost:1234/v1").replace(/\/+$/, "");
    const apiKey = data.llmApiKey?.trim() || settings.llmApiKey || "lm-studio";

    const client = new OpenAI({
      apiKey,
      baseURL: baseUrl,
      timeout: 10000, // 10s timeout for tests
    });

    try {
      const completion = await client.chat.completions.create({
        model,
        messages: [{ role: "user", content: "Reply with: ok" }],
        temperature: 0,
        max_tokens: data.llmMaxTokens || settings.llmMaxTokens || 10,
      });

      const content = completion.choices[0]?.message?.content ?? "";
      return NextResponse.json({
        ok: true,
        message: content.trim() ? `LLM responded: ${content.trim()}` : "LLM responded.",
      });
    } catch (apiError: any) {
      let friendlyError = apiError.message;
      if (apiError.code === "ECONNREFUSED") {
        friendlyError = `Connection refused at ${baseUrl}. Is your model server (LM Studio/Ollama) running and is the 'CORS' or 'Server' enabled?`;
      } else if (apiError.name === "AbortError" || apiError.name === "TimeoutError") {
        friendlyError = `Connection to ${baseUrl} timed out. Check if the URL is correct and the server is accessible.`;
      } else if (apiError.status === 404) {
        friendlyError = `Server at ${baseUrl} returned 404. If you are using Ollama, make sure you are using the '/v1' suffix (e.g. http://127.0.0.1:11434/v1).`;
      }
      return NextResponse.json({ ok: false, error: friendlyError }, { status: 400 });
    }
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Test failed" },
      { status: 500 }
    );
  }
}
