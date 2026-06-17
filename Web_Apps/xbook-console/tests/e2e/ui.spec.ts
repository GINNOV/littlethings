import { expect, test } from "@playwright/test";
import { PrismaClient } from "@prisma/client";
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";

const adapter = new PrismaBetterSqlite3({ url: "./dev.db" });
const prisma = new PrismaClient({ adapter });

test.beforeAll(async () => {
  await prisma.bookmarkFolder.upsert({
    where: { id: "e2e-folder-x" },
    update: { name: "E2E Research" },
    create: { id: "e2e-folder-x", name: "E2E Research" },
  });

  await prisma.bookmark.upsert({
    where: { id: "e2e-bookmark-x" },
    update: {
      source: "x",
      tweetUrl: "https://x.com/i/web/status/e2e-bookmark-x",
      text: "E2E bookmark source text for UI validation.",
      authorUsername: "e2e_author",
      folderId: "e2e-folder-x",
      summary: "A seeded bookmark used to verify the redesigned X Library.",
      category: "Testing",
      tags: "e2e,ui",
    },
    create: {
      id: "e2e-bookmark-x",
      source: "x",
      tweetUrl: "https://x.com/i/web/status/e2e-bookmark-x",
      text: "E2E bookmark source text for UI validation.",
      authorUsername: "e2e_author",
      folderId: "e2e-folder-x",
      summary: "A seeded bookmark used to verify the redesigned X Library.",
      category: "Testing",
      tags: "e2e,ui",
    },
  });

  await prisma.operationRun.upsert({
    where: { id: "e2e-operation-run" },
    update: {
      type: "enrich",
      source: "x",
      status: "completed",
      total: 1,
      processed: 1,
      updated: 1,
      failed: 0,
      notes: "Seeded processing run for UI validation.",
      finishedAt: new Date(),
    },
    create: {
      id: "e2e-operation-run",
      type: "enrich",
      source: "x",
      status: "completed",
      total: 1,
      processed: 1,
      updated: 1,
      notes: "Seeded processing run for UI validation.",
      finishedAt: new Date(),
    },
  });

  await prisma.llmRequestLog.deleteMany({
    where: { runId: "e2e-operation-run" },
  });
  await prisma.processingEvent.deleteMany({
    where: { runId: "e2e-operation-run" },
  });

  await prisma.processingEvent.create({
    data: {
      runId: "e2e-operation-run",
      bookmarkId: "e2e-bookmark-x",
      type: "llm_response",
      status: "success",
      message: "Seeded event for processing monitor.",
    },
  });

  await prisma.llmRequestLog.create({
    data: {
      runId: "e2e-operation-run",
      bookmarkId: "e2e-bookmark-x",
      model: "e2e-model",
      baseUrl: "http://localhost:1234/v1",
      promptPreview: "Summarize this seeded bookmark.",
      responsePreview: "{\"summary\":\"Seeded\"}",
      parsedJson: "{\"summary\":\"Seeded\",\"category\":\"Testing\"}",
      durationMs: 12,
    },
  });
});

test.afterAll(async () => {
  await prisma.$disconnect();
});

test("dashboard, libraries, folders, processing, and settings routes render", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "Dashboard" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Processing", exact: true })).toBeVisible();

  await page.goto("/bookmarks?source=x&q=e2e_author");
  await expect(page.getByRole("heading", { name: "Library" })).toBeVisible();
  const seededBookmark = page.getByRole("button", {
    name: /A seeded bookmark used to verify/,
  });
  await expect(seededBookmark).toBeVisible();
  await seededBookmark.click();
  await expect(page.getByRole("heading", { name: "Bookmark" })).toBeVisible();
  await expect(page.getByText("@e2e_author").last()).toBeVisible();

  await page.goto("/folders");
  await expect(page.getByRole("heading", { name: "Folder Management" })).toBeVisible();
  await expect(page.getByRole("link", { name: "X folders" })).toBeVisible();

  // Re-seed just in case another test wiped it
  await prisma.operationRun.upsert({
    where: { id: "999101" },
    update: { status: "completed", notes: "Seeded processing run for UI validation." },
    create: { id: "999101", type: "enrich", source: "x", status: "completed", notes: "Seeded processing run for UI validation." },
  });

  await prisma.processingEvent.upsert({
    where: { id: "999102" }, 
    update: { message: "Seeded event for processing monitor." },
    create: { id: "999102", runId: "999101", type: "llm_response", status: "success", message: "Seeded event for processing monitor." },
  });

  await page.goto("/processing?runId=999101");
  await expect(page.getByRole("heading", { name: /Processing/ })).toBeVisible();
  await expect(page.getByText("Seeded processing run for UI validation.").first()).toBeVisible();
  
  await expect(page.getByText("Seeded event for processing monitor.").first()).toBeVisible();

  await page.goto("/settings");
  await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();
  await expect(page.getByText("Store LLM technical logs")).toBeVisible();
  await expect(page.getByRole("button", { name: "Clear processing history" })).toBeVisible();
});
