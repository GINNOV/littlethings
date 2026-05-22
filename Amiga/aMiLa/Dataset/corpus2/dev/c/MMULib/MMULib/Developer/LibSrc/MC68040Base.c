#include <exec/libraries.h>
#include <proto/exec.h>

struct Library *MC68040Base = NULL;
extern unsigned long _MC68040BaseVer;

void _INIT_5_MC68040Base()
{
  if (!(MC68040Base = OpenLibrary("68040.library",_MC68040BaseVer)))
    exit(20);
}

void _EXIT_5_MC68040Base()
{
  if (MC68040Base)
    CloseLibrary(MC68040Base);
}
