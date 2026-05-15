#!/usr/bin/env python3
"""Run a keep/revert mutation loop for the sin/cos scroller benchmark."""

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
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib import error as urlerror
from urllib import request as urlrequest

from project_settings import load_project_settings


ROOT = Path(__file__).resolve().parent
PROJECT_SETTINGS = load_project_settings()
OPENAI_SETTINGS = PROJECT_SETTINGS["llm"]["openai"]
LMSTUDIO_SETTINGS = PROJECT_SETTINGS["llm"]["lmstudio"]

DEFAULT_SOURCE = ROOT / "amiga_workspace" / "benchmarks" / "sincos_scroller" / "mutation" / "current.s"
DEFAULT_REFERENCE = ROOT / "amiga_workspace" / "benchmarks" / "sincos_scroller" / "mutation" / "reference.s"
DEFAULT_BENCHMARK_CONFIG = ROOT / "amiga_workspace" / "benchmarks" / "sincos_scroller" / "mutation_suite.json"
DEFAULT_EVAL_SCRIPT = ROOT / "amiga_eval_benchmark_suite.py"
DEFAULT_LOOP_DIR = ROOT / "build" / "amiga" / "sincos_mutation_loop"
RESULTS_HEADER = "iteration\tscore\tbest_before\tbest_after\taction\tmutation\tbenchmark_ok\teval_code\trun_dir\n"
LMSTUDIO_BASE_URL = "http://127.0.0.1:1234"
SCORE_EPSILON = 1e-12
BLOCK_RE = re.compile(
    r"(?ms)^[ \t]*; MUTATION BLOCK (?P<name>[A-Za-z0-9_]+) START[ \t]*\n(?P<body>.*?)^[ \t]*; MUTATION BLOCK (?P=name) END[ \t]*$"
)


@dataclass
class Candidate:
    mutation: str
    description: str
    blocks: tuple[str, ...]
    text: str
    focus: int


@dataclass
class Selection:
    candidate: Candidate
    index: int
    source: str
    rationale: str
    request_payload: dict[str, Any] | None = None
    response_payload: dict[str, Any] | None = None


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
    capture_hash: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a keep/revert loop for the sin/cos scroller benchmark.")
    parser.add_argument("--iterations", type=int, default=10, help="Number of mutation attempts to run.")
    parser.add_argument("--seed", type=int, default=0, help="Random seed. Use 0 for a time-based seed.")
    parser.add_argument("--source", default=str(DEFAULT_SOURCE), help="Mutable sin/cos source file.")
    parser.add_argument("--reference-source", default=str(DEFAULT_REFERENCE), help="Passing reference source file.")
    parser.add_argument(
        "--benchmark-config",
        default=str(DEFAULT_BENCHMARK_CONFIG),
        help="Path to the sin/cos mutation suite config.",
    )
    parser.add_argument(
        "--eval-script",
        default=str(DEFAULT_EVAL_SCRIPT),
        help="Path to amiga_eval_benchmark_suite.py.",
    )
    parser.add_argument(
        "--loop-dir",
        default=str(DEFAULT_LOOP_DIR),
        help="Directory for loop results and archived iterations.",
    )
    parser.add_argument(
        "--results-file",
        default="results.tsv",
        help="Results TSV path, relative to --loop-dir unless absolute.",
    )
    parser.add_argument(
        "--mutator",
        choices=["heuristic", "lmstudio", "openai"],
        default=os.getenv("AMIGA_MUTATOR", "heuristic"),
        help="Candidate chooser. Default is local heuristic.",
    )
    parser.add_argument("--candidate-budget", type=int, default=8, help="Maximum candidates presented to an LLM.")
    parser.add_argument("--plateau-repeat-limit", type=int, default=4, help="Stop after this many identical score+image repeats. Use 0 to disable.")
    parser.add_argument(
        "--lmstudio-base-url",
        default=os.getenv("LMSTUDIO_BASE_URL", str(LMSTUDIO_SETTINGS["baseUrl"] or LMSTUDIO_BASE_URL)),
        help="LM Studio server base URL.",
    )
    parser.add_argument(
        "--lmstudio-model",
        default=os.getenv("LMSTUDIO_MODEL", str(LMSTUDIO_SETTINGS["model"])),
        help="LM Studio model id. Auto-detected if omitted.",
    )
    parser.add_argument(
        "--lmstudio-api-token-env",
        default=str(LMSTUDIO_SETTINGS["apiTokenEnv"]),
        help="Environment variable holding an optional LM Studio token.",
    )
    parser.add_argument(
        "--openai-model",
        default=os.getenv("OPENAI_MODEL", str(OPENAI_SETTINGS["model"])),
        help="OpenAI model identifier for --mutator openai.",
    )
    parser.add_argument(
        "--openai-api-key-env",
        default=str(OPENAI_SETTINGS["apiKeyEnv"]),
        help="Environment variable holding the OpenAI API key.",
    )
    parser.add_argument(
        "--openai-base-url",
        default=os.getenv("OPENAI_BASE_URL", str(OPENAI_SETTINGS["baseUrl"])),
        help="OpenAI Responses API endpoint override.",
    )
    parser.add_argument(
        "--reasoning-effort",
        choices=["minimal", "low", "medium", "high"],
        default=os.getenv("OPENAI_REASONING_EFFORT", str(OPENAI_SETTINGS["reasoningEffort"])),
        help="Reasoning effort for supported OpenAI models.",
    )
    return parser.parse_args()


def load_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


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
    action: str,
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
            action,
            mutation,
            "yes" if benchmark_ok else "no",
            str(eval_code),
            str(run_dir),
        ]
    )
    with path.open("a", encoding="utf-8") as handle:
        handle.write(row + "\n")


def format_score(value: float | None) -> str:
    if value is None:
        return ""
    return f"{value:.6f}"


def now_tag() -> str:
    return time.strftime("%Y-%m-%dT%H-%M-%S", time.localtime())


def load_blocks(text: str) -> dict[str, str]:
    blocks: dict[str, str] = {}
    for match in BLOCK_RE.finditer(text):
        blocks[match.group("name")] = match.group("body")
    if not blocks:
        raise RuntimeError("no mutation blocks found in source")
    return blocks


def replace_block(text: str, block_name: str, replacement_body: str) -> str:
    pattern = re.compile(
        rf"(?ms)(^[ \t]*; MUTATION BLOCK {re.escape(block_name)} START[ \t]*\n)(.*?)(^[ \t]*; MUTATION BLOCK {re.escape(block_name)} END[ \t]*$)"
    )
    match = pattern.search(text)
    if not match:
        raise RuntimeError(f"missing mutation block: {block_name}")
    return text[: match.start(2)] + replacement_body + text[match.end(2) :]


def apply_blocks(text: str, replacements: dict[str, str]) -> str:
    updated = text
    for name, body in replacements.items():
        updated = replace_block(updated, name, body)
    return updated


def block_diff_size(current_body: str, reference_body: str) -> int:
    current_lines = [line.rstrip() for line in current_body.splitlines()]
    reference_lines = [line.rstrip() for line in reference_body.splitlines()]
    diff = list(difflib.unified_diff(current_lines, reference_lines, lineterm=""))
    return max(1, len(diff))


def diff_preview(before_text: str, after_text: str, max_lines: int = 20) -> str:
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


def parse_dc_b_values(body: str) -> list[int]:
    values: list[int] = []
    for raw_line in body.splitlines():
        line = raw_line.split(";", 1)[0].strip()
        if not line:
            continue
        if "dc.b" not in line:
            continue
        _, data = line.split("dc.b", 1)
        for part in data.split(","):
            token = part.strip()
            if not token:
                continue
            values.append(int(token, 0))
    return values


def format_dc_b_block(label: str, values: list[int], *, per_line: int = 8) -> str:
    lines = [f"{label}:"]
    for start in range(0, len(values), per_line):
        chunk = values[start : start + per_line]
        rendered = ",".join(str(value) for value in chunk)
        lines.append(f"\tdc.b {rendered}")
    return "\n".join(lines) + "\n"


def line_chunk_candidates(
    *,
    block_name: str,
    current_body: str,
    reference_body: str,
    label: str,
) -> list[tuple[str, str, int]]:
    current_values = parse_dc_b_values(current_body)
    reference_values = parse_dc_b_values(reference_body)
    if len(current_values) != len(reference_values) or not current_values:
        return []

    candidates: list[tuple[str, str, int]] = []
    chunk_size = 8
    for start in range(0, len(current_values), chunk_size):
        end = min(len(current_values), start + chunk_size)
        if current_values[start:end] == reference_values[start:end]:
            continue
        updated = list(current_values)
        updated[start:end] = reference_values[start:end]
        segment_label = f"{start}-{end - 1}"
        body = format_dc_b_block(label, updated, per_line=chunk_size)
        focus = sum(1 for index in range(start, end) if current_values[index] != reference_values[index])
        candidates.append((f"restore {block_name} segment {segment_label}", body, focus))
    return candidates


def propose_candidates(current_text: str, reference_text: str) -> list[Candidate]:
    current_blocks = load_blocks(current_text)
    reference_blocks = load_blocks(reference_text)
    differing = [name for name in reference_blocks if current_blocks.get(name) != reference_blocks[name]]
    if not differing:
        return []

    candidates: list[Candidate] = []
    seen: set[str] = set()

    def add_candidate(mutation: str, description: str, replacements: dict[str, str], block_names: tuple[str, ...], focus: int | None = None) -> None:
        candidate_text = apply_blocks(current_text, replacements)
        digest = hashlib.sha256(candidate_text.encode("utf-8")).hexdigest()
        if digest in seen:
            return
        seen.add(digest)
        if focus is None:
            focus = sum(block_diff_size(current_blocks[name], reference_blocks[name]) for name in block_names)
        candidates.append(Candidate(mutation=mutation, description=description, blocks=block_names, text=candidate_text, focus=focus))

    for name in ("phase_x", "phase_y"):
        if name in differing:
            add_candidate("restore_block", f"restore {name}", {name: reference_blocks[name]}, (name,))

    table_defs = {
        "scroll_table": "scroll_table",
        "sine_table": "sine_table",
    }
    for name, label in table_defs.items():
        if name not in differing:
            continue
        for description, body, focus in line_chunk_candidates(
            block_name=name,
            current_body=current_blocks[name],
            reference_body=reference_blocks[name],
            label=label,
        ):
            add_candidate("restore_table_segment", description, {name: body}, (name,), focus)
        add_candidate(
            "restore_block",
            f"restore {name}",
            {name: reference_blocks[name]},
            (name,),
        )

    if "phase_x" in differing and "scroll_table" in differing:
        add_candidate(
            "restore_horizontal_motion",
            "restore horizontal motion",
            {
                "phase_x": reference_blocks["phase_x"],
                "scroll_table": reference_blocks["scroll_table"],
            },
            ("phase_x", "scroll_table"),
        )
    if "phase_y" in differing and "sine_table" in differing:
        add_candidate(
            "restore_vertical_motion",
            "restore vertical motion",
            {
                "phase_y": reference_blocks["phase_y"],
                "sine_table": reference_blocks["sine_table"],
            },
            ("phase_y", "sine_table"),
        )

    candidates.sort(key=lambda item: (item.focus, item.description))
    return candidates


def select_candidate_pool(candidates: list[Candidate], budget: int) -> list[tuple[int, Candidate]]:
    indexed = list(enumerate(candidates))
    if len(indexed) <= budget:
        return indexed

    priority_order = [
        "restore_table_segment",
        "restore_block",
        "restore_horizontal_motion",
        "restore_vertical_motion",
    ]
    groups: dict[str, list[tuple[int, Candidate]]] = {}
    for item in indexed:
        groups.setdefault(item[1].mutation, []).append(item)
    for items in groups.values():
        items.sort(key=lambda entry: (entry[1].focus, entry[0]))

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


def candidate_priority(candidate: Candidate, escalation_stage: int) -> tuple[int, int]:
    if escalation_stage <= 0:
        order = {
            "restore_table_segment": 0,
            "restore_block": 1,
            "restore_horizontal_motion": 2,
            "restore_vertical_motion": 3,
        }
    elif escalation_stage == 1:
        order = {
            "restore_block": 0,
            "restore_table_segment": 1,
            "restore_horizontal_motion": 2,
            "restore_vertical_motion": 3,
        }
    else:
        order = {
            "restore_horizontal_motion": 0,
            "restore_vertical_motion": 1,
            "restore_block": 2,
            "restore_table_segment": 3,
        }
    return order.get(candidate.mutation, 99), candidate.focus


def choose_candidate_heuristic(candidates: list[Candidate], rng: random.Random, escalation_stage: int = 0) -> Selection:
    ordered = sorted(
        enumerate(candidates),
        key=lambda item: (
            *candidate_priority(item[1], escalation_stage),
            item[0],
        ),
    )
    top_band = ordered[: min(4, len(ordered))]
    index, candidate = rng.choice(top_band)
    rationale = (
        "smallest safe motion correction"
        if escalation_stage <= 0
        else "escalated to broader motion repair after repeated no-op candidates"
    )
    return Selection(candidate=candidate, index=index, source="heuristic", rationale=rationale)


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
    return json.loads(text)


def extract_output_text(response_json: dict[str, Any]) -> str:
    if isinstance(response_json.get("output_text"), str) and response_json["output_text"].strip():
        return response_json["output_text"]
    for item in response_json.get("output", []):
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            text = content.get("text")
            if isinstance(text, str) and text.strip():
                return text
    for choice in response_json.get("choices", []):
        message = choice.get("message", {})
        content = message.get("content")
        if isinstance(content, str) and content.strip():
            return content
    return ""


def bearer_headers(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"} if token else {}


def http_json_request(*, method: str, url: str, payload: dict[str, Any] | None = None, bearer_token: str = "", timeout: int = 60) -> dict[str, Any]:
    headers = {"Content-Type": "application/json", **bearer_headers(bearer_token)}
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    req = urlrequest.Request(url, data=data, headers=headers, method=method.upper())
    try:
        with urlrequest.urlopen(req, timeout=timeout) as response:
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


def lmstudio_chat_completions_url(base_url: str) -> str:
    return f"{normalize_lmstudio_root(base_url)}/v1/chat/completions"


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
    if args.lmstudio_model.strip():
        return args.lmstudio_model.strip()
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

        def sort_key(item: dict[str, Any]) -> tuple[int, str]:
            return (-model_loaded_score(item), extract_model_id(item))

        for item in sorted(items, key=sort_key):
            model_id = extract_model_id(item)
            if model_id:
                return model_id
    raise RuntimeError(f"could not resolve an LM Studio model automatically. Last error: {last_error or 'no models found'}")


def choose_candidate_via_lmstudio(
    *,
    args: argparse.Namespace,
    candidates: list[Candidate],
    current_text: str,
    current_score: float | None,
    results_file: Path,
) -> Selection:
    model = resolve_lmstudio_model(args)
    pool = select_candidate_pool(candidates, args.candidate_budget)
    request_payload = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": (
                    "Choose one safe mutation candidate for an Amiga sin/cos scroller benchmark. "
                    "Goal: maximize the multi-frame benchmark score. Prefer restoring structurally correct motion blocks. "
                    "Do not predict numeric scores."
                ),
            },
            {
                "role": "user",
                "content": json.dumps(
                    {
                        "task": "Pick the single candidate most likely to improve the benchmark.",
                        "current_score": current_score,
                        "results_file": str(results_file),
                        "candidates": [
                            {
                                "pool_index": pool_index,
                                "original_index": original_index,
                                "mutation": candidate.mutation,
                                "description": candidate.description,
                                "blocks": list(candidate.blocks),
                                "diff_preview": diff_preview(current_text, candidate.text),
                            }
                            for pool_index, (original_index, candidate) in enumerate(pool)
                        ],
                    },
                    indent=2,
                ),
            },
        ],
        "response_format": {
            "type": "json_schema",
            "json_schema": {
                "name": "mutation_choice",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "candidate_index": {"type": "integer", "minimum": 0, "maximum": max(0, len(pool) - 1)},
                        "reason": {"type": "string"},
                    },
                    "required": ["candidate_index", "reason"],
                    "additionalProperties": False,
                },
            },
        },
    }
    token = os.getenv(args.lmstudio_api_token_env, "").strip()
    response_json = http_json_request(
        method="POST",
        url=lmstudio_chat_completions_url(args.lmstudio_base_url),
        payload=request_payload,
        bearer_token=token,
        timeout=60,
    )
    parsed = parse_candidate_choice_text(extract_output_text(response_json))
    pool_index = int(parsed["candidate_index"])
    original_index, candidate = pool[pool_index]
    return Selection(
        candidate=candidate,
        index=original_index,
        source="lmstudio",
        rationale=str(parsed.get("reason", "")).strip() or "LM Studio selection",
        request_payload=request_payload,
        response_payload=response_json,
    )


def choose_candidate_via_openai(
    *,
    args: argparse.Namespace,
    candidates: list[Candidate],
    current_text: str,
    current_score: float | None,
    results_file: Path,
) -> Selection:
    token = os.getenv(args.openai_api_key_env, "").strip()
    if not token:
        raise RuntimeError(f"--mutator openai requires {args.openai_api_key_env} to be set")
    pool = select_candidate_pool(candidates, args.candidate_budget)
    request_payload = {
        "model": args.openai_model,
        "input": [
            {
                "role": "developer",
                "content": (
                    "Choose one safe mutation candidate for an Amiga sin/cos scroller benchmark. "
                    "Prefer edits that restore structurally correct horizontal drift and per-character sine motion. "
                    "Do not predict numeric scores."
                ),
            },
            {
                "role": "user",
                "content": json.dumps(
                    {
                        "task": "Pick the single candidate most likely to improve the benchmark.",
                        "current_score": current_score,
                        "results_file": str(results_file),
                        "candidates": [
                            {
                                "pool_index": pool_index,
                                "original_index": original_index,
                                "mutation": candidate.mutation,
                                "description": candidate.description,
                                "blocks": list(candidate.blocks),
                                "diff_preview": diff_preview(current_text, candidate.text),
                            }
                            for pool_index, (original_index, candidate) in enumerate(pool)
                        ],
                    },
                    indent=2,
                ),
            },
        ],
        "text": {
            "format": {
                "type": "json_schema",
                "name": "mutation_choice",
                "strict": True,
                "schema": {
                    "type": "object",
                    "properties": {
                        "candidate_index": {"type": "integer", "minimum": 0, "maximum": max(0, len(pool) - 1)},
                        "reason": {"type": "string"},
                    },
                    "required": ["candidate_index", "reason"],
                    "additionalProperties": False,
                },
            }
        },
        "max_output_tokens": 300,
        "reasoning": {"effort": args.reasoning_effort},
    }
    response_json = http_json_request(
        method="POST",
        url=args.openai_base_url,
        payload=request_payload,
        bearer_token=token,
        timeout=60,
    )
    parsed = parse_candidate_choice_text(extract_output_text(response_json))
    pool_index = int(parsed["candidate_index"])
    original_index, candidate = pool[pool_index]
    return Selection(
        candidate=candidate,
        index=original_index,
        source="openai",
        rationale=str(parsed.get("reason", "")).strip() or "OpenAI selection",
        request_payload=request_payload,
        response_payload=response_json,
    )


def choose_candidate(
    *,
    args: argparse.Namespace,
    candidates: list[Candidate],
    current_text: str,
    current_score: float | None,
    results_file: Path,
    rng: random.Random,
    escalation_stage: int = 0,
) -> Selection:
    if args.mutator == "heuristic":
        return choose_candidate_heuristic(candidates, rng, escalation_stage)
    if args.mutator == "lmstudio":
        return choose_candidate_via_lmstudio(
            args=args,
            candidates=candidates,
            current_text=current_text,
            current_score=current_score,
            results_file=results_file,
        )
    return choose_candidate_via_openai(
        args=args,
        candidates=candidates,
        current_text=current_text,
        current_score=current_score,
        results_file=results_file,
    )


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def benchmark_capture_paths(report: dict[str, Any]) -> list[Path]:
    paths: list[Path] = []
    suite = report.get("components")
    if isinstance(suite, list):
        for component in suite:
            if not isinstance(component, dict):
                continue
            nested = component.get("report")
            if not isinstance(nested, dict):
                nested_path = component.get("report_path")
                if isinstance(nested_path, str) and Path(nested_path).exists():
                    nested = load_json(Path(nested_path))
            if not isinstance(nested, dict):
                continue
            benchmark = nested.get("benchmark")
            if isinstance(benchmark, dict):
                for key in ("capture_crop_image", "capture_image"):
                    value = benchmark.get(key)
                    if isinstance(value, str) and Path(value).exists():
                        paths.append(Path(value))
    return paths


def suite_capture_hash(report: dict[str, Any]) -> str:
    digest = hashlib.sha256()
    found = False
    for path in benchmark_capture_paths(report):
        found = True
        digest.update(path.read_bytes())
    return digest.hexdigest() if found else ""


def run_eval(eval_script: Path, benchmark_config: Path, report_path: Path) -> EvalOutcome:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    command = ["python3", str(eval_script), "--benchmark-config", str(benchmark_config), "--report", str(report_path)]
    started = time.time()
    proc = subprocess.run(command, cwd=str(ROOT), capture_output=True, text=True)
    seconds = time.time() - started
    report = load_json(report_path) if report_path.exists() else {}
    return EvalOutcome(
        score=float(report.get("score", 0.0) or 0.0) if report else None,
        benchmark_ok=bool(report.get("verify_ok")),
        returncode=proc.returncode,
        report_path=report_path,
        report=report,
        stdout=proc.stdout,
        stderr=proc.stderr,
        seconds=seconds,
        capture_hash=suite_capture_hash(report),
    )


def archive_iteration(
    *,
    run_dir: Path,
    source_path: Path,
    current_text: str,
    outcome: EvalOutcome,
    selection: Selection,
) -> None:
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "current.s").write_text(current_text, encoding="utf-8")
    report_target = run_dir / "report.json"
    if outcome.report_path.resolve() != report_target.resolve():
        shutil.copy2(outcome.report_path, report_target)
    (run_dir / "eval.stdout.log").write_text(outcome.stdout, encoding="utf-8")
    (run_dir / "eval.stderr.log").write_text(outcome.stderr, encoding="utf-8")
    metadata = {
        "selection_source": selection.source,
        "selection_index": selection.index,
        "selection_rationale": selection.rationale,
        "mutation": selection.candidate.mutation,
        "description": selection.candidate.description,
        "blocks": list(selection.candidate.blocks),
        "score": outcome.score,
        "benchmark_ok": outcome.benchmark_ok,
        "capture_hash": outcome.capture_hash,
        "source_path": str(source_path),
    }
    (run_dir / "metadata.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    if selection.request_payload is not None:
        (run_dir / "llm_request.json").write_text(json.dumps(selection.request_payload, indent=2) + "\n", encoding="utf-8")
    if selection.response_payload is not None:
        (run_dir / "llm_response.json").write_text(json.dumps(selection.response_payload, indent=2) + "\n", encoding="utf-8")
    for component in outcome.report.get("components", []):
        if not isinstance(component, dict):
            continue
        report_path = component.get("report_path")
        if isinstance(report_path, str) and Path(report_path).exists():
            target = run_dir / Path(report_path).name
            shutil.copy2(report_path, target)
            nested = load_json(Path(report_path))
            benchmark = nested.get("benchmark")
            if isinstance(benchmark, dict):
                for key in ("capture_image", "capture_crop_image", "capture_diff_image"):
                    value = benchmark.get(key)
                    if isinstance(value, str) and Path(value).exists():
                        shutil.copy2(value, run_dir / Path(value).name)


def summarize(outcomes: list[dict[str, Any]], *, baseline_score: float | None, best_score: float | None, stop_reason: str, summary_path: Path) -> None:
    keeps = [item for item in outcomes if item["action"] == "keep"]
    discards = [item for item in outcomes if item["action"] == "discard"]
    crashes = [item for item in outcomes if item["action"] == "crash"]
    summary = {
        "baseline_score": baseline_score,
        "final_best_score": best_score,
        "iterations_attempted": len(outcomes),
        "keeps": len(keeps),
        "discards": len(discards),
        "crashes": len(crashes),
        "keep_rate": (len(keeps) / len(outcomes)) if outcomes else 0.0,
        "stop_reason": stop_reason,
        "iterations": outcomes,
    }
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    summary_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    rng = random.Random(args.seed or int(time.time()))
    source_path = Path(args.source).resolve()
    reference_path = Path(args.reference_source).resolve()
    benchmark_config = Path(args.benchmark_config).resolve()
    eval_script = Path(args.eval_script).resolve()
    loop_dir = Path(args.loop_dir).resolve()
    results_file = (loop_dir / args.results_file) if not Path(args.results_file).is_absolute() else Path(args.results_file)
    summary_path = loop_dir / "latest_summary.json"

    baseline_outcome = run_eval(eval_script, benchmark_config, loop_dir / "baseline_report.json")
    best_score = baseline_outcome.score
    best_text = load_text(source_path)
    best_hash = baseline_outcome.capture_hash
    repeat_streak = 1 if best_hash else 0
    outcomes: list[dict[str, Any]] = []
    batch_blocklist: set[str] = set()
    stop_reason = "iteration limit reached"

    print("---")
    print(f"baseline score:     {format_score(baseline_outcome.score)}")
    print(f"baseline benchmark: {'yes' if baseline_outcome.benchmark_ok else 'no'}")
    print(f"mutable file:       {source_path}")
    print(f"results file:       {results_file}")
    print(f"mutator:            {args.mutator}")
    if args.mutator == "lmstudio":
        print(f"lmstudio model:     {resolve_lmstudio_model(args)}")
    print(f"plateau limit:      {args.plateau_repeat_limit}")

    for iteration in range(1, args.iterations + 1):
        current_text = load_text(source_path)
        candidates = propose_candidates(current_text, load_text(reference_path))
        if not candidates:
            stop_reason = "no mutation candidates remain"
            break
        candidates = [candidate for candidate in candidates if candidate.description not in batch_blocklist]
        if not candidates:
            stop_reason = "all remaining mutation candidates are already known dead ends for this batch"
            break

        selection = choose_candidate(
            args=args,
            candidates=candidates,
            current_text=current_text,
            current_score=best_score,
            results_file=results_file,
            rng=rng,
            escalation_stage=max(0, repeat_streak - 1),
        )
        source_path.write_text(selection.candidate.text, encoding="utf-8")

        run_dir = loop_dir / "runs" / f"{now_tag()}-iter-{iteration:03d}"
        report_path = run_dir / "report.json"
        outcome = run_eval(eval_script, benchmark_config, report_path)
        action = "discard"
        if outcome.returncode != 0 and outcome.score is None:
            action = "crash"

        best_before = best_score
        if isinstance(outcome.score, (int, float)) and (best_score is None or outcome.score > best_score + SCORE_EPSILON):
            action = "keep"
            best_score = float(outcome.score)
            best_text = selection.candidate.text
            best_hash = outcome.capture_hash
            repeat_streak = 1 if best_hash else 0
        else:
            source_path.write_text(best_text, encoding="utf-8")
            batch_blocklist.add(selection.candidate.description)
            if outcome.capture_hash and outcome.capture_hash == best_hash and best_hash:
                repeat_streak += 1
            else:
                repeat_streak = 1 if outcome.capture_hash else 0

        archive_iteration(
            run_dir=run_dir,
            source_path=source_path,
            current_text=selection.candidate.text if action == "keep" else best_text,
            outcome=outcome,
            selection=selection,
        )
        append_results_row(
            results_file,
            iteration=iteration,
            score=outcome.score,
            best_before=best_before,
            best_after=best_score,
            action=action,
            mutation=selection.candidate.description,
            benchmark_ok=outcome.benchmark_ok,
            eval_code=outcome.returncode,
            run_dir=run_dir,
        )
        item = {
            "iteration": iteration,
            "action": action,
            "score": outcome.score,
            "best_before": best_before,
            "best_after": best_score,
            "mutation_type": selection.candidate.mutation,
            "mutation_description": selection.candidate.description,
            "blocks": list(selection.candidate.blocks),
            "benchmark_ok": outcome.benchmark_ok,
            "capture_hash": outcome.capture_hash,
            "run_dir": str(run_dir),
        }
        outcomes.append(item)

        print(
            f"iteration {iteration}: {action} | score={format_score(outcome.score)} | "
            f"best_before={format_score(best_before)} | best_after={format_score(best_score)} | "
            f"{selection.candidate.description} | mutator={selection.source}"
        )
        if selection.rationale:
            print(f"  rationale: {selection.rationale}")
        if outcome.capture_hash:
            extra = " (seen before)" if outcome.capture_hash == best_hash and action != "keep" else ""
            streak = f" | repeat streak={repeat_streak}" if action != "keep" and repeat_streak > 1 else ""
            print(f"  capture hash: {outcome.capture_hash[:16]}{extra}{streak}")

        if args.plateau_repeat_limit > 0 and repeat_streak >= args.plateau_repeat_limit:
            stop_reason = (
                f"plateau detected after {repeat_streak} consecutive identical score+image outcomes "
                f"(score={format_score(outcome.score)}, hash={outcome.capture_hash[:16]})"
            )
            print(f"plateau detected:   {stop_reason}")
            break
        if best_score is not None and baseline_outcome.report.get("suite", {}).get("minimum_average_score") is not None:
            minimum = float(baseline_outcome.report["suite"]["minimum_average_score"])
            if best_score >= minimum - SCORE_EPSILON and outcome.benchmark_ok:
                stop_reason = "benchmark passed"
                break

    summarize(outcomes, baseline_score=baseline_outcome.score, best_score=best_score, stop_reason=stop_reason, summary_path=summary_path)
    print("---")
    print(f"iterations attempted: {len(outcomes)}")
    print(f"keeps:               {sum(1 for item in outcomes if item['action'] == 'keep')}")
    print(f"discards:            {sum(1 for item in outcomes if item['action'] == 'discard')}")
    print(f"crashes:             {sum(1 for item in outcomes if item['action'] == 'crash')}")
    print(f"baseline score:      {format_score(baseline_outcome.score)}")
    print(f"final best score:    {format_score(best_score)}")
    print(f"stop reason:         {stop_reason}")
    print(f"summary file:        {summary_path}")
    return 0 if best_score is not None and best_score >= float(baseline_outcome.report.get('suite', {}).get('minimum_average_score', 0.999)) - SCORE_EPSILON else 1


if __name__ == "__main__":
    raise SystemExit(main())
