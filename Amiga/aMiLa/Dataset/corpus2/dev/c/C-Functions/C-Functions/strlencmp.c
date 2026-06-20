
#include <exec/types.h>

int strlencmp (s,t,n)   /* Stringcompare n letters; NULL if s == t */
UBYTE s[], t[];         /* End at first '\0' ( if found ) */
int n;
   {
register int i=0;
   while ( (i<n-1) && s[i] == t[i] && s[i] && t[i]) i++;
   return( (int)(s[i] - t[i]) );
   }

