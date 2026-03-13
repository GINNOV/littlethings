#!/usr/bin/env python3
"""Run a local keep/revert mutation loop for the Copper mutation benchmark."""

from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import os
import random
import re
import shutil
import subprocess
import time
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib import error as urlerror
from urllib import request as urlrequest

from project_settings import load_project_settings


ROOT = Path(__file__).resolve().parent
PROJECT_SETTINGS = load_project_settings()
MUTATION_LOOP_SETTINGS = PROJECT_SETTINGS["mutationLoop"]
BENCHMARK_SETTINGS = PROJECT_SETTINGS["benchmark"]
OPENAI_SETTINGS = PROJECT_SETTINGS["llm"]["openai"]
LMSTUDIO_SETTINGS = PROJECT_SETTINGS["llm"]["lmstudio"]

DEFAULT_BENCHMARK_CONFIG = ROOT / MUTATION_LOOP_SETTINGS["benchmarkConfig"]
DEFAULT_EVAL_SCRIPT = ROOT / MUTATION_LOOP_SETTINGS["evalScript"]
DEFAULT_BUILD_DIR = ROOT / "build" / "amiga"
DEFAULT_LOOP_DIR = ROOT / MUTATION_LOOP_SETTINGS["loopDir"]
OPENAI_RESPONSES_URL = "https://api.openai.com/v1/responses"
LMSTUDIO_BASE_URL = "http://127.0.0.1:1234"
SCORE_EPSILON = 1e-12
REGION_BUCKET_SIZE = 16
RESULTS_HEADER = (
    "iteration\tscore\tbest_before\tbest_after\tstatus\tmutation\tbenchmark_ok\teval_code\trun_dir\n"
)
ARCHIVE_FILES = [
    "report.json",
    "selected_source.json",
    "vamigaweb_report.json",
    "benchmark_capture.png",
    "benchmark_capture_crop.png",
    "benchmark_capture_diff.png",
    "assemble.stdout.log",
    "assemble.stderr.log",
    "package.stdout.log",
    "package.stderr.log",
    "emulate.stdout.log",
    "emulate.stderr.log",
    "verify.stdout.log",
    "verify.stderr.log",
]
RATIONALE_MAX_LEN = 220
RATIONALE_SCORE_CLAIM_RE = re.compile(
    r"\b\d+\.\d{3,}\b|\b(?:score|similarity|mae|delta)\b.{0,32}\b(?:from|to|will|would|should)\b",
    re.IGNORECASE,
)


@dataclass
class EvalOutcome:
    score: float | None
    benchmark_ok: bool
    returncode: int
    report_path: Path
    report: dict[str, Any]
    stdout: str
    stderr: str
    seconds: float


@dataclass
class Candidate:
    mutation: str
    description: str
    pairs: list[tuple[str, str]]
    focus: int = 0
    region_start: int | None = None
    region_end: int | None = None


@dataclass
class GapSpan:
    insert_at: int
    left_ref: int | None
    right_ref: int | None
    missing_indices: list[int]


@dataclass
class CandidateSelection:
    candidate: Candidate
    candidate_index: int
    source: str
    rationale: str
    request_payload: dict[str, Any] | None = None
    response_payload: dict[str, Any] | None = None


@dataclass
class MutationTarget:
    mode: str
    path: Path
    entrypoint_path: Path
    state_text: str
    current_pairs: list[tuple[str, str]]
    marker_start: str = ""
    marker_end: str = ""


def default_candidate_rationale(candidate: Candidate) -> str:
    if candidate.mutation == "insert_reference_pair":
        return "Adds a missing reference-derived pair while preserving raster order."
    if candidate.mutation == "insert_reference_segment":
        return "Adds a short reference-derived segment to close a larger gap while preserving raster order."
    if candidate.mutation == "fill_gap_segment":
        return "Closes an entire small or targeted gap with a contiguous reference-derived segment."
    if candidate.mutation == "shift_pair":
        return "Moves one existing pair toward the reference ordering without changing list length."
    if candidate.mutation == "shift_window":
        return "Moves a short consecutive window toward the reference ordering without changing list length."
    if candidate.mutation == "remove_pair":
        return "Tests whether the current list is locally too dense while keeping the list valid."
    return "Chooses the structurally safest next change for the current copper list."


def sanitize_rationale(rationale: str, candidate: Candidate) -> str:
    compact = " ".join(str(rationale or "").split())
    if not compact:
        return default_candidate_rationale(candidate)
    if RATIONALE_SCORE_CLAIM_RE.search(compact):
        return default_candidate_rationale(candidate)
    if len(compact) > RATIONALE_MAX_LEN:
        compact = compact[: RATIONALE_MAX_LEN - 3].rstrip(" ,;:.") + "..."
    return compact


def benchmark_capture_path(report: dict[str, Any]) -> Path | None:
    benchmark = report.get("benchmark") if isinstance(report, dict) else None
    candidates = [
        benchmark.get("capture_crop_image") if isinstance(benchmark, dict) else None,
        benchmark.get("capture_image") if isinstance(benchmark, dict) else None,
        str(DEFAULT_BUILD_DIR / "benchmark_capture_crop.png"),
        str(DEFAULT_BUILD_DIR / "benchmark_capture.png"),
        str(DEFAULT_BUILD_DIR / "emulator_capture.png"),
    ]
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate)
        if path.exists():
            return path
    return None


def file_sha256(path: Path | None) -> str:
    if path is None or not path.exists():
        return ""
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_image_hash_cache(path: Path) -> dict[str, Any]:
    raw = load_json_file_or_default(path, {"version": 1, "hashes": {}})
    hashes = raw.get("hashes")
    if not isinstance(hashes, dict):
        raw["hashes"] = {}
    return raw


def save_image_hash_cache(path: Path, cache: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cache, indent=2) + "\n", encoding="utf-8")


def load_candidate_cache(path: Path) -> dict[str, Any]:
    raw = load_json_file_or_default(path, {"version": 1, "entries": {}})
    entries = raw.get("entries")
    if not isinstance(entries, dict):
        raw["entries"] = {}
    return raw


def save_candidate_cache(path: Path, cache: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cache, indent=2) + "\n", encoding="utf-8")


def load_region_cache(path: Path) -> dict[str, Any]:
    raw = load_json_file_or_default(path, {"version": 1, "entries": {}})
    entries = raw.get("entries")
    if not isinstance(entries, dict):
        raw["entries"] = {}
    return raw


def save_region_cache(path: Path, cache: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(cache, indent=2) + "\n", encoding="utf-8")


def update_image_hash_cache(
    cache: dict[str, Any],
    *,
    image_hash: str,
    score: float | None,
    iteration: int,
    run_dir: Path,
) -> dict[str, Any]:
    hashes = cache.setdefault("hashes", {})
    entry = hashes.get(image_hash)
    repeated = isinstance(entry, dict)
    if not isinstance(entry, dict):
        entry = {
            "count": 0,
            "first_iteration": iteration,
            "first_run_dir": str(run_dir),
            "best_score": score,
            "last_score": score,
            "last_iteration": iteration,
            "last_run_dir": str(run_dir),
        }
        hashes[image_hash] = entry

    previous_best_score = entry.get("best_score") if isinstance(entry.get("best_score"), (int, float)) else None
    entry["count"] = int(entry.get("count", 0)) + 1
    entry["last_score"] = score
    entry["last_iteration"] = iteration
    entry["last_run_dir"] = str(run_dir)
    if previous_best_score is None or (isinstance(score, (int, float)) and score > previous_best_score + SCORE_EPSILON):
        entry["best_score"] = score
    return {
        "repeated": repeated,
        "previous_best_score": previous_best_score,
        "count": entry["count"],
    }


def current_state_hash(current_text: str) -> str:
    return hashlib.sha256(current_text.encode("utf-8")).hexdigest()


def candidate_state_key(state_hash: str, candidate: Candidate) -> str:
    payload = f"{state_hash}\n{candidate.mutation}\n{candidate.description}"
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def normalize_region_bounds(start: int | None, end: int | None) -> tuple[int, int] | None:
    if not isinstance(start, int) or not isinstance(end, int):
        return None
    if start > end:
        start, end = end, start
    return start, end


def candidate_region_bounds(candidate: Candidate) -> tuple[int, int] | None:
    return normalize_region_bounds(candidate.region_start, candidate.region_end)


def bucket_region_bounds(bounds: tuple[int, int] | None, bucket_size: int = REGION_BUCKET_SIZE) -> tuple[int, int] | None:
    if bounds is None:
        return None
    start, end = bounds
    bucket_start = (start // bucket_size) * bucket_size
    bucket_end = ((end // bucket_size) * bucket_size) + bucket_size - 1
    return bucket_start, bucket_end


def region_entry_key(baseline_image_hash: str, bucket_bounds: tuple[int, int] | None) -> str:
    if not baseline_image_hash or bucket_bounds is None:
        return ""
    start, end = bucket_bounds
    return f"{baseline_image_hash}:{start}-{end}"


DESCRIPTION_REGION_RE = re.compile(r"\b(?:gap|segment)\s+(\d+)-(\d+)\b")
DESCRIPTION_PAIR_RE = re.compile(r"\breference pair\s+(\d+)\b")
DESCRIPTION_SHIFT_RE = re.compile(r"\bfrom\s+(\d+)\s+to\s+(\d+)\b")


def infer_region_bounds_from_summary_item(item: dict[str, Any]) -> tuple[int, int] | None:
    start = item.get("region_start")
    end = item.get("region_end")
    bounds = normalize_region_bounds(start if isinstance(start, int) else None, end if isinstance(end, int) else None)
    if bounds is not None:
        return bounds

    description = str(item.get("mutation_description", "")).strip()
    if not description:
        return None

    if match := DESCRIPTION_REGION_RE.search(description):
        return normalize_region_bounds(int(match.group(1)), int(match.group(2)))
    if match := DESCRIPTION_PAIR_RE.search(description):
        value = int(match.group(1))
        return value, value
    if match := DESCRIPTION_SHIFT_RE.search(description):
        return normalize_region_bounds(int(match.group(1)), int(match.group(2)))
    return None


def warm_candidate_cache_for_current_state(
    cache: dict[str, Any],
    *,
    cache_path: Path,
    summary_path: Path,
    state_hash: str,
    current_best_score: float | None,
) -> None:
    if current_best_score is None or not summary_path.exists():
        return
    try:
        summary = json.loads(summary_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return

    if abs(float(summary.get("final_best_score", -1)) - current_best_score) > SCORE_EPSILON:
        return
    iterations = summary.get("iterations")
    if not isinstance(iterations, list):
        return

    entries = cache.setdefault("entries", {})
    changed = False
    for item in iterations:
        if not isinstance(item, dict):
            continue
        if str(item.get("status", "")) != "discard":
            continue
        description = str(item.get("mutation_description", "")).strip()
        mutation_type = str(item.get("mutation_type", "")).strip()
        if not description or not mutation_type:
            continue
        candidate = Candidate(mutation=mutation_type, description=description, pairs=[])
        key = candidate_state_key(state_hash, candidate)
        if key in entries:
            continue
        entries[key] = {
            "state_hash": state_hash,
            "mutation": mutation_type,
            "description": description,
            "status": "discard",
            "last_score": item.get("score"),
            "last_capture_hash": item.get("capture_hash", ""),
            "attempts": 1,
            "last_run_dir": item.get("run_dir", ""),
            "seeded_from_summary": True,
        }
        changed = True
    if changed:
        save_candidate_cache(cache_path, cache)


def warm_region_cache_for_current_baseline(
    cache: dict[str, Any],
    *,
    cache_path: Path,
    summary_path: Path,
    baseline_image_hash: str,
    current_best_score: float | None,
) -> None:
    if current_best_score is None or not baseline_image_hash or not summary_path.exists():
        return
    try:
        summary = json.loads(summary_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return

    if abs(float(summary.get("final_best_score", -1)) - current_best_score) > SCORE_EPSILON:
        return
    iterations = summary.get("iterations")
    if not isinstance(iterations, list):
        return

    entries = cache.setdefault("entries", {})
    changed = False
    for item in iterations:
        if not isinstance(item, dict):
            continue
        if str(item.get("status", "")) not in {"discard", "crash"}:
            continue
        capture_hash = str(item.get("capture_hash", "")).strip()
        score = item.get("score")
        if capture_hash != baseline_image_hash or not isinstance(score, (int, float)):
            continue
        if score > current_best_score + SCORE_EPSILON:
            continue
        bucket_bounds = bucket_region_bounds(infer_region_bounds_from_summary_item(item))
        key = region_entry_key(baseline_image_hash, bucket_bounds)
        if not key or key in entries:
            continue
        entries[key] = {
            "baseline_image_hash": baseline_image_hash,
            "bucket_start": bucket_bounds[0],
            "bucket_end": bucket_bounds[1],
            "status": str(item.get("status", "")) or "discard",
            "last_score": score,
            "last_capture_hash": capture_hash,
            "attempts": 1,
            "last_run_dir": item.get("run_dir", ""),
            "seeded_from_summary": True,
        }
        changed = True
    if changed:
        save_region_cache(cache_path, cache)


def filter_candidates_for_state(
    candidates: list[Candidate],
    *,
    state_hash: str,
    candidate_cache: dict[str, Any],
    batch_blocklist: set[str],
) -> tuple[list[Candidate], dict[str, int]]:
    entries = candidate_cache.get("entries", {})
    filtered: list[Candidate] = []
    skipped_batch = 0
    skipped_cache = 0
    for candidate in candidates:
        key = candidate_state_key(state_hash, candidate)
        if key in batch_blocklist:
            skipped_batch += 1
            continue
        entry = entries.get(key)
        if isinstance(entry, dict) and str(entry.get("status", "")) in {"discard", "crash"}:
            skipped_cache += 1
            continue
        filtered.append(candidate)
    return filtered, {"batch": skipped_batch, "cache": skipped_cache}


def filter_candidates_for_region(
    candidates: list[Candidate],
    *,
    baseline_image_hash: str,
    region_cache: dict[str, Any],
    batch_region_blocklist: set[str],
) -> tuple[list[Candidate], dict[str, int]]:
    if not baseline_image_hash:
        return list(candidates), {"batch_region": 0, "region_cache": 0}

    entries = region_cache.get("entries", {})
    filtered: list[Candidate] = []
    skipped_batch_region = 0
    skipped_region_cache = 0
    for candidate in candidates:
        bucket_bounds = bucket_region_bounds(candidate_region_bounds(candidate))
        key = region_entry_key(baseline_image_hash, bucket_bounds)
        if key and key in batch_region_blocklist:
            skipped_batch_region += 1
            continue
        entry = entries.get(key) if key else None
        if isinstance(entry, dict) and str(entry.get("status", "")) in {"discard", "crash"}:
            skipped_region_cache += 1
            continue
        filtered.append(candidate)
    return filtered, {"batch_region": skipped_batch_region, "region_cache": skipped_region_cache}


def update_candidate_cache(
    cache: dict[str, Any],
    *,
    cache_path: Path,
    state_hash: str,
    candidate: Candidate,
    status: str,
    score: float | None,
    capture_hash: str,
    run_dir: Path,
) -> None:
    entries = cache.setdefault("entries", {})
    key = candidate_state_key(state_hash, candidate)
    entry = entries.get(key)
    if not isinstance(entry, dict):
        entry = {
            "state_hash": state_hash,
            "mutation": candidate.mutation,
            "description": candidate.description,
            "attempts": 0,
        }
        entries[key] = entry
    entry["status"] = status
    entry["last_score"] = score
    entry["last_capture_hash"] = capture_hash
    entry["last_run_dir"] = str(run_dir)
    entry["attempts"] = int(entry.get("attempts", 0)) + 1
    save_candidate_cache(cache_path, cache)


def update_region_cache(
    cache: dict[str, Any],
    *,
    cache_path: Path,
    baseline_image_hash: str,
    baseline_score: float | None,
    candidate: Candidate,
    status: str,
    score: float | None,
    capture_hash: str,
    run_dir: Path,
) -> None:
    if not baseline_image_hash:
        return
    bucket_bounds = bucket_region_bounds(candidate_region_bounds(candidate))
    key = region_entry_key(baseline_image_hash, bucket_bounds)
    if not key:
        return

    should_record = (
        status in {"discard", "crash"}
        and capture_hash == baseline_image_hash
        and isinstance(score, (int, float))
        and (
            baseline_score is None
            or score <= baseline_score + SCORE_EPSILON
        )
    )
    if not should_record:
        return

    entries = cache.setdefault("entries", {})
    entry = entries.get(key)
    if not isinstance(entry, dict):
        entry = {
            "baseline_image_hash": baseline_image_hash,
            "bucket_start": bucket_bounds[0],
            "bucket_end": bucket_bounds[1],
            "attempts": 0,
        }
        entries[key] = entry
    entry["status"] = status
    entry["last_score"] = score
    entry["last_capture_hash"] = capture_hash
    entry["last_run_dir"] = str(run_dir)
    entry["attempts"] = int(entry.get("attempts", 0)) + 1
    save_region_cache(cache_path, cache)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a local Copper mutation keep/revert loop.")
    parser.add_argument(
        "--iterations",
        type=int,
        default=int(MUTATION_LOOP_SETTINGS["iterations"]),
        help="Number of mutation attempts to run.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=int(MUTATION_LOOP_SETTINGS["seed"]),
        help="Random seed. Use 0 for a time-based seed.",
    )
    parser.add_argument(
        "--benchmark-config",
        default=str(DEFAULT_BENCHMARK_CONFIG),
        help="Path to the source benchmark JSON config.",
    )
    parser.add_argument(
        "--eval-script",
        default=str(DEFAULT_EVAL_SCRIPT),
        help="Path to amiga_eval_benchmark_source.py.",
    )
    parser.add_argument(
        "--loop-dir",
        default=str(DEFAULT_LOOP_DIR),
        help="Directory for mutation-loop logs and archived iterations.",
    )
    parser.add_argument(
        "--results-file",
        default=str(MUTATION_LOOP_SETTINGS["resultsFile"]),
        help="Optional TSV file for loop results. Defaults to <loop-dir>/results.tsv.",
    )
    parser.add_argument(
        "--mutator",
        choices=["heuristic", "openai", "lmstudio"],
        default=os.getenv("AMIGA_MUTATOR", str(MUTATION_LOOP_SETTINGS["mutator"])),
        help="Candidate chooser. 'openai' uses the OpenAI Responses API. 'lmstudio' uses the local LM Studio REST API.",
    )
    parser.add_argument(
        "--mutation",
        choices=[
            "any",
            "insert_reference_pair",
            "insert_reference_segment",
            "fill_gap_segment",
            "shift_pair",
            "shift_window",
            "remove_pair",
        ],
        default=str(MUTATION_LOOP_SETTINGS["mutation"]),
        help="Restrict candidate generation to one mutation type for debugging.",
    )
    parser.add_argument(
        "--candidate-budget",
        type=int,
        default=int(MUTATION_LOOP_SETTINGS["candidateBudget"]),
        help="Maximum number of candidate edits to present to the LLM mutator.",
    )
    parser.add_argument(
        "--plateau-repeat-limit",
        type=int,
        default=int(MUTATION_LOOP_SETTINGS["plateauRepeatLimit"]),
        help="Stop early after this many consecutive identical score+image repeats. Use 0 to disable.",
    )
    parser.add_argument(
        "--image-hash-cache-file",
        default=str(MUTATION_LOOP_SETTINGS["imageHashCacheFile"]),
        help="Optional JSON cache file for benchmark crop hashes. Defaults to <loop-dir>/image_hash_cache.json.",
    )
    parser.add_argument(
        "--openai-model",
        default=os.getenv("OPENAI_MODEL", str(OPENAI_SETTINGS["model"])),
        help="Responses API model for --mutator openai.",
    )
    parser.add_argument(
        "--openai-api-key-env",
        default=str(OPENAI_SETTINGS["apiKeyEnv"]),
        help="Environment variable name holding the OpenAI API key.",
    )
    parser.add_argument(
        "--openai-base-url",
        default=os.getenv("OPENAI_BASE_URL", str(OPENAI_SETTINGS["baseUrl"])),
        help="Responses API endpoint override.",
    )
    parser.add_argument(
        "--lmstudio-base-url",
        default=os.getenv("LMSTUDIO_BASE_URL", str(LMSTUDIO_SETTINGS["baseUrl"] or LMSTUDIO_BASE_URL)),
        help="LM Studio server base URL, such as http://127.0.0.1:1234 .",
    )
    parser.add_argument(
        "--lmstudio-model",
        default=os.getenv("LMSTUDIO_MODEL", str(LMSTUDIO_SETTINGS["model"])),
        help="LM Studio model identifier. If omitted, the runner will try to auto-detect one from the LM Studio server.",
    )
    parser.add_argument(
        "--lmstudio-api-token-env",
        default=str(LMSTUDIO_SETTINGS["apiTokenEnv"]),
        help="Environment variable name holding an optional LM Studio server token.",
    )
    parser.add_argument(
        "--reasoning-effort",
        choices=["minimal", "low", "medium", "high"],
        default=os.getenv("OPENAI_REASONING_EFFORT", str(OPENAI_SETTINGS["reasoningEffort"])),
        help="Reasoning effort for supported OpenAI reasoning models.",
    )
    parser.add_argument(
        "--kick-rom-name",
        default=str(BENCHMARK_SETTINGS["kickRomName"]),
        help="Optional ROM filename default to pass through to the benchmark evaluator.",
    )
    parser.add_argument(
        "--kick-rom-dir",
        default=str(BENCHMARK_SETTINGS["kickRomDir"]),
        help="Optional ROM directory default to pass through to the benchmark evaluator.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def ensure_file_with_header(path: Path, header: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text(header, encoding="utf-8")


def append_results_row(
    path: Path,
    *,
    iteration: int,
    score: float | None,
    best_before: float | None,
    best_after: float | None,
    status: str,
    mutation: str,
    benchmark_ok: bool,
    eval_code: int,
    run_dir: Path,
) -> None:
    ensure_file_with_header(path, RESULTS_HEADER)
    row = "\t".join(
        [
            str(iteration),
            format_score(score),
            format_score(best_before),
            format_score(best_after),
            status,
            mutation,
            "yes" if benchmark_ok else "no",
            str(eval_code),
            str(run_dir),
        ]
    )
    with path.open("a", encoding="utf-8") as handle:
        handle.write(row + "\n")


def load_json_file_or_default(path: Path, fallback: dict[str, Any]) -> dict[str, Any]:
    if not path.exists():
        return json.loads(json.dumps(fallback))
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return json.loads(json.dumps(fallback))


def format_score(value: float | None) -> str:
    if value is None:
        return ""
    return f"{value:.6f}"


def now_tag() -> str:
    return time.strftime("%Y-%m-%dT%H-%M-%S", time.localtime())


def resolve_path(base_dir: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else (base_dir / path)


def load_pairs(path: Path) -> list[tuple[str, str]]:
    lines = [line.rstrip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if len(lines) % 2 != 0:
        raise ValueError(f"expected an even number of non-empty lines in {path}, got {len(lines)}")
    return [(lines[index], lines[index + 1]) for index in range(0, len(lines), 2)]


def write_pairs(path: Path, pairs: list[tuple[str, str]]) -> None:
    text = "\n".join("\n".join(pair) for pair in pairs) + "\n"
    path.write_text(text, encoding="utf-8")


def pair_text(pair: tuple[str, str]) -> str:
    return "\n".join(pair)


def extract_inline_pairs_block(text: str, start_marker: str, end_marker: str) -> tuple[str, str, str]:
    start_index = text.find(start_marker)
    if start_index < 0:
        raise ValueError(f"missing mutation start marker: {start_marker!r}")
    end_index = text.find(end_marker, start_index)
    if end_index < 0:
        raise ValueError(f"missing mutation end marker: {end_marker!r}")

    line_break = text.find("\n", start_index)
    if line_break < 0:
        raise ValueError(f"start marker must be followed by a newline: {start_marker!r}")
    prefix = text[: line_break + 1]
    block = text[line_break + 1 : end_index]
    suffix = text[end_index:]
    return prefix, block, suffix


def load_inline_pairs(path: Path, start_marker: str, end_marker: str) -> tuple[str, list[tuple[str, str]]]:
    text = path.read_text(encoding="utf-8")
    _, block, _ = extract_inline_pairs_block(text, start_marker, end_marker)
    lines = [line.rstrip() for line in block.splitlines() if line.strip()]
    if len(lines) % 2 != 0:
        raise ValueError(f"expected an even number of non-empty lines in inline block of {path}, got {len(lines)}")
    pairs = [(lines[index], lines[index + 1]) for index in range(0, len(lines), 2)]
    return text, pairs


def replace_inline_pairs_block(text: str, start_marker: str, end_marker: str, pairs: list[tuple[str, str]]) -> str:
    prefix, _, suffix = extract_inline_pairs_block(text, start_marker, end_marker)
    block_text = "\n".join(pair_text(pair) for pair in pairs)
    if block_text:
        block_text += "\n"
    return prefix + block_text + suffix


def load_mutation_target(source_root: Path, main_source_path: Path, benchmark_cfg: dict[str, Any]) -> MutationTarget:
    target_cfg = benchmark_cfg.get("mutation_target")
    if isinstance(target_cfg, dict):
        target_type = str(target_cfg.get("type", "pair_file")).strip() or "pair_file"
        target_path = resolve_path(ROOT, str(target_cfg.get("path", main_source_path)))
        if target_type == "inline_asm_block":
            start_marker = str(target_cfg.get("start_marker", "")).strip()
            end_marker = str(target_cfg.get("end_marker", "")).strip()
            if not start_marker or not end_marker:
                raise ValueError("inline_asm_block mutation target requires start_marker and end_marker")
            state_text, current_pairs = load_inline_pairs(target_path, start_marker, end_marker)
            return MutationTarget(
                mode=target_type,
                path=target_path,
                entrypoint_path=main_source_path,
                state_text=state_text,
                current_pairs=current_pairs,
                marker_start=start_marker,
                marker_end=end_marker,
            )
        if target_type != "pair_file":
            raise ValueError(f"unsupported mutation target type: {target_type}")
        state_text = target_path.read_text(encoding="utf-8")
        return MutationTarget(
            mode=target_type,
            path=target_path,
            entrypoint_path=main_source_path,
            state_text=state_text,
            current_pairs=load_pairs(target_path),
        )

    target_path = source_root / "out" / "copper-list.s"
    state_text = target_path.read_text(encoding="utf-8")
    return MutationTarget(
        mode="pair_file",
        path=target_path,
        entrypoint_path=main_source_path,
        state_text=state_text,
        current_pairs=load_pairs(target_path),
    )


def render_mutation_target_text(target: MutationTarget, current_state_text: str, candidate_pairs: list[tuple[str, str]]) -> str:
    if target.mode == "inline_asm_block":
        return replace_inline_pairs_block(current_state_text, target.marker_start, target.marker_end, candidate_pairs)
    return "\n".join(pair_text(pair) for pair in candidate_pairs) + "\n"


def diff_preview(before_text: str, after_text: str, max_lines: int = 18) -> str:
    lines = list(
        difflib.unified_diff(
            before_text.splitlines(),
            after_text.splitlines(),
            fromfile="current",
            tofile="candidate",
            lineterm="",
        )
    )
    if len(lines) > max_lines:
        lines = lines[:max_lines] + ["..."]
    return "\n".join(lines)


def map_current_indices(
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
) -> list[int]:
    indices: list[int] = []
    ref_pos = 0
    for current in current_pairs:
        while ref_pos < len(reference_pairs) and reference_pairs[ref_pos] != current:
            ref_pos += 1
        if ref_pos >= len(reference_pairs):
            raise ValueError(
                "current mutable copper list no longer maps cleanly onto the reference list; "
                "the local mutator only supports reference-derived lists"
            )
        indices.append(ref_pos)
        ref_pos += 1
    return indices


def build_gap_spans(indices: list[int], reference_len: int) -> list[GapSpan]:
    gaps: list[GapSpan] = []
    if not indices:
        if reference_len > 0:
            gaps.append(
                GapSpan(
                    insert_at=0,
                    left_ref=None,
                    right_ref=None,
                    missing_indices=list(range(reference_len)),
                )
            )
        return gaps

    if indices[0] > 0:
        gaps.append(
            GapSpan(
                insert_at=0,
                left_ref=None,
                right_ref=indices[0],
                missing_indices=list(range(0, indices[0])),
            )
        )

    for current_pos in range(len(indices) - 1):
        left = indices[current_pos]
        right = indices[current_pos + 1]
        if right - left <= 1:
            continue
        gaps.append(
            GapSpan(
                insert_at=current_pos + 1,
                left_ref=left,
                right_ref=right,
                missing_indices=list(range(left + 1, right)),
            )
        )

    if indices[-1] < reference_len - 1:
        gaps.append(
            GapSpan(
                insert_at=len(indices),
                left_ref=indices[-1],
                right_ref=None,
                missing_indices=list(range(indices[-1] + 1, reference_len)),
            )
        )
    return gaps


def insertion_candidates(
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    gaps: list[GapSpan],
) -> list[Candidate]:
    candidates: list[Candidate] = []
    if not current_pairs:
        return candidates

    for gap in gaps:
        missing = gap.missing_indices
        if not missing:
            continue
        ref_index = missing[len(missing) // 2]
        new_pairs = current_pairs[: gap.insert_at] + [reference_pairs[ref_index]] + current_pairs[gap.insert_at :]
        if gap.left_ref is None:
            description = f"prepend reference pair {ref_index}"
        elif gap.right_ref is None:
            description = f"append reference pair {ref_index}"
        else:
            description = f"insert reference pair {ref_index} between {gap.left_ref} and {gap.right_ref}"
        candidates.append(
            Candidate(
                mutation="insert_reference_pair",
                description=description,
                pairs=new_pairs,
                focus=len(missing),
                region_start=ref_index,
                region_end=ref_index,
            )
        )

    return candidates


def segment_insertion_candidates(
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    gaps: list[GapSpan],
) -> list[Candidate]:
    candidates: list[Candidate] = []
    if not gaps:
        return candidates

    ranked_gaps = sorted(gaps, key=lambda gap: len(gap.missing_indices), reverse=True)
    targeted_full_gap_keys = {
        (
            gap.insert_at,
            gap.missing_indices[0],
            gap.missing_indices[-1],
        )
        for gap in ranked_gaps[:8]
        if len(gap.missing_indices) >= 4
    }

    for gap in gaps:
        missing = gap.missing_indices
        gap_size = len(missing)
        if gap_size < 2:
            continue

        gap_label = (
            f"{missing[0]}-{missing[-1]}"
            if gap_size > 1
            else str(missing[0])
        )
        boundary_label = (
            f"between {gap.left_ref} and {gap.right_ref}"
            if gap.left_ref is not None and gap.right_ref is not None
            else "at the list boundary"
        )

        if gap_size <= 3:
            segment = [reference_pairs[index] for index in missing]
            new_pairs = current_pairs[: gap.insert_at] + segment + current_pairs[gap.insert_at :]
            candidates.append(
                Candidate(
                    mutation="fill_gap_segment",
                    description=f"fill small gap {gap_label} {boundary_label}",
                    pairs=new_pairs,
                    focus=gap_size * 10,
                    region_start=missing[0],
                    region_end=missing[-1],
                )
            )
            continue

        segment_lengths = [2 if gap_size < 6 else 3]
        if gap_size >= 8:
            segment_lengths.append(4)

        for segment_len in segment_lengths:
            if segment_len >= gap_size:
                continue
            start = max(0, (gap_size - segment_len) // 2)
            segment_indices = missing[start : start + segment_len]
            segment = [reference_pairs[index] for index in segment_indices]
            new_pairs = current_pairs[: gap.insert_at] + segment + current_pairs[gap.insert_at :]
            candidates.append(
                Candidate(
                    mutation="insert_reference_segment",
                    description=(
                        f"insert reference segment {segment_indices[0]}-{segment_indices[-1]} {boundary_label}"
                    ),
                    pairs=new_pairs,
                    focus=gap_size * 10 + segment_len,
                    region_start=segment_indices[0],
                    region_end=segment_indices[-1],
                )
            )

        gap_key = (gap.insert_at, missing[0], missing[-1])
        if gap_key in targeted_full_gap_keys:
            segment = [reference_pairs[index] for index in missing]
            new_pairs = current_pairs[: gap.insert_at] + segment + current_pairs[gap.insert_at :]
            candidates.append(
                Candidate(
                    mutation="fill_gap_segment",
                    description=f"fill targeted gap {gap_label} {boundary_label}",
                    pairs=new_pairs,
                    focus=gap_size * 20,
                    region_start=missing[0],
                    region_end=missing[-1],
                )
            )
    return candidates


def removal_candidates(
    current_pairs: list[tuple[str, str]],
    indices: list[int],
) -> list[Candidate]:
    if len(current_pairs) <= 4:
        return []
    candidates: list[Candidate] = []
    removable_positions = list(range(1, len(current_pairs) - 1))
    step = max(1, len(removable_positions) // 6)
    for position in removable_positions[::step]:
        new_pairs = current_pairs[:position] + current_pairs[position + 1 :]
        candidates.append(
            Candidate(
                mutation="remove_pair",
                description=f"remove pair at position {position}",
                pairs=new_pairs,
                focus=0,
                region_start=indices[position],
                region_end=indices[position],
            )
        )
    return candidates


def shift_candidates(
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    indices: list[int],
) -> list[Candidate]:
    if len(current_pairs) <= 2:
        return []

    candidates: list[Candidate] = []
    movable_positions = list(range(1, len(current_pairs) - 1))
    step = max(1, len(movable_positions) // 6)
    for position in movable_positions[::step]:
        current_index = indices[position]
        prev_index = indices[position - 1]
        next_index = indices[position + 1]
        options = [value for value in (current_index - 1, current_index + 1) if prev_index < value < next_index]
        for ref_index in options:
            new_pairs = list(current_pairs)
            new_pairs[position] = reference_pairs[ref_index]
            candidates.append(
                Candidate(
                    mutation="shift_pair",
                    description=f"shift pair at position {position} from {current_index} to {ref_index}",
                    pairs=new_pairs,
                    focus=1,
                    region_start=min(current_index, ref_index),
                    region_end=max(current_index, ref_index),
                )
            )
    return candidates


def shift_window_candidates(
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    indices: list[int],
) -> list[Candidate]:
    if len(current_pairs) <= 3:
        return []

    candidates: list[Candidate] = []
    max_window = min(3, len(current_pairs) - 2)
    for window_len in range(2, max_window + 1):
        start_positions = list(range(1, len(current_pairs) - window_len))
        step = max(1, len(start_positions) // 6)
        for start in start_positions[::step]:
            window = indices[start : start + window_len]
            prev_index = indices[start - 1]
            next_index = indices[start + window_len]
            for delta in (-1, 1):
                shifted = [value + delta for value in window]
                if shifted[0] <= prev_index or shifted[-1] >= next_index:
                    continue
                if any(shifted[idx] >= shifted[idx + 1] for idx in range(len(shifted) - 1)):
                    continue
                new_pairs = list(current_pairs)
                for offset, ref_index in enumerate(shifted):
                    new_pairs[start + offset] = reference_pairs[ref_index]
                direction = "left" if delta < 0 else "right"
                candidates.append(
                    Candidate(
                        mutation="shift_window",
                        description=(
                            f"shift window {start}-{start + window_len - 1} {direction} by {abs(delta)}"
                        ),
                        pairs=new_pairs,
                        focus=window_len,
                        region_start=min(window + shifted),
                        region_end=max(window + shifted),
                    )
                )
    return candidates


def propose_candidate(
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    rng: random.Random,
    mutation_filter: str,
) -> list[Candidate]:
    indices = map_current_indices(current_pairs, reference_pairs)
    gaps = build_gap_spans(indices, len(reference_pairs))
    candidates: list[Candidate] = []
    candidates.extend(insertion_candidates(current_pairs, reference_pairs, gaps))
    candidates.extend(segment_insertion_candidates(current_pairs, reference_pairs, gaps))
    candidates.extend(shift_candidates(current_pairs, reference_pairs, indices))
    candidates.extend(shift_window_candidates(current_pairs, reference_pairs, indices))
    candidates.extend(removal_candidates(current_pairs, indices))
    if mutation_filter != "any":
        candidates = [candidate for candidate in candidates if candidate.mutation == mutation_filter]
    deduped: list[Candidate] = []
    seen: set[tuple[tuple[str, str], ...]] = set()
    for candidate in candidates:
        key = tuple(candidate.pairs)
        if key in seen:
            continue
        seen.add(key)
        deduped.append(candidate)
    candidates = deduped
    if not candidates:
        raise RuntimeError("no mutation candidates available for the current copper list")
    return candidates


def choose_candidate_heuristic(candidates: list[Candidate], rng: random.Random) -> CandidateSelection:
    weighted: list[tuple[int, int, Candidate]] = []
    for index, candidate in enumerate(candidates):
        if candidate.mutation == "fill_gap_segment":
            weight = 10
        elif candidate.mutation == "insert_reference_segment":
            weight = 8
        elif candidate.mutation == "insert_reference_pair":
            weight = 5
        elif candidate.mutation == "shift_window":
            weight = 3
        elif candidate.mutation == "shift_pair":
            weight = 2
        else:
            weight = 1
        weight += min(candidate.focus, 12) // 3
        weighted.append((weight, index, candidate))
    total = sum(weight for weight, _, _ in weighted)
    pick = rng.randrange(total)
    running = 0
    for weight, index, candidate in weighted:
        running += weight
        if pick < running:
            return CandidateSelection(
                candidate=candidate,
                candidate_index=index,
                source="heuristic",
                rationale="weighted random choice",
            )
    _, index, candidate = weighted[-1]
    return CandidateSelection(
        candidate=candidate,
        candidate_index=index,
        source="heuristic",
        rationale="weighted random fallback",
    )


def read_recent_results(results_file: Path, limit: int = 6) -> list[dict[str, str]]:
    if not results_file.exists():
        return []
    lines = [line.rstrip("\n") for line in results_file.read_text(encoding="utf-8").splitlines() if line.strip()]
    if len(lines) <= 1:
        return []
    rows: list[dict[str, str]] = []
    for line in lines[1:]:
        parts = line.split("\t")
        if len(parts) != 9:
            continue
        rows.append(
            {
                "iteration": parts[0],
                "score": parts[1],
                "best_before": parts[2],
                "best_after": parts[3],
                "status": parts[4],
                "mutation": parts[5],
                "benchmark_ok": parts[6],
                "eval_code": parts[7],
                "run_dir": parts[8],
            }
        )
    return rows[-limit:]


def select_candidate_pool(candidates: list[Candidate], budget: int) -> list[tuple[int, Candidate]]:
    indexed = list(enumerate(candidates))
    if len(indexed) <= budget:
        return indexed

    priority_order = [
        "fill_gap_segment",
        "insert_reference_segment",
        "insert_reference_pair",
        "shift_window",
        "shift_pair",
        "remove_pair",
    ]
    groups: dict[str, list[tuple[int, Candidate]]] = {}
    for item in indexed:
        groups.setdefault(item[1].mutation, []).append(item)

    for items in groups.values():
        items.sort(key=lambda item: (-item[1].focus, item[0]))

    selected: list[tuple[int, Candidate]] = []
    while len(selected) < budget:
        added = False
        for mutation in priority_order:
            items = groups.get(mutation, [])
            if not items:
                continue
            selected.append(items.pop(0))
            added = True
            if len(selected) >= budget:
                break
        if not added:
            break
    return selected


def extract_output_text(response_json: dict[str, Any]) -> str:
    output_text = response_json.get("output_text")
    if isinstance(output_text, str) and output_text.strip():
        return output_text

    for item in response_json.get("output", []):
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            text = content.get("text")
            if isinstance(text, str) and text.strip():
                return text
    return ""


def parse_candidate_choice_text(output_text: str) -> dict[str, Any]:
    text = output_text.strip()
    if text.startswith("```"):
        lines = text.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        text = "\n".join(lines).strip()
        if text.lower().startswith("json"):
            text = text[4:].lstrip()

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        start = text.find("{")
        end = text.rfind("}")
        if start != -1 and end != -1 and end > start:
            return json.loads(text[start : end + 1])
        raise


def bearer_headers(token: str) -> dict[str, str]:
    if not token:
        return {}
    return {"Authorization": f"Bearer {token}"}


def http_json_request(
    *,
    method: str,
    url: str,
    payload: dict[str, Any] | None = None,
    bearer_token: str = "",
    timeout: int = 60,
) -> dict[str, Any]:
    headers = {
        "Content-Type": "application/json",
        **bearer_headers(bearer_token),
    }
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    request = urlrequest.Request(url, data=data, headers=headers, method=method.upper())
    try:
        with urlrequest.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))
    except urlerror.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from {url}: {body}") from exc
    except urlerror.URLError as exc:
        raise RuntimeError(f"request failed for {url}: {exc.reason}") from exc


def normalize_lmstudio_root(base_url: str) -> str:
    text = base_url.rstrip("/")
    for suffix in ("/v1/responses", "/v1", "/api/v1"):
        if text.endswith(suffix):
            return text[: -len(suffix)]
    return text


def lmstudio_responses_url(base_url: str) -> str:
    root = normalize_lmstudio_root(base_url)
    return f"{root}/v1/responses"


def lmstudio_chat_completions_url(base_url: str) -> str:
    root = normalize_lmstudio_root(base_url)
    return f"{root}/v1/chat/completions"


def lmstudio_models_urls(base_url: str) -> list[str]:
    root = normalize_lmstudio_root(base_url)
    return [f"{root}/api/v1/models", f"{root}/v1/models"]


def parse_lmstudio_model_list(payload: dict[str, Any]) -> list[dict[str, Any]]:
    if isinstance(payload.get("models"), list):
        return [item for item in payload["models"] if isinstance(item, dict)]
    if isinstance(payload.get("data"), list):
        return [item for item in payload["data"] if isinstance(item, dict)]
    return []


def extract_model_id(item: dict[str, Any]) -> str:
    for key in ("id", "key", "model", "name"):
        value = item.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return ""


def model_loaded_score(item: dict[str, Any]) -> int:
    loaded_instances = item.get("loaded_instances")
    if isinstance(loaded_instances, list):
        return len(loaded_instances)
    if item.get("state") == "loaded":
        return 1
    return 0


def resolve_lmstudio_model(args: argparse.Namespace) -> str:
    explicit = args.lmstudio_model.strip()
    if explicit:
        return explicit

    token = os.getenv(args.lmstudio_api_token_env, "").strip()
    last_error = ""
    for url in lmstudio_models_urls(args.lmstudio_base_url):
        try:
            payload = http_json_request(method="GET", url=url, bearer_token=token, timeout=10)
        except RuntimeError as exc:
            last_error = str(exc)
            continue

        items = parse_lmstudio_model_list(payload)
        if not items:
            continue

        def sort_key(item: dict[str, Any]) -> tuple[int, int, str]:
            item_type = str(item.get("type", "")).lower()
            llm_bonus = 1 if item_type in {"llm", "chat", ""} else 0
            return (-model_loaded_score(item), -llm_bonus, extract_model_id(item))

        for item in sorted(items, key=sort_key):
            model_id = extract_model_id(item)
            if model_id:
                return model_id

    raise RuntimeError(
        "could not resolve an LM Studio model automatically. "
        "Start the LM Studio local server and load a model, or pass --lmstudio-model. "
        f"Last error: {last_error or 'no model endpoints returned usable data'}"
    )


def choose_candidate_via_responses_api(
    *,
    provider_name: str,
    endpoint_url: str,
    model: str,
    bearer_token: str,
    reasoning_effort: str,
    candidate_budget: int,
    candidates: list[Candidate],
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    current_score: float | None,
    results_file: Path,
    current_text: str,
) -> CandidateSelection:
    candidate_pool = select_candidate_pool(candidates, candidate_budget)
    recent_results = read_recent_results(results_file)
    candidate_items = []
    for pool_index, (original_index, candidate) in enumerate(candidate_pool):
        candidate_text = "\n".join(pair_text(pair) for pair in candidate.pairs) + "\n"
        candidate_items.append(
            {
                "pool_index": pool_index,
                "original_index": original_index,
                "mutation": candidate.mutation,
                "description": candidate.description,
                "pair_count": len(candidate.pairs),
                "diff_preview": diff_preview(current_text, candidate_text),
            }
        )

    developer_prompt = (
        "You are choosing one safe mutation candidate for an Amiga Copper bars benchmark. "
        "The goal is to maximize image similarity to a golden reference while keeping raster order valid. "
        "Prefer edits that densify the current degraded copper list toward the reference. "
        "Avoid destructive removals unless the evidence strongly suggests the current list is too dense. "
        "Explain only the structural reason for the choice. "
        "Do not predict exact scores, deltas, or other unmeasured results. "
        "Do not claim a candidate already improved unless that exact result is present in recent_results. "
        "Return only JSON matching the schema."
    )
    user_payload = {
        "task": "Pick the single candidate most likely to improve the benchmark score.",
        "current_state": {
            "current_score": current_score,
            "current_pair_count": len(current_pairs),
            "reference_pair_count": len(reference_pairs),
            "gap_to_reference": len(reference_pairs) - len(current_pairs),
        },
        "recent_results": recent_results,
        "candidates": candidate_items,
    }
    request_payload: dict[str, Any] = {
        "model": model,
        "input": [
            {"role": "developer", "content": developer_prompt},
            {"role": "user", "content": json.dumps(user_payload, indent=2)},
        ],
        "text": {
            "format": {
                "type": "json_schema",
                "name": "mutation_choice",
                "description": "Choose one candidate edit for the Copper mutation loop.",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "candidate_index": {
                            "type": "integer",
                            "minimum": 0,
                            "maximum": max(0, len(candidate_pool) - 1),
                        },
                        "reason": {
                            "type": "string",
                            "description": (
                                "Short structural explanation only. "
                                "Do not include numeric score forecasts, deltas, or invented measurements."
                            ),
                        },
                    },
                    "required": ["candidate_index", "reason"],
                    "additionalProperties": False,
                },
            }
        },
        "max_output_tokens": 300,
    }
    if reasoning_effort:
        request_payload["reasoning"] = {"effort": reasoning_effort}

    response_json = http_json_request(
        method="POST",
        url=endpoint_url,
        payload=request_payload,
        bearer_token=bearer_token,
        timeout=60,
    )
    output_text = extract_output_text(response_json)
    if not output_text:
        raise RuntimeError(f"{provider_name} mutator response did not include output_text")
    parsed = parse_candidate_choice_text(output_text)
    candidate_index = int(parsed["candidate_index"])
    if candidate_index < 0 or candidate_index >= len(candidate_pool):
        raise RuntimeError(
            f"{provider_name} mutator chose candidate_index={candidate_index}, outside 0..{len(candidate_pool) - 1}"
        )

    original_index, candidate = candidate_pool[candidate_index]
    return CandidateSelection(
        candidate=candidate,
        candidate_index=original_index,
        source=provider_name,
        rationale=sanitize_rationale(str(parsed.get("reason", "")).strip(), candidate),
        request_payload=request_payload,
        response_payload=response_json,
    )


def choose_candidate_via_chat_completions(
    *,
    provider_name: str,
    endpoint_url: str,
    model: str,
    bearer_token: str,
    candidate_budget: int,
    candidates: list[Candidate],
    current_pairs: list[tuple[str, str]],
    reference_pairs: list[tuple[str, str]],
    current_score: float | None,
    results_file: Path,
    current_text: str,
) -> CandidateSelection:
    candidate_pool = select_candidate_pool(candidates, candidate_budget)
    recent_results = read_recent_results(results_file)
    candidate_items = []
    for pool_index, (original_index, candidate) in enumerate(candidate_pool):
        candidate_text = "\n".join(pair_text(pair) for pair in candidate.pairs) + "\n"
        candidate_items.append(
            {
                "pool_index": pool_index,
                "original_index": original_index,
                "mutation": candidate.mutation,
                "description": candidate.description,
                "pair_count": len(candidate.pairs),
                "diff_preview": diff_preview(current_text, candidate_text),
            }
        )

    system_prompt = (
        "You are choosing one safe mutation candidate for an Amiga Copper bars benchmark. "
        "The goal is to maximize image similarity to a golden reference while keeping raster order valid. "
        "Prefer edits that densify the current degraded copper list toward the reference. "
        "Avoid destructive removals unless the evidence strongly suggests the current list is too dense. "
        "Explain only the structural reason for the choice. "
        "Do not predict exact scores, deltas, or other unmeasured results. "
        "Do not claim a candidate already improved unless that exact result is present in recent_results."
    )
    user_payload = {
        "task": "Pick the single candidate most likely to improve the benchmark score.",
        "current_state": {
            "current_score": current_score,
            "current_pair_count": len(current_pairs),
            "reference_pair_count": len(reference_pairs),
            "gap_to_reference": len(reference_pairs) - len(current_pairs),
        },
        "recent_results": recent_results,
        "candidates": candidate_items,
    }
    request_payload: dict[str, Any] = {
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": json.dumps(user_payload, indent=2)},
        ],
        "response_format": {
            "type": "json_schema",
            "json_schema": {
                "name": "mutation_choice",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "candidate_index": {
                            "type": "integer",
                            "minimum": 0,
                            "maximum": max(0, len(candidate_pool) - 1),
                        },
                        "reason": {
                            "type": "string",
                            "description": (
                                "Short structural explanation only. "
                                "Do not include numeric score forecasts, deltas, or invented measurements."
                            ),
                        },
                    },
                    "required": ["candidate_index", "reason"],
                    "additionalProperties": False,
                },
            },
        },
        "temperature": 0,
        "stream": False,
    }

    response_json = http_json_request(
        method="POST",
        url=endpoint_url,
        payload=request_payload,
        bearer_token=bearer_token,
        timeout=60,
    )
    try:
        content = response_json["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError(f"{provider_name} chat/completions response did not contain choices[0].message.content") from exc

    if isinstance(content, list):
        text = ""
        for part in content:
            if isinstance(part, dict):
                candidate_text = part.get("text")
                if isinstance(candidate_text, str):
                    text += candidate_text
        content_text = text.strip()
    else:
        content_text = str(content).strip()

    parsed = parse_candidate_choice_text(content_text)
    candidate_index = int(parsed["candidate_index"])
    if candidate_index < 0 or candidate_index >= len(candidate_pool):
        raise RuntimeError(
            f"{provider_name} mutator chose candidate_index={candidate_index}, outside 0..{len(candidate_pool) - 1}"
        )

    original_index, candidate = candidate_pool[candidate_index]
    return CandidateSelection(
        candidate=candidate,
        candidate_index=original_index,
        source=provider_name,
        rationale=sanitize_rationale(str(parsed.get("reason", "")).strip(), candidate),
        request_payload=request_payload,
        response_payload=response_json,
    )


def validate_mutator_configuration(args: argparse.Namespace) -> None:
    if args.mutator == "openai":
        api_key = os.getenv(args.openai_api_key_env, "").strip()
        if not api_key:
            raise RuntimeError(
                f"--mutator openai requires {args.openai_api_key_env} to be set in the environment"
            )
    return


def run_evaluator(
    eval_script: Path,
    benchmark_config: Path,
    report_path: Path,
    cwd: Path,
    *,
    kick_rom_name: str = "",
    kick_rom_dir: str = "",
) -> EvalOutcome:
    started = time.time()
    report_path.parent.mkdir(parents=True, exist_ok=True)
    if report_path.exists():
        report_path.unlink()
    command = ["python3", str(eval_script), "--benchmark-config", str(benchmark_config), "--report", str(report_path)]
    if kick_rom_name:
        command.extend(["--kick-rom-name", kick_rom_name])
    if kick_rom_dir:
        command.extend(["--kick-rom-dir", kick_rom_dir])
    proc = subprocess.run(
        command,
        cwd=str(cwd),
        capture_output=True,
        text=True,
    )
    report = load_json(report_path) if report_path.exists() else {}
    score = report.get("score")
    score_value = float(score) if isinstance(score, (int, float)) else None
    return EvalOutcome(
        score=score_value,
        benchmark_ok=bool(report.get("verify_ok")),
        returncode=proc.returncode,
        report_path=report_path,
        report=report,
        stdout=proc.stdout,
        stderr=proc.stderr,
        seconds=time.time() - started,
    )


def copy_if_exists(src: Path, dst: Path) -> None:
    if src.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)


def archive_iteration(
    *,
    archive_root: Path,
    iteration: int,
    selection: CandidateSelection,
    outcome: EvalOutcome,
    best_before: float | None,
    best_after: float | None,
    status: str,
    mutable_entrypoint: Path,
    mutable_copper_list: Path,
    previous_text: str,
    candidate_text: str,
    capture_hash: str,
    capture_path: Path | None,
    cache_repeat: bool,
    cache_best_score: float | None,
) -> Path:
    run_dir = archive_root / f"{now_tag()}-iter-{iteration:03d}"
    run_dir.mkdir(parents=True, exist_ok=True)

    metadata = {
        "iteration": iteration,
        "mutation": selection.candidate.mutation,
        "description": selection.candidate.description,
        "candidate_index": selection.candidate_index,
        "mutator": selection.source,
        "rationale": selection.rationale,
        "status": status,
        "score": outcome.score,
        "benchmark_ok": outcome.benchmark_ok,
        "eval_returncode": outcome.returncode,
        "best_before": best_before,
        "best_after": best_after,
        "seconds": outcome.seconds,
        "capture_hash": capture_hash,
        "capture_path": str(capture_path) if capture_path else "",
        "capture_hash_repeat": cache_repeat,
        "capture_hash_best_score": cache_best_score,
        "mutable_entrypoint": str(mutable_entrypoint),
        "mutable_copper_list": str(mutable_copper_list),
        "region_start": selection.candidate.region_start,
        "region_end": selection.candidate.region_end,
    }
    (run_dir / "metadata.json").write_text(json.dumps(metadata, indent=2), encoding="utf-8")
    (run_dir / "eval.stdout.log").write_text(outcome.stdout, encoding="utf-8")
    (run_dir / "eval.stderr.log").write_text(outcome.stderr, encoding="utf-8")
    if selection.request_payload is not None:
        (run_dir / "llm_request.json").write_text(json.dumps(selection.request_payload, indent=2), encoding="utf-8")
    if selection.response_payload is not None:
        (run_dir / "llm_response.json").write_text(json.dumps(selection.response_payload, indent=2), encoding="utf-8")
    copy_if_exists(outcome.report_path, run_dir / "report.json")
    copy_if_exists(mutable_entrypoint, run_dir / mutable_entrypoint.name)
    copy_if_exists(mutable_copper_list, run_dir / mutable_copper_list.name)

    diff_lines = list(
        difflib.unified_diff(
            previous_text.splitlines(),
            candidate_text.splitlines(),
            fromfile="previous/copper-list.s",
            tofile="candidate/copper-list.s",
            lineterm="",
        )
    )
    (run_dir / "candidate.diff").write_text("\n".join(diff_lines) + ("\n" if diff_lines else ""), encoding="utf-8")

    for filename in ARCHIVE_FILES:
        if filename == "report.json":
            continue
        copy_if_exists(DEFAULT_BUILD_DIR / filename, run_dir / filename)

    return run_dir


def print_iteration_summary(
    *,
    iteration: int,
    selection: CandidateSelection,
    status: str,
    outcome: EvalOutcome,
    best_before: float | None,
    best_after: float | None,
    capture_hash: str,
    cache_repeat: bool,
    identical_result_streak: int,
) -> None:
    print(
        f"iteration {iteration}: {status} | "
        f"score={format_score(outcome.score) or 'n/a'} | "
        f"best_before={format_score(best_before) or 'n/a'} | "
        f"best_after={format_score(best_after) or 'n/a'} | "
        f"{selection.candidate.description} | "
        f"mutator={selection.source}"
    )
    if selection.rationale:
        print(f"  rationale: {selection.rationale}")
    if capture_hash:
        line = f"  capture hash: {capture_hash[:16]}"
        if cache_repeat:
            line += " (seen before)"
        if identical_result_streak > 1:
            line += f" | repeat streak={identical_result_streak}"
        print(line)


def build_loop_summary(
    *,
    baseline: EvalOutcome,
    best_score: float | None,
    iterations: list[dict[str, Any]],
    image_hash_cache_path: Path,
    candidate_cache_path: Path,
    region_cache_path: Path,
    plateau_repeat_limit: int,
    stopped_early: bool,
    stop_reason: str,
) -> dict[str, Any]:
    status_counts = Counter(str(item.get("status", "")) for item in iterations)
    mutation_counts = Counter(str(item.get("mutation_type", "")) for item in iterations)
    mutator_counts = Counter(str(item.get("mutator", "")) for item in iterations)
    keep_deltas = [
        float(item["score_delta"])
        for item in iterations
        if item.get("status") == "keep" and isinstance(item.get("score_delta"), (int, float))
    ]
    summary = {
        "attempted": len(iterations),
        "keeps": status_counts.get("keep", 0),
        "discards": status_counts.get("discard", 0),
        "crashes": status_counts.get("crash", 0),
        "keep_rate": (status_counts.get("keep", 0) / len(iterations)) if iterations else 0.0,
        "baseline_score": baseline.score,
        "baseline_benchmark_ok": baseline.benchmark_ok,
        "final_best_score": best_score,
        "final_benchmark_ok": iterations[-1]["benchmark_ok"] if iterations else baseline.benchmark_ok,
        "total_score_delta": (
            (best_score - baseline.score)
            if isinstance(best_score, (int, float)) and isinstance(baseline.score, (int, float))
            else None
        ),
        "best_single_step_delta": max(keep_deltas) if keep_deltas else None,
        "average_keep_delta": (sum(keep_deltas) / len(keep_deltas)) if keep_deltas else None,
        "mutation_counts": {key: value for key, value in sorted(mutation_counts.items()) if key},
        "mutator_counts": {key: value for key, value in sorted(mutator_counts.items()) if key},
        "image_hash_cache_file": str(image_hash_cache_path),
        "candidate_cache_file": str(candidate_cache_path),
        "region_cache_file": str(region_cache_path),
        "plateau_repeat_limit": plateau_repeat_limit,
        "stopped_early": stopped_early,
        "stop_reason": stop_reason,
        "iterations": iterations,
    }
    return summary


def print_loop_summary(summary: dict[str, Any], summary_path: Path) -> None:
    print("---")
    print(f"iterations attempted: {summary['attempted']}")
    print(f"keeps:               {summary['keeps']}")
    print(f"discards:            {summary['discards']}")
    print(f"crashes:             {summary['crashes']}")
    print(f"keep rate:           {summary['keep_rate']:.1%}")
    print(f"baseline score:      {format_score(summary['baseline_score']) or 'n/a'}")
    print(f"final best score:    {format_score(summary['final_best_score']) or 'n/a'}")
    print(f"total delta:         {format_score(summary['total_score_delta']) or 'n/a'}")
    print(f"best keep delta:     {format_score(summary['best_single_step_delta']) or 'n/a'}")
    print(f"avg keep delta:      {format_score(summary['average_keep_delta']) or 'n/a'}")
    if summary["mutation_counts"]:
        mutation_counts = ", ".join(f"{key}={value}" for key, value in summary["mutation_counts"].items())
        print(f"mutation counts:     {mutation_counts}")
    if summary["mutator_counts"]:
        mutator_counts = ", ".join(f"{key}={value}" for key, value in summary["mutator_counts"].items())
        print(f"mutator counts:      {mutator_counts}")
    print(f"plateau limit:       {summary['plateau_repeat_limit']}")
    if summary["stopped_early"]:
        print(f"stop reason:         {summary['stop_reason']}")
    print(f"image hash cache:    {summary['image_hash_cache_file']}")
    print(f"candidate cache:     {summary['candidate_cache_file']}")
    print(f"region cache:        {summary['region_cache_file']}")
    print(f"summary file:        {summary_path}")


def main() -> int:
    args = parse_args()
    benchmark_config = Path(args.benchmark_config).resolve()
    eval_script = Path(args.eval_script).resolve()
    loop_dir = Path(args.loop_dir).resolve()
    results_file = Path(args.results_file).resolve() if args.results_file else loop_dir / "results.tsv"
    summary_path = loop_dir / "latest_summary.json"
    image_hash_cache_path = (
        Path(args.image_hash_cache_file).resolve()
        if args.image_hash_cache_file
        else loop_dir / "image_hash_cache.json"
    )
    candidate_cache_path = loop_dir / "candidate_outcome_cache.json"
    region_cache_path = loop_dir / "region_outcome_cache.json"
    plateau_repeat_limit = max(0, int(args.plateau_repeat_limit))
    validate_mutator_configuration(args)
    lmstudio_model = resolve_lmstudio_model(args) if args.mutator == "lmstudio" else ""

    benchmark_cfg = load_json(benchmark_config)
    source_root = ROOT / benchmark_cfg["source_root"]
    include_root = ROOT / benchmark_cfg.get("include_root", benchmark_cfg["source_root"])
    mutable_entrypoint = ROOT / benchmark_cfg["main_source"]
    reference_copper_list = include_root / "out" / "copper-list.s"

    loop_dir.mkdir(parents=True, exist_ok=True)
    archive_root = loop_dir / "runs"
    archive_root.mkdir(parents=True, exist_ok=True)
    ensure_file_with_header(results_file, RESULTS_HEADER)
    latest_report_path = loop_dir / "latest_report.json"
    image_hash_cache = load_image_hash_cache(image_hash_cache_path)
    candidate_cache = load_candidate_cache(candidate_cache_path)
    region_cache = load_region_cache(region_cache_path)

    rng = random.Random(args.seed if args.seed != 0 else time.time_ns())

    reference_pairs = load_pairs(reference_copper_list)
    mutation_target = load_mutation_target(source_root, mutable_entrypoint, benchmark_cfg)
    mutable_copper_list = mutation_target.path
    current_text = mutation_target.state_text
    current_pairs = mutation_target.current_pairs

    baseline = run_evaluator(
        eval_script,
        benchmark_config,
        latest_report_path,
        ROOT,
        kick_rom_name=args.kick_rom_name.strip(),
        kick_rom_dir=args.kick_rom_dir.strip(),
    )
    best_score = baseline.score
    print("---")
    print(f"baseline score:     {format_score(best_score) or 'n/a'}")
    print(f"baseline benchmark: {'yes' if baseline.benchmark_ok else 'no'}")
    print(f"mutable file:       {mutable_copper_list}")
    print(f"results file:       {results_file}")
    print(f"mutator:            {args.mutator}")
    if lmstudio_model:
        print(f"lmstudio model:     {lmstudio_model}")
    print(f"plateau limit:      {plateau_repeat_limit or 'disabled'}")
    print(f"hash cache:         {image_hash_cache_path}")
    print(f"candidate cache:    {candidate_cache_path}")
    print(f"region cache:       {region_cache_path}")

    baseline_capture_path = benchmark_capture_path(baseline.report)
    baseline_capture_hash = file_sha256(baseline_capture_path)
    if baseline_capture_hash:
        update_image_hash_cache(
            image_hash_cache,
            image_hash=baseline_capture_hash,
            score=baseline.score,
            iteration=0,
            run_dir=loop_dir / "baseline",
        )
        save_image_hash_cache(image_hash_cache_path, image_hash_cache)

    best_image_hash = baseline_capture_hash
    current_source_state_hash = current_state_hash(current_text)
    warm_candidate_cache_for_current_state(
        candidate_cache,
        cache_path=candidate_cache_path,
        summary_path=summary_path,
        state_hash=current_source_state_hash,
        current_best_score=best_score,
    )
    warm_region_cache_for_current_baseline(
        region_cache,
        cache_path=region_cache_path,
        summary_path=summary_path,
        baseline_image_hash=best_image_hash,
        current_best_score=best_score,
    )
    batch_blocklist: set[str] = set()
    batch_region_blocklist: set[str] = set()
    identical_result_streak = 0
    last_signature: tuple[str, float] | None = None
    stopped_early = False
    stop_reason = ""

    iteration_summaries: list[dict[str, Any]] = []
    for iteration in range(1, args.iterations + 1):
        previous_text = current_text
        previous_pairs = current_pairs
        best_before = best_score
        current_source_state_hash = current_state_hash(previous_text)
        previous_pairs_text = "\n".join(pair_text(pair) for pair in previous_pairs) + "\n"
        all_candidates = propose_candidate(previous_pairs, reference_pairs, rng, args.mutation)
        candidates, skipped = filter_candidates_for_state(
            all_candidates,
            state_hash=current_source_state_hash,
            candidate_cache=candidate_cache,
            batch_blocklist=batch_blocklist,
        )
        candidates, region_skipped = filter_candidates_for_region(
            candidates,
            baseline_image_hash=best_image_hash,
            region_cache=region_cache,
            batch_region_blocklist=batch_region_blocklist,
        )
        if skipped["batch"] or skipped["cache"] or region_skipped["batch_region"] or region_skipped["region_cache"]:
            print(
                "candidate filter:   "
                f"eligible={len(candidates)} "
                f"skipped_batch={skipped['batch']} "
                f"skipped_cache={skipped['cache']} "
                f"skipped_region_batch={region_skipped['batch_region']} "
                f"skipped_region_cache={region_skipped['region_cache']}"
            )
        if not candidates:
            stopped_early = True
            stop_reason = "no untried mutation candidates remain for the current source state"
            print(f"candidate filter:   {stop_reason}")
            break
        if args.mutator == "openai":
            selection = choose_candidate_via_responses_api(
                provider_name="openai",
                endpoint_url=args.openai_base_url,
                model=args.openai_model,
                bearer_token=os.getenv(args.openai_api_key_env, "").strip(),
                reasoning_effort=args.reasoning_effort,
                candidate_budget=args.candidate_budget,
                candidates=candidates,
                current_pairs=previous_pairs,
                reference_pairs=reference_pairs,
                current_score=best_before,
                results_file=results_file,
                current_text=previous_pairs_text,
            )
        elif args.mutator == "lmstudio":
            selection = choose_candidate_via_chat_completions(
                provider_name="lmstudio",
                endpoint_url=lmstudio_chat_completions_url(args.lmstudio_base_url),
                model=lmstudio_model,
                bearer_token=os.getenv(args.lmstudio_api_token_env, "").strip(),
                candidate_budget=args.candidate_budget,
                candidates=candidates,
                current_pairs=previous_pairs,
                reference_pairs=reference_pairs,
                current_score=best_before,
                results_file=results_file,
                current_text=previous_pairs_text,
            )
        else:
            selection = choose_candidate_heuristic(candidates, rng)

        candidate = selection.candidate
        candidate_text = render_mutation_target_text(mutation_target, previous_text, candidate.pairs)
        mutable_copper_list.write_text(candidate_text, encoding="utf-8")

        outcome = run_evaluator(
            eval_script,
            benchmark_config,
            latest_report_path,
            ROOT,
            kick_rom_name=args.kick_rom_name.strip(),
            kick_rom_dir=args.kick_rom_dir.strip(),
        )
        status = "crash"
        best_after = best_before
        capture_path = benchmark_capture_path(outcome.report)
        capture_hash = file_sha256(capture_path)
        cache_entry = image_hash_cache.get("hashes", {}).get(capture_hash) if capture_hash else None
        cache_repeat = isinstance(cache_entry, dict)
        cache_best_score = cache_entry.get("best_score") if isinstance(cache_entry, dict) and isinstance(cache_entry.get("best_score"), (int, float)) else None

        if outcome.score is not None:
            improved = best_before is None or outcome.score > best_before + SCORE_EPSILON
            repeated_low_value = (
                cache_repeat
                and cache_best_score is not None
                and outcome.score <= cache_best_score + SCORE_EPSILON
            )
            if improved and not repeated_low_value:
                status = "keep"
                best_after = outcome.score
                best_score = outcome.score
                current_text = candidate_text
                current_pairs = candidate.pairs
                if capture_hash:
                    best_image_hash = capture_hash
            else:
                status = "discard"
                mutable_copper_list.write_text(previous_text, encoding="utf-8")
                current_text = previous_text
                current_pairs = previous_pairs
        else:
            mutable_copper_list.write_text(previous_text, encoding="utf-8")
            current_text = previous_text
            current_pairs = previous_pairs

        signature: tuple[str, float] | None = None
        if capture_hash and outcome.score is not None:
            signature = (capture_hash, round(outcome.score, 12))
        if signature and signature == last_signature:
            identical_result_streak += 1
        elif signature:
            identical_result_streak = 1
        else:
            identical_result_streak = 0
        last_signature = signature

        run_dir = archive_iteration(
            archive_root=archive_root,
            iteration=iteration,
            selection=selection,
            outcome=outcome,
            best_before=best_before,
            best_after=best_after,
            status=status,
            mutable_entrypoint=mutable_entrypoint,
            mutable_copper_list=mutable_copper_list,
            previous_text=previous_text,
            candidate_text=candidate_text,
            capture_hash=capture_hash,
            capture_path=capture_path,
            cache_repeat=cache_repeat,
            cache_best_score=cache_best_score,
        )
        if capture_hash:
            update_image_hash_cache(
                image_hash_cache,
                image_hash=capture_hash,
                score=outcome.score,
                iteration=iteration,
                run_dir=run_dir,
            )
            save_image_hash_cache(image_hash_cache_path, image_hash_cache)
        update_candidate_cache(
            candidate_cache,
            cache_path=candidate_cache_path,
            state_hash=current_source_state_hash,
            candidate=candidate,
            status=status,
            score=outcome.score,
            capture_hash=capture_hash,
            run_dir=run_dir,
        )
        update_region_cache(
            region_cache,
            cache_path=region_cache_path,
            baseline_image_hash=best_image_hash,
            baseline_score=best_before,
            candidate=candidate,
            status=status,
            score=outcome.score,
            capture_hash=capture_hash,
            run_dir=run_dir,
        )
        if status != "keep":
            batch_blocklist.add(candidate_state_key(current_source_state_hash, candidate))
            region_key = region_entry_key(best_image_hash, bucket_region_bounds(candidate_region_bounds(candidate)))
            if region_key and capture_hash == best_image_hash:
                batch_region_blocklist.add(region_key)
        else:
            batch_region_blocklist.clear()
        append_results_row(
            results_file,
            iteration=iteration,
            score=outcome.score,
            best_before=best_before,
            best_after=best_after,
            status=status,
            mutation=f"{selection.source}:{candidate.description}",
            benchmark_ok=outcome.benchmark_ok,
            eval_code=outcome.returncode,
            run_dir=run_dir,
        )
        score_delta = None
        if isinstance(outcome.score, (int, float)) and isinstance(best_before, (int, float)):
            score_delta = outcome.score - best_before
        iteration_summaries.append(
            {
                "iteration": iteration,
                "status": status,
                "mutator": selection.source,
                "mutation_type": candidate.mutation,
                "mutation_description": candidate.description,
                "benchmark_ok": outcome.benchmark_ok,
                "score": outcome.score,
                "score_delta": score_delta,
                "capture_hash": capture_hash,
                "capture_hash_repeat": cache_repeat,
                "identical_result_streak": identical_result_streak,
                "skipped_batch_candidates": skipped["batch"],
                "skipped_cached_candidates": skipped["cache"],
                "skipped_batch_regions": region_skipped["batch_region"],
                "skipped_cached_regions": region_skipped["region_cache"],
                "best_before": best_before,
                "best_after": best_after,
                "region_start": candidate.region_start,
                "region_end": candidate.region_end,
                "run_dir": str(run_dir),
            }
        )
        print_iteration_summary(
            iteration=iteration,
            selection=selection,
            status=status,
            outcome=outcome,
            best_before=best_before,
            best_after=best_after,
            capture_hash=capture_hash,
            cache_repeat=cache_repeat,
            identical_result_streak=identical_result_streak,
        )
        plateau_triggered = (
            plateau_repeat_limit > 0
            and status != "keep"
            and signature is not None
            and best_image_hash
            and capture_hash == best_image_hash
            and identical_result_streak >= plateau_repeat_limit
        )
        if plateau_triggered:
            stopped_early = True
            stop_reason = (
                f"plateau detected after {identical_result_streak} consecutive identical score+image outcomes "
                f"(score={format_score(outcome.score) or 'n/a'}, hash={capture_hash[:16]})"
            )
            print(f"plateau detected:   {stop_reason}")
            break

    summary = build_loop_summary(
        baseline=baseline,
        best_score=best_score,
        iterations=iteration_summaries,
        image_hash_cache_path=image_hash_cache_path,
        candidate_cache_path=candidate_cache_path,
        region_cache_path=region_cache_path,
        plateau_repeat_limit=plateau_repeat_limit,
        stopped_early=stopped_early,
        stop_reason=stop_reason,
    )
    summary_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print_loop_summary(summary, summary_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
