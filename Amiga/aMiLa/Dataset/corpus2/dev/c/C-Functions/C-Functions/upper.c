
#include <exec/types.h>

int upper(c)       /* Convert c to upper case; non-Swedish ASCII only */
register int c;
   {
   return ((c >= 'a' && c <= 'z') ? (c - 'a' + 'A') : c );
   }

