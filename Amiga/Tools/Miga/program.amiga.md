# autoresearch-amiga

This is the Amiga 68k adaptation of autoresearch: instead of optimizing
`val_bpb` from ML training, optimize `score` from assembly + emulation checks.

## Scope

- Edit target: `amiga_workspace/main.s`
- Evaluator (fixed harness): `amiga_eval.py` and `amiga_eval.toml`
- Result log: `results_amiga.tsv`

Do not modify unrelated repository files during experiment runs.

## Setup

1. Pick a run tag (for example `mar11-amiga`).
2. Create a branch: `git checkout -b autoresearch-amiga/<tag>`.
3. Verify toolchain commands in `amiga_eval.toml` for this machine:
   - `[commands].assemble`
   - `[commands].emulate`
   - `[commands].verify`
   - `[paths].disk_template` (set to `amiga_workspace/adf/system_template.adf` if using a full system template ADF)
4. Ensure browser backend dependencies are present:
   - `npm install`
   - `npx playwright install chromium`
5. Run baseline once:
   - `python amiga_eval.py > run.log 2>&1`
   - `grep "^score:\|^assembled:\|^emulator_ok:\|^verify_ok:" run.log`
6. Ensure `results_amiga.tsv` has header and baseline row.

## Output format

Each evaluator run prints:

```text
---
score:              0.700000
assembled:          true
packaged:           true
emulator_ok:        true
verify_ok:          true
crash_detected:     false
checks_passed:      4
checks_total:       4
```

Higher `score` is better.

## Logging results

`results_amiga.tsv` is tab-separated with columns:

```text
commit	score	status	description
```

Use:

- `keep`: new best score
- `discard`: score did not improve
- `crash`: evaluator failed to produce a usable score

## Loop

LOOP FOREVER:

1. Inspect git state and identify current best kept commit.
2. Modify `amiga_workspace/main.s` with one experimental idea.
3. Commit:
   - `git add amiga_workspace/main.s`
   - `git commit -m "experiment: <description>"`
4. Run evaluator:
   - `python amiga_eval.py > run.log 2>&1`
5. Extract score:
   - `grep "^score:" run.log`
6. If score missing, inspect failure:
   - `tail -n 80 run.log`
   - record as `crash`, then revert to previous kept commit.
7. Append run to `results_amiga.tsv`.
8. Keep or revert:
   - if score improved: keep commit and amend in updated TSV entry
   - else: revert to previous kept commit

## Strategy focus

Prioritize deterministic, hardware-valid behavior:

- Correct 68000 syntax and addressing modes.
- Safe interactions with Amiga custom chips (Copper/Blitter/interrupt/DMA).
- Explicit guardrails against crash conditions (invalid vectors, bad memory writes).
- Stable boot markers and memory signatures to feed evaluator checks.

The evaluator can only optimize what it can observe. Tighten checks over time.
