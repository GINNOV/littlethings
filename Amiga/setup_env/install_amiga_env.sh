#!/bin/bash
#
# Definitive Amiga Environment Automated Installer (macOS)
# - Builds vasm, vlink, vbcc (m68k) from source
# - Installs vbcc m68k-amigaos target + AmigaOS 3.9 NDK
# - Sets up PATH + handy aliases
#
# Idempotent, with robust error handling.
#

set -euo pipefail

# --- Configuration ---
INSTALL_DIR="/opt/vbcc"
NDK_INSTALL_DIR="/opt/amiga-ndk-3.9"

VBCC_URL="http://www.ibaug.de/vbcc/vbcc.tar.gz"
VASM_URL="http://sun.hasenbraten.de/vasm/release/vasm.tar.gz"
VLINK_URL="http://sun.hasenbraten.de/vlink/release/vlink.tar.gz"
TARGET_URL="https://aminet.net/dev/c/vbcc_target_m68k-amiga.lha"
NDK_URL="https://fsck.technology/software/Commodore/Amiga/Amiga%20Applications/AmigaOS%203.9%20Native%20Development%20Kit/NDK39.lha"

# Colors
C_RESET=$'\033[0m'; C_RED=$'\033[0;31m'; C_GRN=$'\033[0;32m'; C_YEL=$'\033[0;33m'; C_BLU=$'\033[0;34m'; C_BOLD=$'\033[1m'

print_header(){ echo -e "\n${C_BLU}${C_BOLD}--- $1 ---${C_RESET}"; }

clear
echo -e "${C_BOLD}Starting the Definitive Amiga Environment From-Source Installation...${C_RESET}"

# --- 1) Prereqs & temp workspace ---
print_header "Step 1: Checking Prerequisites"

if ! xcode-select -p &>/dev/null; then
  echo -e "${C_RED}Command Line Tools not found. Run: xcode-select --install${C_RESET}"
  exit 1
fi

# Prefer lhasa (provides the `lha` command)
if ! command -v lha &>/dev/null; then
  echo -e "${C_YEL}Installing lhasa (provides 'lha') via Homebrew...${C_RESET}"
  if ! command -v brew &>/dev/null; then
    echo -e "${C_RED}Homebrew not found. Install Homebrew or manually install lhasa, then re-run.${C_RESET}"
    exit 1
  fi
  brew install lhasa
fi

sudo -v

# Temp workspace
WORKDIR="$(mktemp -d -t amigaenv-XXXXXX)"
trap 'rm -rf "$WORKDIR"' EXIT
cd "$WORKDIR"
echo -e "${C_GRN}Prerequisites met. Using temporary workspace: $WORKDIR${C_RESET}"

# --- 2) Prepare install roots ---
print_header "Step 2: Preparing Directories"
sudo mkdir -p "$INSTALL_DIR/bin" "$INSTALL_DIR/config" "$INSTALL_DIR/targets" "$NDK_INSTALL_DIR"
echo -e "${C_GRN}Install roots ensured.${C_RESET}"

# --- 3) Downloads ---
print_header "Step 3: Downloading All Component Archives"
curl -fL --retry 3 -o vbcc.tar.gz   "$VBCC_URL"
curl -fL --retry 3 -o vasm.tar.gz   "$VASM_URL"
curl -fL --retry 3 -o vlink.tar.gz  "$VLINK_URL"
curl -fL --retry 3 -o target.lha    "$TARGET_URL"
curl -fL --retry 3 -o ndk.lha       "$NDK_URL"
echo -e "${C_GRN}All downloads complete.${C_RESET}"

# --- 4) Build + install vasm/vlink/vbcc ---
print_header "Step 4: Building and Installing Components"

# vasm
if [ ! -x "$INSTALL_DIR/bin/vasmm68k_mot" ]; then
  if command -v vasmm68k_mot >/dev/null 2>&1; then
    echo "vasm found in PATH; linking into $INSTALL_DIR/bin"
    sudo ln -sfn "$(command -v vasmm68k_mot)" "$INSTALL_DIR/bin/vasmm68k_mot"
    command -v vobjdump >/dev/null 2>&1 && sudo ln -sfn "$(command -v vobjdump)" "$INSTALL_DIR/bin/vobjdump"
  else
    echo "Building vasm..."
    tar -xzf vasm.tar.gz
    pushd vasm >/dev/null
    make -j"$(sysctl -n hw.ncpu)" CPU=m68k SYNTAX=mot
    sudo install -m 0755 vasmm68k_mot "$INSTALL_DIR/bin/vasmm68k_mot"
    [ -f vobjdump ] && sudo install -m 0755 vobjdump "$INSTALL_DIR/bin/vobjdump" || true
    popd >/dev/null
  fi
fi

# vlink
if [ ! -x "$INSTALL_DIR/bin/vlink" ]; then
  if command -v vlink >/dev/null 2>&1; then
    echo "vlink found in PATH; linking into $INSTALL_DIR/bin"
    sudo ln -sfn "$(command -v vlink)" "$INSTALL_DIR/bin/vlink"
  else
    echo "Building vlink..."
    tar -xzf vlink.tar.gz
    pushd vlink >/dev/null
    make -j"$(sysctl -n hw.ncpu)"
    sudo install -m 0755 vlink "$INSTALL_DIR/bin/vlink"
    popd >/dev/null
  fi
fi

# vbcc
if [ ! -x "$INSTALL_DIR/bin/vc" ] || [ ! -x "$INSTALL_DIR/bin/vbccm68k" ]; then
  echo "Building vbcc..."
  tar -xzf vbcc.tar.gz || true
  [ -d vbcc ] || { echo -e "${C_RED}FATAL: 'vbcc' dir missing after extract.${C_RESET}"; exit 1; }
  pushd vbcc >/dev/null
  [ -f Makefile ] || { echo -e "${C_RED}FATAL: vbcc Makefile not found.${C_RESET}"; exit 1; }

  # Non-interactive build: accept defaults
  yes | make TARGET=m68k

  sudo install -m 0755 bin/vc "$INSTALL_DIR/bin/vc"
  [ -f bin/vbccm68k ] && sudo install -m 0755 bin/vbccm68k "$INSTALL_DIR/bin/vbccm68k" || true
  popd >/dev/null
  echo -e "${C_GRN}vbcc installed.${C_RESET}"
else
  echo -e "${C_YEL}vbcc already present, skipping build.${C_RESET}"
fi

# --- 5) Install target + NDK (correct LHA extraction) ---
print_header "Step 5: Installing Amiga Target and NDK"

# vbcc target (extract inside a working dir, then copy config/ and targets/)
mkdir -p target_extracted
( cd target_extracted && lha x ../target.lha ) | sed -e 's/^/  /' || true

TARGET_TOP="$(find target_extracted -maxdepth 2 -type d -name 'vbcc_target_*' -print -quit || true)"
if [ -z "${TARGET_TOP}" ]; then
  echo -e "${C_RED}FATAL: Could not locate extracted vbcc_target_* directory.${C_RESET}"
  exit 1
fi

sudo rsync -a "${TARGET_TOP}/config/"  "$INSTALL_DIR/config/"
sudo rsync -a "${TARGET_TOP}/targets/" "$INSTALL_DIR/targets/"
echo -e "${C_GRN}vbcc m68k-amigaos target files installed.${C_RESET}"

# NDK 3.9 (same trick; archive has nested layout)
mkdir -p ndk_extracted
( cd ndk_extracted && lha x ../ndk.lha ) | sed -e 's/^/  /' || true
sudo rsync -a ndk_extracted/ "$NDK_INSTALL_DIR/"
echo -e "${C_GRN}NDK 3.9 installed.${C_RESET}"

# Try to discover the best include_h folder for alias wiring
NDK_INC_DIR="$(find "$NDK_INSTALL_DIR" -type d -path '*/Include/include_h' | head -n1 || true)"
[ -n "$NDK_INC_DIR" ] || NDK_INC_DIR="$NDK_INSTALL_DIR/NDK_3.9/Include/include_h"

# --- 6) Compatibility symlink ---
print_header "Step 6: Creating Compatibility Symlink"
sudo ln -sfn "$INSTALL_DIR/bin/vasmm68k_mot" "$INSTALL_DIR/bin/vasm_mot_oldstyle"
echo -e "${C_GRN}Symlink ensured.${C_RESET}"

# --- 7) Configure shell environment ---
print_header "Step 7: Configuring Your Shell Environment"
SHELL_RC=""
for f in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc"; do
  [ -f "$f" ] && { SHELL_RC="$f"; break; }
done
[ -n "$SHELL_RC" ] || { echo -e "${C_RED}No shell config file found (.zshrc/.bash_profile/.bashrc).${C_RESET}"; exit 1; }

BLOCK_BEGIN="# --- AMIGA DEV ENVIRONMENT ---"
BLOCK_END="# --------------------------------"
BLOCK_CONTENT=$(cat <<EOF

$BLOCK_BEGIN
export VBCC="$INSTALL_DIR"
export PATH="\$VBCC/bin:\$PATH"
# Best-guess NDK include path detected at install time:
export AMIGA_NDK_INCLUDE="$NDK_INC_DIR"
# vbcc wrapper for AmigaOS m68k:
alias amigavc="$INSTALL_DIR/bin/vc +aos68k -I\$AMIGA_NDK_INCLUDE"
# vasm (Devpac dialect) shortcut:
alias vasmdp="$INSTALL_DIR/bin/vasmm68k_mot -devpac"
$BLOCK_END
EOF
)

# Use sed to remove the old block, then append the new one.
sed -i.bak "/^${BLOCK_BEGIN}/,/^${BLOCK_END}/d" "$SHELL_RC"
printf "%s\n" "$BLOCK_CONTENT" >> "$SHELL_RC"
echo -e "Updating shell configuration file: ${C_BOLD}$SHELL_RC${C_RESET}\n${C_GRN}Shell block updated successfully.${C_RESET}"

# --- 8) Finalization + non-hanging version dump ---
print_header "Step 8: Finalizing"

echo -e "\n${C_GRN}${C_BOLD}🎉 Installation complete.${C_RESET}"
echo -e "${C_BOLD}Run: exec \$SHELL -l${C_RESET}  (reloads your shell config)"

echo -e "\n${C_BOLD}Installed Versions:${C_RESET}"

printf "vasm:  "
("$INSTALL_DIR/bin/vasmm68k_mot" -version 2>/dev/null || true)
printf "vlink: "
("$INSTALL_DIR/bin/vlink" -V 2>&1 || true) | head -n 1
printf "vbcc:  "
VBCC="$INSTALL_DIR" "$INSTALL_DIR/bin/vc" +aos68k -v 2>&1 | head -n 1 || true
