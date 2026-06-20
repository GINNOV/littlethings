#include <intuition/screens.h>
#include <utility/tagitem.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/displayinfo.h>
#include <graphics/modeid.h>
#include <exec/memory.h>
#include <dos/rdargs.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <string.h>
#include <stdlib.h>

int main(void)
{
  struct RDArgs *rdargs;
  LONG args[3];

  memset(args,0,sizeof(args));
  
  if (rdargs = ReadArgs("MODE/A,DEPTH/N/A",args,NULL)) {
    ULONG mode  = strtol((char *)(args[0]),NULL,0);
    ULONG depth = *(LONG *)(args[1]);
    ULONG id    = BestModeID(BIDTAG_MonitorID,mode,BIDTAG_Depth,depth,TAG_DONE);

    Printf("Found mode is 0x%08lx\n",id);
    FreeArgs(rdargs);
  }
}
