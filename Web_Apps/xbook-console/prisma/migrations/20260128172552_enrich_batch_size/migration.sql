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
    "llmBaseUrl" TEXT,
    "llmApiKey" TEXT,
    "llmModel" TEXT,
    "llmPrompt" TEXT,
    "monthlyCap" INTEGER NOT NULL DEFAULT 100,
    "enrichBatchSize" INTEGER NOT NULL DEFAULT 25,
    "lastBookmarkId" TEXT,
    "lastSyncedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Settings" ("createdAt", "id", "lastBookmarkId", "lastSyncedAt", "llmApiKey", "llmBaseUrl", "llmModel", "llmPrompt", "monthlyCap", "updatedAt", "xAccessToken", "xApiBase", "xBearerToken", "xClientId", "xClientSecret", "xRedirectUri", "xRefreshToken", "xScope", "xTokenExpiresAt", "xTokenType", "xUserId") SELECT "createdAt", "id", "lastBookmarkId", "lastSyncedAt", "llmApiKey", "llmBaseUrl", "llmModel", "llmPrompt", "monthlyCap", "updatedAt", "xAccessToken", "xApiBase", "xBearerToken", "xClientId", "xClientSecret", "xRedirectUri", "xRefreshToken", "xScope", "xTokenExpiresAt", "xTokenType", "xUserId" FROM "Settings";
DROP TABLE "Settings";
ALTER TABLE "new_Settings" RENAME TO "Settings";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
