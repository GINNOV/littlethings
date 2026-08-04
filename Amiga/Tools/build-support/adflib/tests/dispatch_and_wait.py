#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 dispatch_and_wait.py --fixture fixtures/consumer-dispatch-success.json --expect success --output-dir evidence

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final, Literal

NONCE: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")
HEX_40: Final = re.compile(r"[0-9a-f]{40}")


@dataclass(frozen=True, slots=True)
class DispatchSelectionError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


def select_run(fixture: dict[str, object]) -> dict[str, object]:
    nonce = str(fixture["nonce"])
    if NONCE.fullmatch(nonce) is None:
        raise DispatchSelectionError("verification_nonce_invalid")
    prior_runs = fixture["prior_runs"]
    runs_after = fixture["runs_after_dispatch"]
    if not isinstance(prior_runs, list) or not isinstance(runs_after, list):
        raise DispatchSelectionError("run_lists_required")
    if any(nonce in str(run.get("name", "")) for run in prior_runs if isinstance(run, dict)):
        raise DispatchSelectionError("verification_nonce_reused")
    prior_ids = {run.get("id") for run in prior_runs if isinstance(run, dict)}
    exact_name = f'{fixture["workflow_kind"]} {nonce}'
    matches = [
        run
        for run in runs_after
        if isinstance(run, dict)
        and run.get("id") not in prior_ids
        and run.get("workflow") == fixture["workflow"]
        and run.get("event") == "workflow_dispatch"
        and run.get("head_sha") == fixture["head_sha"]
        and run.get("actor") == fixture["actor"]
        and run.get("name") == exact_name
    ]
    if len(matches) != 1:
        raise DispatchSelectionError(f"new_run_match_count:{len(matches)}")
    return matches[0]


def record(fixture_path: Path, expectation: Literal["success", "failure"], output_dir: Path) -> None:
    fixture = json.loads(fixture_path.read_text(encoding="utf-8"))
    if not isinstance(fixture, dict):
        raise DispatchSelectionError("fixture_object_required")
    run = select_run(fixture)
    if run.get("status") != "completed":
        raise DispatchSelectionError("run_not_terminal")
    if run.get("conclusion") != expectation:
        raise DispatchSelectionError("unexpected_conclusion")
    head_sha = str(run.get("head_sha", ""))
    source_sha = str(run.get("workflow_source_sha", ""))
    if HEX_40.fullmatch(head_sha) is None or head_sha != fixture["head_sha"]:
        raise DispatchSelectionError("head_sha_mismatch")
    if HEX_40.fullmatch(source_sha) is None or source_sha != fixture["workflow_source_sha"]:
        raise DispatchSelectionError("workflow_source_sha_mismatch")
    evidence_name = str(fixture["evidence_name"])
    artifacts = run.get("artifacts")
    if not isinstance(artifacts, dict) or set(artifacts) != {evidence_name}:
        raise DispatchSelectionError("named_evidence_set_mismatch")
    output_dir.mkdir(parents=True, exist_ok=False)
    (output_dir / evidence_name).write_text(str(artifacts[evidence_name]), encoding="utf-8")
    receipt = {
        "actor": run["actor"],
        "event": run["event"],
        "head_sha": head_sha,
        "nonce": fixture["nonce"],
        "run_id": run["id"],
        "workflow": run["workflow"],
        "workflow_source_sha": source_sha,
    }
    (output_dir / "dispatch-receipt.json").write_text(
        json.dumps(receipt, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--expect", choices=("success", "failure"), required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    arguments = parser.parse_args()
    try:
        record(arguments.fixture, arguments.expect, arguments.output_dir)
    except (DispatchSelectionError, OSError, KeyError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
