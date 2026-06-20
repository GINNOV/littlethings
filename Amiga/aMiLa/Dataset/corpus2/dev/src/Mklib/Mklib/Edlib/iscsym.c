/* edlib  version 1.0 of 04/08/88 */
/*
    this function returns a non-zero number if the character given
    is suitable for the a character of an identifier
*/
#include <ctype.h>
#define NULL 0

int iscsym(c)
char c;
{
    if ( iscsymf(c) || isdigit(c) )
        return(c);

    return(NULL);
}

