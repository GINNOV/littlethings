-- CreateTable
CREATE TABLE "BookmarkFolder" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Bookmark" (
    "id" TEXT NOT NULL PRIMARY KEY,
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
    CONSTRAINT "Bookmark_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES "BookmarkFolder" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Bookmark" ("authorName", "authorUsername", "category", "createdAt", "externalUrls", "id", "importedAt", "lang", "likeCount", "quoteCount", "rawJson", "replyCount", "retweetCount", "summarizedAt", "summary", "tags", "text", "tweetUrl") SELECT "authorName", "authorUsername", "category", "createdAt", "externalUrls", "id", "importedAt", "lang", "likeCount", "quoteCount", "rawJson", "replyCount", "retweetCount", "summarizedAt", "summary", "tags", "text", "tweetUrl" FROM "Bookmark";
DROP TABLE "Bookmark";
ALTER TABLE "new_Bookmark" RENAME TO "Bookmark";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
