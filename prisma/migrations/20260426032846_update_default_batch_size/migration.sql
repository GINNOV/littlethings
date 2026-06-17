-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Settings" (
    "id" TEXT NOT NULL PRIMARY KEY DEFAULT 'default',
    "xBearerToken" TEXT,
    "xUserId" TEXT,
    "xApiBase" TEXT,
    "xClientId" TEXT,
    "xClientSecret" TEXT,
    "xRedirectUri" TEXT,
    "xAccessToken" TEXT,
    "xRefreshToken" TEXT,
    "xTokenExpiresAt" DATETIME,
    "xScope" TEXT,
    "xTokenType" TEXT,
    "ytClientId" TEXT,
    "ytClientSecret" TEXT,
    "ytRedirectUri" TEXT,
    "ytAccessToken" TEXT,
    "ytRefreshToken" TEXT,
    "ytTokenExpiresAt" DATETIME,
    "ytScope" TEXT,
    "ytTokenType" TEXT,
    "llmBaseUrl" TEXT,
    "llmApiKey" TEXT,
    "llmModel" TEXT,
    "llmPrompt" TEXT,
    "monthlyCap" INTEGER NOT NULL DEFAULT 100,
    "ytMonthlyCap" INTEGER NOT NULL DEFAULT 100,
    "enrichBatchSize" INTEGER NOT NULL DEFAULT 50,
    "llmConcurrency" INTEGER NOT NULL DEFAULT 2,
    "llmMaxTokens" INTEGER NOT NULL DEFAULT 4000,
    "targetLanguage" TEXT NOT NULL DEFAULT 'English',
    "logLlmPayloads" BOOLEAN NOT NULL DEFAULT true,
    "soundOnComplete" BOOLEAN NOT NULL DEFAULT false,
    "soundOnError" BOOLEAN NOT NULL DEFAULT false,
    "lastBookmarkId" TEXT,
    "lastSyncedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Settings" ("createdAt", "enrichBatchSize", "id", "lastBookmarkId", "lastSyncedAt", "llmApiKey", "llmBaseUrl", "llmConcurrency", "llmMaxTokens", "llmModel", "llmPrompt", "logLlmPayloads", "monthlyCap", "soundOnComplete", "soundOnError", "targetLanguage", "updatedAt", "xAccessToken", "xApiBase", "xBearerToken", "xClientId", "xClientSecret", "xRedirectUri", "xRefreshToken", "xScope", "xTokenExpiresAt", "xTokenType", "xUserId", "ytAccessToken", "ytClientId", "ytClientSecret", "ytMonthlyCap", "ytRedirectUri", "ytRefreshToken", "ytScope", "ytTokenExpiresAt", "ytTokenType") SELECT "createdAt", "enrichBatchSize", "id", "lastBookmarkId", "lastSyncedAt", "llmApiKey", "llmBaseUrl", "llmConcurrency", "llmMaxTokens", "llmModel", "llmPrompt", "logLlmPayloads", "monthlyCap", "soundOnComplete", "soundOnError", "targetLanguage", "updatedAt", "xAccessToken", "xApiBase", "xBearerToken", "xClientId", "xClientSecret", "xRedirectUri", "xRefreshToken", "xScope", "xTokenExpiresAt", "xTokenType", "xUserId", "ytAccessToken", "ytClientId", "ytClientSecret", "ytMonthlyCap", "ytRedirectUri", "ytRefreshToken", "ytScope", "ytTokenExpiresAt", "ytTokenType" FROM "Settings";
DROP TABLE "Settings";
ALTER TABLE "new_Settings" RENAME TO "Settings";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
