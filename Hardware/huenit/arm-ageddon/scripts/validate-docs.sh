#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
for name in operator.md privacy.md safety.md model-k210.md contributor.md; do
    file="$project_root/docs/$name"
    [ -s "$file" ] || { printf 'ERROR[missing-doc]: %s\n' "$file" >&2; exit 1; }
done

for phrase in 'G28' 'physical power cutoff' 'Application Support' 'detection-only' 'cloud'; do
    rg -qi -- "$phrase" "$project_root/docs" || {
        printf 'ERROR[missing-document-contract]: %s\n' "$phrase" >&2
        exit 1
    }
done

printf '%s\n' 'PASS: documentation contract validated'
