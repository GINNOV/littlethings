
#include <proto/exec.h>
#include <string.h>
#include "base.h"

/****************************************************************************/

char author[] = "\0$Author Alfonso Ranieri <alforan@tin.it>";
char LIBNAME[] = PRG;
struct libBase *libBase;

/****************************************************************************/

struct libBase *SAVEDS ASM
initLib (REG(a0) ULONG segList,REG(a6) APTR SysBase,REG(d0) struct libBase *base)
{
    base->sysBase        = SysBase;
    base->segList        = segList;
    base->dosBase        = NULL;
    base->utilityBase    = NULL;
    base->intuitionBase  = NULL;
    base->gfxBase        = NULL;
    base->localeBase     = NULL;
    base->muiMasterBase  = NULL;
    base->cat            = NULL;
    base->sitesListClass = NULL;
    base->class          = NULL;
    base->flags          = 0;
    base->freeDBBase     = NULL;

    memset(&base->libSem,0,sizeof(struct SignalSemaphore));
    InitSemaphore(&base->libSem);

    return libBase = base;
}

/****************************************************************************/

struct libBase * SAVEDS ASM
openLib(REG(a6) struct libBase *base)
{
    register struct ExecBase    *SysBase = base->sysBase;
    register struct libBase     *res = base;

    base->libNode.lib_OpenCnt++;
    base->libNode.lib_Flags &= ~LIBF_DELEXP;

    ObtainSemaphore(&base->libSem);
    if (!(base->flags & BASEFLG_INIT))
    {
        if (!initBase(base))
        {
            base->libNode.lib_OpenCnt--;
            res = NULL;
        }
    }
    ReleaseSemaphore(&base->libSem);

    return res;
}

/****************************************************************************/

ULONG SAVEDS ASM
expungeLib(REG(a6) struct libBase *base)
{
    if (base->libNode.lib_OpenCnt==0)
    {
        register struct ExecBase    *SysBase = base->sysBase;
        register ULONG              segList = base->segList;

        Remove((struct Node *)base);
        FreeMem((UBYTE *)base-base->libNode.lib_NegSize,base->libNode.lib_NegSize + base->libNode.lib_PosSize);

        return segList;
    }

    base->libNode.lib_Flags |= LIBF_DELEXP;

    return NULL;
}

/****************************************************************************/

ULONG SAVEDS ASM
closeLib(REG(a6) struct libBase *base)
{
    if (--base->libNode.lib_OpenCnt==0)
    {
        register struct ExecBase *SysBase = base->sysBase;

        ObtainSemaphore(&base->libSem);
        freeBase(base);
        ReleaseSemaphore(&base->libSem);

        if (base->libNode.lib_Flags & LIBF_DELEXP) return expungeLib(base);
    }

    return NULL;
}

/****************************************************************************/
