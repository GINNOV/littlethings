#!/bin/sh

set -eu

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: current-evidence-dir.sh'
    exit 0
fi
[ "$#" -eq 0 ] || { printf '%s\n' 'Usage: current-evidence-dir.sh' >&2; exit 2; }

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
repo_root=$(git -C "$project_root" rev-parse --show-toplevel)
worktree_roots=$(git -C "$project_root" worktree list --porcelain | sed -n 's/^worktree //p')
candidate=${ARMAGEDDON_CURRENT_ATTEMPT_DIR:-}

validate_root() {
    root=$1
    [ "${root#/}" != "$root" ] || return 1
    [ ! -L "$root" ] || return 1
    canonical=$(CDPATH= cd -- "$root" && pwd -P) || return 1
    case "$canonical" in "$repo_root"|"$repo_root"/*|"$project_root"|"$project_root"/*) return 1 ;; esac
    old_ifs=$IFS
    IFS='
'
    for worktree in $worktree_roots; do
        case "$canonical" in "$worktree"|"$worktree"/*) IFS=$old_ifs; return 1 ;; esac
    done
    IFS=$old_ifs
    [ -z "$(find "$canonical" -mindepth 1 -maxdepth 1 -print -quit)" ] || return 1
    printf '%s\n' "$canonical"
}

if [ -n "$candidate" ]; then
    validate_root "$candidate" || { printf '%s\n' 'ERROR[invalid-attempt-root]' >&2; exit 2; }
else
    created=$(mktemp -d /private/tmp/armageddon-evidence.XXXXXX)
    chmod 700 "$created"
    validate_root "$created"
fi
