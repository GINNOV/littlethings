
#include "class.h"

/***********************************************************************/

ULONG
DoSuperNew(struct IClass *cl,Object *obj,ULONG tag1,...)
{
    return DoSuperMethod(cl,obj,OM_NEW,&tag1,NULL);
}

/***********************************************************************/

Object *
hbar(void)
{
    return RectangleObject,
        MUIA_Weight,            0,
        MUIA_Rectangle_HBar,    1,
    End;
}

/***********************************************************************/

Object *
urlTextObject(STRPTR url,STRPTR text)
{
    return UrltextObject,
        MUIA_Urltext_Text,      text,
        MUIA_Urltext_Url,       url,
        MUIA_Urltext_SetMax,    0,
    End;
}

/***********************************************************************/

Object *
textObject(STRPTR contents,STRPTR preParse,ULONG weight,ULONG font)
{
    return TextObject,
        MUIA_Weight,        weight,
        MUIA_Font,          font,
        MUIA_Text_Contents, contents,
        MUIA_Text_PreParse, preParse,
    End;
}

/***********************************************************************/

static UWORD fmtfunc[] = {0x16c0, 0x4e75};
void __stdargs sprintf(char *to,char *fmt,...)
{
    RawDoFmt(fmt,&fmt+1,(APTR)fmtfunc,to);
}

/****************************************************************************/
