
run_tests() {
    local testName=$1

    echo success >$status

    for testCmd in ${testExamples2Dir}/cmd/${testName}/*
    do
	echo "Test command: $testCmd"
	local cmdName=$(basename $testCmd)
	local expectedResFile="${expectedDir}/${cmdName}${resultsOsPostfix}"
	#echo "expectedResFile = '${expectedResFile}'"
	if [ -f "${expectedResFile}" ]
	then
	    # test
	    . $testCmd
	    echo "Executing '$testName / $cmdName' ("$(comment)")."
	    cmd >tmp/${testName}/${cmdName}_output
	    if result_ok tmp/${testName}/${cmdName}_output ${expectedResFile}
	    then
		echo "Test '$testName / $cmdName' ("$(comment)") OK."
	    else
		echo "Test '$testName / $cmdName' ("$(comment)") failed."
		echo failed >$status
	    fi
	else
	    # always fail (not tested!)
            echo failed >$status

	    # generate expected result
	    . $testCmd
	    echo "Generating result for '$testName / $cmdName' ("$(comment)")... "
	    mkdir -pv ${expectedDir}
	    cmd >${expectedResFile}
	    echo "Done."
	fi
    done

    read status < $status && test "x$status" = xsuccess
}
