---
library_name: mlx
pipeline_tag: text-generation
tags:
- mlx
- m68k
- assembly
- retrocomputing
- amiga
- c
- vasm
- multi-adapter
---

# aMiLa Fine-Tuning

This directory contains the local MLX-LM LoRA workflow for rebuilding and serving the Antigravity Amiga 68k model.

The current published model is hosted on Hugging Face:

```text
https://huggingface.co/bmove/antigravity-amiga-68k
```

Generated model artifacts are intentionally ignored by GitHub and should be downloaded from, or uploaded to, Hugging Face.

---

## Current Model & Architecture

- **Hub Repo**: [`bmove/antigravity-amiga-68k`](https://huggingface.co/bmove/antigravity-amiga-68k)
- **Base Foundation Model**: `mlx-community/gemma-4-e4b-it-4bit` (Google Gemma 4, 4-billion parameters)
- **Fine-Tuning Method**: Dual Specialized High-Capacity LoRA Adapters
  - **Motorola 68k Assembly Specialist (`adapters_asm/`)**: High-capacity LoRA adapter targeting all layer projections (rank 32, scale 64.0, 1,500 iterations) trained on 500 VASM-compilable retro assembly examples.
  - **Amiga C Specialist (`adapters_c/`)**: High-capacity LoRA adapter targeting all layer projections (rank 32, scale 64.0, 1,500 iterations) trained on 500 Clang-verified C examples.
- **Dynamic Hot-Swapping**: Supported out-of-the-box! Pass `"adapters": "adapters_asm"` or `"adapters": "adapters_c"` in the OpenAI completions request body to dynamically swap adapter weights instantly.
- **Hub Tags**: `mlx`, `m68k`, `assembly`, `retrocomputing`, `amiga`, `c`, `vasm`, `multi-adapter`

The adapters reduce language interference, but reliability comes from the compiler, semantic validator, template router, repair loop, runtime smoke checks, and promotion ladder. Do not promote a new ASM adapter based on loss alone.

---

## Current Reliability Status

As of the June 2026 app-side producer update, the best user outcomes come from a hybrid path:

1. route supported prompts to deterministic Amiga templates,
2. embed a canonical `AmigaProgramModel` contract in generated source,
3. patch same-conversation follow-ups through structured model/source mutation,
4. reject unsafe or ambiguous recognized edits without mutating the editor state,
5. run source-contract and semantic validation,
6. compile with VASM,
7. package a bootable ADF,
8. run runtime-oriented smoke checks where available.

This substantially improves the practical result users see from the model: common prompts no longer depend entirely on free-form generation, and the UI now reports when a template is being used. The most recent improvement stream focuses on holistic same-conversation code production rather than new model weights. A first prompt such as "Generate play and stop controls for a tracker module" routes to a model-backed MOD controls program; compatible follow-ups can add, rename, remove, reorder, retarget, reposition, and parameterize controls while preserving the existing program model, routines, state, and source regions.

Side-by-side with the earlier flow:

| area | previous app-side path | current app-side producer path |
| --- | --- | --- |
| source contract | Generated text plus template hints. | Source embeds a canonical `AmigaProgramModel` with family, kind, controls, routines, state, hardware, and verification expectations. |
| follow-ups | Follow-ups could become ad hoc edits. | Supported follow-ups patch the embedded model and owned source regions together. |
| rejection behavior | Malformed or ambiguous edits could fall through to generic editing. | Recognized structured failures are terminal and preserve the current editor source unchanged. |
| conversation recovery | Recovery after a rejected turn was mostly implicit. | Representative recovery chains prove the rejected turn does not mutate source/model and that the next compatible request continues from the preserved state. |
| promotion proof | Compile and smoke checks were useful but could be indirect for conversation continuity. | Routed first-shot sources, accepted follow-up artifacts, pre-rejection setup states, recovery outputs, and final conversation artifacts all pass source verification and bootable ADF generation gates. |

Current benchmark evidence:

| prompt | template | compile | semantic | ADF | emulator smoke | result |
| --- | --- | --- | --- | --- | --- | --- |
| generate static copper bars | Static copper bars | pass | pass | pass | pass | pass |
| generate bouncing copper bars | Bouncing copper bars | pass | pass | pass | pass | pass |
| generate a starfield demo | Starfield | pass | pass | pass | pass | pass |
| generate a bouncing sprite object | Bouncing sprite | pass | pass | pass | pass | pass |
| make a color-cycling logo that says "amiga" | Color-cycling text | pass | pass | pass | pass | pass |

The runtime smoke benchmark stores per-prompt artifacts, including the generated ADF, captured emulator screenshot, manifest JSON, and a markdown scorecard. Text-oriented prompts also require bright pixels in the expected central region instead of merely accepting a non-crashing emulator launch.

Important caveat: this scorecard measures the integrated local app path, not raw model weights in isolation. Unsupported prompts still fall back to model generation with warnings and nearest supported template suggestions.

---

## Download The Published Model

Run from this directory:

```bash
./download_model.sh
```

This downloads `bmove/antigravity-amiga-68k` into:

```text
fused_model/
```

You can override the repo or target directory:

```bash
HF_MODEL_REPO=bmove/antigravity-amiga-68k ./download_model.sh fused_model
```

The script requires the Hugging Face CLI:

```bash
hf auth whoami
```

Authentication is optional for the current public model, but required if you publish updated artifacts.

---

## Serve Locally

Start the OpenAI-compatible MLX server:

```bash
uv run python -m mlx_lm.server --model fused_model --port 1234
```

Or use the helper script:

```bash
./deploy.sh
```

The server exposes:

```text
http://localhost:1234/v1/models
http://localhost:1234/v1/chat/completions
```

In Amiga Playground, use the `LM Studio (Port 1234)` provider. The app can also start and stop the local MLX server from **Settings > Local MLX Server** when `fused_model/` is present.

---

## ASM Promotion Ladder

Run the ASM capability ladder against the same OpenAI-compatible request shape used by the app:

```bash
uv run python eval_ladder.py \
  --base-url http://localhost:1234 \
  --model default_model \
  --adapter adapters_asm \
  --ladder asm_capability_ladder.yaml \
  --package-adf \
  --output evaluation_debug/asm_eval_ladder_summary.json
```

For the strict gate, add `--require-emulator` to require FS-UAE to stay alive during the smoke window. The ladder intentionally avoids regex cleanup before compiling: it extracts the model's code block, compiles that source with VASM, applies semantic checks for the prompt family, optionally packages an ADF, and records both first-shot and pass-after-repair rates. Treat an ASM adapter as promotable only when every golden scenario passes after the bounded repair loop.

Blitter code should use the canonical Amiga DMACONR byte busy test:

```asm
            btst    #6,$02(a6)
            bne.s   .waitBlitter
```

The validators can recognize the older bit-14 wording as a blitter wait, but training examples and repair prompts should rewrite to `btst #6,$02(a6)`.

---

## Complex Functional Code Gym

The next model-quality frontier is the execution-grounded complex benchmark and repair corpus:

```text
complex_amiga_benchmark_corpus.json
```

It defines seven representative complex Amiga program families:

- MOD player controls with stateful Paula playback.
- Double-buffered bitplane animation with sprite/copper interaction.
- Blitter BOB movement with bounds and collision.
- Copper raster effects with runtime frame validation.
- Mouse-controlled sprite multiplexing.
- Intuition windowed tools with balanced resource cleanup.
- Clean takeover demos with full system restore.

Current app-side executable seed coverage includes MOD controls, double-buffered bitplanes, blitter BOB collision/bounds, copper raster validation, mouse sprite multiplexing, Intuition window cleanup, and clean takeover restore. The Intuition window tool now embeds an `AmigaProgramModel`, proves deterministic routing, generated ASM, semantic checks, VASM compile, bootable ADF generation, runtime-evidence contract JSON for balanced library/window/event cleanup, the corpus follow-up chain, rejected-turn diagnostics, and targeted cleanup broken-variant rejection. Clean takeover now also embeds an `AmigaProgramModel` and proves deterministic routing, generated ASM, semantic checks, VASM compile, bootable ADF generation, runtime-evidence contract JSON, the corpus follow-up chain, rejected-turn no-mutation behavior, and restore-path broken-variant diagnostics. The standalone Intuition and clean takeover vAmiga artifact gates are wired as opt-in promotion smokes.

Every family must declare the same professional proof surface: structured model requirements, generated ASM expectations, semantic verification, VASM compile, bootable ADF generation, runtime evidence, multi-turn follow-up preservation, rejected-turn no-mutation behavior, and repair-loop seeds from deliberately broken variants.

Validate the corpus before using it to generate golden or repair training data:

```bash
uv run python validate_complex_benchmark_corpus.py
```

Build the deterministic JSONL records used for evaluation, repair-seed curation, and future training data extraction:

```bash
uv run python build_complex_benchmark_records.py
```

Repair records are not just free-form prompts. Each `repair_seed` JSONL entry now carries a `repair_attempt_contract` with the broken variant strategy, expected pre-repair diagnostic, narrow-patch scope, forbidden broad rewrites, post-repair required gates, runtime evidence contract, family proof tests, and preference order. This keeps repair examples aligned with the code-gym verifier stack instead of training the model to produce plausible broad rewrites.

The generated records are stored in:

```text
complex_amiga_benchmark_records.jsonl
```

To verify the tracked records are still synchronized with the corpus:

```bash
uv run python build_complex_benchmark_records.py --check
```

Build the dedicated repair-loop examples used to train or evaluate the narrow repair step:

```bash
uv run python build_complex_repair_loop_examples.py
```

The generated repair-loop examples are stored in:

```text
complex_amiga_repair_loop_examples.jsonl
```

To verify those examples are still synchronized with the corpus and benchmark records:

```bash
uv run python build_complex_repair_loop_examples.py --check
```

Build the before/after proof manifests for every repair-loop example:

```bash
uv run python build_complex_repair_proofs.py
```

The generated repair proof manifests are stored in:

```text
complex_amiga_repair_proofs.jsonl
```

To verify those proof manifests still cover every repair-loop gate in corpus order:

```bash
uv run python build_complex_repair_proofs.py --check
```

Build the executable repair matrix that turns each repair proof into concrete Swift test commands:

```bash
uv run python build_complex_repair_execution_matrix.py
```

The generated execution matrix is stored in:

```text
complex_amiga_repair_execution_matrix.jsonl
```

To verify the matrix is synchronized with the repair proofs:

```bash
uv run python build_complex_repair_execution_matrix.py --check
```

To run the fast before/after proof set for every repair seed:

```bash
uv run python build_complex_repair_execution_matrix.py --check --execute fast
```

Build the concrete source-mutation evidence rows that bind every repair seed to a deterministic broken source, the expected verifier failure, and the repaired source pass condition:

```bash
uv run python build_complex_repair_mutation_runs.py
```

The generated mutation runs are stored in:

```text
complex_amiga_repair_mutation_runs.jsonl
```

To verify the mutation-run artifact is synchronized with the corpus and execution matrix:

```bash
uv run python build_complex_repair_mutation_runs.py --check
```

The Swift test `testComplexAmigaRepairMutationRunsFailBeforeAndPassAfter` reads this JSONL and executes all 14 deterministic mutations. Each row must preserve the embedded template identity, fail before repair with the declared source/semantic/runtime diagnostic, and pass after restoring the verified narrow repair source.

The concrete verifier-output transcript generated by that Swift runner is stored in:

```text
complex_amiga_repair_verifier_transcripts.jsonl
```

Each transcript row records the actual before-repair verifier failure array, the matched expected diagnostic, the preserved template identity, and the empty after-repair failure array. Regenerate it from the Swift verifier stack with:

```bash
AMIGA_COMPLEX_REPAIR_TRANSCRIPT_OUTPUT="$PWD/complex_amiga_repair_verifier_transcripts.jsonl" \
  swift test --package-path ../AmigaPlayground \
  --filter AmigaPlaygroundTests/testComplexAmigaRepairMutationVerifierTranscriptsMatchCurrentVerifierOutput
```

Then validate the tracked transcript structure and mutation-run alignment:

```bash
uv run python validate_complex_repair_verifier_transcripts.py
```

Build and verify the golden source distillation artifact generated from the app-side source providers and replayable corpus follow-up chains:

```bash
AMIGA_COMPLEX_GOLDEN_SOURCES_OUTPUT="$PWD/complex_amiga_golden_sources.jsonl" \
AMIGA_COMPLEX_FOLLOWUP_GAPS_OUTPUT="$PWD/complex_amiga_followup_replay_gaps.jsonl" \
  swift test --package-path ../AmigaPlayground \
  --filter AmigaPlaygroundTests/testComplexAmigaGoldenSourcesMatchCurrentVerifiedOutputs
```

The golden rows are stored in:

```text
complex_amiga_golden_sources.jsonl
```

Each row contains the chat messages, verified assistant source, embedded model metrics, source/semantic/runtime verification status, and distillation labels. Current coverage is 12 rows: first-shot verified sources for all seven families, plus terminal multi-turn sources for the five declared chains that fully replay through structured patching.

Declared follow-up chains that do not yet replay are stored in:

```text
complex_amiga_followup_replay_gaps.jsonl
```

Validate both artifacts with:

```bash
uv run python validate_complex_golden_sources.py
```

Audit the whole code-gym contract across the corpus, benchmark records, golden sources, repair examples, repair proofs, execution matrix, mutation runs, and verifier transcripts:

```bash
uv run python validate_complex_goal_completion.py
```

This cross-artifact audit proves the current package still has 5-8 representative families, the full required gate set, first-shot and terminal multi-turn golden sources for every family, no unresolved follow-up replay gaps, repair evidence for every declared seed, runtime artifact contracts, domain tags, negative/rejected examples, and preference data ordered as `passes_all_gates > compiles_only > plausible_but_unverified`.

Do not train terminal multi-turn golden samples for rows listed in the gap file. Those rows must first gain structured patcher support and verifier coverage, or the unsupported prompt must be removed from the corpus.

Current executable seeds:

- `mod_player_controls_complex` is bound to the app-side `mod-player-controls` template as an initial executable seed. The seed keeps the model-backed Play/Stop UI and existing same-conversation follow-up surface, while boot-previewing `PlayMOD` so vAmiga can observe Paula state without synthetic mouse input. Focused proof tests cover deterministic routing, embedded model verification, semantic validation, VASM compile, bootable ADF generation, generated-record binding, multi-turn Play/Stop/Volume/Pause preservation, rejected-turn no-mutation behavior, runtime-evidence contract JSON for AUD0LC/AUD0LEN/AUD0PER/AUD0VOL and DMACON, and an opt-in standalone vAmiga promotion gate. The exact terminal corpus chain now also proves Play/Stop/Volume/Pause/Mute preservation, collision-aware relative placement for `Volume Up below Play`, shared-verb parameter edits, A-3 playback-period mapping, and a final opt-in vAmiga artifact gate.
- `double_buffered_bitplane_sprite_copper` is bound to the app-side `double-buffer-bitplane` template as an initial executable seed. The seed now declares bitplane, sprite, copper, and CIA ownership; emits an owned copper list; writes front/back BPL pointers, COLOR01 values, and SPR0 pointer evidence; and has a dedicated runtime-evidence manifest for vblank-paced buffer swaps with copper/sprite overlay state. Focused proof tests cover deterministic routing, embedded model verification, semantic validation, VASM compile, bootable ADF generation, generated-record binding, color follow-up preservation, rejected color edits without mutation, runtime source-proof JSON generation, and an opt-in standalone vAmiga promotion gate.
- `blitter_bob_collision_bounds` is bound to the app-side `blitter-bob-collision-bounds` template and is now app-side promoted with opt-in runtime evidence. The focused Swift proof checks deterministic routing, embedded `AmigaProgramModel` source verification, semantic validation, VASM compile, bootable ADF generation, generated-record binding, same-conversation follow-up preservation for speed/target/color edits, rejected-turn no-mutation routing, runtime-evidence contract JSON generation for vblank/blitter/collision observability, and repair-seed diagnostics for missing post-blit wait and missing right-edge bounds clamp. The opt-in `testComplexBlitterBOBStandaloneVAmigaRuntimeEvidenceWhenEnabled` promotion gate compiles the family, generates an ADF, launches the standalone vAmiga validator, and now passes with non-black frame evidence plus register evidence for RAM PC, owned copper list, `BPLCON0=$1200`, `DMACON=$03c0`, and a nonzero first bitplane pointer. The family remains an initial executable seed rather than a complete family proof until every declared follow-up has its own promoted runtime capture.
- `copper_runtime_raster_validation` is bound to the app-side `bouncing-copper-bars` template as an initial executable seed. The seed embeds an `AmigaProgramModel`, routes the benchmark prompt deterministically, compiles with VASM, generates a bootable ADF, and has a dedicated runtime-evidence contract for vblank-paced copper WAIT updates. The template now exposes model-owned bar count, spacing, bounce speed, palette, and top status band state; focused follow-up tests prove the declared same-conversation chain for eight bars, slower bounce, blue/white palette, and a top status band without losing semantic, runtime-contract, or compile validity. Rejected-turn tests also prove unsafe copper waits, odd instruction addresses, COPJMP1 removal, and zero bars are rejected without free-form mutation. Repair-seed diagnostics now cover missing COPJMP1 and flat model-palette runtime evidence. The opt-in `testComplexCopperRuntimeRasterStandaloneVAmigaRuntimeEvidenceWhenEnabled` gate passes with vAmiga evidence for observed `COP1LC`, runtime `DMACON`, changing copper-list memory, and changing custom color register state. The opt-in `testComplexCopperRuntimeRasterFollowUpChainStandaloneVAmigaRuntimeEvidenceWhenEnabled` gate also compiles the terminal four-turn follow-up artifact, builds an ADF, and validates it through standalone vAmiga runtime evidence.
- `mouse_sprite_multiplex` is bound to the app-side `mouse-sprite-multiplex` template as an initial executable seed. The seed embeds an `AmigaProgramModel`, samples `JOY0DAT`, updates primary and offset sprite control words under vblank, programs `SPR0PT`/`SPR1PT`, and owns a visible one-bitplane backdrop so frame capture can prove display output. The opt-in `testComplexMouseSpriteMultiplexStandaloneVAmigaRuntimeEvidenceWhenEnabled` gate passes with vAmiga evidence for nonblack frame output, sprite and bitplane DMA, a nonzero first bitplane pointer, changing `SPR0PT`/`SPR1PT` memory, and left-mouse clean exit behavior after the startup grace period. Focused follow-up tests now prove all declared same-conversation structured patches for sprite color, follower offset, horizontal wrapping, and one-frame follower lag, plus rejected-turn no-mutation behavior for unsupported colors, missing offset values, and unsafe sprite pointer edits. The opt-in `testComplexMouseSpriteMultiplexFollowUpChainStandaloneVAmigaRuntimeEvidenceWhenEnabled` gate also compiles the terminal four-turn follow-up artifact, builds an ADF, and validates it through standalone vAmiga runtime evidence. Repair-seed diagnostics now cover missing multiplexed sprite pointer writes and sprite updates moved outside the vblank-paced path.
- `intuition_window_tool` is bound to the app-side `intuition-window-tool` template as an initial executable seed. The seed opens `intuition.library`, builds a two-gadget window, waits on IDCMP messages, dispatches Play/Stop gadget events, replies to messages, and funnels close-window and failure paths through balanced `CloseWindow`/`CloseLibrary` cleanup. Focused proof tests cover deterministic routing, embedded model verification, semantic validation, VASM compile, bootable ADF generation, generated-record binding, the declared follow-up chain for adding Volume Up, renaming Stop to Halt, moving buttons, and preserving status text cleanup, rejected-turn no-mutation behavior, runtime-evidence contract JSON for system-friendly resource and event cleanup, negative runtime proof for missing `CloseWindow`, and repair-seed diagnostics for missing `CloseLibrary` and missing `CloseWindow`. The opt-in `testComplexIntuitionWindowToolStandaloneVAmigaRuntimeEvidenceWhenEnabled` gate compiles the family, generates an ADF, and launches standalone vAmiga validation when `AMIGA_RUN_COMPLEX_INTUITION_VAMIGA_SMOKE=1` or `/private/tmp/AMIGA_RUN_COMPLEX_INTUITION_VAMIGA_SMOKE` is present.
- `clean_takeover_restore` is now bound to the app-side `clean-takeover` template as an initial executable seed. The seed saves the active view, DMACONR, INTENAR, COP1LC, and COLOR00 before takeover; disables interrupts and old DMA; installs an owned copper list; runs a vblank-paced COLOR00 cycle; and restores palette, copper pointer, DMA, interrupts, view, and graphics.library cleanup through one shared mouse-exit path. Focused proof tests cover deterministic routing, embedded model verification, source-level restore evidence, semantic validation, VASM compile, bootable ADF generation, generated-record binding, runtime-evidence contract JSON for saved state, owned copper/color output, restore routing, LoadView restoration, and CloseLibrary cleanup, a negative runtime proof for missing DMACON restore, the declared four-turn follow-up chain for green palette, copper split, every-other-vblank pacing, and right-mouse restore, rejected-turn no-mutation behavior for unsafe restore edits, and repair-seed diagnostics for missing DMA restore and an exit path that bypasses restore. The opt-in `testComplexCleanTakeoverRestoreStandaloneVAmigaRuntimeEvidenceWhenEnabled` gate compiles the family, generates an ADF, and launches standalone vAmiga validation when `AMIGA_RUN_COMPLEX_CLEAN_TAKEOVER_VAMIGA_SMOKE=1` or `/private/tmp/AMIGA_RUN_COMPLEX_CLEAN_TAKEOVER_VAMIGA_SMOKE` is present.

Runtime validator sanity gate:

- `validate_emulator_runtime.py --skip-gui --allow-state-second-path` now validates the handcrafted sentinel without macOS Accessibility-dependent window capture. It proves the generated ADF boots under vAmiga by combining raw frame evidence with RetroShell CPU/copper/custom-chip state. The app-side opt-in `testVAmigaRuntimeSmokeHandcraftedSentinelWhenEnabled` uses this path unless `AMIGA_SMOKE_HOST_SCREEN_CAPTURE=1` requests the stricter host-image second path. Run it through `AMIGA_RUN_VAMIGA_SENTINEL_SMOKE=1 aMiLa/AmigaPlayground/script/validate_amiga_agent.sh` when changing runtime capture or ADF boot plumbing.
- In ADF mode, the validator also records disk inspection, startup-sequence text, boot-state registers, and template-specific evidence. For the blitter BOB seed, this caught the original failure where the OS copper/interrupt path overwrote direct display writes; the repaired template now disables OS interrupts/DMA for the hardware-owned frame, installs its own copper list, and enables bitplane, copper, and blitter DMA with `$83c0`.
- The full complex promotion suite is available through `AMIGA_RUN_COMPLEX_VAMIGA_SMOKE=1 AMIGA_SMOKE_ROM_DIR=/path/to/kickstarts aMiLa/AmigaPlayground/script/validate_amiga_agent.sh`. It enables all ten focused vAmiga gates for MOD base/follow-up, double-buffered bitplanes, blitter BOB, copper base/follow-up, mouse sprite base/follow-up, Intuition, and clean takeover. The standalone validator treats the first boot-state snapshot as early evidence only; for families still in Kickstart at that instant, runtime CPU/custom-chip snapshots prove execution once the generated program reaches RAM and starts programming DMA, copper, bitplanes, sprites, or audio.

This corpus is intentionally stricter than the older prompt ladder. The prompt ladder measures raw generation and bounded repair. The complex code gym defines what must become a shippable, multi-turn, runtime-observed app-side capability before it is promoted or distilled back into training data.

---

## When To Retrain

Retrain when you add meaningful new `.s`, `.asm`, or curated Amiga C examples and want the model to learn those patterns.

Prefer examples that are:

- legal to redistribute or use for training,
- representative of real Amiga workflows,
- clear enough to teach a pattern,
- compiler-reviewed where practical,
- not raw generated model output.

Do not add unreviewed generated outputs back into the corpus. That reinforces model mistakes.

---

## Retraining Checklist

Run from this directory:

```bash
uv sync
```

1. Add or update source material in the appropriate local corpus/source directories.

2. Regenerate the supervised dataset:

   ```bash
   uv run python prepare_dataset.py
   ```

   `prepare_dataset.py` scans candidate files, filters unsuitable material, checks assembly candidates with `vasmm68k_mot` where supported, and writes:

   ```text
   dataset.jsonl
   ```

3. Rebuild the train/validation split:

   ```bash
   uv run python split_dataset.py
   ```

   This writes:

   ```text
   data/train.jsonl
   data/valid.jsonl
   ```

4. Run a fresh clean ASM LoRA rebuild when changing the broad ASM capability data:

   ```bash
   uv run python -m mlx_lm.lora --config config_asm_clean.yaml
   ```

   This writes a clean adapter to:

   ```text
   adapters_asm_clean/
   ```

5. Run LoRA fine-tuning and fuse the model:

   ```bash
   ./finetune.sh
   ```

   The script:

   - trains LoRA adapters into `adapters/`,
   - saves checkpoints every 100 iterations,
   - runs 1,500 iterations by default,
   - fuses the final adapters into `fused_model/`.

6. Smoke-test the fused model locally:

   ```bash
   uv run python -m mlx_lm.server --model fused_model --port 1234
   curl http://localhost:1234/v1/models
   ```

7. Publish regenerated artifacts to Hugging Face:

   ```bash
   hf upload-large-folder bmove/antigravity-amiga-68k fused_model --type model --num-workers 4
   hf upload bmove/antigravity-amiga-68k adapters adapters --type model --commit-message "Update LoRA adapter checkpoints"
   ```

Update the Hugging Face model card when training parameters, dataset scope, or intended usage changes.

---

## GGUF, LM Studio, And Ollama

The current published artifact is an MLX fused model, not a checked-in GGUF.

LM Studio and Ollama typically expect GGUF for manual model loading. `finetune.sh` no longer performs a GGUF conversion itself because the current quantized Gemma 4 MLX checkpoint is not handled by MLX-LM's primitive GGUF converter.

If you need GGUF:

- fuse the model with `./finetune.sh`,
- convert from compatible unquantized weights using a current `llama.cpp` conversion path,
- store the resulting `.gguf` outside Git or upload it to Hugging Face as a generated artifact.

If a GGUF exists locally, it is ignored by Git:

```text
*.gguf
```

---

## Artifact Policy

GitHub should contain source code, scripts, data preparation logic, lightweight dataset splits, and documentation.

GitHub should not contain generated model artifacts:

- `adapters/`
- `fused_model/`
- `*.gguf`
- `server.log`

The parent repo also ignores the large generated corpus manifest:

```text
aMiLa/Dataset/corpus1/corpus_manifest.jsonl
```

Publish model artifacts to Hugging Face instead.

---

## PDF And Manual Material

Amiga manuals and PDFs can help the broader system, but they should not be dumped directly into this supervised fine-tuning dataset.

Raw PDF text is usually prose-heavy, noisy, table-oriented, and license-sensitive. It can make the model more verbose and less likely to emit clean, compiler-friendly code.

Better uses:

- Use manuals as a retrieval corpus at prompt time.
- Extract small, source-backed examples into clean `.s`, `.asm`, or `.c` files.
- Admit examples only after review and compiler/toolchain checks where practical.
- Convert selected manual sections into curated instruction/answer records only when they teach a concrete Amiga programming concept.

For this model, reviewed source examples are usually more valuable than large volumes of raw manual text.

---

## Outputs

Common local files and directories:

- `dataset.jsonl`: generated supervised fine-tuning dataset.
- `data/train.jsonl`: training split.
- `data/valid.jsonl`: validation split.
- `adapters/`: LoRA adapter checkpoints, ignored by Git.
- `fused_model/`: fused MLX checkpoint, ignored by Git.
- `evaluation_debug/`: local debug outputs from evaluation workflows.
- `server.log`: local MLX server log, ignored by Git.
