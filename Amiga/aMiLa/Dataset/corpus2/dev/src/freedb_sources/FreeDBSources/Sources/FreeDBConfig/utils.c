
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
stringObject(ULONG label,ULONG help,ULONG max)
{
    return TextinputObject,
        StringFrame,
        MUIA_ControlChar,      getKeyChar(strings[label]),
        MUIA_ShortHelp,        help ? strings[help] : NULL,
        MUIA_CycleChain,       TRUE,
        MUIA_Textinput_MaxLen, max,
    End;
}

/***********************************************************************/

Object *
portObject(ULONG label,ULONG help)
{
    return TextinputObject,
        StringFrame,
        MUIA_FixWidthTxt,           "XXXXXXXXXX",
        MUIA_ControlChar,           getKeyChar(strings[label]),
        MUIA_ShortHelp,             strings[help],
        MUIA_CycleChain,            TRUE,
        MUIA_Textinput_MaxLen,      7,
        MUIA_Textinput_AcceptChars, "0123456789",
        MUIA_Textinput_Format,      MUIV_Textinput_Format_Right,
    End;
}

/***********************************************************************/

Object *
checkmarkObject(ULONG key,ULONG help)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_Checkmark,strings[key]))
        SetAttrs(obj,MUIA_CycleChain,TRUE,MUIA_ShortHelp,strings[help],TAG_DONE);


    return obj;
}

/***********************************************************************/

Object *
textObject(STRPTR pp)
{
    return TextObject,
        MUIA_Frame,         MUIV_Frame_Text,
        MUIA_Background,    MUII_TextBack,
        MUIA_Text_PreParse, pp,
    End;
}

/***********************************************************************/

Object *
buttonObject(ULONG label,ULONG help)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_Button,strings[label]))
        SetAttrs(obj,MUIA_CycleChain, TRUE,
                     MUIA_ShortHelp,  strings[help],
                     TAG_DONE);

    return obj;
}

/***********************************************************************/

Object *
hspace(ULONG weight)
{
    register Object *obj;

    if (obj = MUI_MakeObject(MUIO_HSpace,0))
        set(obj,MUIA_Weight,weight);

    return obj;
}

/****************************************************************************/

static UWORD fmtfunc[] = {0x16c0, 0x4e75};
void __stdargs sprintf(char *to,char *fmt,...)
{
    RawDoFmt(fmt,&fmt+1,(APTR)fmtfunc,to);
}

/****************************************************************************/
