
#include <exec/types.h>

int strinstr (s,c)       /* Check if character c is in string s */
UBYTE s[];           /* Return first pos if found, else NULL */
int c;               /* Will return NULL if '\0' was searched for */
   {
register int i=0;
   while ( s[i] != c && s[i] ) i++;
   return ( s[i] ? i+1 : NULL );
   }

