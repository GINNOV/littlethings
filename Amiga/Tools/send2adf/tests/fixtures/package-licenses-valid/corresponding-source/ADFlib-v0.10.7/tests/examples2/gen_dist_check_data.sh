#!/bin/bash
#
# Generate list of files for Makefile.am
#

set -e

output=Makefile.am_cmd

echo 'dist_check_DATA += \' >$output

find cmd/ -type f | sort \
    | sed -e 's/^/\t/' -e 's/$/\ \\/' \
    >>$output

truncate -s -2 $output
