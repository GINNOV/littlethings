# Copper Bars Benchmark

This benchmark is the first task-specific milestone for the Amiga loop.

What it does:

1. Boots a known-good Copper bars ADF in vAmigaWeb.
2. Forces the stable headless software-renderer path.
3. Accepts the bootblock warning automatically.
4. Captures the emulator canvas.
5. Crops away the vAmiga UI chrome and compares the visible bars against a
   golden reference image.

Files:

- `benchmark.json`: task definition used by `amiga_eval_benchmark.py`
- `source_benchmark.json`: task definition used by `amiga_eval_benchmark_source.py`
- `asm_mutation_benchmark.json`: source-built benchmark definition for the inline-assembly mutation workspace
- `disk/copper_bars.adf`: known-good benchmark disk
- `golden/crop.png`: golden crop for scoring
- `source/`: fixed reference source assets and shared include files
- `mutation/`: mutable source workspace used by the mutation benchmark
- `asm_mutation/`: mutable source workspace that mutates the assembly file itself via an inline Copper block
- `frozen/`: frozen passing baselines for both mutation paths
- `bootblock.s.in`: bootblock loader template used for the generated ADF

There are now three benchmark paths:

1. Fixed disk benchmark: boots `disk/copper_bars.adf` exactly as captured.
2. Source-built benchmark: assembles `mutation/current.s`, wraps it in a
   bootblock-loaded ADF, then scores that generated disk against the same
   golden reference image.
3. Assembly-source benchmark: assembles `asm_mutation/current.s`, where the
   mutable Copper list is inlined directly into the assembly source between
   mutation markers, then scores that generated disk against the same golden
   reference image.

The mutable workspace starts from a degraded Copper list on purpose. That gives
the future mutation loop headroom to improve instead of tying the golden output
immediately.

Use the local mutation runner to iterate on either mutable workspace:

```bash
python3 amiga_copper_mutation_loop.py --iterations 10
```

For the standalone Copper-list target, the runner mutates:

- `mutation/out/copper-list.s`

For the inline assembly target, run:

```bash
python3 amiga_copper_mutation_loop.py \
  --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_mutation_benchmark.json \
  --loop-dir build/amiga/asm_mutation_loop \
  --results-file build/amiga/asm_mutation_loop/results.tsv
```

That path mutates:

- `asm_mutation/current.s`

Both modes keep only score improvements and archive every attempt under their
respective loop directories in `build/amiga/`.
