/* edlib  version 1.0 of 04/08/88 */
/* this function takes a string of decimal digits and returns its value */
#include <ctype.h>

int dectoint(number)
char *number;
{
    int value = 0;

    while ( *number )
        if ( isdigit(*number) ) {
            value = value*10  + toint(*number++);
        } else {
            return(value);
        }

    return(value);
}
