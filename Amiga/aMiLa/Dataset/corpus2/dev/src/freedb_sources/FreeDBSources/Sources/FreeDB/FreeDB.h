
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/icon.h>
#include <proto/freedb.h>
#include <workbench/startup.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "macros.h"
#include "FreeDB_rev.h"

/***********************************************************************/

#define DEF_DEVICENAME  "CD0"
#define DEF_UNIT        0
#define DEF_LUN         0

/***********************************************************************/


struct global
{
    struct ExecBase         *sysBase;
    struct DosLibrary       *dOSBase;
    struct IntuitionBase    *intuitionBase;
    struct Process          *this;
    struct WBStartup        *wbs;

    char                    device[256];
    UWORD                   unit;
    UBYTE                   lun;
    Tag                     dtag;

    ULONG                   flags;
};

enum
{
    GFLG_NTUSESPACE = 1,
};

/***********************************************************************/

#ifdef LGLOBAL
#define SysBase         g.sysBase
#define DOSBase         g.dOSBase
#define IntuitionBase   g.intuitionBase
#else
#define SysBase         g->sysBase
#define DOSBase         g->dOSBase
#define IntuitionBase   g->intuitionBase
#endif

/***********************************************************************/

/* parsearg.c */
LONG ASM parseArg ( REG (a0 )struct global *g );

/* request.c */
void request ( struct global *g , char *format , ...);

/***********************************************************************/
