/****************************************************************
   This file was created automatically by `FlexCat 1.5'
   from "AmiFTP.cd".

   Do NOT edit by hand!
****************************************************************/

#if defined(__SASC)  ||  defined(_DCC)
#include <proto/locale.h>
#elif defined(__GNUC__)
#include <inline/locale.h>
#else
#include <clib/locale_protos.h>
#endif




static LONG AmiFTP_Version = 2;
static const STRPTR AmiFTP_BuiltInLanguage = (STRPTR) "english";

struct FC_Type
{   LONG   ID;
    STRPTR Str;
};


const struct FC_Type _SLW_SiteListWindow = { 0, "AmiFTP Sitelist" };
const struct FC_Type _SLW_SiteList = { 1, "FTP Sites" };
const struct FC_Type _SLW_Connect = { 2, "_Connect" };
const struct FC_Type _SLW_New = { 3, "_New site" };
const struct FC_Type _SLW_Edit = { 4, "_Edit" };
const struct FC_Type _SLW_Remove = { 5, "_Remove" };
const struct FC_Type _SLW_Cancel = { 6, "C_ancel" };
const struct FC_Type _SLW_OK = { 7, "_OK" };
const struct FC_Type _SLW_Up = { 8, "Up" };
const struct FC_Type _SLW_Down = { 9, "Down" };
const struct FC_Type _SLW_Top = { 10, "Top" };
const struct FC_Type _SLW_Bottom = { 11, "Bottom" };
const struct FC_Type _SLW_Newstring = { 12, "(New)" };
const struct FC_Type _SLW_Sort = { 13, "_Sort" };
const struct FC_Type _SCW_SiteConfigurationWindow = { 14, "AmiFTP Site Configuration" };
const struct FC_Type _SCW_Name = { 15, "Na_me" };
const struct FC_Type _SCW_Site = { 16, "_Site" };
const struct FC_Type _SCW_Port = { 17, "_Port" };
const struct FC_Type _SCW_RemDir = { 18, "_Auto-cd to drawer" };
const struct FC_Type _SCW_LocDir = { 19, "_Download path" };
const struct FC_Type _SCW_Anonymous = { 20, "Anonymous lo_gin" };
const struct FC_Type _SCW_LoginName = { 21, "_Login name" };
const struct FC_Type _SCW_Password = { 22, "Pass_word" };
const struct FC_Type _SCW_OK = { 23, "_OK" };
const struct FC_Type _SCW_Cancel = { 24, "Ca_ncel" };
const struct FC_Type _SCW_OS = { 25, "Operating S_ystem" };
const struct FC_Type _SCW_Proxy = { 26, "Pro_xy" };
const struct FC_Type _SCW_HotList = { 27, "_HotList" };
const struct FC_Type _TW_WinTitle = { 28, "AmiFTP - %ld file(s) left (%ld %s)" };
const struct FC_Type _TW_RemoteFile = { 29, "Remote file" };
const struct FC_Type _TW_LocalFile = { 30, "Local file" };
const struct FC_Type _TW_Size = { 31, "Size" };
const struct FC_Type _TW_Cps = { 32, "CPS" };
const struct FC_Type _TW_DataTransferred = { 33, "Data transferred" };
const struct FC_Type _TW_Abort = { 34, "Abort transfer" };
const struct FC_Type _TW_FileExists = { 35, "File '%s' already exists.\nOld filesize is: %ld bytes (new %ld bytes).\n" };
const struct FC_Type _TW_Overwrite = { 36, "Overwrite" };
const struct FC_Type _TW_Resume = { 37, "Resume transfer" };
const struct FC_Type _TW_CancelTransfer = { 38, "Cancel transfer" };
const struct FC_Type _TW_DownloadDir = { 39, "You are about to download a directory tree.\nAre you sure you want to do this?" };
const struct FC_Type _TW_GetDir = { 40, "Yes, download it!|Skip this entry" };
const struct FC_Type _MPW_WinTitle = { 41, "AmiFTP Global Preferences" };
const struct FC_Type _MPW_Password = { 42, "_Anonymous password" };
const struct FC_Type _MPW_ViewCommand = { 43, "_View command" };
const struct FC_Type _MPW_ProxyHost = { 44, "Proxy _host" };
const struct FC_Type _MPW_ProxyPort = { 45, "Proxy _port" };
const struct FC_Type _MPW_ProxyDefault = { 46, "Use pro_xy per default" };
const struct FC_Type _MPW_DefDownloadDir = { 47, "Default local drawer" };
const struct FC_Type _MPW_IgnoreCase = { 48, "_Ignore case" };
const struct FC_Type _MW_SiteName = { 49, "_Site" };
const struct FC_Type _MW_DirName = { 50, "Drawer" };
const struct FC_Type _MW_DownloadDir = { 51, "L_ocal drawer" };
const struct FC_Type _MW_Parent = { 52, "_Parent" };
const struct FC_Type _MW_Get = { 53, "_Get" };
const struct FC_Type _MW_Put = { 54, "P_ut" };
const struct FC_Type _MW_View = { 55, "_View" };
const struct FC_Type _MW_Connect = { 56, "_Connect to..." };
const struct FC_Type _MW_Disconnect = { 57, "_Disconnect" };
const struct FC_Type _MW_DeleteRequest = { 58, "Are you sure you want to\ndelete these files?" };
const struct FC_Type _MW_DeleteCancel = { 59, "Delete|Cancel" };
const struct FC_Type _MW_Reload = { 60, "_Reload" };
const struct FC_Type _CW_WinTitle = { 61, "AmiFTP Connect window" };
const struct FC_Type _CW_Abort = { 62, "Abort" };
const struct FC_Type _CW_Site = { 63, "Site:" };
const struct FC_Type _CW_Status = { 64, "Status:" };
const struct FC_Type _CW_Connecting = { 65, "Connecting..." };
const struct FC_Type _CW_ReadingDir = { 66, "Reading drawer..." };
const struct FC_Type _CW_SendingLogin = { 67, "Sending login..." };
const struct FC_Type _CW_SendingPassword = { 68, "Sending password..." };
const struct FC_Type _CW_ChangingDirectory = { 69, "Changing drawer..." };
const struct FC_Type _MENU_Project = { 70, "Project" };
const struct FC_Type _MENU_AddToSiteList = { 71, "Add current to sitelist" };
const struct FC_Type _MENU_Reconnect = { 72, "Reconnect" };
const struct FC_Type _MENU_Iconify = { 73, "I\000Iconify" };
const struct FC_Type _MENU_About = { 74, "?\000About..." };
const struct FC_Type _MENU_Quit = { 75, "Q\000Quit" };
const struct FC_Type _MENU_Files = { 76, "Files" };
const struct FC_Type _MENU_TagAll = { 77, "A\000Tag all" };
const struct FC_Type _MENU_UntagAll = { 78, "U\000Untag all" };
const struct FC_Type _MENU_TransferMode = { 79, "Transfer mode" };
const struct FC_Type _MENU_Binary = { 80, "Binary" };
const struct FC_Type _MENU_ASCII = { 81, "ASCII" };
const struct FC_Type _MENU_ClearCache = { 82, "Clear dir-cache" };
const struct FC_Type _MENU_Delete = { 83, "D\000Delete" };
const struct FC_Type _MENU_Move = { 84, "M\000Move" };
const struct FC_Type _MENU_Sort = { 85, "Sort" };
const struct FC_Type _MENU_SortbyName = { 86, "by name" };
const struct FC_Type _MENU_SortbyDate = { 87, "by date" };
const struct FC_Type _MENU_Settings = { 88, "Settings" };
const struct FC_Type _MENU_Global = { 89, "1\000Global..." };
const struct FC_Type _MENU_Hostlist = { 90, "2\000Sitelist..." };
const struct FC_Type _MENU_LogWindow = { 91, "Log window" };
const struct FC_Type _MENU_ToggleDotFiles = { 92, "Show dot-files" };
const struct FC_Type _MENU_LoadSettings = { 93, "Load settings..." };
const struct FC_Type _MENU_SaveSettings = { 94, "Save settings" };
const struct FC_Type _MENU_SaveSettingsAs = { 95, "Save settings as..." };
const struct FC_Type _MENU_HotList = { 96, "Hotlist" };
const struct FC_Type _Str_ErrorReadingDir = { 97, "Error reading drawer!\n" };
const struct FC_Type _Str_CannotDLDirs = { 98, "Cannot download entire directories!\n" };
const struct FC_Type _Str_SelectDLPath = { 99, "Select download path" };
const struct FC_Type _Str_SelectULFiles = { 100, "Select file(s) to upload" };
const struct FC_Type _Str_CDFailedTimedout = { 101, "Remote CD failed:\nConnection timed out" };
const struct FC_Type _Str_CDFailed = { 102, "Remote CD failed." };
const struct FC_Type _Str_AmiFTPError = { 103, "AmiFTP error" };
const struct FC_Type _Str_OK = { 104, "OK" };
const struct FC_Type _Str_CANCEL = { 105, "Cancel" };
const struct FC_Type _Str_PasswordRequest = { 106, "AmiFTP Password request" };
const struct FC_Type _Str_PasswordEntry = { 107, "Enter password for user:\n%s" };
const struct FC_Type _Str_ServiceNotAvail = { 108, "Service not available." };
const struct FC_Type _Str_ConnectFailed = { 109, "Connect failed." };
const struct FC_Type _Str_ConnectLoginFailed = { 110, "Connect failed, login unknown." };
const struct FC_Type _Str_Putfailed = { 111, "Put of %s failed" };
const struct FC_Type _Str_RemoteWriteFailed = { 112, "Write failed (remote file system full?)." };
const struct FC_Type _Str_GetFailed = { 113, "Get %s failed." };
const struct FC_Type _Str_LocalfileError = { 114, "Error opening %s." };
const struct FC_Type _Str_LocalWriteFailed = { 115, "Write failed: %s" };
const struct FC_Type _Str_NoSuchDir = { 116, "%s: No such file or directory." };
const struct FC_Type _Str_DisconnectedTimeout = { 117, "Disconnected (timeout)." };
const struct FC_Type _Str_Outofmem = { 118, "Out of memory" };
const struct FC_Type _Str_SelectSettingsFile = { 119, "Select settings file..." };
const struct FC_Type _Str_NoRestart = { 120, "Resume command failed." };
const struct FC_Type _Str_ConnectionTimedOut = { 121, "Connection timed out" };
const struct FC_Type _Str_AmiFTPRequest = { 122, "AmiFTP Request" };
const struct FC_Type _Str_AboutAmiFTP = { 123, "About AmiFTP..." };
const struct FC_Type _Str_UnknownHost = { 124, "Unknown host" };
const struct FC_Type _Str_ErrorBuildingDirList = { 125, "Error building filelist." };
const struct FC_Type _Str_Translator = { 126, "" };
const struct FC_Type _SLW_NewGroup = { 127, "New _group" };
const struct FC_Type _SLW_AddBar = { 128, "Add bar" };
const struct FC_Type _MENU_ToggleADTFiles = { 129, "Show entire RECENT" };
const struct FC_Type _MENU_ResetADT = { 130, "Reset Aminet-date" };
const struct FC_Type _MW_ViewReadme = { 131, "View readme" };
const struct FC_Type _MPW_General = { 132, "General" };
const struct FC_Type _MPW_ADT = { 133, "Aminet" };
const struct FC_Type _MPW_Proxy = { 134, "Proxy" };
const struct FC_Type _MPW_BufferSize = { 135, "Buffer size" };
const struct FC_Type _MPW_DirCacheSize = { 136, "Directory cache size" };
const struct FC_Type _MPW_DeleteViewed = { 137, "Delete viewed files" };
const struct FC_Type _MPW_Beep = { 138, "Beep after transfer" };
const struct FC_Type _MPW_HideDirectories = { 139, "Hide drawers" };
const struct FC_Type _MPW_PreservePath = { 140, "Preserve filepath" };
const struct FC_Type _MPW_ShowMOTD = { 141, "Show MOTD-file" };
const struct FC_Type _MPW_GetReadme = { 142, "Download readme" };
const struct FC_Type _SCW_AminetMode = { 143, "Aminet-mode" };
const struct FC_Type _MPW_OK = { 144, "_OK" };
const struct FC_Type _MPW_Cancel = { 145, "C_ancel" };
const struct FC_Type _TW_TimeLeft = { 146, "Time left" };
const struct FC_Type _Str_NoNewAminetFiles = { 147, "No new files since last Aminet visit" };
const struct FC_Type _Str_WindowTitle = { 148, "AmiFTP - %ld files selected (%ld %s) %ld %s free on disk" };
const struct FC_Type _MENU_Connect = { 149, "C\000Connect..." };
const struct FC_Type _MENU_Disconnect = { 150, "Disconnect" };
const struct FC_Type _MENU_Get = { 151, "G\000Get" };
const struct FC_Type _MENU_Put = { 152, "U\000Put" };
const struct FC_Type _MENU_View = { 153, "V\000View" };
const struct FC_Type _MENU_PatternSelect = { 154, "Select by pattern..." };
const struct FC_Type _MPW_Display = { 155, "Display" };
const struct FC_Type _Str_PatternRequest = { 156, "AmiFTP request" };
const struct FC_Type _Str_SelectPattern = { 157, "Enter AmigaDOS pattern:" };
const struct FC_Type _MENU_Parent = { 158, "P\000Parent" };
const struct FC_Type _MPW_PublicScreen = { 159, "Public screen" };
const struct FC_Type _MPW_SystemFonts = { 160, "Use system fonts" };
const struct FC_Type _MPW_InterfaceFont = { 161, "Interface font" };
const struct FC_Type _MPW_FilelistFont = { 162, "Filelist font" };
const struct FC_Type _MPW_ShowButtons = { 163, "Show buttons" };
const struct FC_Type _MPW_ShowToolbar = { 164, "Show toolbar" };
const struct FC_Type _MENU_ViewReadme = { 165, "View readme" };
const struct FC_Type _MPW_DefaultScreen = { 166, "Open on default public screen" };
const struct FC_Type _TW_OverwriteAll = { 167, "Overwrite all" };
const struct FC_Type _MENU_CreateDir = { 168, "Create directory" };
const struct FC_Type _Str_RemoteDir = { 169, "Enter name of directory" };
const struct FC_Type _MENU_RawCommand = { 170, "Send FTP command" };
const struct FC_Type _MENU_Rename = { 171, "Rename" };


static struct Catalog *AmiFTP_Catalog = NULL;

void OpenAmiFTPCatalog(struct Locale *loc, STRPTR language)
{ LONG tag, tagarg;
  extern struct Library *LocaleBase;
  extern void CloseAmiFTPCatalog(void);

  CloseAmiFTPCatalog(); /* Not needed if the programmer pairs OpenAmiFTPCatalog
		       and CloseAmiFTPCatalog right, but does no harm.  */

  if (LocaleBase != NULL  &&  AmiFTP_Catalog == NULL)
  { if (language == NULL)
    { tag = TAG_IGNORE;
    }
    else
    { tag = OC_Language;
      tagarg = (LONG) language;
    }
    AmiFTP_Catalog = OpenCatalog(loc, (STRPTR) "AmiFTP.catalog",
				OC_BuiltInLanguage, AmiFTP_BuiltInLanguage,
				tag, tagarg,
				OC_Version, AmiFTP_Version,
				TAG_DONE);
  }
}

void CloseAmiFTPCatalog(void)
{ if (LocaleBase != NULL)
  { CloseCatalog(AmiFTP_Catalog);
  }
  AmiFTP_Catalog = NULL;
}

STRPTR GetAmiFTPString(APTR fcstr)
{ STRPTR defaultstr;
  LONG strnum;

  strnum = ((struct FC_Type *) fcstr)->ID;
  defaultstr = ((struct FC_Type *) fcstr)->Str;

  return(AmiFTP_Catalog ? GetCatalogStr(AmiFTP_Catalog, strnum, defaultstr) :
		      defaultstr);
}
