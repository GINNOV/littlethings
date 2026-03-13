# autoresearch-mlx

Apple Silicon (MLX) port of [Karpathy's autoresearch](https://github.com/karpathy/autoresearch).

Full credit to [@karpathy](https://github.com/karpathy) for the core idea: fixed-time autonomous research loops controlled through `program.md`. This port keeps the same basic rules: one mutable `train.py`, one metric (`val_bpb`), a fixed 5-minute training budget, and keep-or-revert via git. It runs natively on Apple Silicon through [MLX](https://github.com/ml-explore/mlx), so there is no PyTorch or CUDA dependency.

## Quick start

Requirements: Apple Silicon Mac, Python 3.10+, [uv](https://docs.astral.sh/uv/).

```bash
# install uv if needed
curl -LsSf https://astral.sh/uv/install.sh | sh

# install dependencies
uv sync

# one-time data + tokenizer prep
uv run prepare.py

# run one 5-minute training experiment
uv run train.py
```

Then point Claude Code or another coding agent at `program.md` and let it run the loop.

## Amiga adaptation (assemble/emulate loop)

This repo now also includes an experimental Amiga 68k scaffold that maps the
same keep-or-revert workflow to assembly:

- editable source: `amiga_workspace/main.s`
- evaluator: `amiga_eval.py`
- metric config: `amiga_eval.toml`
- agent protocol: `program.amiga.md`
- score log: `results_amiga.tsv`

The source workspace now lives under `amiga_workspace/`. Generated artifacts
still go to `build/amiga/`.

Run one Amiga experiment with:

```bash
python amiga_eval.py
```

Run the first screenshot-scored benchmark with:

```bash
python amiga_eval_benchmark.py
```

Run the source-built Copper mutation benchmark with:

```bash
python amiga_eval_benchmark_source.py
```

Run the inline-assembly mutation benchmark with:

```bash
python amiga_eval_benchmark_source.py --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark.json
```

Run the first local keep/revert mutation loop with:

```bash
python amiga_copper_mutation_loop.py --iterations 10
```

This loop edits the mutable Copper workspace in place, evaluates each candidate,
keeps only score improvements, and archives every attempt under:

- `build/amiga/mutation_loop/results.tsv`
- `build/amiga/mutation_loop/runs/`
- `build/amiga/mutation_loop/latest_summary.json`
- `build/amiga/mutation_loop/image_hash_cache.json`
- `build/amiga/mutation_loop/candidate_outcome_cache.json`
- `build/amiga/mutation_loop/region_outcome_cache.json`

The same loop can now also mutate the assembly file directly instead of the
derived Copper-list file:

```bash
python amiga_copper_mutation_loop.py \
  --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark.json \
  --loop-dir build/amiga/asm_mutation_loop \
  --results-file build/amiga/asm_mutation_loop/results.tsv \
  --iterations 10
```

The loop now also:

- caches benchmark crop hashes across batches
- caches candidate discard/crash outcomes by mutable-source state
- caches dead visual regions by baseline capture hash
- filters known-dead candidates before the model chooses the next move
- filters adjacent candidates in already-dead regions before evaluation
- stops early when it hits a repeated score+image plateau

To let an LLM choose the next safe mutation candidate, set an API key and use:

```bash
export OPENAI_API_KEY=...
python amiga_copper_mutation_loop.py --iterations 10 --mutator openai
```

The OpenAI-backed mutator currently chooses among safe structured Copper-list
edits instead of emitting raw assembly. That keeps the keep/revert loop stable
while making the model the mutation decision-maker.

To use a local model through LM Studio instead of a paid API:

```bash
python amiga_copper_mutation_loop.py --iterations 10 --mutator lmstudio
```

Defaults:

- LM Studio server base URL: `http://127.0.0.1:1234`
- model: auto-detected from the LM Studio server if omitted

Optional overrides:

```bash
python amiga_copper_mutation_loop.py --iterations 10 --mutator lmstudio --lmstudio-model your-model-id
```

If `xdftool`/`vamos` are not on your `PATH`, point the evaluator to your tool bin:

```bash
export AMIGA_TOOLS_BIN="$HOME/.venv/bin"
```

Kickstart ROM selection defaults to files in `roms/` (prefers a 1.3/A500 ROM when available).
Override for one run with:

```bash
AMIGA_KICK_ROM_NAME="Kickstart v3.1 r40.068 (1993-12)(Commodore)(A1200).rom" python amiga_eval.py
```

Run the monitoring dashboard with:

```bash
npm run monitor:start
```

Then open `http://localhost:4173`.
User walkthrough page: `http://localhost:4173/how-to`.
Shared project settings page: `http://localhost:4173/settings`.
Saved defaults live in `project_settings.json` and are read by both the dashboard
and `amiga_copper_mutation_loop.py`.
The settings page now supports named profiles such as `default`, `benchmark`,
`lmstudio`, and `corpus-validation`, so you can switch terminal/dashboard
defaults without editing the full form every time.
Dashboard footer version comes from `dashboard/VERSION` (bump this file when dashboard UI/API changes).

Build a strict runnable corpus manifest (assemble + `vamos` exit `0`) with:

```bash
python3 amiga_workspace/corpus/scripts/build_runnable_manifest.py
```

Source auto-selection now uses `amiga_workspace/corpus/manifest_runnable.tsv` by default
(dashboard and `pick_for_run.sh`). If the runnable manifest is missing, the
dashboard auto-builds it before selecting a source.
If the runnable manifest is empty, add more runnable corpus files (current
selection pool has no verify-clean candidates).

Security defaults:

- monitor binds to `127.0.0.1` by default (local machine only)
- set `MONITOR_HOST=0.0.0.0` only when you intentionally need LAN access
- optionally protect run-control endpoints with `MONITOR_API_TOKEN`
- when token is enabled, open the UI as `http://localhost:4173/?token=YOUR_TOKEN`

The evaluator emits a normalized `score` derived from:

- assembly success
- emulator crash/no-crash behavior (vAmigaWeb + Playwright backend)
- deterministic `vamos` verification run
- optional log and memory-state checks

The benchmark evaluator uses a task-specific image score instead:

- boot a known-good Copper bars disk
- capture the emulator canvas
- crop the visible bars region
- compare it against a golden reference image

The source-built benchmark uses the same image score, but first assembles the
mutable Copper workspace source into a bootblock-loaded ADF:

- assemble `amiga_workspace/benchmarks/copper_bars/mutation/current.s` to flat binary
- wrap it in a bootblock loader and write `build/amiga/source_copper_bars.adf`
- boot that generated disk in vAmigaWeb
- compare the screenshot crop against the same golden reference image

The local mutation loop sits on top of that benchmark:

- mutate `amiga_workspace/benchmarks/copper_bars/mutation/out/copper-list.s`
- run `amiga_eval_benchmark_source.py`
- keep the candidate only if its score beats the current workspace best
- archive metadata, report, diff, screenshots, and a batch summary for every attempt

See `amiga_workspace/README.md` for setup details.
For a plain-language terminal walkthrough, see [`explainer.md`](explainer.md).

## What matters

- `prepare.py` - data prep, tokenizer, dataloader, and evaluation. Treat as fixed.
- `train.py` - model, optimizer, and training loop. This is the file the agent edits.
- `program.md` - the autonomous experiment protocol.
- `results.tsv` - logged experiment history.

The loop is the same as upstream: edit `train.py`, run a fixed-budget experiment, read `val_bpb`, keep the change if it wins, revert if it loses, and repeat.

## Public baseline results

The public `results.tsv` captures the initial hardware-local walk from the default baseline down to `1.807902`:

| Commit | val_bpb | Status | Description |
|---|---:|---|---|
| `383abb4` | 2.667000 | keep | baseline (AdamW, default config) |
| `909dd59` | 2.588904 | keep | halve total batch size to `2^16` |
| `4161af3` | 2.533728 | keep | increase matrix LR to `0.04` |
| `5efc7aa` | 1.807902 | keep | reduce depth from `8` to `4` |

That result already shows the core Apple Silicon pattern: with a fixed 5-minute wall clock, smaller faster-training models can beat larger ones simply by fitting more optimizer steps into the budget.

## Longer Apple Silicon runs

Longer overnight runs on the working MLX port pushed much further. The long Mac Mini test is included here because it found a meaningfully different winner stack from the Max-class machines.

| Machine | Current best | Starting point | Repeated wins |
|---|---:|---:|---|
| M4 Max #1 | 1.294526 | 1.596971 | AdamW-only, low matrix LR, 3x MLP, no logit cap, moderate weight decay |
| M4 Max #2 | 1.330509 | 1.807902 | leaner batch, long anneal, SiLU, lower regularization, no logit cap |
| Mac Mini (long run) | 1.353329 | 1.922472 | Muon, sharper attention, smaller MLP, lower scalar LR |

The Mac Mini result matters because it did not just rediscover the same exact recipe. On smaller Apple Silicon hardware, the strongest changes leaned toward more aggressive step-efficiency wins. Later transfer tests showed some of those Mac Mini findings did not carry cleanly onto the Max baseline, which is exactly the kind of hardware-specific behavior this loop is useful for uncovering.

## Differences from upstream

- **MLX instead of PyTorch/CUDA.** Native Apple Silicon training with unified memory.
- **AdamW-only public path.** This public `train.py` keeps the default path simple. The long Mac Mini run above explored a Muon variant in the working port, but that branch is not exposed as a public default here.
- **Smaller eval token budget.** Reduced for faster iteration on Apple Silicon while keeping the same `evaluate_bpb` interface in `prepare.py`.
- **Roughly 6-7 minutes per experiment.** Expect 5 minutes of training plus compile and eval overhead.
- **MFU reporting is placeholder.** There is no Apple Silicon equivalent to the H100 FLOPs reference used upstream.

## Acknowledgments

- [Andrej Karpathy](https://github.com/karpathy) - autoresearch and nanochat
- [scasella/nanochat-mlx](https://github.com/scasella/nanochat-mlx) - MLX GPT and optimizer reference
- [awni/picochat](https://github.com/awni/picochat) - MLX training patterns
- [Apple MLX team](https://github.com/ml-explore/mlx)

## License

MIT. See [LICENSE](LICENSE).
