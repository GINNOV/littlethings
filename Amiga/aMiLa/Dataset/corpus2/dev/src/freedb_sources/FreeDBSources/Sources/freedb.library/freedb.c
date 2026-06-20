

#include "freedbmui.h"
#include <dos/dostags.h>

/***********************************************************************/

void
request(Object *app,Object *win,char *format,...)
{
    if (MUIMasterBase)
    {
        register char buf[64];

        if (app) sprintf(buf,"*_");
        else *buf = 0;
        strcat(buf,FreeDBGetString(MSG_Cancel));
        MUI_RequestA(app,win,0,"FreeDB",buf,format,(APTR)(&format+1));
    }
    else
    {
        register struct EasyStruct es;

        es.es_StructSize   = sizeof(struct EasyStruct);
        es.es_TextFormat   = format;
        es.es_Title        = "FreeDB";
        es.es_GadgetFormat = FreeDBGetString(MSG_Cancel);

        EasyRequestArgs(NULL,&es,NULL,(APTR)(&format+1));
    }
}

/***********************************************************************/

APTR SAVEDS ASM
FreeDBCreateAppA(REG(a0) struct TagItem *attrs)
{
    struct appMsg           msg;
    struct MsgPort          port;
    register struct Process *proc;
    register int            sig;

    ObtainSemaphore(&rexxLibBase->libSem);

    if (!(rexxLibBase->flags & BASEFLG_INITMUI))
    {
        register STRPTR name;
        register ULONG  ver;

        if ((rexxLibBase->muiMasterBase = OpenLibrary(name = "muimaster.library",ver = 19)) &&
            (rexxLibBase->iconBase = OpenLibrary(name = "icon.library",ver = 37)) &&
            initAppClass())
        {
            rexxLibBase->flags |= BASEFLG_INITMUI;
        }
        else
        {
            register ULONG err;

            if (rexxLibBase->muiMasterBase)
            {
                if (rexxLibBase->iconBase)
                {
                    CloseLibrary(rexxLibBase->iconBase);
                    rexxLibBase->iconBase = NULL;
                    err = FREEDBV_Err_NoMem;
                }
                else err = MSG_CantOpen;

                CloseLibrary(rexxLibBase->muiMasterBase);
                rexxLibBase->muiMasterBase = NULL;
            }
            else err = MSG_CantOpen;


            ReleaseSemaphore(&rexxLibBase->libSem);

            request(NULL,NULL,FreeDBGetString(err),name,ver);

            return NULL;
        }
    }

    ReleaseSemaphore(&rexxLibBase->libSem);

    if ((sig = AllocSignal(-1))==-1) return NULL;

    msg.flags = 0;

    if (!(msg.device = (STRPTR)GetTagData(FREEDBA_Device,0,attrs)))
    {
        msg.device = (STRPTR)GetTagData(FREEDBA_DeviceName,0,attrs);
        msg.unit   = 0;
        msg.flags  |= AMFGLS_DeviceName;
    }
    else
    {
        msg.unit = (UWORD)GetTagData(FREEDBA_Unit,0,attrs);
    }
    msg.lun = (UBYTE)GetTagData(FREEDBA_Lun,0,attrs);
    msg.prg = (STRPTR)GetTagData(FREEDBA_Prg,0,attrs);
    msg.ver = (STRPTR)GetTagData(FREEDBA_Ver,0,attrs);
    msg.flags |= (GetTagData(FREEDBA_UseSpace,TRUE,attrs) ? AMFGLS_UseSpace : 0) |
                 (GetTagData(FREEDBA_NoRequester,TRUE,attrs) ? AMFGLS_NoRequester : 0) |
                 (GetTagData(FREEDBA_GetDisc,TRUE,attrs) ? AMFGLS_GetDisc : 0) |
                 (GetTagData(FREEDBA_Local,FALSE,attrs) ? AMFGLS_GetDiscLocal : 0) |
                 (GetTagData(FREEDBA_Remote,FALSE,attrs) ? AMFGLS_GetDiscRemote : 0);

    INITPORT(&port,sig);
    INITMESSAGE(&msg,&port,sizeof(struct appMsg));

    if (proc = CreateNewProcTags(NP_Entry,       FreeDB,
                                 NP_Name,        "FreeDB",
                                 NP_CopyVars,    FALSE,
                                 NP_StackSize,   16000,
                                 NP_Input,       NULL,
                                 NP_CloseInput,  FALSE,
                                 NP_Output,      NULL,
                                 NP_CloseOutput, FALSE,
                                 NP_Error,       NULL,
                                 NP_CloseError,  FALSE,
                                 TAG_DONE))
    {
        PutMsg(&proc->pr_MsgPort,(struct Message *)&msg);
        WaitPort(&port);

        Forbid();
        rexxLibBase->use++;
        Permit();
    }

    FreeSignal(sig);

    return proc;
}

/***********************************************************************/
