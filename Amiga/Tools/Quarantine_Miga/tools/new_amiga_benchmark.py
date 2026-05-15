#!/usr/bin/env python3
"""Scaffold a new Amiga benchmark family under amiga_workspace/benchmarks/."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BENCHMARKS_DIR = ROOT / "amiga_workspace" / "benchmarks"
BOOTBLOCK_TEMPLATE = "amiga_workspace/benchmarks/copper_bars/bootblock.s.in"
INCLUDE_ROOT = "amiga_workspace/benchmarks/copper_bars/source"


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", value.strip()).strip("_").lower()
    if not slug:
        raise SystemExit("benchmark name produced an empty slug")
    return slug


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def write_json(path: Path, payload: dict) -> None:
    write_text(path, json.dumps(payload, indent=2) + "\n")


def temporal_readme(name: str, slug: str) -> str:
    return f"""# {name}

This benchmark family was scaffolded by `tools/new_amiga_benchmark.py`.

What is generated:

- `reference/current.s`: passing source workspace
- `control/current.s`: failing control workspace
- `mutation/current.s`: degradable mutable workspace
- `mutation/reference.s`: reference source for safe mutation targets
- `mutation/seed.s`: reset point for repeated mutation runs
- `golden/`: placeholder frame captures to replace with real benchmark crops
- `reference_frame_*.json`: single-frame benchmark configs
- `reference_suite.json`: passing multi-frame suite
- `control_suite.json`: failing control suite
- `mutation_suite.json`: degradable mutation suite

What you still need to do:

1. Replace the placeholder `.s` files with real task code.
2. Capture real golden images into `golden/`.
3. Adjust crop rectangles and timings in the JSON files.
4. Tighten `minimum_similarity` / `minimum_average_score` once the task is stable.

Suggested reset command:

```bash
cp amiga_workspace/benchmarks/{slug}/mutation/seed.s amiga_workspace/benchmarks/{slug}/mutation/current.s
```
"""


def placeholder_source(name: str, mode: str) -> str:
    comment = {
        "reference": "Replace this with a passing reference implementation.",
        "control": "Replace this with an intentionally broken control implementation.",
        "mutation": "Replace this with a degraded but runnable mutation workspace.",
    }[mode]
    return f"""\t; {name} ({mode})
\t; {comment}
\tinclude "../include/registers.i"
\tinclude "hardware/dmabits.i"
\tinclude "hardware/intbits.i"

start:
\tlea \tCUSTOM,a6
\tmove\t#$7ff,DMACON(a6)
\tmove\t#$7fff,INTENA(a6)

\t; TODO: replace this placeholder with real benchmark code.
\t; MUTATION BLOCK main_logic START
\tb ra.s\tmain_loop
\t; MUTATION BLOCK main_logic END

main_loop:
\tbra.s\tmain_loop
"""


def png_placeholder() -> bytes:
    return (
        b"\x89PNG\r\n\x1a\n"
        b"\x00\x00\x00\rIHDR"
        b"\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89"
        b"\x00\x00\x00\x0cIDATx\x9cc```\xf8\x0f\x00\x01\x04\x01\x00]\xc4\xbb\xd1"
        b"\x00\x00\x00\x00IEND\xaeB`\x82"
    )


def frame_config(slug: str, label: str, source_root: str, main_source: str, seconds: int, work_suffix: str, frame_name: str) -> dict:
    return {
        "name": f"{slug}_{work_suffix}_{frame_name}",
        "label": f"{label} {work_suffix.replace('_', ' ').title()} {frame_name.upper()}",
        "description": f"Scaffolded benchmark frame for {label}. Replace placeholder source and golden image.",
        "source_root": source_root,
        "include_root": INCLUDE_ROOT,
        "main_source": main_source,
        "bootblock_template": BOOTBLOCK_TEMPLATE,
        "base_address": "0x70000",
        "disk_size_bytes": 901120,
        "minimum_similarity": 0.999,
        "seconds": seconds,
        "renderer": "software",
        "display": "standard",
        "warp": True,
        "port1": "mouse",
        "port2": "none",
        "accept_bootblock": True,
        "accept_bootblock_delay_ms": 4000,
        "accept_bootblock_hold_ms": 300,
        "work_dir": f"build/amiga/{slug}_{work_suffix}/{frame_name}",
        "disk_image": f"build/amiga/source_{slug}_{work_suffix}_{frame_name}.adf",
        "reference_image": f"amiga_workspace/benchmarks/{slug}/golden/{frame_name}.png",
        "capture_image": f"build/amiga/{slug}_{work_suffix}_{frame_name}_capture.png",
        "capture_crop_image": f"build/amiga/{slug}_{work_suffix}_{frame_name}_crop.png",
        "capture_diff_image": f"build/amiga/{slug}_{work_suffix}_{frame_name}_diff.png",
        "crop": {"left": 240, "top": 180, "right": 620, "bottom": 600},
    }


def suite_config(slug: str, label: str, work_suffix: str) -> dict:
    return {
        "name": f"{slug}_{work_suffix}_suite",
        "label": f"{label} {work_suffix.replace('_', ' ').title()} Suite",
        "description": f"Scaffolded suite for {label}. Replace placeholder sources and goldens.",
        "eval_script": "amiga_eval_benchmark_source.py",
        "work_dir": f"build/amiga/{slug}_{work_suffix}_suite",
        "minimum_average_score": 0.999,
        "components": [
            {
                "label": "frame_02",
                "benchmark_config": f"amiga_workspace/benchmarks/{slug}/{work_suffix}_frame_02.json",
            },
            {
                "label": "frame_04",
                "benchmark_config": f"amiga_workspace/benchmarks/{slug}/{work_suffix}_frame_04.json",
            },
            {
                "label": "frame_06",
                "benchmark_config": f"amiga_workspace/benchmarks/{slug}/{work_suffix}_frame_06.json",
            },
        ],
    }


def create_temporal_family(base_dir: Path, name: str, slug: str) -> None:
    (base_dir / "reference").mkdir(parents=True, exist_ok=True)
    (base_dir / "control").mkdir(parents=True, exist_ok=True)
    (base_dir / "mutation").mkdir(parents=True, exist_ok=True)
    (base_dir / "golden").mkdir(parents=True, exist_ok=True)

    write_text(base_dir / "README.md", temporal_readme(name, slug))
    write_text(base_dir / "reference" / "current.s", placeholder_source(name, "reference"))
    write_text(base_dir / "control" / "current.s", placeholder_source(name, "control"))
    mutation_source = placeholder_source(name, "mutation")
    write_text(base_dir / "mutation" / "current.s", mutation_source)
    write_text(base_dir / "mutation" / "reference.s", placeholder_source(name, "reference"))
    write_text(base_dir / "mutation" / "seed.s", mutation_source)

    for frame_name in ("frame_02", "frame_04", "frame_06"):
        (base_dir / "golden" / f"{frame_name}.png").write_bytes(png_placeholder())

    write_json(
        base_dir / "reference_frame_02.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/reference", f"amiga_workspace/benchmarks/{slug}/reference/current.s", 2, "reference", "frame_02"),
    )
    write_json(
        base_dir / "reference_frame_04.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/reference", f"amiga_workspace/benchmarks/{slug}/reference/current.s", 4, "reference", "frame_04"),
    )
    write_json(
        base_dir / "reference_frame_06.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/reference", f"amiga_workspace/benchmarks/{slug}/reference/current.s", 6, "reference", "frame_06"),
    )
    write_json(
        base_dir / "control_frame_02.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/control", f"amiga_workspace/benchmarks/{slug}/control/current.s", 2, "control", "frame_02"),
    )
    write_json(
        base_dir / "control_frame_04.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/control", f"amiga_workspace/benchmarks/{slug}/control/current.s", 4, "control", "frame_04"),
    )
    write_json(
        base_dir / "control_frame_06.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/control", f"amiga_workspace/benchmarks/{slug}/control/current.s", 6, "control", "frame_06"),
    )
    write_json(
        base_dir / "mutation_frame_02.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/mutation", f"amiga_workspace/benchmarks/{slug}/mutation/current.s", 2, "mutation", "frame_02"),
    )
    write_json(
        base_dir / "mutation_frame_04.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/mutation", f"amiga_workspace/benchmarks/{slug}/mutation/current.s", 4, "mutation", "frame_04"),
    )
    write_json(
        base_dir / "mutation_frame_06.json",
        frame_config(slug, name, f"amiga_workspace/benchmarks/{slug}/mutation", f"amiga_workspace/benchmarks/{slug}/mutation/current.s", 6, "mutation", "frame_06"),
    )

    write_json(base_dir / "reference_suite.json", suite_config(slug, name, "reference"))
    write_json(base_dir / "control_suite.json", suite_config(slug, name, "control"))
    write_json(base_dir / "mutation_suite.json", suite_config(slug, name, "mutation"))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scaffold a new Amiga benchmark family.")
    parser.add_argument("name", help="Human-readable benchmark name, for example 'Raster Twist'.")
    parser.add_argument(
        "--template",
        choices=["temporal_text"],
        default="temporal_text",
        help="Scaffold template to generate.",
    )
    parser.add_argument("--slug", default="", help="Optional directory slug override.")
    parser.add_argument("--force", action="store_true", help="Overwrite an existing benchmark directory.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    slug = args.slug or slugify(args.name)
    base_dir = BENCHMARKS_DIR / slug
    if base_dir.exists() and not args.force:
        raise SystemExit(f"{base_dir} already exists. Use --force to overwrite.")
    if base_dir.exists() and args.force:
        for path in sorted(base_dir.rglob("*"), reverse=True):
            if path.is_file():
                path.unlink()
            elif path.is_dir():
                try:
                    path.rmdir()
                except OSError:
                    pass
        try:
            base_dir.rmdir()
        except OSError:
            pass

    if args.template == "temporal_text":
        create_temporal_family(base_dir, args.name, slug)
    else:
        raise SystemExit(f"unsupported template: {args.template}")

    print("---")
    print(f"benchmark family:   {args.name}")
    print(f"slug:               {slug}")
    print(f"template:           {args.template}")
    print(f"output dir:         {base_dir}")
    print("generated:")
    print("  - reference/current.s")
    print("  - control/current.s")
    print("  - mutation/current.s")
    print("  - mutation/reference.s")
    print("  - mutation/seed.s")
    print("  - golden/frame_02.png")
    print("  - golden/frame_04.png")
    print("  - golden/frame_06.png")
    print("  - reference/control/mutation frame configs")
    print("  - reference/control/mutation suites")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
