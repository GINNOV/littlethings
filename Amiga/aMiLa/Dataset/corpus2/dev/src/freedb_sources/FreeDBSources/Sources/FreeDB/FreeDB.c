
#define LGLOBAL
#include "FreeDB.h"

/***********************************************************************/

char __ver[] = VERSTAG;

/***********************************************************************/

int main(void)
{
    struct global   g;
    register int    res = RETURN_FAIL;

    memset(&g,0,sizeof(struct global));

    g.sysBase = (*((struct ExecBase **)4L));
    g.this = (struct Process *)FindTask(NULL);

    if (!g.this->pr_CLI)
    {
        register struct MsgPort *port = &g.this->pr_MsgPort;

        WaitPort(port);
        g.wbs = (struct WBStartup *)GetMsg(port);
    }

    if (g.dOSBase = (struct DosLibrary *)OpenLibrary("dos.library",37))
    {
        if (g.intuitionBase = (APTR)OpenLibrary("intuition.library",37))
        {
            register struct Library *FreeDBBase;

            if (FreeDBBase = OpenLibrary(FreeDBName,FreeDBVersion))
            {
                res = RETURN_ERROR;

                if (parseArg(&g))
                {
                    if (FreeDBCreateApp(g.dtag, g.device,
                            FREEDBA_Unit,       g.unit,
                            FREEDBA_Lun,        g.lun,
                            FREEDBA_UseSpace,   !(g.flags & GFLG_NTUSESPACE),
                            FREEDBA_Prg,        PRG,
                            FREEDBA_Ver,        VRSTRING,
                            TAG_DONE)) res = RETURN_OK;

                    CloseLibrary(FreeDBBase);
                }
                CloseLibrary((struct Library *)g.intuitionBase);
            }
            else request(&g,"Cant open %s ver %ls or higher.",FreeDBName,FreeDBVersion);
        }
        else g.this->pr_Result2 = ERROR_INVALID_RESIDENT_LIBRARY;

        CloseLibrary((struct Library *)g.dOSBase);
    }
    else g.this->pr_Result2 = ERROR_INVALID_RESIDENT_LIBRARY;

    if (g.wbs)
    {
        Forbid();
        ReplyMsg(MESSAGE(g.wbs));
    }

    return res;
}

/***********************************************************************/
