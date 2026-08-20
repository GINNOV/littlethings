from __future__ import annotations

from pathlib import Path

from evidence_common import EvidenceError, read_json, reject_forbidden_outcomes
from final_gate_support import existing_absolute


def validate_task_modes(evidence_root: Path, expected: int) -> list[Path]:
    root = existing_absolute(evidence_root, "evidence root")
    records: dict[tuple[int, str], Path] = {}
    for path in root.rglob("camera-ml-app.json"):
        if path.is_symlink():
            raise EvidenceError("symlink-evidence", str(path))
        value = read_json(path)
        if not isinstance(value, dict):
            raise EvidenceError("invalid-task-receipt", str(path))
        reject_forbidden_outcomes(value)
        task = value.get("task")
        mode = value.get("mode")
        if not isinstance(task, int) or not isinstance(mode, str) or mode not in {"happy", "failure"}:
            continue
        key = (task, mode)
        if key in records:
            raise EvidenceError("duplicate-task-mode", f"{task}:{mode}")
        outcome = value.get("outcome")
        allowed = outcome == "PASS" or (task == 31 and outcome in {"BLOCKED_MISSING_SIGNING_CREDENTIAL", "EXPECTED_FAILURE"}) or (task == 33 and outcome == "NOT_RUN_OPERATOR_REQUIRED")
        if not allowed:
            raise EvidenceError("task-mode-outcome", str(path))
        records[key] = path.resolve(strict=True)
    expected_keys = {(task, mode) for task in range(1, 34) for mode in ("happy", "failure")}
    if expected != len(expected_keys) or len(records) != expected or set(records) != expected_keys:
        raise EvidenceError("task-modes-incomplete", f"expected {expected} distinct task/mode receipts, found {len(records)}")
    return [records[key] for key in sorted(records)]
