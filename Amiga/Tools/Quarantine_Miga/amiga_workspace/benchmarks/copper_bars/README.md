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
- `benchmark_midband.json`: fixed-disk benchmark for the middle/lower visible bar band
- `source_benchmark_midband.json`: pair-file source benchmark for the middle/lower visible bar band
- `asm_mutation_benchmark_midband.json`: inline-assembly source benchmark for the middle/lower visible bar band
- `asm_playfield_marker_benchmark.json`: source-built benchmark for a visible bitplane marker that is sensitive to display-window setup
- `asm_playfield_structure_benchmark.json`: intentionally wrong setup-control for the playfield-marker benchmark
- `source_benchmark_suite.json`: two-task suite for the pair-file mutation workspace
- `asm_mutation_benchmark_suite.json`: two-task suite for the inline-assembly mutation workspace
- `disk/copper_bars.adf`: known-good benchmark disk
- `golden/crop.png`: golden crop for scoring
- `golden/midband.png`: second-task reference crop for the middle/lower bar band
- `golden/playfield_marker.png`: setup-sensitive reference crop for the top-left playfield marker
- `source/`: fixed reference source assets and shared include files
- `mutation/`: mutable source workspace used by the mutation benchmark
- `asm_mutation/`: mutable source workspace that mutates the assembly file itself via an inline Copper block
- `asm_structure_mutation/`: experimental structure-stepback workspace for future setup-logic benchmarks
- `asm_playfield_marker/`: passing source workspace with a visible bitplane marker
- `asm_playfield_structure/`: failing negative-control workspace with intentionally wrong playfield setup
- `frozen/`: frozen passing baselines for both mutation paths
- `bootblock.s.in`: bootblock loader template used for the generated ADF

There are now four benchmark paths:

1. Fixed disk benchmark: boots `disk/copper_bars.adf` exactly as captured.
2. Source-built benchmark: assembles `mutation/current.s`, wraps it in a
   bootblock-loaded ADF, then scores that generated disk against the same
   golden reference image.
3. Assembly-source benchmark: assembles `asm_mutation/current.s`, where the
   mutable Copper list is inlined directly into the assembly source between
   mutation markers, then scores that generated disk against the same golden
   reference image.
4. Multi-task suite benchmark: runs both the original full crop and the new
   middle/lower band crop, then averages their scores and requires both tasks
   to pass.
5. Playfield-marker benchmark: scores a tight top-left crop containing a visible
   bitplane marker so wrong display-window or fetch setup becomes visible.

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

Current benchmark finding:

- the pair-file mutation workspace still passes the original full-crop task
- but it falls short on the new midband task
- the inline-assembly mutation workspace passes both tasks and the suite
- the original Copper-bars tasks are still mostly sensitive to Copper data
- the new playfield-marker benchmark is the first task here that cleanly fails
  when display-window / fetch setup constants are wrong

That is the current preferred mutation path moving forward.

Use the new setup-sensitive task with:

```bash
python3 amiga_eval_benchmark_source.py --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_playfield_marker_benchmark.json
```

And confirm the negative control fails with:

```bash
python3 amiga_eval_benchmark_source.py --benchmark-config amiga_workspace/benchmarks/copper_bars/asm_playfield_structure_benchmark.json
```
