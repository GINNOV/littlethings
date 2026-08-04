#!/bin/sh

# common settings
. "`dirname $0`/common.sh"

set -e

echo "$0: start"

dumpname=a590_WD93028XA_6parts.hdd

mkdir -vp tmp
cd tmp
tempdir=$(basename $0)"_tmp"
echo $tempdir
tempfile=$(mktemp ${dumpname}.XXXXXX)
echo $tempfile
cd ..

trap cleanup 0 1 2
cleanup() {
    cd tmp
    rm -fv "${tempfile}"
}

#echo "----- hd_test"

gzip -cd ${DUMPS}/${dumpname}.gz > tmp/"${tempfile}"

./hd_test_a590 tmp/"${tempfile}"

#rm -fv "${tempfile}"
