#!/bin/bash -e

# Build for AmigaDOS
./build.sh -DAMIGACROSS=1 -DBUILD_FOR_AMIGADOS=1 -DDISABLE_STREAMCLASS=0

#Build for NDOS
./build.sh -DAMIGACROSS=1 -DBUILD_FOR_AMIGADOS=0 -DDISABLE_STREAMCLASS=0

#Build for Linux
./build.sh -DAMIGACROSS=0 -DDISABLE_STREAMCLASS=0

echo "Everything went fine"
