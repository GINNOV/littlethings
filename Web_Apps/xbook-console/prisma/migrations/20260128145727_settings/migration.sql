-- CreateTable
CREATE TABLE "Settings" (
    "id" TEXT NOT NULL PRIMARY KEY DEFAULT 'default',
    "xBearerToken" TEXT,
    "xUserId" TEXT,
    "xApiBase" TEXT,
    "llmBaseUrl" TEXT,
    "llmApiKey" TEXT,
    "llmModel" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
