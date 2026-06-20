/* edlib  version 1.0 of 04/08/88 */
/*
    returns a nonzero value if c is the code for an octal digit, otherwise
    return zero
*/
#include <ctype.h>

int isodigit(c)
char c;
{
    if (c == '9' || c == '8') {
        return(0);
    } else {
        return(isdigit(c));
    }
}

