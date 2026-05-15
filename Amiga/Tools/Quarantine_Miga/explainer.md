# Amiga Research Explainer (No AI Jargon)

This guide explains what this project does and how to run it from Terminal,
step by step.

## What This Project Does

You give the project a Motorola 68000 assembly source file.

The project then:

1. Assembles the source (`amiga_workspace/main.s`) into an Amiga executable.
2. Builds a bootable ADF disk image containing your executable.
3. Boots that disk in an emulator backend (vAmigaWeb, automated via Playwright).
4. Runs an additional verification pass (`vamos`) for deterministic checks.
5. Produces a score and detailed logs in `build/amiga/`.

In short: **edit code -> run evaluator -> get objective pass/fail signals**.

## Folder Map

- `amiga_workspace/main.s`: current source file that gets assembled.
- `amiga_workspace/startup-sequence`: startup script written into the test ADF.
- `amiga_eval.py`: evaluator entrypoint.
- `amiga_eval.toml`: evaluator configuration (commands, timeouts, checks).
- `amiga_workspace/corpus/raw/`: where you drop collected source repositories/files.
- `amiga_workspace/corpus/curated/`: filtered files considered for selection.
- `amiga_workspace/corpus/manifest_runnable.tsv`: strict selection pool (assemble + verify exit-zero).
- `amiga_workspace/corpus/not_for_training/`: files quarantined as not immediately usable.
- `build/amiga/`: outputs, logs, reports after each run.

## Prerequisites

You need these tools installed and available:

- Python 3
- Node.js + npm
- `vasmm68k_mot`
- `amitools` (`xdftool`)
- `vamos` (from amitools ecosystem)
- Playwright Chromium browser runtime
- Kickstart ROM file referenced in `amiga_eval.toml`
  (or a ROM set under `roms/`)

If `xdftool` and `vamos` live in a custom bin directory (for example a venv),
set this before running:

```bash
export AMIGA_TOOLS_BIN="$HOME/.venv/bin"
```

If you keep multiple Kickstarts in `roms/`, pick one for a run with:

```bash
AMIGA_KICK_ROM_NAME="Kickstart v3.0 r39.115 (1992)(Commodore).rom" python3 amiga_eval.py
```

## One-Time Setup

From the repo root:

```bash
npm install
npx playwright install chromium
python3 -m py_compile amiga_eval.py
```

Run one baseline evaluation:

```bash
python3 amiga_eval.py
```

Run the first task-specific screenshot benchmark:

```bash
python3 amiga_eval_benchmark.py
```

Run the source-built Copper benchmark that is ready for code mutation:

```bash
python3 amiga_eval_benchmark_source.py
```

Run the second Copper task, which scores only the middle/lower visible bar band:

```bash
python3 amiga_eval_benchmark_source.py --benchmark-config amiga_workspace/benchmarks/copper_bars/source_benchmark_midband.json
```

Run the two-task suite for the inline-assembly workspace:

```bash
python3 amiga_eval_benchmark_suite.py --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark_suite.json
```

Run the setup-sensitive benchmark that uses a visible bitplane marker near the
top-left playfield area:

```bash
python3 amiga_eval_benchmark_source.py --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_playfield_marker_benchmark.json
```

Check the intentionally wrong setup control against that same marker crop:

```bash
python3 amiga_eval_benchmark_source.py --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_playfield_structure_benchmark.json
```

Run the first time-based scroller runway suite:

```bash
python3 amiga_eval_benchmark_suite.py --benchmark-config amiga_workspace/benchmarks/sincos_scroller/reference_suite.json
```

Run the intentionally broken scroller control:

```bash
python3 amiga_eval_benchmark_suite.py --benchmark-config amiga_workspace/benchmarks/sincos_scroller/control_suite.json
```

Run the degradable sin/cos mutation suite:

```bash
python3 amiga_eval_benchmark_suite.py --benchmark-config amiga_workspace/benchmarks/sincos_scroller/mutation_suite.json
```

Run the dedicated sin/cos keep/revert loop on top of that benchmark:

```bash
python3 amiga_sincos_mutation_loop.py --iterations 10
```

There is also first-pass audio groundwork now:

```bash
python3 amiga_eval_benchmark_memory.py --benchmark-config amiga_workspace/benchmarks/audio_tone/reference_benchmark.json
```

A reusable native-vAmiga RetroShell launcher now exists too:

```bash
python3 tools/native_vamiga_retrosh.py tools/retrosh/start_rshell.retrosh --disk-image build/amiga/source_mod_playback_frame_02.adf
```

That path uses `Machine -> Import script...` under UI automation and is the current bridge toward native screenshot / recorder / remote-shell driven benchmarks.

Be precise about its status:

- the vAmigaWeb runner can now export wasm audio-buffer captures and raw memory captures
- there is a simple Paula tone source and a wrong-pitch control source under `amiga_workspace/benchmarks/audio_tone/`
- this is not a validated audio benchmark yet
- headless vAmigaWeb is still producing zeroed PCM for the current tone source, and raw HEAP memory capture is not yet confirmed to reflect Amiga RAM addresses directly
- treat the audio family as instrumentation groundwork, not as a finished benchmark

Scaffold the repetitive parts of a new benchmark family with:

```bash
python3 tools/new_amiga_benchmark.py "My New Benchmark"
```

That tool creates:

- `reference/`, `control/`, and `mutation/` source workspaces
- placeholder golden images
- frame configs
- suite configs
- a benchmark README

You still need to supply the real effect source, capture real goldens, and tune
the crop/threshold values. The tool is for the template work, not for task design.

Reset the mutable scroller back to its degraded seed before another recovery run:

```bash
cp amiga_workspace/benchmarks/sincos_scroller/mutation/seed.s amiga_workspace/benchmarks/sincos_scroller/mutation/current.s
```

Run the inline-assembly mutation loop:

```bash
python3 amiga_copper_mutation_loop.py \
  --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark.json \
  --loop-dir build/amiga/asm_mutation_loop \
  --results-file build/amiga/asm_mutation_loop/results.tsv \
  --iterations 10
```

Project-wide saved defaults now live in:

```text
project_settings.json
```

You can edit that file directly or use the browser settings page:

```text
http://localhost:4173/settings
```

The same saved defaults are used by the dashboard form and the terminal mutation loop.
The page now also supports named profiles, so you can keep separate presets such as:

- `default`
- `benchmark`
- `lmstudio`
- `corpus-validation`

Switching the active profile changes which defaults Terminal tools and the dashboard load.

What this loop does:

- edits the mutable Copper workspace, not the fixed reference source
- runs the source-built benchmark after each candidate change
- keeps the candidate only when the score improves
- restores the previous workspace when the score does not improve
- writes a batch summary to `build/amiga/mutation_loop/latest_summary.json`
- caches benchmark crop hashes in `build/amiga/mutation_loop/image_hash_cache.json`
- caches candidate discard/crash outcomes in `build/amiga/mutation_loop/candidate_outcome_cache.json`
- caches dead visual regions in `build/amiga/mutation_loop/region_outcome_cache.json`
- filters known dead-end candidates before the chooser sees them
- filters adjacent candidates in already-dead visual regions before they are evaluated
- can stop early when repeated runs produce the same score and the same captured image

The same loop can also mutate the assembly file directly. In that mode, it
edits the inline Copper block inside
`amiga_workspace/benchmarks/copper_bars/asm_mutation/current.s` instead of the
standalone `mutation/out/copper-list.s` file.

The suite result is important:

- the pair-file mutation path passes the original full-crop benchmark, but fails the new midband task
- the inline-assembly mutation path passes both tasks

That means the project now has a real multi-task signal instead of optimizing only one screenshot crop.

There is now also a setup-sensitive task:

- `asm_playfield_marker/current.s` is the passing source
- `asm_playfield_structure/current.s` is the intentionally wrong setup control
- the marker task scores a tight top-left crop where a visible bitplane marker moves or disappears when display-window / fetch setup is wrong

That closes the earlier blind spot where Copper-only background bars could still
look correct even when important playfield setup constants were not.

There is now also a time-based sin/cos text benchmark:

- `reference/current.s` renders a real text band using embedded glyphs
- that text band drifts horizontally and each character follows a sine-driven
  Y offset over time
- `control/current.s` keeps the same text fixed in place and is used as the
  failing control
- the suite compares three captured frames, so the benchmark can now detect
  text motion patterns instead of only static images

This is still a minimal benchmark, not the final scroller quality target. The
next upgrade is smoother scrolling and then broader assembly-structure mutations
for this benchmark family.

Where to look afterward:

- `build/amiga/mutation_loop/results.tsv`
- `build/amiga/mutation_loop/runs/`

To use an LLM as the candidate chooser:

```bash
export OPENAI_API_KEY=...
python3 amiga_copper_mutation_loop.py --iterations 10 --mutator openai
```

Important:

- the LLM does not emit raw assembly yet
- it chooses among safe candidate edits generated by the local mutator
- every request/response is archived per iteration when LLM mode is used

To use a local model with LM Studio instead of a paid cloud API:

```bash
python3 amiga_copper_mutation_loop.py --iterations 10 --mutator lmstudio
```

Notes:

- the runner expects the LM Studio local server on `http://127.0.0.1:1234`
- if you do not pass `--lmstudio-model`, it tries to auto-detect one from the server
- if your LM Studio server is protected, set `LMSTUDIO_API_TOKEN`

For a forced discard-path test, restrict the mutator to removals:

```bash
python3 amiga_copper_mutation_loop.py --iterations 1 --mutation remove_pair
```

Expected output includes lines like:

- `assembled: true`
- `packaged: true`
- `emulator_ok: true`
- `verify_ok: true`

## Optional (Recommended): Use Your Own Full System ADF Template

If you have a fully functional bootable ADF with working commands/libs, place it here:

```text
amiga_workspace/adf/system_template.adf
```

When this file exists, package step will:

1. Copy template ADF to `build/amiga/main.adf`
2. Overwrite only:
   - `s/startup-sequence`
   - `main`

This is the best way to avoid command-missing/runtime-environment issues.

## Add Source Files For Training/Experiments

Copy all your collected source trees into:

```text
amiga_workspace/corpus/raw/
```

Nested subfolders are supported.

## Build Curated Source Index

```bash
python3 amiga_workspace/corpus/scripts/index_raw_sources.py --refresh
```

This scans `raw`, keeps assembly-like files, and generates:

- `amiga_workspace/corpus/curated/...`
- `amiga_workspace/corpus/manifest.tsv`

## Build Strict Runnable Manifest

```bash
python3 amiga_workspace/corpus/scripts/build_runnable_manifest.py
```

This step keeps only files that:

1. Assemble successfully.
2. Return exit code `0` in `vamos`.

Output files:

- `amiga_workspace/corpus/manifest_runnable.tsv`
- `amiga_workspace/corpus/manifest_runnable_report.json`

## Move Non-Usable Files Out Of Training Pool

Run:

```bash
python3 amiga_workspace/corpus/scripts/quarantine_non_usable.py
```

This moves non-immediately-usable files to:

```text
amiga_workspace/corpus/not_for_training/raw/
```

And writes reports:

- `amiga_workspace/corpus/not_for_training/reports/quarantine_report.tsv`
- `amiga_workspace/corpus/not_for_training/reports/quarantine_summary.json`

## Pick A Source File Into `amiga_workspace/main.s`

Random pick:

```bash
python3 amiga_workspace/corpus/scripts/select_source.py --seed 1
```

By default, selection prefers `manifest_runnable.tsv` (strict pool) when that
file exists.

Filtered pick:

```bash
python3 amiga_workspace/corpus/scripts/select_source.py --contains "boot"
```

One-step helper:

```bash
amiga_workspace/corpus/scripts/pick_for_run.sh --seed 1
```

Selection metadata is saved to:

```text
build/amiga/selected_source.json
```

## Run The Evaluator

```bash
python3 amiga_eval.py
```

Main outputs:

- Console summary
- `build/amiga/report.json`
- `build/amiga/assemble.stdout.log`
- `build/amiga/emulate.stdout.log`
- `build/amiga/verify.stderr.log`

Benchmark mode writes the same main `report.json`, plus image artifacts:

- `build/amiga/benchmark_capture.png`
- `build/amiga/benchmark_capture_crop.png`
- `build/amiga/benchmark_capture_diff.png`

## Monitor In A Website UI

Start the monitor server:

```bash
npm run monitor:start
```

Open in browser:

```text
http://localhost:4173
```

Built-in usage guide page:

```text
http://localhost:4173/how-to
```

Dashboard version shown in page footers is read from:

```text
dashboard/VERSION
```

## What The Copper Benchmark Is For

`amiga_eval_benchmark.py` is the first task-specific check in this project.

It does not try to verify a DOS program exit code. Instead it:

1. Boots a known-good Copper bars disk.
2. Accepts the bootblock prompt automatically.
3. Captures the screen.
4. Compares the captured bars against a saved reference image.

This matters because it gives the project one real Amiga hardware-style task
with a visual scoring signal before code mutation is introduced.

Optional security hardening:

```bash
MONITOR_API_TOKEN='change-me' npm run monitor:start
```

If `MONITOR_API_TOKEN` is set, open the dashboard with:

```text
http://localhost:4173/?token=change-me
```

From the UI you can:

- watch current run progress live
- see score/history from `results_amiga.tsv`
- queue one or many new runs
- choose which Kickstart ROM from `roms/` to use for queued runs
- inspect recent archived run snapshots

## Basic Daily Workflow

1. Update corpus in `amiga_workspace/corpus/raw/` (optional).
2. Re-index:
   - `python3 amiga_workspace/corpus/scripts/index_raw_sources.py --refresh`
3. Quarantine non-usable:
   - `python3 amiga_workspace/corpus/scripts/quarantine_non_usable.py`
4. Build strict runnable manifest:
   - `python3 amiga_workspace/corpus/scripts/build_runnable_manifest.py`
5. Select next source:
   - `python3 amiga_workspace/corpus/scripts/select_source.py --seed 42`
6. Run evaluator:
   - `python3 amiga_eval.py`
7. Inspect score and logs in `build/amiga/`.

## Troubleshooting

- `verify_ok: false`:
  - check `build/amiga/verify.stderr.log`
  - source may be fragment-only or missing expected entry behavior
- `manifest_runnable.tsv` is empty:
  - your current corpus does not contain standalone files that exit `0` in `vamos`
  - add runnable sources (or temporarily relax verify policy if you are debugging)
- `assembled: false`:
  - source may need include paths/macros not present in standalone mode
- `emulator_ok: false`:
  - inspect `build/amiga/emulate.stdout.log` and `build/amiga/report.json`
- ROM path problems:
  - verify `[paths].kick_rom_dir` and `[paths].kick_rom_name` in `amiga_eval.toml`

## Important Note

This pipeline is strict by design. A file being valid assembly does not always
mean it is immediately runnable as a standalone `main.s`. The quarantine step
helps keep the training pool focused on files that can be tested automatically.
