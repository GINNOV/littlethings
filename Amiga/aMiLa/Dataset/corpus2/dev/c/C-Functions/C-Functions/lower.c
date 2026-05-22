
#include <exec/types.h>

int lower(c)       /* Convert c to lower case; non-Swedish ASCII */
register int c;
   {
   return ((c >= 'A' && c <= 'Z') ? (c - 'A' + 'a') : c);
   }

