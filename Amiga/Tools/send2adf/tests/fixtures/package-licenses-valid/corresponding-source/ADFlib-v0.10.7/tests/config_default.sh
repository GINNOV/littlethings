
#
# Configuration file for tests (default)
#
# This file is hardcoded for manual tests (to edit, if needed).
#
# To use (source) in subdirectories(!).
#

#projectBinDir=@abs_builddir@
#examplesBinDir=@abs_builddir@/examples

echo "examplesBinDir: "${examplesBinDir}
echo "testsSrcDir: "${testsSrcDir}
echo "testDataDir: "${testDataDir}

examplesBinDir=${examplesBinDir:-$(pwd)/../../build/debug/examples}

# assumming all tests are in subdirectories (1 level below)
testsSrcDir=${testsSrcDir:-$(pwd)/..}

testDataDir=${testsSrcDir}/data

bootblocksDir=${testDataDir}/Bootblock
dumpsDir=${testDataDir}/Dumps
