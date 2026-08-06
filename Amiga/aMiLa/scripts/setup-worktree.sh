#!/usr/bin/env bash
# Bootstrap an aMiLa worktree: Swift playground + fine_tuning (uv).
#
# From a littlethings worktree root:
#   bash Amiga/aMiLa/scripts/setup-worktree.sh
# From Amiga/aMiLa:
#   bash scripts/setup-worktree.sh
#
# Env:
#   SKIP_INSTALL=1     skip uv sync / swift package resolve
#   DOWNLOAD_MODEL=1   run fine_tuning/download_model.sh (large)
#   COPY_RUNTIME=1     copy primary runtime/base+adapter if present (large)
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not inside a git repository" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AMILA_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
PRIMARY="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"

# Resolve aMiLa path on primary (same relative path under monorepo)
REL_AMILA="${AMILA_ROOT#"$REPO_ROOT"/}"
PRIMARY_AMILA="$PRIMARY/$REL_AMILA"
if [[ ! -d "$PRIMARY_AMILA" ]]; then
  PRIMARY_AMILA="$PRIMARY"
fi

echo "==> aMiLa root: $AMILA_ROOT"
echo "==> Repo root:  $REPO_ROOT"
echo "==> Primary:    $PRIMARY"
echo "==> Primary aMiLa: $PRIMARY_AMILA"

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ -e "$src" && ! -e "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp -R "$src" "$dest"
    echo "    copied $(basename "$dest")"
  fi
}

echo "==> Env / local config (copy, never symlink)"
for f in .env .env.local .env.development.local; do
  copy_if_missing "$PRIMARY_AMILA/$f" "$AMILA_ROOT/$f"
  copy_if_missing "$PRIMARY/$f" "$REPO_ROOT/$f"
done
copy_if_missing "$PRIMARY_AMILA/fine_tuning/.env" "$AMILA_ROOT/fine_tuning/.env"
copy_if_missing "$PRIMARY_AMILA/fine_tuning/.env.local" "$AMILA_ROOT/fine_tuning/.env.local"

# Per-worktree Xcode build dir so parallel worktrees don't clobber each other
export AMIGA_PLAYGROUND_BUILD_DIR="${AMIGA_PLAYGROUND_BUILD_DIR:-${TMPDIR:-/tmp}/amiga-playground-build-$(basename "$REPO_ROOT")}"
echo "    AMIGA_PLAYGROUND_BUILD_DIR=$AMIGA_PLAYGROUND_BUILD_DIR"

if [[ "${SKIP_INSTALL:-}" != "1" ]]; then
  if [[ -f "$AMILA_ROOT/fine_tuning/pyproject.toml" ]]; then
    echo "==> fine_tuning: uv sync"
    if command -v uv >/dev/null 2>&1; then
      (cd "$AMILA_ROOT/fine_tuning" && uv sync)
    else
      echo "    warning: uv not found — install from https://docs.astral.sh/uv/ then re-run"
    fi
  fi

  if [[ -f "$AMILA_ROOT/AmigaPlayground/Package.swift" ]] && command -v swift >/dev/null 2>&1; then
    echo "==> AmigaPlayground: swift package resolve"
    (cd "$AMILA_ROOT/AmigaPlayground" && swift package resolve) || \
      echo "    warning: swift package resolve failed (Xcode open still works for app target)"
  fi
else
  echo "==> Skipping package installs (SKIP_INSTALL=1)"
fi

if [[ "${COPY_RUNTIME:-}" == "1" ]]; then
  echo "==> Copying fine_tuning runtime from primary (COPY_RUNTIME=1)"
  for part in base adapter; do
    src="$PRIMARY_AMILA/fine_tuning/runtime/$part"
    dest="$AMILA_ROOT/fine_tuning/runtime/$part"
    if [[ -d "$src" && ! -d "$dest" ]]; then
      mkdir -p "$AMILA_ROOT/fine_tuning/runtime"
      cp -R "$src" "$dest"
      echo "    copied runtime/$part"
    fi
  done
  copy_if_missing \
    "$PRIMARY_AMILA/fine_tuning/runtime/model_version.json" \
    "$AMILA_ROOT/fine_tuning/runtime/model_version.json"
fi

if [[ "${DOWNLOAD_MODEL:-}" == "1" ]]; then
  if [[ -x "$AMILA_ROOT/fine_tuning/download_model.sh" ]]; then
    echo "==> Downloading model (DOWNLOAD_MODEL=1)"
    (cd "$AMILA_ROOT/fine_tuning" && ./download_model.sh)
  else
    echo "    warning: fine_tuning/download_model.sh missing or not executable"
  fi
elif [[ ! -d "$AMILA_ROOT/fine_tuning/runtime/base" ]]; then
  echo "==> Model weights not present (runtime/base missing)."
  echo "    Later: cd fine_tuning && ./download_model.sh"
  echo "    Or:    COPY_RUNTIME=1 bash scripts/setup-worktree.sh"
fi

echo ""
echo "aMiLa worktree ready."
echo "  Playground:  open Amiga/aMiLa/AmigaPlayground/AmigaPlayground.xcodeproj"
echo "  Or build:    cd Amiga/aMiLa/AmigaPlayground && bash script/build_and_run.sh"
echo "  Fine-tune:   cd Amiga/aMiLa/fine_tuning && uv run python serve_playground.py --port 1234"
echo "  Note: only one process can bind port 1234 across worktrees."
