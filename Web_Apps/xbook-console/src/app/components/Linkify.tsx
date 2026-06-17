import React from "react";

export function Linkify({ text }: { text: string }) {
  const urlRegex = /(https?:\/\/[^\s]+)/g;
  const parts = text.split(urlRegex);

  return (
    <>
      {parts.map((part, i) => {
        if (part.match(urlRegex)) {
          return (
            <a
              key={i}
              href={part}
              target="_blank"
              rel="noreferrer"
              className="text-primary hover:underline break-all"
            >
              {part}
            </a>
          );
        }
        return part;
      })}
    </>
  );
}
