
#include <proto/icon.h>
#include "freedbmui.h"
#include <dos/dosextens.h>
#include <dos/filehandler.h>
#include <devices/cd.h>
#include <devices/scsidisk.h>

/***********************************************************************/

#define APP_TITLE       "FreeDB"
#define APP_VERSION     "$VER: " APP_TITLE " " VRSTRING " (" DATE ")"
#define APP_AUTHOR      "Alfonso Ranieri"
#define APP_COPYRIGHT   "ritten by " APP_AUTHOR ". Under the GPL 2."
#define APP_BASE        "FREEDB"
#define APP_ICON		"ENVARC:FreeDB/FreeDB"

/***********************************************************************/

struct data
{
    Object              *strip;
    Object              *config;
    Object              *about;
    ULONG               flags;
    char                device[256];
    UWORD               unit;
    struct MsgPort      port;
    struct IOStdReq     changeio;
    struct Interrupt    changeInt;
	struct DiskObject	*icon;
};

enum
{
    MUIV_FreeDB_App_Flags_RemChangeInt = 1,
};

/***********************************************************************/

#undef SysBase

static void ASM SAVEDS
changeInt(REG(a1) Object *app,REG(a6) struct ExecBase *SysBase)
{
    DoMethod(app,MUIM_Application_PushMethod,app,3,
        MUIM_Set,MUIA_FreeDB_App_Changed,TRUE);
}

#define SysBase (rexxLibBase->sysBase)

/****************************************************************************/

static void ASM
addFrameInt(REG(a0) Object *obj,REG(a1) struct data *data)
{
    register int sig;

    if ((sig = AllocSignal(-1))!=-1)
    {
        INITPORT(&data->port,sig);
        INITMESSAGE(MESSAGE(&data->changeio),&data->port,sizeof(struct IOStdReq));

        if (!OpenDevice(data->device,data->unit,REQ(&data->changeio),0))
        {
            data->changeInt.is_Data         = obj;
            data->changeInt.is_Code         = (VOID (*)())changeInt;
            data->changeInt.is_Node.ln_Pri  = 0;
            data->changeInt.is_Node.ln_Type = NT_INTERRUPT;

            data->changeio.io_Command = CD_ADDCHANGEINT;
            data->changeio.io_Data    = &data->changeInt;
            data->changeio.io_Length  = sizeof(struct Interrupt);

            SendIO(REQ(&data->changeio));
            if (CheckIO(REQ(&data->changeio))) CloseDevice(REQ(&data->changeio));
            else data->flags |= MUIV_FreeDB_App_Flags_RemChangeInt;
        }
        else FreeSignal(sig);
    }
}

/****************************************************************************/

static void ASM
remChangeInt(REG(a0) struct data *data)
{
    if (data->flags & MUIV_FreeDB_App_Flags_RemChangeInt)
    {
        data->changeio.io_Command = CD_REMCHANGEINT;
        data->changeio.io_Data    = &data->changeInt;
        data->changeio.io_Length  = sizeof(struct Interrupt);
        DoIO(REQ(&data->changeio));

        CloseDevice(REQ(&data->changeio));

        FreeSignal(data->port.mp_SigBit);
    }
}

/****************************************************************************/

struct NewMenu appMenu[] =
{
    MTITLE(MSG_Project),
    MITEM(MSG_About),
    MITEM(MSG_AboutMUI),
    MBAR,
    MITEM(MSG_Hide),
    MBAR,
    MITEM(MSG_Quit),

    MTITLE(MSG_FreeDB),
    MITEM(MSG_Get),
    MBAR,
    MITEM(MSG_GetLocal),
    MITEM(MSG_GetRemote),

    MTITLE(MSG_Editor),
    MITEM(MSG_FreeDBConfig),
    MITEM(MSG_MUI),

    MEND
};

struct NewMenu configMenu[] =
{
    MTITLE(MSG_Config),
    MITEM(MSG_Restore),
    MITEM(MSG_Last),
    MBAR,
    MITEM(MSG_GetSites),

    MEND
};

/***********************************************************************/

ULONG
DoSuperNew(struct IClass *cl,Object *obj,ULONG tag1,...)
{
    return DoSuperMethod(cl,obj,OM_NEW,&tag1,NULL);
}

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,
     REG(a2) Object *obj,
     REG(a1) struct opSet *msg)
{
    register struct TagItem *attrs = msg->ops_AttrList;
    register Object         *strip;

    if (obj = (Object *)DoSuperNew(cl,obj,
        MUIA_Application_Title,         APP_TITLE,
        MUIA_Application_Version,       APP_VERSION,
        MUIA_Application_Copyright,     APP_COPYRIGHT,
        MUIA_Application_Author,        APP_AUTHOR,
        MUIA_Application_Description,   FreeDBGetString(MSG_Description),
        MUIA_Application_Base,          APP_BASE,
        MUIA_Application_Menustrip,     strip = MUI_MakeObject(MUIO_MenustripNM,appMenu,MUIO_MenustripNM_CommandKeyCheck),
        TAG_MORE,attrs))
    {
        register struct data *data = INST_DATA(cl,obj);
        register char        *d;

        data->strip  = strip;
        data->about  = NULL;
        data->config = NULL;
        data->flags  = 0;

		if (data->icon = GetDiskObject(APP_ICON))
			set(obj,MUIA_Application_DiskObject,data->icon);

        if (d = (STRPTR)GetTagData(FREEDBA_Device,0,attrs))
        {
            stccpy(data->device,d,sizeof(data->device));
            data->unit = (UWORD)GetTagData(FREEDBA_Unit,0,attrs);
        }
        else
        {
            if (d = (STRPTR)GetTagData(FREEDBA_DeviceName,0,attrs))
                if (!findDevice(d,data->device,sizeof(data->device),&data->unit))
                    d = NULL;
        }

        if (d) addFrameInt(obj,data);

    }

    return (ULONG)obj;
}

/***********************************************************************/

static ULONG ASM
mOpenAboutWindow(REG(a0) struct IClass *cl,
                 REG(a2) Object *obj,
                 REG(a1) struct MUIP_Application_AboutMUI *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    set(obj,MUIA_Application_Sleep,TRUE);
    if (!data->about)
    {
        data->about = FreeDBAboutObject,End;
        if (!data->about) return 0;
        DoSuperMethod(cl,obj,OM_ADDMEMBER,data->about);
    }
    if (msg->refwindow)
        set(data->about,MUIA_Window_RefWindow,msg->refwindow);
    set(obj,MUIA_Application_Sleep,FALSE);
    set(data->about,MUIA_Window_Open,TRUE);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mOpenConfigWindow(REG(a0) struct IClass *cl,
                  REG(a2) Object *obj,
                  REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    set(obj,MUIA_Application_Sleep,TRUE);
    if (!data->config)
    {
        register Object *cg, *strip;

        data->config = WindowObject,
            MUIA_Window_Title, FreeDBGetString(MSG_ConfWinTitle),
            MUIA_Window_ID, MAKE_ID('C','O','N','F'),
            MUIA_Window_Menustrip, strip = MUI_MakeObject(MUIO_MenustripNM,configMenu,MUIO_MenustripNM_CommandKeyCheck),
            WindowContents, VGroup,
                Child, cg = FreeDBConfigObject,
                End,
            End,
        End;
        if (!data->config) return 0;

        DoMethod(data->config,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,
            MUIV_Notify_Self,3,MUIM_Set,MUIA_Window_Open,FALSE);

        DoMethod(cg,MUIM_Notify,MUIA_FreeDB_Config_Done,TRUE,
            data->config,3,MUIM_Set,MUIA_Window_Open,FALSE);

        DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_Restore),MUIM_Notify,MUIA_Menuitem_Trigger,
            MUIV_EveryTime,cg,2,MUIM_FreeDB_Config_Load,FREEDBV_ReadConfig_Env);

        DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_Last),MUIM_Notify,MUIA_Menuitem_Trigger,
            MUIV_EveryTime,cg,2,MUIM_FreeDB_Config_Load,FREEDBV_ReadConfig_Envarc);

        DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_GetSites),MUIM_Notify,MUIA_Menuitem_Trigger,
            MUIV_EveryTime,cg,1,MUIM_FreeDB_Config_GetSites);

        DoSuperMethod(cl,obj,OM_ADDMEMBER,data->config);
    }
    set(obj,MUIA_Application_Sleep,FALSE);
    set(data->config,MUIA_Window_Open,TRUE);

    return 0;
}

/***********************************************************************/

static ASM ULONG
mOpenMUIConfigWindow(REG(a0) struct IClass *cl,
                     REG(a2) Object *obj,
                     REG(a1) Msg msg)
{
    register ULONG res;

    set(obj,MUIA_Application_Sleep,TRUE);
    res = DoSuperMethodA(cl,obj,msg);
    set(obj,MUIA_Application_Sleep,FALSE);

    return res;
}

/***********************************************************************/

static ASM ULONG
mGet(REG(a0) struct IClass *cl,
     REG(a2) Object *obj,
     REG(a1) struct opGet *msg)
{
    switch(msg->opg_AttrID)
    {
        case MUIA_FreeDB_App_Changed:
            *msg->opg_Storage = 0;
            return 1;

        default:
            return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

static ASM ULONG
mAppSetup(REG(a0) struct IClass *cl,
          REG(a2) Object *obj,
          REG(a1) struct MUIP_FreeDB_App_Setup *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register Object         *strip = data->strip, *disc = msg->disc, *window = msg->window;

    DoMethod(obj,MUIM_Notify,MUIA_FreeDB_App_Changed,TRUE,disc,3,
        MUIM_FreeDB_Disc_GetDisc,NULL,0);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_About),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,obj,2,MUIM_FreeDB_App_About,window);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_AboutMUI),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,obj,2,MUIM_Application_AboutMUI,window);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_Hide),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,obj,3,MUIM_Set,MUIA_Application_Iconified,TRUE);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_Quit),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,obj,2,MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_Get),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,disc,3,MUIM_FreeDB_Disc_GetDisc,NULL,0);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_GetLocal),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,disc,3,MUIM_FreeDB_Disc_GetDisc,NULL,MUIV_FreeDB_Disc_GetDisc_Flags_ForceLocal);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_GetRemote),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,disc,3,MUIM_FreeDB_Disc_GetDisc,NULL,MUIV_FreeDB_Disc_GetDisc_Flags_ForceRemote);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_FreeDBConfig),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,obj,1,MUIM_FreeDB_App_Config);

    DoMethod((Object *)DoMethod(strip,MUIM_FindUData,MSG_MUI),MUIM_Notify,
        MUIA_Menuitem_Trigger,MUIV_EveryTime,obj,2,MUIM_Application_OpenConfigWindow,0);

    return 0;
}

/***********************************************************************/

static ASM ULONG
mDispose(REG(a0) struct IClass *cl,
         REG(a2) Object *obj,
         REG(a1) Msg msg)
{
    register struct data 		*data = INST_DATA(cl,obj);
	register struct DiskObject	*icon = data->icon;
	ULONG				 		res;

    remChangeInt(data);
	res = DoSuperMethodA(cl,obj,msg);
	if (icon) FreeDiskObject(icon);

	return res;
}

/***********************************************************************/

static SAVEDS ASM ULONG
dispatcher(REG(a0) struct IClass *cl,
           REG(a2) Object *obj,
           REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:
            return mNew(cl,obj,(APTR)msg);

        case OM_GET:
            return mGet(cl,obj,(APTR)msg);

        case OM_DISPOSE:
            return mDispose(cl,obj,(APTR)msg);

        case MUIM_FreeDB_App_Setup:
            return mAppSetup(cl,obj,(APTR)msg);

        case MUIM_FreeDB_App_About:
            return mOpenAboutWindow(cl,obj,(APTR)msg);

        case MUIM_FreeDB_App_Config:
            return mOpenConfigWindow(cl,obj,(APTR)msg);

        case MUIM_Application_OpenConfigWindow:
            return mOpenMUIConfigWindow(cl,obj,(APTR)msg);

        default:
            return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

static void ASM
localizeNewMenu(REG(a0) struct NewMenu *nm)
{
    for ( ; nm->nm_Type!=NM_END; nm++)
        if (nm->nm_Label!=NM_BARLABEL)
            nm->nm_Label = FreeDBGetString((ULONG)nm->nm_Label);
}

/***********************************************************************/

BOOL ASM
initAppClass(void)
{
    if (rexxLibBase->appClass = MUI_CreateCustomClass(NULL,MUIC_Application,NULL,sizeof(struct data),dispatcher))
    {
        localizeNewMenu(appMenu);
        localizeNewMenu(configMenu);

        return TRUE;
    }

    return FALSE;
}

/***********************************************************************/
