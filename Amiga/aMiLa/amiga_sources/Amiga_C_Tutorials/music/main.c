
#include <stdio.h>
#include <stdlib.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <exec/execbase.h>
#include <dos/dosextens.h>
#include <intuition/intuitionbase.h>

#include <string.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include "ptreplay.h"
#include "ptreplay_protos.h"
#include "ptreplay_pragmas.h"

struct Library *PTReplayBase;
extern struct DosLibrary *DOSBase;

/* Mod music */
struct Module *theMod;
UBYTE *mod = NULL;

PLANEPTR load_getchipmem(UBYTE *name, ULONG size)
{
  BPTR fileHandle;
  PLANEPTR mem;

  if (fileHandle = Open(name, MODE_OLDFILE))
  {
    if (mem = AllocMem(size, MEMF_CHIP))
    {
      Read(fileHandle, mem, size);
      Close(fileHandle);
      return (mem);
    }
  }
  return (NULL);
}

int main(void)
{
    printf("Playing mod file (34 seconds)...\n\n");
    printf("NE MUTLU TURKUM DIYENE!\n\n");
    Delay(50);

    /* Copy ptreplay.library to SYS:Libs drawer */
    if (!(PTReplayBase = OpenLibrary((UBYTE *)"ptreplay.library", 0)))
    {
      printf("Unable to open ptreplay.library\n");
      return (FALSE);
    }

    mod = load_getchipmem((UBYTE *)"izmirMarsi.bin", 231484);
    theMod = PTSetupMod((APTR)mod);
    PTPlay(theMod);

    Delay(50 * 34); // App will be closed after 34 secs

    /* Closing... */
    if (mod != NULL)
    {
      PTStop(theMod);
      PTFreeMod(theMod);
      FreeMem(mod, 83488);
    }

    if (PTReplayBase) CloseLibrary(PTReplayBase);
    printf("Thanks for listening ...\n");
    Delay(50);

    return 0;
}
