#include <exec/libraries.h>
#include <proto/exec.h>

struct Library *MC680x0Base = NULL;
extern unsigned long _MC680x0BaseVer;

void _INIT_5_MC680x0Base()
{
  if (!(MC680x0Base = OpenLibrary("680x0.library",_MC680x0BaseVer)))
    exit(20);
}

void _EXIT_5_MC680x0Base()
{
  if (MC680x0Base)
    CloseLibrary(MC680x0Base);
}
