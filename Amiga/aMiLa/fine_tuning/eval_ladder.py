#!/usr/bin/env python3
"""Honest ASM generation ladder for the Amiga Playground MLX server.

This script intentionally avoids repair-by-regex cleanup. It extracts one code
block, compiles exactly that source with VASM, runs semantic checks, optionally
packages an ADF, and can optionally require an FS-UAE smoke run.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import tempfile
import time
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from asm_semantics import Scenario, family_hint, semantic_failures


BASE_MODEL = "default_model"
DEFAULT_BASE_URL = "http://localhost:1234"
DEFAULT_ADAPTER = "adapters_asm"
DEFAULT_LADDER = str(Path(__file__).with_name("asm_capability_ladder.yaml"))
DEFAULT_VASM = "/usr/local/bin/vasmm68k_mot"
DEFAULT_XDFTOOL = str(Path(__file__).parent / ".venv/bin/xdftool")
DEFAULT_FS_UAE = "/opt/homebrew/bin/fs-uae"
DEFAULT_NDK_INCLUDE = str(
    Path(__file__).parents[1]
    / "Dataset/corpus3/amiga-dev/targets/m68k-amigaos/ndk/include_i"
)

SYSTEM_PROMPT = """You are AntigravityAmiga, an elite Amiga 68000 Motorola assembly programmer. Write complete VASM-compatible AmigaDOS executables only."""

GENERATION_CONTRACT = """When generating Amiga assembly, return exactly one fenced code block tagged assembly and no prose outside the code block.
- Include SECTION Code,CODE and XDEF _Start for runnable AmigaDOS executables.
- Use SECTION Code,CODE,CHIP for copper-list programs.
- Use $00ff hexadecimal syntax, never 0x00ff.
- Only use 68000 registers d0-d7 and a0-a7.
- Use lea $dff000,a6 and offsets such as $180(a6), $80(a6), $88(a6), $96(a6).
- Never emit bare DFF180, dff000(a6), dec.l, wait.l, BPUSH, OUT, $fp, v0, or symbolic colors like BLUE.
- For animated copper requests, update copper wait/color words every frame, wait for vblank, and exit on left mouse.
- For blitter requests, use the canonical DMACONR byte busy wait btst #6,$02(a6), set BLTCON0, configure pointers/modulos, start work through BLTSIZE, and wait again after BLTSIZE.
"""


@dataclass
class AttemptResult:
    attempt: int
    raw_response: str
    code: str
    compile_ok: bool
    compile_log: str
    semantic_failures: list[str]
    adf_ok: bool | None = None
    adf_log: str = ""
    smoke_ok: bool | None = None
    smoke_log: str = ""

    @property
    def passed(self) -> bool:
        checks = [self.compile_ok, not self.semantic_failures]
        if self.adf_ok is not None:
            checks.append(self.adf_ok)
        if self.smoke_ok is not None:
            checks.append(self.smoke_ok)
        return all(checks)

    def as_dict(self) -> dict[str, Any]:
        return {
            "attempt": self.attempt,
            "raw_response": self.raw_response,
            "code": self.code,
            "compile_ok": self.compile_ok,
            "compile_log": self.compile_log,
            "semantic_failures": self.semantic_failures,
            "adf_ok": self.adf_ok,
            "adf_log": self.adf_log,
            "smoke_ok": self.smoke_ok,
            "smoke_log": self.smoke_log,
            "passed": self.passed,
        }


SCENARIOS = [
    Scenario("minimal_executable", "Generate a minimal Amiga 68000 assembly program that exits cleanly.", ()),
    Scenario("register_color_write", "Generate an Amiga 68000 assembly program that sets COLOR00 to red and exits cleanly.", ("register_color",)),
    Scenario("vblank_wait", "Generate an Amiga 68000 assembly program that waits for vertical blank using VPOSR or VHPOSR and exits cleanly.", ("vblank",)),
    Scenario("static_copper", "Generate a static Amiga copper list that changes the background color across several raster lines.", ("copper",)),
    Scenario("bouncing_copper", "Generate a bouncing multi color copper list with animated bars that exits on left mouse.", ("animated_copper",)),
    Scenario("blitter_clear", "Generate an Amiga 68000 assembly program that clears a CHIP memory bitplane with the blitter and waits for completion.", ("blitter", "bitplane")),
]


def extract_code_block(response_text: str) -> str:
    blocks = re.findall(r"```(?:assembly|asm)?\s*\n(.*?)```", response_text, re.DOTALL | re.IGNORECASE)
    if blocks:
        return blocks[0].strip()
    return response_text.strip()


def log(message: str) -> None:
    print(message, flush=True)


def post_chat(
    base_url: str,
    model: str,
    adapter: str,
    messages: list[dict[str, str]],
    max_tokens: int,
    timeout: int,
) -> str:
    body: dict[str, Any] = {
        "model": model,
        "messages": messages,
        "stream": False,
        "max_tokens": max_tokens,
        "temperature": 0.1,
    }
    if adapter:
        body["adapters"] = adapter

    request = urllib.request.Request(
        base_url.rstrip("/") + "/v1/chat/completions",
        data=json.dumps(body).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        payload = json.loads(response.read().decode("utf-8"))
    return payload["choices"][0]["message"].get("content", "")


def compile_asm(source: str, vasm_path: str, ndk_include: str) -> tuple[bool, str, str | None]:
    if not Path(vasm_path).exists():
        return False, f"vasm compiler not found at {vasm_path}", None

    with tempfile.TemporaryDirectory(prefix="amiga-eval-") as temp_dir:
        source_path = Path(temp_dir) / "source.s"
        output_path = Path(temp_dir) / "program"
        source_path.write_text(source, encoding="utf-8")
        command = [
            vasm_path,
            "-kick1hunks",
            "-Fhunkexe",
            f"-I{ndk_include}",
            "-o",
            str(output_path),
            "-nosym",
            str(source_path),
        ]
        result = subprocess.run(command, capture_output=True, text=True, timeout=10)
        log = (result.stdout + "\n" + result.stderr).strip()
        if result.returncode != 0:
            return False, log, None

        persisted_output = tempfile.NamedTemporaryFile(prefix="amiga-eval-program-", delete=False)
        persisted_output.close()
        Path(persisted_output.name).write_bytes(output_path.read_bytes())
        return True, log, persisted_output.name


def package_adf(program_path: str, xdftool_path: str) -> tuple[bool, str, str | None]:
    if not Path(xdftool_path).exists():
        return False, f"xdftool not found at {xdftool_path}", None

    with tempfile.TemporaryDirectory(prefix="amiga-eval-adf-") as temp_dir:
        startup = Path(temp_dir) / "startup-sequence"
        adf_path = Path(tempfile.NamedTemporaryFile(prefix="amiga-eval-", suffix=".adf", delete=False).name)
        adf_path.unlink(missing_ok=True)
        startup.write_text("program\n", encoding="utf-8")
        command = [
            xdftool_path,
            str(adf_path),
            "create",
            "+",
            "format",
            "Eval",
            "+",
            "boot",
            "install",
            "+",
            "makedir",
            "s",
            "+",
            "write",
            str(startup),
            "s/startup-sequence",
            "+",
            "write",
            program_path,
            "program",
        ]
        result = subprocess.run(command, capture_output=True, text=True, timeout=15)
        log = (result.stdout + "\n" + result.stderr).strip()
        if result.returncode != 0:
            try:
                adf_path.unlink()
            except FileNotFoundError:
                pass
            return False, log, None
        return True, log, str(adf_path)


def smoke_run(adf_path: str, fs_uae_path: str, timeout_seconds: int) -> tuple[bool, str]:
    if not Path(fs_uae_path).exists():
        return False, f"FS-UAE not found at {fs_uae_path}"

    command = [fs_uae_path, f"--floppy_drive_0={adf_path}", "--amiga_model=A500", "--fullscreen=0"]
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        time.sleep(timeout_seconds)
        if process.poll() is None:
            process.terminate()
            stdout, stderr = process.communicate(timeout=5)
            return True, (stdout + "\n" + stderr).strip()
        stdout, stderr = process.communicate(timeout=5)
        return False, (stdout + "\n" + stderr).strip() or f"FS-UAE exited early with {process.returncode}"
    except subprocess.TimeoutExpired:
        process.kill()
        stdout, stderr = process.communicate()
        return False, (stdout + "\n" + stderr).strip() or "FS-UAE did not terminate cleanly"


def repair_prompt(original_request: str, source: str, compile_log: str, failures: list[str], families: tuple[str, ...] = ()) -> str:
    failure_text = "\n".join(f"- {failure}" for failure in failures) or "- No semantic failures"
    hint = family_hint(failures, families)
    return f"""The previous Amiga 68000 assembly failed the reliability gate.

Original request:
```text
{original_request}
```

VASM output:
```text
{compile_log or "No compiler output."}
```

Semantic failures:
```text
{failure_text}
```

Correction hint:
```text
{hint}
```

Return ONLY one complete corrected source file in a fenced assembly code block. Preserve the original request exactly.

Previous source:
```assembly
{source}
```
"""


def scenario_result(scenario: Scenario, attempts: list[AttemptResult]) -> dict[str, Any]:
    first = attempts[0]
    final = attempts[-1]
    return {
        "id": scenario.id,
        "prompt": scenario.prompt,
        "families": list(scenario.families),
        "first_shot_passed": first.passed,
        "passed_after_repair": final.passed,
        "attempts": [attempt.as_dict() for attempt in attempts],
    }


def summary_payload(args: argparse.Namespace, results: list[dict[str, Any]], status: str) -> dict[str, Any]:
    return {
        "status": status,
        "model": args.model,
        "adapter": args.adapter,
        "base_url": args.base_url,
        "dataset_snapshot": args.dataset_snapshot,
        "training_config": args.training_config,
        "ladder": args.ladder,
        "first_shot_passes": sum(1 for result in results if result["first_shot_passed"]),
        "passes_after_repair": sum(1 for result in results if result["passed_after_repair"]),
        "total": len(results),
        "planned_total": len(selected_scenarios(args)),
        "promotion_passed": bool(results) and all(result["passed_after_repair"] for result in results),
        "results": results,
    }


def write_summary(args: argparse.Namespace, results: list[dict[str, Any]], status: str) -> None:
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(summary_payload(args, results, status), indent=2), encoding="utf-8")


def load_ladder(path: str) -> list[Scenario]:
    ladder_path = Path(path)
    if not ladder_path.exists():
        return SCENARIOS
    payload = json.loads(ladder_path.read_text(encoding="utf-8"))
    return [Scenario.from_dict(item) for item in payload]


def selected_scenarios(args: argparse.Namespace) -> list[Scenario]:
    ladder = load_ladder(args.ladder)
    if not args.scenario:
        return ladder

    requested = set(args.scenario)
    scenarios = [scenario for scenario in ladder if scenario.id in requested]
    missing = requested.difference({scenario.id for scenario in scenarios})
    if missing:
        raise SystemExit(f"Unknown scenario id(s): {', '.join(sorted(missing))}")
    return scenarios


def run_scenario(args: argparse.Namespace, scenario: Scenario, results: list[dict[str, Any]]) -> dict[str, Any]:
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "system", "content": GENERATION_CONTRACT},
        {"role": "user", "content": scenario.prompt},
    ]
    attempts: list[AttemptResult] = []
    log(f"[{scenario.id}] start")

    for attempt in range(0, args.max_repairs + 1):
        log(f"[{scenario.id}] attempt {attempt + 1}/{args.max_repairs + 1}: generating")
        response = post_chat(
            args.base_url,
            args.model,
            args.adapter,
            messages,
            args.max_tokens or scenario.max_tokens,
            args.request_timeout,
        )
        code = extract_code_block(response)
        log(f"[{scenario.id}] attempt {attempt + 1}: generated {len(code)} code chars")

        compile_ok, compile_log, program_path = compile_asm(code, args.vasm, args.ndk_include)
        failures = semantic_failures(code, scenario.prompt, scenario.families)

        result = AttemptResult(
            attempt=attempt,
            raw_response=response,
            code=code,
            compile_ok=compile_ok,
            compile_log=compile_log,
            semantic_failures=failures,
        )

        should_package_adf = args.package_adf or scenario.package_adf or args.require_emulator or scenario.require_emulator
        should_require_emulator = args.require_emulator or scenario.require_emulator

        if compile_ok and program_path and should_package_adf:
            result.adf_ok, result.adf_log, adf_path = package_adf(program_path, args.xdftool)
            if result.adf_ok and adf_path and should_require_emulator:
                result.smoke_ok, result.smoke_log = smoke_run(adf_path, args.fs_uae, args.smoke_seconds)
            if adf_path:
                Path(adf_path).unlink(missing_ok=True)

        if program_path:
            Path(program_path).unlink(missing_ok=True)

        attempts.append(result)
        status = "PASS" if result.passed else "FAIL"
        failure_preview = "; ".join(failures[:3]) if failures else compile_log.splitlines()[0] if compile_log else ""
        log(
            f"[{scenario.id}] attempt {attempt + 1}: {status} "
            f"compile={compile_ok} semantic_failures={len(failures)} "
            f"adf={result.adf_ok} smoke={result.smoke_ok}"
        )
        if failure_preview and not result.passed:
            log(f"[{scenario.id}] attempt {attempt + 1}: first failure: {failure_preview[:240]}")

        partial_results = results + [scenario_result(scenario, attempts)]
        write_summary(args, partial_results, "running")
        log(f"[{scenario.id}] wrote partial summary to {args.output}")

        if result.passed:
            break

        messages.append({"role": "assistant", "content": response})
        messages.append({"role": "user", "content": repair_prompt(scenario.prompt, code, compile_log, failures, scenario.families)})

    result = scenario_result(scenario, attempts)
    log(f"[{scenario.id}] done: {'PASS' if result['passed_after_repair'] else 'FAIL'}")
    return result


def self_test() -> None:
    bad = "move.w #0x00f,d8\nmove.w #BLUE,DFF180\ndc.w #$fffe,$0180\ndec.l d0"
    failures = semantic_failures(bad, "set background")
    assert "invalid register d8" in failures
    assert "C-style hex literal 0x00f" in failures
    assert "bare custom-chip register DFF180" in failures
    assert "undefined symbolic color BLUE" in failures
    assert "immediate marker # is invalid in dc data directives" in failures
    assert "invalid pseudo instruction dec.l" in failures
    assert extract_code_block("```assembly\nrts\n```") == "rts"
    wait_only_blitter = """
            SECTION Code,CODE,CHIP
            XDEF _Start
_Start:
            lea $dff000,a6
.wait:
            btst #6,$02(a6)
            bne.s .wait
            rts
"""
    failures = semantic_failures(wait_only_blitter, "Generate a blitter setup.", ("blitter",))
    assert "missing BLTCON0 $40(a6) setup" in failures
    assert "missing BLTSIZE $58(a6) start" in failures
    assert "missing blitter wait after BLTSIZE" in failures
    noncanonical = wait_only_blitter.replace("#6,$02", "#14,$02")
    assert "non-canonical blitter wait; use btst #6,$02(a6)" in semantic_failures(noncanonical, "Generate a blitter setup.", ("blitter",))
    assert "missing AUD0LCH setup" in semantic_failures("SECTION Code,CODE\nXDEF _Start\n_Start:\nrts", "audio", ("audio",))
    assert "missing sprite 0 pointer/setup" in semantic_failures("SECTION Code,CODE\nXDEF _Start\n_Start:\nrts", "sprite", ("sprite",))
    assert "missing CIA/joystick/mouse hardware read" in semantic_failures("SECTION Code,CODE\nXDEF _Start\n_Start:\nrts", "joystick", ("input",))
    prompt = repair_prompt("Generate a blitter setup.", "rts", "No compiler output.", ["missing BLTSIZE $58(a6) start"], ("blitter",))
    assert "Original request:" in prompt
    assert "Generate a blitter setup." in prompt
    assert "canonical DMACONR byte busy test" in prompt


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the honest ASM golden ladder against the local MLX server.")
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL)
    parser.add_argument("--model", default=BASE_MODEL)
    parser.add_argument("--adapter", default=DEFAULT_ADAPTER)
    parser.add_argument("--ladder", default=DEFAULT_LADDER, help="JSON-compatible YAML ladder definition.")
    parser.add_argument("--vasm", default=DEFAULT_VASM)
    parser.add_argument("--ndk-include", default=DEFAULT_NDK_INCLUDE)
    parser.add_argument("--xdftool", default=DEFAULT_XDFTOOL)
    parser.add_argument("--fs-uae", default=DEFAULT_FS_UAE)
    parser.add_argument("--max-tokens", type=int, default=0, help="Override per-scenario max tokens.")
    parser.add_argument("--max-repairs", type=int, default=2)
    parser.add_argument("--request-timeout", type=int, default=90)
    parser.add_argument(
        "--scenario",
        action="append",
        help="Run only this scenario id. Can be passed more than once.",
    )
    parser.add_argument("--package-adf", action="store_true", help="Require ADF packaging for each compiled scenario.")
    parser.add_argument("--require-emulator", action="store_true", help="Require ADF packaging and FS-UAE smoke run.")
    parser.add_argument("--smoke-seconds", type=int, default=8)
    parser.add_argument("--output", default="evaluation_debug/asm_eval_ladder_summary.json")
    parser.add_argument("--dataset-snapshot", default="", help="Optional dataset snapshot or git ref recorded in the eval JSON.")
    parser.add_argument("--training-config", default="config_asm.yaml", help="Training config path recorded in the eval JSON.")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        self_test()
        print("eval_ladder self-test passed")
        return 0

    results: list[dict[str, Any]] = []
    scenarios = selected_scenarios(args)
    log(f"Running {len(scenarios)} ASM scenario(s); output={args.output}")
    write_summary(args, results, "running")

    for scenario in scenarios:
        result = run_scenario(args, scenario, results)
        results.append(result)
        write_summary(args, results, "running")

    summary = summary_payload(args, results, "complete")
    write_summary(args, results, "complete")

    print(json.dumps({key: summary[key] for key in ["first_shot_passes", "passes_after_repair", "total", "promotion_passed"]}, indent=2))
    print(f"Wrote {Path(args.output)}")
    return 0 if summary["promotion_passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
