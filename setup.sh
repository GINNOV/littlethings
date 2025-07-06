#!/bin/bash

# ==============================================================================
# Definitive Setup Script for CILBM Swift Package (Corrected)
# ==============================================================================
# This script automates the entire process of creating a Swift Package that
# correctly wraps the libiff and libilbm C libraries by conforming to SwiftPM
# conventions. This is the standard, robust way to handle C libraries.
#
# It performs the following actions:
#
# 1.  Creates a root directory for the package named "CILBM".
# 2.  Clones the required C library repositories from GitHub.
# 3.  Initializes a Swift Package.
# 4.  Creates the conventional directory structure for each C library:
#     - `Sources/[target]/`: Contains all .c source files.
#     - `Sources/[target]/include/`: Contains all public .h header files.
# 5.  Correctly separates the public headers from the private, partial headers.
# 6.  Correctly finds and processes the `ifftypes.h.in` template file.
# 7.  Generates a radically simplified, definitive `Package.swift` manifest file.
# 8.  Creates a `TestApp` executable to validate the build.
#
# Usage:
# 1. Save this file as `setup.sh` in your desired code directory.
# 2. Open a terminal and navigate to that directory.
# 3. Make the script executable: `chmod +x setup.sh`
# 4. Run the script: `./setup.sh`
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
PROJECT_NAME="CILBM"
MAIN_DIR=$(pwd)/$PROJECT_NAME
SOURCES_DIR="$MAIN_DIR/Sources"

# --- Main Logic ---

echo "🚀 Starting definitive setup for the $PROJECT_NAME Swift Package..."

# 1. Create a clean project directory
echo "[1/7] Creating clean project directory..."
rm -rf "$PROJECT_NAME"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"
echo "  - Done. Working in $(pwd)"

# 2. Clone required C libraries
echo "[2/7] Cloning C library repositories from GitHub..."
git clone https://github.com/svanderburg/libiff.git > /dev/null 2>&1
git clone https://github.com/svanderburg/libilbm.git > /dev/null 2>&1
echo "  - Cloned libiff and libilbm."

# 3. Initialize Swift Package and create target directories
echo "[3/7] Initializing Swift Package and creating structure..."
swift package init --type library > /dev/null 2>&1
rm -rf "Sources/$PROJECT_NAME" # Remove default Swift target
rm -rf "Tests" # Remove default Tests target
mkdir -p "$SOURCES_DIR/libiff/include"
mkdir -p "$SOURCES_DIR/libilbm/include"
mkdir -p "$SOURCES_DIR/TestApp"
echo "  - Initialized package and created target directories."

# 4. Copy and organize source files into the conventional structure
echo "[4/7] Organizing C source and header files..."
# libiff: copy .c files to target root, .h files to include/
find libiff/src/libiff -name "*.c" -exec cp {} Sources/libiff/ \;
find libiff/src/libiff -name "*.h" -exec cp {} Sources/libiff/include/ \;
# libilbm: copy .c files to target root, .h files to include/
find libilbm/src/libilbm -name "*.c" -exec cp {} Sources/libilbm/ \;
find libilbm/src/libilbm -name "*.h" -exec cp {} Sources/libilbm/include/ \;
echo "  - Separated .c and .h files into conventional directories."

# 5. Handle private headers and the template file
echo "[5/7] Handling private headers and templates..."
# Move private headers out of the public include directory so they are not exposed.
mv Sources/libilbm/include/ilbmchunktypes.h Sources/libilbm/
mv Sources/libilbm/include/ilbmformchunktypes.h Sources/libilbm/
mv Sources/libilbm/include/ilbmchunkheaders.h Sources/libilbm/
# Correctly process the ifftypes.h.in template
cp libiff/src/libiff/ifftypes.h.in Sources/libiff/include/ifftypes.h
sed -i '' 's/@IFF_BIG_ENDIAN@/0/' Sources/libiff/include/ifftypes.h
echo "  - Private headers isolated and template configured."

# 6. Generate the definitive, simplified Package.swift
echo "[6/7] Generating manifest and test application files..."
cat > Package.swift << EOF
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CILBM",
    products: [
        .library(
            name: "CILBM",
            targets: ["libilbm"]),
        .executable(
            name: "TestApp",
            targets: ["TestApp"])
    ],
    targets: [
        // Because the files are now in a conventional layout (headers in an
        // "include" subdirectory), SPM requires no extra configuration.
        // It will automatically find the headers and handle dependency linking.
        .target(
            name: "libiff",
            dependencies: []
        ),
        .target(
            name: "libilbm",
            dependencies: ["libiff"]
        ),
        .executableTarget(
            name: "TestApp",
            dependencies: ["libilbm"]
        )
    ]
)
EOF
echo "  - Created Package.swift"

# 7. Create main.swift for TestApp
echo "[7/7] Creating test application..."
cat > Sources/TestApp/main.swift << EOF
import libilbm

print("✅ Successfully imported the libilbm module!")
print("✅ The command-line validation test was successful.")
EOF
echo "  - Created Sources/TestApp/main.swift"

# --- Final Cleanup ---
rm -rf libiff libilbm # Remove the cloned repos, we don't need them anymore

echo ""
echo "----------------------------------------------------"
echo "✅ Setup complete."
echo ""
echo "You can now validate the package by running:"
echo "cd $PROJECT_NAME"
echo "swift run TestApp"
echo "----------------------------------------------------"

