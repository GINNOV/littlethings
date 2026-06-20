#include "mempriv.h"
#undef getcwd

#include <dos.h>

char *MWGetCWD(char *path, int size, char *file, long line)
{
   if(path == NULL)
   {
      path = MWAllocMem(size, 0, MWI_MALLOC, file, line);
      if(path == NULL) return NULL;
   }
   return getcwd(path, size);
}
