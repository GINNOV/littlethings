
[ ! -d ${examplesBinDir} ] && \
    { echo "Examples bin dir. '"${examplesBinDir}"' not found."; \
      exit 1; }


get_test_cmd() {
    if [ ! -d "$examplesBinDir" ]; then
        echo no-such-command
        echo >&2 examplesBinDir "$examplesBinDir" is not a directory
        exit 1
    fi
    if [ -x "$examplesBinDir/$1" ]; then
        echo "$examplesBinDir/$1"
    elif [ -x "$examplesBinDir/$1.exe" ]; then
        echo "$examplesBinDir/$1.exe"
    else
        echo no-such-command
        echo >&2 No $1 executable found in $(cd "$examplesBinDir" && pwd)
        exit 1
    fi
}


#
# parameters:
# - filename with expected result
# - filename with actual result
#
result_ok() {
    diff -u --strip-trailing-cr ${1} ${2}
}


# check if test configured
if [ "x$testName" = "x" ]
then
    echo "$0: test not configured"
    exit 1
fi

# global const
#dumpsDir=${dumpsDir:-../data/Dumps}
readonly hostType=$(uname | sed 's/_.*//')
readonly resultsOsPostfix=$(get_os_postfix)
readonly testExamples2Dir=${testsSrcDir}/examples2
readonly expectedDir=${testExamples2Dir}/res/$testName
status=tmp/${testName}/status
