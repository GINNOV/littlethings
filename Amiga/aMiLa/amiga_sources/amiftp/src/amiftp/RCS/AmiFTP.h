head	1.815;
access;
symbols;
locks
	lilja:1.815
	lilja:0.667; strict;
comment	@ * @;


1.815
date	96.12.14.12.13.03;	author lilja;	state Exp;
branches;
next	1.798;

1.798
date	96.11.06.19.32.54;	author lilja;	state Exp;
branches;
next	1.795;

1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.736;

1.736
date	96.08.17.18.17.57;	author lilja;	state Exp;
branches;
next	1.730;

1.730
date	96.08.02.21.57.32;	author lilja;	state Exp;
branches;
next	1.720;

1.720
date	96.07.27.23.43.40;	author lilja;	state Exp;
branches;
next	1.710;

1.710
date	96.07.25.00.21.30;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.630;

1.630
date	96.07.07.20.10.48;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.585;

1.585
date	96.06.13.00.03.21;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.430;

1.430
date	96.04.14.13.21.26;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	1.265;

1.265
date	96.03.08.18.01.38;	author lilja;	state Exp;
branches;
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.150;

1.150
date	96.02.11.16.38.55;	author lilja;	state Exp;
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
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	0.774;

0.774
date	95.10.07.00.18.25;	author lilja;	state Exp;
branches;
next	0.728;

0.728
date	95.09.30.10.27.47;	author lilja;	state Exp;
branches;
next	0.685;

0.685
date	95.09.22.20.13.06;	author lilja;	state Exp;
branches;
next	0.671;

0.671
date	95.09.20.10.15.33;	author lilja;	state Exp;
branches;
next	0.667;

0.667
date	95.09.18.10.34.24;	author lilja;	state Exp;
branches;
next	0.647;

0.647
date	95.09.16.21.18.38;	author lilja;	state Exp;
branches;
next	0.623;

0.623
date	95.09.16.10.54.30;	author lilja;	state Exp;
branches;
next	0.567;

0.567
date	95.09.11.17.15.13;	author lilja;	state Exp;
branches;
next	0.544;

0.544
date	95.09.08.14.11.28;	author lilja;	state Exp;
branches;
next	0.536;

0.536
date	95.09.05.17.59.01;	author lilja;	state Exp;
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
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
branches;
next	0.326;

0.326
date	95.06.13.12.52.15;	author lilja;	state Exp;
branches;
next	0.322;

0.322
date	95.06.12.23.14.26;	author lilja;	state Exp;
branches;
next	0.312;

0.312
date	95.06.09.18.13.36;	author lilja;	state Exp;
branches;
next	0.305;

0.305
date	95.06.08.16.45.30;	author lilja;	state Exp;
branches;
next	0.303;

0.303
date	95.06.08.15.30.02;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Main includefile
@


1.815
log
@Fixed the proxy-port settings.
Replaced % with @@ since the proxy actually seems to work with other
ftpproxies.
Fixed the Height/Width save-problem.
@
text
@/* RCS Id:  $Id: AmiFTP.h 1.798 1996/11/06 19:32:54 lilja Exp lilja $
   Locked version: $Revision: 1.798 $
*/

#ifndef AS225
#define BSDSOCKET_H

#include <signal.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/errno.h>
#include <arpa/ftp.h>
#include <arpa/inet.h>
#include <arpa/telnet.h>
#include <fcntl.h>
#include <pwd.h>
#include <netdb.h>
#include <errno.h>
#include <syslog.h>
#include <unistd.h>
extern struct Library *SocketBase;

#endif

#include <dirent.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <time.h>

#include <dos.h>
#include <ios1.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <clib/rexxsyslib_protos.h>
#include <rexx/storage.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>
#include <prefs/prefhdr.h>
#include <dos/dos.h>
#include <dos/rdargs.h>
#include <dos/dostags.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <libraries/asl.h>
#include <libraries/reqtools.h>
#include <libraries/iffparse.h>
#include <libraries/amigaguide.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>
#include <graphics/rpattr.h>
#include <exec/types.h>
#include <exec/devices.h>
#include <exec/memory.h>
#include <utility/hooks.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/asl_protos.h>
#include <clib/reqtools_protos.h>
#include <clib/icon_protos.h>
#include <clib/wb_protos.h>
#include <clib/alib_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/amigaguide_protos.h>
#include <string.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/asl_pragmas.h>
#include <pragmas/reqtools.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <pragmas/amigaguide_pragmas.h>

#include <wb2cli.h>
#include <clib/asyncio_protos.h>
#include "dh1:tcp/tcphook/tcphooks.h"
#include <lists.h>
#include "dirlist_struct.h"
#include "AmiFTP_Cat.h"

#define USE_PROTOTYPES 1

#define FTP_PASSTHRU_PORT 4666
#define FTP_PORT 21

#define	BINARY  0
#define	ASCII   1
#define	TENEX   2
#define GadgetTextLength(port,gadget) TextLength((port),gadget.ng_GadgetText,gadstrlen(gadget.ng_GadgetText))

#define	PERMS		1
#define	LINKS		2
#define	USER		3
#define	GROUP		4
#define	SIZE		5
#define	MONTH		6
#define	DAY		7
#define	TIME		8
#define	NAME		9
#define	SKIP		10
#define	NONUNIX		11
#define	LOWERNAME	12
#define	MAXTOKENS	12

/* for multiple directory formats */
/* must match strings in create_other.c */
#define	REMOTE_OS_UNIX	0
#define	REMOTE_OS_VMS	1
#define	REMOTE_OS_DOS	2
#define	REMOTE_OS_OTHER	3

#define MB_DISCONNECTED 0
#define MB_NONESELECTED 1
#define MB_FILESELECTED 2

#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif

struct MainPrefs {
    char       *mp_LocalDir;
    char       *mp_AnonymousPW;
    char       *mp_LoginName;
    char       *mp_DefaultSite;
    char       *mp_ProxyServer;
    char       *mp_ViewCommand;
    char       *mp_HideADTPattern;
#if 0
    int         mp_Showdotfiles:1;
    int         mp_ProxyPort:16;
    int         mp_DefaultProxy:1;
    int         mp_IgnoreCase:1;
    int         mp_Cookie:8;
    int         mp_CacheSize:4;
    int         mp_ShowAllADTFiles:1;
    int         mp_PreserveAminetDir:1;
    int         mp_DeleteFiles:1;
    int         mp_DisplayBeep:1;
    int         mp_ShowMOTD:1;
    int         mp_GetReadme:1;
    int         mp_ShowButtons:1;
    int         mp_ShowToolBar:1;
    int         mp_UseDefaultFonts:1;
    int         mp_OpenOnDefaultScreen:1;
    int         mp_unused:27;
#else
    char        mp_Showdotfiles;
    int         mp_ProxyPort;
    char        mp_DefaultProxy;
    char        mp_IgnoreCase;
    int         mp_Cookie;
    char        mp_CacheSize;
    char        mp_ShowAllADTFiles;
    char        mp_PreserveAminetDir;
    char        mp_DeleteFiles;
    char        mp_DisplayBeep;
    char        mp_ShowMOTD;
    char        mp_GetReadme;
    char        mp_ShowButtons;
    char        mp_ShowToolBar;
    char        mp_UseDefaultFonts;
    char        mp_OpenOnDefaultScreen;
//    int         mp_unused:27;
#endif
    int         mp_BufferSize;
    int         mp_SortMode;
    ULONG       mp_LastAminetDate;
    ULONG       mp_LastAMOTD;
    WORD        mp_LeftEdge;
    WORD        mp_TopEdge;
    WORD        mp_Width;
    WORD        mp_Height;
    WORD        mp_SLLeftEdge;
    WORD        mp_SLTopEdge;
    WORD        mp_SLWidth;
    WORD        mp_SLHeight;
    char       *mp_FontName;
    UWORD       mp_FontSize;
    char       *mp_ListFontName;
    UWORD       mp_ListFontSize;
    char       *mp_PubScreen;
};

enum {SLN_REGULAR,SLN_PARENT,SLN_CHILD,SLN_BARLABEL};

struct SiteNode {
    struct Node sn_Node;
    ULONG       sn_Flags;
#if 0
    int         sn_VMSDIR:3;
    int         sn_Port:16;
    int         sn_Proxy:1;
    int         sn_HotList:1;
    int         sn_Anonymous:1;
    int         sn_MenuType:2;
    int         sn_ShowChildren:1;
    int         sn_BarLabel:1;
    int         sn_ADT:1;
    int         sn_unused:5;
#else
    char        sn_VMSDIR;
    int         sn_Port;
    char        sn_Proxy;
    char        sn_HotList;
    char        sn_Anonymous;
    char        sn_MenuType;
    char        sn_ShowChildren;
    char        sn_BarLabel;
    char        sn_ADT;
//    char        sn_unused:5;
#endif
    char       *sn_RemoteDir;
    char       *sn_LocalDir;
    char       *sn_DirString;
    char       *sn_LoginName;
    char       *sn_SiteAddress;
    char       *sn_Password;
};

#define TEMPLATE "SITE,PUBSCREEN/K,FONT/K,FILEFONT/K,DEBUG/S,ICONIFIED/S,PORTNAME/K,SETTINGS/K,AS225/S"
enum {OPT_SITE=0,OPT_SCREEN,OPT_FONT,OPT_FILEFONT,OPT_DEBUG,
	OPT_ICONIFIED,OPT_PORTNAME,OPT_CONFIG,OPT_AS225,OPT_COUNT};
struct CLIArguments {
    char *site;
    char *pubscreen;
    char *propfontname;
    char *fixedfontname;
    long debug;
    long iconified;
    char *portname;
    char *settings;
    long as225;
};

struct CurrentState {
    char ScreenName[256];
    char CurrentDLDir[256];
    char LastLVSite[60];
    char CurrentSite[50];
    char CurrentRemoteDir[MAXPATHLEN+1];
    char PropFontName[256];
    char FixedFontName[256];
    char LoginName[30];
    char Password[30];
    char RexxPort[50];
    int Proxy;
    int PropFontSize;
    int FixedFontSize;
    int Port;
    int Iconified;
    int ADTMode;
    WORD LeftEdge;
    WORD TopEdge;
    WORD Height;
    WORD Width;
    struct TextFont *PropFont;
    struct TextFont *FixedFont;
};
    
struct CacheNode {
    struct Node cn_Node;
    struct List *dirlist;
};

struct CallBackHook {
    int (*cbh_func)(struct MenuItem *);
    LONG cbh_aguide;
};

struct AGInfo {
    AMIGAGUIDECONTEXT ag_AmigaGuide;
    struct NewAmigaGuide ag_NAG;
    LONG ag_region;
};
extern struct AGInfo ag;
extern ULONG AG_Signal;
enum {AG_MAIN,
	AG_MENUCONNECT, AG_MENUDISCONNECT,
	AG_MENURECONNECT,AG_MENUADDTOSITELIST,AG_MENURESETADT,AG_MENUICONIFY,
	AG_MENUABOUT,
	AG_MENUQUIT,AG_MENUTAGALL,AG_MENUUNTAGALL, AG_MENUPATTERN,
	AG_MENUTRANSFERMODE,
	AG_MENUCLEARCACHE,AG_MENUDELETE,AG_MENUPARENT, AG_MENUPUT,AG_MENUGET,
	AG_MENUVIEW, AG_MENUVIEWREADME,
	AG_MENUSORT,AG_MENUGLOBAL,AG_MENUSITELIST,
	AG_MENULOGWINDOW,AG_MENUTOGGLEDOT,AG_MENUTOGGLEADT,AG_MENULOADSETTINGS,
	AG_MENUSAVESETTINGS,AG_MENUHOTLIST,AG_MAINWIN,AG_GLOBPREFS,AG_SITELIST,
	AG_SITECONF,AG_TRANSWIN,AG_CONNECTWIN,AG_ABOUTWIN
      };

/* Returncodes from lower level transfer routines */
enum {TRSF_OK=0, TRSF_FAILED, TRSF_ABORTED, TRSF_BADFILE, TRSF_INITCONN};

/* Returncodes from DownloadFile/UploadFile */
enum {TRANS_OK=0,TRANS_GUI,TRANS_ABORTED,TRANS_ERROR};

/* Returncodes from ConnectSite */
enum {CONN_OK=0,CONN_GUI,CONN_ERROR, CONN_ABORTED};

extern LONG opts[];
extern struct RDArgs *argsptr;
extern struct CurrentState CurrentState;
extern struct MainPrefs MainPrefs;
extern struct List SiteList;
extern struct Node *GetPred(struct Node *);
extern struct Node *GetTail(struct List *);
extern struct   sockaddr_in data_addr;
extern struct sockaddr_in myctladdr;
extern int      connected;
extern int      timedout;
extern int      non_unix;
extern int      code;
extern int      data;
extern int      remote_os_type;
extern int      which_up_cmd;
extern int      SortMode;
extern int      remote_sort_direction;
extern int      current_year;
extern int      current_month;
extern int      cpend;
extern int      curtype;
extern int      crflag;
extern int      verbose;
extern int      sendport;

extern BOOL     SilentMode;

extern int      cin,cout;

extern int      ftp_port;

extern BOOL    DEBUG;
extern BOOL    TCPStack;

#define	MAXLINE 1024
#define UNIX_DIR_PATTERN "PERMS LINKS USER GROUP SIZE MONTH DAY TIME NAME"

extern char	response_line[MAXLINE];
extern char	scratch[1024 + 1024 + 10];
extern char    *header_name;
extern char    *unix_dir_pattern;
extern char    *other_dir_pattern;
extern char    *defaultanonymouspw;
extern BOOL     ConfigChanged;
extern struct TextAttr *AmiFTPAttrF;
extern struct TextAttr *ListViewAttrF;
extern struct TextFont *PropFont;
extern struct TextFont *LBFont;

extern struct IntuitionBase    *IntuitionBase;
extern struct Library          *UtilityBase;
extern struct GfxBase          *GfxBase;
extern struct Library          *DiskfontBase;
extern struct ReqToolsBase     *ReqToolsBase;
extern struct Library          *AslBase;
extern struct Library          *IFFParseBase;
extern struct IconBase         *IconBase;
extern struct RexxLib          *RexxSysBase;
extern struct WorkbenchBase    *WorkbenchBase;
extern struct Library          *LocaleBase;
extern struct Library          *AmigaGuideBase;
extern struct Library           *TimerBase;

extern struct MsgPort *RexxPort;
extern struct MsgPort *TimerPort;
extern struct MsgPort *AppPort;

extern struct Hook IDCMPHook;
extern struct timerequest *TimeRequest;
extern struct List *FileList;
extern struct List TempList;
extern struct Window *MainWindow;
extern BOOL MenuNeedsUpdate;
extern int TransferMode;

/* sprintf.c */

void Sprintf(char *, const char *, ...);

/* main.c */

void MyOpenLibs(void);
void CleanUp(void);

/* misc.c */

extern BPTR LogWindow;
void OpenLogWindow(void);
void CloseLogWindow(void);
void LogMessage(char *mess, char c);
int sgetc(const int sock);
char *ftp_error(char ch, char *def);
void timeout_disconnect(void);
void quit_ftp(void);
void close_files(void);
int ping_server(void);
char *linkname(char *);
struct Node *AddLBNTail(struct List *list, struct SiteNode *sn);
int strecmp(const char *s1, const char *s2);
void FixSiteList(void);
int DLPath(Object *winobject, char *initialpath, char *newpath);

/* ftp.c */

int ftp_hookup(char *host,short port);
int ftp_login(char *user,char *pass, char *acct);
int command(char *fmt,...);
int command_dataconn(FILE **a_file,char *lmode, char *fmt,...);
int getreply(const int expecteof);
int empty(fd_set *mask, const int sec);
void lostpeer(void);
char *next_remote_line(const int sin);
char *parse_hostname(const char *host,int *port);
void settype(const int type);
void close_remote_ls(const int sin);
int open_remote_ls(const int nlst);
int initconn(void);
int dataconn(void);
void abort_remote(const int din);
int recvrequest(char *cmd,char *local,char *remote,char *lmode,ULONG restartpoint);
int sendrequest(char *cmd, char *local, char *remote);

/* dofuncs.c */

int doconnect(struct SiteNode *sn);
int openhost(char *ftphost,char *login,char *password,char *account,short port,int useproxy);

/* change_dir.c */

int change_remote_dir(char *s,int force);
int checkdir(char *dirname);
int up_one_level(void);
int delete_remote(char *name, const char *delcmd);

/* readdir.c */

struct List *read_remote_dir(void);

/* dirlist.c */
struct dirlist *new_direntry(char *name, char *date, char *owner,
			     char *group, mode_t mode, size_t size);
BOOL add_direntry(struct List *filelist, char *name, char *date,
		  char *owner, char *group, mode_t mode, size_t size, int sort_mode,
		  int sort_direction);
void add_direntry_struct(struct List *filelist,
			 struct dirlist *dlist, int sort_mode, int sort_direction);
void free_dirlist(struct List *filelist);
void free_direntry(struct dirlist *tmp);
struct dirlist *sortupbyname(struct List *filelist, char *name,int dir);
struct dirlist *sortupbydate(struct List *filelist, char *date);
struct dirlist *sortupbysize(struct List *filelist, size_t size);
struct dirlist *sortdownbyname(struct List *filelist, char *name, int dir);
struct dirlist *sortdownbydate(struct List *filelist, char *date);
struct dirlist *sortdownbysize(struct List *filelist, size_t size);
struct List *sort_filelist(struct List *old_filelist,int sort_mode,
			   int sort_direction);
void hour_time(char *date, struct tm *tm);
void year_time(char *date, struct tm *tm);
long datetotime(char *date);
int isearlier(char *date1, char *date2);

/* config.c */
BOOL WriteConfigFile(char *filename);
BOOL ReadConfigFile(char *filename);
void FreeSiteNode(struct SiteNode *sn);
void FreeSiteList(struct List *list);

/* ftpwin.c */

void ftpWindow(void);
char *GetPassword(char *user,char *passbuf);
int Parent_clicked(void);
int Reload_clicked(void);
int Reconnect(void);
int File_clicked(void);
int Get_clicked(void);
int DLPath_clicked(void);
int Put_clicked(void);
int Connect_clicked(void);
int Disconnect_clicked(void);
int View_clicked(BOOL Readme);
int Site_clicked(void);
int Dir_clicked(void);
void RemoteCDFailed(void);
void __stdargs ShowErrorReq(char *str,...);
char *GetPassword(char *user,char *passbuf);
int About(void);
int SavePrefs(void);
int SavePrefsAs(void);
int LoadPrefs(void);
void ViewFile(const char *file);
char *NameToReadme(char *foo, int readmelen);

/* MainWindow.c */
void UpdateMainButtons(const int state);
ULONG HandleMainWindowIDCMP(const BOOL);
void CloseMainWindow(void);
void AttachToolList(const BOOL NoneSelected);
void DetachToolList(void);
void UpdateRemoteDir(const char *dir);
void UpdateLocalDir(const char *dir);
void UpdateSiteName(const char *site);
void ChangeAmiFTPMode(void);

void LockWindow(Object *win);
void UnlockWindow(Object *win);
void UpdateWindowTitle(void);

/* connect_gui.c */

int ConnectSite(struct SiteNode *sn, const BOOL noscan);
void PrintConnectStatus(char *text);
ULONG HandleConnectIDCMP(void);

/* dl_gui.c */

int DownloadFile(struct List *flist, const char *name, const int binary,
		 const int move);
int UploadFile(struct List *transferlist, const char *remote, const int binary);
void UpdateDLGads(const long bytes, const long restart, const time_t timee);
BOOL CheckExists(char *lfile,int size, ULONG *restartpoint);
int get_file(char *name, char *localname, int size);
int get_dir(char *remote_parent, char *local_parent, char *name, char *localname);
ULONG HandleTransferIDCMP(void);
void SetTransferSize(const long size);

/* pref_gui.c */

int OpenPrefsWindow(void);
ULONG HandleMainPrefsIDCMP(void);

/* site_gui.c */

struct SiteNode *OpenSiteListWindow(const BOOL Connect);
ULONG HandleEditSiteIDCMP(void);
ULONG HandleSiteListIDCMP(void);

/* rexx.c */
int HandleRexxMsg(void);

/* cache.c */

void InitCache(void);
void ClearCache(BOOL all);
void RemoveCacheEntry(char *dirname);
void FreeCacheEntry(struct CacheNode *cnode);
void AddCacheEntry(struct List *dirlist, char *name);
struct List *LookupCache(char *name);

/* locale.c */

void SetupLocaleStrings(void);

/* AGuide.c */

int HandleAmigaGuide(void);
int SendAGMessage(LONG ContextNumber);

/* ADT.c */

struct List *ReadRecentList(void);
struct List *sort_ADT(struct List *list, int type);

/* Menu.c */

int BuildMenu(void);
void UpdateMenus(void);

/* SpeedBar.c */

void InitSpeedBarList(void);
void FreeSpeedBarList(void);
int HandleSpeedBar(int button);
void UpdateSpeedBar(int state);
@


1.798
log
@Fixed init of AmigaGuide.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.795 1996/09/28 13:32:58 lilja Exp lilja $
   Locked version: $Revision: 1.795 $
d145 1
d163 19
d206 1
d217 12
@


1.795
log
@Stuff.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.736 1996/08/17 18:17:57 lilja Exp lilja $
   Locked version: $Revision: 1.736 $
d359 4
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.730 1996/08/02 21:57:32 lilja Exp lilja $
   Locked version: $Revision: 1.730 $
d160 2
a161 1
    int         mp_unused:28;
d267 2
a268 1
	AG_MENUCLEARCACHE,AG_MENUDELETE,AG_MENUPUT,AG_MENUGET,AG_MENUVIEW,
@


1.730
log
@AmiFTP starts even if no TCP/IP-stack is running.
No 'please insert inet:...' when starting.
Still has to fix the ARexx stuff to cope with no stack running.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.720 1996/07/27 23:43:40 lilja Exp lilja $
   Locked version: $Revision: 1.720 $
d177 1
@


1.720
log
@Select by pattern added.
DLPath()-function added to save some bytes (200 :).
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.710 1996/07/25 00:21:30 lilja Exp lilja $
   Locked version: $Revision: 1.710 $
d314 1
@


1.710
log
@Fontprefs seems to work ok, except in PrefsWindow.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
d377 1
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.630 1996/07/07 20:10:48 lilja Exp lilja $
   Locked version: $Revision: 1.630 $
d159 2
a160 1
    int         mp_unused:29;
d173 4
@


1.630
log
@Added items in the menu to duplicate the buttons.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AmiFTP.h 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d157 3
a159 1
    int         mp_unused:31;
d258 2
a259 1
	AG_MENUQUIT,AG_MENUTAGALL,AG_MENUUNTAGALL, AG_MENUTRANSFERMODE,
d411 1
a411 1
	char *group, mode_t mode, size_t size);
d413 2
a414 2
	char *owner, char *group, mode_t mode, size_t size, int sort_mode,
	int sort_direction);
d416 1
a416 1
	struct dirlist *dlist, int sort_mode, int sort_direction);
d426 1
a426 1
	int sort_direction);
d429 1
a429 1
long	datetotime(char *date);
d538 7
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: ftpwin.h 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d253 1
d257 2
a258 1
	AG_MENUCLEARCACHE,AG_MENUDELETE,AG_MENUSORT,AG_MENUGLOBAL,AG_MENUSITELIST,
d443 1
a443 1
int Get_Clicked(void);
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id:  $Id$
   Locked version: $Revision$
d42 1
d44 1
d59 3
d91 1
d459 1
a459 1
/* gui.c */
a467 8
int menu_Quit(void);
int menu_SortByName(struct MenuItem *menuitem);
int menu_SortByDate(struct MenuItem *menuitem);
int menu_SelectAll(void);
int menu_UnselectAll(void);
int menu_Delete(void);
int menu_Move(void);
void UpdateMenus(void);
d482 2
a483 1
int DownloadFile(struct List *flist, const char *name, const int binary, const int move);
d528 5
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
@d1 4
@


1.531
log
@Lots of stuff
@
text
@d84 1
a97 1

a265 2
extern struct Node *GetSucc(struct Node *);
extern struct Node *GetHead(struct List *);
d470 1
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d146 2
d149 1
d259 1
a259 1
enum {CONN_OK=0,CONN_GUI,CONN_ERROR};
d279 1
a279 1
extern int      remote_sort_mode;
d449 1
d461 2
a462 2
int menu_SortByName(void);
int menu_SortByDate(void);
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
@d228 1
a228 1
    int (*cbh_func)();
a268 10
extern int      data;
extern int      abrtflag;
extern int      verbose;
extern int      debug;
extern int      code;
extern int      cpend;
extern int      curtype;
extern int      crflag;
extern int      runique;
extern int      sendport;
d271 4
a277 3
extern int      non_unix;
extern int      remote_os_type;
extern int      ignore_case;
d280 6
a285 2
extern int      abort_transfer;
extern int      unique_local_names;
d291 1
a291 1
extern int      ftp_passthru_port;
d355 1
d521 1
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d143 4
d148 1
d240 7
a246 4
	AG_MENURECONNECT,AG_MENUADDTOSITELIST,AG_MENUICONIFY,AG_MENUABOUT,AG_MENUQUIT,AG_MENUTAGALL,AG_MENUUNTAGALL,
	AG_MENUTRANSFERMODE,AG_MENUCLEARCACHE,AG_MENUDELETE,AG_MENUSORT,AG_MENUGLOBAL,
	AG_MENUSITELIST,AG_MENULOGWINDOW,AG_MENUTOGGLEDOT,AG_MENULOADSETTINGS,AG_MENUSAVESETTINGS,AG_MENUHOTLIST,
	AG_MAINWIN,AG_GLOBPREFS,AG_SITELIST,AG_SITECONF,AG_TRANSWIN,AG_CONNECTWIN,AG_ABOUTWIN
a357 1
long gadstrlen(char *text);
a389 1
char *expand_dirname(char *arg);
a395 10
int parse_line(struct List *filelist,char *line,int *temp_non_unix);
int parse_line_ls(struct List *filelist,char *line);
int parse_line_pattern(struct List *filelist,char *pattern,char *line,int *temp_non_unix);
int parse_line_vms(struct List *filelist,char *line,int *temp_non_unix);
int parse_line_dos(struct List *filelist,char *line,int *temp_non_unix);
char *dir_parse_to_pattern(char *dir_parse);
int unix_perms(char *s,int *temp_non_unix);
int vms_perms(char *s,int *temp_non_unix);
int vms_perms_set(char *s);
int vms_filetype(char *s);
d439 1
a439 1
int View_clicked(void);
a452 5
char FindVanillaKey(char *gadtext);
ULONG MatchVanillaKey(unsigned char key,char *array);
void StripIntuiMessages(struct MsgPort *mp, struct Window *win);
void ComputeMinSize(UWORD *,UWORD *);
BOOL LayoutElements(struct Gadget **,UWORD,UWORD);
a469 2
int Layout(struct Gadget **gadg,struct Window *window,struct NewGadget *gadgets,ULONG *tags,ULONG *kinds,struct Gadget **ngadgets, int numgadgets);

a474 2
int Layout_connect(struct Gadget **,struct Window *);
void ComputeSize_connect(UWORD *,UWORD *);
a480 2
int Layout_dl(struct Gadget **,struct Window *);
void ComputeSize_dl(UWORD *minwidth,UWORD *minheight);
a491 2
int Layout_pr(struct Gadget **,struct Window *);
void ComputeSize_pr(UWORD *minwidth,UWORD *minheight);
a503 2
void stackch(void);

d524 1
a524 1
struct List *read_recent_list(void);
@


1.200
log
@GETATTR-hit fixed.
@
text
@d134 1
d141 3
a143 1
    int         mp_unused:1;
d153 3
d164 5
a168 2
    int         sn_SubItem:1;
    int         sn_unused:9;
d208 1
d477 1
d540 4
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d145 4
d329 5
a340 4
extern BPTR LogWindow;
void OpenLogWindow(void);
void CloseLogWindow(void);
void LogMessage(char *mess,char c);
d342 1
d350 2
a351 2
int getreply(int expecteof);
int empty(fd_set *mask,int sec);
d353 1
a353 1
char *next_remote_line(int sin);
d355 3
a357 3
void settype(int type);
void close_remote_ls(int sin);
int open_remote_ls(int nlst);
d359 2
a360 2
int dataconn(char *lmode);
void abort_remote(int din);
d414 1
a414 1
/* iff.c */
d418 1
d428 1
a428 1
int Get_Clicked();
d443 1
d446 1
a446 1
void UpdateMainButtons(int state);
d452 1
a452 1
ULONG HandleMainWindowIDCMP(BOOL);
d454 1
a454 2
void UpdateMainButtons(int state);
void AttachToolList(BOOL NoneSelected);
d456 3
a458 3
void UpdateRemoteDir(char *dir);
void UpdateLocalDir(char *dir);
void UpdateSiteName(char *site);
d466 1
d477 1
a477 1
int ConnectSite(struct SiteNode *sn, BOOL noscan);
d485 3
a487 3
int DownloadFile(struct List *flist, char *name,int binary, int move);
int UploadFile(struct List *transferlist,char *remote, int binary);
void UpdateDLGads(long bytes,long restart,time_t timee);
d492 1
d503 1
a503 1
struct SiteNode *OpenSiteListWindow(BOOL Connect);
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
@a17 5
//#include <proto/socket.h>
//#include <clib/netlib_protos.h>
//#include <proto/usergroup.h>
//#include <pragmas/usergroup_pragmas.h>
#include "dh1:tcp/tcphook/tcphooks.h"
a19 27
#else /* AS225 */
#include <sys/types.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netdb.h>
#include <netinet/in_systm.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <errno.h>
#include <unistd.h>
#include <ss/socket.h>
#include <signal.h>
/* Some things that AS225 is missing */
#include "network:amitcp-3.0b2/netinclude/arpa/ftp.h"

#if defined(__SASC) && defined(S_IFMT)
#undef S_IFMT
#undef S_IFDIR
#undef S_IFREG
#undef S_ISCRIPT
#undef S_IPURE
#undef S_IARCHIVE
#undef S_IREAD
#undef S_IWRITE
#undef S_IEXECUTE
#undef S_IDELETE
a21 46
#define	S_ISUID	0004000		/* set user id on execution */
#define	S_ISGID	0002000		/* set group id on execution */
#define	S_ISVTX	0001000		/* save swapped text even after use */

#define	S_IRWXU	0000700		/* RWX mask for owner */
#define	S_IRUSR	0000400		/* R for owner */
#define	S_IWUSR	0000200		/* W for owner */
#define	S_IXUSR	0000100		/* X for owner */

#define	S_IREAD		S_IRUSR
#define	S_IWRITE	S_IWUSR
#define	S_IEXEC		S_IXUSR

#define	S_IRWXG	0000070		/* RWX mask for group */
#define	S_IRGRP	0000040		/* R for group */
#define	S_IWGRP	0000020		/* W for group */
#define	S_IXGRP	0000010		/* X for group */

#define	S_IRWXO	0000007		/* RWX mask for other */
#define	S_IROTH	0000004		/* R for other */
#define	S_IWOTH	0000002		/* W for other */
#define	S_IXOTH	0000001		/* X for other */

#define	S_IFMT	 0170000	/* type of file */
#define	S_IFCHR	 0020000	/* character special */
#define	S_IFDIR	 0040000	/* directory */
#define	S_IFBLK	 0060000	/* block special */
#define	S_IFREG	 0100000	/* regular */
#define	S_IFLNK	 0120000	/* symbolic link */
#define	S_IFSOCK 0140000	/* socket */
#define	S_IFIFO	 0010000	/* named pipe (fifo) */

#define S_BLKSIZE	512	/* block size used in the stat struct */

#define	S_ISDIR(m)	((m & 0170000) == 0040000)	/* directory */
#define	S_ISCHR(m)	((m & 0170000) == 0020000)	/* char special */
#define	S_ISBLK(m)	((m & 0170000) == 0060000)	/* block special */
#define	S_ISREG(m)	((m & 0170000) == 0100000)	/* regular file */
#define	S_ISLNK(m)	((m & 0170000) == 0120000)	/* symbolic link */
#define	S_ISFIFO(m)	((m & 0170000) == 0010000)	/* fifo */
#define	S_ISSOCK(m)	((m & 0170000) == 0140000)	/* socket */

extern struct Library *SockBase;

#endif /* AS225 */

a30 1
//#include "dh1:tcp/ncftp-1.5.6/src/amiga/s_socket.h"
a270 1
#ifdef SOCKIO
a271 4
#else
extern FILE    *commandfp;
extern FILE    *responsefp;
#endif
a292 1
//extern struct Library          *GadToolsBase;
a346 1
#ifdef SOCKIO
a347 3
#else
char *next_remote_line(FILE *din);
#endif
a349 1
#ifdef SOCKIO
a350 5
#else
void close_remote_ls(FILE *din);
#endif

#ifdef SOCKIO
a351 3
#else
FILE *open_remote_ls(int nlst);
#endif
a352 1
#ifdef SOCKIO
a353 4
#else
FILE *dataconn(char *lmode);
#endif
#ifdef SOCKIO
a354 3
#else
void abort_remote(FILE *din);
#endif
d421 1
a421 1
int __asm __saveds Get_Clicked(register __a0 Object *obj, register __a1 struct IntuiMessage *msg);
d461 3
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d18 6
a23 4
#include <proto/socket.h>
#include <clib/netlib_protos.h>
#include <proto/usergroup.h>
#include <pragmas/usergroup_pragmas.h>
d162 1
a162 1

d243 3
a245 3
#define TEMPLATE "SITE,PUBSCREEN/K,PROPFONTNAME/K,PROPFONTSIZE/K/N,FIXEDFONTNAME/K,FIXEDFONTSIZE/K/N,DEBUG/S,ICONIFIED/S,PORTNAME/K,SETTINGS/K"
enum {OPT_SITE=0,OPT_SCREEN,OPT_PROPFONTNAME,OPT_PROPFONTSIZE,OPT_FIXEDFONTNAME,OPT_FIXEDFONTSIZE,OPT_DEBUG,
	OPT_ICONIFIED,OPT_PORTNAME,OPT_CONFIG,OPT_COUNT};
a249 1
    long *propfontsize;
a250 1
    long *fixedfontsize;
d255 1
d278 2
d302 1
a302 1
	AG_MENUSITELIST,AG_MENULOGWINDOW,AG_MENULOADSETTINGS,AG_MENUSAVESETTINGS,AG_MENUHOTLIST,
a323 1
extern struct   sockaddr_in hisctladdr;
d348 1
d371 4
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d216 2
a217 1
    int         mp_unused:5;
d231 2
a232 1
    int         sn_unused:10;
d300 1
a300 1
	AG_MAINWIN,AG_GLOBPREFS,AG_SITELIST,AG_SITECONF,AG_TRANSWIN,AG_CONNECTWIN
a367 1
extern BOOL     V39;
d370 1
a370 1
extern struct Library          *GadToolsBase;
d382 1
d385 5
d392 1
d398 1
a398 1
void OpenLibs(void);
d414 1
d517 1
d520 1
a520 1
int Get_clicked(void);
d543 2
a544 3
int OpenFTPWindow(void);
int HandleFTPIDCMP(void);
int CloseFTPWindow(void);
d546 1
a546 1
void AttachToolList(void);
a547 1
void RefreshWinGad(void);
d567 1
d579 1
d586 1
a589 1
int OpenSiteWindow(struct SiteNode *sn);
d591 2
@


0.827
log
@Add Current to sitelist added.
More rtLockWindow()'s
Leeching seems to work, but is not finished yet.
@
text
@d297 1
a297 1
	AG_MENUSITELIST,AG_MENULOADSETTINGS,AG_MENUSAVESETTINGS,AG_MENUHOTLIST,
d402 4
@


0.814
log
@Added default download-dir.
@
text
@d295 1
a295 1
	AG_MENURECONNECT,AG_MENUICONIFY,AG_MENUABOUT,AG_MENUQUIT,AG_MENUTAGALL,AG_MENUUNTAGALL,
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d562 1
a562 1
void UpdateDLGadgs(long bytes,long restart,time_t timee);
d595 5
@


0.774
log
@Now handles filenames up to 128 chars, atleast in DownloadFile().
@
text
@d126 1
d143 1
d157 1
d282 19
d380 1
@


0.728
log
@Save settings also saves the window position.
@
text
@d239 12
@


0.685
log
@Links were viewed twice.
Workaround for V39 GTNM_Number/Justification bug.
@
text
@d214 4
@


0.671
log
@"View" on links downloaded it twice.
@
text
@d156 1
a156 1
#include "dh1:ndk/examples/asynchio/asyncio.h"
@


0.667
log
@Datatransferred was updated one time too much.
@
text
@d263 1
d265 6
@


0.647
log
@Release version, small things fixed.
@
text
@d245 1
@


0.623
log
@Added menuitem TransferMode->Binary/ASCII
@
text
@d232 3
a234 10
#define TEMPLATE "SITE,PUBSCREEN/K,FONTNAME/K,FONTSIZE/K/N,DEBUG/S,ICONIFIED/S,PORTNAME/K,SETTINGS/K"
#define OPT_SITE       0
#define OPT_SCREEN     1
#define OPT_FONTNAME   2
#define OPT_FONTSIZE   3
#define OPT_DEBUG      4
#define OPT_ICONIFIED  5
#define OPT_PORTNAME   6
#define OPT_CONFIG     7
#define OPT_COUNT      8
d242 2
a243 1
    char FontName[256];
d247 2
a248 1
    int FontSize;
@


0.567
log
@Fixed busy loop caused by badly timed SetMenuStrip() (In the NextSelect-loop)
@
text
@d344 1
d520 1
a520 1
void UpdateDLGadgs(long bytes,time_t timee);
@


0.544
log
@Added gadstrlen() and macro GadgetTextLength() to compute correct strings with _ in labels.
Checks if CTRL-C has been hit before opening window.
@
text
@d343 1
@


0.536
log
@SETTIINGS-tooltype/cli argument now works again.
@
text
@d169 1
d357 1
@


0.531
log
@Resume transfer added (when getting files).
Get-dir-tree is broken.
@
text
@d24 1
a27 1
#include <netinet/in.h>
d30 1
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d394 1
a394 1
int recvrequest(char *cmd,char *local,char *remote,char *lmode);
d516 1
a516 1
BOOL CheckExists(char *lfile,int size);
@


0.425
log
@Add Settingsmenu with Load/Save settings.
Added Edit hostlist to the settingsmenu.
Changed the search order for the prefs-file.
@
text
@d210 2
a211 1
    int         mp_unused:13;
d220 2
a221 1
    int         sn_unused:11;
d230 1
a230 1
#define TEMPLATE "SITE,PUBSCREEN/K,FONTNAME/K,FONTSIZE/K/N,DEBUG/S,ICONIFIED/S,PORTNAME/K"
d238 2
a239 1
#define OPT_COUNT      7
d513 1
a513 1
int DownloadFile(struct dirlist *curr,char *name,struct List *flist, int binary, int move);
d517 2
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d469 2
d524 1
a524 1
struct SiteNode *OpenSiteListWindow(void);
@


0.371
log
@Localized source.
@
text
@d391 2
a392 2
int recvrequest(char *cmd,char *local,char *remote,char *lmode,int size,BOOL *aborted);
int sendrequest(char *cmd, char *local, char *remote, int size, int *aborted);
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d158 1
d333 2
d537 4
@


0.326
log
@Links are now parsed to linkname and (link)
Upload via ARexx should be finished now
@
text
@d18 4
d35 60
a106 4
#include <proto/socket.h>
#include <clib/netlib_protos.h>
#include <proto/usergroup.h>
#include <pragmas/usergroup_pragmas.h>
d113 1
d124 1
d139 2
d153 1
d194 1
d196 1
@


0.322
log
@Dir-cache added.
Delete added.
@
text
@d439 1
a439 1
int Uploadfile(struct List *transferlist);
@


0.312
log
@Changed the prototype for UploadFile().
@
text
@d189 5
d423 2
d438 1
a438 1
int DownloadFile(struct dirlist *curr,char *name,struct List *flist, int binary);
d458 9
@


0.305
log
@Added some casts to avoid compiler warnings
@
text
@d432 1
a432 1
int Uploadfile(void);
@


0.303
log
@Changed CurrentState to support size/pos.
@
text
@d276 1
@


0.284
log
@First RCS version.
@
text
@d183 4
d329 1
d410 1
a410 1
void UpdateSiteNam1e(char *site);
d414 3
@
