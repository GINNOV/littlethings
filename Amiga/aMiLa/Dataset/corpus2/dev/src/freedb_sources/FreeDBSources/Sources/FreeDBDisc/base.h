#ifndef _BASE_H
#define _BASE_H

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef EXEC_SEMAPHORES_H
#include <exec/semaphores.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef _MACROS_H
#include "macros.h"
#endif

#include "FreeDBDisc.mcc_rev.h"

/***************************************************************************/

struct libBase
{
    struct Library          libNode;
    ULONG                   segList;
    struct ExecBase         *sysBase;
    struct DosLibrary       *dosBase;
    struct Library          *utilityBase;
    struct IntuitionBase    *intuitionBase;
    struct Library          *gfxBase;
    struct Library          *localeBase;
    struct Library          *muiMasterBase;
    struct Library          *dataTypesBase;
    struct Library          *freeDBBase;
    struct SignalSemaphore  libSem;
    struct Catalog          *cat;
    struct MUI_CustomClass  *mcc;
    struct MUI_CustomClass  *mcp;
    struct MUI_CustomClass  *bar;
    struct MUI_CustomClass  *discInfo;
    struct MUI_CustomClass  *multiMatches;
    struct MUI_CustomClass  *edit;
    struct MUI_CustomClass  *titlesList;
    struct MUI_CustomClass  *multiMatchesList;
    ULONG                   flags;
};

#define BASEFLG_INIT    0x00000001

/***************************************************************************/

BOOL ASM initBase(REG(a0) struct libBase *base);
void ASM freeBase(REG(a0) struct libBase *base);

/****************************************************************************/

#endif /* _BASE_H */
