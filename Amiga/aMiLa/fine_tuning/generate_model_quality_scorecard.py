#!/usr/bin/env python3
"""Aggregate evaluation artifacts into a markdown scorecard."""

from __future__ import annotations

import argparse
import json
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path


LADDER_CATEGORY = {
    "minimal_executable": "Foundations",
    "register_color_write": "Foundations",
    "vblank_wait": "Foundations",
    "static_copper": "Copper Effects",
    "bouncing_copper": "Copper Effects",
    "blitter_clear": "Blitter Animations",
    "blitter_copy": "Blitter Animations",
    "blitter_masked_bob": "Blitter Animations",
    "blitter_fill": "Blitter Animations",
    "bitplane_display": "Hardware Takeover",
    "sprite_setup": "Hardware Takeover",
    "audio_dma": "Intuition UI",
    "cia_input": "Foundations",
    "joystick_poll": "Foundations",
    "keyboard_poll": "Foundations",
    "vblank_interrupt": "Hardware Takeover",
    "exec_graphics_call": "Intuition UI",
    "bootblock_skeleton": "Foundations",
    "reusable_memclear_subroutine": "Foundations",
}

INTEGRATED_CATEGORY = {
    "mod_player_controls_complex": "Intuition UI",
    "double_buffered_bitplane_sprite_copper": "Blitter Animations",
    "blitter_bob_collision_bounds": "Blitter Animations",
    "copper_runtime_raster_validation": "Copper Effects",
    "mouse_sprite_multiplex": "Hardware Takeover",
    "intuition_window_tool": "Intuition UI",
    "clean_takeover_restore": "Hardware Takeover",
}


def load_json(path: Path) -> dict | list | None:
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def summarize_ladder(ladder: dict) -> tuple[str, dict]:
    results = ladder.get("results", [])
    agg = defaultdict(lambda: {"n": 0, "syntax": 0, "semantic": 0, "repair": 0})
    for row in results:
        category = LADDER_CATEGORY.get(row["id"], "Other")
        bucket = agg[category]
        bucket["n"] += 1
        attempt = row["attempts"][0]
        if attempt.get("compile_ok"):
            bucket["syntax"] += 1
        if not attempt.get("semantic_failures"):
            bucket["semantic"] += 1
        if row.get("passed_after_repair"):
            bucket["repair"] += 1

    lines = [
        "| Category | N | Syntax (1st) | Semantic (1st) | Pass after repair |",
        "|---|--:|---:|---:|---:|",
    ]
    for category in ["Foundations", "Hardware Takeover", "Intuition UI", "Copper Effects", "Blitter Animations"]:
        bucket = agg.get(category)
        if not bucket:
            continue
        n = bucket["n"]
        lines.append(
            f"| {category} | {n} | {100 * bucket['syntax'] / n:.0f}% | "
            f"{100 * bucket['semantic'] / n:.0f}% | {100 * bucket['repair'] / n:.0f}% |"
        )

    summary = {
        "first_shot_passes": ladder.get("first_shot_passes"),
        "passes_after_repair": ladder.get("passes_after_repair"),
        "total": ladder.get("total"),
        "promotion_passed": ladder.get("promotion_passed"),
    }
    return "\n".join(lines), summary


def summarize_integrated(run_report: dict | None) -> str:
    if not run_report:
        return "_Integrated XCTest battery not run in this session._"
    lines = [
        "| Check | Result |",
        "|---|---|",
    ]
    for key, value in run_report.items():
        lines.append(f"| {key} | {value} |")
    return "\n".join(lines)


def summarize_vamiga(vamiga_report: dict | None) -> str:
    if not vamiga_report:
        return "_vAmiga smoke not run in this session._"
    lines = [
        "| Family | Success | Notes |",
        "|---|---|---|",
    ]
    for row in vamiga_report.get("results", []):
        lines.append(f"| {row.get('family', '?')} | {row.get('success', False)} | {row.get('summary', '')} |")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ladder", default="evaluation_debug/asm_eval_ladder_summary.json")
    parser.add_argument("--run-report", default="evaluation_debug/model_quality_run_report.json")
    parser.add_argument("--output", default="evaluation_debug/model_quality_scorecard.md")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent
    ladder = load_json(root / args.ladder)
    run_report = load_json(root / args.run_report)

    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    sections = [f"# Model Quality Scorecard\n\nGenerated: {timestamp}\n"]

    if isinstance(ladder, dict):
        table, summary = summarize_ladder(ladder)
        sections.extend(
            [
                "## Raw Model (`adapters_asm`)\n",
                f"- First-shot pass: **{summary.get('first_shot_passes')}/{summary.get('total')}**",
                f"- Pass after repair: **{summary.get('passes_after_repair')}/{summary.get('total')}**",
                f"- Promotion gate: **{'PASS' if summary.get('promotion_passed') else 'FAIL'}**\n",
                table,
                "",
            ]
        )

    if isinstance(run_report, dict):
        sections.extend(
            [
                "## Integrated Producer Path\n",
                summarize_integrated(run_report.get("xctest")),
                "",
                "## vAmiga Runtime\n",
                summarize_vamiga(run_report.get("vamiga")),
                "",
            ]
        )

    output_path = root / args.output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(sections) + "\n", encoding="utf-8")
    print(f"Wrote {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())