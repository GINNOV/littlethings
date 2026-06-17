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
    "mediaDescription" TEXT,
    "mediaJson" TEXT,
    "embedding" BLOB,
    "enrichmentError" TEXT,
    "enrichmentFailures" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "Bookmark_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES "BookmarkFolder" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_Bookmark" ("authorName", "authorUsername", "category", "createdAt", "editedAt", "embedding", "externalUrls", "folderId", "id", "importedAt", "lang", "likeCount", "mediaDescription", "mediaJson", "quoteCount", "rawJson", "readAt", "replyCount", "retweetCount", "source", "summarizedAt", "summary", "tags", "text", "tweetUrl") SELECT "authorName", "authorUsername", "category", "createdAt", "editedAt", "embedding", "externalUrls", "folderId", "id", "importedAt", "lang", "likeCount", "mediaDescription", "mediaJson", "quoteCount", "rawJson", "readAt", "replyCount", "retweetCount", "source", "summarizedAt", "summary", "tags", "text", "tweetUrl" FROM "Bookmark";
DROP TABLE "Bookmark";
ALTER TABLE "new_Bookmark" RENAME TO "Bookmark";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
