import { XLogo, YouTubeLogo } from "../Icons";

export function SourceIcon({ source }: { source: string }) {
  return (
    <span className="flex items-center justify-center">
      {source === "yt" ? <YouTubeLogo className="h-3 w-4" /> : <XLogo className="h-3 w-3" />}
    </span>
  );
}
