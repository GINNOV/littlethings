# Frozen Passing Baselines

These snapshots preserve known-good benchmark winners so the live mutation workspaces can keep evolving without losing a clean restore point.

Available snapshots:

- `pair_mutation_pass_0.999007`: passing source benchmark state driven by the standalone mutable Copper list.
- `asm_mutation_pass_1.000000`: passing source benchmark state driven by the inline assembly mutation workspace.

Each snapshot includes `metadata.json` with the benchmark config and recorded score.
