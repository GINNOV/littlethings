import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

interface FnInfo {
  name: string;
  line: number;
  complexity: number;
  coverage: number;
  crap: number;
}

interface CoverageData {
  [filePath: string]: {
    fnMap: {
      [id: string]: {
        name: string;
        line: number;
        loc: { start: { line: number }; end: { line: number } };
      };
    };
    f: { [id: string]: number };
    s: { [id: string]: number };
    statementMap: {
      [id: string]: { start: { line: number }; end: { line: number } };
    };
  };
}

function calculateCrap(cc: number, cov: number): number {
  // CRAP(f) = CC(f)^2 * (1 - Coverage(f))^3 + CC(f)
  return Math.pow(cc, 2) * Math.pow(1 - cov, 3) + cc;
}

async function main() {
  console.log("Running Vitest coverage...");
  try {
    execSync("npm run test:coverage -- --silent", { stdio: "inherit" });
  } catch {
    console.warn("Vitest finished with errors (might be expected during refactoring).");
  }

  const coveragePath = path.resolve(process.cwd(), "coverage/coverage-final.json");
  if (!fs.existsSync(coveragePath)) {
    console.error("Coverage file not found at", coveragePath);
    process.exit(1);
  }

  const coverage: CoverageData = JSON.parse(fs.readFileSync(coveragePath, "utf-8"));

  console.log("Running ESLint for complexity analysis...");
  let eslintOutput = "";
  try {
    eslintOutput = execSync(
      "npx eslint --format json --rule 'complexity: [\"error\", 1]' 'src/**/*.{ts,tsx}' --no-ignore",
      { maxBuffer: 10 * 1024 * 1024, encoding: "utf-8" }
    );
  } catch (e: unknown) {
    eslintOutput = (e as { stdout?: string }).stdout || (e as { stderr?: string }).stderr || "[]";
  }

  const eslintResults = JSON.parse(eslintOutput);
  const reports: { [file: string]: FnInfo[] } = {};

  for (const fileResult of eslintResults) {
    const filePath = fileResult.filePath;
    const relativePath = path.relative(process.cwd(), filePath);
    
    // Find matching coverage data
    const covData = coverage[filePath] || Object.values(coverage).find(v => (v as unknown as { path: string }).path === filePath);
    
    if (!covData) continue;

    reports[relativePath] = [];

    for (const msg of fileResult.messages) {
      if (msg.ruleId === "complexity") {
        const line = msg.line;
        const match = msg.message.match(/complexity of (\d+)/);
        if (!match) continue;
        const complexity = parseInt(match[1], 10);
        
        // Find function in coverage data
        // Istanbul's fnMap IDs match the keys in 'f'
        let fnCoverage = 0;
        let fnName = "anonymous";

        // Try to match by line number
        const fnId = Object.keys(covData.fnMap).find(id => {
          const info = covData.fnMap[id];
          return info.line === line || (info.loc.start.line <= line && info.loc.end.line >= line);
        });

        if (fnId) {
          const info = covData.fnMap[fnId];
          fnName = info.name;
          const hits = covData.f[fnId];
          
          // Estimate function-level coverage by checking statements within the function range
          const stmtsInFn = Object.keys(covData.statementMap).filter(sid => {
            const sinfo = covData.statementMap[sid];
            return sinfo.start.line >= info.loc.start.line && sinfo.end.line <= info.loc.end.line;
          });
          
          if (stmtsInFn.length > 0) {
            const coveredStmts = stmtsInFn.filter(sid => covData.s[sid] > 0);
            fnCoverage = coveredStmts.length / stmtsInFn.length;
          } else {
            fnCoverage = hits > 0 ? 1 : 0;
          }
        }

        const crap = calculateCrap(complexity, fnCoverage);
        reports[relativePath].push({
          name: fnName,
          line,
          complexity,
          coverage: fnCoverage,
          crap
        });
      }
    }
  }

  console.log("\nCRAP Score Report (Goal: CRAP \u2264 30)");
  console.log("---------------------------------------");
  
  let totalViolations = 0;
  
  for (const file in reports) {
    const fns = reports[file].sort((a, b) => b.crap - a.crap);
    if (fns.length === 0) continue;

    console.log(`\nFile: ${file}`);
    console.log(`${"Function".padEnd(30)} | ${"CC".padStart(4)} | ${"Cov".padStart(6)} | ${"CRAP".padStart(6)}`);
    
    for (const fn of fns) {
      const covPct = (fn.coverage * 100).toFixed(1) + "%";
      const crapStr = fn.crap.toFixed(1);
      const status = fn.crap > 30 ? " [FAIL]" : "";
      
      console.log(`${fn.name.substring(0, 30).padEnd(30)} | ${fn.complexity.toString().padStart(4)} | ${covPct.padStart(6)} | ${crapStr.padStart(6)}${status}`);
      
      if (fn.crap > 30) totalViolations++;
    }
  }

  console.log("\n---------------------------------------");
  console.log(`Total functions analyzed: ${Object.values(reports).flat().length}`);
  console.log(`CRAP violations (> 30): ${totalViolations}`);

  if (totalViolations > 0) {
    console.error(`\nEnforcement failed: ${totalViolations} function(s) exceed the CRAP threshold of 30.`);
    process.exit(1);
  } else {
    console.log("\nAll functions pass the CRAP threshold! \u2705");
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
