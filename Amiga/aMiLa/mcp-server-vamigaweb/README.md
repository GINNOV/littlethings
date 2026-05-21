# 🕹️ vAmigaWeb MCP Server: Headless visual testing for Amiga 68k AI Coding Assistants

This directory contains a complete, self-contained **Model Context Protocol (MCP)** server that allows AI coding assistants (such as Antigravity, Claude, Cursor, Roo Code, etc.) to autonomously boot, pilot, and visually audit Amiga ADF floppy disk files in the browser using the accurate WebAssembly emulator **vAmigaWeb**.

With this MCP server, AI assistants can perform visual regression testing, verify if code boots successfully, send keyboard/joystick events, and read console logs by running a headless browser in the background.

---

## 🎯 Core Testing Purpose: LLM-Driven Autonomous Auditing

> [!IMPORTANT]
> **Not for Manual Developer Testing**:
> The primary purpose of this MCP server is for automated visual, semantic, and runtime validation **from the LLM perspective**, rather than manual testing by human developers. 
> 
> By utilizing standard multimodal LLM features (such as vision, code-execution, and planning), this MCP allows an autonomous AI agent to:
> 1. **Capture Screenshots**: Read the exact graphical canvas buffer from vAmigaWeb headlessly. Multimodal AI models use this PNG output to perform real-time optical assertions (e.g. checking color fidelity, alignment of sprites, or correct layout of text fields).
> 2. **Retrieve Debug Information**: Collect console output, emulator logs, and runtime diagnostics from the WebAssembly environment to pinpoint assembly compilation errors, register misbehaviors, or performance drops.
> 3. **Detect Runtime Failures**: Automatically catch Guru Meditations, endless loops, division-by-zero crashes, and unhandled interrupt traps by analyzing screen transitions and log signatures.
> 4. **Closed-Loop Verification**: Perform interactive, state-driven regression testing by sending simulated keypresses/joystick actions and auditing the resultant visual state changes completely headlessly.

---

## 🛠️ Exposed MCP Tools

The server registers the following schema-defined tools:

1. **`launch_emulator`**
   * Description: Launches a headless/headful Chromium instance, loads `vAmigaWeb`, and mounts a local ADF file to `DF0`.
   * Arguments:
     * `adfPath` (string, required): Absolute path to the locally generated `.adf` file on the host machine.
     * `headful` (boolean, optional): Set to `true` to show the browser window to the developer. Defaults to `false`.
   * Returns: A JSON object containing `sessionId` and a status string.

2. **`take_screenshot`**
   * Description: Captures the current output of the Amiga emulator canvas.
   * Arguments:
     * `sessionId` (string, required): The active session identifier.
   * Returns: A base64-encoded PNG image string that multimodal vision LLMs can interpret.

3. **`send_input`**
   * Description: Simulates keyboard keypresses or joystick events in the emulator.
   * Arguments:
     * `sessionId` (string, required): The active session identifier.
     * `key` (string, required): The keyboard character or layout key (e.g. `"Space"`, `"ArrowDown"`, `"Enter"`).
     * `durationMs` (number, optional): How long to hold the key in milliseconds. Defaults to `100`.
   * Returns: Success status.

4. **`close_session`**
   * Description: Closes the Chromium browser instance and frees up memory.
   * Arguments:
     * `sessionId` (string, required): The active session identifier.
   * Returns: Success status.

---

## ⚙️ Installation & Build

### Prerequisites
* **Node.js** (v18 or higher)
* **NPM** (v9 or higher)

### Setup steps:
1. Navigate to the MCP server directory:
   ```bash
   cd /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/mcp-server-vamigaweb
   ```
2. Install the standard dependencies (Playwright, MCP SDK, TypeScript compiler):
   ```bash
   npm install
   ```
3. Install the Playwright browser binaries (specifically Chromium):
   ```bash
   npx playwright install chromium
   ```
4. Compile the TypeScript source code into production JavaScript:
   ```bash
   npm run build
   ```

Now the compiled script is ready at `build/index.js`!

---

## 🔌 Configuration for AI Clients

You can connect this MCP server to any compatible AI agent environment. Here are the most popular setups:

### 1. Claude Desktop App
Open your Claude Desktop Configuration file located at:
* **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
* **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

Append the following configuration entry to the `mcpServers` object:

```json
{
  "mcpServers": {
    "vamigaweb-testing": {
      "command": "node",
      "args": [
        "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/mcp-server-vamigaweb/build/index.js"
      ]
    }
  }
}
```

### 2. Cursor IDE
1. Open Cursor and head to **Settings** -> **Features** -> **MCP**.
2. Click **+ Add New MCP Server**.
3. Fill in the parameters:
   * **Name:** `vAmigaWeb-Emulator`
   * **Type:** `command`
   * **Command:** `node /Users/megov/code/GitHub/littlethings/Amiga/aMiLa/mcp-server-vamigaweb/build/index.js`
4. Click **Save** and verify the status bulb lights up green.

### 3. Roo Code (VS Code Extension)
Open your Roo Code MCP configuration directory and add this block inside your `mcp_settings.json` file:

```json
{
  "mcpServers": {
    "vamigaweb-testing": {
      "command": "node",
      "args": [
        "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/mcp-server-vamigaweb/build/index.js"
      ],
      "disabled": false
    }
  }
}
```

---

## 🚀 Example Interactive Loop

When another AI agent connects to this server, it will execute the following standard flow to test its generated code:

1. **AI compiles code** to `/tmp/test.adf` using local compilers.
2. **AI calls `launch_emulator`** with `{"adfPath": "/tmp/test.adf"}`. The server launches a headless browser, navigates to `https://vamigaweb.github.io/`, base64 encodes the floppy disk, and drops it into the WASM window.
3. **AI waits 3 seconds**, then calls **`take_screenshot`** with the returned session ID. The vision model inspects the PNG to check if colors, sprites, or copper bars rendered correctly.
4. **AI calls `send_input`** with `{"key": "Space"}` to simulate pressing space to dismiss a test screen.
5. **AI calls `close_session`** to clean up the browser resource cleanly.
