
#include "freedb.h"

/***********************************************************************/

APTR ASM
AllocVecPooled ( REG(a0) APTR pool,
                 REG(d0) ULONG size )
{
    register ULONG *mem;

    if (mem = AllocPooled(pool,size = size+sizeof(ULONG)))
    {
        *mem++ = size;
    }

    return mem;
}

/****************************************************************************/

void ASM
FreeVecPooled ( REG(a0) APTR pool,
                REG(a1) APTR mem )
{
    FreePooled(pool,(LONG *)mem-1,*((LONG *)mem-1));
}

/****************************************************************************/

APTR ASM
allocArbitratePooled(REG(d0) ULONG s)
{
    register APTR mem;

    ObtainSemaphore(&rexxLibBase->memSem);
    mem = AllocPooled(rexxLibBase->pool,s);
    ReleaseSemaphore(&rexxLibBase->memSem);

    return mem;
}

/****************************************************************************/

void ASM
freeArbitratePooled(REG(a0) APTR mem,REG(d0) ULONG s)
{
    ObtainSemaphore(&rexxLibBase->memSem);
    FreePooled(rexxLibBase->pool,mem,s);
    ReleaseSemaphore(&rexxLibBase->memSem);
}

/****************************************************************************/

APTR ASM
allocArbitrateVecPooled(REG(d0) ULONG size)
{
    register ULONG *mem;

    ObtainSemaphore(&rexxLibBase->memSem);
    mem = AllocPooled(rexxLibBase->pool,size = size+sizeof(ULONG));
    ReleaseSemaphore(&rexxLibBase->memSem);
    if (mem) *mem++ = size;

    return mem;
}

/****************************************************************************/

void ASM
freeArbitrateVecPooled(REG(a0) APTR mem)
{
    ObtainSemaphore(&rexxLibBase->memSem);
    FreePooled(rexxLibBase->pool,(LONG *)mem-1,*((LONG *)mem-1));
    ReleaseSemaphore(&rexxLibBase->memSem);
}

/****************************************************************************/
