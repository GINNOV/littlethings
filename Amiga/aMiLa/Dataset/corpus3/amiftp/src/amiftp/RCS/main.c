head	1.802;
access;
symbols;
locks
	lilja:1.802; strict;
comment	@ * @;


1.802
date	96.11.30.13.15.06;	author lilja;	state Exp;
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
next	1.710;

1.710
date	96.07.25.00.21.30;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.595;

1.595
date	96.06.18.23.19.14;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.586;

1.586
date	96.06.13.11.07.48;	author lilja;	state Exp;
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
next	0.1343;

0.1343
date	96.01.20.17.34.39;	author lilja;	state Exp;
branches;
next	0.1332;

0.1332
date	95.12.17.13.21.38;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.863;

0.863
date	95.10.28.17.17.56;	author lilja;	state Exp;
branches;
next	0.857;

0.857
date	95.10.24.18.41.14;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	0.774;

0.774
date	95.10.07.00.18.25;	author lilja;	state Exp;
branches;
next	0.765;

0.765
date	95.10.01.17.57.28;	author lilja;	state Exp;
branches;
next	0.723;

0.723
date	95.09.29.16.48.36;	author lilja;	state Exp;
branches;
next	0.710;

0.710
date	95.09.24.18.20.34;	author lilja;	state Exp;
branches;
next	0.647;

0.647
date	95.09.16.21.18.38;	author lilja;	state Exp;
branches;
next	0.588;

0.588
date	95.09.12.16.24.08;	author lilja;	state Exp;
branches;
next	0.563;

0.563
date	95.09.10.20.59.20;	author lilja;	state Exp;
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
next	0.347;

0.347
date	95.06.16.09.38.24;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
branches;
next	0.322;

0.322
date	95.06.12.23.14.26;	author lilja;	state Exp;
branches;
next	0.305;

0.305
date	95.06.08.16.45.30;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Main entry for AmiFTP, open/close libraries etc.
@


1.802
log
@DLDir-func is no longer called via UserData, it's called from the
main event-switch. This seems to have solved the problem with
some setups.
@
text
@/* RCS Id:  $Id: main.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
*/

#include "AmiFTP.h"
#include "gui.h"

extern struct TextAttr AmiFTPAttr,ListViewAttr;
extern Object *ARexx_Object;

BOOL InitRexx(void);
void PrintSiteList(void);
void GetToolTypes(struct WBStartup *msg);
void SetupLocaleStrings(void);
void ConvertFontName(char *dest, int *size, char *source);

extern struct Screen *myScn;

long __stack=16384;
extern struct WBStartup *_WBenchMsg;
extern STRPTR _ProgramName;

char *ConfigName;
char *AMIFTPPREFS="AmiFTP.prefs";
char *PROGDIRPREFS="PROGDIR:AmiFTP.prefs";
char *ENVPREFS="ENVARC:AmiFTP.prefs";

BOOL DEBUG=FALSE;
BOOL TCPStack=FALSE;

struct MsgPort *AppPort;

struct CLIArguments *cliargs=NULL;
extern STRPTR context[];
int CXBRK(){return 0;}
void chkabort(void){return;}

char *ErrorOpenLib="Couldn't open version %ld of %s.";
char *ErrorNoPort="Couldn't open messageport.";

void PrintError(const STRPTR errmsg, ...)
{
    ULONG *args=((ULONG *)&errmsg)+1;
    struct EasyStruct req= {
	sizeof(struct EasyStruct), 0, NULL, NULL, NULL};

    if (_WBenchMsg && IntuitionBase) {
	req.es_Title="AmiFTP Error";
	req.es_TextFormat=errmsg;
	req.es_GadgetFormat="Ok";
	EasyRequestArgs(NULL, &req, NULL, args);
    }
    else {
	VPrintf(errmsg, args);
	Printf("\n");
    }
}

struct as225passwd {
	char	*pw_name;
	char	*pw_dir;
	char	*pw_passwd;
	char	*pw_gecos;
	uid_t	pw_uid;
	gid_t	pw_gid;
	char	*pw_shell;		/* unused */
	char	*pw_comment;
};

BOOL UseAS225=FALSE;
static struct Process *ME;

int main(int argc, char **argv)
{
    struct servent *servent;
    APTR oldwptr;

    if (!ButtonBase)
      return 10;

    if (!PenMapBase)
      return 10;

    if (!DOSBase)
      return 10;

    ME=(struct Process *)FindTask(NULL);
    oldwptr=ME->pr_WindowPtr;

    MyOpenLibs();

    ag.ag_NAG.nag_BaseName="AmiFTP";
    ag.ag_NAG.nag_Name="AmiFTP.guide";
    ag.ag_NAG.nag_ClientPort="AMIFTP_HELP";
    ag.ag_NAG.nag_Context=context;

    MainPrefs.mp_ViewCommand=strdup("MultiView %F");
    MainPrefs.mp_CacheSize=5;
    MainPrefs.mp_BufferSize=8192;
    MainPrefs.mp_DeleteFiles=TRUE;

    if (!argc) {
	WB2CLI(_WBenchMsg, __stack, DOSBase);
	GetToolTypes(_WBenchMsg);
    }
    else {
	argsptr=ReadArgs(TEMPLATE, opts, NULL);
	if (argsptr==NULL) {
	    PrintFault(IoErr(), NULL);
	    CleanUp();
	    exit(1);
	}
	cliargs=(void *)&opts[0];

	if (cliargs->pubscreen)
	  strncpy(CurrentState.ScreenName, (char *)cliargs->pubscreen, 256);
	if (cliargs->iconified)
	  CurrentState.Iconified=1;
	if (cliargs->portname)
	  strncpy(CurrentState.RexxPort, cliargs->portname, 50);
	if (cliargs->settings)
	  ConfigName=strdup((char *)cliargs->settings);

	if (cliargs->debug)
	  DEBUG=TRUE;
	if (cliargs->as225)
	  UseAS225=TRUE;
    }
    if (!strlen(CurrentState.RexxPort)) {
	strcpy(CurrentState.RexxPort, "AMIFTP");
    }

    if (!InitRexx()) {
	CleanUp();
	exit(10);
    }

    /* This has to be here, can't put this in MyOpenLibs() */
    /* Has to check for mlink */
    ME->pr_WindowPtr=-1;
    if (UseAS225==FALSE) {
	if (FindPort("MLINK")) {
	    UseAS225=TRUE;
	}
    }
    TCPStack=OpenTCP(UseAS225);
/*    if (!(TCPStack=OpenTCP(UseAS225))) {
	ME->pr_WindowPtr=oldwptr;
	PrintError("Can't open any TCP/IP-stack\n");
	CleanUp();
	exit(10);
    }*/
    ME->pr_WindowPtr=oldwptr;

    /* FTP inits */
    data = -1;
    verbose = 0;
    code = -1;
    cpend = 0;
    curtype = 0;
    crflag = 1;
    sendport = -1;

    /*
     * Determine port numbers to use
     */
    if (TCPStack) {
	servent = tcp_getservbyname("ftp", "tcp");
	if (servent != NULL) {
	    ftp_port = servent->s_port;
	} else {
	    ftp_port = htons(FTP_PORT);
	}
    }

    /* Set current_month + current_year so date-sorting works */
    {
	time_t	t;
	struct tm *tm;
	
	t = time((time_t *)NULL);
	tm = localtime(&t);
	current_year = tm->tm_year;
	current_month = tm->tm_mon;
    }

    /* Make sure the lists are initialized */

    NewList(&SiteList);
    NewList(&TempList);

    /* Copy the fontnames if the user specified any */

    if (CurrentState.PropFontSize) {
	AmiFTPAttr.ta_Name=CurrentState.PropFontName;
	AmiFTPAttr.ta_YSize=CurrentState.PropFontSize;
    }
    if (CurrentState.FixedFontSize) {
	ListViewAttr.ta_Name=CurrentState.FixedFontName;
	ListViewAttr.ta_YSize=CurrentState.FixedFontSize;
    }

    if (SetSignal(0L, SIGBREAKF_CTRL_C)&SIGBREAKF_CTRL_C) {
	CleanUp();
	exit(1);
    }
    InitCache();
    {
	struct passwd *pw;
	struct as225passwd *as225pw;
	char dirname[MAXPATHLEN+1];
	char dname[MAXHOSTNAMELEN];
	char *cp;
	BPTR lock;

	defaultanonymouspw=NULL;
	memset(dirname, 0, sizeof(dirname));
	if (TCPStack) {
	    if (SocketBase) {
		if (cp=tcp_getlogin()) {
		    if (pw=tcp_getpwnam(cp)) {
			if (!tcp_gethostname(dname, sizeof(dname))) {
			    sprintf(dirname, "%s@@%s", pw->pw_name?pw->pw_name:"user",
				    dname);
			    defaultanonymouspw=strdup(dirname);
			}
			memset(dirname, 0, sizeof(dirname));
			if (pw->pw_dir)
			  strmfp(dirname, pw->pw_dir, AMIFTPPREFS);
			tcp_endpwent();
		    }
		}
	    }
	    else {
		if (cp=tcp_getlogin()) {
		    if (as225pw=(struct as225passwd *)tcp_getpwnam(cp)) {
			if (!tcp_gethostname(dname, sizeof(dname))) {
			    sprintf(dirname, "%s@@%s", 
				    as225pw->pw_name?as225pw->pw_name:"user", dname);
			    defaultanonymouspw=strdup(dirname);
			}
			memset(dirname, 0, sizeof(dirname));
			if (as225pw->pw_dir)
			  strmfp(dirname, as225pw->pw_dir, AMIFTPPREFS);
			tcp_endpwent();
		    }
		}
	    }
	}
	/*
	  Search order for configfile:
	  SETTINGS-tooltype/cli argument
	  CurrentDir
	  PROGDIR:
	  ENVARC:
	  ~user/AmiFTP.prefs (dirname)
	  and perhaps AmiTCP:db/AmiFTP.prefs
	  */
	if (ConfigName) { /* If ConfigName is set the user told us via tooltypes */
	    if (lock=Lock(ConfigName, ACCESS_READ)) {
		UnLock(lock);
		ReadConfigFile(ConfigName);
	    }
	}
	else {
	    if (lock=Lock(AMIFTPPREFS, ACCESS_READ)) {
		UnLock(lock);
		ConfigName=strdup(AMIFTPPREFS);
		ReadConfigFile(ConfigName);
	    }
	    else if (lock=Lock(PROGDIRPREFS, ACCESS_READ)) {
		UnLock(lock);
		ConfigName=strdup(PROGDIRPREFS);
		ReadConfigFile(ConfigName);
	    }
	    else if (lock=Lock(ENVPREFS, ACCESS_READ)) {
		UnLock(lock);
		ConfigName=strdup(ENVPREFS);
		ReadConfigFile(ConfigName);
	    }
	    else if (dirname[0]) {
		ConfigName=strdup(dirname);
		if (lock=Lock(dirname, ACCESS_READ)) {
		    UnLock(lock);
		    ReadConfigFile(ConfigName);
		}
	    }
	    else ConfigName=strdup(PROGDIRPREFS);
	}
    }

    if (!MainPrefs.mp_AnonymousPW) /* Check for lilja@@tomcat.rydnet.lysator.liu.se */
      MainPrefs.mp_AnonymousPW=defaultanonymouspw;
    else if (!strcmp(MainPrefs.mp_AnonymousPW, "lilja@@tomcat.rydnet.lysator.liu.se")) {
	free(MainPrefs.mp_AnonymousPW);
	MainPrefs.mp_AnonymousPW=defaultanonymouspw;
	ConfigChanged=TRUE;
    }

    if (cliargs->pubscreen) {
	char *a=strdup(cliargs->pubscreen);
	MainPrefs.mp_PubScreen=a;
    }

    ag.ag_NAG.nag_PubScreen=MainPrefs.mp_PubScreen;

    ConfigChanged=FALSE;
    if (DEBUG)
      PrintSiteList();

    if (!CurrentState.ScreenName[0])
      ag.ag_NAG.nag_PubScreen=NULL;

    ftpWindow();

    CloseLogWindow();

    if (ConfigChanged)
      WriteConfigFile(ConfigName);

    {
	struct Node *node;
	while (node=RemHead(&TempList)) {
	    if (MainPrefs.mp_DeleteFiles)
	      DeleteFile(node->ln_Name);
	    free(node->ln_Name);
	    free(node);
	}
    }

    CleanUp();
}

void MyOpenLibs()
{
    char *lib;

    lib="intuition.library";
    IntuitionBase=(struct IntuitionBase *)OpenLibrary(lib, 36);
    if(!IntuitionBase) {
	PrintError(ErrorOpenLib,36, lib);
	CleanUp();
	exit(10);
    }

    LocaleBase=OpenLibrary("locale.library", 38L);

    lib="graphics.library";
    GfxBase=(struct GfxBase *)OpenLibrary(lib, 36);
    if (!GfxBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();	
	exit(10);
    }

    lib="utility.library";
    UtilityBase=OpenLibrary(lib, 36);
    if (!UtilityBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();
	exit(10);
    }

    lib="diskfont.library";
    DiskfontBase=OpenLibrary(lib, 36);
    if (!DiskfontBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();
	exit(10);
    }

    lib="icon.library";
    IconBase = (struct IconBase *)OpenLibrary(lib, 36);
    if (!IconBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();
	exit(10);
    }

    lib="workbench.library";
    WorkbenchBase = (struct WorkbenchBase *)OpenLibrary(lib, 36);
    if (!WorkbenchBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();
	exit(10);
    }

    lib="reqtools.library";
    ReqToolsBase=(struct ReqToolsBase *)OpenLibrary(lib, 38);
    if (!ReqToolsBase) {
	PrintError(ErrorOpenLib, 38, lib);
	CleanUp();
	exit(10);
    }

    lib="asl.library";
    AslBase = OpenLibrary(lib, 36);
    if (!AslBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();
	exit(10);
    }

    lib="iffparse.library";
    IFFParseBase = OpenLibrary(lib, 36);
    if (!IFFParseBase) {
	PrintError(ErrorOpenLib, 36, lib);
	CleanUp();
	exit(10);
    }

    lib="rexxsyslib.library";
    RexxSysBase = (struct RexxLib *)OpenLibrary(lib, 0L);
    if (!RexxSysBase) {
	PrintError(ErrorOpenLib, 0, lib);
	CleanUp();
	exit(10);
    }

    AmigaGuideBase = (struct Library *)OpenLibrary("amigaguide.library", 36);

    AppPort = (struct MsgPort *)CreateMsgPort();
    if (!AppPort) {
	PrintError(ErrorNoPort);
	CleanUp();
	exit(10);
    }

    TimerPort = (struct MsgPort *)CreateMsgPort();
    if (!TimerPort) {
	PrintError(ErrorNoPort);
	CleanUp();
	exit(10);
    }
    if (!(TimeRequest=(struct timerequest *)CreateIORequest(TimerPort,
							    sizeof(struct timerequest)))) {
	PrintError("Couldn't allocate timerreq");
	CleanUp();
	exit(10);
    }

    if (OpenDevice("timer.device", UNIT_VBLANK, TimeRequest, 0)) {
	PrintError("Couldn't open timer.device");
	CleanUp();
	exit(10);
    }

    TimerBase=&TimeRequest->tr_node.io_Device->dd_Library;

    OpenAmiFTPCatalog(NULL, NULL);

    SetupLocaleStrings();
}

void CleanUp()
{
    CloseTCP();

#define FREE(x) if (x) free(x)
    FREE(MainPrefs.mp_LocalDir);
    FREE(MainPrefs.mp_AnonymousPW);
    FREE(MainPrefs.mp_LoginName);
    FREE(MainPrefs.mp_DefaultSite);
    FREE(MainPrefs.mp_ProxyServer);
    FREE(MainPrefs.mp_ViewCommand);
    FREE(MainPrefs.mp_HideADTPattern);
    FREE(MainPrefs.mp_FontName);
    FREE(MainPrefs.mp_ListFontName);
    FREE(MainPrefs.mp_PubScreen);

#undef FREE


    if (TimeRequest) {
	if (TimeRequest->tr_node.io_Device)
	  CloseDevice(TimeRequest);

	DeleteIORequest(TimeRequest);
	TimeRequest=NULL;
    }
    if (TimerPort) {
	DeleteMsgPort(TimerPort);
	TimerPort=NULL;
    }

    if (AmigaGuideBase) {
	if (ag.ag_AmigaGuide)
	  CloseAmigaGuide(ag.ag_AmigaGuide);
	CloseLibrary(AmigaGuideBase);
    }

    CloseAmiFTPCatalog();

    if (LocaleBase)
      CloseLibrary(LocaleBase);

    if (ARexx_Object)
      DisposeObject(ARexx_Object);

    if (AppPort)
      DeleteMsgPort(AppPort);

    if (RexxSysBase)
      CloseLibrary((struct Library *)RexxSysBase);

    if (argsptr) {
      FreeArgs(argsptr);
    }

    if (WorkbenchBase)
      CloseLibrary((struct Library *)WorkbenchBase);

    if (IntuitionBase)
      CloseLibrary((struct Library *)IntuitionBase);

    if (GfxBase)
      CloseLibrary((struct Library *)GfxBase);

    if (UtilityBase)
      CloseLibrary((struct Library *)UtilityBase);

    if (DiskfontBase)
      CloseLibrary((struct Library *)DiskfontBase);

    if (ReqToolsBase)
      CloseLibrary((struct Library *)ReqToolsBase);

    if (AslBase)
      CloseLibrary((struct Library *)AslBase);

    if (IFFParseBase)
      CloseLibrary((struct Library *)IFFParseBase);

    if (IconBase)
      CloseLibrary((struct Library *)IconBase);
}

void PrintSiteList()
{
    struct SiteNode *sn;
    struct Node *lbn;

    for(lbn=ListHead(&SiteList);ListEnd(lbn);lbn=ListNext(lbn)) {
	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData, &sn,
				TAG_DONE);
	if (sn) {
	    Printf("Site: %s\n", sn->sn_Node.ln_Name);
	    Printf("RemoteDir: %s\n", sn->sn_RemoteDir?sn->sn_RemoteDir:"");
	    Printf("LocalDir: %s\n", sn->sn_LocalDir?sn->sn_LocalDir:"");
	    Printf("Loginname: %s\n", sn->sn_LoginName?sn->sn_LoginName:"");
	    Printf("DirString: %s\n", sn->sn_DirString?sn->sn_DirString:"");
	}
    }
}

void GetToolTypes(struct WBStartup *msg)
{
    char *key;

    if(msg->sm_NumArgs!=0) {
	BPTR olddir;
	struct DiskObject *infoobj;
	olddir=CurrentDir(msg->sm_ArgList->wa_Lock);
	if(infoobj=GetDiskObject(msg->sm_ArgList->wa_Name)) {
	    if(key=FindToolType(infoobj->do_ToolTypes, "PUBSCREEN")) {
		strncpy(CurrentState.ScreenName, key, 255);
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes, "ICONIFIED")) {
		CurrentState.Iconified=1;
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes, "PORTNAME")) {
		strncpy(CurrentState.RexxPort, key, 50);
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes, "SETTINGS")) {
		ConfigName=strdup(key);
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes, "AS225")) {
		UseAS225=TRUE;
	    }
	    FreeDiskObject(infoobj);
	}
	CurrentDir(olddir);
    }
}

void ConvertFontName(char *dest, int *size, char *source)
{
    char *ptr;
    if ((ptr=strstr(source, "/"))) {
	*ptr=0;
	ptr++;
	if (*ptr) {
	    if (isdigit(*ptr)) {
		*size=atol(ptr);
		strcpy(dest, source);
	    }
	}
    }
}

/* EOF */
@


1.795
log
@Stuff.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: main.c 1.736 1996/08/17 18:17:57 lilja Exp lilja $
   Locked version: $Revision: 1.736 $
d116 1
a116 1
	  strncpy(CurrentState.ScreenName, (char *)cliargs->pubscreen,256);
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: main.c 1.730 1996/08/02 21:57:32 lilja Exp lilja $
   Locked version: $Revision: 1.730 $
d291 1
d294 5
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
/* RCS Id:  $Id: main.c 1.710 1996/07/25 00:21:30 lilja Exp lilja $
   Locked version: $Revision: 1.710 $
d19 1
a19 1
long __stack=10240;
a95 1
    ag.ag_NAG.nag_PubScreen=CurrentState.ScreenName;
d294 7
d452 16
@


1.710
log
@Fontprefs seems to work ok, except in PrefsWindow.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: main.c 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
d29 2
d46 1
d71 1
d76 1
d87 3
d141 1
d147 3
a149 1
    if (!OpenTCP(UseAS225)) { /* Fix: If no stack available, AmiFTP should still start*/
d153 2
a154 1
    }
d168 7
a174 5
    servent = tcp_getservbyname("ftp", "tcp");
    if (servent != NULL) {
	ftp_port = servent->s_port;
    } else {
	ftp_port = htons(FTP_PORT);
d216 1
d219 13
a231 7
	if (SocketBase) {
	    if (cp=tcp_getlogin()) {
		if (pw=tcp_getpwnam(cp)) {
		    if (!tcp_gethostname(dname, sizeof(dname))) {
			sprintf(dirname, "%s@@%s", pw->pw_name?pw->pw_name:"user",
				dname);
			defaultanonymouspw=strdup(dirname);
a232 4
		    memset(dirname, 0, sizeof(dirname));
		    if (pw->pw_dir)
		      strmfp(dirname, pw->pw_dir, AMIFTPPREFS);
		    tcp_endpwent();
d235 12
a246 8
	}
	else {
	    if (cp=tcp_getlogin()) {
		if (as225pw=(struct as225passwd *)tcp_getpwnam(cp)) {
		    if (!tcp_gethostname(dname, sizeof(dname))) {
			sprintf(dirname, "%s@@%s", 
				as225pw->pw_name?as225pw->pw_name:"user", dname);
			defaultanonymouspw=strdup(dirname);
a247 4
		    memset(dirname, 0, sizeof(dirname));
		    if (as225pw->pw_dir)
		      strmfp(dirname, as225pw->pw_dir, AMIFTPPREFS);
		    tcp_endpwent();
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: main.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
a109 8
	if ( cliargs->propfontname ) {
	    ConvertFontName(CurrentState.PropFontName, &CurrentState.PropFontSize,
			    cliargs->propfontname);
	}
	if (cliargs->fixedfontname) {
	    ConvertFontName(CurrentState.FixedFontName, &CurrentState.FixedFontSize,
			    cliargs->fixedfontname);
	}
a522 8
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes, "FONT")) {
		ConvertFontName(CurrentState.PropFontName, 
				&CurrentState.PropFontSize, (key));
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes, "FILEFONT")) {
		ConvertFontName(CurrentState.FixedFontName,
				&CurrentState.FixedFontSize, (key));
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
/* RCS Id:  $Id: main.c 1.595 1996/06/18 23:19:14 lilja Exp lilja $
   Locked version: $Revision: 1.595 $
d74 3
@


1.595
log
@Fixed something.
,
@
text
@d1 2
a2 2
/* RCS Id:  $Id: main.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d5 1
a5 1
#include "ftpwin.h"
a6 3
#include <exec/devices.h>

#include <wb2cli.h>
d36 2
a37 2
char *ErrorOpenLib="Couldn't open version %ld of %s";
char *ErrorNoPort="Couldn't open messageport";
d74 1
a74 1
      return 5;
d77 1
a77 1
      return 5;
d111 1
a111 1
	if ( cliargs->fixedfontname) {
d143 1
a143 1
    if (!OpenTCP(UseAS225)) {
d280 1
a280 1
    if (!MainPrefs.mp_AnonymousPW)
d296 1
d306 1
d313 1
d323 1
d331 1
d339 1
d347 1
d355 1
d363 1
d371 1
d379 1
d387 1
d404 1
d417 1
d423 1
d425 1
d427 1
d445 1
d451 1
d453 1
d456 1
d459 1
d462 1
d465 1
d469 1
d472 1
d475 1
d478 1
d481 1
d484 1
d487 1
d490 1
d493 1
a568 1

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
d294 1
a294 2
    if (DEBUG)
      kprintf("Closing log-window\n");
a296 2
    if (DEBUG)
      kprintf("Writing config\n");
a298 2
    if (DEBUG)
      kprintf("Deleting files\n");
a307 2
    if (DEBUG)
      kprintf("Cleaning up\n");
@


1.586
log
@quit-bug probably fixed. Moved quit_ftp()-call from main.c to ftpwin.c
right before closing the window.
@
text
@d1 4
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
@a294 5
      kprintf("Disconnecting\n");
    if (connected) {
	quit_ftp();
    }
    if (DEBUG)
@


1.531
log
@Lots of stuff
@
text
@d481 1
a481 1
    for(lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d14 1
a14 1
void ConvertFontName(char *dest,int *size,char *source);
d42 1
a42 1
	sizeof(struct EasyStruct),0,NULL,NULL,NULL};
d47 1
a47 1
	EasyRequestArgs(NULL, &req, NULL,args);
d50 1
a50 1
	VPrintf(errmsg,args);
d92 1
a92 1
	WB2CLI(_WBenchMsg,__stack,DOSBase);
d96 1
a96 1
	argsptr=ReadArgs(TEMPLATE,opts,NULL);
d98 1
a98 1
	    PrintFault(IoErr(),NULL);
d105 1
a105 1
	  strncpy(CurrentState.ScreenName,(char *)cliargs->pubscreen,256);
d107 2
a108 1
	    ConvertFontName(CurrentState.PropFontName,&CurrentState.PropFontSize,cliargs->propfontname);
d111 2
a112 1
	    ConvertFontName(CurrentState.FixedFontName,&CurrentState.FixedFontSize,cliargs->fixedfontname);
d117 1
a117 1
	  strncpy(CurrentState.RexxPort,cliargs->portname,50);
d127 1
a127 1
	strcpy(CurrentState.RexxPort,"AMIFTP");
d194 1
a194 1
    if (SetSignal(0L,SIGBREAKF_CTRL_C)&SIGBREAKF_CTRL_C) {
d207 1
a207 1
	memset(dirname,0,sizeof(dirname));
d211 3
a213 2
		    if (!tcp_gethostname(dname,sizeof(dname))) {
			sprintf(dirname,"%s@@%s",pw->pw_name?pw->pw_name:"user",dname);
d216 1
a216 1
		    memset(dirname,0,sizeof(dirname));
d218 1
a218 1
		      strmfp(dirname,pw->pw_dir,AMIFTPPREFS);
d226 3
a228 2
		    if (!tcp_gethostname(dname,sizeof(dname))) {
			sprintf(dirname,"%s@@%s",as225pw->pw_name?as225pw->pw_name:"user",dname);
d231 1
a231 1
		    memset(dirname,0,sizeof(dirname));
d233 1
a233 1
		      strmfp(dirname,as225pw->pw_dir,AMIFTPPREFS);
d248 1
a248 1
	    if (lock=Lock(ConfigName,ACCESS_READ)) {
d254 1
a254 1
	    if (lock=Lock(AMIFTPPREFS,ACCESS_READ)) {
d259 1
a259 1
	    else if (lock=Lock(PROGDIRPREFS,ACCESS_READ)) {
d264 1
a264 1
	    else if (lock=Lock(ENVPREFS,ACCESS_READ)) {
d271 1
a271 1
		if (lock=Lock(dirname,ACCESS_READ)) {
d290 2
d294 2
d299 2
d303 2
d314 2
d323 1
a323 1
    IntuitionBase=(struct IntuitionBase *)OpenLibrary(lib,36);
d325 1
a325 1
	PrintError(ErrorOpenLib,36,lib);
d330 1
a330 1
    LocaleBase=OpenLibrary("locale.library",38L);
d332 1
a332 1
    GfxBase=(struct GfxBase *)OpenLibrary(lib,36);
d334 1
a334 1
	PrintError(ErrorOpenLib,36,lib);
d339 1
a339 1
    UtilityBase=OpenLibrary(lib,36);
d341 1
a341 1
	PrintError(ErrorOpenLib,36,lib);
d346 1
a346 1
    DiskfontBase=OpenLibrary(lib,36);
d348 1
a348 1
	PrintError(ErrorOpenLib,36,lib);
d353 1
a353 1
    IconBase = (struct IconBase *)OpenLibrary(lib,36);
d355 1
a355 1
	PrintError(ErrorOpenLib,36,lib);
d360 1
a360 1
    WorkbenchBase = (struct WorkbenchBase *)OpenLibrary(lib,36);
d362 1
a362 1
	PrintError(ErrorOpenLib,36,lib);
d367 1
a367 1
    ReqToolsBase=(struct ReqToolsBase *)OpenLibrary(lib,38);
d369 1
a369 1
	PrintError(ErrorOpenLib,38,lib);
d374 1
a374 1
    AslBase = OpenLibrary(lib,36);
d376 1
a376 1
	PrintError(ErrorOpenLib,36,lib);
d381 1
a381 1
    IFFParseBase = OpenLibrary(lib,36);
d383 1
a383 1
	PrintError(ErrorOpenLib,36,lib);
d388 1
a388 1
    RexxSysBase = (struct RexxLib *)OpenLibrary(lib,0L);
d390 1
a390 1
	PrintError(ErrorOpenLib,0,lib);
d395 1
a395 1
    AmigaGuideBase = (struct Library *)OpenLibrary("amigaguide.library",36);
d409 2
a410 1
    if (!(TimeRequest=(struct timerequest *)CreateIORequest(TimerPort,sizeof(struct timerequest)))) {
d415 1
a415 1
    if (OpenDevice("timer.device",UNIT_VBLANK,TimeRequest,0)) {
d421 1
a421 1
    OpenAmiFTPCatalog(NULL,NULL);
d486 5
a490 5
	    Printf("Site: %s\n",sn->sn_Node.ln_Name);
	    Printf("RemoteDir: %s\n",sn->sn_RemoteDir?sn->sn_RemoteDir:"");
	    Printf("LocalDir: %s\n",sn->sn_LocalDir?sn->sn_LocalDir:"");
	    Printf("Loginname: %s\n",sn->sn_LoginName?sn->sn_LoginName:"");
	    Printf("DirString: %s\n",sn->sn_DirString?sn->sn_DirString:"");
d504 2
a505 5
	    if(key=FindToolType(infoobj->do_ToolTypes,"PUBSCREEN")) {
		strncpy(CurrentState.ScreenName,key,255);
	    }
	    if (key=FindToolType(infoobj->do_ToolTypes,"FONT")) {
		ConvertFontName(CurrentState.PropFontName,&CurrentState.PropFontSize,(key));
d507 7
a513 2
	    if (key=FindToolType(infoobj->do_ToolTypes,"FILEFONT")) {
		ConvertFontName(CurrentState.FixedFontName,&CurrentState.FixedFontSize,(key));
d515 1
a515 1
	    if (key=FindToolType(infoobj->do_ToolTypes,"ICONIFIED")) {
d518 2
a519 2
	    if (key=FindToolType(infoobj->do_ToolTypes,"PORTNAME")) {
		strncpy(CurrentState.RexxPort,key,50);
d521 1
a521 1
	    if (key=FindToolType(infoobj->do_ToolTypes,"SETTINGS")) {
d524 1
a524 1
	    if (key=FindToolType(infoobj->do_ToolTypes,"AS225")) {
d533 1
a533 1
void ConvertFontName(char *dest,int *size,char *source)
d536 1
a536 1
    if ((ptr=strstr(source,"/"))) {
d542 1
a542 1
		strcpy(dest,source);
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
@a7 1
extern STRPTR _ProgramName;
d9 1
d11 4
d17 1
d19 3
a26 1
void PrintSiteList(void);
a27 3
extern void stackchinit(void);
extern void stackquit(void);
extern struct WBStartup *_WBenchMsg;
a28 2
void GetToolTypes(struct WBStartup *msg);
extern void SetupLocaleStrings(void);
a33 1
void ConvertFontName(char *dest,int *size,char *source);
a147 1
    abrtflag = 0;
a148 1
    debug = 0;
a152 1
    runique = 0;
d164 1
a164 6
    servent = tcp_getservbyname("ftp-passthru", "tcp");
    if (servent != NULL) {
	ftp_passthru_port = servent->s_port;
    } else {
	ftp_passthru_port = htons(FTP_PASSTHRU_PORT);
    }
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d86 4
d140 1
a140 1
	Printf("Can't open any TCP/IP-stack\n");
d303 2
a304 1
	    DeleteFile(node->ln_Name);
@


1.200
log
@GETATTR-hit fixed.
@
text
@d129 6
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d30 1
a30 1
int CXBRK(){return(0);}
d34 2
d37 1
a37 1
void PrintError(long ver,char *error)
d39 13
a51 1
    Printf("Couldn't open version %ld of %s\n",ver,error);
d72 1
a72 1
      return(5);
a153 2
	Printf( "Couldn't find 'ftp' service. Using %ld.\n",
	       FTP_PORT);
d219 1
a219 1
		if (as225pw=tcp_getpwnam(cp)) {
d300 1
a300 1
#define COOPEN(x) Printf("Couldn't open %s\n",x)
d307 1
a307 1
	PrintError(36,lib);
d316 1
a316 1
	PrintError(36,lib);
d323 1
a323 1
	PrintError(36,lib);
d330 1
a330 1
	PrintError(36,lib);
d337 1
a337 1
	PrintError(36,lib);
d344 1
a344 1
	PrintError(36,lib);
d351 1
a351 1
	PrintError(38,lib);
d358 1
a358 1
	PrintError(36,lib);
d365 1
a365 1
	PrintError(36,lib);
d372 1
a372 1
	PrintError(0,lib);
d381 1
a381 1
	Printf("Couldn't create messageport\n");
d387 1
a387 1
	Printf("Couldn't create messageport\n");
d392 1
a392 1
	COOPEN("timerreq");
d397 1
a397 1
	COOPEN("timer.device");
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
@a5 5
#ifdef AS225
#include <pwd.h>
//static void *unit;

#endif
a11 1
//extern struct VisualInfo *myVisualInfo;
d120 1
a120 26
#if 0
    {
	int i=1;
	char portname[30];
	struct MsgPort *port;
	Forbid();
	port=FindPort(CurrentState.RexxPort);
	Permit();
	if (port) {
	    for (i=1;i<100;i++) {
		sprintf(portname,"%s.%ld",CurrentState.RexxPort,i);
		Forbid();
		port=FindPort(portname);
		Permit();
		if (!port)
		  break;
	    }
	    strcpy(CurrentState.RexxPort,portname);
	}
	RexxPort = (struct MsgPort *)CreatePort(CurrentState.RexxPort,0);
	if (!RexxPort) {
	    CleanUp();
	    exit(10);
	}
    }
#endif
a167 1
#if 1
a171 1
#endif
d176 1
a291 46
/*    lib="dos.library";
    DOSBase=(struct DosLibrary *)OpenLibrary(lib,36);
    if (!DOSBase) {
	CleanUp();
	exit(10);
    }*/
#if 0
    lib="bsdsocket.library";
    Printf("SocketBase=%lx\n",SocketBase);
    SocketBase=OpenLibrary(lib,2);
    if (!SocketBase) {
	PrintError(2,lib);
	CleanUp();
	exit(10);
    }
    else {
	lib=USERGROUPNAME;
	UserGroupBase=OpenLibrary(lib,1);
	if (!UserGroupBase) {
	    PrintError(1,lib);
	    CleanUp();
	    exit(10);
	}
	else {
	    if (ug_SetupContextTags(_ProgramName,
				    UGT_INTRMASK, SIGBREAKB_CTRL_C,
				    UGT_ERRNOPTR(sizeof(errno)), &errno,
				    TAG_END)!= 0)
	      {
		  Printf("Can't initialize usergroup.library\n");
		  CleanUp();
		  exit(10);
	      }
	}
    }
#ifdef AS225
    lib="inet:libs/socket.library";
    SockBase = OpenLibrary(lib, 4L);
    if (!SockBase) {
	PrintError(4,lib);
	CleanUp();
	exit(10);
    }
    setup_sockets(6,&errno);
#endif
#endif
a389 16
#ifdef AS225
//    unit=dtimer.tr_node.io_Unit;
#endif
#if 0
    {
	struct timerequest dtimer={0};
	if (!OpenDevice("timer.device",UNIT_VBLANK,(struct IORequest *)&dtimer,0L)) {
	    TimerBase=dtimer.tr_node.io_Device;
	    unit=dtimer.tr_node.io_Unit;
	}
	else {
	    CleanUp();
	    exit(10);
	}
    }
#endif
a395 15
#if 0
#ifdef AS225
    if (SockBase) {
	cleanup_sockets();
	CloseLibrary(SockBase);
    }
#else
    if (SocketBase) {
	CloseLibrary(SocketBase);
    }
    if (UserGroupBase) {
	CloseLibrary(UserGroupBase);
    }
#endif
#endif
a417 4
#if 0
    if (RexxPort)
      DeletePort(RexxPort);
#endif
a440 2
/*    if (DOSBase)
      CloseLibrary((struct Library *)DOSBase);*/
@


0.1343
log
@Removed some redudant things from AllocListbrowserNode()
Gadgets no longer flicker since I keep track of the state. Thought ClassAct did that, but no...
Added one tick to the fuelgauge, now 11 ticks => 10 intervals.
@
text
@d12 4
a15 2
//extern struct Font *Propdfont;
//extern struct Font *NonPropdfont;
d38 2
d46 13
d62 1
a62 3
/*    printf("pling\n");
    fflush(stdout);
    Delay(30);*/
d66 3
d93 5
a97 7
	if ( (cliargs->propfontname) && (cliargs->propfontsize)) {
	    strncpy(CurrentState.PropFontName,(char *)cliargs->propfontname,256);
	    CurrentState.PropFontSize=*cliargs->propfontsize;
	}
	if ( (cliargs->fixedfontname) && (cliargs->fixedfontsize)) {
	    strncpy(CurrentState.FixedFontName,(char *)cliargs->fixedfontname,256);
	    CurrentState.FixedFontSize=*cliargs->fixedfontsize;
d108 2
d114 13
d151 1
d167 1
a167 1
    servent = getservbyname("ftp", "tcp");
d175 1
a175 1
    servent = getservbyname("ftp-passthru", "tcp");
d191 3
d196 13
d216 1
d223 25
a247 5
	if (cp=getlogin()) {
	    if (pw=getpwnam(cp)) {
		if (!gethostname(dname,sizeof(dname))) {
		    sprintf(dirname,"%s@@%s",pw->pw_name,dname);
		    defaultanonymouspw=strdup(dirname);
a248 3
		memset(dirname,0,sizeof(dirname));
		strmfp(dirname,pw->pw_dir,AMIFTPPREFS);
		endpwent();
a249 1

d324 1
a324 1
    lib="dos.library";
d329 7
a335 5
    }
    lib="intuition.library";
    IntuitionBase=(struct IntuitionBase *)OpenLibrary(lib,36);
    if(!IntuitionBase) {
	PrintError(36,lib);
d339 20
d369 9
d490 1
d496 8
d505 1
a521 6
#if 0
    if (NonPropdfont)
      CloseFont(NonPropdfont);
    if (Propdfont)
      CloseFont(Propdfont);
#endif
d525 3
d530 1
d554 2
a555 2
    if (DOSBase)
      CloseLibrary((struct Library *)DOSBase);
d591 2
a592 7
	    if (key=FindToolType(infoobj->do_ToolTypes,"PROPFONTSIZE")) {
		CurrentState.PropFontSize=atol(key);
		if (key=FindToolType(infoobj->do_ToolTypes,"PROPFONTNAME")) {
		    strncpy(CurrentState.PropFontName,key,256);
		}
		else
		  CurrentState.PropFontSize=0;
d594 2
a595 7
	    if (key=FindToolType(infoobj->do_ToolTypes,"FIXEDFONTSIZE")) {
		CurrentState.FixedFontSize=atol(key);
		if (key=FindToolType(infoobj->do_ToolTypes,"FIXEDFONTNAME")) {
		    strncpy(CurrentState.FixedFontName,key,256);
		}
		else
		  CurrentState.FixedFontSize=0;
d606 3
d614 16
@


0.1332
log
@Release 1.0
AmiFTP doesn't need amigaguide.library in order to start.
@
text
@d37 5
d255 1
a255 1

d258 3
a260 1
    DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",36);
d265 7
d273 2
a274 1
    SockBase = OpenLibrary("inet:libs/socket.library", 4L);
d276 1
d283 2
a284 11
    IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",36);
    if(!IntuitionBase) {
	CleanUp();
	exit(10);
    }
/*    GadToolsBase=OpenLibrary("gadtools.library",39);
    if (!GadToolsBase) {
	CleanUp();
	exit(10);
    }*/
    GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0);
d286 1
d290 2
a291 1
    UtilityBase=OpenLibrary("utility.library",0);
d293 1
d297 2
a298 1
    DiskfontBase=OpenLibrary("diskfont.library",0);
d300 1
d304 2
a305 1
    IconBase = (struct IconBase *)OpenLibrary("icon.library",36);
d307 1
d311 2
a312 1
    WorkbenchBase = (struct WorkbenchBase *)OpenLibrary("workbench.library",36);
d314 1
d318 2
a319 1
    ReqToolsBase=(struct ReqToolsBase *)OpenLibrary("reqtools.library",38);
d321 1
a321 1
	Printf("Couldn't open reqtools.library\n");
d325 2
a326 1
    AslBase = OpenLibrary("asl.library",36);
d328 1
d332 2
a333 1
    IFFParseBase = OpenLibrary("iffparse.library",36);
d335 1
d339 2
a340 1
    RexxSysBase = (struct RexxLib *)OpenLibrary("rexxsyslib.library",0L);
d342 1
a342 1
	Printf("Couldn't open rexxsyslib.library\n");
d346 1
d348 1
a348 5
/*    if (!AmigaGuideBase) {
	Printf("Couldn't open amigaguide.library\n");
	CleanUp();
	exit(10);
    }*/
d362 1
d367 1
a441 2
/*    if (GadToolsBase)
      CloseLibrary((struct Library *)GadToolsBase);*/
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d21 1
a21 1
char *ENVPREFS="ENV:AmiFTP.prefs";
d34 2
d186 1
a186 1
	  ENV:
d304 1
d320 1
d325 2
a326 1
    if (!AmigaGuideBase) {
d329 1
a329 1
    }
d332 1
d338 1
@


0.863
log
@Releaseversion (maybe)
@
text
@d2 3
d8 1
a8 2
struct Device *TimerBase=0L;
static void *unit;
d12 2
a13 2
extern struct Font *Propdfont;
extern struct Font *NonPropdfont;
d15 1
a15 1
extern struct VisualInfo *myVisualInfo;
a21 1
BOOL V40;
d38 5
d44 1
a44 1
    OpenLibs();
d51 1
a51 8
    if (GfxBase->LibNode.lib_Version>=39)
      V39=TRUE;
    else
      V39=FALSE;
    if (GfxBase->LibNode.lib_Version==39)
      V40=FALSE;
    else
      V40=TRUE;
d156 1
a156 1
	exit();
d249 1
a249 1
void OpenLibs()
d257 1
a257 1
    SockBase = OpenLibrary("socket.library", 4L);
d265 1
a265 1
    IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0);
d270 1
a270 1
    GadToolsBase=OpenLibrary("gadtools.library",39);
d274 1
a274 1
    }
d320 1
a320 1
    AmigaGuideBase = (struct Library *)OpenLibrary("amigaguide.library",39);
d330 14
d345 3
d371 11
a381 7
    {
	struct timerequest dtimer={0};
	if (TimerBase) {
	    dtimer.tr_node.io_Device=TimerBase;
	    dtimer.tr_node.io_Unit=unit;
	    CloseDevice((struct IORequest *)&dtimer);
	}
a382 1
#endif
d388 1
d393 1
d414 2
a415 2
    if (GadToolsBase)
      CloseLibrary((struct Library *)GadToolsBase);
d433 13
a445 6
    for(sn=(struct SiteNode *)GetHead(&SiteList);sn;sn=(struct SiteNode *)GetSucc((struct Node *)sn)) {
	Printf("Site: %s\n",sn->sn_Node.ln_Name);
	Printf("RemoteDir: %s\n",sn->sn_RemoteDir?sn->sn_RemoteDir:"");
	Printf("LocalDir: %s\n",sn->sn_LocalDir?sn->sn_LocalDir:"");
	Printf("Loginname: %s\n",sn->sn_LoginName?sn->sn_LoginName:"");
	Printf("DirString: %s\n",sn->sn_DirString?sn->sn_DirString:"");
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d228 3
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d229 1
@


0.774
log
@Now handles filenames up to 128 chars, atleast in DownloadFile().
@
text
@d32 1
d40 5
d317 5
d360 5
@


0.765
log
@FIXEDFONTNAME/SIZE should work now. Accidentally copied the PROPNAME/SIZE
@
text
@d31 2
d59 11
a69 9
	if (opts[OPT_SCREEN])
	  strncpy(CurrentState.ScreenName,(char *)opts[OPT_SCREEN],256);
	if ( (opts[OPT_PROPFONTNAME]) && (opts[OPT_PROPFONTSIZE])) {
	    strncpy(CurrentState.PropFontName,(char *)opts[OPT_PROPFONTNAME],256);
	    CurrentState.PropFontSize=*(long *)opts[OPT_PROPFONTSIZE];
	}
	if ( (opts[OPT_FIXEDFONTNAME]) && (opts[OPT_FIXEDFONTSIZE])) {
	    strncpy(CurrentState.FixedFontName,(char *)opts[OPT_FIXEDFONTNAME],256);
	    CurrentState.FixedFontSize=*(long *)opts[OPT_FIXEDFONTSIZE];
d71 1
a71 1
	if (opts[OPT_ICONIFIED])
d73 4
a76 4
	if (opts[OPT_PORTNAME])
	  strncpy(CurrentState.RexxPort,opts[OPT_PORTNAME],50);
	if (opts[OPT_CONFIG])
	  ConfigName=strdup((char *)opts[OPT_CONFIG]);
d78 1
a78 1
	if (opts[OPT_DEBUG])
d221 1
a221 2
//    stackchinit();
//    stackch();
d223 1
a223 1
//    stackquit();
a334 2
/*    if (WBenchLock)
      CurrentDir(WBenchLock);*/
@


0.723
log
@AmiFTP adds .i if the ARexx-port is present.
@
text
@d64 2
a65 2
	    strncpy(CurrentState.FixedFontName,(char *)opts[OPT_PROPFONTNAME],256);
	    CurrentState.FixedFontSize=*(long *)opts[OPT_PROPFONTSIZE];
@


0.710
log
@Transfer Window now looks good on both V39 and V40.
@
text
@d80 24
d211 3
a304 5
	CleanUp();
	exit(10);
    }
    RexxPort = (struct MsgPort *)CreatePort(CurrentState.RexxPort,0);
    if (!RexxPort) {
@


0.647
log
@Release version, small things fixed.
@
text
@d20 1
d41 4
@


0.588
log
@The GUI now handles proportional fonts. Only the main listview is fixed font.
@
text
@d11 2
d54 7
a60 3
	if ( (opts[OPT_FONTNAME]) && (opts[OPT_FONTSIZE])) {
	    strncpy(CurrentState.FontName,(char *)opts[OPT_FONTNAME],256);
	    CurrentState.FontSize=opts[OPT_FONTSIZE];
d321 4
d385 12
a396 4
	    if (key=FindToolType(infoobj->do_ToolTypes,"FONTSIZE")) {
		CurrentState.FontSize=atol(key);
		if (key=FindToolType(infoobj->do_ToolTypes,"FONTNAME")) {
		    CurrentState.FontSize=atol(key);
d399 1
a399 1
		  CurrentState.FontSize=0;
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d10 1
a10 1
extern struct Font *dfont;
@


0.544
log
@Added gadstrlen() and macro GadgetTextLength() to compute correct strings with _ in labels.
Checks if CTRL-C has been hit before opening window.
@
text
@d99 9
a107 9
  {
      time_t	t;
      struct tm *tm;

      t = time((time_t *)NULL);
      tm = localtime(&t);
      current_year = tm->tm_year;
      current_month = tm->tm_mon;
  }
d129 1
d167 1
a169 1
		    ConfigName=strdup(dirname);
d212 1
a212 1
    setup_sockets(2,&errno);
@


0.536
log
@SETTIINGS-tooltype/cli argument now works again.
@
text
@d38 1
d43 7
a49 8
    argsptr=ReadArgs(TEMPLATE,opts,NULL);
    if (argsptr==NULL) {
	PrintFault(IoErr(),NULL);
	CleanUp();
	exit(1);
    }
    MainPrefs.mp_ViewCommand=strdup("MultiView %F");
    if (argc) {
d110 4
@


0.531
log
@Resume transfer added (when getting files).
Get-dir-tree is broken.
@
text
@d139 7
a145 1
	if (!ConfigName) { /* If ConfigName is set the user told us via tooltypes */
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d98 4
d103 5
@


0.425
log
@Add Settingsmenu with Load/Save settings.
Added Edit hostlist to the settingsmenu.
Changed the search order for the prefs-file.
@
text
@d60 3
a62 1
	
d130 12
a141 17
	if (lock=Lock(AMIFTPPREFS,ACCESS_READ)) {
	    UnLock(lock);
	    ConfigName=strdup(AMIFTPPREFS);
	    ReadConfigFile(ConfigName);
	}
	else if (lock=Lock(PROGDIRPREFS,ACCESS_READ)) {
	    UnLock(lock);
	    ConfigName=strdup(PROGDIRPREFS);
	    ReadConfigFile(ConfigName);
	}
	else if (lock=Lock(ENVPREFS,ACCESS_READ)) {
	    UnLock(lock);
	    ConfigName=strdup(ENVPREFS);
	    ReadConfigFile(ConfigName);
	}
	else if (dirname[0]) {
	    if (lock=Lock(dirname,ACCESS_READ)) {
d143 1
a143 1
		ConfigName=strdup(dirname);
d146 8
a154 1
	else ConfigName=strdup(PROGDIRPREFS);
d368 3
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d15 4
d105 1
d107 1
a109 2
		strmfp(dirname,pw->pw_dir,"AmiFTP.prefs");
		ConfigName=strdup(dirname);
d114 1
d117 32
a148 2
	    else
	      ConfigName="AmiTCP:db/AmiFTP.prefs";
d150 1
a150 2
	else
	  ConfigName="AmiTCP:db/AmiFTP.prefs";
a151 1
    ReadConfigFile(ConfigName);
@


0.371
log
@Localized source.
@
text
@a74 2
    unix_dir_pattern = dir_parse_to_pattern(UNIX_DIR_PATTERN);

d104 1
a104 1
		strmfp(dirname,pw->pw_dir,"amiftp.prefs");
d113 1
a113 1
	      ConfigName="AmiTCP:db/amiftp.prefs";
d116 1
a116 1
	  ConfigName="AmiTCP:db/amiftp.prefs";
d132 2
a133 2
	struct Node *node=GetHead(&TempList),*tnode;
	while (node) {
a135 2
	    tnode=GetSucc(node);
	    Remove(node);
a136 1
	    node=tnode;
@


0.347
log
@Yet another change to make it work with as225
@
text
@a18 1
extern struct List StemList;
a20 4
/*struct CommandLineInterface *LocalCLI;
BPTR OldCLI;
WBenchLock=0;
*/
d22 1
a34 5
/*	if (LocalCLI=CloneCLI(&_WBenchMsg->sm_Message)) {
	    OldCLI=ThisProcess->pr_CLI;
	    ThisProcess->pr_CLI=MKBADDR(LocalCLI);
	}
	WBenchLock=CurrentDir(_WBenchMsg->sm_ArgList->wa_Lock);*/
d162 1
d241 2
d263 3
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d5 3
d236 13
d259 8
@


0.322
log
@Dir-cache added.
Delete added.
@
text
@d3 3
d160 8
d239 6
@


0.305
log
@Added some casts to avoid compiler warnings
@
text
@d100 1
@


0.284
log
@First RCS version.
@
text
@a23 2
    char	*helppath;
    int	closed = 0;
d45 1
a45 1
	exit();
d50 1
a50 1
	  strncpy(CurrentState.ScreenName,opts[OPT_SCREEN],256);
d52 1
a52 1
	    strncpy(CurrentState.FontName,opts[OPT_FONTNAME],256);
d151 1
a151 1
    DOSBase=(struct DosBase *)OpenLibrary("dos.library",36);
d181 1
a181 1
    IconBase = OpenLibrary("icon.library",36);
d186 1
a186 1
    WorkbenchBase = OpenLibrary("workbench.library",36);
d257 1
a257 1
      CloseLibrary(IconBase);
d263 1
a263 1
    for(sn=GetHead(&SiteList);sn;sn=GetSucc(sn)) {
d287 1
a287 1
		    strncpy(CurrentState.FontSize,key,255);
@
