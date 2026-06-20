/* edlib  version 1.0 of 04/08/88 */
/* this function takes a string of hex digits and returns its value */
#include <ctype.h>

int hextoint(number)
char *number;
{
    int value = 0;

    while ( *number )
        if ( isxdigit(*number) ) {
            value = ( value << 4 )  + toint(*number++);
        } else {
            return(value);
        }

    return(value);
}
