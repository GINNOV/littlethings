#include <exec/libraries.h>
#include <proto/exec.h>

struct Library *GateXprBase = NULL;
extern unsigned long _GateXprBaseVer;

void _INIT_5_GateXprBase()
{
  if (!(GateXprBase = OpenLibrary("GateXpr.library",_GateXprBaseVer)))
    exit(20);
}

void _EXIT_5_GateXprBase()
{
  if (GateXprBase)
    CloseLibrary(GateXprBase);
}
