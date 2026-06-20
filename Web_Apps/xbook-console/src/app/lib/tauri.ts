export async function openExternalUrl(url: string) {
  if (typeof window !== "undefined" && (window as any).__TAURI_INTERNALS__) {
    try {
      // Dynamically import to avoid errors during server-side rendering or on web
      const { invoke } = await import("@tauri-apps/api/core");
      // If the URL is relative (e.g. starting with /), construct an absolute URL to the local server
      const absoluteUrl = url.startsWith("/") ? `http://localhost:3000${url}` : url;
      console.log(`[Tauri] Opening external URL via Rust: ${absoluteUrl}`);
      await invoke("open_in_browser", { url: absoluteUrl });
    } catch (e) {
      console.error("[Tauri] Failed to open URL via Rust, falling back to window.location:", e);
      window.location.href = url;
    }
  } else {
    window.location.href = url;
  }
}
