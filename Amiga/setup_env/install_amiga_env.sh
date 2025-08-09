#!/bin/bash
#
# Definitive Amiga Environment Automated Installer (macOS)
# Builds vasm, vlink, vbcc; installs vbcc m68k-amigaos target + AmigaOS 3.9 NDK.
# Sets PATH, VBCC, and amigavc wrapper that Just Works.
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
  echo -e "${C_RED}Command Line Tools not found. Run: xcode-select --install${C_RESET}"; exit 1
fi
if ! command -v lha &>/dev/null; then
  echo -e "${C_YEL}Installing lhasa (provides 'lha') via Homebrew...${C_RESET}"
  if ! command -v brew &>/dev/null; then
    echo -e "${C_RED}Homebrew not found. Install Homebrew or lhasa manually, then re-run.${C_RESET}"; exit 1
  fi
  brew install lhasa
fi
sudo -v
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
echo "Downloading vbcc.tar.gz from: $VBCC_URL";  curl -fL --retry 3 -o vbcc.tar.gz  "$VBCC_URL"
echo "Downloading vasm.tar.gz from: $VASM_URL";  curl -fL --retry 3 -o vasm.tar.gz  "$VASM_URL"
echo "Downloading vlink.tar.gz from: $VLINK_URL";curl -fL --retry 3 -o vlink.tar.gz "$VLINK_URL"
echo "Downloading target.lha from: $TARGET_URL"; curl -fL --retry 3 -o target.lha   "$TARGET_URL"
echo "Downloading ndk.lha from: $NDK_URL";       curl -fL --retry 3 -o ndk.lha      "$NDK_URL"
echo -e "${C_GRN}All downloads verified.${C_RESET}"

# --- 4) Build + install vasm/vlink/vbcc ---
print_header "Step 4: Building and Installing Components"

# vasm
if [ ! -x "$INSTALL_DIR/bin/vasmm68k_mot" ]; then
  echo "Building vasm..."
  tar -xzf vasm.tar.gz
  pushd vasm >/dev/null
  make -j"$(sysctl -n hw.ncpu)" CPU=m68k SYNTAX=mot
  sudo install -m 0755 vasmm68k_mot "$INSTALL_DIR/bin/vasmm68k_mot"
  [ -f vobjdump ] && sudo install -m 0755 vobjdump "$INSTALL_DIR/bin/vobjdump" || true
  popd >/dev/null
  echo -e "${C_GRN}vasm installed.${C_RESET}"
else
  echo -e "${C_YEL}vasm already present, skipping build.${C_RESET}"
fi

# vlink
if [ ! -x "$INSTALL_DIR/bin/vlink" ]; then
  echo "Building vlink..."
  tar -xzf vlink.tar.gz
  pushd vlink >/dev/null
  make -j"$(sysctl -n hw.ncpu)"
  sudo install -m 0755 vlink "$INSTALL_DIR/bin/vlink"
  popd >/dev/null
  echo -e "${C_GRN}vlink installed.${C_RESET}"
else
  echo -e "${C_YEL}vlink already present, skipping build.${C_RESET}"
fi

# vbcc
if [ ! -x "$INSTALL_DIR/bin/vc" ] || [ ! -x "$INSTALL_DIR/bin/vbccm68k" ]; then
  echo "Building vbcc..."
  tar -xzf vbcc.tar.gz || true
  [ -d vbcc ] || { echo -e "${C_RED}FATAL: 'vbcc' dir missing after extract.${C_RESET}"; exit 1; }
  pushd vbcc >/dev/null
  yes | make TARGET=m68k
  sudo install -m 0755 bin/vc "$INSTALL_DIR/bin/vc"
  [ -f bin/vbccm68k ] && sudo install -m 0755 bin/vbccm68k "$INSTALL_DIR/bin/vbccm68k" || true
  popd >/dev/null
  echo -e "${C_GRN}vbcc installed.${C_RESET}"
else
  echo -e "${C_YEL}vbcc already present, skipping build.${C_RESET}"
fi

# --- 5) Install target + NDK (LHA extraction to staging, then rsync) ---
print_header "Step 5: Installing Amiga Target and NDK"

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

mkdir -p ndk_extracted
( cd ndk_extracted && lha x ../ndk.lha ) | sed -e 's/^/  /' || true
sudo rsync -a ndk_extracted/ "$NDK_INSTALL_DIR/"
echo -e "${C_GRN}NDK 3.9 installed.${C_RESET}"

# Best-guess include path
NDK_INC_DIR="$(find "$NDK_INSTALL_DIR" -type d -path '*/Include/include_h' | head -n1 || true)"
[ -n "$NDK_INC_DIR" ] || NDK_INC_DIR="$NDK_INSTALL_DIR/NDK_3.9/Include/include_h"

# --- 6) Compatibility symlink ---
print_header "Step 6: Creating Compatibility Symlink"
sudo ln -sfn "$INSTALL_DIR/bin/vasmm68k_mot" "$INSTALL_DIR/bin/vasm_mot_oldstyle"
echo -e "${C_GRN}Symlink ensured.${C_RESET}"

# --- 7) Configure shell environment (write to BOTH login & interactive files) ---
print_header "Step 7: Configuring Your Shell Environment"
DETECT_SHELL="$(basename "${SHELL:-zsh}")"

BLOCK_BEGIN="# --- AMIGA DEV ENVIRONMENT ---"
BLOCK_END="# --------------------------------"
BLOCK_BODY=$(cat <<EOF
export VBCC="$INSTALL_DIR"
export PATH="\$VBCC/bin:\$PATH"
export AMIGA_NDK_INCLUDE="$NDK_INC_DIR"
# vbcc wrapper for AmigaOS m68k:
alias amigavc="\$VBCC/bin/vc +aos68k -I\$AMIGA_NDK_INCLUDE"
# vasm (Devpac dialect) shortcut:
alias vasmdp="\$VBCC/bin/vasmm68k_mot -devpac"
EOF
)
BLOCK_CONTENT=$'\n'"$BLOCK_BEGIN"$'\n'"$BLOCK_BODY"$'\n'"$BLOCK_END"$'\n'

write_or_replace_block() {
  local file="$1"
  if [ -f "$file" ]; then
    if grep -q "$BLOCK_BEGIN" "$file"; then
      awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" -v repl="$BLOCK_CONTENT" '
        $0 ~ begin {print repl; skip=1; next}
        $0 ~ end && skip==1 {skip=0; next}
        skip!=1 {print}
      ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      echo "Updated $file"
    else
      printf "%s" "$BLOCK_CONTENT" >> "$file"
      echo "Appended block to $file"
    fi
  else
    printf "%s" "$BLOCK_CONTENT" > "$file"
    echo "Created $file"
  fi
}

if [ "$DETECT_SHELL" = "zsh" ]; then
  write_or_replace_block "$HOME/.zprofile"
  write_or_replace_block "$HOME/.zshrc"
else
  write_or_replace_block "$HOME/.bash_profile"
  write_or_replace_block "$HOME/.bashrc"
fi
echo -e "${C_GRN}Shell block written to login and interactive rc files.${C_RESET}"

# Also drop a wrapper that guarantees VBCC even if env not loaded
sudo tee "$INSTALL_DIR/bin/amigavc" >/dev/null <<'WRAP'
#!/usr/bin/env bash
set -euo pipefail
: "${VBCC:=/opt/vbcc}"
exec "$VBCC/bin/vc" +aos68k -I"${AMIGA_NDK_INCLUDE:-/opt/amiga-ndk-3.9/NDK_3.9/Include/include_h}" "$@"
WRAP
sudo chmod 0755 "$INSTALL_DIR/bin/amigavc"

# --- 8) Finalizing ---
print_header "Step 8: Finalizing"

echo -e "\n${C_GRN}${C_BOLD}🎉 Installation complete.${C_RESET}"
echo -e "${C_BOLD}Reload your shell environment with one of:${C_RESET}"
echo "  source ~/.zprofile   # login env (zsh)"
echo "  source ~/.zshrc      # interactive env (zsh)"
echo "  or just start a new Terminal window"

echo -e "\n${C_BOLD}Installed Versions:${C_RESET}"
printf "vasm:  "; ("$INSTALL_DIR/bin/vasmm68k_mot" -h 2>&1 || true) | head -n 1 || true
printf "vlink: "; ("$INSTALL_DIR/bin/vlink" -h 2>&1 || true) | head -n 1 || true
printf "vbcc:  "; VBCC="$INSTALL_DIR" "$INSTALL_DIR/bin/vc" +aos68k -v 2>&1 | head -n 1 || true