
#include <proto/datatypes.h>
#include <datatypes/pictureclass.h>
#include <mui/SpeedButton_mcc.h>
#include "class.h"

/***********************************************************************/

struct special
{
    ULONG   exclude;
    ULONG   flags;
};

enum
{
    SPECIALV_Skip     = 1,
    SPECIALV_Disabled = 2,
};

struct data
{
    struct brush    **brushes;
    struct special  *specials;
    ULONG           nb;
    ULONG           nbr;
    ULONG           active;
    ULONG           flags;
};

enum
{
    MUIV_FreeDB_Bar_Flags_NoBrushes = 1,
};

/***********************************************************************/

struct brush
{
    UWORD           width;
    UWORD           height;
    struct BitMap   *bitMap;
    ULONG           *colors;
    Object          *dto;
};

/***********************************************************************/

static LONG ASM
loadDTBrush(REG(a0) struct brush *brush,REG(a1) STRPTR file)
{
    struct BitMapHeader *bmh;

    if (!(brush->dto = NewDTObject(file,DTA_GroupID,GID_PICTURE,PDTA_Remap,FALSE,PDTA_DestMode,PMODE_V42,TAG_DONE)) ||
        !(DoMethod(brush->dto,DTM_PROCLAYOUT,NULL,1)) ||
        !(GetDTAttrs(brush->dto,PDTA_DestBitMap,&brush->bitMap,PDTA_CRegs,&brush->colors,PDTA_BitMapHeader,&bmh,TAG_DONE)==3))
    {
        if (brush->dto)
        {
            DisposeDTObject(brush->dto);
            brush->dto = NULL;
        }

        return 0;
    }
    else
    {
        brush->width  = bmh->bmh_Width;
        brush->height = bmh->bmh_Height;

        return 1;
    }
}

/***********************************************************************/

static void ASM
freeBrushes(REG(a0) struct brush **brushes,REG(d0) int nbr)
{
    register int i;

    for (i = 0; i<nbr && brushes[i]; i++)
    {
        register Object *dto = brushes[i]->dto;

        brushes[i] = NULL;

        if (dto) DisposeDTObject(dto);
        else break;
    }
}

/***********************************************************************/

static ASM ULONG
mNew(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opSet *msg)
{
    register struct SBButton                *source, *s;
    register struct MUIS_SpeedBar_Button    *buttons;
    register struct brush                   **brushes, *brush;
    register struct Process                 *me;
    register struct Window                  *win;
    register struct TagItem                 *tag, *attrs = msg->ops_AttrList;
    register struct special                 *specials;
    struct TagItem                          *tstate;
    register STRPTR                         imagesDrawerName = NULL, spacer = NULL;
    register BPTR                           imagesDrawer, oldDir;
    register ULONG                          viewMode = MUIV_SpeedBar_ViewMode_Gfx,
                                            useSpace = TRUE, spacerIndex = -1,
                                            allEnabled = FALSE;
    register int                            nb, nbr, i, j, bsize, brpsize, brsize, noBrushes;

    for (tstate = attrs; tag = NextTagItem(&tstate); )
    {
        register ULONG tidata = tag->ti_Data;

        switch (tag->ti_Tag)
        {
            case MUIA_FreeDB_Bar_Buttons:
                source = (struct SBButton *)tidata;
                break;

            case MUIA_FreeDB_Bar_ImagesDrawer:
                imagesDrawerName = (STRPTR)tidata;
                break;

            case MUIA_FreeDB_Bar_Spacer:
                spacer = (STRPTR)tidata;
                break;

            case MUIA_SpeedBar_ViewMode:
                viewMode = tidata;
                break;

            case MUIA_FreeDB_Disc_UseSpace:
                useSpace = tidata;
                break;

            case MUIA_FreeDB_Bar_AllUnabled:
                allEnabled = tidata;
                break;

            default:
                break;
        }
    }

    if (!source) return 0;

    for (nb = nbr = 0, s = source; ; s++, nb++)
    {
        if (s->file==(STRPTR)MUIV_SpeedBar_End) break;
        if (s->file!=(STRPTR)MUIV_SpeedBar_Spacer) nbr++;
    }
    nb++;

    if (!useSpace) spacer = NULL;
    else if (spacer) nbr++;
    bsize   = sizeof(struct MUIS_SpeedBar_Button)*nb;
    brpsize = sizeof(struct brush *)*nbr;
    brsize  = sizeof(struct brush)*nbr;

    if (!(buttons = AllocVec(bsize,MEMF_PUBLIC|MEMF_CLEAR)) ||
        !(brushes = AllocVec(brpsize+brsize+sizeof(struct special)*nb,MEMF_PUBLIC|MEMF_CLEAR)))
    {
        if (buttons) FreeVec(buttons);
        return 0;
    }
    brush    = (struct brush *)((UBYTE *)brushes+brpsize);
    specials = (struct special *)((UBYTE *)brushes+brpsize+brsize);

    me  = (struct Process *)FindTask(NULL);
    win = me->pr_WindowPtr;
    me->pr_WindowPtr = (struct Window *)-1;

    if (imagesDrawerName && (imagesDrawer = Lock(imagesDrawerName,SHARED_LOCK)))
        oldDir = CurrentDir(imagesDrawer);
    else imagesDrawer = NULL;

    for (noBrushes = i = j = 0, s = source; i<nb; i++)
    {
        if (s[i].file==(STRPTR)MUIV_SpeedBar_Spacer)
        {
            buttons[i].Img = MUIV_SpeedBar_Spacer;
            specials[i].flags |= SPECIALV_Skip;
            continue;
        }

        if (s[i].file==(STRPTR)MUIV_SpeedBar_End)
        {
            buttons[i].Img = MUIV_SpeedBar_End;
            continue;
        }

        if (!noBrushes)
            if (!loadDTBrush(brushes[j] = brush+j,s[i].file))
            {
                freeBrushes(brushes,nbr);
                noBrushes = 1;
                j = 0;
            }
            else buttons[i].Img = j++;

        buttons[i].Text  = strings[s[i].text];
        buttons[i].Help  = s[i].help ? strings[s[i].help] : NULL;

        if (allEnabled) buttons[i].Flags = s[i].flags & ~MUIV_SpeedBar_ButtonFlag_Disabled;
        else buttons[i].Flags = s[i].flags;

        if (specials[i].exclude = s[i].exclude)
        {
            buttons[i].Flags |= MUIV_SpeedBar_ButtonFlag_Immediate;
            buttons[i].Flags &= ~MUIV_SpeedBar_ButtonFlag_Toggle;
        }
    }

    if (!noBrushes && spacer && loadDTBrush(brushes[j] = brush+j,spacer))
        spacerIndex = j;

    if (imagesDrawer)
    {
        CurrentDir(oldDir);
        UnLock(imagesDrawer);
    }

    me->pr_WindowPtr = win;

    if (obj = (Object *)DoSuperNew(cl,obj,
        MUIA_Group_Horiz,               TRUE,
        MUIA_SpeedBar_Buttons,          buttons,
        MUIA_SpeedBar_Images,           brushes,
        MUIA_SpeedBar_ViewMode,         noBrushes ? MUIV_SpeedBar_ViewMode_Text : viewMode,
        MUIA_SpeedBar_SpacerIndex,      spacerIndex,
        MUIA_SpeedBar_StripUnderscore,  TRUE,
        MUIA_SpeedBar_SameWidth,        TRUE,
        MUIA_SpeedBar_SameHeight,       TRUE,
        TAG_MORE,attrs))
    {
        register struct data    *data = INST_DATA(cl,obj);
        register ULONG          sel = -1;

        data->nb       = nb;
        data->nbr      = nbr;
        data->brushes  = brushes;
        data->specials = specials;
        data->active   = -1;
        data->flags    = noBrushes ? MUIV_FreeDB_Bar_Flags_NoBrushes : 0;

        for (i = 0; i<nb; i++)
        {
            if (specials[i].exclude)
            {
                DoMethod(buttons[i].Object,MUIM_Notify,MUIA_Selected,TRUE,obj,3,MUIM_Set,MUIA_FreeDB_Bar_Active,i);
                if (buttons[i].Flags & MUIV_SpeedBar_ButtonFlag_Selected) sel = i;
            }
        }

        if (sel>=0) set(obj,MUIA_FreeDB_Bar_Active,sel);
    }
    else
    {
        if (brushes) freeBrushes(brushes,nbr);
        FreeVec(brushes);
    }

    FreeVec(buttons);

    return (ULONG)obj;
}

/***********************************************************************/

static ASM ULONG
mGet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct opGet *msg)
{
    register struct data *data = INST_DATA(cl,obj);

    switch (msg->opg_AttrID)
    {
        case MUIA_FreeDB_Bar_Active:
            *msg->opg_Storage = data->active;
            return 1;

        case MUIA_FreeDB_Bar_NoBrushes:
            *msg->opg_Storage = data->flags & MUIV_FreeDB_Bar_Flags_NoBrushes;
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
    register ULONG          nb = data->nb;

    for (tstate = msg->ops_AttrList; tag = NextTagItem(&tstate); )
    {
        register ULONG tidata = tag->ti_Data;

        switch(tag->ti_Tag)
        {
            case MUIA_SpeedBar_ViewMode:
                if (data->flags & MUIV_FreeDB_Bar_Flags_NoBrushes)
                    tag->ti_Tag = TAG_IGNORE;
                break;

            case MUIA_FreeDB_Bar_Active:
            {
                register struct data    *data = INST_DATA(cl,obj);
                register ULONG          button = tidata, exclude;
                register Object         *o;
                register int            i;

                if (data->active==button || button<0 || button>nb-1 || !(exclude = data->specials[button].exclude))
                {
                    tag->ti_Tag = TAG_IGNORE;
                    break;
                }

                data->active = button;
                o = (Object *)DoSuperMethod(cl,obj,MUIM_SpeedBar_GetObject,button);
                set(o,MUIA_Selected,TRUE);

                for (i = 0; i<nb; i++)
                    if (exclude & (1<<i))
                    {
                        register Object *oo = (Object *)DoSuperMethod(cl,obj,MUIM_SpeedBar_GetObject,i);
                        ULONG           sel;

                        get(oo,MUIA_Selected,&sel);
                        if (sel) set(oo,MUIA_Selected,FALSE);
                    }

                break;
            }
        }
    }

    return DoSuperMethodA(cl,obj,msg);
}

/***********************************************************************/

static ASM ULONG
mBarSet(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Bar_Set *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          button = msg->button;
    register Object         *o;
    register ULONG          tag, value;

    if (button>=data->nb) return 0;
    o = (Object *)DoSuperMethod(cl,obj,MUIM_SpeedBar_GetObject,button);

    set(o,tag = msg->tag,value = msg->value);

    if (msg->remember)
    {
        register struct special *specials = data->specials;

        switch (tag)
        {
            case MUIA_Disabled:
                if (value) specials[button].flags |= SPECIALV_Disabled;
                else specials[button].flags &= ~SPECIALV_Disabled;
                break;

            default:
                break;
        }
    }

    return 1;
}

/***********************************************************************/


static ASM ULONG
mBarDisable(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Bar_Disable *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register struct special *specials = data->specials;
    register ULONG          restore = msg->restore, nb = data->nb;
    register int            i;

    for (i = 0; i<nb; i++)
    {
        register Object *o;

        if (specials[i].flags & SPECIALV_Skip) continue;

        o = (Object *)DoSuperMethod(cl,obj,MUIM_SpeedBar_GetObject,i);

        if (restore) set(o,MUIA_Disabled,specials[i].flags & SPECIALV_Disabled);
        else
        {
            ULONG dis;

            get(o,MUIA_Disabled,&dis);
            if (dis) specials[i].flags |= SPECIALV_Disabled;
            else specials[i].flags &= ~SPECIALV_Disabled;

            set(o,MUIA_Disabled,TRUE);
        }
    }

    return 0;
}

/***********************************************************************/

static ASM ULONG
mBarNotify(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) struct MUIP_FreeDB_Bar_Notify *msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register ULONG          button = msg->button, res;

    if (button>=data->nb) return 0;

    msg->button = MUIM_Notify;
    res = DoMethodA((Object *)DoSuperMethod(cl,obj,MUIM_SpeedBar_GetObject,button),(Msg)&msg->button);
    msg->button = button;

    return res;
}

/***********************************************************************/

static ASM ULONG
mDispose(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    register struct data    *data = INST_DATA(cl,obj);
    register struct brush   **brushes = data->brushes;
    register ULONG          res, nbr = data->nbr;

    res = DoSuperMethodA(cl,obj,msg);
    freeBrushes(brushes,nbr);
    FreeVec(brushes);

    return res;
}

/***********************************************************************/

static ULONG SAVEDS ASM
dispatcher(REG(a0) struct IClass *cl,REG(a2) Object *obj,REG(a1) Msg msg)
{
    switch(msg->MethodID)
    {
        case OM_NEW:                    return mNew(cl,obj,(APTR)msg);
        case OM_GET:                    return mGet(cl,obj,(APTR)msg);
        case OM_SET:                    return mSets(cl,obj,(APTR)msg);
        case OM_DISPOSE:                return mDispose(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Bar_Set:       return mBarSet(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Bar_Notify:    return mBarNotify(cl,obj,(APTR)msg);
        case MUIM_FreeDB_Bar_Disable:   return mBarDisable(cl,obj,(APTR)msg);
        default:                        return DoSuperMethodA(cl,obj,msg);
    }
}

/***********************************************************************/

BOOL ASM
initBarClass(REG(a0) struct libBase *base)
{
    return (BOOL)(base->bar = MUI_CreateCustomClass(NULL,MUIC_SpeedBar,NULL,sizeof(struct data),dispatcher));
}

/***********************************************************************/
