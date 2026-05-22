
#include "class.h"

/***********************************************************************/

struct data
{
    struct SignalSemaphore      sem;

    struct FREEDBS_DiscInfo     *di;
    struct FREEDBS_TOC          *toc;
    APTR                        handle;

    struct Hook                 statusHook;
    struct Hook                 multiHook;

    ULONG                       flags;
    ULONG                       status;
    LONG                        active;

    char                        device[256];
    Tag                         dtag;
    UWORD                       unit;
    UBYTE                       lun;
    char                        prg[64];
    char                        ver[32];

    struct MUI_InputHandlerNode ih;

    Object                      *app;
    Object                      *win;
    Object                      *this;
    Object                      *sb;
    Object                      *pager;
    Object                      *discInfo;
    Object                      *matches;
    Object                      *edit;
    Object                      *info;
};

enum
{
    FREEDBV_Disc_Flags_Setup      =  1,
    FREEDBV_Disc_Flags_TOC        =  2,
    FREEDBV_Disc_Flags_DiscInfo   =  4,
    FREEDBV_Disc_Flags_Submitting =  8,
    FREEDBV_Disc_Flags_Update     = 16,
    FREEDBV_Disc_Flags_Disc       = 32,
};

/***********************************************************************/

static SAVEDS ASM LONG
statusFun(REG(a0) struct Hook *hook,REG(a1) ULONG status,REG(a2) APTR handle)
{
    register struct data *data = (struct data *)hook->h_Data;

    if (data->app)
        DoMethod(data->app,MUIM_Application_PushMethod,data->this,2,MUIM_FreeDB_Disc_SetError,status);

    return 0;
}

/***********************************************************************/

static SAVEDS ASM LONG
multiFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_MultiHookMessage *msg,REG(a2) APTR handle)
{
    register struct data *data = (struct data *)hook->h_Data;

        if (data->app)
            DoMethod(data->app,MUIM_Application_PushMethod,data->matches,3,MUIM_NList_InsertSingle,msg,MUIV_NList_Insert_Bottom);

    return 0;
}

/***********************************************************************/

#define hleft(obj) (HGroup, GroupSpacing(0), Child, (obj), Child, HSpace(0), End)

struct SBButton sbuttons[] =
{
    SBENTRY("Get",MSG_Get,MSG_Get_Help,0,0),
    SBENTRY("Save",MSG_Save,MSG_Save_Help,MUIV_SpeedBar_ButtonFlag_Disabled,0),
    SBENTRY("Stop",MSG_Stop,MSG_Stop_Help,MUIV_SpeedBar_ButtonFlag_Disabled,0),
    SBSPACER,
    SBENTRY("Disc",MSG_Disc,MSG_Disc_Help,MUIV_SpeedBar_ButtonFlag_Immediate|MUIV_SpeedBar_ButtonFlag_Selected,(1<<BMATCHES)|(1<<BEDIT)),
    SBENTRY("Matches",MSG_Matches,MSG_Matches_Help,MUIV_SpeedBar_ButtonFlag_Immediate,(1<<BDISC)|(1<<BEDIT)),
    SBENTRY("Edit",MSG_Edit,MSG_Edit_Help,MUIV_SpeedBar_ButtonFlag_Immediate,(1<<BDISC)|(1<<BMATCHES)),
    SBEND
};

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register struct FREEDBS_DiscInfo    *di;
    register struct FREEDBS_TOC         *toc;
    register APTR                       handle;
    register struct TagItem             *attrs = msg->ops_AttrList;
    register Object                     *sb, *pager, *discInfo, *matches, *edit, *info;

    if ((di = FreeDBAllocObject(FREEDBV_AllocObject_DiscInfo,TAG_DONE)) &&
        (toc = FreeDBAllocObject(FREEDBV_AllocObject_TOC,TAG_DONE)) &&
       (handle = FreeDBHandleCreateA(NULL)) &&
       (obj = (Object *)DoSuperNew(cl,obj,
            Child, hleft((sb = barObject,
                MUIA_FreeDB_Bar_ImagesDrawer, FREEDBV_ImagesDir,
                MUIA_FreeDB_Bar_Buttons, sbuttons,
                MUIA_FreeDB_Bar_Spacer, "Space",
                MUIA_FreeDB_Disc_UseSpace, GetTagData(MUIA_FreeDB_Disc_UseSpace,TRUE,attrs),
            End)),
            Child, pager = VGroup,
                MUIA_Group_PageMode, TRUE,
                Child, discInfo = discInfoObject,
                End,
                Child, NListviewObject,
                    MUIA_CycleChain, 1,
                    MUIA_NListview_NList, matches = multiMatchesListObject,
                    End,
                End,
                Child, edit = editObject,
                End,
            End,
            Child, info = textObject(-1,"\33c",FALSE),
        TAG_MORE,attrs)))
    {
        register struct data    *data = INST_DATA(cl,obj);
        register STRPTR         tidata;

        memset(&data->sem,0,sizeof(struct SignalSemaphore));
        InitSemaphore(&data->sem);

        data->di         = di;
        data->toc        = toc;
        data->handle     = handle;

        data->statusHook.h_Entry = (APTR)statusFun;
        data->statusHook.h_Data  = data;
        data->multiHook.h_Entry  = (APTR)multiFun;
        data->multiHook.h_Data   = data;

        data->flags      = 0;
        data->status     = MUIV_FreeDB_Disc_Status_None;
        data->active     = -1;

        if (tidata = (STRPTR)GetTagData(FREEDBA_Device,0,attrs))
        {
            data->dtag = FREEDBA_Device;
            data->unit = (UWORD)GetTagData(FREEDBA_Unit,0,attrs);
        }
        else
        {
            tidata = (STRPTR)GetTagData(FREEDBA_DeviceName,(ULONG)"CD0",attrs);
            data->dtag = FREEDBA_DeviceName;
            data->unit = 0;
        }
        stccpy(data->device,tidata,sizeof(data->device));
        data->lun = (UBYTE)GetTagData(FREEDBA_Lun,0,attrs);

        tidata = (STRPTR)GetTagData(FREEDBA_Prg,(ULONG)PRG,attrs);
        stccpy(data->prg,tidata,sizeof(data->prg));

        tidata = (STRPTR)GetTagData(FREEDBA_Ver,(ULONG)VRSTRING,attrs);
        stccpy(data->ver,tidata,sizeof(data->ver));

        data->ih.ihn_Object  = obj;
        data->ih.ihn_Signals = FreeDBHandleSignal(handle);
        data->ih.ihn_Method  = MUIM_FreeDB_Disc_HandleEvent;
        data->ih.ihn_Flags   = 0;

        data->app        = NULL;
        data->win        = NULL;
        data->this       = obj;
        data->sb         = sb;
        data->pager      = pager;
        data->discInfo   = discInfo;
        data->matches    = matches;
        data->edit       = edit;
        data->info       = info;

        DoMethod(sb,MUIM_FreeDB_Bar_Notify,BGET,MUIA_Pressed,0,obj,3,MUIM_FreeDB_Disc_GetDisc,NULL,0);
        DoMethod(sb,MUIM_FreeDB_Bar_Notify,BSAVE,MUIA_Pressed,0,obj,1,MUIM_FreeDB_Disc_Save);
        DoMethod(sb,MUIM_FreeDB_Bar_Notify,BSTOP,MUIA_Pressed,0,obj,1,MUIM_FreeDB_Disc_Break);

        DoMethod(sb,MUIM_Notify,MUIA_FreeDB_Bar_Active,BDISC,pager,3,MUIM_Set,MUIA_Group_ActivePage,0);
        DoMethod(sb,MUIM_Notify,MUIA_FreeDB_Bar_Active,BMATCHES,pager,3,MUIM_Set,MUIA_Group_ActivePage,1);
        DoMethod(sb,MUIM_Notify,MUIA_FreeDB_Bar_Active,BEDIT,obj,1,MUIM_FreeDB_Disc_Edit);

        DoMethod(pager,MUIM_Notify,MUIA_Group_ActivePage,0,sb,3,MUIM_Set,MUIA_FreeDB_Bar_Active,BDISC);
        DoMethod(pager,MUIM_Notify,MUIA_Group_ActivePage,1,sb,3,MUIM_Set,MUIA_FreeDB_Bar_Active,BMATCHES);
        DoMethod(pager,MUIM_Notify,MUIA_Group_ActivePage,2,sb,3,MUIM_Set,MUIA_FreeDB_Bar_Active,BEDIT);

        DoMethod(discInfo,MUIM_Notify,MUIA_FreeDB_DiscInfo_ActiveTitle,MUIV_EveryTime,obj,3,MUIM_Set,MUIA_FreeDB_Disc_ActiveTitle,MUIV_TriggerValue);
        DoMethod(discInfo,MUIM_Notify,MUIA_FreeDB_DiscInfo_DoubleClick,TRUE,obj,3,MUIM_Set,MUIA_FreeDB_Disc_DoubleClick,TRUE);

        DoMethod(matches,MUIM_Notify,MUIA_NList_DoubleClick,TRUE,obj,1,MUIM_FreeDB_Disc_GetMatch);

        DoMethod(obj,MUIM_Notify,MUIA_FreeDB_Disc_ActiveTitle,MUIV_EveryTime,obj,3,MUIM_Set,MUIA_FreeDB_DiscInfo_ActiveTitle,MUIV_TriggerValue);

        DoMethod(edit,MUIM_FreeDB_Edit_Setup,obj);
        DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_Welcome,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
    }
    else
    {
        if (di)
        {
            if (toc)
            {
                if (handle) FreeDBHandleFree(handle);
                FreeDBFreeObject(toc);
            }
            FreeDBFreeObject(di);
        }
    }

    return (ULONG)obj;
}

/***********************************************************************/

static ASM ULONG
mSetStatus(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_SetStatus *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          string;

    switch (msg->mode)
    {
        case MUIV_FreeDB_Disc_SetStatus_Mode_Status:
            string = (ULONG)strings[msg->string];
            break;

        case MUIV_FreeDB_Disc_SetStatus_Mode_Error:
            string = (ULONG)FreeDBGetString(msg->string);
            break;

        case MUIV_FreeDB_Disc_SetStatus_Mode_String:
            string = (ULONG)msg->string;
            break;
    }

    set(data->info,MUIA_Text_Contents,string);

    return 0;
}

/***********************************************************************/

static ASM ULONG
mSetError(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_SetError *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (data->status!=MUIV_FreeDB_Disc_Status_None)
        DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,msg->err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);

    return 0;
}

/***********************************************************************/

static ASM ULONG
mEdit(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_SetError *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (data->flags & FREEDBV_Disc_Flags_Update)
    {
        DoMethod(data->edit,MUIM_FreeDB_Edit_InfoToGadgets);
        data->flags &= ~FREEDBV_Disc_Flags_Update;
    }

    set(data->pager,MUIA_Group_ActivePage,2);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mGetDisc(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_GetDisc *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          res;
    ULONG                   err;

    set(data->pager,MUIA_Group_ActivePage,0);
    setbar(data->sb,BSAVE,MUIA_Disabled,TRUE);
    DoMethod(obj,MUIM_FreeDB_Disc_ObtainInfo,NULL,NULL);

    set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_LookingUp);
    FreeDBClearObject(data->di);
    FreeDBClearObject(data->toc);

    DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_ReadingTOC,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
    data->flags &= ~FREEDBV_Disc_Flags_TOC;

    if (msg->toc) memcpy(data->toc,msg->toc,sizeof(struct FREEDBS_TOC));
    else
        if (err = FreeDBReadTOC(FREEDBA_TOC,data->toc,
                                data->dtag, data->device,
                                FREEDBA_Unit,data->unit,
                                FREEDBA_Lun,data->lun,
                                TAG_DONE))
        {
            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_None);
            return err;
        }

    data->flags |= FREEDBV_Disc_Flags_TOC;

    switch (res = FreeDBGetDisc(FREEDBA_Handle, data->handle,
                                FREEDBA_TOC, data->toc,
                                FREEDBA_DiscInfo, data->di,
                                FREEDBA_StatusHook, &data->statusHook,
                                FREEDBA_MultiHook, &data->multiHook,
                                FREEDBA_Local, msg->flags & MUIV_FreeDB_Disc_GetDisc_Flags_ForceLocal,
                                FREEDBA_Remote, msg->flags & MUIV_FreeDB_Disc_GetDisc_Flags_ForceRemote,
                                FREEDBA_ErrorPtr, &err,
                                TAG_DONE))
    {
        case FREEDBV_GetDisc_LocalFound:
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_LocalFound);
            break;

        case FREEDBV_GetDisc_LocalMulti:
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_MultiMatches);
            break;

        case FREEDBV_GetDisc_Remote:
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_RemoteLookingUp);
            break;

        case FREEDBV_GetDisc_Error:
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_None);
            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
            break;
    }

    return err;
}

/***********************************************************************/

static ULONG ASM
mGetMatch(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data            *data = INST_DATA(cl,obj);
    struct FREEDBS_MultiHookMessage *m;
    register ULONG                  err;

    set(data->pager,MUIA_Group_ActivePage,0);
    setbar(data->sb,BSAVE,MUIA_Disabled,TRUE);
    DoMethod(obj,MUIM_FreeDB_Disc_ObtainInfo,NULL,NULL);

    DoMethod(data->matches,MUIM_NList_GetEntry,MUIV_NList_GetEntry_Active,&m);
    if (!m)
    {
        DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
        return 0;
    }

    set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_LookingUpMatch);
    FreeDBClearObject(data->di);

    switch (m->code)
    {
        case 0:
            switch (err = FreeDBGetLocalDisc(FREEDBA_Categ,m->categ,
                                             FREEDBA_DiscID,m->discID,
                                             FREEDBA_DiscInfo,data->di,
                                             FREEDBA_MultiHook,&data->multiHook,
                                             TAG_DONE))
            {
                case 0:
                    set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_LocalFound);
                    break;

                default:
                    DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
                    set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_None);
                    break;
            }
            break;

        default:
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_RemoteLookingUpMatch);
            data->di->discID = m->discID;
            strcpy(data->di->categ,m->categ);
            if (err = FreeDBHandleCommand(data->handle,FREEDBV_Command_Read,
                FREEDBA_TOC,        data->toc,
                FREEDBA_DiscInfo,   data->di,
                FREEDBA_Categ,      m->categ,
                FREEDBA_DiscID,     m->discID,
                FREEDBA_StatusHook, &data->statusHook,
                FREEDBA_MultiHook,  &data->multiHook,
                TAG_DONE))
            {
                DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
                set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_None);
            }
            break;
    }

    return err;
}

/***********************************************************************/

static ULONG ASM
mSubmit(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data   *data = INST_DATA(cl,obj);
    register ULONG         err;

    DoMethod(obj,MUIM_FreeDB_Disc_ObtainInfo,NULL,NULL);

    data->flags |= FREEDBV_Disc_Flags_Submitting;
    setbar(data->sb,BSTOP,MUIA_Disabled,FALSE);

    if (err = FreeDBHandleCommand(data->handle,FREEDBV_Command_Submit,
                FREEDBA_TOC,        data->toc,
                FREEDBA_DiscInfo,   data->di,
                FREEDBA_StatusHook, &data->statusHook,
                FREEDBA_Prg,        data->prg,
                FREEDBA_Ver,        data->ver,
                TAG_DONE))
    {
        DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
        data->flags &= ~FREEDBV_Disc_Flags_Submitting;
    }

    return err;
}

/***********************************************************************/

static ULONG ASM
mHandleEvent(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register LONG           err;

    if (!FreeDBHandleCheck(data->handle)) return 0;

    switch (err = FreeDBHandleWait(data->handle))
    {
        case 0:
            if (data->flags & FREEDBV_Disc_Flags_Submitting)
            {
                data->flags &= ~FREEDBV_Disc_Flags_Submitting;
                setbar(data->sb,BSTOP,MUIA_Disabled,TRUE);
                DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
            }
            else set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_RemoteFound);
            break;

        case FREEDBV_Err_Multi:
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_MultiMatches);
            break;

        case FREEDBV_Err_NotFound:
            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,FREEDBV_Err_NotFound,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
            set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_None);
            break;

        default:
            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
            if (data->flags & FREEDBV_Disc_Flags_Submitting)
            {
                data->flags &= ~FREEDBV_Disc_Flags_Submitting;
                setbar(data->sb,BSTOP,MUIA_Disabled,TRUE);
                DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
            }
            else set(obj,MUIA_FreeDB_Disc_Status,MUIV_FreeDB_Disc_Status_None);
            break;
    }

    return 1;
}

/***********************************************************************/

static ULONG ASM
mBreak(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    FreeDBHandleAbort(data->handle);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mSave(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register LONG           err, overWrite;

    setbar(data->sb,BSAVE,MUIA_Disabled,TRUE);
    DoMethod(obj,MUIM_FreeDB_Disc_ObtainInfo,NULL,NULL);

    for (overWrite = 0; ; )
        switch (err = FreeDBSaveLocalDisc(FREEDBA_TOC, data->toc,
                                          FREEDBA_DiscInfo,  data->di,
                                          FREEDBA_UseTOCID,  TRUE,
                                          FREEDBA_OverWrite, overWrite,
                                          FREEDBA_Prg,       data->prg,
                                          FREEDBA_Ver,       data->ver,
                                          TAG_DONE))
        {
            case 0:
                DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_Saved,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
                goto end;

            case FREEDBV_Err_FileExists:
            {
                Object *win;

                get(obj,MUIA_WindowObject,&win);
                ObtainSemaphoreShared(&data->sem);
                overWrite = MUI_Request(data->app,win,0,"FreeDB",strings[MSG_SaveCancel],strings[MSG_SaveFile],data->toc->discID,data->di->categ);
                ReleaseSemaphore(&data->sem);
                if (!overWrite) goto end;
                break;
            }

            default:
                DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,err,MUIV_FreeDB_Disc_SetStatus_Mode_Error);
                goto end;
                break;
        }

end:
    DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
    if (err) setbar(data->sb,BSAVE,MUIA_Disabled,FALSE);

    return (ULONG)err;
}

/***********************************************************************/

static ASM ULONG
mObtainInfo(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_ObtainInfo *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          res = 0;

    ObtainSemaphore(&data->sem);

    DoMethod(data->sb,MUIM_FreeDB_Bar_Disable,0);
    DoMethod(data->edit,MUIA_Disabled,TRUE);

    if (msg->di)
    {
        *msg->di = data->di;
        if (data->flags & FREEDBV_Disc_Flags_DiscInfo) res |= MUIV_FreeDB_Disc_ObtainInfo_Res_DiscInfo;
    }

    if (msg->toc)
    {
        *msg->toc = data->toc;
        if (data->flags & FREEDBV_Disc_Flags_TOC) res |= MUIV_FreeDB_Disc_ObtainInfo_Res_TOC;
    }

    return res;
}

/***********************************************************************/

static ASM ULONG
mReleaseInfo(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_ReleaseInfo *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    DoMethod(data->sb,MUIM_FreeDB_Bar_Disable,1);

    if (msg->update)
    {
        setbar(data->sb,BSAVE,MUIA_Disabled,FALSE);
        setbar(data->sb,BSTOP,MUIA_Disabled,TRUE);
        DoMethod(data->discInfo,MUIM_FreeDB_DiscInfo_SetContents,data->di,data->toc,MUIV_FreeDB_DiscInfo_SetContents_Flags_ClearList);
        setsuper(cl,obj,MUIA_FreeDB_Disc_Disc,TRUE);
        data->flags |= FREEDBV_Disc_Flags_DiscInfo;
    }

    DoMethod(data->edit,MUIA_Disabled,FALSE);
    ReleaseSemaphore(&data->sem);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          viewMode = MUIV_SpeedBar_ViewMode_Gfx, borderLess = FALSE,
                            sunny = FALSE, raising = FALSE, small = FALSE;
    ULONG                   *p;

    if (DoMethod(obj,MUIM_GetConfigItem,MUIA_FreeDB_Bar_ViewMode,&p))
        viewMode = *p;

    if (DoMethod(obj,MUIM_GetConfigItem,MUIA_FreeDB_Bar_Sunny,&p))
        sunny = *p;

    if (DoMethod(obj,MUIM_GetConfigItem,MUIA_FreeDB_Bar_Borderless,&p))
        borderLess = *p;

    if (DoMethod(obj,MUIM_GetConfigItem,MUIA_FreeDB_Bar_Raising,&p))
        raising = *p;

    if (DoMethod(obj,MUIM_GetConfigItem,MUIA_FreeDB_Bar_Small,&p))
        small = *p;

    SetAttrs(data->sb,MUIA_SpeedBar_Borderless,     borderLess,
                      MUIA_SpeedBar_ViewMode,       viewMode,
                      MUIA_SpeedBar_RaisingFrame,   raising,
                      MUIA_SpeedBar_Sunny,          sunny,
                      MUIA_SpeedBar_SmallImages,    small,
                      TAG_DONE);

    if (!DoSuperMethodA(cl,obj,msg)) return FALSE;

    ObtainSemaphore(&data->sem);

    if (!(data->flags & FREEDBV_Disc_Flags_Setup))
    {
        DoMethod(data->app = _app(obj),MUIM_Application_AddInputHandler,&data->ih);
        data->flags |= FREEDBV_Disc_Flags_Setup;
    }

    data->win = _win(obj);

    ReleaseSemaphore(&data->sem);

    return TRUE;
}

/***********************************************************************/

static ULONG ASM
mCleanup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    data->win = NULL;

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ULONG ASM
mFreeDBSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          res;

    ObtainSemaphore(&data->sem);

    if (!(data->flags & FREEDBV_Disc_Flags_Setup))
    {
        Object *app;

        get(obj,MUIA_ApplicationObject,&app);
        if (app)
        {
            DoMethod(data->app = app,MUIM_Application_AddInputHandler,&data->ih);
            data->flags |= FREEDBV_Disc_Flags_Setup;
            res = 1;
        }
        else res = 0;
    }

    ReleaseSemaphore(&data->sem);

    return res;
}

/***********************************************************************/

static ULONG ASM
mRemove(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_Remove *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    FreeDBHandleAbort(data->handle);
    FreeDBHandleWait(data->handle);

    ObtainSemaphore(&data->sem);

    if (data->flags & FREEDBV_Disc_Flags_Setup)
    {
        DoMethod(data->app,MUIM_Application_RemInputHandler,&data->ih);
        data->flags &= ~FREEDBV_Disc_Flags_Setup;
    }

    data->app = NULL;

    ReleaseSemaphore(&data->sem);

    if (msg->parent) DoMethod(msg->parent,OM_REMMEMBER,obj);

    return 0;
}

/***********************************************************************/

static ASM ULONG
mGet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    switch(msg->opg_AttrID)
    {
        case MUIA_FreeDB_Disc_Disc:
            *msg->opg_Storage = data->flags & FREEDBV_Disc_Flags_Disc;
            return 1;

        case MUIA_FreeDB_Disc_Status:
            *msg->opg_Storage = data->status;
            return 1;

        case MUIA_FreeDB_Disc_ActiveTitle:
            *msg->opg_Storage = data->active;
            return 1;

        case MUIA_FreeDB_Disc_DoubleClick:
            *msg->opg_Storage = 0;
            return 1;

        case MUIA_Version:
            *msg->opg_Storage = VERSION;
            return 1;

        case MUIA_Revision:
            *msg->opg_Storage = REVISION;
            return 1;

        default:
            return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

static ASM ULONG
mSets(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register struct TagItem *tag;
    struct TagItem          *tstate;

    for (tstate = msg->ops_AttrList; tag = NextTagItem(&tstate); )
    {
        register ULONG tidata = tag->ti_Data;

        switch(tag->ti_Tag)
        {
            case MUIA_FreeDB_Disc_ActiveTitle:
                if (data->active==tidata)
                    tag->ti_Tag = TAG_IGNORE;
                else data->active = tidata;
                break;

            case MUIA_FreeDB_Disc_Disc:
                if (tidata)
                    if (data->flags & FREEDBV_Disc_Flags_Disc) tag->ti_Tag = TAG_IGNORE;
                    else data->flags |= FREEDBV_Disc_Flags_Disc;
                else
                    if (data->flags & FREEDBV_Disc_Flags_Disc) data->flags &= ~FREEDBV_Disc_Flags_Disc;
                    else tag->ti_Tag = TAG_IGNORE;
                break;

            case MUIA_FreeDB_Disc_Status:
            {
                if (data->status==tidata)
                {
                    tag->ti_Tag = TAG_IGNORE;
                    break;
                }

                switch (tidata)
                {
                    case MUIV_FreeDB_Disc_Status_None:
                        set(data->matches,MUIA_NList_Quiet,FALSE);
                        if (data->flags & FREEDBV_Disc_Flags_TOC)
                        {
                            DoMethod(data->discInfo,MUIM_FreeDB_DiscInfo_SetContents,NULL,data->toc,0);
                            set(obj,MUIA_FreeDB_Disc_Disc,TRUE);
                        }
                        data->flags |= FREEDBV_Disc_Flags_Update;
                        data->flags &= ~FREEDBV_Disc_Flags_DiscInfo;
                        DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
                        break;

                    case MUIV_FreeDB_Disc_Status_LookingUp:
                        set(data->matches,MUIA_NList_Quiet,TRUE);
                        DoMethod(data->matches,MUIM_NList_Clear);
                        DoMethod(data->discInfo,MUIM_FreeDB_DiscInfo_SetContents,NULL,NULL,MUIV_FreeDB_DiscInfo_SetContents_Flags_Clear);
                        set(obj,MUIA_FreeDB_Disc_Disc,FALSE);
                        data->flags &= ~FREEDBV_Disc_Flags_DiscInfo;
                        break;

                    case MUIV_FreeDB_Disc_Status_RemoteLookingUp:
                        setbar(data->sb,BSTOP,MUIA_Disabled,FALSE);
                        break;

                    case MUIV_FreeDB_Disc_Status_MultiMatches:
                        set(data->matches,MUIA_NList_Quiet,FALSE);
                        set(data->pager,MUIA_Group_ActivePage,1);
                        if (data->status==MUIV_FreeDB_Disc_Status_LookingUp)
                            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_LocalMulti,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
                        else DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_RemoteMulti,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
                        data->flags &= ~FREEDBV_Disc_Flags_DiscInfo;
                        DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
                        break;

                    case MUIV_FreeDB_Disc_Status_LocalFound:
                    case MUIV_FreeDB_Disc_Status_RemoteFound:
                        set(data->matches,MUIA_NList_Quiet,FALSE);
                        DoMethod(data->discInfo,MUIM_FreeDB_DiscInfo_SetContents,data->di,data->toc,0);
                        set(obj,MUIA_FreeDB_Disc_Disc,TRUE);
                        data->flags |= FREEDBV_Disc_Flags_Update;
                        if (tidata==MUIV_FreeDB_Disc_Status_LocalFound)
                            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_LocalFound,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
                        else
                        {
                            DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,MSG_RemoteFound,MUIV_FreeDB_Disc_SetStatus_Mode_Status);
                            setbarrem(data->sb,BSAVE,MUIA_Disabled,FALSE);
                        }
                        data->flags |= FREEDBV_Disc_Flags_DiscInfo;
                        DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);
                        break;

                    case MUIV_FreeDB_Disc_Status_LookingUpMatch:
                        DoMethod(data->discInfo,MUIM_FreeDB_DiscInfo_SetContents,NULL,NULL,MUIV_FreeDB_DiscInfo_SetContents_Flags_Clear);
                        set(obj,MUIA_FreeDB_Disc_Disc,FALSE);
                        data->flags |= FREEDBV_Disc_Flags_Update;
                        data->flags &= ~FREEDBV_Disc_Flags_DiscInfo;
                        break;

                    case MUIV_FreeDB_Disc_Status_RemoteLookingUpMatch:
                        setbar(data->sb,BSTOP,MUIA_Disabled,FALSE);
                        break;

                    default:
                        break;
                }

                data->status = tidata;

                break;
            }
        }
    }

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ASM ULONG
mPlay(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Disc_Play *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register char           buf[64];
    register LONG           err = FREEDBV_Err_CantPlay;
    LONG                    t = -1;

    DoMethod(obj,MUIM_FreeDB_Disc_ObtainInfo,NULL,NULL);

    if (data->flags & FREEDBV_Disc_Flags_TOC)
    {
        if (msg->track>=0) t = msg->track;
        else get(data->discInfo,MUIA_FreeDB_DiscInfo_ActiveTitle,&t);

        if (t>=0 && t<data->toc->numTracks && data->toc->tracks[t].audio)
            err = FreeDBPlayMSF(data->dtag,     data->device,
                                FREEDBA_Unit,   data->unit,
                                FREEDBA_Lun,    data->lun,
                                FREEDBA_FromM,  data->toc->tracks[t].startMin,
                                FREEDBA_FromS,  data->toc->tracks[t].startSec,
                                FREEDBA_FromF,  data->toc->tracks[t].startFrame,
                                FREEDBA_ToM,    data->toc->min,
                                FREEDBA_ToS,    data->toc->sec,
                                FREEDBA_ToF,    data->toc->frame,
                                TAG_DONE);
    }

    snprintf(buf,sizeof(buf),strings[t>=0 ? (err ? MSG_CantPlay : MSG_Playing) : MSG_NothingToPlay],t+1);
    DoMethod(obj,MUIM_FreeDB_Disc_SetStatus,buf,MUIV_FreeDB_Disc_SetStatus_Mode_String);

    DoMethod(obj,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);

    return (ULONG)err;
}

/***********************************************************************/

static ASM ULONG
mDispose(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    DoMethod(obj,MUIM_FreeDB_Disc_Remove,NULL);
    FreeDBHandleFree(data->handle);
    FreeDBFreeObject(data->toc);
    FreeDBFreeObject(data->di);

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ULONG SAVEDS ASM
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch (msg->MethodID)
    {
        case OM_NEW:                        return mNew(cl,obj,(APTR)msg);
        case MUIM_Setup:                    return mSetup(cl,obj,(APTR)msg);
        case MUIM_Cleanup:                  return mCleanup(cl,obj,(APTR)msg);
        case OM_GET:                        return mGet(cl,obj,(APTR)msg);
        case OM_SET:                        return mSets(cl,obj,(APTR)msg);
        case OM_DISPOSE:                    return mDispose(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_GetDisc:      return mGetDisc(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_GetMatch:     return mGetMatch(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Submit:       return mSubmit(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_HandleEvent:  return mHandleEvent(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Break:        return mBreak(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Save:         return mSave(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_SetStatus:    return mSetStatus(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_SetError:     return mSetError(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_ObtainInfo:   return mObtainInfo(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_ReleaseInfo:  return mReleaseInfo(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Setup:        return mFreeDBSetup(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Remove:       return mRemove(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Play:         return mPlay(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Disc_Edit:         return mEdit(cl,obj,(APTR)msg);
        default:                            return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initMCCClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->mcc = MUI_CreateCustomClass((struct Library *)base,MUIC_Group,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
