
#include <exec/types.h>

VOID strupp(pc)     /* Make a string upper case only */
UBYTE *pc;
   {
register int i=0;
   while (pc[i] = upper(pc[i])) i++;    /* Do untill /0 is found */
   }

