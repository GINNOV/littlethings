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
next	1.585;

1.585
date	96.06.13.00.03.21;	author lilja;	state Exp;
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
next	0.531;

0.531
date	95.09.01.17.25.42;	author lilja;	state Exp;
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
@File created by FlexCat.
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

#ifndef AmiFTP_CAT_H
#define AmiFTP_CAT_H


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif	/*  !EXEC_TYPES_H	    */
#ifndef LIBRARIES_LOCALE_H
#include <libraries/locale.h>
#endif	/*  !LIBRARIES_LOCALE_H     */


/*  Prototypes	*/
extern void OpenAmiFTPCatalog(struct Locale *, STRPTR);
extern void CloseAmiFTPCatalog(void);
extern STRPTR GetAmiFTPString(APTR);

/*  Definitions */
extern const APTR _SLW_SiteListWindow;
#define SLW_SiteListWindow ((APTR) &_SLW_SiteListWindow)
extern const APTR _SLW_SiteList;
#define SLW_SiteList ((APTR) &_SLW_SiteList)
extern const APTR _SLW_Connect;
#define SLW_Connect ((APTR) &_SLW_Connect)
extern const APTR _SLW_New;
#define SLW_New ((APTR) &_SLW_New)
extern const APTR _SLW_Edit;
#define SLW_Edit ((APTR) &_SLW_Edit)
extern const APTR _SLW_Remove;
#define SLW_Remove ((APTR) &_SLW_Remove)
extern const APTR _SLW_Cancel;
#define SLW_Cancel ((APTR) &_SLW_Cancel)
extern const APTR _SLW_OK;
#define SLW_OK ((APTR) &_SLW_OK)
extern const APTR _SLW_Up;
#define SLW_Up ((APTR) &_SLW_Up)
extern const APTR _SLW_Down;
#define SLW_Down ((APTR) &_SLW_Down)
extern const APTR _SLW_Top;
#define SLW_Top ((APTR) &_SLW_Top)
extern const APTR _SLW_Bottom;
#define SLW_Bottom ((APTR) &_SLW_Bottom)
extern const APTR _SLW_Newstring;
#define SLW_Newstring ((APTR) &_SLW_Newstring)
extern const APTR _SLW_Sort;
#define SLW_Sort ((APTR) &_SLW_Sort)
extern const APTR _SCW_SiteConfigurationWindow;
#define SCW_SiteConfigurationWindow ((APTR) &_SCW_SiteConfigurationWindow)
extern const APTR _SCW_Name;
#define SCW_Name ((APTR) &_SCW_Name)
extern const APTR _SCW_Site;
#define SCW_Site ((APTR) &_SCW_Site)
extern const APTR _SCW_Port;
#define SCW_Port ((APTR) &_SCW_Port)
extern const APTR _SCW_RemDir;
#define SCW_RemDir ((APTR) &_SCW_RemDir)
extern const APTR _SCW_LocDir;
#define SCW_LocDir ((APTR) &_SCW_LocDir)
extern const APTR _SCW_Anonymous;
#define SCW_Anonymous ((APTR) &_SCW_Anonymous)
extern const APTR _SCW_LoginName;
#define SCW_LoginName ((APTR) &_SCW_LoginName)
extern const APTR _SCW_Password;
#define SCW_Password ((APTR) &_SCW_Password)
extern const APTR _SCW_OK;
#define SCW_OK ((APTR) &_SCW_OK)
extern const APTR _SCW_Cancel;
#define SCW_Cancel ((APTR) &_SCW_Cancel)
extern const APTR _SCW_OS;
#define SCW_OS ((APTR) &_SCW_OS)
extern const APTR _SCW_Proxy;
#define SCW_Proxy ((APTR) &_SCW_Proxy)
extern const APTR _SCW_HotList;
#define SCW_HotList ((APTR) &_SCW_HotList)
extern const APTR _TW_WinTitle;
#define TW_WinTitle ((APTR) &_TW_WinTitle)
extern const APTR _TW_RemoteFile;
#define TW_RemoteFile ((APTR) &_TW_RemoteFile)
extern const APTR _TW_LocalFile;
#define TW_LocalFile ((APTR) &_TW_LocalFile)
extern const APTR _TW_Size;
#define TW_Size ((APTR) &_TW_Size)
extern const APTR _TW_Cps;
#define TW_Cps ((APTR) &_TW_Cps)
extern const APTR _TW_DataTransferred;
#define TW_DataTransferred ((APTR) &_TW_DataTransferred)
extern const APTR _TW_Abort;
#define TW_Abort ((APTR) &_TW_Abort)
extern const APTR _TW_FileExists;
#define TW_FileExists ((APTR) &_TW_FileExists)
extern const APTR _TW_Overwrite;
#define TW_Overwrite ((APTR) &_TW_Overwrite)
extern const APTR _TW_Resume;
#define TW_Resume ((APTR) &_TW_Resume)
extern const APTR _TW_CancelTransfer;
#define TW_CancelTransfer ((APTR) &_TW_CancelTransfer)
extern const APTR _TW_DownloadDir;
#define TW_DownloadDir ((APTR) &_TW_DownloadDir)
extern const APTR _TW_GetDir;
#define TW_GetDir ((APTR) &_TW_GetDir)
extern const APTR _MPW_WinTitle;
#define MPW_WinTitle ((APTR) &_MPW_WinTitle)
extern const APTR _MPW_Password;
#define MPW_Password ((APTR) &_MPW_Password)
extern const APTR _MPW_ViewCommand;
#define MPW_ViewCommand ((APTR) &_MPW_ViewCommand)
extern const APTR _MPW_ProxyHost;
#define MPW_ProxyHost ((APTR) &_MPW_ProxyHost)
extern const APTR _MPW_ProxyPort;
#define MPW_ProxyPort ((APTR) &_MPW_ProxyPort)
extern const APTR _MPW_ProxyDefault;
#define MPW_ProxyDefault ((APTR) &_MPW_ProxyDefault)
extern const APTR _MPW_DefDownloadDir;
#define MPW_DefDownloadDir ((APTR) &_MPW_DefDownloadDir)
extern const APTR _MPW_IgnoreCase;
#define MPW_IgnoreCase ((APTR) &_MPW_IgnoreCase)
extern const APTR _MW_SiteName;
#define MW_SiteName ((APTR) &_MW_SiteName)
extern const APTR _MW_DirName;
#define MW_DirName ((APTR) &_MW_DirName)
extern const APTR _MW_DownloadDir;
#define MW_DownloadDir ((APTR) &_MW_DownloadDir)
extern const APTR _MW_Parent;
#define MW_Parent ((APTR) &_MW_Parent)
extern const APTR _MW_Get;
#define MW_Get ((APTR) &_MW_Get)
extern const APTR _MW_Put;
#define MW_Put ((APTR) &_MW_Put)
extern const APTR _MW_View;
#define MW_View ((APTR) &_MW_View)
extern const APTR _MW_Connect;
#define MW_Connect ((APTR) &_MW_Connect)
extern const APTR _MW_Disconnect;
#define MW_Disconnect ((APTR) &_MW_Disconnect)
extern const APTR _MW_DeleteRequest;
#define MW_DeleteRequest ((APTR) &_MW_DeleteRequest)
extern const APTR _MW_DeleteCancel;
#define MW_DeleteCancel ((APTR) &_MW_DeleteCancel)
extern const APTR _MW_Reload;
#define MW_Reload ((APTR) &_MW_Reload)
extern const APTR _CW_WinTitle;
#define CW_WinTitle ((APTR) &_CW_WinTitle)
extern const APTR _CW_Abort;
#define CW_Abort ((APTR) &_CW_Abort)
extern const APTR _CW_Site;
#define CW_Site ((APTR) &_CW_Site)
extern const APTR _CW_Status;
#define CW_Status ((APTR) &_CW_Status)
extern const APTR _CW_Connecting;
#define CW_Connecting ((APTR) &_CW_Connecting)
extern const APTR _CW_ReadingDir;
#define CW_ReadingDir ((APTR) &_CW_ReadingDir)
extern const APTR _CW_SendingLogin;
#define CW_SendingLogin ((APTR) &_CW_SendingLogin)
extern const APTR _CW_SendingPassword;
#define CW_SendingPassword ((APTR) &_CW_SendingPassword)
extern const APTR _CW_ChangingDirectory;
#define CW_ChangingDirectory ((APTR) &_CW_ChangingDirectory)
extern const APTR _MENU_Project;
#define MENU_Project ((APTR) &_MENU_Project)
extern const APTR _MENU_AddToSiteList;
#define MENU_AddToSiteList ((APTR) &_MENU_AddToSiteList)
extern const APTR _MENU_Reconnect;
#define MENU_Reconnect ((APTR) &_MENU_Reconnect)
extern const APTR _MENU_Iconify;
#define MENU_Iconify ((APTR) &_MENU_Iconify)
extern const APTR _MENU_About;
#define MENU_About ((APTR) &_MENU_About)
extern const APTR _MENU_Quit;
#define MENU_Quit ((APTR) &_MENU_Quit)
extern const APTR _MENU_Files;
#define MENU_Files ((APTR) &_MENU_Files)
extern const APTR _MENU_TagAll;
#define MENU_TagAll ((APTR) &_MENU_TagAll)
extern const APTR _MENU_UntagAll;
#define MENU_UntagAll ((APTR) &_MENU_UntagAll)
extern const APTR _MENU_TransferMode;
#define MENU_TransferMode ((APTR) &_MENU_TransferMode)
extern const APTR _MENU_Binary;
#define MENU_Binary ((APTR) &_MENU_Binary)
extern const APTR _MENU_ASCII;
#define MENU_ASCII ((APTR) &_MENU_ASCII)
extern const APTR _MENU_ClearCache;
#define MENU_ClearCache ((APTR) &_MENU_ClearCache)
extern const APTR _MENU_Delete;
#define MENU_Delete ((APTR) &_MENU_Delete)
extern const APTR _MENU_Move;
#define MENU_Move ((APTR) &_MENU_Move)
extern const APTR _MENU_Sort;
#define MENU_Sort ((APTR) &_MENU_Sort)
extern const APTR _MENU_SortbyName;
#define MENU_SortbyName ((APTR) &_MENU_SortbyName)
extern const APTR _MENU_SortbyDate;
#define MENU_SortbyDate ((APTR) &_MENU_SortbyDate)
extern const APTR _MENU_Settings;
#define MENU_Settings ((APTR) &_MENU_Settings)
extern const APTR _MENU_Global;
#define MENU_Global ((APTR) &_MENU_Global)
extern const APTR _MENU_Hostlist;
#define MENU_Hostlist ((APTR) &_MENU_Hostlist)
extern const APTR _MENU_LogWindow;
#define MENU_LogWindow ((APTR) &_MENU_LogWindow)
extern const APTR _MENU_ToggleDotFiles;
#define MENU_ToggleDotFiles ((APTR) &_MENU_ToggleDotFiles)
extern const APTR _MENU_LoadSettings;
#define MENU_LoadSettings ((APTR) &_MENU_LoadSettings)
extern const APTR _MENU_SaveSettings;
#define MENU_SaveSettings ((APTR) &_MENU_SaveSettings)
extern const APTR _MENU_SaveSettingsAs;
#define MENU_SaveSettingsAs ((APTR) &_MENU_SaveSettingsAs)
extern const APTR _MENU_HotList;
#define MENU_HotList ((APTR) &_MENU_HotList)
extern const APTR _Str_ErrorReadingDir;
#define Str_ErrorReadingDir ((APTR) &_Str_ErrorReadingDir)
extern const APTR _Str_CannotDLDirs;
#define Str_CannotDLDirs ((APTR) &_Str_CannotDLDirs)
extern const APTR _Str_SelectDLPath;
#define Str_SelectDLPath ((APTR) &_Str_SelectDLPath)
extern const APTR _Str_SelectULFiles;
#define Str_SelectULFiles ((APTR) &_Str_SelectULFiles)
extern const APTR _Str_CDFailedTimedout;
#define Str_CDFailedTimedout ((APTR) &_Str_CDFailedTimedout)
extern const APTR _Str_CDFailed;
#define Str_CDFailed ((APTR) &_Str_CDFailed)
extern const APTR _Str_AmiFTPError;
#define Str_AmiFTPError ((APTR) &_Str_AmiFTPError)
extern const APTR _Str_OK;
#define Str_OK ((APTR) &_Str_OK)
extern const APTR _Str_CANCEL;
#define Str_CANCEL ((APTR) &_Str_CANCEL)
extern const APTR _Str_PasswordRequest;
#define Str_PasswordRequest ((APTR) &_Str_PasswordRequest)
extern const APTR _Str_PasswordEntry;
#define Str_PasswordEntry ((APTR) &_Str_PasswordEntry)
extern const APTR _Str_ServiceNotAvail;
#define Str_ServiceNotAvail ((APTR) &_Str_ServiceNotAvail)
extern const APTR _Str_ConnectFailed;
#define Str_ConnectFailed ((APTR) &_Str_ConnectFailed)
extern const APTR _Str_ConnectLoginFailed;
#define Str_ConnectLoginFailed ((APTR) &_Str_ConnectLoginFailed)
extern const APTR _Str_Putfailed;
#define Str_Putfailed ((APTR) &_Str_Putfailed)
extern const APTR _Str_RemoteWriteFailed;
#define Str_RemoteWriteFailed ((APTR) &_Str_RemoteWriteFailed)
extern const APTR _Str_GetFailed;
#define Str_GetFailed ((APTR) &_Str_GetFailed)
extern const APTR _Str_LocalfileError;
#define Str_LocalfileError ((APTR) &_Str_LocalfileError)
extern const APTR _Str_LocalWriteFailed;
#define Str_LocalWriteFailed ((APTR) &_Str_LocalWriteFailed)
extern const APTR _Str_NoSuchDir;
#define Str_NoSuchDir ((APTR) &_Str_NoSuchDir)
extern const APTR _Str_DisconnectedTimeout;
#define Str_DisconnectedTimeout ((APTR) &_Str_DisconnectedTimeout)
extern const APTR _Str_Outofmem;
#define Str_Outofmem ((APTR) &_Str_Outofmem)
extern const APTR _Str_SelectSettingsFile;
#define Str_SelectSettingsFile ((APTR) &_Str_SelectSettingsFile)
extern const APTR _Str_NoRestart;
#define Str_NoRestart ((APTR) &_Str_NoRestart)
extern const APTR _Str_ConnectionTimedOut;
#define Str_ConnectionTimedOut ((APTR) &_Str_ConnectionTimedOut)
extern const APTR _Str_AmiFTPRequest;
#define Str_AmiFTPRequest ((APTR) &_Str_AmiFTPRequest)
extern const APTR _Str_AboutAmiFTP;
#define Str_AboutAmiFTP ((APTR) &_Str_AboutAmiFTP)
extern const APTR _Str_UnknownHost;
#define Str_UnknownHost ((APTR) &_Str_UnknownHost)
extern const APTR _Str_ErrorBuildingDirList;
#define Str_ErrorBuildingDirList ((APTR) &_Str_ErrorBuildingDirList)
extern const APTR _Str_Translator;
#define Str_Translator ((APTR) &_Str_Translator)
extern const APTR _SLW_NewGroup;
#define SLW_NewGroup ((APTR) &_SLW_NewGroup)
extern const APTR _SLW_AddBar;
#define SLW_AddBar ((APTR) &_SLW_AddBar)
extern const APTR _MENU_ToggleADTFiles;
#define MENU_ToggleADTFiles ((APTR) &_MENU_ToggleADTFiles)
extern const APTR _MENU_ResetADT;
#define MENU_ResetADT ((APTR) &_MENU_ResetADT)
extern const APTR _MW_ViewReadme;
#define MW_ViewReadme ((APTR) &_MW_ViewReadme)
extern const APTR _MPW_General;
#define MPW_General ((APTR) &_MPW_General)
extern const APTR _MPW_ADT;
#define MPW_ADT ((APTR) &_MPW_ADT)
extern const APTR _MPW_Proxy;
#define MPW_Proxy ((APTR) &_MPW_Proxy)
extern const APTR _MPW_BufferSize;
#define MPW_BufferSize ((APTR) &_MPW_BufferSize)
extern const APTR _MPW_DirCacheSize;
#define MPW_DirCacheSize ((APTR) &_MPW_DirCacheSize)
extern const APTR _MPW_DeleteViewed;
#define MPW_DeleteViewed ((APTR) &_MPW_DeleteViewed)
extern const APTR _MPW_Beep;
#define MPW_Beep ((APTR) &_MPW_Beep)
extern const APTR _MPW_HideDirectories;
#define MPW_HideDirectories ((APTR) &_MPW_HideDirectories)
extern const APTR _MPW_PreservePath;
#define MPW_PreservePath ((APTR) &_MPW_PreservePath)
extern const APTR _MPW_ShowMOTD;
#define MPW_ShowMOTD ((APTR) &_MPW_ShowMOTD)
extern const APTR _MPW_GetReadme;
#define MPW_GetReadme ((APTR) &_MPW_GetReadme)
extern const APTR _SCW_AminetMode;
#define SCW_AminetMode ((APTR) &_SCW_AminetMode)
extern const APTR _MPW_OK;
#define MPW_OK ((APTR) &_MPW_OK)
extern const APTR _MPW_Cancel;
#define MPW_Cancel ((APTR) &_MPW_Cancel)
extern const APTR _TW_TimeLeft;
#define TW_TimeLeft ((APTR) &_TW_TimeLeft)
extern const APTR _Str_NoNewAminetFiles;
#define Str_NoNewAminetFiles ((APTR) &_Str_NoNewAminetFiles)
extern const APTR _Str_WindowTitle;
#define Str_WindowTitle ((APTR) &_Str_WindowTitle)
extern const APTR _MENU_Connect;
#define MENU_Connect ((APTR) &_MENU_Connect)
extern const APTR _MENU_Disconnect;
#define MENU_Disconnect ((APTR) &_MENU_Disconnect)
extern const APTR _MENU_Get;
#define MENU_Get ((APTR) &_MENU_Get)
extern const APTR _MENU_Put;
#define MENU_Put ((APTR) &_MENU_Put)
extern const APTR _MENU_View;
#define MENU_View ((APTR) &_MENU_View)
extern const APTR _MENU_PatternSelect;
#define MENU_PatternSelect ((APTR) &_MENU_PatternSelect)
extern const APTR _MPW_Display;
#define MPW_Display ((APTR) &_MPW_Display)
extern const APTR _Str_PatternRequest;
#define Str_PatternRequest ((APTR) &_Str_PatternRequest)
extern const APTR _Str_SelectPattern;
#define Str_SelectPattern ((APTR) &_Str_SelectPattern)
extern const APTR _MENU_Parent;
#define MENU_Parent ((APTR) &_MENU_Parent)
extern const APTR _MPW_PublicScreen;
#define MPW_PublicScreen ((APTR) &_MPW_PublicScreen)
extern const APTR _MPW_SystemFonts;
#define MPW_SystemFonts ((APTR) &_MPW_SystemFonts)
extern const APTR _MPW_InterfaceFont;
#define MPW_InterfaceFont ((APTR) &_MPW_InterfaceFont)
extern const APTR _MPW_FilelistFont;
#define MPW_FilelistFont ((APTR) &_MPW_FilelistFont)
extern const APTR _MPW_ShowButtons;
#define MPW_ShowButtons ((APTR) &_MPW_ShowButtons)
extern const APTR _MPW_ShowToolbar;
#define MPW_ShowToolbar ((APTR) &_MPW_ShowToolbar)
extern const APTR _MENU_ViewReadme;
#define MENU_ViewReadme ((APTR) &_MENU_ViewReadme)
extern const APTR _MPW_DefaultScreen;
#define MPW_DefaultScreen ((APTR) &_MPW_DefaultScreen)
extern const APTR _TW_OverwriteAll;
#define TW_OverwriteAll ((APTR) &_TW_OverwriteAll)

#endif /*   !AmiFTP_CAT_H  */
@


1.795
log
@Stuff.
@
text
@d360 2
@


1.720
log
@Select by pattern added.
DLPath()-function added to save some bytes (200 :).
@
text
@d342 18
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d336 6
@


1.630
log
@Added items in the menu to duplicate the buttons.
@
text
@d334 2
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
@d324 10
@


1.531
log
@Lots of stuff
@
text
@d322 2
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
@d314 8
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d284 30
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
@d280 4
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d52 2
a113 2
extern const APTR _MPW_ShowDots;
#define MPW_ShowDots ((APTR) &_MPW_ShowDots)
d146 2
d160 6
d168 2
d208 4
a279 14
extern const APTR _MENU_AddToSiteList;
#define MENU_AddToSiteList ((APTR) &_MENU_AddToSiteList)
extern const APTR _MENU_LogWindow;
#define MENU_LogWindow ((APTR) &_MENU_LogWindow)
extern const APTR _MW_Reload;
#define MW_Reload ((APTR) &_MW_Reload)
extern const APTR _SLW_Sort;
#define SLW_Sort ((APTR) &_SLW_Sort)
extern const APTR _CW_SendingLogin;
#define CW_SendingLogin ((APTR) &_CW_SendingLogin)
extern const APTR _CW_SendingPassword;
#define CW_SendingPassword ((APTR) &_CW_SendingPassword)
extern const APTR _CW_ChangingDirectory;
#define CW_ChangingDirectory ((APTR) &_CW_ChangingDirectory)
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d270 10
@


0.827
log
@Add Current to sitelist added.
More rtLockWindow()'s
Leeching seems to work, but is not finished yet.
@
text
@d268 2
@


0.685
log
@Links were viewed twice.
Workaround for V39 GTNM_Number/Justification bug.
@
text
@d266 2
@


0.623
log
@Added menuitem TransferMode->Binary/ASCII
@
text
@d264 2
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d98 4
d174 6
@


0.531
log
@Resume transfer added (when getting files).
Get-dir-tree is broken.
@
text
@d98 4
d150 4
a241 4
extern const APTR _TW_DownloadDir;
#define TW_DownloadDir ((APTR) &_TW_DownloadDir)
extern const APTR _TW_GetDir;
#define TW_GetDir ((APTR) &_TW_GetDir)
d244 10
@


0.425
log
@Add Settingsmenu with Load/Save settings.
Added Edit hostlist to the settingsmenu.
Changed the search order for the prefs-file.
@
text
@d234 6
@


0.371
log
@Localized source.
@
text
@d40 2
a149 4
extern const APTR _MENU_Preferences;
#define MENU_Preferences ((APTR) &_MENU_Preferences)
extern const APTR _MENU_SavePrefs;
#define MENU_SavePrefs ((APTR) &_MENU_SavePrefs)
d174 12
d232 2
@
