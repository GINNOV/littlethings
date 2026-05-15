#!/bin/bash
set -e
echo "🚀 Setting up Amiga code build + validation environment..."

# 1. FS-UAE (best Amiga emulator for macOS)
echo "Installing FS-UAE via Homebrew..."
brew install fs-uae fs-uae-launcher

# 2. Create tools directory
TOOLS_DIR="$HOME/amiga-tools"
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR"

# 3. vasm (68000 assembler) — latest official build
echo "Downloading and installing vasm (m68k)..."
curl -L -O http://www.ibscompiler.de/vasm/vasm-m68k.tar.gz
tar xzf vasm-m68k.tar.gz
sudo cp vasm-m68k/vasm6502_std "$TOOLS_DIR/vasm"
sudo cp vasm-m68k/vobjdump "$TOOLS_DIR/"
chmod +x "$TOOLS_DIR/vasm" "$TOOLS_DIR/vobjdump"

# 4. Add to PATH permanently
if ! grep -q "amiga-tools" ~/.zshrc; then
    echo "export PATH=\"\$PATH:$TOOLS_DIR\"" >> ~/.zshrc
    echo "✅ Added amiga-tools to PATH"
fi

echo ""
echo "✅ Environment ready!"
echo "   vasm path: $TOOLS_DIR/vasm"
echo "   FS-UAE installed"
echo "   Run: source ~/.zshrc"
