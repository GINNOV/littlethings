#!/bin/bash

# Enable verbose output if VERBOSE=1
[ "$VERBOSE" = "1" ] && set -x

set -e
set -x

baseDir=$(dirname $0)

tests[0]="test_adfbitmap.sh"
tests[1]="test_adf_floppy.sh"
tests[2]="test_adfinfo_hd.sh"
tests[3]="test_adfinfo.sh"
tests[4]="test_adfinfo_links.sh"
tests[5]="test_adfls.sh"
tests[6]="test_adfsalvage.sh"
tests[7]="test_unadf_hdd.sh"
tests[8]="test_unadf.sh"
tests[9]="test_unadf_win32.sh"

for i in "${tests[@]}"
do
    ${baseDir}/${i} $@
done
