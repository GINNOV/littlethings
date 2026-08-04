
#
# Independent functions (no needing any test env.)
#


#
# Returns "_msys" on MSYS2, empty string in other cases
#
get_os_postfix() {
    local host_type=$(uname | sed 's/_.*//')
    echo >&2 "Host type: '${host_type}'"
    if [ "x${host_type}" = 'xMINGW32' -o \
         "x${host_type}" = 'xMINGW64' ]
    then
	echo "_msys"
##elif [ "x${hostType}" = 'xCYGWIN' ]; then
    else
	echo
    fi
}


#
# Compares 2 file (text), displays differences (if any)
# and returns status (shell style):
#   true/no errors (0) - if there is no difference
#   false/error (1)    - in case of any difference
#
# parameters:
# - filename with expected result
# - filename with actual result
#
result_ok() {
    diff -u --strip-trailing-cr ${1} ${2}
}
