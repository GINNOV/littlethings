# Amiga Playground ASM — local MLX runtime

Apple Silicon runtime for **Amiga Playground**: Qwen2.5-Coder-3B + Amiga 68000 ASM LoRA.

| | |
|--|--|
| **Product** | Amiga Playground ASM model |
| **HF** | https://huggingface.co/bmove/amiga-playground-asm |
| **Model id** | `amiga-playground-asm` |
| **Layout** | `runtime/base` + `runtime/adapter` |

## Setup

```bash
cd aMiLa/fine_tuning
uv sync
./download_model.sh
./deploy.sh
```

Amiga Playground: provider **LM Studio (Port 1234)**, model **`amiga-playground-asm`**.

Or use the in-app MLX **Start** control (same layout).

## Score

First-shot sealed compile: **140/140** (7 families × 20), `vasmm68k_mot -m68000 -Fhunkexe`, temp=0.  
Compile gate only — not full hardware-semantic / emulator ladder.

## Server

```bash
uv run python serve_playground.py --port 1234
```

## Train / score (dev)

```bash
uv run python tools/minimal_sealed_asm.py \
  --adapter runtime/adapter \
  --output-dir /tmp/asm-score \
  --limit 0 --compile-backend both
```
