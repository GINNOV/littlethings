
#include <proto/muimaster.h>
#include "freedb.h"

/****************************************************************************/

void ASM
freeBase(REG(a0) struct rexxLibBase *base)
{
    if (base->iconBase)
    {
        CloseLibrary(base->iconBase);
        base->iconBase = NULL;
    }

    if (base->muiMasterBase)
    {
        if (base->appClass)
        {
            MUI_DeleteCustomClass(base->appClass);
            base->appClass = NULL;
        }

        CloseLibrary(base->muiMasterBase);
        base->muiMasterBase = NULL;
    }

    if (base->localeBase)
    {
        if (base->cat)
        {
            CloseCatalog(base->cat);
            base->cat = NULL;
        }
        CloseLibrary(base->localeBase);
        base->localeBase = NULL;
    }

    if (base->rexxSysBase)
    {
        CloseLibrary((struct Library *)base->rexxSysBase);
        base->rexxSysBase = NULL;
    }

    base->flags &= ~(BASEFLG_INIT|BASEFLG_INITMUI);
}

/***********************************************************************/

BOOL ASM
initBase(REG(a0) struct rexxLibBase *base)
{
    if (base->rexxSysBase = (struct RxsLib *)OpenLibrary("rexxsyslib.library",0L))
    {
        if (base->localeBase = OpenLibrary("locale.library",37))
            base->cat = OpenCatalogA(NULL,CATNAME,NULL);

        readConfig(base->opts,FREEDBV_ReadConfig_Env);

        base->flags |= BASEFLG_INIT;

        return TRUE;
    }
    else
    {
        freeBase(base);

        return FALSE;
    }
}

/***********************************************************************/
