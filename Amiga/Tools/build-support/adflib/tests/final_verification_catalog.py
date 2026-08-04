#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# Imported by the coordinator and lane driver; it has no standalone CLI.

from __future__ import annotations

from typing import Final, Literal

Lane = Literal["compliance", "quality", "manual-qa", "scope"]
Probe = Literal[
    "offline-rebuild",
    "omit-corresponding-source",
    "inject-workflow-write-permission",
    "omit-protected-environment-denial",
    "inject-out-of-scope-path",
]

LANES: Final[tuple[Lane, ...]] = ("compliance", "quality", "manual-qa", "scope")
PROBES: Final[tuple[Probe, ...]] = (
    "offline-rebuild",
    "omit-corresponding-source",
    "inject-workflow-write-permission",
    "omit-protected-environment-denial",
    "inject-out-of-scope-path",
)
PROBE_LANE: Final[dict[Probe, Lane]] = {
    "offline-rebuild": "manual-qa",
    "omit-corresponding-source": "compliance",
    "inject-workflow-write-permission": "quality",
    "omit-protected-environment-denial": "manual-qa",
    "inject-out-of-scope-path": "scope",
}
