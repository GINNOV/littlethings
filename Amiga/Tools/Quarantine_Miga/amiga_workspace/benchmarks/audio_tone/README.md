# Audio Tone Benchmark

This benchmark family is experimental groundwork for Paula audio benchmarking.

Current status:
- `amiga_workspace/run_vamigaweb.js` can now export wasm audio-buffer and raw memory captures.
- A simple one-channel Paula tone source and wrong-pitch control source exist.
- The real benchmark path is not validated yet because headless vAmigaWeb is not materializing non-zero PCM for this tone source, and direct `HEAPU8` memory capture is not currently confirmed to map Amiga RAM addresses.

Files:
- `reference/current.s`: known-good one-channel tone source.
- `control/current.s`: wrong-pitch control source.
- `golden/reference_state.json`: optional runtime-state capture used as the benchmark target.
- `reference_benchmark.json`: passing benchmark config.
- `control_benchmark.json`: failing control config.

Run:

```bash
python3 amiga_eval_benchmark_memory.py --benchmark-config amiga_workspace/benchmarks/audio_tone/reference_benchmark.json
python3 amiga_eval_benchmark_memory.py --benchmark-config amiga_workspace/benchmarks/audio_tone/control_benchmark.json
```

To attempt regenerating the reference state from the reference source:

```bash
python3 amiga_eval_benchmark_memory.py \
  --benchmark-config amiga_workspace/benchmarks/audio_tone/reference_benchmark.json \
  --write-reference
```
