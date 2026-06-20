-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Bookmark" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "source" TEXT NOT NULL DEFAULT 'x',
    "tweetUrl" TEXT NOT NULL,
    "text" TEXT,
    "authorName" TEXT,
    "authorUsername" TEXT,
    "createdAt" DATETIME,
    "likeCount" INTEGER,
    "replyCount" INTEGER,
    "retweetCount" INTEGER,
    "quoteCount" INTEGER,
    "lang" TEXT,
    "externalUrls" TEXT,
    "summary" TEXT,
    "category" TEXT,
    "tags" TEXT,
    "rawJson" TEXT,
    "folderId" TEXT,
    "importedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "summarizedAt" DATETIME,
    "editedAt" DATETIME,
    "readAt" DATETIME,
    CONSTRAINT "Bookmark_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES "BookmarkFolder" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Bookmark" ("authorName", "authorUsername", "category", "createdAt", "editedAt", "externalUrls", "folderId", "id", "importedAt", "lang", "likeCount", "quoteCount", "rawJson", "readAt", "replyCount", "retweetCount", "summarizedAt", "summary", "tags", "text", "tweetUrl") SELECT "authorName", "authorUsername", "category", "createdAt", "editedAt", "externalUrls", "folderId", "id", "importedAt", "lang", "likeCount", "quoteCount", "rawJson", "readAt", "replyCount", "retweetCount", "summarizedAt", "summary", "tags", "text", "tweetUrl" FROM "Bookmark";
DROP TABLE "Bookmark";
ALTER TABLE "new_Bookmark" RENAME TO "Bookmark";
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
    "enrichBatchSize" INTEGER NOT NULL DEFAULT 25,
    "lastBookmarkId" TEXT,
    "lastSyncedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_Settings" ("createdAt", "enrichBatchSize", "id", "lastBookmarkId", "lastSyncedAt", "llmApiKey", "llmBaseUrl", "llmModel", "llmPrompt", "monthlyCap", "updatedAt", "xAccessToken", "xApiBase", "xBearerToken", "xClientId", "xClientSecret", "xRedirectUri", "xRefreshToken", "xScope", "xTokenExpiresAt", "xTokenType", "xUserId") SELECT "createdAt", "enrichBatchSize", "id", "lastBookmarkId", "lastSyncedAt", "llmApiKey", "llmBaseUrl", "llmModel", "llmPrompt", "monthlyCap", "updatedAt", "xAccessToken", "xApiBase", "xBearerToken", "xClientId", "xClientSecret", "xRedirectUri", "xRefreshToken", "xScope", "xTokenExpiresAt", "xTokenType", "xUserId" FROM "Settings";
DROP TABLE "Settings";
ALTER TABLE "new_Settings" RENAME TO "Settings";
CREATE TABLE "new_UsageMonth" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "month" TEXT NOT NULL,
    "source" TEXT NOT NULL DEFAULT 'x',
    "usedBookmarks" INTEGER NOT NULL DEFAULT 0,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_UsageMonth" ("id", "month", "updatedAt", "usedBookmarks") SELECT "id", "month", "updatedAt", "usedBookmarks" FROM "UsageMonth";
DROP TABLE "UsageMonth";
ALTER TABLE "new_UsageMonth" RENAME TO "UsageMonth";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
