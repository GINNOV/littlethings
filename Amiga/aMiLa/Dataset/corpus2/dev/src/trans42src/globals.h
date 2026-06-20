#ifndef STRUCT
#define STRUCT(x) typedef struct x x; struct x
#endif

#include <exec/nodes.h>
#include <exec/types.h>

STRUCT (globalPart)
{
    struct MinList languages;
    struct SignalSemaphore *semaphore;
};

int __saveds __asm __InitLibGlobals(register __a6 struct MyLibrary *);
void __saveds __asm __CleanupLibGlobals(register __a6 struct MyLibrary *);

int __saveds __asm __UserLibInit(register __a6 struct MyLibrary *);
void __saveds __asm __UserLibCleanup(register __a6 struct MyLibrary *);

void  __saveds __asm
__SetLibGlobals(register __a6 struct MyLibrary *libbase,
                 register __a0 globalPart *g);
