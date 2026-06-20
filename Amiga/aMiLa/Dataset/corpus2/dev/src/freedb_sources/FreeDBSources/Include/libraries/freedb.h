#ifndef LIBRARIES_FREEDB_H
#define LIBRARIES_FREEDB_H

/*
**  $VER: freedb.h 3.1 (12.12.2001)
**  Includes Release 3.1
**
**  Written by Alfonso Ranieri
**  Released under the GNU Public Licence version 2
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef UTILITY_HOOKS_H
#include <utility/hooks.h>
#endif

#ifndef DEVICES_CD_H
#include <devices/cd.h>
#endif

#ifndef DEVICES_SCSIDISK_H
#include <devices/scsidisk.h>
#endif

/***********************************************************************/

#define FreeDBName      "freedb.library"
#define FreeDBVersion   2

/***********************************************************************/
/* Note
** FREEDBS_XXX FreeDB structure
** FREEDBV_XXX FreeDB value
** FREEDBM_XXX FreeDB macro
*/

/***********************************************************************/
/*
** scsi proto 2 stuff
**/

#define FREEDBV_TOCSIZE     804
#define FREEDBV_MAXTRACKS   100

struct FREEDBS_Track
{
    ULONG   track;
    ULONG   startAddr;
    ULONG   endAddr;
    ULONG   frames;
    ULONG   startMin;
    ULONG   startSec;
    ULONG   startFrame;
    ULONG   endMin;
    ULONG   endSec;
    ULONG   endFrame;
    ULONG   min;
    ULONG   sec;
    ULONG   frame;
    BOOL    ADR;
    BOOL    audio;
    BOOL    copyPerm;
    BOOL    preEmp;
    BOOL    fourChannels;
};

struct FREEDBS_TOC
{
    ULONG               firstTrack;
    ULONG               lastTrack;
    ULONG               startAddress;
    ULONG               endAddress;
    ULONG               frames;
    ULONG               min;
    ULONG               sec;
    ULONG               frame;
    ULONG               discID;
    ULONG               numTracks;
    struct FREEDBS_Track    tracks[FREEDBV_MAXTRACKS];
};

/***********************************************************************/
/*
** FREEDBS_DiscInfo
*/

struct FREEDBS_TrackInfo
{
  char  title[256];
  char  artist[256];
  char  *extd;
  ULONG flags;
};

enum
{
    FREEDBV_TrackInfo_Flags_Artist = 1,
};

struct FREEDBS_DiscInfo
{
    ULONG                   discID;
    char                    discIDString[16];
    ULONG                   flags;
    ULONG                   numTracks;
    char                    *header;
    ULONG                   revision;
    ULONG                   year;
    char                    categ[256];
    char                    genre[256];
    char                    title[256];
    char                    artist[256];
    char                    *extd;
    char                    playOrder[256];
    struct FREEDBS_TrackInfo    *tracks[FREEDBV_MAXTRACKS];
};

enum
{
    FREEDBV_DiscInfo_Flags_NoArtist    = 1,
    FREEDBV_DiscInfo_Flags_MultiArtist = 2,
    FREEDBV_DiscInfo_Flags_HeaderDone  = 512,
};

/***********************************************************************/
/*
** Tags
*/

#define FREEDBLIB_TAG(n) ((int)(0xFEC901F4+(n)))

#define FREEDBA_Base                FREEDBLIB_TAG(0)
#define FREEDBA_Pool                FREEDBLIB_TAG(0)
#define FREEDBA_ErrorPtr            FREEDBLIB_TAG(1)
#define FREEDBA_TOC                 FREEDBLIB_TAG(2)
#define FREEDBA_TOCPtr              FREEDBLIB_TAG(3)
#define FREEDBA_DiscInfo            FREEDBLIB_TAG(4)
#define FREEDBA_Categ               FREEDBLIB_TAG(5)
#define FREEDBA_DiscID              FREEDBLIB_TAG(6)
#define FREEDBA_Device              FREEDBLIB_TAG(7)
#define FREEDBA_Unit                FREEDBLIB_TAG(8)
#define FREEDBA_DeviceName          FREEDBLIB_TAG(9)
#define FREEDBA_Lun                 FREEDBLIB_TAG(10)
#define FREEDBA_Request             FREEDBLIB_TAG(11)
#define FREEDBA_RequestSignal       FREEDBLIB_TAG(12)
#define FREEDBA_OverWrite           FREEDBLIB_TAG(13)
#define FREEDBA_OrigHeader          FREEDBLIB_TAG(14)
#define FREEDBA_UseTOCID            FREEDBLIB_TAG(15)
#define FREEDBA_Command             FREEDBLIB_TAG(16)
#define FREEDBA_Host                FREEDBLIB_TAG(17)
#define FREEDBA_HostPort            FREEDBLIB_TAG(18)
#define FREEDBA_User                FREEDBLIB_TAG(19)
#define FREEDBA_Prg                 FREEDBLIB_TAG(20)
#define FREEDBA_Ver                 FREEDBLIB_TAG(21)
#define FREEDBA_CGI                 FREEDBLIB_TAG(22)
#define FREEDBA_Proxy               FREEDBLIB_TAG(23)
#define FREEDBA_ProxyPort           FREEDBLIB_TAG(24)
#define FREEDBA_UseProxy            FREEDBLIB_TAG(25)
#define FREEDBA_SocketError         FREEDBLIB_TAG(26)
#define FREEDBA_StatusHook          FREEDBLIB_TAG(27)
#define FREEDBA_MultiHook           FREEDBLIB_TAG(28)
#define FREEDBA_SitesHook           FREEDBLIB_TAG(29)
#define FREEDBA_LsCatHook           FREEDBLIB_TAG(30)
#define FREEDBA_Local               FREEDBLIB_TAG(31)
#define FREEDBA_Remote              FREEDBLIB_TAG(32)
#define FREEDBA_Handle              FREEDBLIB_TAG(33)
#define FREEDBA_HandlePtr           FREEDBLIB_TAG(34)
#define FREEDBA_FromM               FREEDBLIB_TAG(35)
#define FREEDBA_FromS               FREEDBLIB_TAG(36)
#define FREEDBA_FromF               FREEDBLIB_TAG(37)
#define FREEDBA_ToM                 FREEDBLIB_TAG(38)
#define FREEDBA_ToS                 FREEDBLIB_TAG(39)
#define FREEDBA_ToF                 FREEDBLIB_TAG(40)
#define FREEDBA_Title               FREEDBLIB_TAG(41)
#define FREEDBA_Titles              FREEDBLIB_TAG(42)
#define FREEDBA_Tracks              FREEDBLIB_TAG(43)
#define FREEDBA_Year                FREEDBLIB_TAG(44)
#define FREEDBA_Genre               FREEDBLIB_TAG(45)
#define FREEDBA_Artist              FREEDBLIB_TAG(46)
#define FREEDBA_Extd                FREEDBLIB_TAG(47)
#define FREEDBA_PlayOrder           FREEDBLIB_TAG(48)
#define FREEDBA_Email               FREEDBLIB_TAG(49)
#define FREEDBA_NoRequester         FREEDBLIB_TAG(50)
#define FREEDBA_BumpRev             FREEDBLIB_TAG(51)
#define FREEDBA_UseSpace            FREEDBLIB_TAG(52)
#define FREEDBA_GetDisc             FREEDBLIB_TAG(53)
#define FREEDBA_ErrorBuffer         FREEDBLIB_TAG(54)
#define FREEDBA_ErrorBufferLen      FREEDBLIB_TAG(55)

/***********************************************************************/
/*
**  FREEDBA_Command
*/

enum
{
    FREEDBV_Command_QueryRead,
    FREEDBV_Command_Query,
    FREEDBV_Command_Read,
    FREEDBV_Command_Sites,
    FREEDBV_Command_LsCat,
    FREEDBV_Command_Submit,
};

/***********************************************************************/
/*
** Hook messages
*/

struct FREEDBS_MultiHookMessage
{
    struct MinNode  link;
    ULONG           size;
    ULONG           code;
    char            categ[256];
    ULONG           discID;
    char            discIDString[16];
    char            artist[256];
    char            title[256];
};

struct FREEDBS_SitesHookMessage
{
    struct MinNode  link;
    ULONG           size;
    char            host[256];
    UWORD           port;
    char            portString[16];
    char            cgi[256];
    char            latitude[256];
    char            longitude[256];
    char            description[256];
};

struct FREEDBS_LsCatHookMessage
{
    struct MinNode  link;
    ULONG           size;
    char            categ[256];
};

/***********************************************************************/
/*
** FREEDBGetDiscA() results
*/

enum
{
    FREEDBV_GetDisc_LocalFound,
    FREEDBV_GetDisc_LocalMulti,
    FREEDBV_GetDisc_Remote,
    FREEDBV_GetDisc_Error,
};

/***********************************************************************/
/*
** FREEDBAllocObject
*/

enum
{
    FREEDBV_AllocObject_TOC,
    FREEDBV_AllocObject_DiscInfo,
    FREEDBV_AllocObject_DiscInfoTOC,
};

#define FREEDBM_GETTOCFROMDI(di) ((struct FREEDBS_TOC *)((ULONG)di+sizeof(struct FREEDBS_DiscInfo)))

/***********************************************************************/
/*
** Congif
**/

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

#define FREEDBV_ReadConfig_Env      (NULL)
#define FREEDBV_ReadConfig_Envarc   ((STRPTR)(-1))
#define FREEDBV_SaveConfig_Env      (NULL)
#define FREEDBV_SaveConfig_Envarc   ((STRPTR)(-1))

/***********************************************************************/
/*
** Errors and strings
**/

enum
{
    FREEDBV_Err_NoMem = 51,
    FREEDBV_Err_NoParms,
    FREEDBV_Err_BadNumber,
    FREEDBV_Err_BadValue,
    FREEDBV_Err_Unknown,
    FREEDBV_Err_NoDevice,
    FREEDBV_Err_NoOpenDevice,
    FREEDBV_Err_NotCD,
    FREEDBV_Err_NoMedium,
    FREEDBV_Err_NoTOC,
    FREEDBV_Err_BadTOC,
    FREEDBV_Err_NoRootDir,
    FREEDBV_Err_NotFound,
    FREEDBV_Err_NoSocketBase,
    FREEDBV_Err_NoSocket,
    FREEDBV_Err_NoHost,
    FREEDBV_Err_NoProxy,
    FREEDBV_Err_CantConnect,
    FREEDBV_Err_Send,
    FREEDBV_Err_Recv,
    FREEDBV_Err_LinkClosed,
    FREEDBV_Err_ServerHTTPError,
    FREEDBV_Err_Aborted,
    FREEDBV_Err_ServerError,
    FREEDBV_Err_Multi,
    FREEDBV_Err_CantSave,
    FREEDBV_Err_FileExists,
    FREEDBV_Err_BadFormat,
    FREEDBV_Err_CantPlay,
    FREEDBV_Err_NoEmail,

    FREEDBV_Handle_Status_Base = 500,
    FREEDBV_Handle_Status_ResolvingHost,
    FREEDBV_Handle_Status_Connecting,
    FREEDBV_Handle_Status_Sending,
    FREEDBV_Handle_Status_Receiving,
    FREEDBV_Handle_Status_Done,
    FREEDBV_Handle_Status_Error,

    FREEDBV_String_Library = 600,
};

/***********************************************************************/

#endif /* LIBRARIES_FREEDB_H */
