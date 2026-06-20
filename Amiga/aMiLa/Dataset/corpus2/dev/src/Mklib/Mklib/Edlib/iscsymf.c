/* edlib  version 1.0 of 04/08/88 */
/*
    iscsymf is included here because Manx for some reason does not have
    it in ctype.h. tells whether or not the given character may be the
    first character of a valid C symbol
*/
#include <ctype.h>
int iscsymf(c)
char c;
{
    return( isalpha(c) || c == '_' );
}
