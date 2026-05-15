#!/bin/bash -e

PROJECT=example

rm -rf ../${PROJECT}_build

mkdir ../${PROJECT}_build
cd ../${PROJECT}_build
cmake -G "Eclipse CDT4 - Unix Makefiles" $* ../$PROJECT
make -j$(nproc)
