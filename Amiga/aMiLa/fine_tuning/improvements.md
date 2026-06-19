# Amiga 68k Model Quality Evaluation — June 2026

Research from a structured four-part audit of the fine-tuned `adapters_asm` MLX model and the integrated Amiga Playground producer path (template routing + `AmigaProgramModel` + verifier stack).

**Evaluation date:** 2026-06-19  
**Model endpoint:** `http://localhost:1234` (`default_model` + `adapters_asm`)  
**Compiler:** `vasmm68k_mot` at `/usr/local/bin/vasmm68k_mot`  
**Artifacts:** `evaluation_debug/asm_eval_ladder_summary.json`

---

## Evaluation Scope

Two distinct paths were measured:

| Path | What it tests |
|------|----------------|
| **Raw model** | `eval_ladder.py` — model generates assembly directly, no template router |
| **Integrated producer** | Routed templates + golden sources + XCTest gates — what users get for supported prompts |

The integrated path scorecard measures user-facing quality. Raw weights alone are not promotion-ready.

---

## 1. Static Analysis & Syntax Audit (`vasm`)

### Raw model (`eval_ladder.py`, 19 scenarios)

| Metric | Result |
|--------|--------|
| First-shot pass (compile + semantic + ADF) | **3/19 (15.8%)** |
| Pass after 3-attempt repair loop | **5/19 (26.3%)** |
| Compile-only (first shot) | **9/19 (47.4%)** |
| Semantic-only (first shot) | **4/19 (21.1%)** |
| Promotion gate | **FAILED** (`promotion_passed: false`) |

**Passed after repair:** `minimal_executable`, `register_color_write`, `vblank_wait`, `static_copper`, `reusable_memclear_subroutine`

**Never passed:** all blitter variants, `bouncing_copper`, `bitplane_display`, `sprite_setup`, `audio_dma`, input/interrupt/exec/bootblock

#### Top VASM error categories (first shot)

| Category | Count | Examples |
|----------|------:|----------|
| Section/label conflict (warning 41) | 10 | `SECTION Code,CODE,CHIP` treated as label |
| Illegal instruction / invalid register | 6 | `d8`–`d10`, `bne.s d0` (register as branch target) |
| Label redefined | 3 | Repeated `_Start:` blocks (bootblock, memclear) |
| Unknown symbol/opcode | 1 | Miscellaneous |

#### Top semantic failures (first shot)

| Pattern | Count |
|---------|------:|
| Non-canonical blitter wait (`btst #6,$02(a6)`) | 4 |
| Missing post-`BLTSIZE` wait | 4 |
| Missing `BLTCON0` / pointer / modulo setup | 4 each |
| Missing CIA/joystick/mouse reads | 4 |
| Invalid registers `d8`–`d10` | 2 |

#### Structure audit (raw model)

- Minimal programs correctly emit `SECTION Code,CODE`, `XDEF _Start`, `_Start:`.
- Copper basics compile; animated copper lacks left-mouse exit and animated wait words.
- Blitter family compiles syntactically but uses legacy wait patterns instead of canonical `btst #6,$02(a6)`.
- Complex prompts degenerate into repeated minimal stubs (bootblock) or register overflow (`d8`+).

### Integrated path (7 complex benchmark families, golden sources)

| Check | Result |
|-------|--------|
| VASM compile (all 7 first-shot golden sources) | **7/7 (100%)** |
| Semantic validator | **7/7 (100%)** |
| `SECTION Code,CODE` present | **7/7 (100%)** |
| `; @amiga:region model begin` embedded | **7/7 (100%)** |
| Clean takeover: `INTENA` / `DMACON` / `COP1LC` save-restore | **Verified** |
| XCTest compile + ADF for all Goal 2 benchmarks | **PASSED** |

---

## 2. Behavioral & Emulator Validation

### Integrated template path (static/runtime contract tests)

All complex-family compile + ADF + follow-up XCTests passed (14/14 in benchmark battery).

### vAmiga runtime smoke — **PASS** (2026-06-19, blitter BOB promotion)

Focused promotion test `testComplexBlitterBOBStandaloneVAmigaRuntimeEvidenceWhenEnabled` **passed** (~9 min). This was an automation/stack issue on vAmiga 4.4, not an assembly defect in the golden blitter BOB template.

| Lesson | Where implemented |
|--------|-------------------|
| Launch via `.retrosh` document (`open -n -a vAmiga.app`) | `validate_emulator_runtime.py` |
| vAmiga 4.4+: plain RetroShell on **8080**; JSON-RPC on **8081** — probe order and transport matter | `wait_for_retroshell()`, `RetroShellEndpoint` in `validate_emulator_runtime.py` |
| vAmiga 4.4 register dumps need `debugger` then `r cpu` / `r agnus` / `.` | `debugger_register_commands()` in `validate_emulator_runtime.py` |
| ADF boot: `df0 connect` + `df0 insert` + reset; **25s** boot wait from XCTest | `create_retrosh()`, `--boot-wait 25` in `AmigaPlaygroundTests` |
| Screenshot capture must use a **second launch** (debugger pauses CPU) | split debug/visual path in `validate_prompt_adf()` |
| Patch/restore real-user `vAmiga.ini` `[SRV]` keys | `patch_vamiga_server_config()` in validator; `VAmigaServerConfigPatcher` in app |
| XCTest runs validator outside app sandbox | `launchctl asuser` wrapper in `AmigaPlaygroundTests` |
| No RetroShell `wait` for smoke timing | Wall-clock sleep, then TCP `screenshot save` |

**Earlier failures (same session):**

1. Port 8081 accepted TCP but returned JSON-RPC parse errors for plain-text `r cpu` — looked like “null registers / Kickstart ROM”.
2. Flat gray frames — program had not finished booting; `df0 connect` and longer boot wait fixed ADF execution.
3. `screenshot save` produced 0 bytes when sent after debugger sessions — fixed by relaunching for visual capture.

See [`../vamiga.md`](../vamiga.md) for the full automation flow.

**Run emulator validation:**

```bash
touch /private/tmp/AMIGA_RUN_COMPLEX_BLITTER_VAMIGA_SMOKE
echo "$HOME/Desktop/Quarantine_Miga/roms" > /private/tmp/AMIGA_SMOKE_ROM_DIR
# Requires KS 2.x/3.1 for A500 — KS 1.3 ROMs are excluded by smoke hardware picker
./evaluate_model_quality.sh --vamiga
```

Prior documented smoke results (basic routed prompts: copper bars, starfield, sprite, color-cycling text) show **100% pass** on compile + semantic + ADF for the integrated path (`README.md`). vAmiga execution evidence is now confirmed for the blitter BOB benchmark family.

---

## 3. Follow-Up & Edit Robustness

### Multi-turn chains (XCTest)

| Family | Follow-up compiles | Model preserved | Rejected turns no-mutate |
|--------|:------------------:|:---------------:|:------------------------:|
| Blitter BOB collision | PASS | PASS | PASS |
| Copper raster bars | PASS | PASS | PASS |
| Mouse sprite multiplex | PASS | PASS | PASS |
| MOD player controls | PASS | PASS | — |
| Intuition window tool | PASS | PASS | PASS |
| Clean takeover restore | PASS | PASS | — |

### Golden source artifacts

| Metric | Result |
|--------|--------|
| Follow-up terminal sources | **7/7 families** |
| `@amiga:model` region preserved in follow-ups | **7/7 (100%)** |
| Follow-up replay gaps | **0** |

Representative chain behavior:

- **Round 1:** Add controls (e.g., Volume Up) — model JSON and dispatch markers updated.
- **Round 2:** Rename/reposition (e.g., Stop → Halt) — coordinates adjust without overlap.
- **Round 3:** Parameter edits — existing controls retained.
- **Rejected turns:** Ambiguous edits produce **no source mutation**.

---

## 4. Model Quality Scorecard

### A. Integrated producer path (template-routed)

| Category | Prompts | Syntax Pass | Semantic Pass | Follow-up Model |
|----------|--------:|------------:|--------------:|----------------:|
| Hardware Takeover | 2 | 100% | 100% | 100% |
| Intuition UI | 2 | 100% | 100% | 100% |
| Copper Effects | 1 | 100% | 100% | 100% |
| Blitter Animations | 2 | 100% | 100% | 100% |
| **Overall (7 families)** | **7** | **100%** | **100%** | **100%** |

Execution pass rate (vAmiga): **blitter BOB collision bounds PASS** (2026-06-19); other Goal 2 families not yet re-smoked with the 4.4 validator fixes.

### B. Raw model weights (`adapters_asm`, isolated generation)

| Category | N | Syntax (1st) | Semantic (1st) | Pass after repair |
|----------|--:|-------------:|---------------:|------------------:|
| Foundations | 8 | 25% | 38% | 50% |
| Hardware Takeover | 3 | 33% | 0% | 0% |
| Intuition UI | 2 | 50% | 0% | 0% |
| Copper Effects | 2 | 100% | 50% | 50% |
| Blitter Animations | 4 | 75% | 0% | 0% |
| **Overall** | **19** | **47%** | **21%** | **26%** |

---

## Most Common Failure Patterns

| Failure pattern | Raw model freq. | Recommended fix |
|-----------------|-----------------|-----------------|
| Non-canonical blitter busy wait | Very high | Train only `btst #6,$02(a6)` before/after `BLTSIZE` |
| Missing post-BLTSIZE wait | High | Pair every `BLTSIZE` with labeled busy-wait loop |
| Incomplete blitter setup | High | Full pointer-modulo-BLTSIZE sequences in curated data |
| Animated copper missing exit + frame updates | Medium | vblank-paced copper + `btst #6,$bfe001` exit |
| Invalid registers d8+ | Medium | Hard-negative training; strengthen semantic validator |
| Degenerate repetition (repeated `_Start`) | Medium | Bootblock-specific examples; cap `max_tokens` |
| Missing executable structure on complex prompts | Medium | Require `SECTION`/`XDEF`/`_Start` in every training record |
| Follow-up control loss | Low (integrated) | Continue corpus gym repair seeds |

---

## Priority Fine-Tuning Adjustments

1. **Blitter canonicalization sprint** — largest gap: 75% compile vs 0% semantic in Blitter Animations.
2. **Hardware takeover curriculum** — bitplane + sprite + interrupt scenarios need full DMA/copper/sprite pointer templates.
3. **Animated copper + input exit** — combine copper animation with mouse/CIA reads in single examples.
4. **Keep hybrid routing** — raw model is not safe for unsupported prompts; template router + `AmigaProgramModel` carries production quality.

---

## Next Steps (implemented)

| Action | Location |
|--------|----------|
| Repeatable evaluation orchestrator | `evaluate_model_quality.sh` |
| Scorecard aggregation | `generate_model_quality_scorecard.py` |
| Blitter-semantics training patches | `curated_asm_regressions.py` (copy/fill/masked-bob families) |
| vAmiga 4.4 RetroShell transport + debugger + boot fixes | `scripts/validate_emulator_runtime.py` (see `../vamiga.md`) |
| Rebuild train split after patches | `apply_blitter_semantics_patches.sh` |

---

## Reproduce

```bash
cd fine_tuning

# Full audit (corpus validators + ladder + XCTest + optional vAmiga)
./evaluate_model_quality.sh

# Raw model ladder only (requires MLX server on :1234)
uv run python eval_ladder.py \
  --base-url http://localhost:1234 \
  --model default_model \
  --adapter adapters_asm \
  --ladder asm_capability_ladder.yaml \
  --package-adf \
  --output evaluation_debug/asm_eval_ladder_summary.json

# Apply blitter patches and rebuild data_asm/train.jsonl
./apply_blitter_semantics_patches.sh
```