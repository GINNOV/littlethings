# Model Quality Scorecard

Generated: 2026-06-19 11:38 UTC

## Raw Model (`adapters_asm`)

- First-shot pass: **3/19**
- Pass after repair: **5/19**
- Promotion gate: **FAIL**

| Category | N | Syntax (1st) | Semantic (1st) | Pass after repair |
|---|--:|---:|---:|---:|
| Foundations | 8 | 25% | 38% | 50% |
| Hardware Takeover | 3 | 33% | 0% | 0% |
| Intuition UI | 2 | 50% | 0% | 0% |
| Copper Effects | 2 | 100% | 50% | 50% |
| Blitter Animations | 4 | 75% | 0% | 0% |

## Integrated Producer Path

| Check | Result |
|---|---|
| eval_ladder | skipped: --no-ladder |
| integrated_battery | pass |
| vamiga | pass (blitter BOB) |

## vAmiga Runtime

| Family | Success | Notes |
|---|---|---|
| blitter_bob_collision_bounds | True | xcodebuild smoke passed |

