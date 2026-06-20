#include "mempriv.h"
#undef getcwd

#include <dos/dos.h>

char *MWGetCWD(char *path, int size, char *file, long line)
{
   if(path == NULL)
   {
      path = MWAllocMem(size, 0, MWI_MALLOC, file, line);
      if(path == NULL) return NULL;
   }
   return((char *)getcwd((char *)path,(int)size));
}
