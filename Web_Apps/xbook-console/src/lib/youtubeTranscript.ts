function extractVideoId(url: string) {
  try {
    const p = new URL(url);
    if (p.hostname.includes("youtu.be")) return p.pathname.replace("/", "").trim() || null;
    return p.searchParams.get("v")?.trim() || null;
  } catch { return null; }
}

function pickCaptionTrack(tracks: Array<{ baseUrl?: string; languageCode?: string }>) {
  return tracks.find((t) => t.languageCode?.startsWith("en")) ?? tracks[0] ?? null;
}

async function fetchWithTimeout(url: string, ms = 10000) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), ms);
  try {
    return await fetch(url, {
      signal: ctrl.signal,
      headers: { "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" },
    });
  } finally { clearTimeout(t); }
}

function parsePlayer(html: string) {
  const m = html.match(/ytInitialPlayerResponse\s*=\s*(\{[\s\S]*?\});/);
  if (!m?.[1]) return null;
  try { return JSON.parse(m[1]) as any; } catch { return null; }
}

async function fetchTranscriptJson(trackUrl: string) {
  const res = await fetchWithTimeout(`${trackUrl}&fmt=json3`);
  if (!res.ok) return null;
  return (await res.json()) as { events?: Array<{ segs?: Array<{ utf8?: string }> }> };
}

function extractTextFromJson(json: any) {
  const text = (json.events ?? [])
    .flatMap((e: any) => e.segs ?? [])
    .map((s: any) => s.utf8 ?? "")
    .join(" ").replace(/\s+/g, " ").trim();
  return text ? text.slice(0, 12000) : null;
}

export async function fetchYouTubeTranscriptFromUrl(videoUrl: string) {
  const vid = extractVideoId(videoUrl);
  if (!vid) return null;
  try {
    const res = await fetchWithTimeout(`https://www.youtube.com/watch?v=${vid}`);
    if (!res.ok) return null;
    const player = parsePlayer(await res.text());
    const tracks = player?.captions?.playerCaptionsTracklistRenderer?.captionTracks ?? [];
    const track = pickCaptionTrack(tracks);
    if (!track?.baseUrl) return null;
    const json = await fetchTranscriptJson(track.baseUrl);
    return json ? extractTextFromJson(json) : null;
  } catch { return null; }
}
