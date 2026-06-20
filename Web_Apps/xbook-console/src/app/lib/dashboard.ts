export function formatDateShort(date: Date | string | null) {
  if (!date) return "-";
  return new Date(date).toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export const getYouTubeTitle = (rawJson: string | null, text: string | null) => {
  try {
    const parsed = JSON.parse(rawJson ?? "{}") as {
      item?: { snippet?: { title?: string } };
    };
    const byJson = parsed.item?.snippet?.title?.trim();
    if (byJson) return byJson;
  } catch {}
  return text?.split("\n")[0]?.trim() ?? null;
};

export const getYouTubeFolder = (rawJson: string | null, folderName: string | null) => {
  if (folderName?.trim()) return folderName.trim();
  try {
    const parsed = JSON.parse(rawJson ?? "{}") as { playlistTitle?: string };
    return parsed.playlistTitle?.trim() ?? null;
  } catch {
    return null;
  }
};
