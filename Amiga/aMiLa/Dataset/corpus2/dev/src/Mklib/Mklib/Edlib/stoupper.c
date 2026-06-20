/* edlib  version 1.0 of 04/08/88 */
/*
    string to upper changes all lower case letters in a string to upper
    case.
*/
#include <ctype.h>

char *stoupper(str)
char *str;
{
    char *temp = str;

    for ( ; *temp ; temp++ )
        *temp = (char) toupper(*temp);

    return(str);
}
