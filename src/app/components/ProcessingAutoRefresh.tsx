"use client";

import { useEffect, useRef, useTransition } from "react";
import { useRouter } from "next/navigation";

type Props = {
  enabled: boolean;
};

export default function ProcessingAutoRefresh({
  enabled,
}: Props) {
  const router = useRouter();
  const [, startTransition] = useTransition();
  const eventSourceRef = useRef<EventSource | null>(null);
  const lastRefreshRef = useRef<number>(0);

  useEffect(() => {
    if (!enabled) {
      if (eventSourceRef.current) {
        eventSourceRef.current.close();
        eventSourceRef.current = null;
      }
      return;
    }

    const connect = () => {
      if (eventSourceRef.current) return;

      const es = new EventSource("/api/processing/events");
      eventSourceRef.current = es;

      const handleUpdate = () => {
        const now = Date.now();
        // Debounce refresh to at most once per 2 seconds
        if (now - lastRefreshRef.current > 2000) {
          lastRefreshRef.current = now;
          startTransition(() => {
            router.refresh();
          });
        }
      };

      es.addEventListener("run_updated", handleUpdate);
      es.addEventListener("event_logged", handleUpdate);
      es.addEventListener("run_created", handleUpdate);

      es.onerror = () => {
        es.close();
        eventSourceRef.current = null;
        // Retry after 5s
        setTimeout(connect, 5000);
      };
    };

    connect();

    return () => {
      if (eventSourceRef.current) {
        eventSourceRef.current.close();
        eventSourceRef.current = null;
      }
    };
  }, [enabled, router]);

  return null;
}
