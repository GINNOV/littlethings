#!/usr/bin/env bash
# littlethings monorepo worktree bootstrap.
# Always copies root env; bootstraps aMiLa when present.
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not inside a git repository" >&2
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
PRIMARY="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"

echo "==> littlethings worktree: $ROOT"
echo "==> Primary: $PRIMARY"

for f in .env .env.local; do
  if [[ -f "$PRIMARY/$f" && ! -f "$ROOT/$f" ]]; then
    cp "$PRIMARY/$f" "$ROOT/$f"
    echo "    copied $f"
  fi
done

if [[ -x "$ROOT/Amiga/aMiLa/scripts/setup-worktree.sh" ]]; then
  echo "==> aMiLa bootstrap"
  bash "$ROOT/Amiga/aMiLa/scripts/setup-worktree.sh"
elif [[ -f "$ROOT/Amiga/aMiLa/scripts/setup-worktree.sh" ]]; then
  bash "$ROOT/Amiga/aMiLa/scripts/setup-worktree.sh"
else
  echo "==> No Amiga/aMiLa/scripts/setup-worktree.sh — monorepo env only"
fi

echo "littlethings worktree setup done."
