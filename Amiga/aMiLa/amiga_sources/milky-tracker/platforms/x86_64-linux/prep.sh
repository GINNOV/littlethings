#!/bin/bash

# exit when any command fails
set -e
export CURPATH="${PWD}"
export SUBMODULES="${CURPATH}/src/submodules"

#set compiler params
# SDL2.0
if [ ! -d "${SUBMODULES}/SDL2" ]; then
        git clone --recursive https://github.com/libsdl-org/SDL.git "${SUBMODULES}"/SDL2
fi
cd "${SUBMODULES}"/SDL2
git checkout tags/release-2.28.5 ; rm -rf "${SUBMODULES}"/SDL2/build
mkdir -p "${SUBMODULES}"/SDL2/build
cd "${SUBMODULES}"/SDL2/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/tmp/libs
cmake --build . --config Release --target install -- -j$(getconf _NPROCESSORS_ONLN)
cd "${SUBMODULES}"

cd "${CURPATH}"
