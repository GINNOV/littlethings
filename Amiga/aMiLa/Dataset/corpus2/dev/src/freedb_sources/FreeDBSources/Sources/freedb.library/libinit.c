
#include <proto/exec.h>
#include <proto/locale.h>
#include <exec/memory.h>
#include <string.h>
#include "freedbbase.h"
#include <rexx/rexxlibrary.h>

/****************************************************************************/

char author[] = "\0$Author Alfonso Ranieri <alforan@tin.it>";
char LIBNAME[] = PRG;
STRPTR rexxStemErrorVarName = "FREEDBERROR";
struct rexxLibBase *rexxLibBase;

BOOL ASM initBase(REG(a0) struct rexxLibBase *base);
void ASM freeBase(REG(a0) struct rexxLibBase *base);

/****************************************************************************/

struct  rexxLibBase * SAVEDS ASM
initLib(REG(a0) ULONG segList,REG(a6) APTR SysBase,REG(d0) struct rexxLibBase *base)
{
    if ((base->dosBase = (struct DosLibrary *)OpenLibrary("dos.library",37)) &&
        (base->intuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",37)) &&
        (base->utilityBase = OpenLibrary("utility.library",37)) &&
        (base->pool = CreatePool(MEMF_PUBLIC|MEMF_CLEAR,4096,512)))
    {
        base->sysBase       = SysBase;
        base->segList       = segList;
        base->rexxSysBase   = NULL;
        base->localeBase    = NULL;
        base->muiMasterBase = NULL;
        base->cat           = NULL;
        base->flags         = 0;
        base->use           = 0;
        base->freeMessages  = 0;
        base->opts          = &opts;
        base->appClass      = NULL;

        memset(&base->libSem,0,sizeof(struct SignalSemaphore));
        InitSemaphore(&base->libSem);

        memset(&base->memSem,0,sizeof(struct SignalSemaphore));
        InitSemaphore(&base->memSem);

        NEWLIST(&base->messages);

        return rexxLibBase = base;
    }
    else
    {
        if (base->dosBase)
        {
            if (base->intuitionBase)
            {
                if (base->utilityBase) CloseLibrary(base->utilityBase);
                CloseLibrary((struct Library *)base->intuitionBase);
            }
            CloseLibrary((struct Library *)base->dosBase);
        }

        FreeMem((UBYTE *)base-base->libNode.lib_NegSize,base->libNode.lib_NegSize+base->libNode.lib_PosSize);

        return NULL;
    }
}

/****************************************************************************/

LONG ASM readConfig(REG(a0) struct FREEDBS_Config *,REG(a1) STRPTR name);

struct rexxLibBase * SAVEDS ASM
openLib(REG(a6) struct rexxLibBase *base)
{
    register struct ExecBase    *SysBase = base->sysBase;
    register struct rexxLibBase *res = base;

    base->libNode.lib_OpenCnt++;
    base->libNode.lib_Flags &= ~LIBF_DELEXP;

    ObtainSemaphore(&base->libSem);

    if (!(base->flags & BASEFLG_INIT) && !initBase(base))
    {
        base->libNode.lib_OpenCnt--;
        res = NULL;
    }

    ReleaseSemaphore(&base->libSem);

    return res;
}

/***********************************************************************/

ULONG SAVEDS ASM
expungeLib(REG(a6) struct rexxLibBase *base)
{
    base->libNode.lib_Flags |= LIBF_DELEXP;

    if (!base->libNode.lib_OpenCnt && !base->use)
    {
        register struct ExecBase    *SysBase = base->sysBase;
        register ULONG              segList = base->segList;

        Remove((struct Node *)base);

        freeBase(base);
        DeletePool(base->pool);
        CloseLibrary(base->utilityBase);
        CloseLibrary((struct Library *)base->intuitionBase);
        CloseLibrary((struct Library *)base->dosBase);

        FreeMem((UBYTE *)base-base->libNode.lib_NegSize,base->libNode.lib_NegSize+base->libNode.lib_PosSize);

        return segList;
    }

    return NULL;
}

/****************************************************************************/

ULONG ASM
closeLib(REG(a6) struct rexxLibBase *base)
{
    return (!--base->libNode.lib_OpenCnt && !base->use && (base->libNode.lib_Flags & LIBF_DELEXP)) ?
        expungeLib(base) : NULL;
}

/****************************************************************************/
