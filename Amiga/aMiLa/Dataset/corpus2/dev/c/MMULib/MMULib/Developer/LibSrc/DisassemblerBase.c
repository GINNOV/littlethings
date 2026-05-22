#include <exec/libraries.h>
#include <proto/exec.h>

struct Library *DisassemblerBase = NULL;
extern unsigned long _DisassemblerBaseVer;

void _INIT_5_DisassemblerBase()
{
  if (!(DisassemblerBase = OpenLibrary("Disassembler.library",_DisassemblerBaseVer)))
    exit(20);
}

void _EXIT_5_DisassemblerBase()
{
  if (DisassemblerBase)
    CloseLibrary(DisassemblerBase);
}
