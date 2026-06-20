-- CreateTable
CREATE TABLE "Bookmark" (
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
    "importedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "summarizedAt" DATETIME
);

-- CreateTable
CREATE TABLE "ImportRun" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "startedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" DATETIME,
    "totalFetched" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT
);
