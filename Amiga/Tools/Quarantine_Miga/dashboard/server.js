#!/usr/bin/env node
'use strict';

const express = require('express');
const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = path.resolve(__dirname, '..');
const PUBLIC_DIR = path.join(__dirname, 'public');
const ASSETS_DIR = path.join(ROOT, 'assets');
const DASHBOARD_VERSION_FILE = path.join(__dirname, 'VERSION');
const PROJECT_SETTINGS_FILE = path.join(ROOT, 'project_settings.json');
const BUILD_AMIGA_DIR = path.join(ROOT, 'build', 'amiga');
const AMIGA_EVAL_SCRIPT = path.join(ROOT, 'amiga_eval.py');
const AMIGA_BENCHMARK_EVAL_SCRIPT = path.join(ROOT, 'amiga_eval_benchmark.py');
const AMIGA_SOURCE_BENCHMARK_EVAL_SCRIPT = path.join(ROOT, 'amiga_eval_benchmark_source.py');
const AMIGA_BENCHMARK_SUITE_EVAL_SCRIPT = path.join(ROOT, 'amiga_eval_benchmark_suite.py');
const RESULTS_TSV = path.join(ROOT, 'results_amiga.tsv');
const DEFAULT_MUTATION_SOURCE_REL = path.join(
  'amiga_workspace',
  'benchmarks',
  'copper_bars',
  'mutation',
  'current.s'
);
const REPORT_JSON = path.join(BUILD_AMIGA_DIR, 'report.json');
const SELECTED_SOURCE_JSON = path.join(BUILD_AMIGA_DIR, 'selected_source.json');
const VAMIGA_REPORT_JSON = path.join(BUILD_AMIGA_DIR, 'vamigaweb_report.json');
const EMULATOR_CAPTURE_PNG = path.join(BUILD_AMIGA_DIR, 'emulator_capture.png');
const BENCHMARK_CAPTURE_PNG = path.join(BUILD_AMIGA_DIR, 'benchmark_capture.png');
const BENCHMARK_CAPTURE_CROP_PNG = path.join(BUILD_AMIGA_DIR, 'benchmark_capture_crop.png');
const BENCHMARK_CAPTURE_DIFF_PNG = path.join(BUILD_AMIGA_DIR, 'benchmark_capture_diff.png');
const ARCHIVED_DISK_IMAGE = 'disk_image.adf';
const RUNS_DIR = path.join(BUILD_AMIGA_DIR, 'runs');
const CORPUS_MANIFEST_REL = path.join('amiga_workspace', 'corpus', 'manifest.tsv');
const RUNNABLE_MANIFEST_REL = path.join('amiga_workspace', 'corpus', 'manifest_runnable.tsv');
const BUILD_RUNNABLE_MANIFEST_SCRIPT = path.join('amiga_workspace', 'corpus', 'scripts', 'build_runnable_manifest.py');
const CORPUS_MANIFEST = path.join(ROOT, CORPUS_MANIFEST_REL);
const RUNNABLE_MANIFEST = path.join(ROOT, RUNNABLE_MANIFEST_REL);
const RUN_MODE_PRESETS = {
  corpus_validation: {
    label: 'Corpus validation',
    description:
      'Auto-selects from the strict runnable corpus and uses the normal assemble, emulate, and verify flow.',
    kind: 'corpus',
    useCorpusControls: true,
    source: null,
    env: {},
  },
  copper_reference: {
    label: 'Copper bars reference benchmark',
    description:
      'Boots the fixed known-good Copper bars ADF and scores the captured frame against the original full-frame crop.',
    kind: 'benchmark',
    script: AMIGA_BENCHMARK_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/copper_bars/benchmark.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
  copper_bars_asm: {
    label: 'Copper bars assembly benchmark',
    description:
      'Builds the inline-assembly Copper bars workspace and scores it against the original full-frame benchmark crop.',
    kind: 'benchmark',
    script: AMIGA_SOURCE_BENCHMARK_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
  copper_bars_suite: {
    label: 'Copper bars suite benchmark',
    description:
      'Runs the inline-assembly Copper bars suite so both the full-frame crop and the midband crop must hold at once.',
    kind: 'benchmark_suite',
    script: AMIGA_BENCHMARK_SUITE_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark_suite.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
  playfield_marker: {
    label: 'Playfield marker benchmark',
    description:
      'Builds the setup-sensitive playfield-marker source and scores a tight top-left crop where display-window and fetch setup visibly matter.',
    kind: 'benchmark',
    script: AMIGA_SOURCE_BENCHMARK_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/copper_bars/asm_playfield_marker_benchmark.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
  playfield_structure_control: {
    label: 'Playfield structure control',
    description:
      'Runs the intentionally wrong playfield-setup control against the playfield-marker crop to confirm the setup-sensitive benchmark still fails when it should.',
    kind: 'benchmark',
    script: AMIGA_SOURCE_BENCHMARK_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/copper_bars/asm_playfield_structure_benchmark.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
  sincos_scroller_reference: {
    label: 'Sin/Cos scroller benchmark',
    description:
      'Runs the glyph-based sin/cos text scroller across the 2s, 4s, and 6s reference suite. Use it as the benchmarked passing path for the current text-effect task.',
    kind: 'benchmark_suite',
    script: AMIGA_BENCHMARK_SUITE_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/sincos_scroller/reference_suite.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
  sincos_scroller_control: {
    label: 'Sin/Cos scroller control',
    description:
      'Runs the fixed-position text control against the same three-frame suite to confirm the sin/cos scroller benchmark still fails when the motion is wrong.',
    kind: 'benchmark_suite',
    script: AMIGA_BENCHMARK_SUITE_EVAL_SCRIPT,
    benchmarkConfig: 'amiga_workspace/benchmarks/sincos_scroller/control_suite.json',
    useCorpusControls: false,
    source: null,
    env: {},
  },
};
const RUN_MODE_ALIASES = {
  current: 'corpus_validation',
  copper_benchmark: 'copper_reference',
  copper_mutation: 'copper_bars_asm',
  copper_source_benchmark: 'copper_bars_asm',
};
const ROMS_DIR = path.join(ROOT, 'roms');
const KICK_ROM_EXTENSIONS = new Set(['.rom', '.bin', '.kick']);
const DEFAULT_SETTINGS_PROFILE = {
  dashboard: {
    defaults: {
      iterations: 1,
      seed: 0,
      runMode: 'copper_bars_suite',
      sourceFilter: '',
      manifestIndex: 0,
      kickRom: '',
      autoSelect: true,
      allowIncludes: false,
      allowNonentry: false,
    },
  },
  benchmark: {
    kickRomName: '',
    kickRomDir: '',
  },
  mutationLoop: {
    iterations: 10,
    seed: 0,
    benchmarkConfig: 'amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark.json',
    evalScript: 'amiga_eval_benchmark_source.py',
    loopDir: 'build/amiga/asm_mutation_loop',
    resultsFile: '',
    mutator: 'heuristic',
    mutation: 'any',
    candidateBudget: 12,
    plateauRepeatLimit: 4,
    imageHashCacheFile: '',
  },
  llm: {
    openai: {
      model: 'gpt-5-mini',
      apiKeyEnv: 'OPENAI_API_KEY',
      baseUrl: 'https://api.openai.com/v1/responses',
      reasoningEffort: 'minimal',
    },
    lmstudio: {
      baseUrl: 'http://127.0.0.1:1234',
      model: '',
      apiTokenEnv: 'LMSTUDIO_API_TOKEN',
    },
  },
};
function buildDefaultProjectSettings() {
  return {
    activeProfile: 'default',
    profiles: {
      default: deepClone(DEFAULT_SETTINGS_PROFILE),
      benchmark: deepMerge(DEFAULT_SETTINGS_PROFILE, {
        dashboard: {
          defaults: {
            runMode: 'copper_reference',
          },
        },
      }),
      lmstudio: deepMerge(DEFAULT_SETTINGS_PROFILE, {
        dashboard: {
          defaults: {
            runMode: 'copper_bars_suite',
          },
        },
        mutationLoop: {
          mutator: 'lmstudio',
        },
      }),
      'corpus-validation': deepMerge(DEFAULT_SETTINGS_PROFILE, {
        dashboard: {
          defaults: {
            runMode: 'corpus_validation',
          },
        },
      }),
    },
  };
}
const DEFAULT_PROJECT_SETTINGS = buildDefaultProjectSettings();

const RESULTS_HEADER = 'commit\tscore\tstatus\tdescription\n';
const MUTATION_RESULTS_HEADER = 'iteration\tscore\tbest_before\tbest_after\tstatus\tmutation\tbenchmark_ok\teval_code\trun_dir\n';
const LOG_FILES = {
  assemble_stdout: path.join(BUILD_AMIGA_DIR, 'assemble.stdout.log'),
  assemble_stderr: path.join(BUILD_AMIGA_DIR, 'assemble.stderr.log'),
  emulate_stdout: path.join(BUILD_AMIGA_DIR, 'emulate.stdout.log'),
  emulate_stderr: path.join(BUILD_AMIGA_DIR, 'emulate.stderr.log'),
  verify_stdout: path.join(BUILD_AMIGA_DIR, 'verify.stdout.log'),
  verify_stderr: path.join(BUILD_AMIGA_DIR, 'verify.stderr.log'),
};

const state = {
  running: false,
  queue: [],
  current: null,
  lastCompleted: null,
  nextJobId: 1,
  nextRunId: 1,
};

function nowIso() {
  return new Date().toISOString();
}

function safeParseFloat(value) {
  const n = Number.parseFloat(value);
  return Number.isFinite(n) ? n : null;
}

function deepClone(value) {
  return JSON.parse(JSON.stringify(value));
}

function deepMerge(base, override) {
  const merged = deepClone(base);
  if (!override || typeof override !== 'object' || Array.isArray(override)) {
    return merged;
  }
  for (const [key, value] of Object.entries(override)) {
    if (
      value &&
      typeof value === 'object' &&
      !Array.isArray(value) &&
      merged[key] &&
      typeof merged[key] === 'object' &&
      !Array.isArray(merged[key])
    ) {
      merged[key] = deepMerge(merged[key], value);
    } else {
      merged[key] = value;
    }
  }
  return merged;
}

function normalizeString(value, fallback = '') {
  return typeof value === 'string' ? value.trim() : fallback;
}

function shQuote(value) {
  return `'${String(value).replace(/'/g, `'\\''`)}'`;
}

function normalizeBool(value, fallback = false) {
  return typeof value === 'boolean' ? value : fallback;
}

function normalizeInt(value, fallback, { min = Number.MIN_SAFE_INTEGER, max = Number.MAX_SAFE_INTEGER } = {}) {
  const parsed = Number.parseInt(String(value), 10);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(max, Math.max(min, parsed));
}

function normalizeChoice(value, allowed, fallback) {
  const text = normalizeString(value, fallback);
  return allowed.includes(text) ? text : fallback;
}

function normalizeRunMode(value, fallback = DEFAULT_SETTINGS_PROFILE.dashboard.defaults.runMode) {
  const text = normalizeString(value, fallback);
  const aliased = RUN_MODE_ALIASES[text] || text;
  return Object.prototype.hasOwnProperty.call(RUN_MODE_PRESETS, aliased) ? aliased : fallback;
}

function normalizeProfileName(value) {
  const text = normalizeString(value, '');
  return /^[a-z0-9][a-z0-9_-]{0,63}$/i.test(text) ? text : '';
}

function listRunModes() {
  return Object.entries(RUN_MODE_PRESETS).map(([id, preset]) => ({
    id,
    label: preset.label,
    description: preset.description || '',
    kind: preset.kind || 'benchmark',
    useCorpusControls: preset.useCorpusControls === true,
  }));
}

async function ensureFileWithHeader(filePath, header) {
  try {
    await fsp.access(filePath, fs.constants.F_OK);
  } catch {
    await fsp.writeFile(filePath, header, 'utf8');
  }
}

async function ensureDirs() {
  await fsp.mkdir(BUILD_AMIGA_DIR, { recursive: true });
  await fsp.mkdir(RUNS_DIR, { recursive: true });
  await ensureFileWithHeader(RESULTS_TSV, RESULTS_HEADER);
}

async function readJsonSafe(filePath) {
  try {
    const text = await fsp.readFile(filePath, 'utf8');
    return JSON.parse(text);
  } catch {
    return null;
  }
}

async function readTextSafe(filePath) {
  try {
    return await fsp.readFile(filePath, 'utf8');
  } catch {
    return '';
  }
}

async function statSafe(filePath) {
  try {
    return await fsp.stat(filePath);
  } catch {
    return null;
  }
}

async function manifestHasRows(filePath) {
  try {
    const text = await fsp.readFile(filePath, 'utf8');
    const lines = text
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean);
    return lines.length > 1;
  } catch {
    return false;
  }
}

async function readDashboardVersion() {
  try {
    const text = await fsp.readFile(DASHBOARD_VERSION_FILE, 'utf8');
    const value = text.trim();
    return value || '0.0.0-dev';
  } catch {
    return '0.0.0-dev';
  }
}

function normalizeSettingsProfile(raw) {
  const merged = deepMerge(DEFAULT_SETTINGS_PROFILE, raw && typeof raw === 'object' ? raw : {});
  const profile = deepClone(DEFAULT_SETTINGS_PROFILE);
  const dashboardDefaults = merged.dashboard?.defaults || {};
  const mutationLoop = merged.mutationLoop || {};
  const benchmark = merged.benchmark || {};
  const openai = merged.llm?.openai || {};
  const lmstudio = merged.llm?.lmstudio || {};

  profile.dashboard.defaults.iterations = normalizeInt(profile.dashboard.defaults.iterations, profile.dashboard.defaults.iterations, {
    min: 1,
    max: 200,
  });
  profile.dashboard.defaults.iterations = normalizeInt(dashboardDefaults.iterations, profile.dashboard.defaults.iterations, {
    min: 1,
    max: 200,
  });
  profile.dashboard.defaults.seed = normalizeInt(dashboardDefaults.seed, profile.dashboard.defaults.seed, {
    min: 0,
    max: 999999999,
  });
  profile.dashboard.defaults.runMode = normalizeRunMode(
    dashboardDefaults.runMode,
    profile.dashboard.defaults.runMode
  );
  profile.dashboard.defaults.sourceFilter = normalizeString(dashboardDefaults.sourceFilter, '');
  profile.dashboard.defaults.manifestIndex = normalizeInt(
    dashboardDefaults.manifestIndex,
    profile.dashboard.defaults.manifestIndex,
    { min: 0, max: 999999 }
  );
  profile.dashboard.defaults.kickRom = normalizeString(dashboardDefaults.kickRom, '');
  profile.dashboard.defaults.autoSelect = normalizeBool(dashboardDefaults.autoSelect, profile.dashboard.defaults.autoSelect);
  profile.dashboard.defaults.allowIncludes = normalizeBool(
    dashboardDefaults.allowIncludes,
    profile.dashboard.defaults.allowIncludes
  );
  profile.dashboard.defaults.allowNonentry = normalizeBool(
    dashboardDefaults.allowNonentry,
    profile.dashboard.defaults.allowNonentry
  );

  profile.benchmark.kickRomName = normalizeString(benchmark.kickRomName, '');
  profile.benchmark.kickRomDir = normalizeString(benchmark.kickRomDir, '');

  profile.mutationLoop.iterations = normalizeInt(mutationLoop.iterations, profile.mutationLoop.iterations, {
    min: 1,
    max: 100000,
  });
  profile.mutationLoop.seed = normalizeInt(mutationLoop.seed, profile.mutationLoop.seed, {
    min: 0,
    max: 999999999,
  });
  profile.mutationLoop.benchmarkConfig = normalizeString(mutationLoop.benchmarkConfig, profile.mutationLoop.benchmarkConfig);
  profile.mutationLoop.evalScript = normalizeString(mutationLoop.evalScript, profile.mutationLoop.evalScript);
  profile.mutationLoop.loopDir = normalizeString(mutationLoop.loopDir, profile.mutationLoop.loopDir);
  profile.mutationLoop.resultsFile = normalizeString(mutationLoop.resultsFile, profile.mutationLoop.resultsFile);
  profile.mutationLoop.mutator = normalizeChoice(
    mutationLoop.mutator,
    ['heuristic', 'openai', 'lmstudio'],
    profile.mutationLoop.mutator
  );
  profile.mutationLoop.mutation = normalizeChoice(
    mutationLoop.mutation,
    [
      'any',
      'insert_reference_pair',
      'insert_reference_segment',
      'fill_gap_segment',
      'shift_pair',
      'shift_window',
      'remove_pair',
    ],
    profile.mutationLoop.mutation
  );
  profile.mutationLoop.candidateBudget = normalizeInt(mutationLoop.candidateBudget, profile.mutationLoop.candidateBudget, {
    min: 1,
    max: 200,
  });
  profile.mutationLoop.plateauRepeatLimit = normalizeInt(
    mutationLoop.plateauRepeatLimit,
    profile.mutationLoop.plateauRepeatLimit,
    { min: 0, max: 1000 }
  );
  profile.mutationLoop.imageHashCacheFile = normalizeString(
    mutationLoop.imageHashCacheFile,
    profile.mutationLoop.imageHashCacheFile
  );

  profile.llm.openai.model = normalizeString(openai.model, profile.llm.openai.model);
  profile.llm.openai.apiKeyEnv = normalizeString(openai.apiKeyEnv, profile.llm.openai.apiKeyEnv);
  profile.llm.openai.baseUrl = normalizeString(openai.baseUrl, profile.llm.openai.baseUrl);
  profile.llm.openai.reasoningEffort = normalizeChoice(
    openai.reasoningEffort,
    ['minimal', 'low', 'medium', 'high'],
    profile.llm.openai.reasoningEffort
  );

  profile.llm.lmstudio.baseUrl = normalizeString(lmstudio.baseUrl, profile.llm.lmstudio.baseUrl);
  profile.llm.lmstudio.model = normalizeString(lmstudio.model, profile.llm.lmstudio.model);
  profile.llm.lmstudio.apiTokenEnv = normalizeString(lmstudio.apiTokenEnv, profile.llm.lmstudio.apiTokenEnv);

  return profile;
}

function isLegacyProjectSettings(raw) {
  return Boolean(
    raw &&
      typeof raw === 'object' &&
      !Array.isArray(raw) &&
      (Object.prototype.hasOwnProperty.call(raw, 'dashboard') ||
        Object.prototype.hasOwnProperty.call(raw, 'benchmark') ||
        Object.prototype.hasOwnProperty.call(raw, 'mutationLoop') ||
        Object.prototype.hasOwnProperty.call(raw, 'llm'))
  );
}

function normalizeProjectSettingsConfig(raw) {
  const config = buildDefaultProjectSettings();
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) {
    return config;
  }

  if (isLegacyProjectSettings(raw)) {
    config.profiles.default = normalizeSettingsProfile(raw);
    return config;
  }

  const rawProfiles = raw.profiles;
  if (rawProfiles && typeof rawProfiles === 'object' && !Array.isArray(rawProfiles)) {
    for (const [name, value] of Object.entries(rawProfiles)) {
      const normalizedName = normalizeProfileName(name);
      if (!normalizedName) continue;
      config.profiles[normalizedName] = normalizeSettingsProfile(value);
    }
  }

  const activeProfile = normalizeProfileName(raw.activeProfile);
  if (activeProfile && Object.prototype.hasOwnProperty.call(config.profiles, activeProfile)) {
    config.activeProfile = activeProfile;
  }

  return config;
}

function resolveProjectSettingsConfig(config) {
  const normalizedConfig = normalizeProjectSettingsConfig(config);
  const activeProfile = normalizeProfileName(normalizedConfig.activeProfile) || 'default';
  const profile = normalizedConfig.profiles[activeProfile] || normalizedConfig.profiles.default;
  return normalizeSettingsProfile(profile);
}

async function readProjectSettingsConfig() {
  try {
    const text = await fsp.readFile(PROJECT_SETTINGS_FILE, 'utf8');
    const parsed = JSON.parse(text);
    return normalizeProjectSettingsConfig(parsed);
  } catch {
    return buildDefaultProjectSettings();
  }
}

async function readProjectSettings() {
  const config = await readProjectSettingsConfig();
  return resolveProjectSettingsConfig(config);
}

async function writeProjectSettings(raw) {
  const config = normalizeProjectSettingsConfig(raw);
  await fsp.writeFile(PROJECT_SETTINGS_FILE, `${JSON.stringify(config, null, 2)}\n`, 'utf8');
  return config;
}

function basenameSafe(filePath) {
  if (!filePath || typeof filePath !== 'string') return '';
  return path.basename(filePath);
}

function extractRunTag(description) {
  const match = String(description || '').match(/\brun\s+([^\s]+)/i);
  return match ? match[1] : '';
}

function parseRunTagMs(runTag) {
  const match = String(runTag || '').match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2})-(\d{2})-(\d{2})(?:-(\d{3}))?(Z)?/i);
  if (!match) return null;
  const [, year, month, day, hour, minute, second, millis = '000', isZulu = ''] = match;
  if (isZulu) {
    return Date.UTC(
      Number.parseInt(year, 10),
      Number.parseInt(month, 10) - 1,
      Number.parseInt(day, 10),
      Number.parseInt(hour, 10),
      Number.parseInt(minute, 10),
      Number.parseInt(second, 10),
      Number.parseInt(millis, 10)
    );
  }
  return new Date(
    Number.parseInt(year, 10),
    Number.parseInt(month, 10) - 1,
    Number.parseInt(day, 10),
    Number.parseInt(hour, 10),
    Number.parseInt(minute, 10),
    Number.parseInt(second, 10),
    Number.parseInt(millis, 10)
  ).getTime();
}

function resolveMutationLoopPaths(projectSettings) {
  const settings = projectSettings && typeof projectSettings === 'object' ? projectSettings : DEFAULT_SETTINGS_PROFILE;
  const mutationLoop = settings.mutationLoop || {};
  const loopDir = path.resolve(ROOT, normalizeString(mutationLoop.loopDir, DEFAULT_SETTINGS_PROFILE.mutationLoop.loopDir));
  const resultsFileSetting = normalizeString(mutationLoop.resultsFile, '');
  const resultsFile = resultsFileSetting ? path.resolve(ROOT, resultsFileSetting) : path.join(loopDir, 'results.tsv');
  return {
    loopDir,
    runsDir: path.join(loopDir, 'runs'),
    resultsFile,
  };
}

function extractRunMode(description) {
  const match = String(description || '').match(/\bmode=([^\s]+)/i);
  return match ? match[1] : '';
}

function extractSourcePath(description) {
  const match = String(description || '').match(/\bsource=([^\s]+)/i);
  return match ? match[1] : '';
}

function historyRunModeLabel(mode) {
  const raw = normalizeString(mode, '');
  switch (raw) {
    case 'copper_mutation':
    case 'copper_source_benchmark':
      return 'Legacy copper pair benchmark';
    case 'copper_benchmark':
      return 'Copper bars reference benchmark';
    default:
      break;
  }

  switch (normalizeRunMode(mode, raw)) {
    case 'corpus_validation':
      return 'Corpus validation';
    case 'copper_reference':
      return 'Copper bars reference benchmark';
    case 'copper_bars_asm':
      return 'Copper bars assembly benchmark';
    case 'copper_bars_suite':
      return 'Copper bars suite benchmark';
    case 'playfield_marker':
      return 'Playfield marker benchmark';
    case 'playfield_structure_control':
      return 'Playfield structure control';
    case 'copper_mutation_loop':
      return 'Copper mutation loop';
    case 'intentional_failure':
      return 'Legacy failure demo';
    case 'demo_success':
      return 'Legacy success demo';
    default:
      return raw || 'Unknown';
  }
}

async function listKickRoms() {
  try {
    const entries = await fsp.readdir(ROMS_DIR, { withFileTypes: true });
    return entries
      .filter((entry) => entry.isFile() && KICK_ROM_EXTENSIONS.has(path.extname(entry.name).toLowerCase()))
      .map((entry) => entry.name)
      .sort((a, b) => a.localeCompare(b));
  } catch {
    return [];
  }
}

async function parseMonitorResultsTsv() {
  await ensureFileWithHeader(RESULTS_TSV, RESULTS_HEADER);
  const text = await readTextSafe(RESULTS_TSV);
  const lines = text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length <= 1) return [];

  const rows = [];
  for (const line of lines.slice(1)) {
    const [commit = '', scoreRaw = '', status = '', ...rest] = line.split('\t');
    const description = rest.join('\t');
    rows.push({
      commit,
      score: safeParseFloat(scoreRaw),
      scoreRaw,
      status,
      description,
      runTag: extractRunTag(description),
      runMode: extractRunMode(description),
      sourcePath: extractSourcePath(description),
      line,
    });
  }
  return rows;
}

async function parseMutationLoopResultsTsv(projectSettings) {
  const { resultsFile, runsDir } = resolveMutationLoopPaths(projectSettings);
  const text = await readTextSafe(resultsFile);
  const lines = text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length <= 1) return [];

  const rows = [];
  for (const line of lines.slice(1)) {
    const [
      iterationRaw = '',
      scoreRaw = '',
      bestBeforeRaw = '',
      bestAfterRaw = '',
      status = '',
      mutationRaw = '',
      benchmarkOkRaw = '',
      evalCodeRaw = '',
      runDirRaw = '',
    ] = line.split('\t');
    const runDir = normalizeString(runDirRaw, '');
    const runTag = runDir ? path.basename(runDir) : '';
    const mutationField = normalizeString(mutationRaw, '');
    let mutator = 'mutation-loop';
    let mutationDescription = mutationField;
    const prefixMatch = mutationField.match(/^([a-z0-9_-]+):(.*)$/i);
    if (prefixMatch) {
      mutator = normalizeString(prefixMatch[1], mutator);
      mutationDescription = normalizeString(prefixMatch[2], mutationDescription);
    }
    const metadata = runDir ? await readJsonSafe(path.join(runDir, 'metadata.json')) : null;
    const sourceAbs =
      normalizeString(metadata?.mutable_entrypoint, '') || path.join(ROOT, DEFAULT_MUTATION_SOURCE_REL);
    const sourcePath = sourceAbs.startsWith(ROOT) ? path.relative(ROOT, sourceAbs) : sourceAbs;
    rows.push({
      commit: mutator,
      score: safeParseFloat(scoreRaw),
      scoreRaw,
      status,
      description: [
        `iteration ${iterationRaw || '?'}`,
        `mutator=${mutator}`,
        mutationDescription || 'unknown mutation',
        benchmarkOkRaw ? `benchmark=${benchmarkOkRaw}` : '',
        evalCodeRaw ? `eval=${evalCodeRaw}` : '',
      ]
        .filter(Boolean)
        .join(' | '),
      runTag,
      runMode: 'copper_mutation_loop',
      sourcePath,
      runDir: runDir || path.join(runsDir, runTag),
      line,
      iteration: Number.parseInt(iterationRaw, 10) || 0,
      bestBefore: safeParseFloat(bestBeforeRaw),
      bestAfter: safeParseFloat(bestAfterRaw),
      mutation: mutationDescription || mutationField,
      mutator,
    });
  }
  return rows;
}

function sortHistoryRows(rows) {
  return rows
    .map((row, index) => ({ row, index, ts: parseRunTagMs(row.runTag) }))
    .sort((a, b) => {
      if (a.ts != null && b.ts != null && a.ts !== b.ts) return a.ts - b.ts;
      if (a.ts != null && b.ts == null) return -1;
      if (a.ts == null && b.ts != null) return 1;
      return a.index - b.index;
    })
    .map((item) => item.row);
}

async function parseResultsTsv(projectSettings = null) {
  const settings = projectSettings || (await readProjectSettings());
  const [monitorRows, mutationRows] = await Promise.all([
    parseMonitorResultsTsv(),
    parseMutationLoopResultsTsv(settings),
  ]);
  return sortHistoryRows(monitorRows.concat(mutationRows));
}

async function clearHistoryData(projectSettings = null) {
  const settings = projectSettings || (await readProjectSettings());
  const monitorRows = await parseMonitorResultsTsv();
  const mutationRows = await parseMutationLoopResultsTsv(settings);
  await ensureFileWithHeader(RESULTS_TSV, RESULTS_HEADER);
  await fsp.writeFile(RESULTS_TSV, RESULTS_HEADER, 'utf8');

  const { resultsFile } = resolveMutationLoopPaths(settings);
  await fsp.mkdir(path.dirname(resultsFile), { recursive: true });
  await fsp.writeFile(resultsFile, MUTATION_RESULTS_HEADER, 'utf8');

  return {
    clearedMonitorRows: monitorRows.length,
    clearedMutationRows: mutationRows.length,
    clearedTotalRows: monitorRows.length + mutationRows.length,
    mutationResultsFile: path.relative(ROOT, resultsFile),
  };
}

function resultTrackKey(runMode, sourcePath = '') {
  let mode = String(runMode || '').trim();
  if (mode === 'copper_mutation_loop') mode = 'copper_mutation';
  if (!mode) return '';
  if (mode === 'copper_mutation' || mode === 'copper_source_benchmark') {
    return `${mode}::${String(sourcePath || '').trim()}`;
  }
  return mode;
}

function computeBestScore(rows, trackKey = '') {
  let best = null;
  for (const row of rows) {
    if (trackKey) {
      const rowTrackKey = resultTrackKey(row.runMode, row.sourcePath);
      if (rowTrackKey !== trackKey) continue;
    }
    if (row.score == null) continue;
    if (best == null || row.score > best) best = row.score;
  }
  return best;
}

async function appendResultRow({ commit, score, status, description }) {
  await ensureFileWithHeader(RESULTS_TSV, RESULTS_HEADER);
  const scoreText = Number.isFinite(score) ? score.toFixed(6) : '0.000000';
  const line = `${commit}\t${scoreText}\t${status}\t${description}\n`;
  await fsp.appendFile(RESULTS_TSV, line, 'utf8');
  return line.trimEnd();
}

function trimLogTail(lines, maxLines = 350) {
  if (lines.length <= maxLines) return lines;
  return lines.slice(lines.length - maxLines);
}

function pushLiveLog(line) {
  if (!state.current) return;
  state.current.logTail.push(line);
  state.current.logTail = trimLogTail(state.current.logTail, 500);
}

function runProcess(command, args, options = {}) {
  return new Promise((resolve) => {
    const startMs = Date.now();
    let stdout = '';
    let stderr = '';
    let stdoutBuffer = '';
    let stderrBuffer = '';

    const child = spawn(command, args, {
      cwd: options.cwd || ROOT,
      env: { ...process.env, ...(options.env || {}) },
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    const flushBuffer = (buffer, isErr) => {
      if (!buffer) return '';
      const lines = buffer.split(/\r?\n/);
      const remainder = lines.pop() || '';
      for (const line of lines) {
        const prefix = options.prefix ? `${options.prefix} ` : '';
        const tagged = `${prefix}${line}`;
        if (options.onLine) options.onLine(tagged, isErr ? 'stderr' : 'stdout');
      }
      return remainder;
    };

    child.stdout.on('data', (chunk) => {
      const text = chunk.toString('utf8');
      stdout += text;
      stdoutBuffer += text;
      stdoutBuffer = flushBuffer(stdoutBuffer, false);
    });

    child.stderr.on('data', (chunk) => {
      const text = chunk.toString('utf8');
      stderr += text;
      stderrBuffer += text;
      stderrBuffer = flushBuffer(stderrBuffer, true);
    });

    child.on('error', (err) => {
      const seconds = (Date.now() - startMs) / 1000;
      resolve({
        code: 127,
        stdout,
        stderr: `${stderr}\n${String(err)}`,
        seconds,
        failedToStart: true,
      });
    });

    child.on('close', (code) => {
      if (stdoutBuffer) {
        const prefix = options.prefix ? `${options.prefix} ` : '';
        if (options.onLine) options.onLine(`${prefix}${stdoutBuffer}`, 'stdout');
      }
      if (stderrBuffer) {
        const prefix = options.prefix ? `${options.prefix} ` : '';
        if (options.onLine) options.onLine(`${prefix}${stderrBuffer}`, 'stderr');
      }

      const seconds = (Date.now() - startMs) / 1000;
      resolve({ code: code ?? 1, stdout, stderr, seconds, failedToStart: false });
    });
  });
}

async function copyIfExists(src, dst) {
  try {
    await fsp.copyFile(src, dst);
    return true;
  } catch {
    return false;
  }
}

async function getGitCommitShort() {
  const proc = await runProcess('git', ['rev-parse', '--short', 'HEAD'], { cwd: ROOT });
  if (proc.code !== 0) return 'unknown';
  return (proc.stdout || '').trim() || 'unknown';
}

function getRunModePreset(mode) {
  const normalized = normalizeRunMode(mode, 'corpus_validation');
  return RUN_MODE_PRESETS[normalized] || RUN_MODE_PRESETS.corpus_validation;
}

function isBenchmarkRunMode(mode) {
  return getRunModePreset(mode).kind !== 'corpus';
}

function benchmarkEvalScriptForMode(mode) {
  return getRunModePreset(mode).script || AMIGA_BENCHMARK_EVAL_SCRIPT;
}

function buildEvalArgsForMode(mode) {
  const preset = getRunModePreset(mode);
  const scriptPath = path.relative(ROOT, preset.script || AMIGA_EVAL_SCRIPT);
  const args = [scriptPath];
  if (preset.benchmarkConfig) {
    args.push('--benchmark-config', preset.benchmarkConfig);
  }
  return args;
}

function benchmarkArtifactsFromReport(report) {
  if (!report || typeof report !== 'object') return [];

  const artifacts = [];
  const pushArtifacts = (benchmark, prefix = 'benchmark') => {
    if (!benchmark || typeof benchmark !== 'object') return;
    const mapping = [
      ['capture_image', `${prefix}_capture.png`],
      ['capture_crop_image', `${prefix}_capture_crop.png`],
      ['capture_diff_image', `${prefix}_capture_diff.png`],
    ];
    for (const [key, targetName] of mapping) {
      const sourcePath = normalizeString(benchmark[key], '');
      if (sourcePath) artifacts.push({ sourcePath, targetName });
    }
  };

  pushArtifacts(report.benchmark);

  if (Array.isArray(report.components)) {
    const labeled = report.components.find(
      (component) => component?.label === 'full' && component?.report?.benchmark
    );
    const firstWithBenchmark = report.components.find((component) => component?.report?.benchmark);
    const primary = labeled || firstWithBenchmark || null;
    if (primary?.report?.benchmark) {
      pushArtifacts(primary.report.benchmark);
    }
  }

  return artifacts;
}

function reportDiskImageSource(report) {
  const direct = normalizeString(report?.disk_image, '');
  if (direct) return direct;
  if (Array.isArray(report?.components)) {
    for (const component of report.components) {
      const nested = normalizeString(component?.report?.disk_image, '');
      if (nested) return nested;
    }
  }
  return '';
}

function reportKickRomSource(report) {
  const direct = normalizeString(report?.kick_rom, '');
  if (direct) return direct;
  if (Array.isArray(report?.components)) {
    for (const component of report.components) {
      const nested = normalizeString(component?.report?.kick_rom, '');
      if (nested) return nested;
    }
  }
  return '';
}

function buildSelectArgs(job, iterationIdx) {
  const args = ['amiga_workspace/corpus/scripts/select_source.py', '--manifest', RUNNABLE_MANIFEST_REL];
  if (job.contains) args.push('--contains', job.contains);
  if (Number.isInteger(job.index) && job.index > 0) args.push('--index', String(job.index));

  const seedValue = Number.isInteger(job.seed) ? job.seed + iterationIdx : 0;
  if (seedValue > 0) args.push('--seed', String(seedValue));

  if (job.allowIncludes) args.push('--allow-includes');
  if (job.allowNonentry) args.push('--allow-nonentry');
  return args;
}

async function ensureRunnableManifest(logLine) {
  const baseStat = await statSafe(CORPUS_MANIFEST);
  if (!baseStat) {
    throw new Error(
      `missing ${CORPUS_MANIFEST_REL}. Run: python3 amiga_workspace/corpus/scripts/index_raw_sources.py --refresh`
    );
  }

  const runnableStat = await statSafe(RUNNABLE_MANIFEST);
  const needsBuild = !runnableStat || runnableStat.mtimeMs < baseStat.mtimeMs;
  if (!needsBuild) {
    const hasRows = await manifestHasRows(RUNNABLE_MANIFEST);
    if (!hasRows) {
      throw new Error(
        `no runnable rows in ${RUNNABLE_MANIFEST_REL}. Add verify-clean corpus files or rebuild runnable manifest.`
      );
    }
    return;
  }

  if (logLine) logLine(`[manifest] rebuilding ${RUNNABLE_MANIFEST_REL}`);
  const result = await runProcess(
    'python3',
    [BUILD_RUNNABLE_MANIFEST_SCRIPT, '--manifest', CORPUS_MANIFEST_REL, '--output', RUNNABLE_MANIFEST_REL],
    {
      cwd: ROOT,
      prefix: '[manifest]',
      onLine: (line) => {
        if (logLine) logLine(line);
      },
    }
  );

  if (result.code !== 0) {
    throw new Error(`failed to build ${RUNNABLE_MANIFEST_REL} (exit=${result.code})`);
  }

  const hasRows = await manifestHasRows(RUNNABLE_MANIFEST);
  if (!hasRows) {
    throw new Error(
      `built ${RUNNABLE_MANIFEST_REL} but it has no runnable rows (verify exit=0 candidates missing)`
    );
  }
}

async function executeIteration(job, iterationIdx) {
  const runTag = `${new Date().toISOString().replace(/[:.]/g, '-')}-${state.nextRunId++}`;
  const runDir = path.join(RUNS_DIR, runTag);
  await fsp.mkdir(runDir, { recursive: true });

  state.current = {
    jobId: job.id,
    iteration: iterationIdx + 1,
      totalIterations: job.iterations,
      phase: 'prepare',
      startedAt: nowIso(),
      runTag,
      runMode: job.runMode,
      runModeLabel: getRunModePreset(job.runMode).label,
      kickRom: job.kickRom || null,
      logTail: [],
    };

  pushLiveLog(`[monitor] run ${runTag} started`);

  let selectionResult = null;
  if (isBenchmarkRunMode(job.runMode)) {
    pushLiveLog(`[benchmark] using ${getRunModePreset(job.runMode).label}`);
  } else if (job.autoSelect) {
    state.current.phase = 'build-runnable-manifest';
    await ensureRunnableManifest((line) => pushLiveLog(line));

    state.current.phase = 'select-source';
    const selectArgs = buildSelectArgs(job, iterationIdx);
    pushLiveLog(`[select] python3 ${selectArgs.join(' ')}`);

    selectionResult = await runProcess('python3', selectArgs, {
      cwd: ROOT,
      prefix: '[select]',
      onLine: (line) => pushLiveLog(line),
    });

    await fsp.writeFile(
      path.join(runDir, 'select.log'),
      `${selectionResult.stdout}\n${selectionResult.stderr}`,
      'utf8'
    );

    if (selectionResult.code !== 0) {
      pushLiveLog(`[select] failed with code ${selectionResult.code}`);
    }
  }

  const evalArgs = isBenchmarkRunMode(job.runMode)
    ? buildEvalArgsForMode(job.runMode)
    : [path.relative(ROOT, AMIGA_EVAL_SCRIPT)];
  const evalScriptRel = evalArgs[0];
  state.current.phase = isBenchmarkRunMode(job.runMode) ? 'benchmark-evaluate' : 'evaluate';
  pushLiveLog(`[eval] python3 ${evalArgs.join(' ')}`);
  const evalEnv = {};
  Object.assign(evalEnv, getRunModePreset(job.runMode).env);
  if (job.kickRom) {
    evalEnv.AMIGA_KICK_ROM_NAME = job.kickRom;
    evalEnv.AMIGA_ROMS_DIR = ROMS_DIR;
    pushLiveLog(`[eval] kick rom ${job.kickRom}`);
  }
  const evalResult = await runProcess('python3', evalArgs, {
    cwd: ROOT,
    prefix: '[eval]',
    env: evalEnv,
    onLine: (line) => pushLiveLog(line),
  });

  await fsp.writeFile(path.join(runDir, 'eval.log'), `${evalResult.stdout}\n${evalResult.stderr}`, 'utf8');

  const report = await readJsonSafe(REPORT_JSON);
  const selected = await readJsonSafe(SELECTED_SOURCE_JSON);
  const vamiga = await readJsonSafe(VAMIGA_REPORT_JSON);
  const commit = await getGitCommitShort();
  const selectedPath = selected?.entry?.source_rel || 'unknown-source';
  const kickRomUsed = basenameSafe(report?.kick_rom) || job.kickRom || 'unknown-rom';
  const projectSettings = await readProjectSettings();
  const historyBeforeAppend = await parseResultsTsv(projectSettings);
  const trackKey = resultTrackKey(job.runMode, selectedPath);
  const bestBefore = computeBestScore(historyBeforeAppend, trackKey);

  const score = report && Number.isFinite(report.score) ? report.score : null;
  let status = 'crash';
  if (score != null) {
    status = bestBefore == null || score > bestBefore ? 'keep' : 'discard';
  }

  const description = `${status} run ${runTag} mode=${job.runMode} source=${selectedPath} rom=${kickRomUsed}`;
  const appended = await appendResultRow({
    commit,
    score: score ?? 0,
    status,
    description,
  });

  await copyIfExists(REPORT_JSON, path.join(runDir, 'report.json'));
  await copyIfExists(SELECTED_SOURCE_JSON, path.join(runDir, 'selected_source.json'));
  await copyIfExists(VAMIGA_REPORT_JSON, path.join(runDir, 'vamigaweb_report.json'));
  const diskImageSource = reportDiskImageSource(report);
  if (diskImageSource) {
    await copyIfExists(path.resolve(ROOT, diskImageSource), path.join(runDir, ARCHIVED_DISK_IMAGE));
  }
  await copyIfExists(EMULATOR_CAPTURE_PNG, path.join(runDir, 'emulator_capture.png'));
  const reportBenchmarkArtifacts = benchmarkArtifactsFromReport(report);
  for (const artifact of reportBenchmarkArtifacts) {
    await copyIfExists(path.resolve(ROOT, artifact.sourcePath), path.join(runDir, artifact.targetName));
  }
  const archivedArtifactNames = new Set(reportBenchmarkArtifacts.map((artifact) => artifact.targetName));
  if (!archivedArtifactNames.has('benchmark_capture.png')) {
    await copyIfExists(BENCHMARK_CAPTURE_PNG, path.join(runDir, 'benchmark_capture.png'));
  }
  if (!archivedArtifactNames.has('benchmark_capture_crop.png')) {
    await copyIfExists(BENCHMARK_CAPTURE_CROP_PNG, path.join(runDir, 'benchmark_capture_crop.png'));
  }
  if (!archivedArtifactNames.has('benchmark_capture_diff.png')) {
    await copyIfExists(BENCHMARK_CAPTURE_DIFF_PNG, path.join(runDir, 'benchmark_capture_diff.png'));
  }
  for (const [key, src] of Object.entries(LOG_FILES)) {
    await copyIfExists(src, path.join(runDir, `${key}.log`));
  }

  const metadata = {
    runTag,
    jobId: job.id,
    iteration: iterationIdx + 1,
    totalIterations: job.iterations,
    startedAt: state.current.startedAt,
    finishedAt: nowIso(),
    phaseResult: {
      selectionCode: selectionResult ? selectionResult.code : null,
      evaluateCode: evalResult.code,
    },
    commit,
    score,
    status,
    selectedSource: selectedPath,
    runMode: job.runMode,
    runModeLabel: getRunModePreset(job.runMode).label,
    kickRom: kickRomUsed,
    resultRow: appended,
    reportSummary: report
      ? {
          assembled: report.assembled,
          packaged: report.packaged,
          emulator_ok: report.emulator_ok,
          verify_ok: report.verify_ok,
          checks_passed: report.checks_passed,
          checks_total: report.checks_total,
          report_mode: report.report_mode || 'default',
          benchmark_name: report.benchmark?.name || null,
          benchmark_similarity: report.benchmark?.similarity ?? null,
        }
      : null,
    vamigaSummary: vamiga
      ? {
          ready: vamiga.ready,
          hasDiskDf0: vamiga.hasDiskDf0,
          cpuCycles: vamiga.cpuCycles,
        }
      : null,
  };

  await fsp.writeFile(path.join(runDir, 'metadata.json'), JSON.stringify(metadata, null, 2), 'utf8');

  state.lastCompleted = metadata;
  state.current.phase = 'done';
  pushLiveLog(`[monitor] run ${runTag} completed with status=${status} score=${score ?? 'n/a'}`);

  return metadata;
}

async function processQueue() {
  if (state.running) return;
  state.running = true;

  try {
    while (state.queue.length > 0) {
      const job = state.queue.shift();
      for (let i = 0; i < job.iterations; i += 1) {
        await executeIteration(job, i);
      }
    }
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    if (state.current) {
      state.lastCompleted = {
        runTag: state.current.runTag,
        jobId: state.current.jobId,
        iteration: state.current.iteration,
        totalIterations: state.current.totalIterations,
        startedAt: state.current.startedAt,
        finishedAt: nowIso(),
        status: 'crash',
        error: message,
      };
      pushLiveLog(`[monitor] run failed: ${message}`);
    }
    throw err;
  } finally {
    state.running = false;
    state.current = null;
  }
}

async function loadRecentRuns(limit = 30) {
  try {
    const entries = await fsp.readdir(RUNS_DIR, { withFileTypes: true });
    const dirs = entries
      .filter((e) => e.isDirectory())
      .map((e) => e.name)
      .sort()
      .reverse();

    const out = [];
    for (const dir of dirs.slice(0, limit)) {
      const metadata = await readJsonSafe(path.join(RUNS_DIR, dir, 'metadata.json'));
      if (metadata) out.push(metadata);
    }
    return out;
  } catch {
    return [];
  }
}

async function enrichHistoryRow(row) {
  const runTag = normalizeString(row.runTag, '') || extractRunTag(row.description);
  const runMode = normalizeString(row.runMode, '') || extractRunMode(row.description);
  const runModeLabel = historyRunModeLabel(runMode);
  let metadata = null;
  let report = null;
  if (!runTag) {
    return {
      ...row,
      runTag: '',
      runMode,
      runModeLabel,
      resultLabel: 'unknown',
      resultOk: false,
      reportMode: '',
      screenshotUrl: '',
    };
  }

  const isMutationLoop = runMode === 'copper_mutation_loop';
  const runDir = normalizeString(row.runDir, '') || path.join(RUNS_DIR, runTag);
  metadata = await readJsonSafe(path.join(runDir, 'metadata.json'));
  report = await readJsonSafe(path.join(runDir, 'report.json'));
  const candidates = ['benchmark_capture.png', 'benchmark_capture_crop.png', 'emulator_capture.png'];
  let screenshotUrl = '';
  for (const filename of candidates) {
    const stat = await statSafe(path.join(runDir, filename));
    if (stat && stat.isFile()) {
      screenshotUrl = isMutationLoop
        ? `/artifacts/mutation-loop/${encodeURIComponent(runTag)}/${filename}`
        : `/artifacts/runs/${encodeURIComponent(runTag)}/${filename}`;
      break;
    }
  }

  const reportMode = String(report?.report_mode || '');
  const isBenchmark = reportMode === 'benchmark' || reportMode === 'benchmark_suite';
  const resultOk = Boolean(report?.verify_ok);
  const resultLabel = isBenchmark
    ? resultOk
      ? 'benchmark passed'
      : 'benchmark failed'
    : report
      ? resultOk
        ? 'verify passed'
        : 'verify failed'
      : 'unknown';

  return {
    ...row,
    runTag,
    runMode,
    runModeLabel,
    jobId: metadata?.jobId ?? row.jobId ?? null,
    iteration: Number.isInteger(metadata?.iteration) ? metadata.iteration : row.iteration ?? null,
    totalIterations: Number.isInteger(metadata?.totalIterations)
      ? metadata.totalIterations
      : row.totalIterations ?? null,
    selectedSource: normalizeString(metadata?.selectedSource, row.selectedSource || row.sourcePath || ''),
    kickRom: normalizeString(metadata?.kickRom, row.kickRom || ''),
    resultLabel,
    resultOk,
    reportMode,
    screenshotUrl,
  };
}

async function enrichHistoryRows(rows) {
  const out = [];
  for (const row of rows) {
    out.push(await enrichHistoryRow(row));
  }
  return out;
}

async function latestRunArtifacts(runTag) {
  const normalized = normalizeString(runTag, '');
  if (!normalized) return { nativeReplayNote: '' };
  const runDir = path.join(RUNS_DIR, normalized);
  const candidates = ['benchmark_capture.png', 'benchmark_capture_crop.png', 'emulator_capture.png'];
  return {
    nativeReplayNote:
      'Replays the archived run in native vAmiga using the archived ROM, archived disk image, and a RetroShell boot script.',
  };
}

async function buildStatePayload() {
  const [projectSettings, report, selected, recentRuns, kickRoms, dashboardVersion] = await Promise.all([
    readProjectSettings(),
    readJsonSafe(REPORT_JSON),
    readJsonSafe(SELECTED_SOURCE_JSON),
    loadRecentRuns(25),
    listKickRoms(),
    readDashboardVersion(),
  ]);
  const history = await enrichHistoryRows((await parseResultsTsv(projectSettings)).slice(-80).reverse());
  const latestRunTagForArtifacts = normalizeString(state.lastCompleted?.runTag, '') || normalizeString(history[0]?.runTag, '');
  const latestArtifacts = await latestRunArtifacts(latestRunTagForArtifacts);
  const latestKickRom = basenameSafe(report?.kick_rom) || null;
  const configuredKickRom = normalizeString(projectSettings?.dashboard?.defaults?.kickRom, '');
  const defaultKickRom = configuredKickRom && kickRoms.includes(configuredKickRom) ? configuredKickRom : kickRoms[0] || null;
  const waitingIterations = state.queue.reduce(
    (sum, job) => sum + (Number.isInteger(job.iterations) ? job.iterations : 0),
    0
  );
  const currentRemainingIterations =
    state.current &&
    Number.isInteger(state.current.iteration) &&
    Number.isInteger(state.current.totalIterations)
      ? Math.max(state.current.totalIterations - state.current.iteration, 0)
      : 0;

  return {
    now: nowIso(),
    dashboardVersion,
    runModes: listRunModes(),
    running: state.running,
    queueLength: state.queue.length,
    pendingIterations: waitingIterations + currentRemainingIterations,
    current: state.current,
    lastCompleted: state.lastCompleted,
    latestReport: report,
    latestSelection: selected,
    latestKickRom,
    latestNativeReplayNote: latestArtifacts.nativeReplayNote,
    kickRoms,
    defaultKickRom: latestKickRom || defaultKickRom,
    history,
    recentRuns,
  };
}

async function main() {
  await ensureDirs();

  const app = express();
  const monitorApiToken = (process.env.MONITOR_API_TOKEN || '').trim();
  app.use(express.json({ limit: '1mb' }));
  app.get(/^\/how-to$/, (_req, res) => {
    res.redirect('/how-to/');
  });
  app.get('/how-to/overview', (_req, res) => {
    res.redirect('/overview.html');
  });
  app.get('/how-to/project-structure', (_req, res) => {
    res.redirect('/project-structure.html');
  });
  app.get('/how-to/corpus', (_req, res) => {
    res.redirect('/corpus.html');
  });
  app.get('/how-to/settings', (_req, res) => {
    res.redirect('/settings-guide.html');
  });
  app.get('/how-to/agentic', (_req, res) => {
    res.redirect('/agentic.html');
  });
  app.get('/how-to/credits', (_req, res) => {
    res.redirect('/credits.html');
  });
  app.get('/settings', (_req, res) => {
    res.redirect('/settings.html');
  });
  app.use(express.static(PUBLIC_DIR));
  app.use('/assets', express.static(ASSETS_DIR));
  app.use('/artifacts/runs', express.static(RUNS_DIR));
  app.get('/artifacts/mutation-loop/:runTag/:filename', async (req, res) => {
    const { runTag, filename } = req.params;
    if (path.basename(runTag) !== runTag || path.basename(filename) !== filename) {
      res.status(400).end('invalid artifact path');
      return;
    }
    const settings = await readProjectSettings();
    const { runsDir } = resolveMutationLoopPaths(settings);
    const filePath = path.join(runsDir, runTag, filename);
    if (!filePath.startsWith(path.join(runsDir, runTag))) {
      res.status(400).end('invalid artifact path');
      return;
    }
    const stat = await statSafe(filePath);
    if (!stat || !stat.isFile()) {
      res.status(404).end('not found');
      return;
    }
    res.sendFile(filePath);
  });

  function requireRunControlAuth(req, res, next) {
    if (!monitorApiToken) {
      next();
      return;
    }
    const provided = (req.get('x-monitor-token') || '').trim();
    if (provided && provided === monitorApiToken) {
      next();
      return;
    }
    res.status(401).json({ error: 'unauthorized' });
  }

  app.get('/api/state', async (_req, res) => {
    res.json(await buildStatePayload());
  });

  app.get('/api/version', async (_req, res) => {
    res.json({ dashboardVersion: await readDashboardVersion() });
  });

app.get('/api/settings', async (_req, res) => {
    const [settings, kickRoms, dashboardVersion] = await Promise.all([
      readProjectSettingsConfig(),
      listKickRoms(),
      readDashboardVersion(),
    ]);
    res.json({
      settings,
      effectiveSettings: resolveProjectSettingsConfig(settings),
      defaults: deepClone(DEFAULT_PROJECT_SETTINGS),
      runModes: listRunModes(),
      kickRoms,
      settingsPath: path.relative(ROOT, PROJECT_SETTINGS_FILE),
      dashboardVersion,
    });
  });

  app.get('/api/history', async (_req, res) => {
    const rows = await parseResultsTsv(await readProjectSettings());
    res.json({ rows: await enrichHistoryRows(rows.reverse()) });
  });

  app.post('/api/history/clear', requireRunControlAuth, async (_req, res) => {
    if (state.running) {
      res.status(409).json({ error: 'cannot clear history while a run is active' });
      return;
    }
    const summary = await clearHistoryData(await readProjectSettings());
    res.json(summary);
  });

  app.get('/api/runs', async (_req, res) => {
    res.json({ runs: await loadRecentRuns(120) });
  });

  app.get('/api/log/:name', async (req, res) => {
    const key = req.params.name;
    if (!Object.prototype.hasOwnProperty.call(LOG_FILES, key)) {
      res.status(404).json({ error: 'unknown log' });
      return;
    }
    res.type('text/plain').send(await readTextSafe(LOG_FILES[key]));
  });

  app.get('/api/run/:runTag', async (req, res) => {
    const runTag = req.params.runTag;
    const runDir = path.join(RUNS_DIR, runTag);
    const meta = await readJsonSafe(path.join(runDir, 'metadata.json'));
    if (!meta) {
      res.status(404).json({ error: 'run not found' });
      return;
    }
    const evalLog = await readTextSafe(path.join(runDir, 'eval.log'));
    res.json({ metadata: meta, evalLogTail: evalLog.split(/\r?\n/).slice(-120).join('\n') });
  });

  app.post('/api/run', requireRunControlAuth, async (req, res) => {
    const body = req.body || {};
    const iterations = Number.isInteger(body.iterations) ? body.iterations : 1;
    if (iterations < 1 || iterations > 200) {
      res.status(400).json({ error: 'iterations must be between 1 and 200' });
      return;
    }
    const kickRom = typeof body.kickRom === 'string' ? body.kickRom.trim() : '';
    if (kickRom) {
      const availableRoms = await listKickRoms();
      if (!availableRoms.includes(kickRom)) {
        res.status(400).json({ error: 'unknown kick rom selection' });
        return;
      }
    }

    const job = {
      id: state.nextJobId++,
      queuedAt: nowIso(),
      iterations,
      runMode: normalizeRunMode(body.runMode, 'corpus_validation'),
      autoSelect: body.autoSelect !== false,
      contains: typeof body.contains === 'string' ? body.contains.trim() : '',
      index: Number.isInteger(body.index) ? body.index : 0,
      seed: Number.isInteger(body.seed) ? body.seed : 0,
      allowIncludes: body.allowIncludes === true,
      allowNonentry: body.allowNonentry === true,
      kickRom,
    };

    state.queue.push(job);
    processQueue().catch((err) => {
      console.error('[monitor] queue failure', err);
      state.running = false;
      state.current = null;
    });

    res.json({ accepted: true, job, queueLength: state.queue.length });
  });

  app.post('/api/queue/clear', requireRunControlAuth, (_req, res) => {
    const cleared = state.queue.length;
    state.queue = [];
    res.json({ cleared });
  });

  app.post('/api/settings', requireRunControlAuth, async (req, res) => {
    const raw = Object.prototype.hasOwnProperty.call(req.body || {}, 'settings') ? req.body.settings : req.body;
    const settings = await writeProjectSettings(raw);
    const [kickRoms, dashboardVersion] = await Promise.all([listKickRoms(), readDashboardVersion()]);
    res.json({
      saved: true,
      settings,
      effectiveSettings: resolveProjectSettingsConfig(settings),
      defaults: deepClone(DEFAULT_PROJECT_SETTINGS),
      runModes: listRunModes(),
      kickRoms,
      settingsPath: path.relative(ROOT, PROJECT_SETTINGS_FILE),
      dashboardVersion,
    });
  });

  const port = Number.parseInt(process.env.MONITOR_PORT || '4173', 10);
  const host = (process.env.MONITOR_HOST || '127.0.0.1').trim() || '127.0.0.1';
  app.listen(port, host, () => {
    const printedHost = host === '0.0.0.0' ? 'localhost' : host;
    console.log(`[monitor] listening on http://${printedHost}:${port}`);
    if (monitorApiToken) {
      console.log('[monitor] run-control endpoints require x-monitor-token');
  }
});

app.post('/api/open-vamiga', async (req, res) => {
  try {
    const requestedRunTag = normalizeString(req.body?.runTag, '');
    let runTag = requestedRunTag || normalizeString(state.lastCompleted?.runTag, '');
    if (!runTag) {
      const projectSettings = await readProjectSettings();
      const history = await enrichHistoryRows((await parseResultsTsv(projectSettings)).slice(-1).reverse());
      runTag = normalizeString(history[0]?.runTag, '');
    }
    if (!runTag) {
      res.status(400).json({ error: 'No completed run is available yet.' });
      return;
    }

    const replayTool = path.join(ROOT, 'tools', 'replay_archived_run.py');
    const replayProc = await runProcess('python3', [replayTool, '--run-tag', runTag, '--settle-seconds', '4'], { cwd: ROOT });
    if (replayProc.code !== 0) {
      throw new Error((replayProc.stderr || replayProc.stdout || '').trim() || `replay exited with code ${replayProc.code}`);
    }

    res.json({ launched: true, runTag, stdout: replayProc.stdout.trim() });
  } catch (err) {
    res.status(500).json({ error: err instanceof Error ? err.message : String(err) });
  }
});
}

main().catch((err) => {
  console.error('[monitor] fatal', err);
  process.exit(1);
});
