-- AlterTable
ALTER TABLE "Settings" ADD COLUMN "logLlmPayloads" BOOLEAN NOT NULL DEFAULT true;

-- CreateTable
CREATE TABLE "OperationRun" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "type" TEXT NOT NULL,
    "source" TEXT,
    "status" TEXT NOT NULL DEFAULT 'queued',
    "total" INTEGER NOT NULL DEFAULT 0,
    "processed" INTEGER NOT NULL DEFAULT 0,
    "updated" INTEGER NOT NULL DEFAULT 0,
    "failed" INTEGER NOT NULL DEFAULT 0,
    "skipped" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT,
    "startedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" DATETIME
);

-- CreateTable
CREATE TABLE "ProcessingEvent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "runId" TEXT NOT NULL,
    "bookmarkId" TEXT,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "message" TEXT,
    "metadataJson" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "ProcessingEvent_runId_fkey" FOREIGN KEY ("runId") REFERENCES "OperationRun" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "ProcessingEvent_bookmarkId_fkey" FOREIGN KEY ("bookmarkId") REFERENCES "Bookmark" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "LlmRequestLog" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "runId" TEXT,
    "bookmarkId" TEXT,
    "model" TEXT,
    "baseUrl" TEXT,
    "promptPreview" TEXT,
    "prompt" TEXT,
    "responsePreview" TEXT,
    "response" TEXT,
    "parsedJson" TEXT,
    "durationMs" INTEGER,
    "tokenUsageJson" TEXT,
    "error" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "LlmRequestLog_runId_fkey" FOREIGN KEY ("runId") REFERENCES "OperationRun" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "LlmRequestLog_bookmarkId_fkey" FOREIGN KEY ("bookmarkId") REFERENCES "Bookmark" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateIndex
CREATE INDEX "ProcessingEvent_runId_idx" ON "ProcessingEvent"("runId");

-- CreateIndex
CREATE INDEX "ProcessingEvent_bookmarkId_idx" ON "ProcessingEvent"("bookmarkId");

-- CreateIndex
CREATE INDEX "ProcessingEvent_status_idx" ON "ProcessingEvent"("status");

-- CreateIndex
CREATE INDEX "ProcessingEvent_createdAt_idx" ON "ProcessingEvent"("createdAt");

-- CreateIndex
CREATE INDEX "LlmRequestLog_runId_idx" ON "LlmRequestLog"("runId");

-- CreateIndex
CREATE INDEX "LlmRequestLog_bookmarkId_idx" ON "LlmRequestLog"("bookmarkId");

-- CreateIndex
CREATE INDEX "LlmRequestLog_createdAt_idx" ON "LlmRequestLog"("createdAt");
