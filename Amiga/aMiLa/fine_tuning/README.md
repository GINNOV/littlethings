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

As of the May 2026 app-side validation update, the best user outcomes come from a hybrid path:

1. route supported prompts to deterministic Amiga templates,
2. extract visible parameters such as text, color, speed, direction, object type, and counts,
3. compile with VASM,
4. run semantic validation,
5. package a bootable ADF,
6. launch FS-UAE and validate a captured frame for visible pixels.

This substantially improves the practical result users see from the model: common prompts no longer depend entirely on free-form generation, and the UI now reports when a template is being used.

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
