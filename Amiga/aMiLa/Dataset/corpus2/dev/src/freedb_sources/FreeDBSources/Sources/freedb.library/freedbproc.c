
#include "freedbmui.h"

/***********************************************************************/

void SAVEDS
FreeDB(void)
{
    struct Process          *me = (struct Process *)FindTask(NULL);
    register struct appMsg  *msg;
    register Object         *app, *window, *disc;
    register char           device[256], prg[256], ver[64];
    register Tag            dtag;
    register ULONG          flags;
    register UWORD          unit;
    register UBYTE          lun;

    WaitPort(&me->pr_MsgPort);
    msg = (struct appMsg *)GetMsg(&me->pr_MsgPort);

    flags = msg->flags;

    if (msg->device)
    {
        stccpy(device,msg->device,sizeof(device));
        dtag = (flags & AMFGLS_DeviceName) ? FREEDBA_DeviceName : FREEDBA_Device;

    }
    else dtag = TAG_IGNORE;

    if (msg->prg) stccpy(prg,msg->prg,sizeof(prg));
    else *prg = 0;
    if (msg->ver) stccpy(ver,msg->ver,sizeof(ver));
    else *ver = 0;
    unit = msg->unit;
    lun  = msg->lun;

    ReplyMsg((struct Message *)msg);

    if (app = FreeDBAppObject,
        (flags & AMFGLS_DeviceName) ? FREEDBA_DeviceName : FREEDBA_Device, device,
        FREEDBA_Unit, unit,
        FREEDBA_Lun, lun,
        SubWindow, window = WindowObject,
            MUIA_Window_Title, FreeDBGetString(MSG_WinTitle),
            MUIA_Window_ID, MAKE_ID('M','A','I','N'),
            WindowContents, VGroup,
                Child, disc = FreeDBDiscObject,
                    dtag, device,
                    FREEDBA_Unit, unit,
                    FREEDBA_Lun, lun,
                    MUIA_FreeDB_Disc_UseSpace, flags & AMFGLS_UseSpace,
                    *prg ? FREEDBA_Prg : TAG_IGNORE, prg,
                    *ver ? FREEDBA_Ver : TAG_IGNORE, ver,
                End,
            End,
        End,
    End)
    {
        struct Window   *win;
        ULONG           signals;

        DoMethod(app,MUIM_FreeDB_App_Setup,disc,window);

        DoMethod(window,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,app,2,
            MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit);

        DoMethod(disc,MUIM_Notify,MUIA_FreeDB_Disc_DoubleClick,MUIV_EveryTime,
            MUIV_Notify_Self,2,MUIM_FreeDB_Disc_Play,MUIV_FreeDB_Disc_Play_Active);

        DoMethod(disc,MUIM_FreeDB_Disc_Setup);

        if (flags & AMFGLS_NoRequester)
        {
            win = me->pr_WindowPtr;
            me->pr_WindowPtr = (struct Window *)-1;
        }

        set(window,MUIA_Window_Open,TRUE);

        if (flags & AMFGLS_GetDisc)
        {
            register ULONG mode = 0;

            if (flags & AMFGLS_GetDiscLocal)
                mode = MUIV_FreeDB_Disc_GetDisc_Flags_ForceLocal;

            if (flags & AMFGLS_GetDiscRemote)
                mode |= MUIV_FreeDB_Disc_GetDisc_Flags_ForceRemote;

            DoMethod(disc,MUIM_FreeDB_Disc_GetDisc,NULL,mode);
        }

        for (signals = 0; DoMethod(app,MUIM_Application_NewInput,&signals)!=MUIV_Application_ReturnID_Quit; )
            if (signals && ((signals = Wait(signals | SIGBREAKF_CTRL_C)) & SIGBREAKF_CTRL_C))
                break;

        set(window,MUIA_Window_Open,FALSE);
        MUI_DisposeObject(app);

        if (flags & AMFGLS_NoRequester)
            me->pr_WindowPtr = win;
    }
    else request(NULL,NULL,FreeDBGetString(MSG_NoApp));

    Forbid();
    rexxLibBase->use--;
}

/***********************************************************************/
