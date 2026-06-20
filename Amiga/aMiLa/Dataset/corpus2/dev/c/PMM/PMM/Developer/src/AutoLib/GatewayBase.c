#include <exec/libraries.h>
#include <proto/exec.h>

struct Library *GatewayBase = NULL;
extern unsigned long _GatewayBaseVer;

void _INIT_5_GatewayBase()
{
  if (!(GatewayBase = OpenLibrary("Gateway.library",_GatewayBaseVer)))
    exit(20);
}

void _EXIT_5_GatewayBase()
{
  if (GatewayBase)
    CloseLibrary(GatewayBase);
}
