import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { chromium, Browser, Page } from "playwright";
import * as fs from "fs";
import * as path from "path";

interface Session {
  browser: Browser;
  page: Page;
  logs: string[];
}

const sessions = new Map<string, Session>();

// Create the MCP Server
const server = new Server(
  {
    name: "mcp-server-vamigaweb",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Define Tools list
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "launch_emulator",
        description: "Launch the vAmigaWeb emulator and insert a custom local ADF disk.",
        inputSchema: {
          type: "object",
          properties: {
            adfPath: {
              type: "string",
              description: "Absolute path to the local ADF floppy disk image.",
            },
            headful: {
              type: "boolean",
              description: "Show the browser window (useful for debugging).",
            },
          },
          required: ["adfPath"],
        },
      },
      {
        name: "take_screenshot",
        description: "Capture the current visual output of the running Amiga emulator.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string" },
          },
          required: ["sessionId"],
        },
      },
      {
        name: "send_input",
        description: "Simulate keyboard keypresses or joystick triggers in the emulator.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string" },
            key: { type: "string", description: "e.g., 'Space', 'ArrowDown', 'Enter'" },
            durationMs: { type: "number", description: "How long to hold the key in milliseconds." }
          },
          required: ["sessionId", "key"],
        },
      },
      {
        name: "close_session",
        description: "Close the running emulator session and free up resources.",
        inputSchema: {
          type: "object",
          properties: {
            sessionId: { type: "string" },
          },
          required: ["sessionId"],
        },
      },
    ],
  };
});

// Implement Tool Logic
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "launch_emulator": {
        const adfPath = args?.adfPath as string;
        const headful = !!args?.headful;

        if (!fs.existsSync(adfPath)) {
          throw new Error(`ADF file not found at path: ${adfPath}`);
        }

        const sessionId = `amiga_${Date.now()}`;
        const browser = await chromium.launch({ headless: !headful });
        const context = await browser.newContext({
          permissions: ["clipboard-read", "clipboard-write"],
        });
        const page = await context.newPage();

        const logs: string[] = [];
        page.on("console", (msg) => logs.push(`[Console] ${msg.type()}: ${msg.text()}`));

        // 1. Navigate to vAmigaWeb
        await page.goto("https://vamigaweb.github.io/");

        // Wait for WebAssembly emulator load
        await page.waitForSelector("#canvas", { timeout: 15000 });

        // 2. Perform File Drop Simulation in Page Context
        const buffer = fs.readFileSync(adfPath);
        const fileName = path.basename(adfPath);

        // Read the local file as base64 and feed it directly to the drag-and-drop listener
        const base64File = buffer.toString("base64");

        await page.evaluate(
          async ({ base64, name }) => {
            const res = await fetch(`data:application/octet-stream;base64,${base64}`);
            const blob = await res.blob();
            const file = new File([blob], name, { type: "application/octet-stream" });

            // Create custom drag-and-drop events directly targeting the dropsheet layer
            const target = document.querySelector("#canvas") || document.body;
            
            const dataTransfer = new DataTransfer();
            dataTransfer.items.add(file);

            const dragOverEvent = new DragEvent("dragover", {
              bubbles: true,
              cancelable: true,
              dataTransfer,
            });
            const dropEvent = new DragEvent("drop", {
              bubbles: true,
              cancelable: true,
              dataTransfer,
            });

            target.dispatchEvent(dragOverEvent);
            target.dispatchEvent(dropEvent);
          },
          { base64: base64File, name: fileName }
        );

        sessions.set(sessionId, { browser, page, logs });

        // Give the emulator 3 seconds to spin up and load the bootblock
        await page.waitForTimeout(3000);

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify({
                status: "success",
                sessionId,
                message: `Amiga booted successfully with disk: ${fileName}`,
              }),
            },
          ],
        };
      }

      case "take_screenshot": {
        const sessionId = args?.sessionId as string;
        const session = sessions.get(sessionId);

        if (!session) {
          throw new Error(`Active session not found for ID: ${sessionId}`);
        }

        // Take a screenshot of the Canvas target specifically
        const canvas = await session.page.$("#canvas");
        const target = canvas || session.page;
        const screenshotBuffer = await target.screenshot({ type: "png" });

        return {
          content: [
            {
              type: "text",
              text: `data:image/png;base64,${screenshotBuffer.toString("base64")}`,
            },
          ],
        };
      }

      case "send_input": {
        const sessionId = args?.sessionId as string;
        const key = args?.key as string;
        const duration = (args?.durationMs as number) || 100;

        const session = sessions.get(sessionId);
        if (!session) {
          throw new Error(`Active session not found for ID: ${sessionId}`);
        }

        // Target the canvas element for keystrokes
        await session.page.focus("#canvas");
        await session.page.keyboard.down(key);
        await session.page.waitForTimeout(duration);
        await session.page.keyboard.up(key);

        return {
          content: [{ type: "text", text: `Sent key press: ${key} for ${duration}ms` }],
        };
      }

      case "close_session": {
        const sessionId = args?.sessionId as string;
        const session = sessions.get(sessionId);

        if (!session) {
          throw new Error(`Active session not found for ID: ${sessionId}`);
        }

        await session.browser.close();
        sessions.delete(sessionId);

        return {
          content: [{ type: "text", text: `Session ${sessionId} closed successfully.` }],
        };
      }

      default:
        throw new Error(`Unsupported tool: ${name}`);
    }
  } catch (error: any) {
    return {
      isError: true,
      content: [{ type: "text", text: error.message || "Unknown error" }],
    };
  }
});

// Setup Stdio Transport connection
const transport = new StdioServerTransport();
await server.connect(transport);
console.error("vAmigaWeb MCP Server is running and listening on Stdio!");
