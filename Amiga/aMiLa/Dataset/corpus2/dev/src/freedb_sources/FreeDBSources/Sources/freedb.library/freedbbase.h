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

#include "freedb.library_rev.h"

/***************************************************************************/

struct FREEDBS_Site
{
    struct MinNode  link;
    char            host[128];
    UWORD           port;
    char            portString[16];
    char            cgi[128];
    char            latitude[16];
    char            longitude[16];
    char            description[64];
    ULONG           flags;
};

enum
{
    FREEDBV_Site_Flags_Active = 1,
};

struct FREEDBS_Config
{
    struct MinList      sites;
    struct FREEDBS_Site *defaultSite;
    struct FREEDBS_Site *activeSite;
    char                proxy[128];
    UWORD               proxyPort;
    char                proxyPortString[16];
    BOOL                useProxy;
    char                rootDir[256];
    char                user[64];
    char                email[256];
    ULONG               flags;
};

enum
{
    FREEDBV_Config_Flags_NoUser = 1,
};


#define DEFAULT_USER        "ILoveNewYork"
#define DEFAULT_ROOTDIR     "FREEDB:"
#define DEFAULT_PORT        80
#define DEFAULT_CGI         "/~cddb/cddb.cgi"
#define DEFAULT_PROXYPORT   8080

extern struct FREEDBS_Config opts;

/***********************************************************************/

struct rexxLibBase
{
    struct Library          libNode;
    ULONG                   segList;
    struct ExecBase         *sysBase;
    struct RxsLib           *rexxSysBase;
    struct DosLibrary       *dosBase;
    struct Library          *utilityBase;
    struct IntuitionBase    *intuitionBase;
    struct Library          *localeBase;
    struct Library          *muiMasterBase;
    struct SignalSemaphore  libSem;
    struct SignalSemaphore  memSem;
    APTR                    pool;
    struct MinList          messages;
    ULONG                   freeMessages;
    struct MUI_CustomClass  *appClass;
    struct FREEDBS_Config   *opts;
    struct Catalog          *cat;
    ULONG                   flags;
    ULONG                   use;
    struct Library          *iconBase;
};

/***************************************************************************/

#define BASEFLG_INIT        0x00000001
#define BASEFLG_INITMUI     0x00000002

/***************************************************************************/

#define FREEDBV_ReadConfig_Env      (NULL)
#define FREEDBV_ReadConfig_Envarc   ((STRPTR)(-1))
#define FREEDBV_SaveConfig_Env      (NULL)
#define FREEDBV_SaveConfig_Envarc   ((STRPTR)(-1))

#define FREEDBV_Config              "FreeDB/FreeDB"
#define FREEDBV_Config_Env          "ENV:" FREEDBV_Config
#define FREEDBV_Config_Envarc       "ENVARC:" FREEDBV_Config

/***********************************************************************/

#endif /* _BASE_H */
