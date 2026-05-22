
#include "class.h"

/***********************************************************************/

ULONG
DoSuperNew(struct IClass *cl,Object *obj,ULONG tag1,...)
{
    return DoSuperMethod(cl,obj,OM_NEW,&tag1,NULL);
}

/***********************************************************************/

ULONG
getKeyChar(STRPTR string)
{
    register ULONG res = 0;

    if (string)
    {
        for (; *string && *string!='_'; string++);
        if (*string++) res = ToLower(*string);
    }

    return res;
}

/***********************************************************************/

Object *
textObject(ULONG help,STRPTR pp,BOOL clean)
{
    return TextObject,
        ((LONG)help==-1) ? TAG_IGNORE : MUIA_ShortHelp, strings[help],
        clean ? TAG_IGNORE : MUIA_Frame, MUIV_Frame_Text,
        clean ? TAG_IGNORE : MUIA_Background, MUII_TextBack,
        MUIA_Text_PreParse, pp,
    End;
}

/****************************************************************************/

Object *
stringObject(ULONG label,ULONG help,ULONG weight,ULONG max)
{
    return TextinputObject,
        StringFrame,
        MUIA_Weight, weight,
        MUIA_ControlChar, getKeyChar(strings[label]),
        ((LONG)help==-1) ? TAG_IGNORE : MUIA_ShortHelp, strings[help],
        MUIA_CycleChain, TRUE,
        MUIA_Textinput_MaxLen, max,
        MUIA_Textinput_AdvanceOnCR, TRUE,
    End;
}

/****************************************************************************/

Object *
hspace(ULONG weight)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_HSpace,0)) set(obj,MUIA_Weight,weight);

    return obj;
}

/****************************************************************************/

Object *
hbar(void)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_HBar,0)) set(obj,MUIA_Weight,0);

    return obj;
}

/****************************************************************************/

Object *
checkmarkObject(ULONG key,ULONG help)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_Checkmark,strings[key]))
        SetAttrs(obj,MUIA_CycleChain,TRUE,
                     ((LONG)help==-1) ? TAG_IGNORE : MUIA_ShortHelp,strings[help],
                     TAG_DONE);

    return obj;
}

/****************************************************************************/

Object *
cycleObject(ULONG key,ULONG help,STRPTR *labels)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_Cycle,strings[key],labels))
        SetAttrs(obj,MUIA_CycleChain,TRUE,
                     ((LONG)help==-1) ? TAG_IGNORE : MUIA_ShortHelp,strings[help],
                     TAG_DONE);

    return obj;
}

/****************************************************************************/

Object *
buttonObject(ULONG label,ULONG help)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_Button,strings[label]))
        SetAttrs(obj,MUIA_CycleChain, TRUE,
                     ((LONG)help==-1) ? TAG_IGNORE : MUIA_ShortHelp, strings[help],
                     TAG_DONE);

    return obj;
}

/***********************************************************************/

static void ASM
stripText(REG(a0) STRPTR text)
{
    for (; *text; text++) if (*text=='\33') *text = '%';
}

void ASM
stripDiscInfo(REG(a0) struct FREEDBS_DiscInfo *di)
{
    if (di)
    {
        register int i;

        if (*di->categ) stripText(di->categ);
        if (*di->genre) stripText(di->genre);
        if (*di->title) stripText(di->title);
        if (*di->artist) stripText(di->artist);
        if (*di->playOrder) stripText(di->playOrder);
        if (di->extd) stripText(di->extd);

        for (i = di->numTracks; --i>=0; )
        {
            struct FREEDBS_TrackInfo *track;

            if (track = di->tracks[i])
            {
                if (*track->title) stripText(track->title);
                if (*track->artist) stripText(track->artist);
                if (track->extd) stripText(track->extd);
            }
        }
    }
}

/***********************************************************************/

static UWORD fmtfunc[] = {0x16c0, 0x4e75};

void STDARGS
sprintf(char *to,char *fmt,...)
{
    RawDoFmt(fmt,&fmt+1,(APTR)fmtfunc,to);
}

/****************************************************************************/

struct stream
{
    char    *buf;
    int     size;
    int     counter;
    int     stop;
};

/****************************************************************************/

static void ASM
___stuff(REG(d0) char c,REG(a3) struct stream *s)
{
    if (!s->stop)
    {
        if (++s->counter>=s->size)
        {
            *(s->buf) = 0;
            s->stop   = 1;
        }
        else *(s->buf++) = c;
    }
}

/****************************************************************************/

int STDARGS
snprintf(char *buf,int size,char *fmt,...)
{
    struct stream s;

    s.buf     = buf;
    s.size    = size;
    s.counter = 0;
    s.stop    = 0;

    RawDoFmt(fmt,&fmt+1,(APTR)___stuff,&s);

    return s.counter-1;
}

/****************************************************************************/

