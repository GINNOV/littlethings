
#include "proc.h"
#include "freedb.h"

/****************************************************************************/

static void
freeHandle(struct FREEDBS_Handle *handle)
{
    FreeSignal(handle->sig);
    freeArbitratePooled(handle,sizeof(struct FREEDBS_Handle));
}

/****************************************************************************/

struct FREEDBS_Handle * SAVEDS ASM
FreeDBHandleCreateA(REG(a0) struct TagItem *attrs)
{
    register struct FREEDBS_Handle  *handle;
    register int                    sig;

    if (((sig = AllocSignal(-1))!=-1) && (handle = allocArbitratePooled(sizeof(struct FREEDBS_Handle))))
    {
        InitSemaphore(&handle->sem);
        INITPORT(&handle->port,sig);
        handle->sig = sig;
    }
    else if (sig!=-1) FreeSignal(sig);

    return handle;
}

/****************************************************************************/

LONG SAVEDS ASM
FreeDBHandleCommandA(REG(a0) struct FREEDBS_Handle *handle,REG(d0) ULONG cmd,REG(a1) struct TagItem *attrs)
{
    register struct TagItem *tag;
    struct TagItem          *tstate;

    if (handle->flags & FREEDBV_Handle_Flags_InUse)
    {
        FreeDBHandleAbort(handle);
        FreeDBHandleWait(handle);
    }

    memset(&handle->msg,0,sizeof(struct FREEDBS_StartMsg));
    INITMESSAGE(&handle->msg,&handle->port,sizeof(struct FREEDBS_StartMsg));
    handle->msg.handle = handle;
    handle->msg.cmd = cmd;

    for (tstate = attrs; tag = NextTagItem(&tstate); )
    {
        register ULONG tidata = tag->ti_Data;

        switch(tag->ti_Tag)
        {
            case FREEDBA_TOC:
                handle->msg.toc = (struct FREEDBS_TOC *)tidata;
                break;

            case FREEDBA_DiscInfo:
                handle->msg.di = (struct FREEDBS_DiscInfo *)tidata;
                break;

            case FREEDBA_Categ:
                stccpy(handle->msg.categ,(STRPTR)tidata,sizeof(handle->msg.categ));
                break;

            case FREEDBA_DiscID:
                handle->msg.discID = tidata;
                break;

            case FREEDBA_StatusHook:
                handle->msg.statusHook = (struct Hook *)tidata;
                break;

            case FREEDBA_MultiHook:
                handle->msg.multiHook = (struct Hook *)tidata;
                break;

            case FREEDBA_SitesHook:
                handle->msg.sitesHook = (struct Hook *)tidata;
                break;

            case FREEDBA_LsCatHook:
                handle->msg.lsCatHook = (struct Hook *)tidata;
                break;

            case FREEDBA_Host:
                handle->msg.host = (STRPTR)tidata;
                break;

            case FREEDBA_HostPort:
                handle->msg.hostPort = (int)tidata;
                break;

            case FREEDBA_CGI:
                handle->msg.cgi = (STRPTR)tidata;
                break;

            case FREEDBA_Proxy:
                handle->msg.proxy = (STRPTR)tidata;
                break;

            case FREEDBA_ProxyPort:
                handle->msg.proxyPort = (int)tidata;

            case FREEDBA_UseProxy:
                handle->msg.useProxy = tidata;
                handle->msg.flags |= FREEDBV_StartMsg_Flags_UseProxySupplied;
                break;

            case FREEDBA_User:
                handle->msg.user = (STRPTR)tidata;
                break;

            case FREEDBA_Email:
                handle->msg.email = (STRPTR)tidata;
                break;

            case FREEDBA_Prg:
                handle->msg.prg = (STRPTR)tidata;
                break;

            case FREEDBA_Ver:
                handle->msg.ver = (STRPTR)tidata;
                break;

            case FREEDBA_ErrorBuffer:
                handle->msg.errorBuffer = (STRPTR)tidata;

            case FREEDBA_ErrorBufferLen:
                handle->msg.errorBufferLen = tidata;
                break;
        }
    }

    if (handle->proc = CreateNewProcTags(NP_Entry, FreeDBProc,
                                         NP_Name, "FreeDBProc",
                                         NP_CopyVars, FALSE,
                                         NP_StackSize, 12000,
                                         NP_Input, NULL,
                                         NP_CloseInput, FALSE,
                                         NP_Output, NULL,
                                         NP_CloseOutput, FALSE,
                                         NP_Error, NULL,
                                         NP_CloseError, FALSE,
                                         NP_CurrentDir, NULL,
                                         NP_HomeDir, NULL,
                                         TAG_DONE))
    {
        PutMsg(&handle->proc->pr_MsgPort,(struct Message *)&handle->msg);
        Forbid();
        rexxLibBase->use++;
        Permit();
        handle->flags |= FREEDBV_Handle_Flags_InUse;

        return 0;
    }
    else return FREEDBV_Err_NoMem;
}

/****************************************************************************/

ULONG SAVEDS ASM
FreeDBHandleSignal(REG(a0) struct FREEDBS_Handle *handle)
{
    return (ULONG)(1<<handle->sig);
}

/****************************************************************************/

LONG SAVEDS ASM
FreeDBHandleWait(REG(a0) struct FREEDBS_Handle *handle)
{
    if (!(handle->flags & FREEDBV_Handle_Flags_InUse))
        return FREEDBV_Err_NoMem;

    WaitPort(&handle->port);
    GetMsg(&handle->port);
    handle->flags &= ~FREEDBV_Handle_Flags_InUse;

    return handle->msg.err;
}

/****************************************************************************/

void SAVEDS ASM
FreeDBHandleAbort(REG(a0) struct FREEDBS_Handle *handle)
{
    ObtainSemaphore(&handle->sem);
    if (handle->proc) Signal((struct Task *)handle->proc,SIGBREAKF_CTRL_C);
    ReleaseSemaphore(&handle->sem);
}

/****************************************************************************/

ULONG SAVEDS ASM
FreeDBHandleCheck(REG(a0) struct FREEDBS_Handle *handle)
{
    register ULONG res;

    if (!(handle->flags & FREEDBV_Handle_Flags_InUse)) return 0;

    ObtainSemaphore(&handle->sem);
    res = !handle->proc;
    ReleaseSemaphore(&handle->sem);

    return res;
}

/****************************************************************************/

void SAVEDS ASM
FreeDBHandleFree(REG(a0) struct FREEDBS_Handle *handle)
{
    FreeDBHandleAbort(handle);
    FreeDBHandleWait(handle);
    freeHandle(handle);
}

/****************************************************************************/

LONG SAVEDS ASM
FreeDBHandleResult(REG(a0) struct FREEDBS_Handle *handle)
{
    return 0;
}

/****************************************************************************/

enum
{
    FREEDBV_GetDisc_Mode_LocalRemote,
    FREEDBV_GetDisc_Mode_Local,
    FREEDBV_GetDisc_Mode_Remote
};

LONG SAVEDS ASM
FreeDBGetDiscA(REG(a0) struct TagItem *attrs)
{
    register APTR *handlePtr;
    register LONG *errPtr, err, res, mode;

    handlePtr = (APTR *)GetTagData(FREEDBA_HandlePtr,0,attrs);
    if (handlePtr) *handlePtr = NULL;

    errPtr = (LONG *)GetTagData(FREEDBA_ErrorPtr,0,attrs);

    if (GetTagData(FREEDBA_Local,0,attrs)) mode = FREEDBV_GetDisc_Mode_Local;
    else if (GetTagData(FREEDBA_Remote,0,attrs)) mode = FREEDBV_GetDisc_Mode_Remote;
         else mode = FREEDBV_GetDisc_Mode_LocalRemote;

    switch (mode)
    {
        case FREEDBV_GetDisc_Mode_LocalRemote:
            switch (err = FreeDBGetLocalDiscA(attrs))
            {
                case 0:
                    res = FREEDBV_GetDisc_LocalFound;
                    break;

                case FREEDBV_Err_Multi:
                    res = FREEDBV_GetDisc_LocalMulti;
                    break;

                case FREEDBV_Err_NotFound:
                {
                    register APTR handle;

                    if (!(handle = (APTR)GetTagData(FREEDBA_Handle,0,attrs)))
                    {
                        if (!handlePtr)
                        {
                            err = FREEDBV_Err_NoParms;
                            res = FREEDBV_GetDisc_Error;
                            break;
                        }

                        if (!(handle = FreeDBHandleCreateA(attrs)))
                        {
                            err = FREEDBV_Err_NoMem;
                            res = FREEDBV_GetDisc_Error;
                            break;
                        }

                        *handlePtr = handle;
                    }

                    if (err = FreeDBHandleCommandA(handle,FREEDBV_Command_QueryRead,attrs))
                    {
                        if (handlePtr) FreeDBHandleFree(handle);
                        res = FREEDBV_GetDisc_Error;
                        break;
                    }

                    err = 0;
                    res = FREEDBV_GetDisc_Remote;

                    break;
                }

                default:
                    res = FREEDBV_GetDisc_Error;
                    break;
            }
            break;

        case FREEDBV_GetDisc_Mode_Local:
            switch (err = FreeDBGetLocalDiscA(attrs))
            {
                case 0:
                    res = FREEDBV_GetDisc_LocalFound;
                    break;

                case FREEDBV_Err_Multi:
                    res = FREEDBV_GetDisc_LocalMulti;
                    break;

                case FREEDBV_Err_NotFound:
                    res = FREEDBV_GetDisc_Error; //FREEDBV_GetDisc_Remote;
                    break;

                default:
                    res = FREEDBV_GetDisc_Error;
                    break;
            }
            break;

        case FREEDBV_GetDisc_Mode_Remote:
        {
            register APTR handle;

            if (!(handle = (APTR)GetTagData(FREEDBA_Handle,0,attrs)))
            {
                if (!handlePtr)
                {
                    err = FREEDBV_Err_NoParms;
                    res = FREEDBV_GetDisc_Error;
                    break;
                }

                if (!(handle = FreeDBHandleCreateA(attrs)))
                {
                    err = FREEDBV_Err_NoMem;
                    res = FREEDBV_GetDisc_Error;
                    break;
                }

                *handlePtr = handle;
            }

            if (err = FreeDBHandleCommandA(handle,FREEDBV_Command_QueryRead,attrs))
            {
                if (handlePtr) FreeDBHandleFree(handle);
                res = FREEDBV_GetDisc_Error;
                break;
            }

            err = 0;
            res = FREEDBV_GetDisc_Remote;

            break;
        }

        default:
            res = FREEDBV_GetDisc_Error;
            break;
    }

    if (errPtr) *errPtr = err;
    return res;
}

/***************************************************************************/
