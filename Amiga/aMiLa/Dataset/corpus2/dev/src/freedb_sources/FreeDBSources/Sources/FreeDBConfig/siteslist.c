
#include "class.h"

/***********************************************************************/

struct data
{
    struct FREEDBS_Site *active;
    struct Hook         conHook;
    struct Hook         desHook;
    struct Hook         dispHook;
};

#define MUIV_SitesList_Insert_Empty ((struct FREEDBS_Site *)(-1))

/***********************************************************************/

static SAVEDS ASM APTR
sitesListConFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_Site *site,REG(a2) APTR pool)
{
    register struct FREEDBS_Site *entry;

    if (entry = AllocPooled(pool,sizeof(struct FREEDBS_Site)))
    {
        if (site!=MUIV_SitesList_Insert_Empty)
        {
            strcpy(entry->host,site->host);
            entry->port = site->port;
            sprintf(entry->portString,"%ld",site->port);
            strcpy(entry->cgi,site->cgi);
            strcpy(entry->latitude,site->latitude);
            strcpy(entry->longitude,site->longitude);
            strcpy(entry->description,site->description);
        }
        else memset(entry,0,sizeof(struct FREEDBS_Site));
    }

    return entry;
}

/***********************************************************************/

static SAVEDS ASM void
sitesListDesFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_Site *entry,REG(a2) APTR pool)
{
    FreePooled(pool,entry,sizeof(struct FREEDBS_Site));
}

/***********************************************************************/

static SAVEDS ASM LONG
sitesListDispFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_Site *entry,REG(a2) char **array)
{
    if (entry)
    {
        *array++ = (((struct data *)hook->h_Data)->active==entry) ? ">" : " ";
        *array++ = entry->host;
        *array++ = entry->portString;
        *array++ = entry->cgi;
        *array++ = entry->longitude;
        *array++ = entry->latitude;
        *array   = entry->description;
    }
    else
    {
        *array++ = " ";
        *array++ = strings[MSG_Sites_Host];
        *array++ = strings[MSG_Sites_Port];
        *array++ = strings[MSG_Sites_CGI];
        *array++ = strings[MSG_Sites_Lat];
        *array++ = strings[MSG_Sites_Long];
        *array   = strings[MSG_Sites_Desc];
    }

    return 0;
}

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    if (obj = (Object *)DoSuperNew(cl,obj,
        MUIA_NList_Format, "NOBAR,BAR,D 8 P \33r BAR,BAR,P \33r BAR,P \33r BAR,",
        MUIA_NList_Title, TRUE,
        MUIA_NList_AutoVisible, TRUE,
        MUIA_NList_MinColSortable, 100,
        TAG_MORE,msg->ops_AttrList))
    {
        register struct data *data = INST_DATA(cl,obj);

        data->active = NULL;
        data->conHook.h_Entry  = (APTR)sitesListConFun;
        data->conHook.h_Data   = data;
        data->desHook.h_Entry  = (APTR)sitesListDesFun;
        data->desHook.h_Data   = data;
        data->dispHook.h_Entry = (APTR)sitesListDispFun;
        data->dispHook.h_Data  = data;

        SetSuperAttrs(cl,obj,MUIA_NList_ConstructHook,&data->conHook,
                             MUIA_NList_DestructHook,&data->desHook,
                             MUIA_NList_DisplayHook,&data->dispHook,
                             TAG_DONE);

        DoSuperMethod(cl,obj,MUIM_Notify,MUIA_NList_DoubleClick,MUIV_EveryTime,MUIV_Notify_Self,1,MUIM_FreeDB_SitesList_ChangeActive);
    }

    return (ULONG)obj;
}

/***********************************************************************/

static ULONG ASM
mChangeActive(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data   *data = INST_DATA(cl,obj);
    struct FREEDBS_Site    *entry, *old;

    DoSuperMethod(cl,obj,MUIM_NList_GetEntry,MUIV_NList_GetEntry_Active,&entry);
    if (!entry) return 0;

    data->active = ((old = data->active)==entry) ? NULL : entry;
    DoSuperMethod(cl,obj,MUIM_NList_Redraw,MUIV_NList_Redraw_Active);
    if (old) DoSuperMethod(cl,obj,MUIM_NList_RedrawEntry,old);

    return 1;
}

/***********************************************************************/

static ULONG ASM
mGetActive(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data  *data = INST_DATA(cl,obj);

    return (ULONG)data->active;
}

/***********************************************************************/

static ASM ULONG
InsertSites(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_SitesList_InsertSites *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register struct MinNode *mstate, *succ;
    ULONG                   a = -1;

    setsuper(cl,obj,MUIA_NList_Quiet,TRUE);
    DoSuperMethod(cl,obj,MUIM_NList_Clear);
    data->active = NULL;

    for (mstate = msg->opts->sites.mlh_Head; succ = mstate->mln_Succ; mstate = succ)
    {
        DoSuperMethod(cl,obj,MUIM_NList_InsertSingle,mstate,MUIV_NList_Insert_Bottom);
        if (msg->opts->activeSite==(struct FREEDBS_Site *)mstate)
        {
            struct FREEDBS_Site *entry;

            get(obj,MUIA_NList_InsertPosition,&a);
            DoSuperMethod(cl,obj,MUIM_NList_GetEntry,a,&entry);
            data->active = entry;
        }
        Remove((struct Node *)mstate);
        FreeMem(mstate,sizeof(struct FREEDBS_Site));
    }

    SetSuperAttrs(cl,obj,MUIA_NList_Active,a,MUIA_NList_Quiet,FALSE,TAG_DONE);

    return 1;
}

/***********************************************************************/

static ASM ULONG
mAdd(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    ULONG p;

    DoSuperMethod(cl,obj,MUIM_NList_InsertSingle,MUIV_SitesList_Insert_Empty,MUIV_NList_Insert_Bottom);
    get(obj,MUIA_NList_InsertPosition,&p);
    if (p>=0)
    {
        set(obj,MUIA_NList_Active,p);

        return 1;
    }

    return 0;
}

/***********************************************************************/

static SAVEDS ASM ULONG
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:                                return mNew(cl,obj,(APTR)msg);
        case MUIM_FreeDB_SitesList_ChangeActive:    return mChangeActive(cl,obj,(APTR)msg);
        case MUIM_FreeDB_SitesList_GetActive:       return mGetActive(cl,obj,(APTR)msg);
        case MUIM_FreeDB_SitesList_InsertSites:     return InsertSites(cl,obj,(APTR)msg);
        case MUIM_FreeDB_SitesList_Add:             return mAdd(cl,obj,(APTR)msg);
        default:                                    return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initSitesListClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->sitesListClass = MUI_CreateCustomClass(NULL,MUIC_NList,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
