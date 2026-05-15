/* RCS Id:  $Id: AmiFTP.h 1.815 1996/12/14 12:13:03 lilja Exp lilja $
   Locked version: $Revision: 1.815 $
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
    char       *mp_LogFile;
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
    char        mp_Log;
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
    char        sn_VMSDIR;
    int         sn_Port;
    char        sn_Proxy;
    char        sn_HotList;
    char        sn_Anonymous;
    char        sn_MenuType;
    char        sn_ShowChildren;
    char        sn_BarLabel;
    char        sn_ADT;
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
    char LogFile[256];
    char Log;
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
	AG_MENURECONNECT, AG_MENURAWCOMMAND, AG_MENUADDTOSITELIST, AG_MENURESETADT, AG_MENUICONIFY,
	AG_MENUABOUT,
	AG_MENUQUIT, AG_MENUTAGALL, AG_MENUUNTAGALL, AG_MENUPATTERN,
	AG_MENUTRANSFERMODE,
	AG_MENUCLEARCACHE, AG_MENUPARENT, AG_MENUPUT, AG_MENUGET,
	AG_MENUVIEW, AG_MENUVIEWREADME, AG_MENUCREATEDIR, AG_MENUDELETE,
	AG_MENURENAME,
	AG_MENUSORT, AG_MENUGLOBAL, AG_MENUSITELIST,
	AG_MENULOGWINDOW, AG_MENUTOGGLEDOT, AG_MENUTOGGLEADT, AG_MENULOADSETTINGS,
	AG_MENUSAVESETTINGS, AG_MENUHOTLIST, AG_MAINWIN, AG_GLOBPREFS, AG_SITELIST,
	AG_SITECONF, AG_TRANSWIN, AG_CONNECTWIN, AG_ABOUTWIN
      };

/* Returncodes from lower level transfer routines */
enum {TRSF_OK=0, TRSF_FAILED, TRSF_ABORTED, TRSF_BADFILE, TRSF_INITCONN};

/* Returncodes from DownloadFile/UploadFile */
enum {TRANS_OK=0, TRANS_GUI, TRANS_ABORTED, TRANS_ERROR};

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
