
#include "class.h"

/***********************************************************************/

static LONG ids[] =
{
    MSG_Title,
    MSG_By,
    MSG_Infos,
    MSG_ThirdParts,
    MSG_NList,
    MSG_Speedbar,
    MSG_Textinput,
    MSG_OfCourse,
    MSG_LibVersion,
    MSG_Author,
    MSG_Support,
    MSG_Freedb,
    MSG_Translation,
    -1,
};

static STRPTR staticStrings[] =
{
    "About FreeDB",
    "Written by Alfonso Ranieri\nReleased under GPL 2.",
    "Infos",
    "Third parts",
    "NList(view).mcc by",
    "Speedbar.mcc by",
    "Textinput.mcc by",
    ", of course",
    "Version:",
    "Author:",
    "Support:",
    "freedb site:",
    NULL
};

STRPTR localizedStrings[sizeof(ids)/sizeof(ULONG)-1];
STRPTR *strings;

/***********************************************************************/

void ASM
initStrings(REG(a0) struct libBase *base)
{
    register STRPTR *s, *ss;
    register LONG   *id;

    if ((base->localeBase = OpenLibrary("locale.library",37)) &&
        (base->cat = OpenCatalogA(NULL,CATNAME,NULL)))
    {
        strings = localizedStrings;

        for (id = ids, s = strings, ss = staticStrings; *id!=-1; id++, s++, ss++)
            *s = GetCatalogStr(libBase->cat,*id,*ss);
    }
    else strings = staticStrings;
}

/***********************************************************************/
