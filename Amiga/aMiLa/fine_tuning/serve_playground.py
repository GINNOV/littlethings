#!/usr/bin/env python3
"""Amiga Playground MLX server.

Loads runtime/base + runtime/adapter. Canonical model id: amiga-playground-asm.

Works around mlx_lm.server dropping --adapter-path when remapping model ids.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

FT = Path(__file__).resolve().parent
DEFAULT_BASE = FT / "runtime" / "base"
DEFAULT_ADAPTER = FT / "runtime" / "adapter"
CANONICAL_ID = "amiga-playground-asm"


def _install_patches() -> None:
    from mlx_lm import server as mlx_server

    original_init = mlx_server.ModelProvider.__init__
    original_load = mlx_server.ModelProvider.load

    def patched_init(self, cli_args, *args, **kwargs):
        original_init(self, cli_args, *args, **kwargs)
        model = cli_args.model
        adapter = cli_args.adapter_path
        # mlx_lm seeds maps with "default_model". Replace with our product id only.
        self._model_map.pop("default_model", None)
        self._adapter_map.pop("default_model", None)
        self._draft_model_map.pop("default_model", None)
        keys = {
            CANONICAL_ID,
            model,
            str(Path(model).resolve()) if model else None,
            Path(model).name if model else None,
        }
        for key in keys:
            if not key:
                continue
            self._model_map[key] = model
            self._adapter_map[key] = adapter

    def patched_load_default(self):
        # Upstream load_default() hardcodes key "default_model".
        if self._model_map.get(CANONICAL_ID) is not None:
            self.load(CANONICAL_ID)

    def patched_load(self, model_path, adapter_path=None, draft_model_path=None):
        # Resolve using the *request* id first (fixes upstream map order bug).
        request_id = model_path
        if request_id == "default_model":
            raise ValueError(
                "Unknown model id 'default_model'. Use 'amiga-playground-asm'."
            )
        # mlx_lm request parser defaults draft_model to the string "default_model".
        # That is not a repo id — treat it as "no draft".
        if draft_model_path in (None, "default_model", ""):
            draft_model_path = None
        adapter_path = self._adapter_map.get(request_id, adapter_path)
        model_path = self._model_map.get(request_id, model_path)
        if adapter_path is None:
            adapter_path = self._adapter_map.get(model_path, self.cli_args.adapter_path)
        if draft_model_path is not None:
            draft_model_path = self._draft_model_map.get(
                draft_model_path, draft_model_path
            )
        model_key = (model_path, adapter_path, draft_model_path)
        if self.model_key != model_key:
            self._load(*model_key)
        return self.model, self.tokenizer

    mlx_server.ModelProvider.__init__ = patched_init
    mlx_server.ModelProvider.load = patched_load
    mlx_server.ModelProvider.load_default = patched_load_default


def main(argv: list[str] | None = None) -> None:
    argv = list(sys.argv[1:] if argv is None else argv)

    # Defaults for Playground layout when flags omitted.
    if "--model" not in argv:
        argv = ["--model", str(DEFAULT_BASE), *argv]
    if "--adapter-path" not in argv:
        argv = ["--adapter-path", str(DEFAULT_ADAPTER), *argv]
    if "--port" not in argv:
        argv = ["--port", "1234", *argv]
    if "--host" not in argv:
        argv = ["--host", "127.0.0.1", *argv]

    model = None
    adapter = None
    for i, a in enumerate(argv):
        if a == "--model" and i + 1 < len(argv):
            model = argv[i + 1]
        if a == "--adapter-path" and i + 1 < len(argv):
            adapter = argv[i + 1]

    if not model or not Path(model).exists():
        print(
            f"Missing base model at {model}. Run ./download_model.sh",
            file=sys.stderr,
        )
        sys.exit(2)
    if not adapter or not (Path(adapter) / "adapters.safetensors").exists():
        print(
            f"Missing adapter at {adapter}/adapters.safetensors. Run ./download_model.sh",
            file=sys.stderr,
        )
        sys.exit(2)

    os.chdir(FT)
    sys.argv = [sys.argv[0], *argv]
    _install_patches()

    from mlx_lm.server import main as mlx_main

    print(
        f"Amiga Playground MLX: base={model} adapter={adapter} "
        f"model_id={CANONICAL_ID}",
        flush=True,
    )
    mlx_main()


if __name__ == "__main__":
    main()
