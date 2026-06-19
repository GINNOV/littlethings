#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Validating new blitter curated sources with VASM..."
python3 - <<'PY'
import subprocess
import tempfile
from pathlib import Path

from curated_asm_regressions import (
    BLITTER_COPY_SOURCE,
    BLITTER_FILL_SOURCE,
    BLITTER_MASKED_BOB_SOURCE,
    BLITTER_CLEAR_SOURCE,
)

VASM = "/usr/local/bin/vasmm68k_mot"
NDK = Path(__file__).resolve().parents[1] / "Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"

for name, source in [
    ("clear", BLITTER_CLEAR_SOURCE),
    ("copy", BLITTER_COPY_SOURCE),
    ("fill", BLITTER_FILL_SOURCE),
    ("masked_bob", BLITTER_MASKED_BOB_SOURCE),
]:
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / f"{name}.s"
        out = Path(tmp) / f"{name}.o"
        src.write_text(source)
        proc = subprocess.run(
            [
                VASM,
                "-kick1hunks",
                "-Fhunkexe",
                f"-I{NDK}",
                "-o",
                str(out),
                "-nosym",
                str(src),
            ],
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            raise SystemExit(f"{name} failed VASM:\n{proc.stdout}\n{proc.stderr}")
        print(f"  {name}: VASM ok")
PY

echo "Rebuilding data_asm train/valid splits with weighted curated regressions..."
python3 split_dataset.py

echo "Blitter semantics patches applied."
echo "Next: re-run eval_ladder after fine-tuning, or ./evaluate_model_quality.sh"