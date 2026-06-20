
#include "class.h"

/***********************************************************************/

struct data
{
    struct Hook conHook;
    struct Hook desHook;
    struct Hook dispHook;
};

/***********************************************************************/

static SAVEDS ASM APTR
conFun(REG(a0) struct Hook *hook,REG(a1) struct title *title,REG(a2) APTR pool)
{
    register struct title *t;

    if (t = AllocPooled(pool,sizeof(struct title)))
    {
        register struct FREEDBS_Track *track = title->toc->tracks+title->track;

        t->di    = title->di;
        t->toc   = title->toc;
        t->track = title->track;

        memset(t->type,0,sizeof(t->type));
        stccpy(t->type,strings[track->audio ? MSG_TitleAudio : MSG_TitleData],sizeof(title->type)-1);

        sprintf(t->time,"%02ld:%02ld",track->min,track->sec);

        sprintf(t->trackS,"%ld",track->track);
    }

    return t;
}

/***********************************************************************/

static SAVEDS ASM void
desFun(REG(a0) struct Hook *hook,REG(a1) struct title *title,REG(a2) APTR pool)
{
    FreePooled(pool,title,sizeof(struct title));
}

/***********************************************************************/

static SAVEDS ASM LONG
dispFun(REG(a0) struct Hook *hook,REG(a1) struct title *title,REG(a2) char **array)
{
    if (title)
    {
        register struct FREEDBS_TrackInfo *track = title->di ? title->di->tracks[title->track] : NULL;

        *array++ = title->trackS;
        *array++ = title->type;
        *array++ = track ? track->title : "";
        *array++ = track ? track->artist: "";
        *array   = title->time;
    }
    else
    {
        *array++ = strings[MSG_TitleTrack];
        *array++ = strings[MSG_TitleContents];
        *array++ = strings[MSG_TitleTitle];
        *array++ = strings[MSG_TitleArtist];
        *array   = strings[MSG_TitleTime];
    }

    return 0;
}

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    if (obj = (Object *)DoSuperNew(cl,obj,
            InputListFrame,
            MUIA_ShortHelp, strings[MSG_TitleHelp],
            MUIA_NList_Format, MUIV_FreeDB_Titles_Format,
            MUIA_NList_Title, TRUE,
            MUIA_NList_MinColSortable, 100,
        TAG_MORE,msg->ops_AttrList))
    {
        register struct data *data = INST_DATA(cl,obj);

        data->conHook.h_Entry   = (APTR)conFun;
        data->conHook.h_Data    = data;
        data->desHook.h_Entry   = (APTR)desFun;
        data->desHook.h_Data    = data;
        data->dispHook.h_Entry  = (APTR)dispFun;
        data->dispHook.h_Data   = data;

        SetSuperAttrs(cl,obj,MUIA_NList_ConstructHook,&data->conHook,
                             MUIA_NList_DestructHook,&data->desHook,
                             MUIA_NList_DisplayHook,&data->dispHook,
                             TAG_DONE);
    }

    return (ULONG)obj;
}

/***********************************************************************/

static ULONG SAVEDS ASM
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:    return mNew(cl,obj,(APTR)msg);
        default:        return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initTitlesListClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->titlesList = MUI_CreateCustomClass(NULL,MUIC_NList,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
