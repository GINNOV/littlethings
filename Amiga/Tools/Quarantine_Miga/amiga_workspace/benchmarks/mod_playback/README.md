# MOD Playback Benchmark

This benchmark family boots a raw `.mod` player based on the ProTracker 2.3A replay routine and encodes live player state into three visible bitplane bars.

Why this exists:
- raw PCM validation is not stable yet in headless vAmigaWeb
- but we can still verify that the music engine is active and driving visible replay state
- the current suite distinguishes `player advancing` from `player initialized but static`
- the three captures are kept for consistency, but the current visual state is not meaningfully different across `2s`, `4s`, and `6s` yet

Files:
- `reference/current.s`: raw MOD playback source that calls `mt_music` once per polled frame and paints replay-state bars
- `control/current.s`: control source that initializes the module but never advances playback, leaving the bars static
- `include/ProTracker2.3A.i`: replay routine copied from the existing corpus
- `reference/music.mod`: the benchmark module
- `golden/frame_02.png`, `frame_04.png`, `frame_06.png`: golden screenshots

Run:

```bash
python3 amiga_eval_benchmark_suite.py --benchmark-config amiga_workspace/benchmarks/mod_playback/reference_suite.json
python3 amiga_eval_benchmark_suite.py --benchmark-config amiga_workspace/benchmarks/mod_playback/control_suite.json
```
