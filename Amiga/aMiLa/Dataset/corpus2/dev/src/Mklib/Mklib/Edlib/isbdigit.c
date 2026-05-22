/* edlib  version 1.0 of 04/08/88 */
/*
    tests whether the given character could be a binary digit
*/
#include <stdio.h>

int isbdigit(c)
char c;
{
    if ( c == '1' || c == '0' ) {
        return(1);
    } else {
        return(NULL);
    }
}
