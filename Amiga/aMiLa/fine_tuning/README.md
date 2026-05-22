# aMiLa Fine-Tuning

This directory contains the local MLX-LM LoRA pipeline for rebuilding the Antigravity Amiga 68k model after adding new Amiga assembly content.

## When To Retrain

Retrain when you add meaningful new `.s` or `.asm` examples under `../amiga_sources/` and want the model to learn those patterns. Prefer source files that are clear, legal to use, representative of real Amiga workflows, and compilable with `vasmm68k_mot`.

Do not add generated model outputs back into the training corpus unless they were manually reviewed, corrected, and validated. Training on unreviewed generated code will reinforce mistakes.

## Retraining Checklist

Run these commands from this directory:

```bash
cd aMiLa/fine_tuning
uv sync
```

1. Add or update source files under `../amiga_sources/`.
2. Regenerate the dataset:

   ```bash
   uv run python prepare_dataset.py
   ```

   This scans `.s` and `.asm` files, filters unsuitable files, verifies candidates with `vasmm68k_mot`, and writes `dataset.jsonl`.

3. Rebuild the train/validation split:

   ```bash
   uv run python split_dataset.py
   ```

   This writes `data/train.jsonl` and `data/valid.jsonl` using a fixed 90/10 split.

4. Run LoRA fine-tuning and fuse the model:

   ```bash
   ./finetune.sh
   ```

   The script trains adapters into `adapters/`, fuses them into `fused_model/`, and attempts to export `antigravity-amiga-68k.gguf`.

5. Serve the fused model locally:

   ```bash
   mlx_lm.server --model fused_model/ --port 1234
   ```

   The AmigaPlayground app can then use the OpenAI-compatible endpoint at `http://localhost:1234/v1/chat/completions`.

## Where The Model Is

The primary model output is the fused MLX model directory:

```text
aMiLa/fine_tuning/fused_model/
```

Use that path with MLX-LM:

```bash
cd aMiLa/fine_tuning
uv run mlx_lm.server --model fused_model/ --port 1234
```

For AmigaPlayground, choose `LM Studio (Port 1234)` and leave the model name as `antigravity-amiga-68k` or use `default_model`. The app maps the default MLX-LM server model to `default_model` for LM Studio-compatible requests.

## LM Studio And Ollama

The current checked-in model is an MLX fused model, not a checked-in GGUF. LM Studio and Ollama usually expect a GGUF file for local manual loading. The training script attempts to export one here:

```text
aMiLa/fine_tuning/antigravity-amiga-68k.gguf
```

If that file is present after `./finetune.sh`, load it in LM Studio by adding or opening the local GGUF file from that path.

For Ollama, create a local model from the GGUF with a `Modelfile` such as:

```text
FROM ./aMiLa/fine_tuning/antigravity-amiga-68k.gguf
```

Then run:

```bash
ollama create antigravity-amiga-68k -f Modelfile
ollama run antigravity-amiga-68k
```

If the GGUF file is missing, rerun `./finetune.sh` or use the MLX-LM server directly from `fused_model/`.

## PDF Material

Amiga PDFs can improve the overall system, but they should not be dumped directly into the current code-generation fine-tuning dataset.

The current pipeline is built for assembly source files and compiler-verified assistant responses. Raw PDF text is usually prose, tables, OCR noise, examples with broken formatting, and license-sensitive manual content. Mixing that directly into this supervised fine-tune can make the model more verbose, less code-focused, and less likely to emit compilable assembly.

Recommended uses for PDFs:

- Use PDFs as a retrieval corpus for documentation lookup at prompt time.
- Extract small, source-backed examples from PDFs into clean `.s` or `.asm` files, then let `prepare_dataset.py` admit only examples that assemble.
- Convert selected manual sections into curated instruction/answer records only when the answer teaches a concrete Amiga concept and does not replace compiler-verified code examples.
- Keep the original PDFs out of normal Git history unless they are redistributable and tracked intentionally, ideally with Git LFS for large files.

For this model, high-quality verified source examples will usually help more than large volumes of raw manual text.

## Current Outputs

- `dataset.jsonl`: full generated supervised fine-tuning dataset
- `data/train.jsonl`: training split consumed by `finetune.sh`
- `data/valid.jsonl`: validation split consumed by `finetune.sh`
- `adapters/`: LoRA adapter checkpoints
- `fused_model/`: fused MLX model and model card
- `antigravity-amiga-68k.gguf`: optional GGUF export produced by `finetune.sh`
