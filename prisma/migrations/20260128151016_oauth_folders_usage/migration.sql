-- CreateTable
CREATE TABLE "OAuthSession" (
    "state" TEXT NOT NULL PRIMARY KEY,
    "codeVerifier" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "UsageMonth" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "month" TEXT NOT NULL,
    "usedBookmarks" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" DATETIME NOT NULL
);

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
    "monthlyCap" INTEGER NOT NULL DEFAULT 100,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Settings" ("createdAt", "id", "llmApiKey", "llmBaseUrl", "llmModel", "updatedAt", "xApiBase", "xBearerToken", "xUserId") SELECT "createdAt", "id", "llmApiKey", "llmBaseUrl", "llmModel", "updatedAt", "xApiBase", "xBearerToken", "xUserId" FROM "Settings";
DROP TABLE "Settings";
ALTER TABLE "new_Settings" RENAME TO "Settings";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
