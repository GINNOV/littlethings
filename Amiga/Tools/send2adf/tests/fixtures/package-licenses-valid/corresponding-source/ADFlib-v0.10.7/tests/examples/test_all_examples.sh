#!/bin/sh
# Usage: test_all_examples.sh <install path>
#  e.g.: test_all_examples.sh /usr/local/bin
#        test_all_examples.sh .
set -e

if [ $# -ne 1 ]; then
    echo 2>&1 "Usage: $0 <install path>"
    exit 1
fi

basedir=$(dirname "$0")
cmd_path="$1" "$basedir/test_unadf.sh"

