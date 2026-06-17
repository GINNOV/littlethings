import { processingEvents } from "@/lib/signals";

export const dynamic = "force-dynamic";

export async function GET() {
  const encoder = new TextEncoder();
  let cleanup: (() => void) | undefined;

  const stream = new ReadableStream({
    start(controller) {
      const onRunCreated = (run: unknown) => {
        try { controller.enqueue(encoder.encode(`event: run_created\ndata: ${JSON.stringify(run)}\n\n`)); } catch { /* ignore */ }
      };
      const onRunUpdated = (run: unknown) => {
        try { controller.enqueue(encoder.encode(`event: run_updated\ndata: ${JSON.stringify(run)}\n\n`)); } catch { /* ignore */ }
      };
      const onEventLogged = (event: unknown) => {
        try { controller.enqueue(encoder.encode(`event: event_logged\ndata: ${JSON.stringify(event)}\n\n`)); } catch { /* ignore */ }
      };

      processingEvents.on("run_created", onRunCreated);
      processingEvents.on("run_updated", onRunUpdated);
      processingEvents.on("event_logged", onEventLogged);

      const interval = setInterval(() => {
        try { controller.enqueue(encoder.encode(": heartbeat\n\n")); } catch { /* ignore */ }
      }, 30000);

      cleanup = () => {
        clearInterval(interval);
        processingEvents.off("run_created", onRunCreated);
        processingEvents.off("run_updated", onRunUpdated);
        processingEvents.off("event_logged", onEventLogged);
      };
    },
    cancel() {
      if (cleanup) cleanup();
    },
  });

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    },
  });
}
