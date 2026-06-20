#include "mempriv.h"

#undef getenv
#undef free

char *MWGetEnv(const char *name, char *file, long line)
{
   char *var, *mem;
   var = getenv(name);
   if(var == NULL) return NULL;
   mem = MWStrDup(var, file, line);
   free(var);
   return mem;
}
