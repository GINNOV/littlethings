head	1.803;
access;
symbols;
locks
	lilja:1.803; strict;
comment	@ * @;


1.803
date	96.11.30.21.14.49;	author lilja;	state Exp;
branches;
next	1.795;

1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.720;

1.720
date	96.07.27.23.43.40;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.630;

1.630
date	96.07.07.20.10.48;	author lilja;	state Exp;
branches;
next	1.608;

1.608
date	96.07.01.20.14.54;	author lilja;	state Exp;
branches;
next	1.585;

1.585
date	96.06.13.00.03.21;	author lilja;	state Exp;
branches;
next	1.539;

1.539
date	96.06.01.14.40.45;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	1.265;

1.265
date	96.03.08.18.01.38;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.857;

0.857
date	95.10.24.18.41.14;	author lilja;	state Exp;
branches;
next	0.827;

0.827
date	95.10.23.21.01.35;	author lilja;	state Exp;
branches;
next	0.685;

0.685
date	95.09.22.20.13.06;	author lilja;	state Exp;
branches;
next	0.623;

0.623
date	95.09.16.10.54.30;	author lilja;	state Exp;
branches;
next	0.563;

0.563
date	95.09.10.20.59.20;	author lilja;	state Exp;
branches;
next	0.541;

0.541
date	95.09.06.12.36.41;	author lilja;	state Exp;
branches;
next	0.534;

0.534
date	95.09.03.18.34.27;	author lilja;	state Exp;
branches;
next	0.531;

0.531
date	95.09.01.17.25.42;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.425;

0.425
date	95.07.24.18.19.29;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	;


desc
@File created by FlexCat
@


1.803
log
@Added 'Overwrite all'-option.
@
text
@/****************************************************************
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
@


1.795
log
@Stuff.
@
text
@d195 1
@


1.720
log
@Select by pattern added.
DLPath()-function added to save some bytes (200 :).
@
text
@d56 1
a56 1
const struct FC_Type _TW_WinTitle = { 28, "AmiFTP Transfer window" };
d77 1
a77 1
const struct FC_Type _MW_SiteName = { 49, "Current _site:" };
d180 1
a180 1
const struct FC_Type _MENU_Put = { 152, "P\000Put" };
d186 9
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d183 3
@


1.630
log
@Added items in the menu to duplicate the buttons.
@
text
@d182 1
@


1.608
log
@Removed some question-marks.
@
text
@d46 1
a46 1
const struct FC_Type _SCW_RemDir = { 18, "_Auto-cd to directory" };
d75 1
a75 1
const struct FC_Type _MPW_DefDownloadDir = { 47, "Default download directory" };
d78 2
a79 2
const struct FC_Type _MW_DirName = { 50, "D_irectory" };
const struct FC_Type _MW_DownloadDir = { 51, "D_ownload path" };
d94 1
a94 1
const struct FC_Type _CW_ReadingDir = { 66, "Reading directory..." };
d97 1
a97 1
const struct FC_Type _CW_ChangingDirectory = { 69, "Changing directory..." };
d125 1
a125 1
const struct FC_Type _Str_ErrorReadingDir = { 97, "Error reading dir\n" };
d167 1
a167 1
const struct FC_Type _MPW_HideDirectories = { 139, "Hide directories" };
d177 5
@


1.585
log
@Changed the parsing of the command line site.
ESC now closes all windows but connect- and transferwindow.
RETURN connects to the current site.
Using the Exec-list functions/macros.
New windowtitle, now with # of files selected and more.
@
text
@d48 1
a48 1
const struct FC_Type _SCW_Anonymous = { 20, "Anonymous lo_gin?" };
d74 1
a74 1
const struct FC_Type _MPW_ProxyDefault = { 46, "Use pro_xy per default?" };
d76 1
a76 1
const struct FC_Type _MPW_IgnoreCase = { 48, "_Ignore case?" };
d119 2
a120 2
const struct FC_Type _MENU_LogWindow = { 91, "Log window?" };
const struct FC_Type _MENU_ToggleDotFiles = { 92, "Show dot-files?" };
d157 1
a157 1
const struct FC_Type _MENU_ToggleADTFiles = { 129, "Show entire RECENT?" };
d165 2
a166 2
const struct FC_Type _MPW_DeleteViewed = { 137, "Delete viewed files?" };
const struct FC_Type _MPW_Beep = { 138, "Beep after transfer?" };
d168 4
a171 4
const struct FC_Type _MPW_PreservePath = { 140, "Preserve filepath?" };
const struct FC_Type _MPW_ShowMOTD = { 141, "Show MOTD-file?" };
const struct FC_Type _MPW_GetReadme = { 142, "Download readme?" };
const struct FC_Type _SCW_AminetMode = { 143, "Aminet-mode?" };
@


1.539
log
@Fixed bug.
@
text
@d176 1
@


1.531
log
@Lots of stuff
@
text
@d48 1
a48 1
const struct FC_Type _SCW_Anonymous = { 20, "Anon_ymous login?" };
@


1.401
log
@Started on improving the functionnames.
Added Aminet-mode, not 100% finished yet.
Reworked the prefs-window, not everything is finished.
Started using listbrowser v41-functions.
Added parsing of URL-like commandline.
@
text
@d48 1
a48 1
const struct FC_Type _SCW_Anonymous = { 20, "A_nonymous login?" };
d158 1
a158 1
const struct FC_Type _MENU_ResetADT = { 130, "Reset ADT-date" };
d172 4
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d157 15
@


1.124
log
@AmiTCP and AS225r2 support in the same binary.
ARexx-command VIEW added.
New option to SETATTR, QUIET.
SETATTR LOCALDIR didn't update the download dir-gadget.
GETATTR STEM=bar didn't work since bar is in lowercase.
Enforcer hits when trying to open AmiFTP on a non-existing screen removed.
Moved 'Show dot-files?' to the Settings-menu.
Icelandic and Spanish catalogs added.
@
text
@d31 1
a31 1
const struct FC_Type _SLW_New = { 3, "_New" };
d102 1
a102 1
const struct FC_Type _MENU_About = { 74, "?\000About" };
d118 1
a118 1
const struct FC_Type _MENU_Hostlist = { 90, "2\000Hostlist..." };
d155 2
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d19 1
a19 1
static LONG AmiFTP_Version = 1;
d41 31
a71 31
const struct FC_Type _SCW_SiteConfigurationWindow = { 13, "AmiFTP Site Configuration" };
const struct FC_Type _SCW_Name = { 14, "Na_me" };
const struct FC_Type _SCW_Site = { 15, "_Site" };
const struct FC_Type _SCW_Port = { 16, "_Port" };
const struct FC_Type _SCW_RemDir = { 17, "_Auto-cd to directory" };
const struct FC_Type _SCW_LocDir = { 18, "_Download path" };
const struct FC_Type _SCW_Anonymous = { 19, "A_nonymous login?" };
const struct FC_Type _SCW_LoginName = { 20, "_Login name" };
const struct FC_Type _SCW_Password = { 21, "Pass_word" };
const struct FC_Type _SCW_OK = { 22, "_OK" };
const struct FC_Type _SCW_Cancel = { 23, "Ca_ncel" };
const struct FC_Type _SCW_OS = { 24, "Operating S_ystem" };
const struct FC_Type _SCW_Proxy = { 25, "Pro_xy" };
const struct FC_Type _SCW_HotList = { 26, "_HotList" };
const struct FC_Type _TW_WinTitle = { 27, "AmiFTP Transfer window" };
const struct FC_Type _TW_RemoteFile = { 28, "Remote file" };
const struct FC_Type _TW_LocalFile = { 29, "Local file" };
const struct FC_Type _TW_Size = { 30, "Size" };
const struct FC_Type _TW_Cps = { 31, "CPS" };
const struct FC_Type _TW_DataTransferred = { 32, "Data transferred" };
const struct FC_Type _TW_Abort = { 33, "Abort transfer" };
const struct FC_Type _TW_FileExists = { 34, "File '%s' already exists.\nOld filesize is: %ld bytes (new %ld bytes).\n" };
const struct FC_Type _TW_Overwrite = { 35, "Overwrite" };
const struct FC_Type _TW_Resume = { 36, "Resume transfer" };
const struct FC_Type _TW_CancelTransfer = { 37, "Cancel transfer" };
const struct FC_Type _TW_DownloadDir = { 38, "You are about to download a directory tree.\nAre you sure you want to do this?" };
const struct FC_Type _TW_GetDir = { 39, "Yes, download it!|Skip this entry" };
const struct FC_Type _MPW_WinTitle = { 40, "AmiFTP Global Preferences" };
const struct FC_Type _MPW_Password = { 41, "_Anonymous password" };
const struct FC_Type _MPW_ViewCommand = { 42, "_View command" };
const struct FC_Type _MPW_ShowDots = { 43, "Show _dot-files?" };
d88 67
a154 67
const struct FC_Type _CW_WinTitle = { 60, "AmiFTP Connect window" };
const struct FC_Type _CW_Abort = { 61, "Abort" };
const struct FC_Type _CW_Site = { 62, "Site:" };
const struct FC_Type _CW_Status = { 63, "Status:" };
const struct FC_Type _CW_Connecting = { 64, "Connecting..." };
const struct FC_Type _CW_ReadingDir = { 65, "Reading directory..." };
const struct FC_Type _MENU_Project = { 66, "Project" };
const struct FC_Type _MENU_Reconnect = { 67, "Reconnect" };
const struct FC_Type _MENU_Iconify = { 68, "I\000Iconify" };
const struct FC_Type _MENU_About = { 69, "?\000About" };
const struct FC_Type _MENU_Quit = { 70, "Q\000Quit" };
const struct FC_Type _MENU_Files = { 71, "Files" };
const struct FC_Type _MENU_TagAll = { 72, "A\000Tag all" };
const struct FC_Type _MENU_UntagAll = { 73, "U\000Untag all" };
const struct FC_Type _MENU_TransferMode = { 74, "Transfer mode" };
const struct FC_Type _MENU_Binary = { 75, "Binary" };
const struct FC_Type _MENU_ASCII = { 76, "ASCII" };
const struct FC_Type _MENU_ClearCache = { 77, "Clear dir-cache" };
const struct FC_Type _MENU_Delete = { 78, "D\000Delete" };
const struct FC_Type _MENU_Move = { 79, "M\000Move" };
const struct FC_Type _MENU_Sort = { 80, "Sort" };
const struct FC_Type _MENU_SortbyName = { 81, "by name" };
const struct FC_Type _MENU_SortbyDate = { 82, "by date" };
const struct FC_Type _MENU_Settings = { 83, "Settings" };
const struct FC_Type _MENU_Global = { 84, "1\000Global..." };
const struct FC_Type _MENU_Hostlist = { 85, "2\000Hostlist..." };
const struct FC_Type _MENU_LoadSettings = { 86, "Load settings..." };
const struct FC_Type _MENU_SaveSettings = { 87, "Save settings" };
const struct FC_Type _MENU_SaveSettingsAs = { 88, "Save settings as..." };
const struct FC_Type _MENU_HotList = { 89, "Hotlist" };
const struct FC_Type _Str_ErrorReadingDir = { 90, "Error reading dir\n" };
const struct FC_Type _Str_CannotDLDirs = { 91, "Cannot download entire directories!\n" };
const struct FC_Type _Str_SelectDLPath = { 92, "Select download path" };
const struct FC_Type _Str_SelectULFiles = { 93, "Select file(s) to upload" };
const struct FC_Type _Str_CDFailedTimedout = { 94, "Remote CD failed:\nConnection timed out" };
const struct FC_Type _Str_CDFailed = { 95, "Remote CD failed." };
const struct FC_Type _Str_AmiFTPError = { 96, "AmiFTP error" };
const struct FC_Type _Str_OK = { 97, "OK" };
const struct FC_Type _Str_CANCEL = { 98, "Cancel" };
const struct FC_Type _Str_PasswordRequest = { 99, "AmiFTP Password request" };
const struct FC_Type _Str_PasswordEntry = { 100, "Enter password for user:\n%s" };
const struct FC_Type _Str_ServiceNotAvail = { 101, "Service not available." };
const struct FC_Type _Str_ConnectFailed = { 102, "Connect failed." };
const struct FC_Type _Str_ConnectLoginFailed = { 103, "Connect failed, login unknown." };
const struct FC_Type _Str_Putfailed = { 104, "Put of %s failed" };
const struct FC_Type _Str_RemoteWriteFailed = { 105, "Write failed (remote file system full?)." };
const struct FC_Type _Str_GetFailed = { 106, "Get %s failed." };
const struct FC_Type _Str_LocalfileError = { 107, "Error opening %s." };
const struct FC_Type _Str_LocalWriteFailed = { 108, "Write failed: %s" };
const struct FC_Type _Str_NoSuchDir = { 109, "%s: No such file or directory." };
const struct FC_Type _Str_DisconnectedTimeout = { 110, "Disconnected (timeout)." };
const struct FC_Type _Str_Outofmem = { 111, "Out of memory" };
const struct FC_Type _Str_SelectSettingsFile = { 112, "Select settings file..." };
const struct FC_Type _Str_NoRestart = { 113, "Resume command failed." };
const struct FC_Type _Str_ConnectionTimedOut = { 114, "Connection timed out" };
const struct FC_Type _Str_AmiFTPRequest = { 115, "AmiFTP Request" };
const struct FC_Type _Str_AboutAmiFTP = { 116, "About AmiFTP..." };
const struct FC_Type _Str_UnknownHost = { 117, "Unknown host" };
const struct FC_Type _Str_ErrorBuildingDirList = { 118, "Error building filelist." };
const struct FC_Type _Str_Translator = { 119, "" };
const struct FC_Type _MENU_AddToSiteList = { 120, "Add current to sitelist" };
const struct FC_Type _MENU_LogWindow = { 121, "Log window?" };
const struct FC_Type _MW_Reload = { 122, "_Reload" };
const struct FC_Type _SLW_Sort = { 123, "_Sort" };
const struct FC_Type _CW_SendingLogin = { 124, "Sending login..." };
const struct FC_Type _CW_SendingPassword = { 125, "Sending password..." };
const struct FC_Type _CW_ChangingDirectory = { 126, "Changing directory..." };
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d112 2
a113 2
const struct FC_Type _MENU_Global = { 84, "1\000Global" };
const struct FC_Type _MENU_Hostlist = { 85, "2\000Hostlist" };
d150 5
@


0.827
log
@Add Current to sitelist added.
More rtLockWindow()'s
Leeching seems to work, but is not finished yet.
@
text
@d149 1
@


0.685
log
@Links were viewed twice.
Workaround for V39 GTNM_Number/Justification bug.
@
text
@d148 1
@


0.623
log
@Added menuitem TransferMode->Binary/ASCII
@
text
@d147 1
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d63 84
a146 79
const struct FC_Type _TW_Overwrite = { 35, "Overwrite|Resume transfer|Cancel transfer" };
const struct FC_Type _TW_DownloadDir = { 36, "You are about to download a directory tree.\nAre you sure you want to do this?" };
const struct FC_Type _TW_GetDir = { 37, "Yes, download it!|Skip this entry" };
const struct FC_Type _MPW_WinTitle = { 38, "AmiFTP Global Preferences" };
const struct FC_Type _MPW_Password = { 39, "_Anonymous password" };
const struct FC_Type _MPW_ViewCommand = { 40, "_View command" };
const struct FC_Type _MPW_ShowDots = { 41, "Show _dot-files?" };
const struct FC_Type _MPW_ProxyHost = { 42, "Proxy _host" };
const struct FC_Type _MPW_ProxyPort = { 43, "Proxy _port" };
const struct FC_Type _MPW_ProxyDefault = { 44, "Use pro_xy per default?" };
const struct FC_Type _MPW_DefDownloadDir = { 45, "Default download directory" };
const struct FC_Type _MPW_IgnoreCase = { 46, "_Ignore case?" };
const struct FC_Type _MW_SiteName = { 47, "Current _site:" };
const struct FC_Type _MW_DirName = { 48, "D_irectory" };
const struct FC_Type _MW_DownloadDir = { 49, "D_ownload path" };
const struct FC_Type _MW_Parent = { 50, "_Parent" };
const struct FC_Type _MW_Get = { 51, "_Get" };
const struct FC_Type _MW_Put = { 52, "P_ut" };
const struct FC_Type _MW_View = { 53, "_View" };
const struct FC_Type _MW_Connect = { 54, "_Connect to..." };
const struct FC_Type _MW_Disconnect = { 55, "_Disconnect" };
const struct FC_Type _MW_DeleteRequest = { 56, "Are you sure you want to\ndelete these files?" };
const struct FC_Type _MW_DeleteCancel = { 57, "Delete|Cancel" };
const struct FC_Type _CW_WinTitle = { 58, "AmiFTP Connect window" };
const struct FC_Type _CW_Abort = { 59, "Abort" };
const struct FC_Type _CW_Site = { 60, "Site:" };
const struct FC_Type _CW_Status = { 61, "Status:" };
const struct FC_Type _CW_Connecting = { 62, "Connecting..." };
const struct FC_Type _CW_ReadingDir = { 63, "Reading directory..." };
const struct FC_Type _MENU_Project = { 64, "Project" };
const struct FC_Type _MENU_Reconnect = { 65, "Reconnect" };
const struct FC_Type _MENU_Iconify = { 66, "I\000Iconify" };
const struct FC_Type _MENU_About = { 67, "?\000About" };
const struct FC_Type _MENU_Quit = { 68, "Q\000Quit" };
const struct FC_Type _MENU_Files = { 69, "Files" };
const struct FC_Type _MENU_TagAll = { 70, "A\000Tag all" };
const struct FC_Type _MENU_UntagAll = { 71, "U\000Untag all" };
const struct FC_Type _MENU_ClearCache = { 72, "Clear dir-cache" };
const struct FC_Type _MENU_Delete = { 73, "D\000Delete" };
const struct FC_Type _MENU_Move = { 74, "M\000Move" };
const struct FC_Type _MENU_Sort = { 75, "Sort" };
const struct FC_Type _MENU_SortbyName = { 76, "by name" };
const struct FC_Type _MENU_SortbyDate = { 77, "by date" };
const struct FC_Type _MENU_Settings = { 78, "Settings" };
const struct FC_Type _MENU_Global = { 79, "1\000Global" };
const struct FC_Type _MENU_Hostlist = { 80, "2\000Hostlist" };
const struct FC_Type _MENU_LoadSettings = { 81, "Load settings..." };
const struct FC_Type _MENU_SaveSettings = { 82, "Save settings" };
const struct FC_Type _MENU_SaveSettingsAs = { 83, "Save settings as..." };
const struct FC_Type _MENU_HotList = { 84, "Hotlist" };
const struct FC_Type _Str_ErrorReadingDir = { 85, "Error reading dir\n" };
const struct FC_Type _Str_CannotDLDirs = { 86, "Cannot download entire directories!\n" };
const struct FC_Type _Str_SelectDLPath = { 87, "Select download path" };
const struct FC_Type _Str_SelectULFiles = { 88, "Select file(s) to upload" };
const struct FC_Type _Str_CDFailedTimedout = { 89, "Remote CD failed:\nConnection timed out" };
const struct FC_Type _Str_CDFailed = { 90, "Remote CD failed." };
const struct FC_Type _Str_AmiFTPError = { 91, "AmiFTP error" };
const struct FC_Type _Str_OK = { 92, "OK" };
const struct FC_Type _Str_CANCEL = { 93, "Cancel" };
const struct FC_Type _Str_PasswordRequest = { 94, "AmiFTP Password request" };
const struct FC_Type _Str_PasswordEntry = { 95, "Enter password for user:\n%s" };
const struct FC_Type _Str_ServiceNotAvail = { 96, "Service not available." };
const struct FC_Type _Str_ConnectFailed = { 97, "Connect failed." };
const struct FC_Type _Str_ConnectLoginFailed = { 98, "Connect failed, login unknown." };
const struct FC_Type _Str_Putfailed = { 99, "Put of %s failed" };
const struct FC_Type _Str_RemoteWriteFailed = { 100, "Write failed (remote file system full?)." };
const struct FC_Type _Str_GetFailed = { 101, "Get %s failed." };
const struct FC_Type _Str_LocalfileError = { 102, "Error opening %s." };
const struct FC_Type _Str_LocalWriteFailed = { 103, "Write failed: %s" };
const struct FC_Type _Str_NoSuchDir = { 104, "%s: No such file or directory." };
const struct FC_Type _Str_DisconnectedTimeout = { 105, "Disconnected (timeout)." };
const struct FC_Type _Str_Outofmem = { 106, "Out of memory" };
const struct FC_Type _Str_SelectSettingsFile = { 107, "Select settings file..." };
const struct FC_Type _Str_NoRestart = { 108, "Resume command failed." };
const struct FC_Type _Str_ConnectionTimedOut = { 109, "Connection timed out" };
const struct FC_Type _Str_AmiFTPRequest = { 110, "AmiFTP Request" };
const struct FC_Type _Str_AboutAmiFTP = { 111, "About AmiFTP..." };
const struct FC_Type _Str_UnknownHost = { 112, "Unknown host" };
const struct FC_Type _Str_ErrorBuildingDirList = { 113, "Error building filelist." };
@


0.541
log
@Forgot to set ConfigChanged=FALSE when saving the config
Added more hotkeys.
@
text
@d19 1
a19 1
static LONG AmiFTP_Version = 0;
d64 78
a141 71
const struct FC_Type _MPW_WinTitle = { 36, "AmiFTP Global Preferences" };
const struct FC_Type _MPW_Password = { 37, "_Anonymous password" };
const struct FC_Type _MPW_ViewCommand = { 38, "_View command" };
const struct FC_Type _MPW_ShowDots = { 39, "Show _dot-files?" };
const struct FC_Type _MPW_ProxyHost = { 40, "Proxy _host" };
const struct FC_Type _MPW_ProxyPort = { 41, "Proxy _port" };
const struct FC_Type _MPW_ProxyDefault = { 42, "Use pro_xy per default?" };
const struct FC_Type _MPW_DefDownloadDir = { 43, "Default download directory" };
const struct FC_Type _MPW_IgnoreCase = { 44, "_Ignore case?" };
const struct FC_Type _MW_SiteName = { 45, "Current _site:" };
const struct FC_Type _MW_DirName = { 46, "D_irectory" };
const struct FC_Type _MW_DownloadDir = { 47, "D_ownload path" };
const struct FC_Type _MW_Parent = { 48, "_Parent" };
const struct FC_Type _MW_Get = { 49, "_Get" };
const struct FC_Type _MW_Put = { 50, "P_ut" };
const struct FC_Type _MW_View = { 51, "_View" };
const struct FC_Type _MW_Connect = { 52, "_Connect to..." };
const struct FC_Type _MW_Disconnect = { 53, "_Disconnect" };
const struct FC_Type _MW_DeleteRequest = { 54, "Are you sure you want to\ndelete these files?" };
const struct FC_Type _MW_DeleteCancel = { 55, "Delete|Cancel" };
const struct FC_Type _CW_WinTitle = { 56, "AmiFTP Connect window" };
const struct FC_Type _CW_Abort = { 57, "Abort" };
const struct FC_Type _CW_Site = { 58, "Site:" };
const struct FC_Type _CW_Status = { 59, "Status:" };
const struct FC_Type _MENU_Project = { 60, "Project" };
const struct FC_Type _MENU_Reconnect = { 61, "Reconnect" };
const struct FC_Type _MENU_Iconify = { 62, "I\000Iconify" };
const struct FC_Type _MENU_About = { 63, "?\000About" };
const struct FC_Type _MENU_Quit = { 64, "Q\000Quit" };
const struct FC_Type _MENU_Files = { 65, "Files" };
const struct FC_Type _MENU_TagAll = { 66, "A\000Tag all" };
const struct FC_Type _MENU_UntagAll = { 67, "U\000Untag all" };
const struct FC_Type _MENU_ClearCache = { 68, "Clear dir-cache" };
const struct FC_Type _MENU_Delete = { 69, "D\000Delete" };
const struct FC_Type _MENU_Move = { 70, "M\000Move" };
const struct FC_Type _MENU_Sort = { 71, "Sort" };
const struct FC_Type _MENU_SortbyName = { 72, "by name" };
const struct FC_Type _MENU_SortbyDate = { 73, "by date" };
const struct FC_Type _MENU_Settings = { 74, "Settings" };
const struct FC_Type _MENU_Global = { 75, "1\000Global" };
const struct FC_Type _MENU_Hostlist = { 76, "2\000Hostlist" };
const struct FC_Type _MENU_LoadSettings = { 77, "Load settings..." };
const struct FC_Type _MENU_SaveSettings = { 78, "Save settings" };
const struct FC_Type _MENU_SaveSettingsAs = { 79, "Save settings as..." };
const struct FC_Type _MENU_HotList = { 80, "Hotlist" };
const struct FC_Type _Str_ErrorReadingDir = { 81, "Error reading dir\n" };
const struct FC_Type _Str_CannotDLDirs = { 82, "Cannot download entire directories!\n" };
const struct FC_Type _Str_SelectDLPath = { 83, "Select download path" };
const struct FC_Type _Str_SelectULFiles = { 84, "Select file(s) to upload" };
const struct FC_Type _Str_CDFailedTimedout = { 85, "Remote CD failed:\nConnection timed out" };
const struct FC_Type _Str_CDFailed = { 86, "Remote CD failed." };
const struct FC_Type _Str_AmiFTPError = { 87, "AmiFTP error" };
const struct FC_Type _Str_OK = { 88, "OK" };
const struct FC_Type _Str_CANCEL = { 89, "Cancel" };
const struct FC_Type _Str_PasswordRequest = { 90, "AmiFTP Password request" };
const struct FC_Type _Str_PasswordEntry = { 91, "Enter password for user:\n%s" };
const struct FC_Type _Str_ServiceNotAvail = { 92, "Service not available." };
const struct FC_Type _Str_ConnectFailed = { 93, "Connect failed." };
const struct FC_Type _Str_ConnectLoginFailed = { 94, "Connect failed, login unknown." };
const struct FC_Type _Str_Putfailed = { 95, "Put of %s failed" };
const struct FC_Type _Str_RemoteWriteFailed = { 96, "Write failed (remote file system full?)." };
const struct FC_Type _Str_GetFailed = { 97, "Get %s failed." };
const struct FC_Type _Str_LocalfileError = { 98, "Error opening %s." };
const struct FC_Type _Str_LocalWriteFailed = { 99, "Write failed: %s" };
const struct FC_Type _Str_NoSuchDir = { 100, "%s: No such file or directory." };
const struct FC_Type _Str_DisconnectedTimeout = { 101, "Disconnected (timeout)." };
const struct FC_Type _Str_Outofmem = { 102, "Out of memory" };
const struct FC_Type _Str_SelectSettingsFile = { 103, "Select settings file..." };
const struct FC_Type _TW_DownloadDir = { 104, "You are about to download a directory tree.\nAre you sure you want to do this?" };
const struct FC_Type _TW_GetDir = { 105, "Yes, download it!|Skip this entry" };
const struct FC_Type _Str_NoRestart = { 106, "Resume command failed." };
@


0.534
log
@Anonymous flag on per default
@
text
@d47 1
a47 1
const struct FC_Type _SCW_Anonymous = { 19, "Anonymous login?" };
d49 2
a50 2
const struct FC_Type _SCW_Password = { 21, "Password" };
const struct FC_Type _SCW_OK = { 22, "OK" };
d64 1
a64 1
const struct FC_Type _MPW_WinTitle = { 36, "AmiFTP Preferences" };
d66 5
a70 5
const struct FC_Type _MPW_ViewCommand = { 38, "View command" };
const struct FC_Type _MPW_ShowDots = { 39, "Show dot-files?" };
const struct FC_Type _MPW_ProxyHost = { 40, "Proxy host" };
const struct FC_Type _MPW_ProxyPort = { 41, "Proxy port" };
const struct FC_Type _MPW_ProxyDefault = { 42, "Use proxy per default?" };
d72 1
a72 1
const struct FC_Type _MPW_IgnoreCase = { 44, "Ignore case?" };
@


0.531
log
@Resume transfer added (when getting files).
Get-dir-tree is broken.
@
text
@d103 2
a104 2
const struct FC_Type _MENU_Global = { 75, "Global" };
const struct FC_Type _MENU_Hostlist = { 76, "Hostlist" };
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d63 1
a63 1
const struct FC_Type _TW_Overwrite = { 35, "Overwrite|Cancel transfer" };
d94 2
a95 2
const struct FC_Type _MENU_TagAll = { 66, "Tag all" };
const struct FC_Type _MENU_UntagAll = { 67, "Untag all" };
d132 3
@


0.425
log
@Add Settingsmenu with Load/Save settings.
Added Edit hostlist to the settingsmenu.
Changed the search order for the prefs-file.
@
text
@d91 1
a91 1
const struct FC_Type _MENU_About = { 63, "About" };
@


0.371
log
@Localized source.
@
text
@d35 97
a131 91
const struct FC_Type _SLW_Up = { 7, "Up" };
const struct FC_Type _SLW_Down = { 8, "Down" };
const struct FC_Type _SLW_Top = { 9, "Top" };
const struct FC_Type _SLW_Bottom = { 10, "Bottom" };
const struct FC_Type _SLW_Newstring = { 11, "(New)" };
const struct FC_Type _SCW_SiteConfigurationWindow = { 12, "AmiFTP Site Configuration" };
const struct FC_Type _SCW_Name = { 13, "Na_me" };
const struct FC_Type _SCW_Site = { 14, "_Site" };
const struct FC_Type _SCW_Port = { 15, "_Port" };
const struct FC_Type _SCW_RemDir = { 16, "_Auto-cd to directory" };
const struct FC_Type _SCW_LocDir = { 17, "_Download path" };
const struct FC_Type _SCW_Anonymous = { 18, "Anonymous login?" };
const struct FC_Type _SCW_LoginName = { 19, "_Login name" };
const struct FC_Type _SCW_Password = { 20, "Password" };
const struct FC_Type _SCW_OK = { 21, "OK" };
const struct FC_Type _SCW_Cancel = { 22, "Ca_ncel" };
const struct FC_Type _SCW_OS = { 23, "Operating S_ystem" };
const struct FC_Type _SCW_Proxy = { 24, "Pro_xy" };
const struct FC_Type _SCW_HotList = { 25, "_HotList" };
const struct FC_Type _TW_WinTitle = { 26, "AmiFTP Transfer window" };
const struct FC_Type _TW_RemoteFile = { 27, "Remote file" };
const struct FC_Type _TW_LocalFile = { 28, "Local file" };
const struct FC_Type _TW_Size = { 29, "Size" };
const struct FC_Type _TW_Cps = { 30, "CPS" };
const struct FC_Type _TW_DataTransferred = { 31, "Data transferred" };
const struct FC_Type _TW_Abort = { 32, "Abort transfer" };
const struct FC_Type _TW_FileExists = { 33, "File '%s' already exists.\nOld filesize is: %ld bytes (new %ld bytes).\n" };
const struct FC_Type _TW_Overwrite = { 34, "Overwrite|Cancel transfer" };
const struct FC_Type _MPW_WinTitle = { 35, "AmiFTP Preferences" };
const struct FC_Type _MPW_Password = { 36, "_Anonymous password" };
const struct FC_Type _MPW_ViewCommand = { 37, "View command" };
const struct FC_Type _MPW_ShowDots = { 38, "Show dot-files?" };
const struct FC_Type _MPW_ProxyHost = { 39, "Proxy host" };
const struct FC_Type _MPW_ProxyPort = { 40, "Proxy port" };
const struct FC_Type _MPW_ProxyDefault = { 41, "Use proxy per default?" };
const struct FC_Type _MPW_DefDownloadDir = { 42, "Default download directory" };
const struct FC_Type _MPW_IgnoreCase = { 43, "Ignore case?" };
const struct FC_Type _MW_SiteName = { 44, "Current _site:" };
const struct FC_Type _MW_DirName = { 45, "D_irectory" };
const struct FC_Type _MW_DownloadDir = { 46, "D_ownload path" };
const struct FC_Type _MW_Parent = { 47, "_Parent" };
const struct FC_Type _MW_Get = { 48, "_Get" };
const struct FC_Type _MW_Put = { 49, "P_ut" };
const struct FC_Type _MW_View = { 50, "_View" };
const struct FC_Type _MW_Connect = { 51, "_Connect to..." };
const struct FC_Type _MW_Disconnect = { 52, "_Disconnect" };
const struct FC_Type _MW_DeleteRequest = { 53, "Are you sure you want to\ndelete these files?" };
const struct FC_Type _MW_DeleteCancel = { 54, "Delete|Cancel" };
const struct FC_Type _CW_WinTitle = { 55, "AmiFTP Connect window" };
const struct FC_Type _CW_Abort = { 56, "Abort" };
const struct FC_Type _CW_Site = { 57, "Site:" };
const struct FC_Type _CW_Status = { 58, "Status:" };
const struct FC_Type _MENU_Project = { 59, "Project" };
const struct FC_Type _MENU_Reconnect = { 60, "Reconnect" };
const struct FC_Type _MENU_Preferences = { 61, "Preferences" };
const struct FC_Type _MENU_SavePrefs = { 62, "Save preferences" };
const struct FC_Type _MENU_Iconify = { 63, "I\000Iconify" };
const struct FC_Type _MENU_About = { 64, "About" };
const struct FC_Type _MENU_Quit = { 65, "Q\000Quit" };
const struct FC_Type _MENU_Files = { 66, "Files" };
const struct FC_Type _MENU_TagAll = { 67, "Tag all" };
const struct FC_Type _MENU_UntagAll = { 68, "Untag all" };
const struct FC_Type _MENU_ClearCache = { 69, "Clear dir-cache" };
const struct FC_Type _MENU_Delete = { 70, "D\000Delete" };
const struct FC_Type _MENU_Move = { 71, "M\000Move" };
const struct FC_Type _MENU_Sort = { 72, "Sort" };
const struct FC_Type _MENU_SortbyName = { 73, "by name" };
const struct FC_Type _MENU_SortbyDate = { 74, "by date" };
const struct FC_Type _MENU_HotList = { 75, "Hotlist" };
const struct FC_Type _Str_ErrorReadingDir = { 76, "Error reading dir\n" };
const struct FC_Type _Str_CannotDLDirs = { 77, "Cannot download entire directories!\n" };
const struct FC_Type _Str_SelectDLPath = { 78, "Select download path" };
const struct FC_Type _Str_SelectULFiles = { 79, "Select file(s) to upload" };
const struct FC_Type _Str_CDFailedTimedout = { 80, "Remote CD failed:\nConnection timed out" };
const struct FC_Type _Str_CDFailed = { 81, "Remote CD failed." };
const struct FC_Type _Str_AmiFTPError = { 82, "AmiFTP error" };
const struct FC_Type _Str_OK = { 83, "OK" };
const struct FC_Type _Str_CANCEL = { 84, "Cancel" };
const struct FC_Type _Str_PasswordRequest = { 85, "AmiFTP Password request" };
const struct FC_Type _Str_PasswordEntry = { 86, "Enter password for user:\n%s" };
const struct FC_Type _Str_ServiceNotAvail = { 87, "Service not available." };
const struct FC_Type _Str_ConnectFailed = { 88, "Connect failed." };
const struct FC_Type _Str_ConnectLoginFailed = { 89, "Connect failed, login unknown." };
const struct FC_Type _Str_Putfailed = { 90, "Put of %s failed" };
const struct FC_Type _Str_RemoteWriteFailed = { 91, "Write failed (remote file system full?)." };
const struct FC_Type _Str_GetFailed = { 92, "Get %s failed." };
const struct FC_Type _Str_LocalfileError = { 93, "Error opening %s." };
const struct FC_Type _Str_LocalWriteFailed = { 94, "Write failed: %s" };
const struct FC_Type _Str_NoSuchDir = { 95, "%s: No such file or directory." };
const struct FC_Type _Str_DisconnectedTimeout = { 96, "Disconnected (timeout)." };
const struct FC_Type _Str_Outofmem = { 97, "Out of memory" };
@
