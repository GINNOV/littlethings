import { describe, it, expect, vi, beforeEach } from "vitest";
import { getSettings, updateSettings } from "@/lib/settings";
import { prisma } from "@/lib/db";

vi.mock("@/lib/db", () => ({
  prisma: {
    settings: {
      upsert: vi.fn(),
    },
  },
}));

describe("settings", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should get settings", async () => {
    const mockSettings = { id: "default", monthlyCap: 100 };
    vi.mocked(prisma.settings.upsert).mockResolvedValue(mockSettings as any);

    const result = await getSettings();

    expect(prisma.settings.upsert).toHaveBeenCalledWith({
      where: { id: "default" },
      update: {},
      create: { id: "default" },
    });
    expect(result).toEqual(mockSettings);
  });

  it("should update settings and clean strings", async () => {
    const input = { xBearerToken: "  trimmed-token  ", monthlyCap: 200 };
    vi.mocked(prisma.settings.upsert).mockResolvedValue({ id: "default", ...input } as any);

    await updateSettings(input);

    expect(prisma.settings.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: "default" },
        update: expect.objectContaining({
          xBearerToken: "trimmed-token",
          monthlyCap: 200,
        }),
      })
    );
  });
});
