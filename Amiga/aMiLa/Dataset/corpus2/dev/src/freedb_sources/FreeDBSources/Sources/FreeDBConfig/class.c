
#include <libraries/asl.h>
#include "class.h"

/***********************************************************************/

struct data
{
    struct SignalSemaphore      sem;

    struct FREEDBS_Config       *opts;
    APTR                        handle;

    struct MUI_InputHandlerNode ih;

    struct Hook                 statusHook;
    struct Hook                 sitesHook;

    Object                      *this;
    Object                      *app;
    Object                      *win;
    Object                      *user;
    Object                      *email;
    Object                      *popd;
    Object                      *rootDir;
    Object                      *proxy;
    Object                      *proxyPort;
    Object                      *useProxy;
    Object                      *sites;
    Object                      *status;
    Object                      *host;
    Object                      *port;
    Object                      *cgi;
    Object                      *latitude;
    Object                      *longitude;
    Object                      *description;
    Object                      *pager1;
    Object                      *sitesGroup;

    ULONG                       flags;
};

enum
{
    FREEDBV_Flags_Setup = 1,
};

/***********************************************************************/

static SAVEDS ASM LONG
statusFun(REG(a0) struct Hook *hook,REG(a1) ULONG status,REG(a2) APTR handle)
{
    register struct data *data = (struct data *)hook->h_Data;

    ObtainSemaphoreShared(&data->sem);

    if (data->app)
        DoMethod(data->app,MUIM_Application_PushMethod,data->status,3,MUIM_Set,MUIA_Text_Contents,FreeDBGetString(status));

    ReleaseSemaphore(&data->sem);

    return 0;
}

/***********************************************************************/

static SAVEDS ASM LONG
sitesFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_SitesHookMessage *msg,REG(a2) APTR handle)
{
    register struct data *data = (struct data *)hook->h_Data;

    ObtainSemaphoreShared(&data->sem);

    if (data->app)
    {
        register struct FREEDBS_Site *entry;

        if (!(entry = AllocMem(sizeof(struct FREEDBS_Site),MEMF_PUBLIC|MEMF_CLEAR)))
            return FREEDBV_Err_NoMem;

        strcpy(entry->host,msg->host);
        entry->port = msg->port;
        strcpy(entry->portString,msg->portString);
        strcpy(entry->cgi,msg->cgi);
        strcpy(entry->latitude,msg->latitude);
        strcpy(entry->longitude,msg->longitude);
        strcpy(entry->description,msg->description);

        DoMethod(data->app,MUIM_Application_PushMethod,data->sites,3,MUIM_NList_InsertSingle,entry,MUIV_NList_Insert_Bottom);
    }

    ReleaseSemaphore(&data->sem);

    return 0;
}

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register Object *user, *email, *popd, *rootDir, *proxy, *proxyPort, *useProxy,
                    *sites, *status, *save, *use, *apply, *cancel, *host, *port,
                    *cgi, *latitude, *longitude, *description, *add, *del, *active,
                    *pager1, *stop, *sitesGroup;

    if (obj = (Object *)DoSuperNew(cl,obj,
        Child, ColGroup(2),
            GroupFrame,
            MUIA_Background, MUII_GroupBack,
            Child, Label2(strings[MSG_User]),
            Child, HGroup,
                Child, user = stringObject(MSG_User,MSG_User_Help,256),
                Child, Label2(strings[MSG_Email]),
                Child, email = stringObject(MSG_Email,MSG_Email_Help,256),
            End,
            Child, Label2(strings[MSG_RootDir]),
            Child, popd = PopaslObject,
                MUIA_ShortHelp, strings[MSG_RootDir_Help],
                MUIA_Popstring_String, rootDir = stringObject(MSG_RootDir,0,256),
                MUIA_Popstring_Button, MUI_MakeObject(MUIO_PopButton,MUII_PopDrawer),
                ASLFR_DrawersOnly, TRUE,
                ASLFR_TitleText, strings[MSG_RootDirASLTitle],
            End,
            Child, Label2(strings[MSG_Proxy]),
            Child, HGroup,
                Child, proxy = stringObject(MSG_Proxy,MSG_Proxy_Help,256),
                Child, Label2(strings[MSG_ProxyPort]),
                Child, proxyPort = portObject(MSG_ProxyPort,MSG_ProxyPort_Help),
                Child, Label1(strings[MSG_UseProxy]),
                Child, useProxy = checkmarkObject(MSG_UseProxy,MSG_UseProxy_Help),
            End,
        End,
        Child, sitesGroup = VGroup,
            GroupFrame,
            MUIA_Background, MUII_GroupBack,
            MUIA_ShortHelp, strings[MSG_Sites_Help],
            Child, NListviewObject,
                MUIA_CycleChain, 1,
                MUIA_NListview_NList, sites = sitesListObject,
                End,
            End,
            Child, VGroup,
                Child, ColGroup(2),
                    Child, Label2(strings[MSG_Host]),
                    Child, HGroup,
                        Child, host = stringObject(MSG_Host,MSG_Host_Help,256),
                        Child, Label2(strings[MSG_Port]),
                        Child, port = portObject(MSG_Port,MSG_Port_Help),
                    End,
                    Child, Label2(strings[MSG_CGI]),
                    Child, HGroup,
                        Child, cgi = stringObject(MSG_CGI,MSG_CGI_Help,256),
                        Child, Label2(strings[MSG_Lat]),
                        Child, latitude = stringObject(MSG_Lat,MSG_Lat_Help,16),
                        Child, Label2(strings[MSG_Long]),
                        Child, longitude = stringObject(MSG_Long,MSG_Long_Help,16),
                    End,
                    Child, Label2(strings[MSG_Desc]),
                    Child, description = stringObject(MSG_Desc,MSG_Desc_Help,256),
                End,
                Child, HGroup,
                    MUIA_Group_SameSize, 1,
                    Child, add = buttonObject(MSG_Add,MSG_Add_Help),
                    Child, hspace(40),
                    Child, del = buttonObject(MSG_Del,MSG_Del_Help),
                    Child, hspace(40),
                    Child, active = buttonObject(MSG_Active,MSG_Active_Help),
                End,
            End,
        End,
        Child, status = textObject("\33c"),
        Child, pager1 = HGroup,
            MUIA_Group_PageMode, TRUE,
            Child, HGroup,
                MUIA_Group_SameSize, 1,
                Child, save = buttonObject(MSG_Save,MSG_Save_Help),
                Child, hspace(20),
                Child, use = buttonObject(MSG_Use,MSG_Use_Help),
                Child, hspace(20),
                Child, apply = buttonObject(MSG_Apply,MSG_Apply_Help),
                Child, hspace(20),
                Child, cancel = buttonObject(MSG_Cancel,MSG_Cancel_Help),
            End,
            Child, stop = buttonObject(MSG_Stop,MSG_Stop_Help),
        End,
        TAG_MORE,msg->ops_AttrList))
    {
        register struct data *data = INST_DATA(cl,obj);

        memset(&data->sem,0,sizeof(struct SignalSemaphore));
        InitSemaphore(&data->sem);

        data->opts        = NULL;
        data->handle      = NULL;
        data->app         = NULL;
        data->win         = NULL;
        data->this        = obj;
        data->user        = user;
        data->email       = email;
        data->popd        = popd;
        data->rootDir     = rootDir;
        data->proxy       = proxy;
        data->proxyPort   = proxyPort;
        data->useProxy    = useProxy;
        data->sites       = sites;
        data->status      = status;
        data->host        = host;
        data->port        = port;
        data->cgi         = cgi;
        data->latitude    = latitude;
        data->longitude   = longitude;
        data->description = description;
        data->pager1      = pager1;
        data->sitesGroup  = sitesGroup;

        data->statusHook.h_Entry = (APTR)statusFun;
        data->statusHook.h_Data  = data;
        data->sitesHook.h_Entry  = (APTR)sitesFun;
        data->sitesHook.h_Data   = data;

        data->ih.ihn_Object  = NULL;
        data->ih.ihn_Signals = 0;
        data->ih.ihn_Method  = 0;
        data->ih.ihn_Flags   = 0;

        DoMethod(save,MUIM_Notify,MUIA_Pressed,0,obj,2,MUIM_FreeDB_Config_Save,MUIV_FreeDB_Config_Save_Mode_Save);
        DoMethod(use,MUIM_Notify,MUIA_Pressed,0,obj,2,MUIM_FreeDB_Config_Save,MUIV_FreeDB_Config_Save_Mode_Use);
        DoMethod(apply,MUIM_Notify,MUIA_Pressed,0,obj,2,MUIM_FreeDB_Config_Save,MUIV_FreeDB_Config_Save_Mode_Apply);
        DoMethod(cancel,MUIM_Notify,MUIA_Pressed,0,obj,3,MUIM_Set,MUIA_FreeDB_Config_Done,TRUE);
        DoMethod(stop,MUIM_Notify,MUIA_Pressed,0,obj,1,MUIM_FreeDB_Config_Break);

        DoMethod(sites,MUIM_Notify,MUIA_NList_Active,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_ChangeEdit);

        DoMethod(host,MUIM_Notify,MUIA_Textinput_Acknowledge,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_EditChange);
        DoMethod(port,MUIM_Notify,MUIA_Textinput_Acknowledge,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_EditChange);
        DoMethod(cgi,MUIM_Notify,MUIA_Textinput_Acknowledge,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_EditChange);
        DoMethod(latitude,MUIM_Notify,MUIA_Textinput_Acknowledge,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_EditChange);
        DoMethod(longitude,MUIM_Notify,MUIA_Textinput_Acknowledge,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_EditChange);
        DoMethod(description,MUIM_Notify,MUIA_Textinput_Acknowledge,MUIV_EveryTime,obj,1,MUIM_FreeDB_Config_EditChange);

        DoMethod(del,MUIM_Notify,MUIA_Pressed,0,data->sites,2,MUIM_NList_Remove,MUIV_NList_Remove_Active);
        DoMethod(add,MUIM_Notify,MUIA_Pressed,0,data->sites,1,MUIM_FreeDB_SitesList_Add);
        DoMethod(active,MUIM_Notify,MUIA_Pressed,0,data->sites,1,MUIM_FreeDB_SitesList_ChangeActive);
    }

    return (ULONG)obj;
}

/***********************************************************************/

static ULONG ASM
mSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (!DoSuperMethodA(cl,obj,msg)) return FALSE;

    ObtainSemaphore(&data->sem);
    data->app = _app(obj);
    data->win = _win(obj);
    ReleaseSemaphore(&data->sem);

    if (data->handle = FreeDBHandleCreateA(NULL))
    {
        data->ih.ihn_Object  = obj;
        data->ih.ihn_Signals = FreeDBHandleSignal(data->handle);
        data->ih.ihn_Method  = MUIM_FreeDB_Config_HandleEvent;
        data->ih.ihn_Flags   = 0;
        DoMethod(data->app,MUIM_Application_AddInputHandler,&data->ih);

        DoMethod(obj,MUIM_FreeDB_Config_Load,MUIV_FreeDB_Config_Load_Env);

        return TRUE;
    }

    return FALSE;
}

/***********************************************************************/

static ULONG ASM
mCleanup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (data->opts)
    {
        FreeDBFreeConfig(data->opts);
        data->opts = NULL;
    }

    if (data->handle)
    {
        FreeDBHandleFree(data->handle);
        DoMethod(data->app,MUIM_Application_RemInputHandler,&data->ih);
        data->handle = NULL;
    }

    ObtainSemaphore(&data->sem);
    data->app = NULL;
    data->win = NULL;
    ReleaseSemaphore(&data->sem);

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ULONG ASM
mLoad(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Config_Load *msg)
{
    register struct data            *data = INST_DATA(cl,obj);
    register struct FREEDBS_Config  *opts;

    set(data->status,MUIA_Text_Contents,strings[MSG_Reading]);
    set(data->user,MUIA_Textinput_Contents,NULL);
    set(data->email,MUIA_Textinput_Contents,NULL);
    set(data->rootDir,MUIA_Textinput_Contents,NULL);
    set(data->proxy,MUIA_Textinput_Contents,NULL);
    set(data->useProxy,MUIA_Selected,NULL);

    if (data->opts) FreeDBFreeConfig(data->opts);

    if (data->opts = opts = FreeDBReadConfig((msg->name==MUIV_FreeDB_Config_Load_Env) ? FREEDBV_ReadConfig_Env : msg->name))
    {
        if (!(opts->flags & FREEDBV_Config_Flags_NoUser)) set(data->user,MUIA_Textinput_Contents,opts->user);
        set(data->email,MUIA_Textinput_Contents,opts->email);
        set(data->rootDir,MUIA_Textinput_Contents,opts->rootDir);
        set(data->proxy,MUIA_Textinput_Contents,opts->proxy);
        set(data->proxy,MUIA_Textinput_Contents,opts->proxyPortString);
        set(data->useProxy,MUIA_Selected,opts->useProxy);
        set(data->status,MUIA_Text_Contents,strings[MSG_Read]);

        DoMethod(data->sites,MUIM_FreeDB_SitesList_InsertSites,opts);

        return 1;
    }
    else
    {
        set(data->status,MUIA_Text_Contents,strings[MSG_CantRead]);
        return 0;
    }
}

/***********************************************************************/

static ULONG ASM
mBreak(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    FreeDBHandleAbort(data->handle);
    set(data->pager1,MUIA_Group_ActivePage,0);
    set(data->sites,MUIA_NList_Quiet,0);
    set(data->sitesGroup,MUIA_Disabled,0);

    return 0;
}

/***********************************************************************/

static ULONG ASM
mHandleEvent(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);
    register LONG               err;

    if (!FreeDBHandleCheck(data->handle))
        return 0;

    set(data->pager1,MUIA_Group_ActivePage,0);
    set(data->sitesGroup,MUIA_Disabled,0);
    set(data->sites,MUIA_NList_Quiet,0);

    switch (err = FreeDBHandleWait(data->handle))
    {
        case 0:
            set(data->status,MUIA_Text_Contents,strings[MSG_Download]);
            break;

        default:
            set(data->status,MUIA_Text_Contents,FreeDBGetString(err));
            break;
    }

    return 1;
}

/***********************************************************************/

static ULONG ASM
mSave(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Config_Save *msg)
{
    register struct data            *data = INST_DATA(cl,obj);
    register struct FREEDBS_Config  *opts = data->opts;
    register Object                 *sites = data->sites;
    register BOOL                   done;
    char                            *c;
    long                            port;
    register int                    i;

    get(data->proxy,MUIA_Textinput_Contents,&c);
    if (strstr(c,":") || strstr(c," "))
    {
        if (data->win) set(data->win,MUIA_Window_ActiveObject,data->proxy);
        return 0;
    }
    strcpy(opts->proxy,c);

    get(data->proxyPort,MUIA_Textinput_Contents,&c);
    if (c && *c)
    {
        port = atoi(c);
        if (port<=0 || port>65535)
        {
            if (data->win) set(data->win,MUIA_Window_ActiveObject,data->proxyPort);
            return 0;
        }
    }
    else port = 8080;
    opts->proxyPort = port;

    if (!*opts->proxy) set(data->useProxy,MUIA_Selected,0);

    get(data->useProxy,MUIA_Selected,&c);
    opts->useProxy = (ULONG)c;

    get(data->user,MUIA_Textinput_Contents,&c);
    if (*c) opts->flags &= ~FREEDBV_Config_Flags_NoUser;
    stccpy(opts->user,c,sizeof(opts->user));

    get(data->email,MUIA_Textinput_Contents,&c);
    stccpy(opts->email,c,sizeof(opts->email));

    get(data->rootDir,MUIA_Textinput_Contents,&c);
    stccpy(opts->rootDir,c,sizeof(opts->rootDir));

    opts->activeSite = (struct FREEDBS_Site *)DoMethod(sites,MUIM_FreeDB_SitesList_GetActive);

    for (i = 0; ;i++)
    {
        struct FREEDBS_Site *entry;

        DoMethod(sites,MUIM_NList_GetEntry,i,&entry);
        if (!entry) break;
        AddTail(LIST(&opts->sites),NODE(entry));
    }

    done = msg->name!=MUIV_FreeDB_Config_Save_Mode_Apply;

    if ((msg->name==MUIV_FreeDB_Config_Save_Mode_Use) || (msg->name==MUIV_FreeDB_Config_Save_Mode_Apply))
        FreeDBSaveConfig(opts,FREEDBV_SaveConfig_Env);
    else
        if (msg->name==MUIV_FreeDB_Config_Save_Mode_Save)
            FreeDBSaveConfig(opts,FREEDBV_SaveConfig_Envarc);
        else FreeDBSaveConfig(opts,msg->name);

    FreeDBConfigChanged();

    NEWLIST(&opts->sites);

    if (done) set(obj,MUIA_FreeDB_Config_Done,TRUE);
    return 1;
}

/***********************************************************************/

static ULONG ASM
mGetSites(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register LONG               err;

    if (!data->app) return 0;

    DoMethod(data->sites,MUIM_NList_Clear);

    err = FreeDBHandleCommand(data->handle,FREEDBV_Command_Sites,
            FREEDBA_StatusHook, &data->statusHook,
            FREEDBA_SitesHook,  &data->sitesHook,
            TAG_DONE);

    if (err)
    {
        set(data->status,MUIA_Text_Contents,FreeDBGetString(err));
        return 0;
    }

    set(data->pager1,MUIA_Group_ActivePage,1);
    set(data->sites,MUIA_NList_Quiet,1);
    set(data->sitesGroup,MUIA_Disabled,1);
    return 1;
}

/***********************************************************************/

static ULONG ASM
mChangeEdit(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    struct FREEDBS_Site     *entry;

    DoMethod(data->sites,MUIM_NList_GetEntry,MUIV_NList_GetEntry_Active,&entry);
    if (entry)
    {
        set(data->host,MUIA_Textinput_Contents,entry->host);
        set(data->port,MUIA_Textinput_Contents,entry->portString);
        set(data->cgi,MUIA_Textinput_Contents,entry->cgi);
        set(data->latitude,MUIA_Textinput_Contents,entry->latitude);
        set(data->longitude,MUIA_Textinput_Contents,entry->longitude);
        set(data->description,MUIA_Textinput_Contents,entry->description);
    }
    else
    {
        set(data->host,MUIA_Textinput_Contents,NULL);
        set(data->port,MUIA_Textinput_Contents,NULL);
        set(data->cgi,MUIA_Textinput_Contents,NULL);
        set(data->latitude,MUIA_Textinput_Contents,NULL);
        set(data->longitude,MUIA_Textinput_Contents,NULL);
        set(data->description,MUIA_Textinput_Contents,NULL);
    }

    return 1;
}

/***********************************************************************/

static ULONG ASM
mEditChange(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    struct FREEDBS_Site     *entry;
    char                    *c;
    long                    port;

    DoMethod(data->sites,MUIM_NList_GetEntry,MUIV_NList_GetEntry_Active,&entry);
    if (!entry) return 0;

    memset(entry->host,0,sizeof(entry->host));
    entry->port = 80;
    memset(entry->portString,0,sizeof(entry->portString));
    memset(entry->cgi,0,sizeof(entry->cgi));
    memset(entry->latitude,0,sizeof(entry->latitude));
    memset(entry->longitude,0,sizeof(entry->longitude));
    memset(entry->description,0,sizeof(entry->description));

    get(data->host,MUIA_Textinput_Contents,&c);
    if (strstr(c,":") || strstr(c," "))
    {
        if (data->win) set(data->win,MUIA_Window_ActiveObject,data->host);
        return 0;
    }
    strcpy(entry->host,c);

    get(data->port,MUIA_Textinput_Contents,&c);
    if (c && *c)
    {
        port = atoi(c);
        if (port<=0 || port>65535)
        {
            if (data->win) set(data->win,MUIA_Window_ActiveObject,data->port);
            return 0;
        }
    }
    else
    {
        set(data->port,MUIA_Textinput_Integer,80);
        port = 80;
    }
    entry->port = port;
    sprintf(entry->portString,"%ld",port);

    get(data->cgi,MUIA_Textinput_Contents,&c);
    stccpy(entry->cgi,c,sizeof(entry->cgi));

    get(data->latitude,MUIA_Textinput_Contents,&c);
    stccpy(entry->latitude,c,sizeof(entry->latitude));

    get(data->longitude,MUIA_Textinput_Contents,&c);
    stccpy(entry->longitude,c,sizeof(entry->longitude));

    get(data->description,MUIA_Textinput_Contents,&c);
    stccpy(entry->description,c,sizeof(entry->description));

    DoMethod(data->sites,MUIM_NList_Redraw,MUIV_NList_Redraw_Active);

    return 1;
}

/***********************************************************************/

static ULONG ASM
mGet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    switch(msg->opg_AttrID)
    {
        case MUIA_FreeDB_Config_Done:
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

static ULONG SAVEDS ASM
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:                            return mNew(cl,obj,(APTR)msg);
        case MUIM_Setup:                        return mSetup(cl,obj,(APTR)msg);
        case MUIM_Cleanup:                      return mCleanup(cl,obj,(APTR)msg);
        case OM_GET:                            return mGet(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_Load:           return mLoad(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_HandleEvent:    return mHandleEvent(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_Break:          return mBreak(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_Save:           return mSave(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_GetSites:       return mGetSites(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_ChangeEdit:     return mChangeEdit(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Config_EditChange:     return mEditChange(cl,obj,(APTR)msg);
        default:                                return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->class = MUI_CreateCustomClass((struct Library *)base,MUIC_Group,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
