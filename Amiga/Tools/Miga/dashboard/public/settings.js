const $ = (id) => document.getElementById(id);

let monitorToken = '';
let settingsConfig = null;
let defaultConfig = null;
let availableKickRoms = [];

{
  const params = new URLSearchParams(window.location.search);
  const fromQuery = params.get('token');
  if (fromQuery) {
    monitorToken = fromQuery.trim();
    window.localStorage.setItem('monitorApiToken', monitorToken);
  } else {
    monitorToken = (window.localStorage.getItem('monitorApiToken') || '').trim();
  }
}

const el = {
  settingsPath: $('settingsPath'),
  versionPill: $('versionPill'),
  tokenPill: $('tokenPill'),
  dashboardVersion: $('dashboardVersion'),
  feedback: $('settingsFeedback'),
  activeProfile: $('activeProfile'),
  newProfileName: $('newProfileName'),
  activateProfile: $('activateProfile'),
  createProfile: $('createProfile'),
  deleteProfile: $('deleteProfile'),
  profileSummary: $('profileSummary'),
  saveSettings: $('saveSettings'),
  resetSettings: $('resetSettings'),
  reloadSettings: $('reloadSettings'),
  terminalPreview: $('terminalPreview'),
  dashboardIterations: $('dashboardIterations'),
  dashboardSeed: $('dashboardSeed'),
  dashboardRunMode: $('dashboardRunMode'),
  dashboardKickRom: $('dashboardKickRom'),
  dashboardSourceFilter: $('dashboardSourceFilter'),
  dashboardManifestIndex: $('dashboardManifestIndex'),
  dashboardAutoSelect: $('dashboardAutoSelect'),
  dashboardAllowIncludes: $('dashboardAllowIncludes'),
  dashboardAllowNonentry: $('dashboardAllowNonentry'),
  benchmarkKickRomName: $('benchmarkKickRomName'),
  benchmarkKickRomDir: $('benchmarkKickRomDir'),
  mutationIterations: $('mutationIterations'),
  mutationSeed: $('mutationSeed'),
  mutationMutator: $('mutationMutator'),
  mutationStrategy: $('mutationStrategy'),
  mutationCandidateBudget: $('mutationCandidateBudget'),
  mutationPlateauRepeatLimit: $('mutationPlateauRepeatLimit'),
  mutationBenchmarkConfig: $('mutationBenchmarkConfig'),
  mutationEvalScript: $('mutationEvalScript'),
  mutationLoopDir: $('mutationLoopDir'),
  mutationResultsFile: $('mutationResultsFile'),
  mutationImageHashCacheFile: $('mutationImageHashCacheFile'),
  openaiModel: $('openaiModel'),
  openaiApiKeyEnv: $('openaiApiKeyEnv'),
  openaiBaseUrl: $('openaiBaseUrl'),
  openaiReasoningEffort: $('openaiReasoningEffort'),
  lmstudioBaseUrl: $('lmstudioBaseUrl'),
  lmstudioModel: $('lmstudioModel'),
  lmstudioApiTokenEnv: $('lmstudioApiTokenEnv'),
};

function deepClone(value) {
  return JSON.parse(JSON.stringify(value));
}

function normalizeProfileName(value) {
  const text = String(value || '').trim();
  return /^[a-z0-9][a-z0-9_-]{0,63}$/i.test(text) ? text : '';
}

function shellQuote(value) {
  return `'${String(value).replaceAll("'", "'\\''")}'`;
}

function setSelectOptions(select, values, emptyLabel) {
  if (!select) return;
  const current = String(select.value || '').trim();
  select.innerHTML = '';
  if (emptyLabel) {
    const emptyOption = document.createElement('option');
    emptyOption.value = '';
    emptyOption.textContent = emptyLabel;
    select.appendChild(emptyOption);
  }
  for (const value of values) {
    const text = String(value || '').trim();
    if (!text) continue;
    const option = document.createElement('option');
    option.value = text;
    option.textContent = text;
    if (current === text) option.selected = true;
    select.appendChild(option);
  }
}

function setSelectValue(select, value) {
  if (!select) return;
  const desired = String(value || '').trim();
  if (!desired) {
    select.value = '';
    return;
  }
  const found = Array.from(select.options).some((option) => option.value === desired);
  if (!found) {
    const option = document.createElement('option');
    option.value = desired;
    option.textContent = desired;
    select.appendChild(option);
  }
  select.value = desired;
}

function setProfileOptions(config) {
  const select = el.activeProfile;
  if (!select) return;
  const active = String(config?.activeProfile || 'default').trim() || 'default';
  const names = Object.keys(config?.profiles || {}).sort((a, b) => a.localeCompare(b));
  select.innerHTML = '';
  for (const name of names) {
    const option = document.createElement('option');
    option.value = name;
    option.textContent = name;
    if (name === active) option.selected = true;
    select.appendChild(option);
  }
}

function intValue(node, fallback) {
  const parsed = Number.parseInt(node?.value || '', 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function stringValue(node) {
  return String(node?.value || '').trim();
}

function boolValue(node) {
  return !!node?.checked;
}

function activeProfileName(config = settingsConfig) {
  const selected = String(el.activeProfile?.value || '').trim();
  if (selected) return selected;
  return String(config?.activeProfile || 'default').trim() || 'default';
}

function collectProfileSettings() {
  return {
    dashboard: {
      defaults: {
        iterations: intValue(el.dashboardIterations, 1),
        seed: intValue(el.dashboardSeed, 0),
        runMode: stringValue(el.dashboardRunMode) || 'copper_mutation',
        sourceFilter: stringValue(el.dashboardSourceFilter),
        manifestIndex: intValue(el.dashboardManifestIndex, 0),
        kickRom: stringValue(el.dashboardKickRom),
        autoSelect: boolValue(el.dashboardAutoSelect),
        allowIncludes: boolValue(el.dashboardAllowIncludes),
        allowNonentry: boolValue(el.dashboardAllowNonentry),
      },
    },
    benchmark: {
      kickRomName: stringValue(el.benchmarkKickRomName),
      kickRomDir: stringValue(el.benchmarkKickRomDir),
    },
    mutationLoop: {
      iterations: intValue(el.mutationIterations, 10),
      seed: intValue(el.mutationSeed, 0),
      benchmarkConfig: stringValue(el.mutationBenchmarkConfig),
      evalScript: stringValue(el.mutationEvalScript),
      loopDir: stringValue(el.mutationLoopDir),
      resultsFile: stringValue(el.mutationResultsFile),
      mutator: stringValue(el.mutationMutator) || 'heuristic',
      mutation: stringValue(el.mutationStrategy) || 'any',
      candidateBudget: intValue(el.mutationCandidateBudget, 12),
      plateauRepeatLimit: intValue(el.mutationPlateauRepeatLimit, 4),
      imageHashCacheFile: stringValue(el.mutationImageHashCacheFile),
    },
    llm: {
      openai: {
        model: stringValue(el.openaiModel),
        apiKeyEnv: stringValue(el.openaiApiKeyEnv),
        baseUrl: stringValue(el.openaiBaseUrl),
        reasoningEffort: stringValue(el.openaiReasoningEffort) || 'minimal',
      },
      lmstudio: {
        baseUrl: stringValue(el.lmstudioBaseUrl),
        model: stringValue(el.lmstudioModel),
        apiTokenEnv: stringValue(el.lmstudioApiTokenEnv),
      },
    },
  };
}

function renderTerminalPreview() {
  const settings = collectProfileSettings();
  const profileName = activeProfileName();
  const mutation = settings.mutationLoop;
  const benchmark = settings.benchmark;
  const openai = settings.llm.openai;
  const lmstudio = settings.llm.lmstudio;

  const lines = [`# active profile: ${profileName}`, 'python3 amiga_copper_mutation_loop.py'];
  const args = [
    ['--iterations', String(mutation.iterations)],
    ['--seed', String(mutation.seed)],
    ['--mutator', mutation.mutator],
    ['--mutation', mutation.mutation],
    ['--candidate-budget', String(mutation.candidateBudget)],
    ['--plateau-repeat-limit', String(mutation.plateauRepeatLimit)],
    ['--benchmark-config', mutation.benchmarkConfig],
    ['--eval-script', mutation.evalScript],
    ['--loop-dir', mutation.loopDir],
  ];

  if (mutation.resultsFile) args.push(['--results-file', mutation.resultsFile]);
  if (mutation.imageHashCacheFile) args.push(['--image-hash-cache-file', mutation.imageHashCacheFile]);
  if (benchmark.kickRomName) args.push(['--kick-rom-name', benchmark.kickRomName]);
  if (benchmark.kickRomDir) args.push(['--kick-rom-dir', benchmark.kickRomDir]);

  if (mutation.mutator === 'openai') {
    args.push(['--openai-model', openai.model]);
    args.push(['--openai-api-key-env', openai.apiKeyEnv]);
    args.push(['--openai-base-url', openai.baseUrl]);
    args.push(['--reasoning-effort', openai.reasoningEffort]);
  }

  if (mutation.mutator === 'lmstudio') {
    args.push(['--lmstudio-base-url', lmstudio.baseUrl]);
    if (lmstudio.model) args.push(['--lmstudio-model', lmstudio.model]);
    if (lmstudio.apiTokenEnv) args.push(['--lmstudio-api-token-env', lmstudio.apiTokenEnv]);
  }

  for (const [flag, value] of args) {
    lines.push(`  ${flag} ${shellQuote(value)} \\`);
  }
  if (lines.length > 2) {
    const last = lines[lines.length - 1];
    lines[lines.length - 1] = last.replace(/ \\$/, '');
  }

  el.terminalPreview.textContent = lines.join('\n');
}

function applyProfileToForm(profile) {
  const dashboard = profile.dashboard?.defaults || {};
  const benchmark = profile.benchmark || {};
  const mutation = profile.mutationLoop || {};
  const openai = profile.llm?.openai || {};
  const lmstudio = profile.llm?.lmstudio || {};

  el.dashboardIterations.value = String(dashboard.iterations ?? 1);
  el.dashboardSeed.value = String(dashboard.seed ?? 0);
  el.dashboardRunMode.value = String(dashboard.runMode || 'copper_mutation');
  el.dashboardSourceFilter.value = String(dashboard.sourceFilter || '');
  el.dashboardManifestIndex.value = String(dashboard.manifestIndex ?? 0);
  setSelectValue(el.dashboardKickRom, dashboard.kickRom || '');
  el.dashboardAutoSelect.checked = dashboard.autoSelect !== false;
  el.dashboardAllowIncludes.checked = dashboard.allowIncludes === true;
  el.dashboardAllowNonentry.checked = dashboard.allowNonentry === true;

  setSelectValue(el.benchmarkKickRomName, benchmark.kickRomName || '');
  el.benchmarkKickRomDir.value = String(benchmark.kickRomDir || '');

  el.mutationIterations.value = String(mutation.iterations ?? 10);
  el.mutationSeed.value = String(mutation.seed ?? 0);
  el.mutationMutator.value = String(mutation.mutator || 'heuristic');
  el.mutationStrategy.value = String(mutation.mutation || 'any');
  el.mutationCandidateBudget.value = String(mutation.candidateBudget ?? 12);
  el.mutationPlateauRepeatLimit.value = String(mutation.plateauRepeatLimit ?? 4);
  el.mutationBenchmarkConfig.value = String(mutation.benchmarkConfig || '');
  el.mutationEvalScript.value = String(mutation.evalScript || '');
  el.mutationLoopDir.value = String(mutation.loopDir || '');
  el.mutationResultsFile.value = String(mutation.resultsFile || '');
  el.mutationImageHashCacheFile.value = String(mutation.imageHashCacheFile || '');

  el.openaiModel.value = String(openai.model || '');
  el.openaiApiKeyEnv.value = String(openai.apiKeyEnv || '');
  el.openaiBaseUrl.value = String(openai.baseUrl || '');
  el.openaiReasoningEffort.value = String(openai.reasoningEffort || 'minimal');

  el.lmstudioBaseUrl.value = String(lmstudio.baseUrl || '');
  el.lmstudioModel.value = String(lmstudio.model || '');
  el.lmstudioApiTokenEnv.value = String(lmstudio.apiTokenEnv || '');
}

function updateProfileSummary() {
  const selected = activeProfileName();
  const savedActive = String(settingsConfig?.activeProfile || 'default').trim() || 'default';
  const names = Object.keys(settingsConfig?.profiles || {});
  if (el.profileSummary) {
    el.profileSummary.textContent = `saved active: ${savedActive} | editor target: ${selected} | profiles: ${names.join(', ')}`;
  }
  if (el.deleteProfile) {
    el.deleteProfile.disabled = selected === 'default';
  }
}

function applySettingsPayload(payload) {
  settingsConfig = payload.settings || null;
  defaultConfig = payload.defaults || null;
  availableKickRoms = Array.isArray(payload.kickRoms) ? payload.kickRoms : [];

  if (el.settingsPath) el.settingsPath.textContent = payload.settingsPath || 'project_settings.json';
  if (el.versionPill) el.versionPill.textContent = `version: ${payload.dashboardVersion || '0.0.0-dev'}`;
  if (el.dashboardVersion) el.dashboardVersion.textContent = payload.dashboardVersion || '0.0.0-dev';
  if (el.tokenPill) el.tokenPill.textContent = `run-control token: ${monitorToken ? 'present' : 'optional'}`;

  setSelectOptions(el.dashboardKickRom, availableKickRoms, 'Auto (empty)');
  setSelectOptions(el.benchmarkKickRomName, availableKickRoms, 'Auto (empty)');
  setProfileOptions(settingsConfig || defaultConfig || { activeProfile: 'default', profiles: { default: {} } });

  const active = activeProfileName(settingsConfig);
  const profile =
    settingsConfig?.profiles?.[active] ||
    payload.effectiveSettings ||
    defaultConfig?.profiles?.default ||
    {};
  applyProfileToForm(profile);
  updateProfileSummary();
  renderTerminalPreview();
}

function loadSelectedProfileIntoForm() {
  const selected = activeProfileName();
  const profile = settingsConfig?.profiles?.[selected];
  if (!profile) {
    updateProfileSummary();
    renderTerminalPreview();
    return;
  }
  applyProfileToForm(profile);
  updateProfileSummary();
  renderTerminalPreview();
}

async function fetchJson(url, options) {
  const headers = { ...(options?.headers || {}) };
  if (monitorToken) headers['x-monitor-token'] = monitorToken;
  const res = await fetch(url, { ...(options || {}), headers });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || `${res.status}`);
  }
  return res.json();
}

function buildConfigWithCurrentForm(targetProfile = activeProfileName()) {
  const base = deepClone(settingsConfig || defaultConfig || { activeProfile: 'default', profiles: {} });
  const name = normalizeProfileName(targetProfile);
  if (!name) {
    throw new Error('profile name must use letters, numbers, dashes, or underscores');
  }
  if (!base.profiles || typeof base.profiles !== 'object') {
    base.profiles = {};
  }
  base.activeProfile = name;
  base.profiles[name] = collectProfileSettings();
  return base;
}

async function loadSettings() {
  const payload = await fetchJson('/api/settings');
  applySettingsPayload(payload);
}

async function saveSettings() {
  const payload = await fetchJson('/api/settings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ settings: buildConfigWithCurrentForm() }),
  });
  applySettingsPayload(payload);
  el.feedback.textContent = `Saved active profile ${activeProfileName(payload.settings)} to ${payload.settingsPath || 'project_settings.json'}.`;
}

async function setActiveProfile() {
  const target = normalizeProfileName(activeProfileName());
  if (!target) {
    throw new Error('choose a valid profile first');
  }
  const base = deepClone(settingsConfig || defaultConfig || { activeProfile: 'default', profiles: {} });
  if (!base.profiles || !Object.prototype.hasOwnProperty.call(base.profiles, target)) {
    throw new Error(`unknown profile: ${target}`);
  }
  base.activeProfile = target;
  const payload = await fetchJson('/api/settings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ settings: base }),
  });
  applySettingsPayload(payload);
  el.feedback.textContent = `Switched active profile to ${target}.`;
}

async function createProfile() {
  const name = normalizeProfileName(el.newProfileName?.value || '');
  if (!name) {
    throw new Error('new profile name must use letters, numbers, dashes, or underscores');
  }
  const payload = await fetchJson('/api/settings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ settings: buildConfigWithCurrentForm(name) }),
  });
  applySettingsPayload(payload);
  if (el.newProfileName) el.newProfileName.value = '';
  el.feedback.textContent = `Created and activated profile ${name}.`;
}

async function deleteProfile() {
  const name = normalizeProfileName(activeProfileName());
  if (!name || name === 'default') {
    throw new Error('the default profile cannot be deleted');
  }
  const base = deepClone(settingsConfig || defaultConfig || { activeProfile: 'default', profiles: {} });
  delete base.profiles[name];
  base.activeProfile = 'default';
  const payload = await fetchJson('/api/settings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ settings: base }),
  });
  applySettingsPayload(payload);
  el.feedback.textContent = `Deleted profile ${name} and switched back to default.`;
}

async function resetSettings() {
  if (!defaultConfig) {
    throw new Error('defaults are not loaded yet');
  }
  const payload = await fetchJson('/api/settings', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ settings: defaultConfig }),
  });
  applySettingsPayload(payload);
  el.feedback.textContent = `Reset ${payload.settingsPath || 'project_settings.json'} to built-in profiles.`;
}

function attachPreviewListeners() {
  const fields = Object.values(el).filter((node) => node instanceof HTMLElement);
  for (const node of fields) {
    if (!(node instanceof HTMLInputElement || node instanceof HTMLSelectElement || node instanceof HTMLTextAreaElement)) {
      continue;
    }
    node.addEventListener('input', renderTerminalPreview);
    node.addEventListener('change', renderTerminalPreview);
  }
}

el.activateProfile?.addEventListener('click', async () => {
  try {
    await setActiveProfile();
  } catch (err) {
    el.feedback.textContent = `Profile switch failed: ${err.message}`;
  }
});

el.activeProfile?.addEventListener('change', () => {
  loadSelectedProfileIntoForm();
});

el.createProfile?.addEventListener('click', async () => {
  try {
    await createProfile();
  } catch (err) {
    el.feedback.textContent = `Profile create failed: ${err.message}`;
  }
});

el.deleteProfile?.addEventListener('click', async () => {
  try {
    await deleteProfile();
  } catch (err) {
    el.feedback.textContent = `Profile delete failed: ${err.message}`;
  }
});

el.saveSettings?.addEventListener('click', async () => {
  try {
    await saveSettings();
  } catch (err) {
    el.feedback.textContent = `Save failed: ${err.message}`;
  }
});

el.resetSettings?.addEventListener('click', async () => {
  try {
    await resetSettings();
  } catch (err) {
    el.feedback.textContent = `Reset failed: ${err.message}`;
  }
});

el.reloadSettings?.addEventListener('click', async () => {
  try {
    await loadSettings();
    el.feedback.textContent = 'Reloaded settings from disk.';
  } catch (err) {
    el.feedback.textContent = `Reload failed: ${err.message}`;
  }
});

attachPreviewListeners();
loadSettings().catch((err) => {
  el.feedback.textContent = `Initial load failed: ${err.message}`;
  if (el.versionPill) el.versionPill.textContent = 'version: 0.0.0-dev';
  if (el.dashboardVersion) el.dashboardVersion.textContent = '0.0.0-dev';
});
