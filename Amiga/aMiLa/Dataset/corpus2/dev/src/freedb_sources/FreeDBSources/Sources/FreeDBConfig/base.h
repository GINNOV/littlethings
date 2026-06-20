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

#include "FreeDBConfig.mcc_rev.h"

/***************************************************************************/

struct libBase
{
    struct Library          libNode;
    ULONG                   segList;
    struct ExecBase         *sysBase;
    struct DosLibrary       *dosBase;
    struct Library          *utilityBase;
    struct IntuitionBase    *intuitionBase;
    struct Library          *localeBase;
    struct Library          *muiMasterBase;
    struct Library          *gfxBase;
    struct Library          *freeDBBase;
    struct SignalSemaphore  libSem;
    struct Catalog          *cat;
    struct MUI_CustomClass  *sitesListClass;
    struct MUI_CustomClass  *class;
    ULONG                   flags;
};

#define BASEFLG_INIT 0x00000001

/***************************************************************************/

BOOL ASM initBase(REG(a0) struct libBase *base);
void ASM freeBase(REG(a0) struct libBase *base);

/****************************************************************************/

#endif /* _BASE_H */

