#!/bin/bash
#
# Definitive Amiga Environment Check Script (v4)
#
# This script validates the complete Amiga cross-development environment, including:
# - The vbcc toolchain installation.
# - The 'amigavc' alias to resolve naming conflicts.
# - The Amiga NDK 3.9 installation and integration.
#

# --- Color Definitions for Output ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_BOLD='\033[1m'

# --- Helper Functions ---
print_header() {
    echo -e "\n${C_BLUE}${C_BOLD}--- $1 ---${C_RESET}"
}

print_status() {
    local status=$1
    local message=$2
    if [ "$status" -eq 0 ]; then
        echo -e "  [${C_GREEN}✔${C_RESET}] ${message}"
    else
        echo -e "  [${C_RED}✘${C_RESET}] ${message}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# --- Script Start ---
FAIL_COUNT=0
clear
echo -e "${C_BOLD}Definitive Amiga Environment Sanity Check (v4)${C_RESET}"

# --- 1. Check Core Environment ---
print_header "Step 1: Checking Core Environment"

if [ -z "$VBCC" ]; then
    print_status 1 "\$VBCC environment variable is NOT set."
    exit 1
else
    print_status 0 "\$VBCC is set to: ${C_YELLOW}$VBCC${C_RESET}"
fi

if [[ ":$PATH:" != *":$VBCC/bin:"* ]]; then
    print_status 1 "\$VBCC/bin is NOT in your \$PATH."
else
    print_status 0 "\$VBCC/bin is in your \$PATH."
fi

# --- 2. Check for 'amigavc' Alias ---
print_header "Step 2: Checking for 'amigavc' Alias"
if alias amigavc &> /dev/null; then
    print_status 0 "Alias 'amigavc' is correctly defined."
    AMIGAVC_COMMAND="amigavc"
else
    print_status 1 "Alias 'amigavc' is NOT defined. Cannot proceed."
    echo -e "    ${C_YELLOW}Ensure your .zshrc contains: alias amigavc=\"/opt/vbcc/bin/vc -I/opt/amiga-ndk-3.9/include_h\"${C_RESET}"
    exit 1
fi

# --- 3. Check NDK Installation ---
print_header "Step 3: Checking NDK Installation"
NDK_PATH="/opt/amiga-ndk-3.9"
if [ -d "$NDK_PATH/include_h" ]; then
    print_status 0 "Amiga NDK found at: ${C_YELLOW}$NDK_PATH${C_RESET}"
else
    print_status 1 "Amiga NDK not found at the expected location."
    echo -e "    ${C_YELLOW}Please ensure you have installed the NDK to '$NDK_PATH'.${C_RESET}"
fi

# --- 4. Perform Live Compilation Tests ---
print_header "Step 4: Performing Live Compilation Tests (using 'amigavc')"

TEST_DIR=$(mktemp -d)
echo -e "  Using temporary directory: ${C_YELLOW}$TEST_DIR${C_RESET}"
cd "$TEST_DIR" || exit

# --- C Compilation Test (with NDK include) ---
echo -e "\n  ${C_BOLD}Attempting to compile a C program that uses the NDK...${C_RESET}"
cat > test_c.c << EOF
#include <proto/dos.h>
#include <proto/exec.h>

struct Library *DOSBase;

int main(void) {
    DOSBase = OpenLibrary("dos.library", 37);
    if (DOSBase) {
        Write(Output(), "Hello from C!\\n", 14);
        CloseLibrary(DOSBase);
    }
    return 0;
}
EOF

$AMIGAVC_COMMAND -o test_c_prog -lamiga test_c.c &> build_c.log
if [ $? -eq 0 ] && [ -f "test_c_prog" ]; then
    print_status 0 "C program compiled successfully."
else
    print_status 1 "C program compilation FAILED."
    echo -e "    ${C_RED}Check the log file for details: ${C_YELLOW}${TEST_DIR}/build_c.log${C_RESET}"
fi

# --- Assembly Compilation Test ---
echo -e "\n  ${C_BOLD}Attempting to compile an Assembly program...${C_RESET}"
cat > test_asm.s << EOF
    INCLUDE "exec/exec.i"
    INCLUDE "dos/dos.i"

start:
    move.l  4.w,a6
    lea     dosName(pc),a1
    jsr     _LVOOldOpenLibrary(a6)
    move.l  d0,a6
    beq.s   fail

    lea     helloStr(pc),a1
    move.l  a1,d1
    jsr     _LVOOutput(a6)
    move.l  d0,d2
    move.l  #18,d3
    jsr     _LVOWrite(a6)

    move.l  a6,a1
    move.l  4.w,a6
    jsr     _LVOCloseLibrary(a6)

fail:
    moveq   #0,d0
    rts

dosName:
    dc.b    'dos.library',0
helloStr:
    dc.b    'Hello from ASM!\\n',0
    even
EOF

$AMIGAVC_COMMAND -o test_asm_prog -lamiga test_asm.s &> build_asm.log
if [ $? -eq 0 ] && [ -f "test_asm_prog" ]; then
    print_status 0 "Assembly program compiled successfully."
else
    print_status 1 "Assembly program compilation FAILED."
    echo -e "    ${C_RED}Check the log file for details: ${C_YELLOW}${TEST_DIR}/build_asm.log${C_RESET}"
fi

# --- Cleanup ---
cd ..
rm -rf "$TEST_DIR"
echo -e "\n  Cleaned up temporary directory."

# --- 5. Final Summary ---
print_header "Step 5: Final Summary"
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "\n${C_GREEN}${C_BOLD}🎉 CONGRATULATIONS! Your Amiga development environment is fully configured and working.${C_RESET}"
else
    echo -e "\n${C_RED}${C_BOLD}🔥 Found $FAIL_COUNT issue(s). Please review the errors above.${C_RESET}"
fi
echo ""
