# Sin/Cos Scroller Benchmark

This folder is the next benchmark family after the Copper tasks.

Current milestone:

- the source renders actual text glyphs, not a placeholder block
- the text band drifts horizontally and each character follows a sine-driven Y offset
- motion is intentionally quantized so the benchmark is stable across runs
- the suite scores three captured frames at fixed times
- the passing reference clears the suite, while the fixed-position control fails it

Why this exists:

- it proves the repo can benchmark a temporal effect across multiple frames
- it gives the mutation loop a real text-scroller target instead of a proxy marker
- it is the right mechanical step toward a richer scrolling-text-with-sine/cosine benchmark

Files:

- `reference/current.s`: passing glyph-based text scroller source
- `control/current.s`: broken control with the text band fixed in place
- `mutation/current.s`: degraded motion workspace used by the mutation loop
- `mutation/reference.s`: passing motion blocks used as safe restore targets
- `mutation/seed.s`: degraded reset point for repeated recovery runs
- `golden/frame_02.png`, `frame_04.png`, `frame_06.png`: golden captures for the runway source
- `reference_frame_02.json`, `reference_frame_04.json`, `reference_frame_06.json`: source-built benchmark configs
- `reference_suite.json`: three-frame suite for the passing source
- `control_suite.json`: three-frame suite for the broken control
- `mutation_frame_02.json`, `mutation_frame_04.json`, `mutation_frame_06.json`: source-built benchmark configs for the mutable workspace
- `mutation_suite.json`: three-frame suite for the degradable mutation source

Mutation loop:

- `amiga_sincos_mutation_loop.py` restores named motion blocks from `mutation/reference.s`
- it keeps only score improvements and reverts everything else
- it archives runs under `build/amiga/sincos_mutation_loop/`
- reset the workspace with:

```bash
cp amiga_workspace/benchmarks/sincos_scroller/mutation/seed.s amiga_workspace/benchmarks/sincos_scroller/mutation/current.s
```

Important limitation:

- this is now a working text benchmark, but still a minimal one-byte-aligned scroller
- it benchmarks motion and timing first, not smooth pixel scrolling or advanced raster tricks
- the next step is to add smoother scrolling and broader code-structure mutations
