
#include "freedb.h"

/****************************************************************************/

#define FREEDBV_Err_NoMem_String                    "Too few memory"
#define FREEDBV_Err_NoParms_String                  "Required argument missed"
#define FREEDBV_Err_BadNumber_String                "Bad number"
#define FREEDBV_Err_BadValue_String                 "Bad value"
#define FREEDBV_Err_Unknown_String                  "Unknown FreeDB error %ld"
#define FREEDBV_Err_NoDevice_String                 "Device not found"
#define FREEDBV_Err_NoOpenDevice_String             "Device not opened"
#define FREEDBV_Err_NotCD_String                    "Not a CDROM device"
#define FREEDBV_Err_NoMedium_String                 "Medium not present"
#define FREEDBV_Err_NoTOC_String                    "TOC not read"
#define FREEDBV_Err_BadTOC_String                   "Bad TOC format"
#define FREEDBV_Err_NoRootDir_String                "Root drawer not found"
#define FREEDBV_Err_NotFound_String                 "Disc not found"
#define FREEDBV_Err_NoSocketBase_String             "No TCP/IP stack running"
#define FREEDBV_Err_NoSocket_String                 "Socket not created"
#define FREEDBV_Err_NoHost_String                   "Host not found"
#define FREEDBV_Err_NoProxy_String                  "Proxy not found"
#define FREEDBV_Err_CantConnect_String              "Can't connect"
#define FREEDBV_Err_Send_String                     "Error sending"
#define FREEDBV_Err_Recv_String                     "Error receiving"
#define FREEDBV_Err_LinkClosed_String               "Link closed"
#define FREEDBV_Err_ServerHTTPError_String          "Invalid HTTP protocol answer"
#define FREEDBV_Err_Aborted_String                  "Aborted"
#define FREEDBV_Err_ServerError_String              "Server error"
#define FREEDBV_Err_Multi_String                    "Multi matches"
#define FREEDBV_Err_CantSave_String                 "File not saved"
#define FREEDBV_Err_FileExists_String               "File already exists"
#define FREEDBV_Err_BadFormat_String                "Invalid format"
#define FREEDBV_Err_CantPlay_String                 "Can't play"
#define FREEDBV_Err_NoEmail_String                  "Missed or invalid email address"

#define FREEDBV_Handle_Status_ResolvingHost_String  "Resolving host..."
#define FREEDBV_Handle_Status_Connecting_String     "Connecting..."
#define FREEDBV_Handle_Status_Sending_String        "Sending request..."
#define FREEDBV_Handle_Status_Receiving_String      "Receiving results..."
#define FREEDBV_Handle_Status_Error_String          "Error"
#define FREEDBV_Handle_Status_Done_String           "Done"

#define FREEDBV_String_Library_String               VERS " ("DATE")"

#define MSG_Cancel_String                           "Cancel"
#define MSG_CantOpen_String                         "Can't open %s ver %ld or higher"
#define MSG_NoApp_String                            "Can't create Application"

#define MSG_WinTitle_String                         "FreeDB"
#define MSG_ConfWinTitle_String                     "FreeDB configuration"
#define MSG_Description_String                      "Manage CD-ROM via freedb"

#define MSG_Project_String                          "Project"
#define MSG_About_String                            "?\0About..."
#define MSG_AboutMUI_String                         "About MUI..."
#define MSG_Hide_String                             "H\0Hide"
#define MSG_Quit_String                             "Q\0Quit"

#define MSG_FreeDB_String                           "FreeDB"
#define MSG_Get_String                              "G\0Get"
#define MSG_GetLocal_String                         "A\0Get local"
#define MSG_GetRemote_String                        "E\0Get remote"

#define MSG_Editor_String                           "Editor"
#define MSG_FreeDBConfig_String                     "C\0Config..."
#define MSG_MUI_String                              "M\0MUI..."

#define MSG_Config_String                           "Config"
#define MSG_Restore_String                          "R\0Restore"
#define MSG_Last_String                             "L\0Last saveds"
#define MSG_GetSites_String                         "S\0Get sites"

/****************************************************************************/

struct message
{
    LONG   id;
    STRPTR string;
};

/****************************************************************************/

struct message strings[] =
{
    FREEDBV_Err_NoMem,                          FREEDBV_Err_NoMem_String,
    FREEDBV_Err_NoParms,                        FREEDBV_Err_NoParms_String,
    FREEDBV_Err_BadNumber,                      FREEDBV_Err_BadNumber_String,
    FREEDBV_Err_BadValue,                       FREEDBV_Err_BadValue_String,
    FREEDBV_Err_Unknown,                        FREEDBV_Err_Unknown_String,
    FREEDBV_Err_NoDevice,                       FREEDBV_Err_NoDevice_String,
    FREEDBV_Err_NoOpenDevice,                   FREEDBV_Err_NoOpenDevice_String,
    FREEDBV_Err_NotCD,                          FREEDBV_Err_NotCD_String,
    FREEDBV_Err_NoMedium,                       FREEDBV_Err_NoMedium_String,
    FREEDBV_Err_NoTOC,                          FREEDBV_Err_NoTOC_String,
    FREEDBV_Err_BadTOC,                         FREEDBV_Err_BadTOC_String,
    FREEDBV_Err_NoRootDir,                      FREEDBV_Err_NoRootDir_String,
    FREEDBV_Err_NotFound,                       FREEDBV_Err_NotFound_String,
    FREEDBV_Err_NoSocketBase,                   FREEDBV_Err_NoSocketBase_String,
    FREEDBV_Err_NoSocket,                       FREEDBV_Err_NoSocket_String,
    FREEDBV_Err_NoHost,                         FREEDBV_Err_NoHost_String,
    FREEDBV_Err_NoProxy,                        FREEDBV_Err_NoProxy_String,
    FREEDBV_Err_CantConnect,                    FREEDBV_Err_CantConnect_String,
    FREEDBV_Err_Send,                           FREEDBV_Err_Send_String,
    FREEDBV_Err_Recv,                           FREEDBV_Err_Recv_String,
    FREEDBV_Err_LinkClosed,                     FREEDBV_Err_LinkClosed_String,
    FREEDBV_Err_ServerHTTPError,                FREEDBV_Err_ServerHTTPError_String,
    FREEDBV_Err_Aborted,                        FREEDBV_Err_Aborted_String,
    FREEDBV_Err_ServerError,                    FREEDBV_Err_ServerError_String,
    FREEDBV_Err_Multi,                          FREEDBV_Err_Multi_String,
    FREEDBV_Err_CantSave,                       FREEDBV_Err_CantSave_String,
    FREEDBV_Err_FileExists,                     FREEDBV_Err_FileExists_String,
    FREEDBV_Err_BadFormat,                      FREEDBV_Err_BadFormat_String,
    FREEDBV_Err_CantPlay,                       FREEDBV_Err_CantPlay_String,
    FREEDBV_Err_NoEmail,                        FREEDBV_Err_NoEmail_String,

    FREEDBV_Handle_Status_ResolvingHost,        FREEDBV_Handle_Status_ResolvingHost_String,
    FREEDBV_Handle_Status_Connecting,           FREEDBV_Handle_Status_Connecting_String,
    FREEDBV_Handle_Status_Sending,              FREEDBV_Handle_Status_Sending_String,
    FREEDBV_Handle_Status_Receiving,            FREEDBV_Handle_Status_Receiving_String,
    FREEDBV_Handle_Status_Done,                 FREEDBV_Handle_Status_Done_String,
    FREEDBV_Handle_Status_Error,                FREEDBV_Handle_Status_Error_String,

    FREEDBV_String_Library,                     FREEDBV_String_Library_String,

    MSG_Cancel,                                 MSG_Cancel_String,
    MSG_CantOpen,                               MSG_CantOpen_String,
    MSG_NoApp,                                  MSG_NoApp_String,

    MSG_WinTitle,                               MSG_WinTitle_String,
    MSG_ConfWinTitle,                           MSG_ConfWinTitle_String,
    MSG_Description,                            MSG_Description_String,

    MSG_Project,                                MSG_Project_String,
    MSG_About,                                  MSG_About_String,
    MSG_AboutMUI,                               MSG_AboutMUI_String,
    MSG_Hide,                                   MSG_Hide_String,
    MSG_Quit,                                   MSG_Quit_String,

    MSG_FreeDB,                                 MSG_FreeDB_String,
    MSG_Get,                                    MSG_Get_String,
    MSG_GetLocal,                               MSG_GetLocal_String,
    MSG_GetRemote,                              MSG_GetRemote_String,

    MSG_Editor,                                 MSG_Editor_String,
    MSG_FreeDBConfig,                           MSG_FreeDBConfig_String,
    MSG_MUI,                                    MSG_MUI_String,

    MSG_Config,                                 MSG_Config_String,
    MSG_Restore,                                MSG_Restore_String,
    MSG_Last,                                   MSG_Last_String,
    MSG_GetSites,                               MSG_GetSites_String,

    NULL
};

/****************************************************************************/

STRPTR SAVEDS ASM
FreeDBGetString(REG(d0) ULONG id)
{
    register struct message *array;
    register STRPTR         string;

    for (array = strings; array->string && (array->id!=id); array++);

    string = array->string;

    return (rexxLibBase->localeBase && rexxLibBase->cat) ?
        GetCatalogStr(rexxLibBase->cat,id,string) : string;
}

/***********************************************************************/
