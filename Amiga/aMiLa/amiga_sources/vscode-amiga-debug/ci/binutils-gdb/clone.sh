#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

git clone --depth=1 https://github.com/grahambates/binutils-gdb.git
