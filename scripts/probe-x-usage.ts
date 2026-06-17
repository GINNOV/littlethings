import { PrismaClient } from "@prisma/client";
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";

const adapter = new PrismaBetterSqlite3({ url: "dev.db" });
const prisma = new PrismaClient({ adapter });

async function main() {
  const settings = await prisma.settings.findUnique({ where: { id: "default" } });
  if (!settings) throw new Error("No settings found");

  const apiBase = settings.xApiBase || "https://api.x.com/2";
  const token = settings.xAccessToken;

  console.log(`Checking API Base: ${apiBase}`);
  
  if (!token) {
    console.log("No access token found in database.");
    return;
  }

  const paths = ["/usage/tweets", "/usage", "/me"];
  
  for (const path of paths) {
    console.log(`\nProbing path: ${path}`);
    try {
      const res = await fetch(`${apiBase}${path}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log(`Status: ${res.status}`);
      const json = await res.json();
      console.log("Response:", JSON.stringify(json, null, 2));
    } catch (e) {
      console.log(`Failed to probe ${path}:`, e instanceof Error ? e.message : e);
    }
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
