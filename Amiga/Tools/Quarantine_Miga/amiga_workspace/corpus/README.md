# Amiga Corpus Workflow

## Layout

- `amiga_workspace/corpus/raw/` - original source trees (can include nested repos/subfolders)
- `amiga_workspace/corpus/curated/` - filtered assembly-like files copied from raw
- `amiga_workspace/corpus/manifest.tsv` - index generated from curated entries
- `amiga_workspace/corpus/manifest_runnable.tsv` - subset that assembles and exits cleanly under `vamos`

## Build/refresh curated index

```bash
python3 amiga_workspace/corpus/scripts/index_raw_sources.py --refresh
```

## Select one source into `amiga_workspace/main.s`

Random selection:

```bash
python3 amiga_workspace/corpus/scripts/select_source.py
```

Filtered selection (example):

```bash
python3 amiga_workspace/corpus/scripts/select_source.py --contains "bootblock"
```

Pinned entry by manifest index:

```bash
python3 amiga_workspace/corpus/scripts/select_source.py --index 42
```

One-step helper (build manifest if missing, then select):

```bash
amiga_workspace/corpus/scripts/pick_for_run.sh --seed 1
```

Selection metadata is written to `build/amiga/selected_source.json`.

By default, selection uses `manifest_runnable.tsv` (if present) so picked files
already satisfy assemble + `vamos` exit-zero checks. If runnable manifest is not
available yet, it falls back to `manifest.tsv`.

## Build runnable manifest (strict verify pool)

```bash
python3 amiga_workspace/corpus/scripts/build_runnable_manifest.py
```

This validates each candidate from `manifest.tsv` by running:

1. `vasmm68k_mot` assemble step
2. `vamos` verify step (must exit `0`)

Outputs:

- `amiga_workspace/corpus/manifest_runnable.tsv`
- `amiga_workspace/corpus/manifest_runnable_report.json`

If `manifest_runnable.tsv` has only the header row, the current corpus has no
strict verify-clean candidates yet.
