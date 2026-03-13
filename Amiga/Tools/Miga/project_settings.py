#!/usr/bin/env python3
"""Shared project settings for the dashboard and terminal tools."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent
PROJECT_SETTINGS_PATH = ROOT / "project_settings.json"

DEFAULT_SETTINGS_PROFILE: dict[str, Any] = {
    "dashboard": {
        "defaults": {
            "iterations": 1,
            "seed": 0,
            "runMode": "copper_mutation",
            "sourceFilter": "",
            "manifestIndex": 0,
            "kickRom": "",
            "autoSelect": True,
            "allowIncludes": False,
            "allowNonentry": False,
        }
    },
    "benchmark": {
        "kickRomName": "",
        "kickRomDir": "",
    },
    "mutationLoop": {
        "iterations": 10,
        "seed": 0,
        "benchmarkConfig": "amiga_workspace/benchmarks/copper_bars/source_benchmark.json",
        "evalScript": "amiga_eval_benchmark_source.py",
        "loopDir": "build/amiga/mutation_loop",
        "resultsFile": "",
        "mutator": "heuristic",
        "mutation": "any",
        "candidateBudget": 12,
        "plateauRepeatLimit": 4,
        "imageHashCacheFile": "",
    },
    "llm": {
        "openai": {
            "model": "gpt-5-mini",
            "apiKeyEnv": "OPENAI_API_KEY",
            "baseUrl": "https://api.openai.com/v1/responses",
            "reasoningEffort": "minimal",
        },
        "lmstudio": {
            "baseUrl": "http://127.0.0.1:1234",
            "model": "",
            "apiTokenEnv": "LMSTUDIO_API_TOKEN",
        },
    },
}


def deep_merge(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    merged = copy.deepcopy(base)
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = deep_merge(merged[key], value)
        else:
            merged[key] = value
    return merged


def build_default_project_settings() -> dict[str, Any]:
    return {
        "activeProfile": "default",
        "profiles": {
            "default": copy.deepcopy(DEFAULT_SETTINGS_PROFILE),
            "benchmark": deep_merge(
                DEFAULT_SETTINGS_PROFILE,
                {"dashboard": {"defaults": {"runMode": "copper_reference"}}},
            ),
            "lmstudio": deep_merge(
                DEFAULT_SETTINGS_PROFILE,
                {"mutationLoop": {"mutator": "lmstudio"}},
            ),
            "corpus-validation": deep_merge(
                DEFAULT_SETTINGS_PROFILE,
                {"dashboard": {"defaults": {"runMode": "corpus_validation"}}},
            ),
        },
    }


DEFAULT_PROJECT_SETTINGS: dict[str, Any] = build_default_project_settings()
PROFILE_NAME_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{0,63}$", re.IGNORECASE)


def normalize_profile_name(value: Any) -> str:
    text = str(value or "").strip()
    return text if PROFILE_NAME_RE.match(text) else ""


def normalize_settings_profile(profile: dict[str, Any] | None) -> dict[str, Any]:
    if not isinstance(profile, dict):
        return copy.deepcopy(DEFAULT_SETTINGS_PROFILE)
    return deep_merge(DEFAULT_SETTINGS_PROFILE, profile)


def is_legacy_project_settings(raw: Any) -> bool:
    return isinstance(raw, dict) and any(
        key in raw for key in ("dashboard", "benchmark", "mutationLoop", "llm")
    )


def normalize_project_settings(raw: Any) -> dict[str, Any]:
    normalized = build_default_project_settings()
    if not isinstance(raw, dict):
        return normalized

    if is_legacy_project_settings(raw):
        normalized["profiles"]["default"] = normalize_settings_profile(raw)
        return normalized

    raw_profiles = raw.get("profiles")
    if isinstance(raw_profiles, dict):
        for name, profile in raw_profiles.items():
            normalized_name = normalize_profile_name(name)
            if not normalized_name:
                continue
            normalized["profiles"][normalized_name] = normalize_settings_profile(profile)

    active_profile = normalize_profile_name(raw.get("activeProfile"))
    if active_profile and active_profile in normalized["profiles"]:
        normalized["activeProfile"] = active_profile

    return normalized


def resolve_active_profile(settings: dict[str, Any]) -> dict[str, Any]:
    active_profile = normalize_profile_name(settings.get("activeProfile")) or "default"
    profile = settings.get("profiles", {}).get(active_profile)
    if not isinstance(profile, dict):
        profile = settings.get("profiles", {}).get("default", {})
    return normalize_settings_profile(profile)


def load_project_settings_config(path: Path | None = None) -> dict[str, Any]:
    settings_path = path or PROJECT_SETTINGS_PATH
    if not settings_path.exists():
        return build_default_project_settings()
    try:
        loaded = json.loads(settings_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return build_default_project_settings()
    return normalize_project_settings(loaded)


def load_project_settings(path: Path | None = None) -> dict[str, Any]:
    return resolve_active_profile(load_project_settings_config(path))
