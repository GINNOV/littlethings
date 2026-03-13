# Amiga Autoresearch Adaptation

This folder holds the Amiga-targeted scaffold for adapting the original
`train.py` loop into an `assemble -> emulate -> score` loop.

## What this adds

- `amiga_workspace/main.s`: editable Motorola 68000 source seed.
- `amiga_workspace/startup-sequence`: command file for the generated ADF.
- `amiga_workspace/fs-uae.conf`: starter emulator config placeholder.
- `../amiga_eval.py`: single-run evaluator script.
- `../amiga_eval.toml`: configurable commands, checks, and metric weights.
- `../program.amiga.md`: autonomous experiment protocol for coding agents.

Generated outputs for this workspace still live in `build/amiga/`.

## Toolchain options

Use any assembler/emulator pair that works from shell commands:

- Assembler: `vasm`, `asmone`, `phxass`, custom wrapper script, etc.
- Emulator: `FS-UAE`, `WinUAE` CLI wrapper, `UAE` fork, or custom 68k runner.

Update commands in [`amiga_eval.toml`](../amiga_eval.toml) to match your local setup.

## Template ADF (recommended)

If you have a fully functional system ADF with the commands you need, place it at:

- `amiga_workspace/adf/system_template.adf`

The package step will clone this template each run and then replace only:

- `s/startup-sequence`
- `main`

## Run one experiment

```bash
npm install
npx playwright install chromium
python amiga_eval.py
```

Output includes a normalized `score` in `[0, 1]`, plus assembly/emulator health
signals and check pass rates.

The evaluator stages are:

1. assemble (`main.s` -> Amiga executable)
2. package (create `main.adf` with `startup-sequence`)
3. emulate (boot ADF in vAmigaWeb via Playwright)
4. verify (run `main` in `vamos` for deterministic CPU-level checks)

## Run the Copper benchmark

```bash
python amiga_eval_benchmark.py
```

This benchmark uses a fixed known-good Copper bars disk and scores the result by
comparing a captured screen crop against a saved reference image.

Benchmark assets live in:

- `amiga_workspace/benchmarks/copper_bars/`

## Run the source-built Copper benchmark

```bash
python amiga_eval_benchmark_source.py
```

This mode assembles the mutable Copper benchmark workspace source, wraps it in a
bootblock-loaded ADF, boots the generated disk in vAmigaWeb, and scores the
captured screen against the same saved reference image. This is the mutation
baseline for the Copper task.

## Run the local Copper mutation loop

```bash
python amiga_copper_mutation_loop.py --iterations 10
```

This loop mutates the Copper workspace file
`amiga_workspace/benchmarks/copper_bars/mutation/out/copper-list.s`, evaluates
the benchmark after each change, keeps only improvements, and reverts losing
candidates automatically.

To let an LLM pick the candidate instead of the heuristic chooser:

```bash
export OPENAI_API_KEY=...
python amiga_copper_mutation_loop.py --iterations 10 --mutator openai
```

The current LLM path selects among generated safe edits. It does not rewrite the
assembly source freely yet.

To use LM Studio as the local model backend:

```bash
python amiga_copper_mutation_loop.py --iterations 10 --mutator lmstudio
```

This targets the LM Studio local server at `http://127.0.0.1:1234` by default
and will try to auto-detect a model unless you pass `--lmstudio-model`.

Loop outputs are stored in:

- `build/amiga_workspace/mutation_loop/results.tsv`
- `build/amiga_workspace/mutation_loop/runs/`

## Runnable corpus selection

When selecting files from `amiga_workspace/corpus/`, prefer the strict runnable manifest:

```bash
python3 amiga_workspace/corpus/scripts/build_runnable_manifest.py
python3 amiga_workspace/corpus/scripts/select_source.py --seed 1
```

`select_source.py` automatically prefers `amiga_workspace/corpus/manifest_runnable.tsv`
when present, so selected files are already filtered to pass assemble + verify.

## Metric design guidance

Use layered checks:

1. Build gate: assembly succeeds and emits artifact.
2. Runtime gate: emulator executes without crash signatures.
3. Behavioral checks: log markers and/or memory dump assertions.

This does not guarantee "perfect" correctness by itself; the loop quality is
bounded by how strict and relevant your checks are.
