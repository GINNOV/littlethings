#!/bin/bash
#
# Definitive Amiga Environment Check Script (Final)
#
# Validates the complete Amiga cross-development environment by checking
# for the existence of all required files and performing live compilations
# without depending on the user's shell configuration.
#

set -euo pipefail

# --- Configuration ---
INSTALL_DIR="/opt/vbcc"
NDK_INSTALL_DIR="/opt/amiga-ndk-3.9"

# --- Color Definitions for Output ---
C_RESET=$'\033[0m'
C_RED=$'\033[0;31m'
C_GRN=$'\033[0;32m'
C_YEL=$'\033[0;33m'
C_BLUE=$'\033[0;34m'
C_BOLD=$'\033[1m'

# --- Helper Functions ---
print_header(){ printf "\n%s--- %s ---%s\n" "$C_BLUE$C_BOLD" "$1" "$C_RESET"; }
print_status(){
  local status=$1 message=$2
  if [ "$status" -eq 0 ]; then
    printf "  [%s✔%s] %b\n" "$C_GRN" "$C_RESET" "$message"
  else
    printf "  [%s✘%s] %b\n" "$C_RED" "$C_RESET" "$message"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# --- Script Start ---
FAIL_COUNT=0
clear
echo -e "${C_BOLD}Definitive Amiga Environment Sanity Check (Final)${C_RESET}"

# --- 1) Check Core File System Layout ---
print_header "Step 1: Verifying File & Directory Structure"
if [ ! -d "$INSTALL_DIR" ]; then
    print_status 1 "Toolchain directory NOT found at '$INSTALL_DIR'."
    exit 1
fi
print_status 0 "Toolchain root directory found at ${C_YEL}$INSTALL_DIR${C_RESET}"

for tool in vc vlink vasmm68k_mot; do
    if [ -x "$INSTALL_DIR/bin/$tool" ]; then
        print_status 0 "Found executable: ${C_YEL}$INSTALL_DIR/bin/$tool${C_RESET}"
    else
        print_status 1 "Executable NOT found: ${C_YEL}$INSTALL_DIR/bin/$tool${C_RESET}"
    fi
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

if [ -n "$NDK_INC_DIR_H" ]; then
  print_status 0 "Amiga NDK C include dir: ${C_YEL}$NDK_INC_DIR_H${C_RESET}"
else
  print_status 1 "Could not find ${C_YEL}Include/include_h${C_RESET} in '$NDK_INSTALL_DIR'"
fi

if [ -n "$NDK_INC_DIR_I" ]; then
  print_status 0 "Amiga NDK asm include dir: ${C_YEL}$NDK_INC_DIR_I${C_RESET}"
else
  print_status 1 "Could not find ${C_YEL}Include/include_i${C_RESET} in '$NDK_INSTALL_DIR'"
fi

if [ -z "$NDK_INC_DIR_H" ] || [ -z "$NDK_INC_DIR_I" ]; then
  printf "%s%sEnvironment incomplete; aborting.%s\n" "$C_RED" "$C_BOLD" "$C_RESET"
  exit 1
fi

# --- 2) Perform Live Compilation Tests ---
print_header "Step 2: Performing Live Compilation Tests"

COMPILER_COMMAND="$INSTALL_DIR/bin/vc +aos68k -I$NDK_INC_DIR_H -I$NDK_INC_DIR_I"

TEST_DIR="$(mktemp -d -t amiga-test-XXXXXX)"
trap 'rm -rf "$TEST_DIR"' EXIT
echo -e "  Using temporary directory: ${C_YEL}$TEST_DIR${C_RESET}"
pushd "$TEST_DIR" >/dev/null

# C Test
cat > test.c << EOF
#include <proto/dos.h>
int main(void) {
    const char *msg = "Hello from C!\n";
    Write(Output(), msg, 15);
    return 0;
}
EOF
if VBCC="$INSTALL_DIR" $COMPILER_COMMAND -o test_c_prog -lamiga test.c &> build_c.log; then
    print_status 0 "C program compiled successfully."
else
    print_status 1 "C program compilation FAILED. Check log: ${TEST_DIR}/build_c.log"
fi

# Assembly Test
cat > test.s << EOF
    INCLUDE "exec/exec.i"
    INCLUDE "dos/dos.i"
start:
    move.l  4.w,a6
    lea     dosName(pc),a1
    jsr     _LVOOldOpenLibrary(a6) ; d0 = DOSBase
    move.l  d0,a6                  ; a6 = DOSBase
    beq.s   fail

    jsr     _LVOOutput(a6)         ; d0 = current output FH (BPTR)
    move.l  d0,d1                  ; D1 = FH
    lea     helloStr(pc),a0
    move.l  a0,d2                  ; D2 = buffer
    move.l  #helloStrEnd-helloStr,d3 ; D3 = length
    jsr     _LVOWrite(a6)
fail:
    moveq   #0,d0
    rts

dosName:    dc.b 'dos.library',0
helloStr:   dc.b 'Hello from Assembly!',10  ; 10 = '\n'
helloStrEnd:
    even
EOF
if VBCC="$INSTALL_DIR" $COMPILER_COMMAND -o test_asm_prog -lamiga test.s &> build_asm.log; then
    print_status 0 "Assembly program compiled successfully."
else
    print_status 1 "Assembly program compilation FAILED. Check log: ${TEST_DIR}/build_asm.log"
fi
popd >/dev/null

# --- 3) Final Summary ---
print_header "Step 3: Final Summary"
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "\n${C_GRN}${C_BOLD}🎉 CONGRATULATIONS! Your Amiga development environment is fully configured and working.${C_RESET}"
else
    echo -e "\n${C_RED}${C_BOLD}🔥 Found $FAIL_COUNT issue(s). Please review the errors above.${C_RESET}"
fi
echo ""
