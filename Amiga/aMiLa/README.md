# aMiLa

aMiLa is a native macOS playground for writing, generating, assembling, and testing Commodore Amiga 68k code.

It combines:

- a SwiftUI editor for Motorola 68000 assembly
- an AI assistant tuned for Amiga code generation and repair
- VASM-based assembly checks
- ADF export
- emulator launch paths for FS-UAE, vAmiga, and vAmigaWeb
- an optional local MLX model server

The current model is published at [`bmove/antigravity-amiga-68k`](https://huggingface.co/bmove/antigravity-amiga-68k).

## Quick Start

Open the macOS app:

```bash
open AmigaPlayground/AmigaPlayground.xcodeproj
```

Select the `AmigaPlayground` scheme in Xcode and run it.

The main workflow is:

1. Write or generate 68k assembly in the editor.
2. Assemble it with VASM.
3. Ask the assistant to repair compile errors when needed.
4. Save source, export an ADF, or launch an emulator.

## Local Model

The app can use a local OpenAI-compatible MLX server.

Download the model:

```bash
cd fine_tuning
./download_model.sh
```

Start the server:

```bash
uv run python -m mlx_lm.server --model fused_model --port 1234
```

The app also includes controls in **Settings > Local MLX Server** for starting and inspecting the local server.

## Main Folders

- `AmigaPlayground/`: the macOS app.
- `fine_tuning/`: dataset preparation, training scripts, and model download helper.
- `Dataset/`: Amiga source corpora used for experiments and training.

## App Features

- **Assemble**: compile the current source with `vasmm68k_mot`.
- **Fix Compile Errors with Assistant**: send assembler errors back to the assistant for repair.
- **Save Code**: save the current editor source.
- **Indent Code**: format assembly/C source.
- **Export Bootable ADF**: build an Amiga executable and write an `.adf`.
- **Run Default Emulator**: launch FS-UAE or vAmiga depending on settings.
- **Validate with vAmiga**: run the native vAmiga validation path.
- **Run Web Emulator**: open the embedded vAmigaWeb view.

## Development

Requirements:

- Xcode
- macOS Command Line Tools
- `vasmm68k_mot`
- Python 3.10+
- `uv`

Install Python tooling:

```bash
cd fine_tuning
uv sync
```

Build from the command line:

```bash
xcodebuild \
  -project AmigaPlayground/AmigaPlayground.xcodeproj \
  -scheme AmigaPlayground \
  -destination 'platform=macOS' \
  build
```

Fine-tuning details live in [`fine_tuning/README.md`](fine_tuning/README.md).

## Contributing

Useful contributions include Amiga assembly/C examples, prompt library entries, compiler-repair cases, UI improvements, and emulator validation fixes.

Issues are tracked in the parent repository:

<https://github.com/GINNOV/littlethings/issues>
