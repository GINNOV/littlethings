#!/bin/bash
#
# Convert results for MSYS
#

set -e

main() {
    #local resultsOsPostfix=$(get_os_postfix)
    local resultsOsPostfix=_msys

    for testResDir in res/*
    do
	echo "Entering $testResDir/"
        local curDir=$(pwd)
        cd $testResDir
#        rm -fv *_msys
#        for testCmd in `ls | grep -v _msys`
        for testCmd in *
        do
            if [[ "$testCmd" =~ "_msys" ]] ; then continue ; fi
            local testCmdMsys=${testCmd}${resultsOsPostfix}
            if [ ! -f "${testCmdMsys}" ]
            then
		echo "Converting ${testCmd} to ${testCmdMsys}..."
		#unix2dos -v <"${testCmd}" >"${testCmdMsys}"
		# this is better for this case - it skips binary files
                unix2dos -v -n "${testCmd}" "${testCmdMsys}"
            fi
	done
	cd $curDir
    done
}

main

echo "REMEMBER TO CHANGE '/' TO '\\' IN PATHS!!!"
