#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 final_verification_coordinator.py --repo-root "$PWD" --attempt-id 00000000-0000-4000-8000-000000000000

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final, Literal, assert_never

from final_verification_catalog import LANES, PROBE_LANE, PROBES, Lane, Probe

ATTEMPT: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")
SCRUB_PREFIXES: Final = ("GITHUB_", "ACTIONS_", "RUNNER_")
SCRUB_NAMES: Final = frozenset(
    {
        "CI",
        "CODEX_HOME",
        "GIT_ASKPASS",
        "SSH_ASKPASS",
        "GH_TOKEN",
        "OP_SERVICE_ACCOUNT_TOKEN",
        "FINAL_VERIFY_CONTROL_SOCKET",
        "FINAL_VERIFY_SIGNING_FD",
    }
)
SAFE_ENVIRONMENT: Final = frozenset({"LANG", "LC_ALL", "LC_CTYPE", "TZ", "TMPDIR"})


@dataclass(frozen=True, slots=True)
class CoordinatorError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


def sanitized_environment(source: dict[str, str], *, role: Literal["lane", "reviewer"]) -> dict[str, str]:
    environment = {
        name: value
        for name, value in source.items()
        if name in SAFE_ENVIRONMENT
        and name not in SCRUB_NAMES
        and not name.startswith(SCRUB_PREFIXES)
    }
    match role:
        case "lane":
            return environment
        case "reviewer":
            return environment
        case unreachable:
            assert_never(unreachable)


def build_lane_argv(
    repo_root: Path,
    evidence_dir: Path,
    state: Path,
    attempt_id: str,
    lane: Lane,
    probe: Probe | None,
) -> tuple[str, ...]:
    if ATTEMPT.fullmatch(attempt_id) is None:
        raise CoordinatorError("attempt_id_invalid")
    driver = repo_root / "Amiga/Tools/build-support/adflib/tests/run_final_verification.py"
    argv = (
        sys.executable,
        str(driver),
        "--repo-root",
        str(repo_root),
        "--evidence-dir",
        str(evidence_dir),
        "--state",
        str(state),
        "--attempt-id",
        attempt_id,
        "--lane",
        lane,
    )
    if probe is not None:
        return (*argv, "--probe", probe)
    return argv


def catalog(repo_root: Path, evidence_root: Path, attempt_id: str) -> dict[str, list[list[str]]]:
    positive: list[list[str]] = []
    negative: list[list[str]] = []
    for lane in LANES:
        state = evidence_root / "lane-state" / lane / "state.json"
        positive.append(list(build_lane_argv(repo_root, evidence_root, state, attempt_id, lane, None)))
    for probe in PROBES:
        lane = PROBE_LANE[probe]
        state = evidence_root / "lane-state" / lane / "state.json"
        negative.append(
            list(build_lane_argv(repo_root, evidence_root / "probes" / probe, state, attempt_id, lane, probe))
        )
    return {"positive": positive, "probes": negative}


def main() -> int:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--repo-root", type=Path, required=True)
    parser.add_argument("--evidence-root", type=Path, default=Path("evidence"))
    parser.add_argument("--attempt-id", required=True)
    arguments = parser.parse_args()
    try:
        result = catalog(
            arguments.repo_root.resolve(strict=True),
            arguments.evidence_root.resolve(),
            arguments.attempt_id,
        )
    except (CoordinatorError, OSError) as error:
        print(error, file=sys.stderr)
        return 2
    json.dump(result, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
