
#include "class.h"

/***********************************************************************/

struct data
{
    Object  *id;
    Object  *categ;
    Object  *year;
    Object  *title;
    Object  *artist;
    Object  *extended;
    Object  *tList;
    LONG    active;
};

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register Object *id, *categ, *year, *title, *artist, *tList;

    if (obj = (Object *)DoSuperNew(cl,obj,
        GroupFrame,
        MUIA_Background, MUII_GroupBack,
        MUIA_ShortHelp, strings[MSG_TextHelp],
        Child, ColGroup(2),
            Child, Label2(strings[MSG_TextDiscID]),
            Child, HGroup,
                Child, id = textObject(MSG_TextDiscIDHelp,"\33c",FALSE),
                Child, Label2(strings[MSG_TextCateg]),
                Child, categ = textObject(MSG_TextCategHelp,"\33c",FALSE),
            End,
            Child, Label2(strings[MSG_TextTitle]),
            Child, title = textObject(MSG_TextTitleHelp,"\33l",FALSE),
            Child, Label2(strings[MSG_TextArtist]),
            Child, HGroup,
                Child, artist = textObject(MSG_TextArtistHelp,"\33l",FALSE),
                Child, Label2(strings[MSG_TextYear]),
                Child, year = TextObject,
                    MUIA_ShortHelp,strings[MSG_TextYearHelp],
                    MUIA_FixWidthTxt, "XXXXXX",
                    MUIA_Frame, MUIV_Frame_Text,
                    MUIA_Background, MUII_TextBack,
                    MUIA_Text_PreParse, "\33c",
                End,
            End,
        End,
        Child, NListviewObject,
            MUIA_CycleChain, 1,
            MUIA_NListview_NList, tList = titlesListObject,
            End,
        End,
        TAG_MORE,msg->ops_AttrList))
    {
        register struct data *data = INST_DATA(cl,obj);

        set(year,MUIA_Weight,20);

        data->id       = id;
        data->categ    = categ;
        data->year     = year;
        data->title    = title;
        data->artist   = artist;
        data->extended = NULL;
        data->tList    = tList;
        data->active   = -1;

        DoMethod(tList,MUIM_Notify,MUIA_NList_Active,MUIV_EveryTime,obj,3,
            MUIM_Set,MUIA_FreeDB_DiscInfo_ActiveTitle,MUIV_TriggerValue);

        DoMethod(tList,MUIM_Notify,MUIA_NList_DoubleClick,TRUE,obj,3,
            MUIM_Set,MUIA_FreeDB_DiscInfo_DoubleClick,TRUE);

        DoMethod(obj,MUIM_Notify,MUIA_FreeDB_DiscInfo_ActiveTitle,MUIV_EveryTime,obj,3,
            MUIM_Set,MUIA_NList_Active,MUIV_TriggerValue);
    }

    return (ULONG)obj;
}

/***********************************************************************/

static ASM ULONG
mGet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    switch (msg->opg_AttrID)
    {
        case MUIA_FreeDB_DiscInfo_ActiveTitle:
            *msg->opg_Storage = data->active;
            return 1;

        case MUIA_FreeDB_DiscInfo_DoubleClick:
            *msg->opg_Storage = 0;
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

    if (tag = FindTagItem(MUIA_FreeDB_DiscInfo_ActiveTitle,msg->ops_AttrList))
    {
        if (data->active==tag->ti_Data) tag->ti_Tag = TAG_IGNORE;
        else data->active = tag->ti_Data;
    }

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ASM ULONG
mSetContents(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_DiscInfo_SetContents *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (msg->flags & MUIV_FreeDB_DiscInfo_SetContents_Flags_Clear)
    {
        DoMethod(data->tList,MUIM_NList_Clear);
        set(data->id,MUIA_Text_Contents,NULL);
        set(data->categ,MUIA_Text_Contents,NULL);
        set(data->year,MUIA_Text_Contents,NULL);
        set(data->title,MUIA_Text_Contents,NULL);
        set(data->artist,MUIA_Text_Contents,NULL);
    }
    else
    {
        struct FREEDBS_DiscInfo *di = msg->di;
        struct FREEDBS_TOC      *toc = msg->toc;
        struct title            title;
        register char           buf[16];
        register int            i, tracks;

        stripDiscInfo(di);

        if (msg->flags & MUIV_FreeDB_DiscInfo_SetContents_Flags_ClearList)
            DoMethod(data->tList,MUIM_NList_Clear);

        sprintf(buf,"%08lx",toc->discID);
        set(data->id,MUIA_Text_Contents,buf);
        set(data->categ,MUIA_Text_Contents,di ? di->categ : NULL);
        if (di && di->year)
        {
            sprintf(buf,"%ld",msg->di->year);
            set(data->year,MUIA_Text_Contents,buf);
        }
        else set(data->year,MUIA_Text_Contents,NULL);
        set(data->title,MUIA_Text_Contents,di ? di->title : NULL);
        set(data->artist,MUIA_Text_Contents,di ? di->artist : NULL);

        set(data->tList,MUIA_NList_Quiet,TRUE);

        title.di  = di;
        title.toc = toc;

        tracks = (!di || di->numTracks>toc->numTracks) ? toc->numTracks : di->numTracks;

        for (i = 0; i<tracks; i++)
        {
            title.track = i;
            DoMethod(data->tList,MUIM_NList_InsertSingle,&title,MUIV_NList_Insert_Bottom);
        }

        SetAttrs(data->tList,
            MUIA_NList_Format, di ? ((msg->di->flags & FREEDBV_DiscInfo_Flags_MultiArtist) ? MUIV_FreeDB_Titles_Format : MUIV_FreeDB_Titles_NAFormat) : MUIV_FreeDB_Titles_NDFormat,
            MUIA_NList_Quiet,  FALSE,
            TAG_DONE);
    }

    return 1;
}

/***********************************************************************/

static ULONG SAVEDS ASM
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:                            return mNew(cl,obj,(APTR)msg);
        case OM_GET:                            return mGet(cl,obj,(APTR)msg);
        case OM_SET:                            return mSets(cl,obj,(APTR)msg);
        case MUIM_FreeDB_DiscInfo_SetContents:  return mSetContents(cl,obj,(APTR)msg);
        default:                                return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initDiscInfoClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->discInfo = MUI_CreateCustomClass(NULL,MUIC_Group,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
