# Recent activity outcome counts — Design

**Date:** 2026-08-05  
**Status:** Approved (Approach B)

## Problem

Dashboard **Recent activity** and the **Processing runs list** show only a humanized run type (e.g. “enrichment batch”) and raw `notes`. Enrichment finish notes are generic (`Completed.` / `Finished with N errors.`), so every source and run looks the same. Counters already exist on `OperationRun` (`total`, `processed`, `updated`, `failed`, `skipped`) but are unused in those UIs.

## Goal

At a glance, a run row answers “what happened?” via **outcome counts**, on:

1. Dashboard `RecentActivity`
2. Processing `RunTable`

## Approach (B)

Shared pure helper used by both surfaces. No schema changes. No rewriting of `notes` on write paths.

## Helper: `formatRunOutcome(run)`

**Location:** `src/app/lib/formatters.ts` (alongside existing display helpers)

**Input (minimal shape):**

```ts
type RunOutcomeInput = {
  status: string;
  total?: number | null;
  processed?: number | null;
  updated?: number | null;
  failed?: number | null;
  skipped?: number | null;
  notes?: string | null;
};
```

**Output:** single secondary-line string.

### Rules

1. Build segments from counters; omit zeros except when needed for progress.
2. **Updated** when `updated > 0`: `N updated`
3. **Failed** when `failed > 0`: `N failed`
4. **Skipped** when `skipped > 0`: `N skipped`
5. **Progress** when `total > 0` and (`status` is `running`/`queued` **or** no other success/fail segments yet): prefer `processed/total processed` (e.g. `12/50 processed`)
6. Join segments with ` · `
7. If no counter segments: use trimmed `notes` if present; else `No details`

### Examples

| Run state | Outcome line |
|-----------|--------------|
| Completed enrich: 18 updated, 2 failed | `18 updated · 2 failed` |
| Running: 12 processed of 50, 1 failed | `12/50 processed · 1 failed` |
| All zeros, notes `Completed.` | `Completed.` |
| Empty | `No details` |

## UI

| Component | Change |
|-----------|--------|
| `RecentActivity.tsx` | Secondary line = `formatRunOutcome(run)` |
| `RunTable.tsx` | Secondary line under type = `formatRunOutcome(run)` |

Title remains humanized `type` (`replaceAll("_", " ")` + capitalize). Date/status columns unchanged.

## Out of scope

- Rewriting notes in enrich/import APIs
- Category/tag content previews
- Source badges on dashboard (tab already filters)

## Testing

Unit tests for `formatRunOutcome` covering: completed with failures, running mid-batch, notes-only fallback, empty.

## Success criteria

- Enrichment rows show counts when available, not only “Completed.”
- Processing list and dashboard share the same wording
- Existing e2e that matches “enrichment batch” still passes (title unchanged)
