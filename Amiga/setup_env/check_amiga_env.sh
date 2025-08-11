#!/bin/bash
#
# Definitive Amiga Environment Check Script (Final, clean linking)
#
# Validates the Amiga m68k cross-dev env using vbcc/vlink/vasm + NDK.
# - Only calls `vc +aos68k` (no manual vlink, no startup/minstart juggling)
# - Injects a temporary `delete` shim so vbcc's -rm=delete works on POSIX hosts
#

set -euo pipefail

# --- Configuration ---
INSTALL_DIR="/opt/vbcc"
NDK_INSTALL_DIR="/opt/amiga-ndk-3.9"

# --- Color Output ---
C_RESET=$'\033[0m'
C_RED=$'\033[0;31m'
C_GRN=$'\033[0;32m'
C_YEL=$'\033[0;33m'
C_BLU=$'\033[0;34m'
C_BOLD=$'\033[1m'

print_header(){ printf "\n%s%s--- %s ---%s\n" "$C_BLU" "$C_BOLD" "$1" "$C_RESET"; }
print_status(){
  local ok=$1; shift
  if [ "$ok" -eq 0 ]; then
    printf "  [%s✔%s] %b\n" "$C_GRN" "$C_RESET" "$*"
  else
    printf "  [%s✘%s] %b\n" "$C_RED" "$C_RESET" "$*"
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
}

FAIL_COUNT=0
clear || true
echo -e "${C_BOLD}Definitive Amiga Environment Sanity Check (Final)${C_RESET}"

# --- Step 1: FS layout ---
print_header "Step 1: Verifying File & Directory Structure"

if [ ! -d "$INSTALL_DIR" ]; then
  print_status 1 "Toolchain directory NOT found at '$INSTALL_DIR'."
  exit 1
fi
print_status 0 "Toolchain root directory found at ${C_YEL}$INSTALL_DIR${C_RESET}"

for t in vc vlink vasmm68k_mot; do
  [ -x "$INSTALL_DIR/bin/$t" ] \
    && print_status 0 "Found executable: ${C_YEL}$INSTALL_DIR/bin/$t${C_RESET}" \
    || print_status 1 "Executable NOT found: ${C_YEL}$INSTALL_DIR/bin/$t${C_RESET}"
done

if [ -f "$INSTALL_DIR/config/aos68k" ]; then
  print_status 0 "vbcc target config found: ${C_YEL}$INSTALL_DIR/config/aos68k${C_RESET}"
else
  print_status 1 "vbcc target config NOT found: ${C_YEL}$INSTALL_DIR/config/aos68k${C_RESET}"
fi

if [ ! -d "$NDK_INSTALL_DIR" ]; then
  print_status 1 "NDK directory NOT found at '$NDK_INSTALL_DIR'."
  exit 1
fi
print_status 0 "NDK root directory found at ${C_YEL}$NDK_INSTALL_DIR${C_RESET}"

NDK_INC_DIR_H="$(find "$NDK_INSTALL_DIR" -type d -path '*/Include/include_h' | head -n1 || true)"
NDK_INC_DIR_I="$(find "$NDK_INSTALL_DIR" -type d -path '*/Include/include_i' | head -n1 || true)"

[ -n "$NDK_INC_DIR_H" ] \
  && print_status 0 "Amiga NDK C include dir: ${C_YEL}$NDK_INC_DIR_H${C_RESET}" \
  || print_status 1 "Could not find ${C_YEL}Include/include_h${C_RESET} in '$NDK_INSTALL_DIR'"

[ -n "$NDK_INC_DIR_I" ] \
  && print_status 0 "Amiga NDK asm include dir: ${C_YEL}$NDK_INC_DIR_I${C_RESET}" \
  || print_status 1 "Could not find ${C_YEL}Include/include_i${C_RESET} in '$NDK_INSTALL_DIR'"

if [ -z "${NDK_INC_DIR_H:-}" ] || [ -z "${NDK_INC_DIR_I:-}" ]; then
  printf "%s%sEnvironment incomplete; aborting.%s\n" "$C_RED" "$C_BOLD" "$C_RESET"
  exit 1
fi

# --- Step 2: Live build tests ---
print_header "Step 2: Performing Live Compilation Tests"

# vc driver (let +aos68k control compile & link)
VC_CMD="$INSTALL_DIR/bin/vc +aos68k -I$NDK_INC_DIR_H -I$NDK_INC_DIR_I"

TEST_DIR="$(mktemp -d -t amiga-test-XXXXXX)"
echo -e "  Using temporary directory: ${C_YEL}$TEST_DIR${C_RESET}"

# Create a PATH shim for 'delete' (vbcc config may specify -rm=delete)
SHIM_DIR="$TEST_DIR/shim"
mkdir -p "$SHIM_DIR"
cat > "$SHIM_DIR/delete" <<'SH'
#!/usr/bin/env bash
# vbcc uses "delete" in some target configs; map it to rm -f on POSIX hosts
exec rm -f "$@"
SH
chmod +x "$SHIM_DIR/delete"

export PATH="$SHIM_DIR:$INSTALL_DIR/bin:$PATH"
export VBCC="$INSTALL_DIR"

pushd "$TEST_DIR" >/dev/null

# --- C test ---
cat > test.c << 'EOF'
#include <proto/dos.h>
int main(void) {
    const char *msg = "Hello from C!\n";
    Write(Output(), msg, 15);
    return 0;
}
EOF

if $VC_CMD test.c -lamiga -o test_c_prog &> build_c.log; then
  print_status 0 "C build & link succeeded."
else
  print_status 1 "C build FAILED. Log:"
  sed -n '1,120p' build_c.log
fi

# --- ASM test (export _main so vc's C runtime is satisfied) ---
cat > test.s << 'EOF'
    INCLUDE "exec/exec.i"
    INCLUDE "dos/dos.i"

    XDEF _main
_main:
    move.l  4.w,a6
    lea     dosName(pc),a1
    jsr     _LVOOldOpenLibrary(a6) ; DOSBase in d0
    move.l  d0,a6
    beq.s   fail

    jsr     _LVOOutput(a6)         ; d0 = BPTR to current output
    move.l  d0,d1                  ; D1 = file handle
    lea     helloStr(pc),a0
    move.l  a0,d2                  ; D2 = buffer
    move.l  #helloStrEnd-helloStr,d3 ; D3 = length
    jsr     _LVOWrite(a6)

fail:
    moveq   #0,d0                  ; return 0
    rts

dosName:    dc.b 'dos.library',0
helloStr:   dc.b 'Hello from Assembly!',10
helloStrEnd:
    even
EOF

# Let vc drive as;ld as per +aos68k
if $VC_CMD test.s -lamiga -o test_asm_prog &> build_asm.log; then
  print_status 0 "ASM build & link succeeded."
else
  print_status 1 "ASM build FAILED. Log:"
  sed -n '1,160p' build_asm.log
fi

popd >/dev/null

# --- Step 3: Summary ---
print_header "Step 3: Final Summary"
if [ "$FAIL_COUNT" -eq 0 ]; then
  echo -e "\n${C_GRN}${C_BOLD}🎉 All good! Your Amiga m68k cross-environment is working.${C_RESET}\n"
else
  echo -e "\n${C_RED}${C_BOLD}🔥 Found $FAIL_COUNT issue(s).${C_RESET}"
  echo -e "Logs kept at: ${C_YEL}$TEST_DIR${C_RESET}\n"
fi