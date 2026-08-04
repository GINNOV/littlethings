from __future__ import annotations

import hashlib
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Final

COORDINATOR: Final = Path(__file__).resolve().parents[1] / "canary_coordinator.py"
CONSUMER_CONTRACT: Final = Path(__file__).resolve().parent / "consumer_workflow_contract.py"
NETWORK_DENIED: Final = Path(__file__).resolve().parent / "run_network_denied.py"
MANIFEST: Final = Path(__file__).resolve().parents[1] / "ADFlibDependency.cmake"
FORBIDDEN_API_ACTION: Final = re.compile(r"(?:artifact|cache|refs?|pulls?|packages?|releases?|settings|variables|environments)(?:/|:|$)")


@dataclass(frozen=True, slots=True)
class IncompatibleScenario:
    authorize_returncode: int
    route_returncode: int
    preflight_returncode: int
    terminal_state: str
    manifest_before: str
    manifest_after: str
    upload_failure_logs: str
    api_actions: tuple[str, ...]
    detail: str


def run_denied(command: tuple[str, ...], environment: dict[str, str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(NETWORK_DENIED), "--", *command],
        env=environment,
        check=False,
        capture_output=True,
        text=True,
    )


def read_outputs(path: Path) -> dict[str, str]:
    return dict(line.split("=", 1) for line in path.read_text(encoding="utf-8").splitlines())


def run_incompatible_scenario(consumer_contract: Path = CONSUMER_CONTRACT) -> IncompatibleScenario:
    trusted_sha = "a" * 40
    nonce = "123e4567-e89b-42d3-a456-426614174000"
    manifest_before = hashlib.sha256(MANIFEST.read_bytes()).hexdigest()
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        base_environment = {"HOME": temporary, "PATH": os.environ.get("PATH", "/usr/bin:/bin")}
        authorize_output = root / "authorize-output"
        authorize_command = (sys.executable, str(COORDINATOR), "authorize")
        authorize = run_denied(
            authorize_command,
            {
                **base_environment,
                "EVENT_NAME": "workflow_dispatch",
                "EVENT_SHA": trusted_sha,
                "TRUSTED_SHA": trusted_sha,
                "WORKFLOW_REF": "GINNOV/littlethings/.github/workflows/adflib-canary.yml@master",
                "WORKFLOW_SHA": trusted_sha,
                "FIXTURE": "incompatible-master",
                "VERIFICATION_NONCE": nonce,
                "OUTPUT_FILE": str(authorize_output),
            },
        )
        authorized = read_outputs(authorize_output) if authorize.returncode == 0 else {}
        route_output = root / "route-output"
        route_command = (sys.executable, str(consumer_contract), "route")
        route = run_denied(
            route_command,
            {
                **base_environment,
                "EVENT_NAME": "workflow_call",
                "EVENT_SHA": trusted_sha,
                "CANDIDATE_REF": trusted_sha,
                "CANDIDATE_BUNDLE_ARTIFACT": "",
                "CHANNEL": "canary",
                "COMPATIBILITY_FIXTURE": authorized.get("compatibility_fixture", ""),
                "TRUSTED_SHA": trusted_sha,
                "WORKFLOW_REF": f"GINNOV/littlethings/.github/workflows/adflib-canary.yml@{trusted_sha}",
                "OUTPUT_FILE": str(route_output),
            },
        )
        routed = read_outputs(route_output) if route.returncode == 0 else {}
        preflight_command = (sys.executable, str(consumer_contract), "compatibility-preflight")
        preflight = run_denied(
            preflight_command,
            {
                **base_environment,
                "EFFECTIVE_CHANNEL": "canary",
                "ADFLIB_COMPATIBILITY_FIXTURE": routed.get("compatibility_fixture", ""),
            },
        )
        invocations = (authorize_command, route_command, preflight_command)
        api_actions = tuple(
            argument
            for invocation in invocations
            for argument in invocation
            if FORBIDDEN_API_ACTION.search(argument) is not None
        )
    manifest_after = hashlib.sha256(MANIFEST.read_bytes()).hexdigest()
    terminal_state = "failure" if preflight.returncode != 0 else "success"
    detail = (
        f"authorize={authorize.returncode}:{authorize.stderr.strip()}; "
        f"route={route.returncode}:{route.stderr.strip()}; "
        f"preflight={preflight.returncode}:{preflight.stderr.strip()}; "
        f"terminal={terminal_state}; manifest_unchanged={manifest_before == manifest_after}; "
        f"upload_failure_logs={routed.get('upload_failure_logs', 'missing')}; api_actions={api_actions}"
    )
    return IncompatibleScenario(
        authorize.returncode,
        route.returncode,
        preflight.returncode,
        terminal_state,
        manifest_before,
        manifest_after,
        routed.get("upload_failure_logs", "missing"),
        api_actions,
        detail,
    )


def incompatible_scenario_passed(scenario: IncompatibleScenario) -> bool:
    return (
        scenario.authorize_returncode == 0
        and scenario.route_returncode == 0
        and scenario.preflight_returncode == 2
        and scenario.terminal_state == "failure"
        and "adflib_compatibility_fixture: incompatible-master" in scenario.detail
        and scenario.manifest_before == scenario.manifest_after
        and scenario.upload_failure_logs == "false"
        and scenario.api_actions == ()
    )
