/* edlib  version 1.0 of 04/08/88 */
/*
    string to lower changes all upper case letters in a string to lower
    case.
*/
#include <ctype.h>

char *stolower(str)
char *str;
{
    char *temp = str;

    for ( ; *temp ; temp++ )
        *temp = (char) tolower(*temp);

    return(str);
}
