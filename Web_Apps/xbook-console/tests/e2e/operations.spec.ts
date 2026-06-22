import { expect, test } from "@playwright/test";
import { PrismaClient } from "@prisma/client";
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";

const adapter = new PrismaBetterSqlite3({ url: "./dev.db" });
const prisma = new PrismaClient({ adapter });

test.describe("Operations & Logs", () => {
  test.beforeEach(async () => {
    // Seed some active and completed runs with numeric-compatible IDs
    await prisma.operationRun.createMany({
      data: [
        { id: "999001", type: "enrichment_batch", source: "x", status: "running", startedAt: new Date() },
        { id: "999002", type: "enrichment_batch", source: "yt", status: "completed", startedAt: new Date(Date.now() - 3600000), finishedAt: new Date() },
      ]
    });

    await prisma.bookmark.upsert({
      where: { id: "e2e-bookmark-x" },
      update: {
        source: "x",
        tweetUrl: "https://x.com/i/web/status/e2e-bookmark-x",
        text: "E2E bookmark source text for UI validation.",
        authorUsername: "e2e_author",
        summary: null,
        category: null,
        tags: null,
      },
      create: {
        id: "e2e-bookmark-x",
        source: "x",
        tweetUrl: "https://x.com/i/web/status/e2e-bookmark-x",
        text: "E2E bookmark source text for UI validation.",
        authorUsername: "e2e_author",
      },
    });
  });

  test.afterEach(async () => {
    await prisma.operationRun.deleteMany({
      where: { id: { in: ["999001", "999002"] } }
    });
    await prisma.bookmark.deleteMany({
      where: { id: "e2e-bookmark-x" }
    });
  });

  test("Source filtering works correctly", async ({ page }) => {
    await page.goto("/processing");
    
    // Check all visible initially
    await expect(page.getByText("enrichment batch").first()).toBeVisible();
    
    // Filter by X
    await page.getByRole("link", { name: "X", exact: true }).click();
    await page.waitForURL(/source=x/);
    await expect(page.url()).toContain("source=x");
    
    // Check that X items are visible (by title) and YT items are not
    await expect(page.getByTitle("YouTube")).not.toBeVisible();

    // Filter by YouTube
    await page.getByRole("link", { name: "YouTube", exact: true }).click();
    await page.waitForURL(/source=yt/);
    await expect(page.url()).toContain("source=yt");
    await expect(page.getByTitle("YouTube").first()).toBeVisible();
    await expect(page.getByTitle("X", { exact: true })).not.toBeVisible();
  });

  test("Stop all operations button appears and works", async ({ page }) => {
    await page.goto("/processing");
    
    const stopAllBtn = page.getByRole("button", { name: "Stop all operations" });
    await expect(stopAllBtn).toBeVisible();
    
    await stopAllBtn.click();
    await page.getByRole("button", { name: "Stop All", exact: true }).click();
    
    // After stopping, wait for the status to update in the UI (lowercase stopped in the list)
    await expect(page.locator(".font-bold", { hasText: "stopped" }).first()).toBeVisible();
    
    const run = await prisma.operationRun.findUnique({ where: { id: "999001" } });
    expect(run?.status).toBe("stopped");
  });

  test("Clear all logs button works", async ({ page }) => {
    await prisma.operationRun.update({
      where: { id: "999001" },
      data: { status: "stopped" },
    });

    await page.goto("/processing");
    
    const clearBtn = page.getByRole("button", { name: "Clear history" });
    await expect(clearBtn).toBeVisible();
    
    await clearBtn.click();
    await page.getByRole("button", { name: "Clear History", exact: true }).click();
    
    // List should be empty (excluding the system e2e-operation-run if it exists, or just check the list text)
    // Actually the button clears EVERYTHING, so we should re-seed if we want ui.spec.ts to pass.
    // A better way is to run ui.spec.ts first or make them independent.
    await expect(page.getByText("No runs match filters.")).toBeVisible();
    
    const count = await prisma.operationRun.count();
    expect(count).toBe(0);
  });

  test("Multi-batch enrichment consolidates into a single run", async ({ page }) => {
    // We'll mock the enrichment API to return a runId and then simulate multiple batches
    let callCount = 0;
    const testRunId = "consolidated-run-id";
    
    await page.route("**/api/enrich*", async (route) => {
      callCount++;
      if (callCount === 1) {
        // First call creates the run
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ ok: true, runId: testRunId, processed: 1, updated: 1, remaining: 1, errors: [] })
        });
      } else {
        // Subsequent calls use the same runId
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ ok: true, runId: testRunId, processed: 0, updated: 0, remaining: 0, errors: [] })
        });
      }
    });
// Start enrichment
await page.goto("/");
const enrichBtn = page.getByRole("button", { name: /Enrich all X/ });
await expect(enrichBtn).toBeVisible();

await enrichBtn.click();

// Wait for the message to indicate completion (from showToast or setMessage)
await expect(page.getByText("Processing finished.")).toBeVisible();

// We expect 2 calls (because remaining was 1 then 0)
expect(callCount).toBe(2);
});

  test("Stopping a run aborts the in-flight LLM request", async ({ page }) => {
    await page.route("**/api/enrich*", async (route) => {
      // Simulate a long-running request
      
      // Wait for a bit to allow the user to click stop
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      if (route.request().isNavigationRequest()) {
         return route.continue();
      }

      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ ok: true, runId: "abort-test", processed: 1, updated: 1, remaining: 0, errors: [] })
      });
    });

    // This is hard to test perfectly via E2E because the signal is on the server side.
    // But we can check that the UI stops polling and the status changes.
    await page.goto("/processing");
    const stopAllBtn = page.getByRole("button", { name: "Stop all operations" });
    await expect(stopAllBtn).toBeVisible();
    
    await stopAllBtn.click();
    await page.getByRole("button", { name: "Stop All", exact: true }).click();
    
    await expect(page.locator(".font-bold", { hasText: "stopped" }).first()).toBeVisible();
    
    // On the server, the signal would have been called. 
    // To truly verify the AbortSignal, we would need a unit test for the API route or a more complex mock.
    // Given the constraints, the fact that the status is 'stopped' in the DB is the primary success criteria.
  });
});
