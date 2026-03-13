#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

function envOr(name, fallback) {
  const value = process.env[name];
  return value && value.trim() ? value : fallback;
}

function envFlag(name, fallback = false) {
  const raw = (process.env[name] || '').trim().toLowerCase();
  if (['1', 'true', 'yes', 'on'].includes(raw)) return true;
  if (['0', 'false', 'no', 'off'].includes(raw)) return false;
  return fallback;
}

function envInt(name, fallback) {
  const raw = (process.env[name] || '').trim();
  const value = Number.parseInt(raw, 10);
  return Number.isFinite(value) ? value : fallback;
}

async function safeEvaluate(page, fn, arg) {
  try {
    return await page.evaluate(fn, arg);
  } catch (err) {
    return { error: err instanceof Error ? err.message : String(err) };
  }
}

async function setPort(page, selectId, value) {
  if (!value || value === 'none') return;
  await page.evaluate(({ selectId: targetId, value: targetValue }) => {
    const select = document.getElementById(targetId);
    if (!select) return;
    select.value = targetValue;
    if (typeof select.onchange === 'function') {
      select.onchange();
    } else {
      select.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }, { selectId, value });
}

async function main() {
  const vamigaUrl = envOr('VAMIGA_URL', 'https://vamigaweb.github.io/');
  const diskImagePath = envOr('VAMIGA_DISK_IMAGE', '');
  const kickRomPath = envOr('VAMIGA_KICK_ROM', '');
  const seconds = Number(envOr('VAMIGA_SECONDS', '8'));
  const reportPath = envOr('VAMIGA_REPORT_PATH', 'build/amiga/vamigaweb_report.json');
  const screenshotPath = envOr('VAMIGA_SCREENSHOT_PATH', '');
  const renderer = envOr('VAMIGA_RENDERER', 'software');
  const display = envOr('VAMIGA_DISPLAY', 'standard');
  const port1 = envOr('VAMIGA_PORT1', 'none');
  const port2 = envOr('VAMIGA_PORT2', 'none');
  const warp = envFlag('VAMIGA_WARP', true);
  const bootblockAccept = envFlag('VAMIGA_ACCEPT_BOOTBLOCK', false);
  const bootblockAcceptDelayMs = envInt('VAMIGA_BOOTBLOCK_ACCEPT_DELAY_MS', 4000);
  const bootblockAcceptHoldMs = envInt('VAMIGA_BOOTBLOCK_ACCEPT_HOLD_MS', 300);

  if (!diskImagePath || !fs.existsSync(diskImagePath)) {
    throw new Error(`Missing VAMIGA_DISK_IMAGE: ${diskImagePath}`);
  }
  if (!kickRomPath || !fs.existsSync(kickRomPath)) {
    throw new Error(`Missing VAMIGA_KICK_ROM: ${kickRomPath}`);
  }

  const result = {
    ready: false,
    url: vamigaUrl,
    diskImagePath,
    kickRomPath,
    seconds,
    renderer,
    display,
    port1,
    port2,
    warp,
    bootblockAccept,
    bootblockAcceptDelayMs,
    bootblockAcceptHoldMs,
    screenshotPath: screenshotPath ? path.resolve(screenshotPath) : '',
    hasDiskDf0: 0,
    cpuCycles: '0',
    serialLen: 0,
    serialPreview: '',
    romInfo: null,
    running: false,
    bodyTextPreview: '',
    fileSlotFileName: '',
    modalRomsVisible: false,
    modalFileVisible: false,
    error: '',
    console: [],
    pageErrors: [],
  };

  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });

    await page.addInitScript(
      ({ renderer: preferredRenderer, display: preferredDisplay, warpEnabled }) => {
        try {
          localStorage.setItem('renderer', preferredRenderer);
          localStorage.setItem('display', preferredDisplay);
          localStorage.setItem('pixel_art', 'true');
          localStorage.setItem('use_warp', warpEnabled ? 'true' : 'false');
        } catch (_err) {
          // Local storage is an optimization only.
        }
      },
      { renderer, display, warpEnabled: warp }
    );

    page.on('console', (msg) => {
      result.console.push(`${msg.type()}: ${msg.text()}`);
    });
    page.on('pageerror', (err) => {
      result.pageErrors.push(err instanceof Error ? err.message : String(err));
    });

    await page.goto(vamigaUrl, { waitUntil: 'domcontentloaded', timeout: 120000 });
    await page.waitForFunction(
      () =>
        typeof window.wasm_rom_info === 'function' &&
        typeof window.wasm_loadfile === 'function' &&
        typeof window.current_renderer !== 'undefined',
      { timeout: 120000 }
    );

    await page.evaluate(({ warpEnabled }) => {
      if (typeof Module !== 'undefined') {
        if (!Module.HEAPU32 && typeof HEAPU32 !== 'undefined') Module.HEAPU32 = HEAPU32;
        if (!Module.HEAPU8 && typeof HEAPU8 !== 'undefined') Module.HEAPU8 = HEAPU8;
      }
      if (typeof window.wasm_set_warp === 'function') {
        window.wasm_set_warp(warpEnabled ? 1 : 0);
      }
    }, { warpEnabled: warp });

    await setPort(page, 'port1', port1);
    await setPort(page, 'port2', port2);

    await page.evaluate(() => {
      try {
        $('#modal_roms').modal('show');
      } catch (_err) {
        // Ignore bootstrap modal issues; the file upload path still works.
      }
    });
    await page.waitForTimeout(500);
    await page.setInputFiles('#filedialog', kickRomPath);
    await page.waitForFunction(() => {
      try {
        return JSON.parse(window.wasm_rom_info()).hasRom === 'true';
      } catch (_err) {
        return false;
      }
    }, { timeout: 60000 });

    await page.evaluate(() => {
      try {
        $('#modal_roms').modal('hide');
      } catch (_err) {
        // Ignore bootstrap modal issues; the emu can continue.
      }
    });

    await page.waitForTimeout(1000);
    await page.setInputFiles('#filedialog', diskImagePath);
    const diskBase = path.basename(diskImagePath).toLowerCase();
    await page.waitForFunction(
      ({ expectedBase }) => {
        return (
          typeof window.file_slot_file_name === 'string' &&
          window.file_slot_file_name.toLowerCase() === expectedBase
        );
      },
      { expectedBase: diskBase },
      { timeout: 30000 }
    );

    await page.evaluate(() => {
      window.insert_file(0);
      try {
        $('#modal_file_slot').modal('hide');
      } catch (_err) {
        // The benchmark crops away this UI anyway.
      }
    });

    if (bootblockAccept) {
      await page.waitForTimeout(Math.max(0, bootblockAcceptDelayMs));
      await page.evaluate(() => {
        Module._wasm_mouse_button(1, 1, 1);
      });
      await page.waitForTimeout(Math.max(0, bootblockAcceptHoldMs));
      await page.evaluate(() => {
        Module._wasm_mouse_button(1, 1, 0);
      });
    }

    await page.waitForTimeout(Math.max(0, seconds) * 1000);

    if (screenshotPath) {
      fs.mkdirSync(path.dirname(screenshotPath), { recursive: true });
      await page.locator('canvas').screenshot({ path: screenshotPath });
    }

    const state = await safeEvaluate(page, () => {
      const serial = String(window.serial_port_out_buffer || '');
      const cyclesRaw = typeof window.wasm_get_cpu_cycles === 'function' ? window.wasm_get_cpu_cycles() : 0;
      const cycles = typeof cyclesRaw === 'bigint' ? cyclesRaw.toString() : String(cyclesRaw ?? 0);
      let romInfo = null;
      try {
        romInfo = typeof window.wasm_rom_info === 'function' ? JSON.parse(window.wasm_rom_info()) : null;
      } catch (_err) {
        romInfo = null;
      }
      return {
        renderer: typeof current_renderer !== 'undefined' ? current_renderer : null,
        hasDiskDf0: typeof window.wasm_has_disk === 'function' ? window.wasm_has_disk('df0') : 0,
        cpuCycles: cycles,
        serialLen: serial.length,
        serialPreview: serial.slice(0, 300),
        romInfo,
        running: typeof is_running === 'function' ? is_running() : false,
        bodyTextPreview: document.body ? document.body.innerText.slice(0, 400) : '',
        fileSlotFileName: typeof window.file_slot_file_name === 'string' ? window.file_slot_file_name : '',
        modalRomsVisible: typeof $ === 'function' ? $('#modal_roms').is(':visible') : false,
        modalFileVisible: typeof $ === 'function' ? $('#modal_file_slot').is(':visible') : false,
      };
    });

    if (state && !state.error) {
      Object.assign(result, state);
      result.ready = true;
    } else if (state && state.error) {
      result.error = state.error;
    }
  } catch (err) {
    result.error = err instanceof Error ? err.message : String(err);
  } finally {
    if (browser) {
      await browser.close();
    }
  }

  const reportDir = path.dirname(reportPath);
  fs.mkdirSync(reportDir, { recursive: true });
  fs.writeFileSync(reportPath, JSON.stringify(result, null, 2), 'utf-8');

  const cpuCyclesNum = Number.parseInt(result.cpuCycles || '0', 10);
  const ok =
    result.ready &&
    !result.error &&
    result.romInfo &&
    result.romInfo.hasRom === 'true' &&
    result.hasDiskDf0 === 1 &&
    Number.isFinite(cpuCyclesNum) &&
    cpuCyclesNum > 0;

  console.log(`VAMIGA_READY ${result.ready ? 'yes' : 'no'}`);
  console.log(`VAMIGA_RENDERER ${result.renderer}`);
  console.log(`VAMIGA_PORT1 ${result.port1}`);
  console.log(`VAMIGA_PORT2 ${result.port2}`);
  console.log(`VAMIGA_DF0 ${result.hasDiskDf0}`);
  console.log(`VAMIGA_CPU_CYCLES ${result.cpuCycles}`);
  console.log(`VAMIGA_SERIAL_LEN ${result.serialLen}`);
  if (result.screenshotPath) {
    console.log(`VAMIGA_SCREENSHOT ${result.screenshotPath}`);
  }
  console.log(`VAMIGA_REPORT ${path.resolve(reportPath)}`);

  if (result.error) {
    console.error(`VAMIGA_ERROR ${result.error}`);
  }

  process.exit(ok ? 0 : 1);
}

main().catch((err) => {
  console.error(`VAMIGA_FATAL ${err instanceof Error ? err.stack || err.message : String(err)}`);
  process.exit(1);
});
