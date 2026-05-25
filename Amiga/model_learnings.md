# Model Learnings: Amiga ASM Reliability

## Current State

- The current adapter should not be promoted as "rock solid" yet.
- A fresh clean ASM adapter was trained into `aMiLa/fine_tuning/adapters_asm_clean`.
- The broad ladder improved many routine families, but promotion still fails because `bouncing_copper` does not pass after repair.
- The app-side gate is now stricter and should refuse generated ASM that compiles but is semantically wrong.

## What Worked

- Reliability must be built around the model, not trusted to weights alone.
- The useful loop is:
  1. Generate with the same request shape as the app.
  2. Compile with real VASM.
  3. Run semantic validators.
  4. Package an ADF where applicable.
  5. Run emulator smoke checks for hardware/visual cases.
  6. Feed compiler and semantic failures back through a bounded repair loop.
- The model improved materially when trained on compile-verified hard negatives plus corrected outputs.
- The broad capability ladder is more useful than the old six-case ladder because it exposes regressions outside the original prompts.
- Blitter behavior improved after standardizing examples, prompts, and validators around a single convention.

## Why So Many Corrections Were Needed

- The model was not failing from one simple "bad weight" issue. It was learning from a mixed and partially malformed supervision surface.
- The dataset contained different artifact types under the same assistant-output shape:
  - complete AmigaDOS executables,
  - callable routines,
  - bootblocks,
  - constants/equate files,
  - register reference lists,
  - fragments extracted from larger projects.
- When all of those are trained as equally valid answers, the model learns that incomplete snippets and reference listings are acceptable responses to generation prompts.
- Some source examples compile only in their original project context, but the app/eval path asks for standalone VASM-compatible source. That mismatch teaches patterns that look legitimate but fail in the app.
- Several failures were caused by conflicting conventions in the surrounding system:
  - examples used canonical blitter `btst #6,$02(a6)`,
  - earlier validators/prompts expected `btst #14,$02(a6)`,
  - the model learned both and sometimes used the wrong one in the wrong context.
- Prompt-family inference caused misreads. For example, "changes the background color" in a copper prompt was accidentally interpreted as requiring a CPU `COLOR00` write. Explicit ladder families now need to override generic prompt inference.
- Regex validators caused some false positives. The important example was `$a8(a6)` for `AUD0VOL`, which was wrongly read as invalid register `a8`. Validators must distinguish hardware offsets from CPU registers.
- Repair loops can amplify confusion if the repair prompt does not restate the original task and the precise family rule. A model may preserve the wrong behavior because it only sees local failures, not the intended program.
- Repairs were valuable because they turned observed failures into supervised examples of how to recover, but they should not be counted as raw model success. They teach recovery behavior; they do not prove the model can generate correctly first-shot.
- The most useful hard negatives are concrete observed failures, not generic "bad code" examples. Examples:
  - wait-only blitter routine,
  - copper data using `dc.w #...`,
  - missing `dc.w $ffff,$fffe`,
  - `.mouse` label without `btst #6,$bfe001`,
  - malformed sprite code with repeated placeholder writes.

## Blitter Lessons

- Use the canonical Amiga DMACONR byte busy test:

```asm
            btst    #6,$02(a6)
            bne.s   .waitBlitter
```

- Do not train new examples toward `btst #14,$02(a6)`. The validator may recognize it as an old/non-canonical pattern, but repair prompts and curated examples should rewrite to `btst #6,$02(a6)`.
- A blitter routine that only waits and returns is not valid.
- A valid blitter routine should include:
  - wait before starting,
  - `BLTCON0` at `$40(a6)`,
  - source and/or destination pointer setup such as `$50(a6)` / `$54(a6)`,
  - modulo setup such as `$64(a6)` / `$66(a6)`,
  - `BLTSIZE` at `$58(a6)` to start the operation,
  - wait again after `BLTSIZE`.
- After the clean rebuild, blitter copy, masked bob, and fill passed first-shot. Blitter clear passed after repair plus emulator smoke.

## Copper Lessons

- Copper remains the biggest blocker.
- The model frequently emits malformed copper data like:

```asm
            dc.w    #$fffe,$0180,$0f00
```

  This is wrong because `dc.*` data directives must not use immediate `#` markers.

- The model also often omits the required copper terminator:

```asm
            dc.w    $ffff,$fffe
```

- For bouncing/animated copper, require all of:
  - `SECTION Code,CODE,CHIP`,
  - `XDEF _Start`,
  - install list through `$80(a6)`,
  - strobe `$88(a6)`,
  - enable copper DMA through `$96(a6)`,
  - wait for vertical blank,
  - update copper wait/color words every frame,
  - exit on real left mouse check: `btst #6,$bfe001`,
  - terminate with `dc.w $ffff,$fffe`.
- A label named `.mouse` is not evidence of a mouse exit. Validators should require the actual `$bfe001` test.
- The latest model still fails `bouncing_copper` after repair, usually by omitting the terminator and/or using the wrong mouse check.

## Validator Lessons

- Regex validators are useful but can introduce false positives.
- Fixed false positive: `$a8(a6)` for `AUD0VOL` must not be interpreted as invalid address register `a8`.
- Invalid register detection should ignore register-looking text immediately after `$`.
- Data directives should reject immediate markers:

```asm
            dc.w    #$1234
```

- Explicit ladder families should override prompt inference. Otherwise prompts like "changes background color" can accidentally require a CPU `COLOR00` write for a copper-list scenario.

## Dataset Lessons

- The original ASM dataset mixed runnable programs, routines, constants, register lists, bootblocks, and fragments.
- Treating all of those as equivalent "good assistant output" hurts code generation quality.
- The clean split filtered out 358 fragment/reference/long records before training.
- Keep reference/listing examples only when the user prompt explicitly asks for a reference/listing.
- Curated examples must compile with VASM before entering training.
- Hard negatives should be repair examples, not assistant "good output."
- Long examples still caused truncation warnings during training. Future work should split or remove examples that exceed the 1024-token training window.

## Training Lessons

- Loss alone is not a promotion signal.
- The fresh clean training run produced useful improvements, but final validation loss worsened after the best intermediate points.
- Future runs should compare checkpoints using the ladder instead of assuming the final checkpoint is best.
- The clean adapter path used was:

```text
aMiLa/fine_tuning/adapters_asm_clean
```

- The clean config used was:

```text
aMiLa/fine_tuning/config_asm_clean.yaml
```

- The current model should be promoted only when the broad ladder reaches 100% pass-after-repair.

## Eval Results To Remember

- Broad ladder after clean rebuild was not promotable.
- Failed broad cases before later fixes included:
  - `static_copper`,
  - `bouncing_copper`,
  - `sprite_setup`,
  - `audio_dma`.
- After validator/data fixes and short corrective resume:
  - `static_copper`: passed first-shot in focused eval.
  - `sprite_setup`: passed first-shot plus emulator smoke in focused eval.
  - `audio_dma`: passed first-shot plus emulator smoke after fixing `$a8(a6)` false positive.
  - `bouncing_copper`: still failed after repair.

## Recommended Next Steps

1. Add more compiler-verified bouncing copper positives.
2. Add hard-negative repair pairs for:
   - missing `dc.w $ffff,$fffe`,
   - using `$02(a6)` instead of `$bfe001` for mouse,
   - repeated setup writes instead of an animation loop,
   - dropping `SECTION Code,CODE,CHIP` during repair.
3. Regenerate `data_asm`.
4. Train a short focused copper pass from multiple checkpoints, not only the latest adapter.
5. Evaluate these scenarios first:

```bash
python3 aMiLa/fine_tuning/eval_ladder.py \
  --base-url http://localhost:1234 \
  --model default_model \
  --adapter adapters_asm_clean \
  --ladder aMiLa/fine_tuning/asm_capability_ladder.yaml \
  --scenario static_copper \
  --scenario bouncing_copper \
  --scenario sprite_setup \
  --scenario audio_dma \
  --max-repairs 2 \
  --request-timeout 120 \
  --package-adf
```

6. Only after focused scenarios pass, run the full broad ladder.
7. Do not promote until the full broad ladder is 100% pass-after-repair.

## Important Commands

Run Python checks:

```bash
python3 -m py_compile \
  aMiLa/fine_tuning/asm_semantics.py \
  aMiLa/fine_tuning/eval_ladder.py \
  aMiLa/fine_tuning/curated_asm_regressions.py \
  aMiLa/fine_tuning/split_dataset.py

python3 aMiLa/fine_tuning/eval_ladder.py --self-test
```

Regenerate splits:

```bash
python3 aMiLa/fine_tuning/split_dataset.py
```

Train clean adapter:

```bash
cd aMiLa/fine_tuning
uv run python -m mlx_lm.lora --config config_asm_clean.yaml
```

Serve local model:

```bash
cd aMiLa/fine_tuning
uv run python -m mlx_lm.server --model fused_model --port 1234
```

Run broad ladder:

```bash
python3 aMiLa/fine_tuning/eval_ladder.py \
  --base-url http://localhost:1234 \
  --model default_model \
  --adapter adapters_asm_clean \
  --ladder aMiLa/fine_tuning/asm_capability_ladder.yaml \
  --max-repairs 2 \
  --request-timeout 120 \
  --package-adf \
  --output /tmp/amiga_asm_eval_broad_clean.json
```

## Promotion Rule

Do not promote repaired output as raw model success.

Track both:

- first-shot pass rate,
- pass-after-repair rate.

Promotion requires:

- full broad ladder complete,
- 100% pass-after-repair,
- no known validator false positives,
- emulator smoke passing for visual/hardware scenarios selected by the ladder.
