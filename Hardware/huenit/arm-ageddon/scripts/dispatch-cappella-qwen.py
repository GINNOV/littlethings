#!/usr/bin/env python3
"""Fan bounded coding jobs to cappella Qwen (SGLang). Orchestrator applies results."""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

DEFAULT_BASE = os.environ.get("CAPPELLA_SGLANG_BASE_URL", "http://192.168.0.69:8888/v1")
DEFAULT_MODEL = os.environ.get("CAPPELLA_SGLANG_MODEL", "qwen3.8-27b-sglang")


def post_chat(base: str, model: str, prompt: str, max_tokens: int) -> dict:
    body = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a Swift 6 coder for ArmageddonCore (macOS 15, Sendable, "
                    "no force-try in production paths). Reply with ONE markdown fence "
                    "of Swift (or the exact file contents requested). No G28, no USB, "
                    "no network in tests, no motors."
                ),
            },
            {"role": "user", "content": prompt},
        ],
        "max_tokens": max_tokens,
        "temperature": 0.2,
        "top_p": 0.8,
        "chat_template_kwargs": {"enable_thinking": False},
    }
    data = json.dumps(body).encode()
    req = urllib.request.Request(
        base.rstrip("/") + "/chat/completions",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=180) as response:
        return json.loads(response.read().decode())


def extract_fence(text: str) -> str:
    marker = "```"
    start = text.find(marker)
    if start < 0:
        return text.strip() + "\n"
    rest = text[start + len(marker) :]
    if rest.startswith("swift"):
        rest = rest[5:]
    elif rest.startswith("json"):
        rest = rest[4:]
    if rest.startswith("\n"):
        rest = rest[1:]
    end = rest.find(marker)
    if end < 0:
        return rest.strip() + "\n"
    return rest[:end].strip() + "\n"


def run_job(path: Path, base: str, model: str, max_tokens: int, out_dir: Path) -> dict:
    prompt = path.read_text()
    started = time.time()
    try:
        payload = post_chat(base, model, prompt, max_tokens)
        message = payload["choices"][0]["message"]
        content = message.get("content") or ""
        fence = extract_fence(content)
        stem = path.stem
        (out_dir / f"{stem}.raw.json").write_text(json.dumps(payload, indent=2) + "\n")
        (out_dir / f"{stem}.md").write_text(content + "\n")
        (out_dir / f"{stem}.out").write_text(fence)
        elapsed = time.time() - started
        usage = payload.get("usage") or {}
        return {
            "job": stem,
            "ok": True,
            "seconds": round(elapsed, 2),
            "completion_tokens": usage.get("completion_tokens"),
            "bytes": len(fence),
        }
    except (urllib.error.URLError, TimeoutError, KeyError, json.JSONDecodeError, OSError) as error:
        (out_dir / f"{path.stem}.error.txt").write_text(str(error) + "\n")
        return {"job": path.stem, "ok": False, "error": str(error), "seconds": round(time.time() - started, 2)}


def main() -> int:
    parser = argparse.ArgumentParser(description="Dispatch coding jobs to cappella Qwen")
    parser.add_argument("--jobs", type=Path, required=True, help="Directory of *.md job prompts")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--base", default=DEFAULT_BASE)
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--max-tokens", type=int, default=4096)
    parser.add_argument("--workers", type=int, default=4)
    args = parser.parse_args()
    jobs = sorted(args.jobs.glob("*.md"))
    if not jobs:
        print("no jobs", file=sys.stderr)
        return 2
    args.out.mkdir(parents=True, exist_ok=True)
    print(f"base={args.base} model={args.model} jobs={len(jobs)} workers={args.workers}", flush=True)
    results = []
    with ThreadPoolExecutor(max_workers=max(1, min(args.workers, 10))) as pool:
        futures = {
            pool.submit(run_job, job, args.base, args.model, args.max_tokens, args.out): job for job in jobs
        }
        for future in as_completed(futures):
            result = future.result()
            results.append(result)
            print(json.dumps(result), flush=True)
    (args.out / "summary.json").write_text(json.dumps(results, indent=2) + "\n")
    return 0 if all(item.get("ok") for item in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
