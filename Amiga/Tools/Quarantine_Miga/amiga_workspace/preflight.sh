#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FS_UAE_BIN="/Applications/FS-UAE.app/Contents/MacOS/fs-uae"
VASM_BIN="/usr/local/bin/vasmm68k_mot"
AMITOOLS_BIN="$HOME/.venv/bin"
FSUAE_DIR="$HOME/Documents/FS-UAE"
FSUAE_LOG="$FSUAE_DIR/Cache/Logs/fs-uae.log.txt"
KICK_DIR="$FSUAE_DIR/Kickstarts"
DEFAULT_CFG="$FSUAE_DIR/Configurations/Default.fs-uae"

ok() { printf "  [ok] %s\n" "$1"; }
warn() { printf "  [warn] %s\n" "$1"; }
fail() { printf "  [fail] %s\n" "$1"; }

echo "Amiga autoresearch preflight"
echo "workspace: $ROOT_DIR"
echo

if [[ -x "$VASM_BIN" ]]; then
  ok "assembler found: $VASM_BIN"
else
  fail "assembler missing: $VASM_BIN"
fi

if [[ -x "$FS_UAE_BIN" ]]; then
  ok "emulator found: $FS_UAE_BIN"
else
  fail "emulator missing: $FS_UAE_BIN"
fi

if [[ -x "$AMITOOLS_BIN/xdftool" ]]; then
  ok "amitools xdftool found: $AMITOOLS_BIN/xdftool"
else
  warn "xdftool not found in $AMITOOLS_BIN"
fi

if [[ -f "$DEFAULT_CFG" ]]; then
  ok "FS-UAE default config present: $DEFAULT_CFG"
  if rg -q "main\\.adf" "$DEFAULT_CFG"; then
    ok "Default config points at generated ADF"
  else
    warn "Default config does not reference main.adf yet"
  fi
else
  warn "FS-UAE default config missing: $DEFAULT_CFG"
  warn "Install with: cp amiga_workspace/Default.fs-uae \"$DEFAULT_CFG\""
fi

if [[ -x "$AMITOOLS_BIN/vamos" ]]; then
  if "$AMITOOLS_BIN/vamos" --help >/tmp/miga-vamos-help.txt 2>&1; then
    ok "vamos runnable"
  else
    if rg -q "machine68k" /tmp/miga-vamos-help.txt 2>/dev/null; then
      warn "vamos present but machine68k is missing in the .venv"
    else
      warn "vamos present but failed to run"
    fi
  fi
else
  warn "vamos not found in $AMITOOLS_BIN"
fi

if [[ -d "$KICK_DIR" ]]; then
  ROM_COUNT=$(find "$KICK_DIR" -maxdepth 1 -type f \( -iname "*.rom" -o -iname "*.bin" \) | wc -l | tr -d ' ')
  if [[ "$ROM_COUNT" -gt 0 ]]; then
    ok "kickstart ROMs found ($ROM_COUNT files)"
  else
    warn "no ROMs found (AROS ROM fallback may be used)"
  fi
else
  warn "kickstart dir missing: $KICK_DIR"
fi

if [[ -f "$FSUAE_LOG" ]]; then
  ok "fs-uae log path exists: $FSUAE_LOG"
else
  warn "fs-uae log not created yet: $FSUAE_LOG"
fi

echo
echo "Next command:"
echo "  python3 $ROOT_DIR/amiga_eval.py"
