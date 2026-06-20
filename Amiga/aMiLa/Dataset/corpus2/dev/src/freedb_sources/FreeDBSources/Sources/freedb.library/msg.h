#ifndef _FREEDBMSG_H
#define _FREEDBMSG_H

/****************************************************************************/

enum
{
    FREEDBV_Err_NoMem = MSG_NO_MEM,
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

    MSG_Cancel = 1000,
    MSG_CantOpen,
    MSG_NoApp,

    MSG_WinTitle,
    MSG_ConfWinTitle,
    MSG_Description,

    MSG_Project,
    MSG_About,
    MSG_AboutMUI,
    MSG_Hide,
    MSG_Quit,

    MSG_FreeDB,
    MSG_Get,
    MSG_GetLocal,
    MSG_GetRemote,

    MSG_Editor,
    MSG_FreeDBConfig,
    MSG_MUI,

    MSG_Config,
    MSG_Restore,
    MSG_Last,
    MSG_GetSites,
};

/****************************************************************************/

#define CATNAME "freedb.library.catalog"

/****************************************************************************/

#endif /* _FREEDBMSG_H */

