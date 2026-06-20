/* edlib  version 1.0 of 04/08/88 */
#include <ctype.h>

int stricmp(str1,str2)
char *str1,*str2;
{
    int index = 0;

    while ( str1[index] && str2[index] &&
            tolower(str1[index]) == tolower(str2[index]) )
        ++index;

    return( (tolower(str1[index]) < tolower(str2[index])) ? -1 :
          ( (tolower(str1[index]) > tolower(str2[index])) ?  1 : 0) );
}

