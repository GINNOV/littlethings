#!/bin/sh

set -e

examples_bin=../../build/debug/examples

results_dir=results
results_msys=results_msys

adfimgcreate=${examples_bin}/adfimgcreate
adfformat=${examples_bin}/adfformat
adfinfo=${examples_bin}/adfinfo

tempdir=TEMPDIR
mkdir -p "$tempdir"

dumpfile=${tempdir}/testflopdd1.adf

$adfimgcreate -t dd $dumpfile >${results_dir}/adf_floppy_test_1

$adfformat -t 1 -l TestFlopDD1 -v $dumpfile >${results_dir}/adf_floppy_test_2 2>/dev/null

$adfinfo $dumpfile >${results_dir}/adf_floppy_test_3

$adfinfo $dumpfile 0 | grep -v \
  -e Created: -e 'Last access:' -e checkSum: -e calculated -e days: \
  -e mins: -e ticks: -e coDays: -e coMins -e coTicks >${results_dir}/adf_floppy_test_4

rm -fv "${dumpfile}"
rm -dv "${tempdir}"
