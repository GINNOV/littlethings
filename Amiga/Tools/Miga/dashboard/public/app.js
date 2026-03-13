const $ = (id) => document.getElementById(id);

let monitorToken = '';
let latestStatePayload = null;
let dashboardDefaultsApplied = false;
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
  running: $('pill-running-value'),
  iteration: $('pill-iteration-value'),
  queue: $('pill-queue-value'),
  now: $('pill-now'),
  score: $('scoreValue'),
  assembleLabel: $('assembleLabel'),
  emulatorLabel: $('emulatorLabel'),
  verifyLabel: $('verifyLabel'),
  assemble: $('assembleValue'),
  emulator: $('emulatorValue'),
  verify: $('verifyValue'),
  iterationsDone: $('iterationsDoneValue'),
  selectedSource: $('selectedSourceValue'),
  selectedRom: $('selectedRomValue'),
  latestOutcome: $('latestOutcome'),
  liveLog: $('liveLog'),
  runList: $('runList'),
  historyBody: $('historyBody'),
  historyStatusFilter: $('historyStatusFilter'),
  historySearch: $('historySearch'),
  historyTodayOnly: $('historyTodayOnly'),
  historyFilterSummary: $('historyFilterSummary'),
  scoreChart: $('scoreChart'),
  chartSummary: $('chartSummary'),
  dashboardVersion: $('dashboardVersion'),
  feedback: $('actionFeedback'),
  btnStart: $('btnStart'),
  btnClear: $('btnClear'),
  historyClearButton: $('historyClearButton'),
  iterations: $('iterations'),
  seed: $('seed'),
  contains: $('contains'),
  index: $('index'),
  kickRom: $('kickRom'),
  runMode: $('runMode'),
  runModeHint: $('runModeHint'),
  autoSelect: $('autoSelect'),
  allowIncludes: $('allowIncludes'),
  allowNonentry: $('allowNonentry'),
};

const RUN_MODE_DESCRIPTIONS = {
  corpus_validation: 'Corpus validation auto-selects from the strict runnable corpus and uses the normal assemble, emulate, and verify flow.',
  copper_reference:
    'Copper reference benchmark boots the known-good Copper bars disk and scores the captured screen against the golden reference crop.',
  copper_mutation:
    'Copper mutation benchmark assembles the mutable Copper workspace source into a bootblock-loaded ADF, boots it in vAmigaWeb, and scores the rendered bars against the golden reference crop.',
};

const DEFAULT_STAGE_LABELS = {
  assemble: 'Assemble',
  emulator: 'Emulator',
  verify: 'Verify',
};

function formatBool(value) {
  return value ? 'yes' : 'no';
}

function setMetricState(node, value, type) {
  node.textContent = value;
  node.classList.remove('ok', 'warn', 'bad');
  if (type) node.classList.add(type);
}

function scoreType(score) {
  if (score == null) return 'warn';
  if (score >= 0.95) return 'ok';
  if (score >= 0.7) return 'warn';
  return 'bad';
}

function escapeXml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
}

function rowScore(row) {
  if (Number.isFinite(row.score)) return row.score;
  const n = Number.parseFloat(row.scoreRaw || '');
  return Number.isFinite(n) ? n : null;
}

function rowStatusClass(status) {
  const key = String(status || '').toLowerCase();
  if (key === 'keep' || key === 'discard' || key === 'crash') return key;
  return 'other';
}

function basenameSafe(filePath) {
  if (!filePath || typeof filePath !== 'string') return '';
  const parts = filePath.split(/[\\/]/);
  return parts[parts.length - 1] || '';
}

function localDateIso(now = new Date()) {
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function parseRunTagDate(runTag) {
  const match = String(runTag || '').match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2})-(\d{2})-(\d{2})(?:-(\d{3}))?(Z)?/i);
  if (!match) return null;
  const [, year, month, day, hour, minute, second, millis = '000', isZulu = ''] = match;
  if (isZulu) {
    return new Date(
      Date.UTC(
        Number.parseInt(year, 10),
        Number.parseInt(month, 10) - 1,
        Number.parseInt(day, 10),
        Number.parseInt(hour, 10),
        Number.parseInt(minute, 10),
        Number.parseInt(second, 10),
        Number.parseInt(millis, 10)
      )
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
  );
}

function timezoneLabel(date) {
  try {
    const parts = new Intl.DateTimeFormat(undefined, { timeZoneName: 'short' }).formatToParts(date);
    const zone = parts.find((part) => part.type === 'timeZoneName');
    return zone?.value || '';
  } catch {
    return '';
  }
}

function rowRunTag(row) {
  const direct = typeof row?.runTag === 'string' ? row.runTag.trim() : '';
  if (direct) return direct;
  const desc = String(row?.description || '');
  const match = desc.match(/\brun\s+([^\s]+)/i);
  return match ? match[1] : '';
}

function rowRunDate(row) {
  const date = parseRunTagDate(rowRunTag(row));
  return date ? localDateIso(date) : null;
}

function rowRunDateTime(row) {
  const date = parseRunTagDate(rowRunTag(row));
  if (!date) return '--';
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');
  const second = String(date.getSeconds()).padStart(2, '0');
  const millis = String(date.getMilliseconds()).padStart(3, '0');
  const zone = timezoneLabel(date);
  return `${year}-${month}-${day} ${hour}:${minute}:${second}.${millis}${zone ? ` ${zone}` : ''}`;
}

function filteredHistoryRows(rows) {
  const statusFilter = (el.historyStatusFilter?.value || 'all').toLowerCase();
  const searchQuery = (el.historySearch?.value || '').trim().toLowerCase();
  const todayOnly = !!el.historyTodayOnly?.checked;
  const today = localDateIso();

  return rows.filter((row) => {
    const status = String(row?.status || '').toLowerCase();
    if (statusFilter !== 'all' && status !== statusFilter) return false;
    if (todayOnly) {
      const runDate = rowRunDate(row);
      if (runDate !== today) return false;
    }
    if (!searchQuery) return true;

    const searchText = [
      row?.runModeLabel,
      row?.runMode,
      row?.status,
      row?.resultLabel,
      row?.scoreRaw,
      rowRunDateTime(row),
      row?.description,
      row?.selectedSource,
      row?.kickRom,
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase();

    return searchText.includes(searchQuery);
  });
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

function renderHistory(rows) {
  el.historyBody.innerHTML = '';
  for (const row of rows) {
    const tr = document.createElement('tr');
    const statusClass = rowStatusClass(row.status);
    const statusTitle = escapeXml(row.status || 'unknown');
    const runDateTime = rowRunDateTime(row);
    const runModeLabel = escapeXml(row.runModeLabel || row.runMode || 'Unknown');
    const resultLabel = escapeXml(row.resultLabel || 'unknown');
    const resultClass = row.resultOk ? 'ok' : 'bad';
    const screenshotCell = row.screenshotUrl
      ? `<a href="${escapeXml(row.screenshotUrl)}" target="_blank" rel="noopener noreferrer">view</a>`
      : '--';
    tr.innerHTML = `
      <td>${runModeLabel}</td>
      <td class="mono">${escapeXml(row.scoreRaw || '')}</td>
      <td title="${statusTitle}"><span class="legend-dot ${statusClass}"></span></td>
      <td><span class="result-chip ${resultClass}">${resultLabel}</span></td>
      <td class="mono">${escapeXml(runDateTime)}</td>
      <td>${escapeXml(row.description || '')}</td>
      <td>${screenshotCell}</td>
    `;
    el.historyBody.appendChild(tr);
  }
}

function renderRuns(runs) {
  el.runList.innerHTML = '';
  if (!runs.length) {
    el.runList.innerHTML = '<div class="hint">No archived runs yet.</div>';
    return;
  }

  for (const run of runs) {
    const box = document.createElement('article');
    box.className = 'run-item';
    const score = run.score == null ? 'n/a' : Number(run.score).toFixed(6);
    box.innerHTML = `
      <b class="mono">${run.runTag}</b>
      <div>status: <strong>${run.status || 'unknown'}</strong></div>
      <div class="mono">score: ${score}</div>
      <div class="mono">source: ${run.selectedSource || 'unknown'}</div>
      <div class="mono">rom: ${run.kickRom || 'default'}</div>
    `;
    el.runList.appendChild(box);
  }
}

function renderKickRomOptions(payload) {
  const select = el.kickRom;
  if (!select) return;
  const roms = Array.isArray(payload.kickRoms) ? payload.kickRoms : [];
  const currentValue = select.value;
  const defaultValue = typeof payload.defaultKickRom === 'string' ? payload.defaultKickRom : '';
  const freezeDefault = select.dataset.freezeDefault === '1';

  const options = [`<option value=""${!currentValue && (freezeDefault || !defaultValue) ? ' selected' : ''}>Auto (default)</option>`];
  for (const rom of roms) {
    const selected = (currentValue && currentValue === rom) || (!currentValue && !freezeDefault && defaultValue === rom);
    options.push(`<option value="${escapeXml(rom)}"${selected ? ' selected' : ''}>${escapeXml(rom)}</option>`);
  }
  select.innerHTML = options.join('');
}

function setSelectValue(select, value) {
  if (!select) return;
  const desired = String(value || '').trim();
  select.dataset.freezeDefault = '1';
  if (!desired) {
    select.value = '';
    return;
  }
  const exists = Array.from(select.options || []).some((option) => option.value === desired);
  if (exists) {
    select.value = desired;
    return;
  }
  const option = document.createElement('option');
  option.value = desired;
  option.textContent = desired;
  select.appendChild(option);
  select.value = desired;
}

function applyDashboardDefaults(settingsPayload) {
  if (dashboardDefaultsApplied) return;
  const defaults = settingsPayload?.effectiveSettings?.dashboard?.defaults || settingsPayload?.settings?.dashboard?.defaults;
  if (!defaults || typeof defaults !== 'object') return;

  if (el.iterations) el.iterations.value = String(defaults.iterations ?? 1);
  if (el.seed) el.seed.value = String(defaults.seed ?? 0);
  if (el.contains) el.contains.value = String(defaults.sourceFilter || '');
  if (el.index) el.index.value = String(defaults.manifestIndex ?? 0);
  if (el.runMode) el.runMode.value = String(defaults.runMode || 'corpus_validation');
  if (el.autoSelect) el.autoSelect.checked = defaults.autoSelect !== false;
  if (el.allowIncludes) el.allowIncludes.checked = defaults.allowIncludes === true;
  if (el.allowNonentry) el.allowNonentry.checked = defaults.allowNonentry === true;
  setSelectValue(el.kickRom, defaults.kickRom || '');

  dashboardDefaultsApplied = true;
}

function renderScoreChart(rows) {
  const svg = el.scoreChart;
  if (!svg) return;

  const series = rows
    .slice()
    .reverse()
    .map((row, idx) => ({
      idx,
      score: rowScore(row),
      status: row.status || '',
      runModeLabel: row.runModeLabel || row.runMode || '',
      resultLabel: row.resultLabel || '',
    }))
    .filter((entry) => Number.isFinite(entry.score));

  if (!series.length) {
    svg.innerHTML =
      '<text x="26" y="42" class="chart-label">No numeric score data yet. Run one iteration to populate trend.</text>';
    if (el.chartSummary) el.chartSummary.textContent = 'runs: 0 | latest: -- | best: --';
    return;
  }

  const width = 960;
  const height = 260;
  const margin = { top: 16, right: 18, bottom: 28, left: 58 };
  const plotW = width - margin.left - margin.right;
  const plotH = height - margin.top - margin.bottom;

  const minScore = Math.min(...series.map((p) => p.score));
  const maxScore = Math.max(...series.map((p) => p.score));
  const span = maxScore - minScore;
  const pad = span > 0 ? span * 0.12 : Math.max(Math.abs(maxScore) * 0.08, 0.05);
  const yMin = minScore - pad;
  const yMax = maxScore + pad;

  const xFor = (i) => {
    if (series.length === 1) return margin.left + plotW * 0.5;
    return margin.left + (i / (series.length - 1)) * plotW;
  };
  const yFor = (score) => margin.top + ((yMax - score) / (yMax - yMin)) * plotH;

  const ticks = 5;
  let grid = '';
  for (let i = 0; i < ticks; i += 1) {
    const t = i / (ticks - 1);
    const y = margin.top + t * plotH;
    const value = yMax - t * (yMax - yMin);
    grid += `<line class="chart-grid" x1="${margin.left}" y1="${y.toFixed(2)}" x2="${(width - margin.right).toFixed(2)}" y2="${y.toFixed(2)}"></line>`;
    grid += `<text class="chart-label" x="${(margin.left - 8).toFixed(2)}" y="${(y + 4).toFixed(2)}" text-anchor="end">${value.toFixed(3)}</text>`;
  }

  const points = series.map((p) => ({ ...p, x: xFor(p.idx), y: yFor(p.score) }));
  const pathD = points.map((p, idx) => `${idx === 0 ? 'M' : 'L'} ${p.x.toFixed(2)} ${p.y.toFixed(2)}`).join(' ');
  const line = series.length > 1 ? `<path class="chart-line" d="${pathD}"></path>` : '';

  const circles = points
    .map((p) => {
      const statusClass = rowStatusClass(p.status);
      const title = escapeXml(
        `run ${p.idx + 1} | score=${p.score.toFixed(6)} | status=${p.status || 'n/a'} | method=${p.runModeLabel || 'n/a'} | result=${p.resultLabel || 'n/a'}`
      );
      return `<circle class="chart-point ${statusClass}" cx="${p.x.toFixed(2)}" cy="${p.y.toFixed(2)}" r="4.2"><title>${title}</title></circle>`;
    })
    .join('');

  const xAxisY = margin.top + plotH;
  const earliest = points[0];
  const latest = points[points.length - 1];
  const best = series.reduce((acc, item) => (item.score > acc.score ? item : acc), series[0]);
  const bestPoint = points.find((p) => p.idx === best.idx) || latest;

  const axis = [
    `<line class="chart-axis" x1="${margin.left}" y1="${xAxisY.toFixed(2)}" x2="${(width - margin.right).toFixed(2)}" y2="${xAxisY.toFixed(2)}"></line>`,
    `<text class="chart-label" x="${earliest.x.toFixed(2)}" y="${(height - 8).toFixed(2)}" text-anchor="start">oldest</text>`,
    `<text class="chart-label" x="${latest.x.toFixed(2)}" y="${(height - 8).toFixed(2)}" text-anchor="end">latest</text>`,
    `<text class="chart-label" x="${bestPoint.x.toFixed(2)}" y="${(bestPoint.y - 10).toFixed(2)}" text-anchor="middle">best ${best.score.toFixed(4)}</text>`,
  ].join('');

  svg.innerHTML = `${grid}${axis}${line}${circles}`;

  if (el.chartSummary) {
    el.chartSummary.textContent = `runs: ${series.length} | latest: ${latest.score.toFixed(6)} | best: ${best.score.toFixed(6)}`;
  }
}

function renderLiveLog(current) {
  if (!current) {
    el.liveLog.textContent = 'idle';
    return;
  }
  const lines = current.logTail || [];
  const header = [
    `[job ${current.jobId}] iteration ${current.iteration}/${current.totalIterations}`,
    `[phase] ${current.phase}`,
    `[run] ${current.runTag}`,
    '',
  ];
  el.liveLog.textContent = header.concat(lines).join('\n');
  el.liveLog.scrollTop = el.liveLog.scrollHeight;
}

function renderState(payload) {
  latestStatePayload = payload;
  if (el.dashboardVersion) el.dashboardVersion.textContent = payload.dashboardVersion || '0.0.0-dev';
  el.running.textContent = payload.running ? 'running' : 'idle';
  if (payload.current && Number.isInteger(payload.current.iteration) && Number.isInteger(payload.current.totalIterations)) {
    el.iteration.textContent = `${payload.current.iteration}/${payload.current.totalIterations}`;
  } else {
    el.iteration.textContent = '--';
  }
  const pendingIterations = Number.isInteger(payload.pendingIterations) ? payload.pendingIterations : 0;
  el.queue.textContent = String(pendingIterations);
  el.now.textContent = `time: ${new Date(payload.now).toLocaleTimeString()}`;

  const report = payload.latestReport;
  const stageLabels = report && report.stage_labels ? report.stage_labels : DEFAULT_STAGE_LABELS;
  if (el.assembleLabel) el.assembleLabel.textContent = stageLabels.assemble || DEFAULT_STAGE_LABELS.assemble;
  if (el.emulatorLabel) el.emulatorLabel.textContent = stageLabels.emulator || DEFAULT_STAGE_LABELS.emulator;
  if (el.verifyLabel) el.verifyLabel.textContent = stageLabels.verify || DEFAULT_STAGE_LABELS.verify;
  const score = report && Number.isFinite(report.score) ? report.score : null;
  setMetricState(el.score, score == null ? '--' : score.toFixed(6), scoreType(score));

  if (report) {
    setMetricState(el.assemble, formatBool(report.assembled), report.assembled ? 'ok' : 'bad');
    setMetricState(el.emulator, formatBool(report.emulator_ok), report.emulator_ok ? 'ok' : 'bad');
    setMetricState(el.verify, formatBool(report.verify_ok), report.verify_ok ? 'ok' : 'bad');
  } else {
    setMetricState(el.assemble, '--', 'warn');
    setMetricState(el.emulator, '--', 'warn');
    setMetricState(el.verify, '--', 'warn');
  }

  if (el.iterationsDone) {
    if (payload.current && Number.isInteger(payload.current.iteration) && Number.isInteger(payload.current.totalIterations)) {
      el.iterationsDone.textContent = `${payload.current.iteration}/${payload.current.totalIterations}`;
      el.iterationsDone.classList.remove('ok', 'warn', 'bad');
      el.iterationsDone.classList.add('warn');
    } else if (
      payload.lastCompleted &&
      Number.isInteger(payload.lastCompleted.iteration) &&
      Number.isInteger(payload.lastCompleted.totalIterations)
    ) {
      el.iterationsDone.textContent = `${payload.lastCompleted.iteration}/${payload.lastCompleted.totalIterations}`;
      el.iterationsDone.classList.remove('ok', 'warn', 'bad');
      el.iterationsDone.classList.add('ok');
    } else {
      el.iterationsDone.textContent = '--';
      el.iterationsDone.classList.remove('ok', 'warn', 'bad');
      el.iterationsDone.classList.add('warn');
    }
  }

  const source = payload.latestSelection?.entry?.source_rel || 'unknown';
  if (el.selectedSource) el.selectedSource.textContent = source;
  const kickRomNow = payload.latestKickRom || basenameSafe(report?.kick_rom) || payload.defaultKickRom || 'auto';
  if (el.selectedRom) el.selectedRom.textContent = kickRomNow;
  if (el.latestOutcome) {
    let note = 'latest outcome: --';
    let noteClass = 'warn';
    const status = String(payload.lastCompleted?.status || '').toLowerCase();
    const isBenchmark = String(report?.report_mode || '') === 'benchmark';
    if (report) {
      if (isBenchmark) {
        if (report.verify_ok) {
          if (status === 'keep') {
            note = 'latest outcome: benchmark passed and improved the current best score';
          } else if (status === 'discard') {
            note = 'latest outcome: benchmark passed, but the score only matched or missed the current best, so status is discard';
          } else {
            note = 'latest outcome: benchmark passed';
          }
          noteClass = 'ok';
        } else {
          note = 'latest outcome: benchmark failed';
          noteClass = 'bad';
        }
      } else if (typeof report.verify_ok === 'boolean') {
        if (report.verify_ok) {
          if (status === 'discard') {
            note = 'latest outcome: verification passed, but the run did not improve the current best score';
          } else if (status === 'keep') {
            note = 'latest outcome: verification passed and improved the current best score';
          } else {
            note = 'latest outcome: verification passed';
          }
          noteClass = 'ok';
        } else {
          note = 'latest outcome: verification failed';
          noteClass = 'bad';
        }
      }
    }
    el.latestOutcome.textContent = note;
    el.latestOutcome.classList.remove('ok', 'bad', 'warn');
    el.latestOutcome.classList.add(noteClass);
  }

  renderKickRomOptions(payload);
  const historyRows = payload.history || [];
  const filteredRows = filteredHistoryRows(historyRows);
  if (el.historyFilterSummary) {
    el.historyFilterSummary.textContent = `showing: ${filteredRows.length}/${historyRows.length}`;
  }
  renderLiveLog(payload.current);
  renderScoreChart(filteredRows);
  renderHistory(filteredRows);
  renderRuns(payload.recentRuns || []);
}

function updateRunModeUi() {
  const mode = el.runMode?.value || 'corpus_validation';
  const corpusControlsEnabled = mode === 'corpus_validation';
  if (el.runModeHint) {
    el.runModeHint.textContent = RUN_MODE_DESCRIPTIONS[mode] || RUN_MODE_DESCRIPTIONS.corpus_validation;
  }

  for (const node of [el.seed, el.contains, el.index, el.autoSelect, el.allowIncludes, el.allowNonentry]) {
    if (!node) continue;
    node.disabled = !corpusControlsEnabled;
  }
}

async function refresh() {
  try {
    const payload = await fetchJson('/api/state');
    renderState(payload);
  } catch (err) {
    el.feedback.textContent = `refresh failed: ${err.message}`;
  }
}

async function bootstrap() {
  await refresh();
  try {
    const settingsPayload = await fetchJson('/api/settings');
    applyDashboardDefaults(settingsPayload);
    updateRunModeUi();
  } catch (err) {
    if (!latestStatePayload) {
      el.feedback.textContent = `settings load failed: ${err.message}`;
    }
  }
}

async function queueRuns() {
  const payload = {
    iterations: Number.parseInt(el.iterations.value || '1', 10),
    seed: Number.parseInt(el.seed.value || '0', 10),
    index: Number.parseInt(el.index.value || '0', 10),
    contains: el.contains.value || '',
    kickRom: el.kickRom.value || '',
    runMode: el.runMode.value || 'corpus_validation',
    autoSelect: el.autoSelect.checked,
    allowIncludes: el.allowIncludes.checked,
    allowNonentry: el.allowNonentry.checked,
  };

  try {
    const out = await fetchJson('/api/run', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const modeLabel = el.runMode?.selectedOptions?.[0]?.textContent?.trim() || out.job.runMode;
    el.feedback.textContent = `queued job ${out.job.id} (${out.job.iterations} iteration${out.job.iterations === 1 ? '' : 's'}, mode ${modeLabel})`;
    await refresh();
  } catch (err) {
    el.feedback.textContent = `queue failed: ${err.message}`;
  }
}

async function clearQueue() {
  try {
    const out = await fetchJson('/api/queue/clear', { method: 'POST' });
    el.feedback.textContent = `cleared ${out.cleared} waiting job(s)`;
    await refresh();
  } catch (err) {
    el.feedback.textContent = `clear failed: ${err.message}`;
  }
}

async function clearHistory() {
  const totalRows = Array.isArray(latestStatePayload?.history) ? latestStatePayload.history.length : null;
  const rowLabel =
    totalRows == null ? 'the stored history' : `${totalRows} stored history entr${totalRows === 1 ? 'y' : 'ies'}`;
  const confirmed = window.confirm(
    `Delete ${rowLabel}?\n\nThis clears the persisted history rows shown in the dashboard. Archived run folders and screenshots are kept.`
  );
  if (!confirmed) return;

  try {
    const out = await fetchJson('/api/history/clear', { method: 'POST' });
    el.feedback.textContent = `deleted ${out.clearedTotalRows} history entr${out.clearedTotalRows === 1 ? 'y' : 'ies'}`;
    await refresh();
  } catch (err) {
    el.feedback.textContent = `history delete failed: ${err.message}`;
  }
}

el.btnStart.addEventListener('click', queueRuns);
el.btnClear.addEventListener('click', clearQueue);
el.historyClearButton?.addEventListener('click', clearHistory);
el.runMode?.addEventListener('change', updateRunModeUi);
el.kickRom?.addEventListener('change', () => {
  el.kickRom.dataset.freezeDefault = '1';
});
el.historyStatusFilter?.addEventListener('change', () => {
  if (latestStatePayload) renderState(latestStatePayload);
});
el.historySearch?.addEventListener('input', () => {
  if (latestStatePayload) renderState(latestStatePayload);
});
el.historyTodayOnly?.addEventListener('change', () => {
  if (latestStatePayload) renderState(latestStatePayload);
});

bootstrap();
setInterval(refresh, 2000);
