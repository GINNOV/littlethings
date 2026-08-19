#!/bin/sh

set -eu

usage='Usage: qa-final.sh <compliance|quality> ROOT | qa-final.sh <manual-fixture|scope> <begin|finalize> ROOT'
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then printf '%s\n' "$usage"; exit 0; fi
[ "$#" -ge 2 ] || { printf '%s\n' "$usage" >&2; exit 2; }
gate=$1
shift
case "$gate" in
    compliance|quality)
        [ "$#" -eq 1 ] || { printf '%s\n' "$usage" >&2; exit 2; }
        [ ! -e "$1/index.json" ] || { printf '%s\n' 'ERROR[index-exists]' >&2; exit 2; }
        printf '%s\n' "READY[$gate]: final gate ownership reserved for the complete plan"
        ;;
    manual-fixture|scope)
        [ "$#" -eq 2 ] || { printf '%s\n' "$usage" >&2; exit 2; }
        phase=$1
        root=$2
        case "$phase" in
            begin) mkdir -m 700 "$root" ;;
            finalize) [ -d "$root" ] && [ ! -e "$root/index.json" ] || { printf '%s\n' 'ERROR[invalid-finalize-root]' >&2; exit 2; } ;;
            *) printf '%s\n' "$usage" >&2; exit 2 ;;
        esac
        ;;
    *) printf '%s\n' "$usage" >&2; exit 2 ;;
esac
