#!/usr/bin/env python3
"""Semantic checks for generated Amiga VASM sources."""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class Scenario:
    id: str
    prompt: str
    families: tuple[str, ...]
    package_adf: bool = True
    require_emulator: bool = False
    max_tokens: int = 1200

    @classmethod
    def from_dict(cls, payload: dict[str, Any]) -> "Scenario":
        families = payload.get("families") or payload.get("family") or []
        if isinstance(families, str):
            families = [families]
        return cls(
            id=payload["id"],
            prompt=payload["prompt"],
            families=tuple(families),
            package_adf=bool(payload.get("package_adf", True)),
            require_emulator=bool(payload.get("require_emulator", False)),
            max_tokens=int(payload.get("max_tokens", 1200)),
        )


FAMILY_HINTS = {
    "blitter": "Use the canonical DMACONR byte busy test btst #6,$02(a6), set BLTCON0 at $40(a6), configure blitter pointers/modulos, start with BLTSIZE at $58(a6), then wait again.",
    "copper": "Install CopperList through COP1LC $80(a6), strobe COPJMP1 $88(a6), enable copper DMA through DMACON $96(a6), and terminate with dc.w $ffff,$fffe.",
    "animated_copper": "For animated copper, wait for vblank, update copper wait/color words every frame, and exit on left mouse with btst #6,$bfe001.",
    "bitplane": "Configure BPLCON0 and bitplane pointers from $dff000 offsets, and store bitplane data in CHIP memory.",
    "sprite": "Configure SPRxPTH/SPRxPTL or sprite pointer data and terminate sprite data with zero words.",
    "audio": "Configure AUDxLCH/AUDxLCL, AUDxLEN, AUDxPER, AUDxVOL, and enable audio DMA.",
    "input": "Read CIA/joy registers with concrete hardware addresses and include a bounded loop or clean exit path.",
    "interrupt": "Use INTENA/INTREQ deliberately and acknowledge interrupts that are enabled.",
    "exec": "Use Exec/Graphics library vectors with a6 as the library base and restore state before returning.",
    "bootblock": "Emit a DOS bootblock shape only for bootblock prompts; otherwise produce an AmigaDOS executable.",
    "subroutine": "Produce callable labels with documented register inputs/outputs and preserve non-scratch registers when needed.",
}


def strip_comments(source: str) -> str:
    return "\n".join(line.split(";", 1)[0] for line in source.splitlines())


def ordered_unique(values: list[str]) -> list[str]:
    seen = set()
    unique = []
    for value in values:
        if value not in seen:
            unique.append(value)
            seen.add(value)
    return unique


def contains(pattern: str, source: str) -> bool:
    return re.search(pattern, source, re.IGNORECASE | re.MULTILINE) is not None


def semantic_failures(source: str, prompt: str = "", families: tuple[str, ...] = ()) -> list[str]:
    code = strip_comments(source)
    lower_prompt = prompt.lower()
    requested = set(families) if families else infer_families(lower_prompt)
    failures: list[str] = []

    failures.extend(validate_global_rules(code))
    failures.extend(validate_executable_structure(code, requested))

    validators = {
        "register_color": validate_register_color,
        "vblank": validate_vblank,
        "copper": validate_copper,
        "animated_copper": validate_animated_copper,
        "blitter": validate_blitter,
        "bitplane": validate_bitplane,
        "sprite": validate_sprite,
        "audio": validate_audio,
        "input": validate_input,
        "interrupt": validate_interrupt,
        "exec": validate_exec,
        "bootblock": validate_bootblock,
        "subroutine": validate_subroutine,
    }
    for family in sorted(requested):
        validator = validators.get(family)
        if validator:
            failures.extend(validator(code))

    return ordered_unique(failures)


def infer_families(lower_prompt: str) -> set[str]:
    families: set[str] = set()
    if "color00" in lower_prompt or "background color" in lower_prompt:
        families.add("register_color")
    if "vblank" in lower_prompt or "vertical blank" in lower_prompt or "raster" in lower_prompt:
        families.add("vblank")
    if "copper" in lower_prompt:
        families.add("copper")
    if "bounc" in lower_prompt or "animated" in lower_prompt:
        if "copper" in lower_prompt:
            families.add("animated_copper")
    if "blitter" in lower_prompt or "blit" in lower_prompt:
        families.add("blitter")
    if "bitplane" in lower_prompt or "screen" in lower_prompt:
        families.add("bitplane")
    if "sprite" in lower_prompt:
        families.add("sprite")
    if "audio" in lower_prompt or "sound" in lower_prompt:
        families.add("audio")
    if any(term in lower_prompt for term in ["cia", "joystick", "mouse", "keyboard", "input"]):
        families.add("input")
    if "interrupt" in lower_prompt or "irq" in lower_prompt:
        families.add("interrupt")
    if any(term in lower_prompt for term in ["exec", "graphics.library", "intuition", "library"]):
        families.add("exec")
    if "bootblock" in lower_prompt:
        families.add("bootblock")
    if "subroutine" in lower_prompt or "routine" in lower_prompt:
        families.add("subroutine")
    return families


def validate_global_rules(code: str) -> list[str]:
    failures: list[str] = []
    for match in re.findall(r"(?<!\$)\b[da](?:[8-9]|[1-9][0-9]+)\b", code, re.IGNORECASE):
        failures.append(f"invalid register {match.lower()}")
    for match in re.findall(r"\b0x[0-9a-f]+\b", code, re.IGNORECASE):
        failures.append(f"C-style hex literal {match.lower()}")
    for match in re.findall(r"(?<!\$)\bDFF[0-9A-F]{3}\b", code, re.IGNORECASE):
        failures.append(f"bare custom-chip register {match.upper()}")
    for match in re.findall(r"\b(BLUE|RED|GREEN|YELLOW|CYAN|MAGENTA|PURPLE|WHITE|BLACK)\b", code, re.IGNORECASE):
        failures.append(f"undefined symbolic color {match.upper()}")
    for match in re.findall(r"\b(dec\.[blw]|wait\.[blw]|and\.t|bpush|out)\b", code, re.IGNORECASE):
        failures.append(f"invalid pseudo instruction {match.lower()}")
    if contains(r"dc\.[bwl]\s+#", code):
        failures.append("immediate marker # is invalid in dc data directives")
    if contains(r"^\s*SECTION\s*$", code):
        failures.append("split SECTION directive")
    return failures


def validate_executable_structure(code: str, families: set[str]) -> list[str]:
    if "bootblock" in families or "subroutine" in families:
        return []
    failures: list[str] = []
    if not contains(r"^\s*SECTION\s+\S+\s*,\s*CODE(?:\s*,\s*CHIP)?\b", code):
        failures.append("missing SECTION Code,CODE")
    if not contains(r"^\s*XDEF\s+_Start\b", code):
        failures.append("missing XDEF _Start")
    if not contains(r"^_Start:\s*$", code):
        failures.append("missing _Start label")
    return failures


def validate_register_color(code: str) -> list[str]:
    if not contains(r"\$180\s*\(\s*a[0-7]\s*\)", code):
        return ["missing COLOR00 $180(a6) write"]
    return []


def validate_vblank(code: str) -> list[str]:
    if not contains(r"(waitvblank|\$04\s*\(\s*a[0-7]\s*\)|\$06\s*\(\s*a[0-7]\s*\)|vhposr|vposr)", code):
        return ["missing vertical blank/raster register wait"]
    if not contains(r"\b(cmp|btst|tst)\.[bwl]\b|\bdbf\b", code):
        return ["missing bounded vblank/raster wait condition"]
    return []


def validate_copper(code: str) -> list[str]:
    failures: list[str] = []
    lower_code = code.lower()
    if not all(token in lower_code for token in ["section", "code", "chip"]):
        failures.append("copper program must use SECTION Code,CODE,CHIP")
    if "copperlist" not in lower_code:
        failures.append("missing CopperList label")
    if not contains(r"\$80\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing COP1LC $80(a6) install")
    if not contains(r"\$88\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing COPJMP1 $88(a6) strobe")
    if not contains(r"\$96\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing DMACON $96(a6) enable")
    if not contains(r"dc\.w\s+\$ffff\s*,\s*\$fffe", code):
        failures.append("missing copper list terminator dc.w $ffff,$fffe")
    return failures


def validate_animated_copper(code: str) -> list[str]:
    failures = validate_copper(code)
    if not contains(r"(waitvblank|\$06\s*\(\s*a[0-7]\s*\)|vhposr|vposr)", code):
        failures.append("missing vertical blank wait")
    if not contains(r"btst\s+#6\s*,\s*\$bfe001", code):
        failures.append("missing left mouse exit")
    updates_waits = contains(r"^\s*(move|add|sub|neg|clr)\.[bwl]\s+[^;\n]+,\s*[A-Za-z_][A-Za-z0-9_]*Wait\b", code)
    wait_labels = re.findall(r"(?im)^[A-Za-z_][A-Za-z0-9_]*Wait:", code)
    if not updates_waits and len(wait_labels) < 2:
        failures.append("missing animated copper wait words")
    return failures


def validate_blitter(code: str) -> list[str]:
    failures: list[str] = []
    wait_matches = re.findall(r"btst\s+#(?:6|14)\s*,\s*\$02\s*\(\s*a[0-7]\s*\)", code, re.IGNORECASE)
    if not wait_matches:
        failures.append("missing blitter busy wait btst #6,$02(a6)")
    if not contains(r"btst\s+#6\s*,\s*\$02\s*\(\s*a[0-7]\s*\)", code):
        failures.append("non-canonical blitter wait; use btst #6,$02(a6)")
    if len(wait_matches) < 2:
        failures.append("missing blitter wait after BLTSIZE")
    if not contains(r"\$40\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing BLTCON0 $40(a6) setup")
    if not contains(r"\$58\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing BLTSIZE $58(a6) start")
    if not contains(r"\$(50|54)\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing blitter source or destination pointer setup")
    if not contains(r"\$(64|66)\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing blitter modulo setup")
    return failures


def validate_bitplane(code: str) -> list[str]:
    failures: list[str] = []
    if not contains(r"\$100\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing BPLCON0 $100(a6) setup")
    if not contains(r"\$(e0|e2)\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing bitplane pointer setup")
    if not contains(r"SECTION\s+\S+\s*,\s*DATA\s*,\s*CHIP|ds\.b", code):
        failures.append("missing CHIP bitplane data")
    return failures


def validate_sprite(code: str) -> list[str]:
    failures: list[str] = []
    if not contains(r"\$120\s*\(\s*a[0-7]\s*\)|spr0", code):
        failures.append("missing sprite 0 pointer/setup")
    if not contains(r"dc\.w\s+\$0000\s*,\s*\$0000", code):
        failures.append("missing sprite data terminator")
    return failures


def validate_audio(code: str) -> list[str]:
    failures: list[str] = []
    for offset, name in [("$a0", "AUD0LCH"), ("$a4", "AUD0LEN"), ("$a6", "AUD0PER"), ("$a8", "AUD0VOL")]:
        if not contains(rf"{re.escape(offset)}\s*\(\s*a[0-7]\s*\)", code):
            failures.append(f"missing {name} setup")
    if not contains(r"\$96\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing audio DMA enable through DMACON")
    return failures


def validate_input(code: str) -> list[str]:
    if not contains(r"\$bfe001|\$dff00a|\$0a\s*\(\s*a[0-7]\s*\)|cia|joy", code):
        return ["missing CIA/joystick/mouse hardware read"]
    return []


def validate_interrupt(code: str) -> list[str]:
    failures: list[str] = []
    if not contains(r"\$9a\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing INTENA $9a(a6) setup")
    if not contains(r"\$9c\s*\(\s*a[0-7]\s*\)", code):
        failures.append("missing INTREQ $9c(a6) acknowledge")
    return failures


def validate_exec(code: str) -> list[str]:
    if not contains(r"4\.w\s*,\s*a6|move\.l\s+4\.w\s*,\s*a6|jsr\s+-\d+\s*\(\s*a6\s*\)", code):
        return ["missing Exec/library base LVO call pattern"]
    return []


def validate_bootblock(code: str) -> list[str]:
    failures: list[str] = []
    if not contains(r"dc\.b\s+['\"]DOS['\"]", code):
        failures.append("missing DOS bootblock signature")
    if not contains(r"dc\.l\s+880|root", code):
        failures.append("missing bootblock root block longword")
    return failures


def validate_subroutine(code: str) -> list[str]:
    if not contains(r"^[A-Za-z_][A-Za-z0-9_]*:\s*$", code) or not contains(r"\brts\b", code):
        return ["missing callable label and rts"]
    return []


def family_hint(failures: list[str], families: tuple[str, ...]) -> str:
    for family in families:
        hint = FAMILY_HINTS.get(family)
        if hint:
            return hint
    if any("blitter" in failure.lower() or "blt" in failure.lower() for failure in failures):
        return FAMILY_HINTS["blitter"]
    return "Return a complete VASM-compatible source file that preserves the original requested behavior."
