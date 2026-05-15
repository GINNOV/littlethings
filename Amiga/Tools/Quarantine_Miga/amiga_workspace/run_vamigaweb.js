#!/usr/bin/env node
'use strict';

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const os = require('os');
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

async function activateBrowserWindow(page) {
  if (!page) return;
  try {
    await page.bringToFront();
  } catch (_err) {
    // Best-effort only.
  }
  if (process.platform !== 'darwin') return;
  try {
    const { spawn } = require('child_process');
    const script = 'tell application "Google Chrome for Testing" to activate';
    const proc = spawn('osascript', ['-e', script], { stdio: 'ignore' });
    await new Promise((resolve) => proc.on('exit', resolve));
  } catch (_err) {
    // Best-effort only.
  }
}

async function main() {
  const vamigaUrl = envOr('VAMIGA_URL', 'https://vamigaweb.github.io/');
  const diskImagePath = envOr('VAMIGA_DISK_IMAGE', '');
  const kickRomPath = envOr('VAMIGA_KICK_ROM', '');
  const seconds = Number(envOr('VAMIGA_SECONDS', '8'));
  const reportPath = envOr('VAMIGA_REPORT_PATH', 'build/amiga/vamigaweb_report.json');
  const screenshotPath = envOr('VAMIGA_SCREENSHOT_PATH', '');
  const audioCapturePath = envOr('VAMIGA_AUDIO_CAPTURE_PATH', '');
  const audioSampleCount = envInt('VAMIGA_AUDIO_SAMPLE_COUNT', 4096);
  const audioWarmupUpdates = envInt('VAMIGA_AUDIO_WARMUP_UPDATES', 32);
  const audioUpdateIterations = envInt('VAMIGA_AUDIO_UPDATE_ITERATIONS', 8);
  const audioSampleRate = envInt('VAMIGA_AUDIO_SAMPLE_RATE', 44100);
  const memoryCapturePath = envOr('VAMIGA_MEMORY_CAPTURE_PATH', '');
  const memoryCaptureAddress = envInt('VAMIGA_MEMORY_CAPTURE_ADDRESS', 0);
  const memoryCaptureLength = envInt('VAMIGA_MEMORY_CAPTURE_LENGTH', 0);
  const headless = envFlag('VAMIGA_HEADLESS', true);
  const interactive = envFlag('VAMIGA_INTERACTIVE', false);
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
    audioCapturePath: audioCapturePath ? path.resolve(audioCapturePath) : '',
    memoryCapturePath: memoryCapturePath ? path.resolve(memoryCapturePath) : '',
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
    audioCapture: null,
    memoryCapture: null,
  };

  let browser;
  let context;
  try {
    let page;
    if (interactive) {
      const userDataDir = fs.mkdtempSync(path.join(os.tmpdir(), 'miga-vamiga-'));
      context = await chromium.launchPersistentContext(userDataDir, {
        headless: false,
        ignoreDefaultArgs: ['--no-startup-window'],
        viewport: { width: 1280, height: 900 },
      });
      page = context.pages()[0] || (await context.newPage());
      await activateBrowserWindow(page);
    } else {
      browser = await chromium.launch({ headless: true });
      page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
    }

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
    if (interactive) await activateBrowserWindow(page);
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
        if (!Module.HEAPF32 && typeof HEAPF32 !== 'undefined') Module.HEAPF32 = HEAPF32;
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

    if (audioCapturePath) {
      const audioCapture = await safeEvaluate(
        page,
        async ({ sampleCount, warmupUpdates, updateIterations, sampleRate }) => {
          const getBufferAddress =
            typeof window.wasm_get_sound_buffer_address === 'function'
              ? window.wasm_get_sound_buffer_address
              : typeof window._wasm_get_sound_buffer_address === 'function'
                ? window._wasm_get_sound_buffer_address
                : null;
          const setSampleRate =
            typeof window.wasm_set_sample_rate === 'function'
              ? window.wasm_set_sample_rate
              : typeof window._wasm_set_sample_rate === 'function'
                ? window._wasm_set_sample_rate
                : null;
          const copyIntoSoundBuffer =
            typeof Module !== 'undefined' && typeof Module._wasm_copy_into_sound_buffer === 'function'
              ? Module._wasm_copy_into_sound_buffer
              : typeof window.wasm_copy_into_sound_buffer === 'function'
                ? window.wasm_copy_into_sound_buffer
                : null;
          const updateAudio =
            typeof window._wasm_update_audio === 'function'
              ? window._wasm_update_audio
              : typeof window.wasm_update_audio === 'function'
                ? window.wasm_update_audio
                : null;
          const connectAudio =
            typeof window.connect_audio_processor === 'function'
              ? window.connect_audio_processor
              : typeof window.connect_audio_processor_standard === 'function'
                ? window.connect_audio_processor_standard
                : null;
          const resumeAudio =
            typeof window.resume_audio === 'function' ? window.resume_audio : null;

          if (typeof Module === 'undefined' || !Module.HEAPF32) {
            return { error: 'Module.HEAPF32 is not available' };
          }
          if (typeof getBufferAddress !== 'function') {
            return { error: 'wasm_get_sound_buffer_address is not available' };
          }
          if (typeof copyIntoSoundBuffer !== 'function' && typeof updateAudio !== 'function') {
            return { error: 'No audio copy or update function is available' };
          }
          if (typeof setSampleRate === 'function') {
            setSampleRate(sampleRate);
          }
          if (typeof resumeAudio === 'function') {
            try {
              await resumeAudio();
            } catch (_err) {
              // Best effort only.
            }
          }
          if (typeof connectAudio === 'function') {
            try {
              await connectAudio();
            } catch (_err) {
              // Best effort only.
            }
          }

          const bufferAddress = getBufferAddress();
          const slotSize = 2048;
          const slotViews = [];
          for (let slot = 0; slot < 16; slot += 1) {
            slotViews.push(new Float32Array(Module.HEAPF32.buffer, bufferAddress + (slot * slotSize * 4), slotSize));
          }

          let copiedSamples = 0;
          for (let index = 0; index < Math.max(0, warmupUpdates); index += 1) {
            if (typeof copyIntoSoundBuffer === 'function') {
              copiedSamples = copyIntoSoundBuffer();
            } else if (typeof updateAudio === 'function') {
              updateAudio();
            }
          }
          for (let index = 0; index < Math.max(1, updateIterations); index += 1) {
            if (typeof copyIntoSoundBuffer === 'function') {
              copiedSamples = copyIntoSoundBuffer();
            } else if (typeof updateAudio === 'function') {
              updateAudio();
            }
          }

          const effectiveSamples = Math.max(0, Math.min(sampleCount, copiedSamples || slotSize));
          const samples = [];
          let remaining = effectiveSamples || Math.max(1, sampleCount);
          for (const slotView of slotViews) {
            if (remaining <= 0) break;
            const take = Math.min(slotView.length, remaining);
            for (let index = 0; index < take; index += 1) {
              samples.push(slotView[index]);
            }
            remaining -= take;
          }
          let meanAbs = 0;
          let rms = 0;
          let peakAbs = 0;
          let zeroCrossings = 0;
          let nonZeroSamples = 0;
          let previous = samples[0] || 0;
          for (const sample of samples) {
            const abs = Math.abs(sample);
            meanAbs += abs;
            rms += sample * sample;
            if (abs > peakAbs) peakAbs = abs;
            if (abs > 1e-9) nonZeroSamples += 1;
            if ((previous < 0 && sample >= 0) || (previous > 0 && sample <= 0)) {
              zeroCrossings += 1;
            }
            previous = sample;
          }
          meanAbs /= samples.length || 1;
          rms = Math.sqrt(rms / (samples.length || 1));

          return {
            sampleRate,
            sampleCount: samples.length,
            bufferAddress,
            copiedSamples,
            soundbufferSlots: typeof window.soundbuffer_slots === 'number' ? window.soundbuffer_slots : null,
            currentSoundVolume:
              typeof window.current_sound_volume === 'number' ? window.current_sound_volume : null,
            meanAbs,
            rms,
            peakAbs,
            zeroCrossings,
            nonZeroSamples,
            samples,
          };
        },
        {
          sampleCount: audioSampleCount,
          warmupUpdates: audioWarmupUpdates,
          updateIterations: audioUpdateIterations,
          sampleRate: audioSampleRate,
        }
      );

      if (audioCapture && !audioCapture.error) {
        const samples = Array.isArray(audioCapture.samples) ? audioCapture.samples : [];
        const hash = crypto.createHash('sha1').update(JSON.stringify(samples)).digest('hex');
        audioCapture.sha1 = hash;
        result.audioCapture = {
          sampleRate: audioCapture.sampleRate,
          sampleCount: audioCapture.sampleCount,
          meanAbs: audioCapture.meanAbs,
          rms: audioCapture.rms,
          peakAbs: audioCapture.peakAbs,
          zeroCrossings: audioCapture.zeroCrossings,
          nonZeroSamples: audioCapture.nonZeroSamples,
          sha1: hash,
        };
        fs.mkdirSync(path.dirname(audioCapturePath), { recursive: true });
        fs.writeFileSync(audioCapturePath, JSON.stringify(audioCapture, null, 2), 'utf-8');
      } else if (audioCapture && audioCapture.error) {
        result.audioCapture = { error: audioCapture.error };
      }
    }

    if (memoryCapturePath && memoryCaptureLength > 0) {
      const memoryCapture = await safeEvaluate(
        page,
        ({ address, length }) => {
          if (typeof Module === 'undefined' || !Module.HEAPU8) {
            return { error: 'Module.HEAPU8 is not available' };
          }
          const start = Math.max(0, address >>> 0);
          const end = start + Math.max(1, length);
          const bytes = Array.from(Module.HEAPU8.slice(start, end));
          return { address: start, length: bytes.length, bytes };
        },
        { address: memoryCaptureAddress, length: memoryCaptureLength }
      );

      if (memoryCapture && !memoryCapture.error) {
        const hash = crypto.createHash('sha1').update(Buffer.from(memoryCapture.bytes)).digest('hex');
        memoryCapture.sha1 = hash;
        result.memoryCapture = {
          address: memoryCapture.address,
          length: memoryCapture.length,
          sha1: hash,
        };
        fs.mkdirSync(path.dirname(memoryCapturePath), { recursive: true });
        fs.writeFileSync(memoryCapturePath, JSON.stringify(memoryCapture, null, 2), 'utf-8');
      } else if (memoryCapture && memoryCapture.error) {
        result.memoryCapture = { error: memoryCapture.error };
      }
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

    if (interactive) {
      if (context) {
        await new Promise((resolve) => {
          context.on('close', resolve);
        });
        context = null;
      } else if (browser) {
        await new Promise((resolve) => {
          browser.on('disconnected', resolve);
        });
        browser = null;
      }
    }
  } catch (err) {
    result.error = err instanceof Error ? err.message : String(err);
  } finally {
    if (context) {
      await context.close();
    }
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
  if (result.audioCapturePath) {
    console.log(`VAMIGA_AUDIO_CAPTURE ${result.audioCapturePath}`);
  }
  if (result.memoryCapturePath) {
    console.log(`VAMIGA_MEMORY_CAPTURE ${result.memoryCapturePath}`);
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
