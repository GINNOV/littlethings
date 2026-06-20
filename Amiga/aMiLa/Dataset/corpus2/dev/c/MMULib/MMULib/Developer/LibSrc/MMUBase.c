#include <exec/libraries.h>
#include <proto/exec.h>

struct Library *MMUBase = NULL;
extern unsigned long _MMUBaseVer;

void _INIT_5_MMUBase()
{
  if (!(MMUBase = OpenLibrary("MMU.library",_MMUBaseVer)))
    exit(20);
}

void _EXIT_5_MMUBase()
{
  if (MMUBase)
    CloseLibrary(MMUBase);
}
