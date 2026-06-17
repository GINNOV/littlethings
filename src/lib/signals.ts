import { EventEmitter } from "events";

type SignalMap = Map<string, AbortController>;

declare global {
  var enrichmentSignals: SignalMap | undefined;
  var processingEvents: EventEmitter | undefined;
}

if (!global.enrichmentSignals) {
  global.enrichmentSignals = new Map();
}

if (!global.processingEvents) {
  global.processingEvents = new EventEmitter();
  // Increase limit for concurrent SSE connections
  global.processingEvents.setMaxListeners(100);
}

export const enrichmentSignals = global.enrichmentSignals!;
export const processingEvents = global.processingEvents!;
