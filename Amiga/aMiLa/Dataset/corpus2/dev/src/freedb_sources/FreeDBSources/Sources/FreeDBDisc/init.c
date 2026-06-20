
#include "class.h"

/***********************************************************************/

ULONG SAVEDS ASM
query(REG(d0) LONG which)
{
    switch (which)
    {
        case 0:
            return (ULONG)libBase->mcc;

        case 1:
            ObtainSemaphore(&libBase->libSem);
            if (!libBase->mcp) initMCPClass();
            ReleaseSemaphore(&libBase->libSem);
            return (ULONG)libBase->mcp;

        default:
            return 0;
    }
}

/****************************************************************************/

void ASM
freeBase(REG(a0) struct libBase *base)
{
    if (base->muiMasterBase)
    {
        if (base->bar)
        {
            MUI_DeleteCustomClass(base->bar);
            base->bar = NULL;
        }

        if (base->titlesList)
        {
            MUI_DeleteCustomClass(base->titlesList);
            base->titlesList = NULL;
        }

        if (base->edit)
        {
            MUI_DeleteCustomClass(base->edit);
            base->edit = NULL;
        }

        if (base->multiMatchesList)
        {
            MUI_DeleteCustomClass(base->multiMatchesList);
            base->multiMatchesList = NULL;
        }

        if (base->discInfo)
        {
            MUI_DeleteCustomClass(base->discInfo);
            base->discInfo = NULL;
        }

        if (base->mcc)
        {
            MUI_DeleteCustomClass(base->mcc);
            base->mcc = NULL;
        }

        if (base->mcp)
        {
            MUI_DeleteCustomClass(base->mcp);
            base->mcp = NULL;
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

    if (base->freeDBBase)
    {
        CloseLibrary(base->freeDBBase);
        base->freeDBBase = NULL;
    }

    if (base->dataTypesBase)
    {
        CloseLibrary(base->dataTypesBase);
        base->dataTypesBase = NULL;
    }

    base->flags &= ~BASEFLG_INIT;
}

/***********************************************************************/

BOOL ASM
initBase(REG(a0) struct libBase *base)
{
    if ((base->muiMasterBase = OpenLibrary("muimaster.library",19)) &&
        (base->dataTypesBase = OpenLibrary("datatypes.library",37)) &&
        (base->freeDBBase = OpenLibrary("freedb.library",1)) &&
        initBarClass(base) &&
        initTitlesListClass(base) &&
        initEditClass(base) &&
        initMultiMatchesListClass(base) &&
        initDiscInfoClass(base) &&
        initMCCClass(base))
    {
        base->dosBase       = (APTR)base->mcc->mcc_DOSBase;
        base->utilityBase   = base->mcc->mcc_UtilityBase;
        base->intuitionBase = (APTR)base->mcc->mcc_IntuitionBase;
        base->gfxBase       = base->mcc->mcc_GfxBase;

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
