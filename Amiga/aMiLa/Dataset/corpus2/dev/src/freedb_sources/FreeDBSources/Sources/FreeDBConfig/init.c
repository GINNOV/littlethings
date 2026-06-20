
#include "class.h"

/***********************************************************************/

ULONG SAVEDS ASM
query(REG(d0) LONG which)
{
    switch (which)
    {
        case 0:     return (ULONG)libBase->class;
        default:    return 0;
    }
}

/****************************************************************************/

void ASM
freeBase(REG(a0) struct libBase *base)
{
    if (base->muiMasterBase)
    {
        if (base->sitesListClass)
        {
            MUI_DeleteCustomClass(base->sitesListClass);
            base->sitesListClass = NULL;
        }

        if (base->class)
        {
            MUI_DeleteCustomClass(base->class);
            base->class = NULL;
        }

        CloseLibrary(base->muiMasterBase);
        base->muiMasterBase = NULL;
    }

    if (base->freeDBBase)
    {
        CloseLibrary(base->freeDBBase);
        base->freeDBBase = NULL;
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

    base->flags &= ~BASEFLG_INIT;
}

/***********************************************************************/

BOOL ASM
initBase(REG(a0) struct libBase *base)
{
    if ((base->freeDBBase = OpenLibrary("freedb.library",1)) &&
        (base->muiMasterBase = OpenLibrary("muimaster.library",19)) &&
        initSitesListClass(base) &&
        initClass(base))
    {
        base->dosBase       = (APTR)base->class->mcc_DOSBase;
        base->utilityBase   = base->class->mcc_UtilityBase;
        base->intuitionBase = (APTR)base->class->mcc_IntuitionBase;
        base->gfxBase       = base->class->mcc_GfxBase;

        initStrings(base);
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
