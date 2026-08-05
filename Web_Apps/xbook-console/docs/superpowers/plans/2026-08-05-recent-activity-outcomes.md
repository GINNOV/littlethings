# Recent Activity Outcomes Implementation Plan

> **For agentic workers:** Execute task-by-task. Steps use checkbox syntax.

**Goal:** Show concrete outcome counts on dashboard Recent activity and Processing run list via a shared formatter.

**Architecture:** Pure `formatRunOutcome` in formatters; wire into two presentational components; unit-test the helper.

**Tech Stack:** TypeScript, Next.js, Vitest

---

### Task 1: Helper + unit tests

**Files:**
- Modify: `src/app/lib/formatters.ts`
- Create: `tests/unit/formatRunOutcome.test.ts`

- [ ] Implement `formatRunOutcome` per design rules
- [ ] Unit tests for completed/failed/running/notes/empty cases
- [ ] `npm test -- tests/unit/formatRunOutcome.test.ts`

### Task 2: Wire UI

**Files:**
- Modify: `src/app/components/dashboard/RecentActivity.tsx`
- Modify: `src/app/components/processing/RunTable.tsx`

- [ ] Replace `run.notes ?? "No details"` secondary line with `formatRunOutcome(run)`

### Task 3: Verify

- [ ] Run unit tests
- [ ] Lint touched files if needed
