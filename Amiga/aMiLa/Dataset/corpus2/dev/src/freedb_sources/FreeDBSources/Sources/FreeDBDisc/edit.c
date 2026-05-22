
#include "class.h"

/***********************************************************************/

static STRPTR categs[] =
{
    "misc",
    "blues",
    "classical",
    "country",
    "data",
    "folk",
    "jazz",
    "newage",
    "reggae",
    "rock",
    "soundtrack",

    NULL
};

#define MISC 0

static ULONG ASM
findCategByName(REG(a0) STRPTR name)
{
    register STRPTR *s;
    register int    i;

    for (i = 0, s = categs; *s && stricmp(name,*s); s++, i++);

    return (ULONG)(*s ? i : MISC);
}

/***********************************************************************/

struct data
{
    Object  *win;
    Object  *disc;
    Object  *id;
    Object  *categ;
    Object  *year;
    Object  *title;
    Object  *artist;
    Object  *extended;
    Object  *virtual;
    Object  *titles;
    Object  *space;
    Object  *use;
    Object  *restore;
    Object  *submit;
    int     tracks;
    ULONG   flags;
};

enum
{
    MUIV_FreeDB_Edit_Flags_Nothing = 1,
    MUIV_FreeDB_Edit_Flags_Shown    = 2,
    MUIV_FreeDB_Edit_Flags_DelayUpdate  = 4,
};

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register Object *id, *categ, *year, *title, *artist, *virtual,
                    *titles, *use, *restore, *submit, *space;

    if (!(titles = ColGroup(2),End)) return 0;

    if (obj = (Object *)DoSuperNew(cl,obj,
        GroupFrame,
        MUIA_Background, MUII_GroupBack,
        MUIA_ShortHelp, strings[MSG_EditHelp],
        Child, ColGroup(2),
            Child, Label2(strings[MSG_TextDiscID]),
            Child, HGroup,
                Child, id = textObject(MSG_TextDiscIDHelp,"\33c",FALSE),
                Child, Label2(strings[MSG_EditCateg]),
                Child, categ = cycleObject(MSG_EditCateg,MSG_TextCategHelp,categs),
            End,
            Child, Label2(strings[MSG_EditTitle]),
            Child, title = stringObject(MSG_EditTitle,MSG_TextTitleHelp,100,257),
            Child, Label2(strings[MSG_EditArtist]),
            Child, HGroup,
                Child, artist = stringObject(MSG_EditArtist,MSG_TextArtistHelp,100,257),
                Child, Label2(strings[MSG_EditYear]),
                Child, year = TextinputObject,
                    StringFrame,
                    MUIA_FixWidthTxt, "XXXXXX",
                    MUIA_ControlChar, getKeyChar(strings[MSG_EditYear]),
                    MUIA_ShortHelp, strings[MSG_TextYearHelp],
                    MUIA_CycleChain, TRUE,
                    MUIA_Textinput_MaxLen, 5,
                    MUIA_Textinput_IsNumeric, TRUE,
                    MUIA_Textinput_MinVal, 0,
                    MUIA_Textinput_Format, MUIV_Textinput_Format_Right,
                    MUIA_Textinput_AdvanceOnCR, TRUE,
                End,
            End,
        End,
        Child, ScrollgroupObject,
            MUIA_Scrollgroup_Contents, virtual = VirtgroupObject,
                MUIA_Background, MUII_ListBack,
                InputListFrame,
                Child, space = HVSpace,
            End,
        End,
        Child, HGroup,
            MUIA_Group_SameSize, 1,
            Child, use = buttonObject(MSG_EditUse,MSG_EditUseHelp),
            Child, HSpace(0),
            Child, restore = buttonObject(MSG_EditRestore,MSG_EditRestoreHelp),
            Child, HSpace(0),
            Child, submit = buttonObject(MSG_EditSubmit,MSG_EditSubmitHelp),
        End,
        TAG_MORE,msg->ops_AttrList))
    {
        register struct data *data = INST_DATA(cl,obj);

        data->win      = NULL;
        data->disc     = NULL;
        data->id       = id;
        data->categ    = categ;
        data->year     = year;
        data->title    = title;
        data->artist   = artist;
        data->extended = NULL;
        data->virtual  = virtual;
        data->titles   = titles;
        data->use      = use;
        data->restore  = restore;
        data->submit   = submit;
        data->space    = space;
        data->tracks   = 0;
        data->flags    |= MUIV_FreeDB_Edit_Flags_Nothing;

        DoMethod(use,MUIM_Notify,MUIA_Pressed,0,obj,1,MUIM_FreeDB_Edit_GadgetsToInfo);
        DoMethod(restore,MUIM_Notify,MUIA_Pressed,0,obj,1,MUIM_FreeDB_Edit_InfoToGadgets);
        DoMethod(submit,MUIM_Notify,MUIA_Pressed,0,obj,1,MUIM_FreeDB_Edit_Submit);

        DoMethod(categ,MUIM_Notify,MUIA_Cycle_Active,MUIV_EveryTime,use,3,MUIM_Set,MUIA_Disabled,FALSE);
        DoMethod(year,MUIM_Notify,MUIA_Textinput_Changed,MUIV_EveryTime,use,3,MUIM_Set,MUIA_Disabled,FALSE);
        DoMethod(title,MUIM_Notify,MUIA_Textinput_Changed,MUIV_EveryTime,use,3,MUIM_Set,MUIA_Disabled,FALSE);
        DoMethod(artist,MUIM_Notify,MUIA_Textinput_Changed,MUIV_EveryTime,use,3,MUIM_Set,MUIA_Disabled,FALSE);

        DoMethod(use,MUIM_Notify,MUIA_Disabled,MUIV_EveryTime,restore,3,MUIM_Set,MUIA_Disabled,MUIV_TriggerValue);
    }
    else MUI_DisposeObject(titles);

    return (ULONG)obj;
}

/***********************************************************************/

static ULONG SAVEDS ASM
mEditSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Edit_Setup *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    data->disc = msg->disc;

    return 0;
}

/***********************************************************************/

static void
freeTitles(struct data *data)
{
    struct List     *list;
    struct Node     *mstate;
    register Object *o;

    DoMethod(data->titles,MUIM_Group_InitChange);

    get(data->titles,MUIA_Group_ChildList,&list);
    for (mstate = list->lh_Head; o = NextObject(&mstate); )
    {
        DoMethod(data->titles,OM_REMMEMBER,o);
        MUI_DisposeObject(o);
    }

    DoMethod(data->titles,MUIM_Group_ExitChange);
}

/***********************************************************************/

static ULONG SAVEDS ASM
mInfoToGadgets(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    struct FREEDBS_DiscInfo *di;
    struct FREEDBS_TOC      *toc;
    register ULONG          res;
    register char           buf[256];
    register int            i, tracks;

    data->tracks = 0;
    data->flags &= ~MUIV_FreeDB_Edit_Flags_DelayUpdate;

    res = DoMethod(data->disc,MUIM_FreeDB_Disc_ObtainInfo,&di,&toc);
    if (!(res & MUIV_FreeDB_Disc_ObtainInfo_Res_TOC)) toc = NULL;
    if (!(res & MUIV_FreeDB_Disc_ObtainInfo_Res_DiscInfo)) di = NULL;

    if (!toc && !di)
    {
        if (!(data->flags & MUIV_FreeDB_Edit_Flags_Nothing))
        {
            DoMethod(data->virtual,MUIM_Group_InitChange);
            DoMethod(data->virtual,OM_REMMEMBER,data->titles);
            freeTitles(data);
            data->flags |= MUIV_FreeDB_Edit_Flags_Nothing;
            DoMethod(data->virtual,MUIM_Group_ExitChange);

            set(data->id,MUIA_Text_Contents,NULL);
            set(data->categ,MUIA_Disabled,TRUE);
            SetAttrs(data->title,MUIA_Textinput_Contents,NULL,MUIA_Disabled,TRUE,TAG_DONE);
            SetAttrs(data->artist,MUIA_Textinput_Contents,NULL,MUIA_Disabled,TRUE,TAG_DONE);
            SetAttrs(data->year,MUIA_Textinput_Integer,0,MUIA_Disabled,TRUE,TAG_DONE);
        }
        DoMethod(data->disc,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);

        set(data->use,MUIA_Disabled,TRUE);

        return 0;
    }

    DoMethod(data->virtual,MUIM_Group_InitChange);

    if (!(data->flags & MUIV_FreeDB_Edit_Flags_Nothing))
    {
        DoMethod(data->virtual,OM_REMMEMBER,data->titles);
        freeTitles(data);
    }

    DoMethod(data->titles,MUIM_Group_InitChange);

    if (di)
    {
        SetAttrs(data->categ,MUIA_Cycle_Active,findCategByName(di->categ),MUIA_Disabled,FALSE,TAG_DONE);
        SetAttrs(data->year,MUIA_Textinput_Integer,di->year,MUIA_Disabled,FALSE,TAG_DONE);
        SetAttrs(data->title,MUIA_Textinput_Contents,di->title,MUIA_Disabled,FALSE,TAG_DONE);
        SetAttrs(data->artist,MUIA_Textinput_Contents,di->artist,MUIA_Disabled,FALSE,TAG_DONE);

    }
    else
    {
        SetAttrs(data->categ,MUIA_Cycle_Active,MISC,MUIA_Disabled,FALSE,TAG_DONE);
        SetAttrs(data->year,MUIA_Textinput_Integer,0,MUIA_Disabled,FALSE,TAG_DONE);
        SetAttrs(data->title,MUIA_Textinput_Contents,NULL,MUIA_Disabled,FALSE,TAG_DONE);
        SetAttrs(data->artist,MUIA_Textinput_Contents,NULL,MUIA_Disabled,FALSE,TAG_DONE);
    }

    tracks = toc->numTracks;

    for (i = 0; i<tracks; i++)
    {
        register Object *lo;

        snprintf(buf,sizeof(buf),strings[MSG_EditTTitle],i+1);
        if (lo = Label2(buf))
        {
            register Object *so;

            if (so = stringObject(NULL,MSG_EditTTitleHelp,100,257))
            {
                register char *c;

                DoMethod(so,MUIM_Notify,MUIA_Textinput_Changed,MUIV_EveryTime,data->use,3,MUIM_Set,MUIA_Disabled,FALSE);

                if (di)
                {
                    register struct FREEDBS_TrackInfo *track = di->tracks[i];

                    if (track->flags & FREEDBV_TrackInfo_Flags_Artist)
                    {
                        snprintf(buf,sizeof(buf),"%s / %s",track->artist,track->title);
                        c = buf;
                    }
                    else c = track->title;
                }
                else c = NULL;

                set(so,MUIA_Textinput_Contents,c);

                DoMethod(data->titles,OM_ADDMEMBER,lo);
                DoMethod(data->titles,OM_ADDMEMBER,so);
            }
            else MUI_DisposeObject(lo);
        }
    }

    data->tracks = i;

    DoMethod(data->titles,MUIM_Group_ExitChange);

    DoMethod(data->virtual,OM_REMMEMBER,data->space);
    DoMethod(data->virtual,OM_ADDMEMBER,data->titles);
    DoMethod(data->virtual,OM_ADDMEMBER,data->space);
    data->flags &= ~MUIV_FreeDB_Edit_Flags_Nothing;

    DoMethod(data->virtual,MUIM_Group_ExitChange);

    sprintf(buf,"%08lx",toc->discID);
    set(data->id,MUIA_Text_Contents,buf);

    DoMethod(data->disc,MUIM_FreeDB_Disc_ReleaseInfo,FALSE);

    set(data->use,MUIA_Disabled,TRUE);

    return 0;
}

/***********************************************************************/

static ULONG SAVEDS ASM
mGadgetsToInfo(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Edit_InfoToGadgets *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    struct FREEDBS_TOC      *toc;
    struct FREEDBS_DiscInfo *di;
    struct List             *list;
    struct Node             *mstate;
    STRPTR                  title, artist, ttitle;
    register ULONG          res, rev, update = FALSE;
    ULONG                   categ, year;
    register int            i;

    res = DoMethod(data->disc,MUIM_FreeDB_Disc_ObtainInfo,&di,&toc);

    if (!(res & (MUIV_FreeDB_Disc_ObtainInfo_Res_DiscInfo|MUIV_FreeDB_Disc_ObtainInfo_Res_TOC)))
        goto end;

    get(data->title,MUIA_Textinput_Contents,&title);
    if (!*title)
    {
        if (data->win) set(data->win,MUIA_Window_ActiveObject,data->title);
        goto end;
    }
    get(data->artist,MUIA_Textinput_Contents,&artist);
    get(data->categ,MUIA_Cycle_Active,&categ);
    get(data->year,MUIA_Textinput_Integer,&year);

    get(data->titles,MUIA_Group_ChildList,&list);
    for (mstate = list->lh_Head; NextObject(&mstate); )
    {
        Object *o;

        get(o = NextObject(&mstate),MUIA_Textinput_Contents,&ttitle);
        if (!*ttitle)
        {
            if (data->win) set(data->win,MUIA_Window_ActiveObject,o);
            goto end;
        }
    }

    rev = di->revision;

    FreeDBSetDiscInfo(di,FREEDBA_Tracks, toc->numTracks,
                         FREEDBA_DiscID, toc->discID,
                         FREEDBA_Title,  title,
                         FREEDBA_Artist, artist,
                         FREEDBA_Categ,  categs[categ],
                         FREEDBA_Year,   year,
                         TAG_DONE);

    di->revision = rev;

    for (i = 0, mstate = list->lh_Head; NextObject(&mstate); )
    {
        register char buf[256], *t, *a;

        get(NextObject(&mstate),MUIA_Textinput_Contents,&ttitle);

        strcpy(buf,ttitle);

        if (t = strstr(buf," / "))
        {
            *t = 0;
            t += 3;
            if (!*t) t = NULL;
        }
        else t = NULL;

        if (t)
        {
            a = buf;
        }
        else
        {
            a = NULL;
            t = buf;
        }

        FreeDBSetDiscInfoTrack(di,i++,FREEDBA_Title,t,
                                      FREEDBA_Artist,a,
                                      TAG_DONE);
    }

    update = 1;

end:

    set(data->use,MUIA_Disabled,update);
    DoMethod(data->disc,MUIM_FreeDB_Disc_ReleaseInfo,update);

    return update;
}

/***********************************************************************/

static ASM ULONG
mSubmit(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (data->win) set(data->win,MUIA_Window_Sleep,TRUE);

    if (DoMethod(obj,MUIM_FreeDB_Edit_GadgetsToInfo))
        DoMethod(data->disc,MUIM_FreeDB_Disc_Submit);

    if (data->win) set(data->win,MUIA_Window_Sleep,FALSE);
    return FALSE;
}

/***********************************************************************/

static ASM ULONG
mSetup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    if (!DoSuperMethodA(cl,obj,msg)) return FALSE;
    data->win = _win(obj);

    return TRUE;
}

/***********************************************************************/

static ASM ULONG
mCleanup(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data *data = INST_DATA(cl,obj);

    data->win = NULL;

    return DoSuperMethodA(cl,obj,msg);
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
        case MUIM_FreeDB_Edit_Setup:            return mEditSetup(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Edit_InfoToGadgets:    return mInfoToGadgets(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Edit_GadgetsToInfo:    return mGadgetsToInfo(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Edit_Submit:           return mSubmit(cl,obj,(APTR)msg);
        default:                                return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initEditClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->edit = MUI_CreateCustomClass(NULL,MUIC_Group,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
