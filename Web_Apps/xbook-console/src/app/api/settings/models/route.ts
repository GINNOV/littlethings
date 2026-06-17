import { NextResponse } from "next/server";
import OpenAI from "openai";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  try {
    const { baseUrl, apiKey } = await request.json();
    if (!baseUrl) return NextResponse.json({ ok: false, error: "Missing base URL" }, { status: 400 });

    const cleanBaseUrl = baseUrl.trim().replace(/\/+$/, "");
    const client = new OpenAI({
      apiKey: apiKey || "lm-studio",
      baseURL: cleanBaseUrl,
      timeout: 5000,
    });

    const response = await client.models.list();
    const models = response.data.map((m) => m.id);

    return NextResponse.json({ ok: true, models });
  } catch (error: any) {
    let friendlyError = error.message;
    if (error.code === "ECONNREFUSED") {
      friendlyError = `Connection refused. Is your model server running at the specified URL?`;
    } else if (error.status === 404) {
      friendlyError = `Server returned 404. Ensure you use the '/v1' suffix for Ollama/vLLM.`;
    }

    return NextResponse.json(
      { ok: false, error: friendlyError },
      { status: 500 }
    );
  }
}
