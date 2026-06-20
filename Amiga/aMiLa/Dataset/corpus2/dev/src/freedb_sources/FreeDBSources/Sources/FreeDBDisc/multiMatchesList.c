
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
conFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_MultiHookMessage *msg,REG(a2) APTR pool)
{
    return msg;
}

/***********************************************************************/

static SAVEDS ASM void
desFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_MultiHookMessage *msg,REG(a2) APTR pool)
{
    FreeDBFreeMessage(msg);
}

/***********************************************************************/

static SAVEDS ASM LONG
dispFun(REG(a0) struct Hook *hook,REG(a1) struct FREEDBS_MultiHookMessage *msg,REG(a2) char **array)
{
    if (msg)
    {
        *array++ = msg->discIDString;
        *array++ = msg->categ;
        *array++ = msg->title;
        *array   = msg->artist;
    }
    else
    {
        *array++ = strings[MSG_MatchesDiscID];
        *array++ = strings[MSG_MatchesCateg];
        *array++ = strings[MSG_MatchesTitle];
        *array   = strings[MSG_MatchesArtist];
    }

    return 0;
}

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    if (obj = (Object *)DoSuperNew(cl,obj,
            InputListFrame,
            MUIA_ShortHelp, strings[MSG_MatchesHelp],
            MUIA_NList_Format, MUIV_FreeDB_Matches_Format,
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

        SetSuperAttrs(cl,obj,MUIA_NList_ConstructHook, &data->conHook,
                             MUIA_NList_DestructHook,  &data->desHook,
                             MUIA_NList_DisplayHook,   &data->dispHook,
                             TAG_DONE);
    }

    return (ULONG)obj;
}

/***********************************************************************/

/* XXX Really don't understand why
** and from whom <MUIA_NList_Active,-4>
** is propagated.
*/

static ASM ULONG
mSet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register struct TagItem *tag;

    if ((tag = FindTagItem(MUIA_NList_Active,msg->ops_AttrList)) && ((LONG)tag->ti_Data==-4))
        tag->ti_Tag = TAG_IGNORE;

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ULONG SAVEDS ASM
dispatcher (REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:    return mNew(cl,obj,(APTR)msg);
        case OM_SET:    return mSet(cl,obj,(APTR)msg);
        default:        return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initMultiMatchesListClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->multiMatchesList = MUI_CreateCustomClass(NULL,MUIC_NList,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
