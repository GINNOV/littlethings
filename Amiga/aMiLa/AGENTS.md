# aMiLa — agent notes

## Layout

- `AmigaPlayground/` — native macOS SwiftUI editor (Xcode + SPM)
- `fine_tuning/` — MLX LoRA runtime / `uv` Python server (`serve_playground.py`)
- `scripts/setup-worktree.sh` — bootstrap after `git worktree add`

## Worktrees

`aMiLa` lives inside the **littlethings** monorepo. Multi-step agent work should use a linked worktree of littlethings, then bootstrap:

```bash
# from littlethings primary on master
git worktree add -b feat-amila-x ../littlethings-feat-amila-x master
cd ../littlethings-feat-amila-x
bash Amiga/aMiLa/scripts/setup-worktree.sh
# optional: COPY_RUNTIME=1  or  DOWNLOAD_MODEL=1
```

Cursor may run setup via `Amiga/aMiLa/.cursor/worktrees.json` (path is relative to monorepo root).

Do not run two MLX servers on port **1234** at once. Prefer one shared server from primary, or pick another port.

Xcode build products use `AMIGA_PLAYGROUND_BUILD_DIR` (set by the setup script) so parallel worktrees do not stomp the same DerivedData-style folder.

## Commands

```bash
# Swift app
cd Amiga/aMiLa/AmigaPlayground && bash script/build_and_run.sh

# Local model server
cd Amiga/aMiLa/fine_tuning && uv sync && uv run python serve_playground.py --port 1234
```
