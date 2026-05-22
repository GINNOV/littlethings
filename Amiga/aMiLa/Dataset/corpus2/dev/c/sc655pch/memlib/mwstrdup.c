/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* |_o_o|\\ Copyright (c) 1994 Doug Walker                                 *
* |. o.| ||          All Rights Reserved                                  *
* | .  | ||          Written by Doug Walker                               *
* | o  | ||          4701 Oak Park Road                                   *
* |  . |//           Raleigh, NC 27612                                    *
* ======                                                                  *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "mempriv.h"
#include <string.h>

char *MWStrDup(const char *str, char *file, long line)
{
   char *mem;
   if(str == NULL)
   {
      MWPrintf("\7\nMemWatch ERROR: strdup(NULL) called from file \"%s\" line %d\n",
         file, line);
      return NULL;
   }
   // Pass file and line along so any future memory error messages show the
   // line of the strdup() call and not this one.
   mem = MWAllocMem(strlen(str)+1, 0, MWI_MALLOC, file, line);

   if(mem) strcpy(mem, str);
   
   return mem;
}
