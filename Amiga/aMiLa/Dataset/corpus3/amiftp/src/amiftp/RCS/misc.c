head	1.795;
access;
symbols;
locks
	lilja:1.795; strict;
comment	@ * @;


1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.736;

1.736
date	96.08.17.18.17.57;	author lilja;	state Exp;
branches;
next	1.720;

1.720
date	96.07.27.23.43.40;	author lilja;	state Exp;
branches;
next	1.710;

1.710
date	96.07.25.00.21.30;	author lilja;	state Exp;
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
next	0.1301;

0.1301
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.857;

0.857
date	95.10.24.18.41.14;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.774;

0.774
date	95.10.07.00.18.25;	author lilja;	state Exp;
branches;
next	0.757;

0.757
date	95.09.30.16.00.45;	author lilja;	state Exp;
branches;
next	0.544;

0.544
date	95.09.08.14.11.28;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
branches;
next	0.322;

0.322
date	95.06.12.23.14.26;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Miscellaneous help-functions for AmiFTP
@


1.795
log
@Stuff.
@
text
@/* RCS Id: $Id: misc.c 1.736 1996/08/17 18:17:57 lilja Exp lilja $
   Locked version: $Revision: 1.736 $
*/

#include "AmiFTP.h"
#include "gui.h"

BPTR LogWindow=0;

void OpenLogWindow()
{
    if (!LogWindow) {
	char *name=malloc(100);
	if (name) {
	    sprintf(name,"CON:%ld/%ld/%ld/%ld/AmiFTP Logwindow/INACTIVE/SCREEN %s",
		    MainWindow?MainWindow->LeftEdge:40,
		    MainWindow?MainWindow->TopEdge+MainWindow->Height:40,
		    MainWindow?MainWindow->Width:400,
		    140,
		    MainPrefs.mp_PubScreen);
	    LogWindow=Open(name,MODE_NEWFILE);
	    free(name);
	}
    }
}

void CloseLogWindow()
{
    if (LogWindow) {
	Close(LogWindow);
	LogWindow=NULL;
    }
}

void LogMessage(char *mess, char c)
{
    if (mess) {
	Write(LogWindow, mess, strlen(mess));
	Write(LogWindow, "\n", 1);
    }
    else
      Write(LogWindow, &c, 1);
}

int sgetc(const int sock)
{
    unsigned char c;
    fd_set rd,ex;
    long flgs;
    int n;

    struct timeval t;
    t.tv_sec = 120L;
    t.tv_usec = 0;


//    Printf("sgetc: Entered sgetc())\n");
    FD_ZERO(&rd);
    FD_ZERO(&ex);

    FD_SET(sock, &rd);
    FD_SET(sock, &ex);
    flgs = SIGBREAKF_CTRL_D;
	
//    Printf("sgetc: WaitSelect()\n");
    tcp_waitselect(16, &rd, 0L, &ex, &t, (ULONG *)&flgs);

    if (FD_ISSET(sock,&rd))
      {	
//	  Printf("sgetc: recv'ing\n");
	  n = tcp_recv(sock, &c, 1, 0);
//	  Printf("sgetc: recv'ed\n");
	  if (n == 1)
	    return c;
	  else return -1;
    }

    else return -1;
}

char	*ftp_error(char ch, char *def)
{
    char	*str;
    char	*nl;

    if ((str = index(response_line, ch)) != NULL) {
	if ((nl = index(str, '\n')) != NULL)
	  *nl = '\0';
	return str+1;
    }
    return def;
}

void timeout_disconnect(void)
{
    if (MainWindow)
      PrintConnectStatus(GetAmiFTPString(Str_DisconnectedTimeout));
    quit_ftp();
}

void quit_ftp(void)
{
    connected = 0;

    if (!timedout && cout)
      (void) command("QUIT");
    close_files();
    data = -1;
    if (MainWindow) {
	DetachToolList();
    }
    ClearCache(TRUE);
    InitCache();

    UpdateMainButtons(MB_DISCONNECTED);

    if (other_dir_pattern) {
	free(other_dir_pattern);
	other_dir_pattern=NULL;
    }
    response_line[0]='\0';
    non_unix=0;
}

void close_files(void)
{
    if (cout!=-1) {
	tcp_closesocket(cout);
    }
    cout = cin = -1;
}

int ping_server(void)
{
    (void) command("NOOP");
    if (code == 421) {
	timedout++;
	return ETIMEDOUT;
    }
    return 0;
}

char *linkname(char *string)
{
    char *str, *tmp;

    /* string is of the form */
    /* name -> value */
    /* be somewhat sure we find the ->, not just one or the other, */
    /* since those _are_ legal filename characters */
    str = strdup(string);
    if (str == NULL) {
	ShowErrorReq("Out of memory");
	return NULL;
    }
    tmp = str;

    while ((tmp = index(tmp, '-')) != NULL) {
	if (tmp[1] == '>' && tmp[2] == ' ' &&
	    tmp > str && tmp[-1] == ' ') {
	    tmp[-1] = '\0';
	    return str;
	}
	tmp++;			/* skip '-', since we didn't find -> */
    }
    /*
      fprintf(stderr, "linkval: malformed link entry\n");
      free(str);
      */
    return str;
}

struct Node *AddLBNTail(struct List *list, struct SiteNode *sn)
{
    struct Node *lbn;
    ULONG flags;

    if (sn->sn_MenuType==SLN_PARENT) {
	flags=LBFLG_HASCHILDREN;
	if (sn->sn_ShowChildren)
	  flags|=LBFLG_SHOWCHILDREN;

	lbn=AllocListBrowserNode(1,
				 LBNA_UserData, sn,
				 LBNA_Generation, 1,
				 LBNA_Flags, flags,
				 LBNA_Column, 0,
				 LBNCA_Text, sn->sn_Node.ln_Name,
				 TAG_DONE);
    }
    else {
	lbn=AllocListBrowserNode(1,
				 LBNA_UserData, sn,
				 LBNA_Generation, sn->sn_MenuType==SLN_CHILD?2:1,
				 LBNA_Column, 0,
				 LBNCA_Text, sn->sn_Node.ln_Name,
				 TAG_DONE);
    }
    if (lbn) {
	lbn->ln_Name=sn->sn_Node.ln_Name;
	AddTail(list, lbn);
	return lbn;
    }
    return NULL;
}

int strecmp(const char *s1, const char *s2)
{
    int n1, n2;

    if ((n1 = strlen(s1)) == (n2 = strlen(s2)))
      return strnicmp(s1, s2, n1);
    else
      return (n1 < n2 ? -1 : 1);
}

void FixSiteList(void)
{
    struct Node *lbn;
    struct SiteNode *parent,*sn;

    lbn=FirstNode(&SiteList);
    while (lbn) {
	GetListBrowserNodeAttrs(lbn, LBNA_UserData, &parent, TAG_DONE);
	if (parent->sn_MenuType==SLN_PARENT) {
	    lbn=GetSucc(lbn);
	    if (lbn) {
		GetListBrowserNodeAttrs(lbn, LBNA_UserData, &sn, TAG_DONE);
		while (sn->sn_MenuType==SLN_CHILD) {
		    SetListBrowserNodeAttrs(lbn,
					    LBNA_Flags,parent->sn_ShowChildren?NULL:LBFLG_HIDDEN,
					    TAG_DONE);
		    if (lbn=GetSucc(lbn)) {
			GetListBrowserNodeAttrs(lbn, LBNA_UserData, &sn, TAG_DONE);
		    }
		    else break;
		}
	    }
	}
	else lbn=GetSucc(lbn);
    }
}

int DLPath(Object *winobject, char *initialpath, char *newpath)
{
    struct FileRequester *DirRequester;
    struct Window *window;
    static ULONG dlpath_tags[]={
	ASL_Window, NULL,
	ASLFR_PrivateIDCMP, TRUE,
	ASLFR_SleepWindow, TRUE,
	ASLFR_InitialDrawer, NULL,
	ASLFR_DrawersOnly, TRUE,
	ASLFR_RejectIcons, TRUE,
	ASLFR_TitleText, NULL,
	ASLFR_InitialLeftEdge, NULL,
	ASLFR_InitialTopEdge, NULL,
	TAG_END
      };
    int ret=0;

    GetAttr(WINDOW_Window, winobject, (ULONG *)&window);

    dlpath_tags[1]=(unsigned long)window;
    dlpath_tags[7]=(unsigned long)initialpath;
    dlpath_tags[13]=(unsigned long)GetAmiFTPString(Str_SelectDLPath);
    dlpath_tags[15]=window->LeftEdge;
    dlpath_tags[17]=window->TopEdge;

    DirRequester=AllocAslRequest(ASL_FileRequest, NULL);
    if (!DirRequester)
      return 0;

    LockWindow(winobject);

    if (AslRequest(DirRequester, (struct TagItem *)dlpath_tags)) {
	ret=1;
	strcpy(newpath, DirRequester->rf_Dir);
    }
    FreeAslRequest(DirRequester);

    UnlockWindow(winobject);
    return ret;
}

int makeremotedir()
{
/*    if (command("MKD %s", dir)==ERROR) {
    }*/
}

// EOF
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@d1 2
a2 2
/* RCS Id: $Id: misc.c 1.720 1996/07/27 23:43:40 lilja Exp lilja $
   Locked version: $Revision: 1.720 $
d284 6
@


1.720
log
@Select by pattern added.
DLPath()-function added to save some bytes (200 :).
@
text
@d1 2
a2 2
/* RCS Id: $Id: misc.c 1.710 1996/07/25 00:21:30 lilja Exp lilja $
   Locked version: $Revision: 1.710 $
d20 1
a20 1
		    CurrentState.ScreenName);
@


1.710
log
@Fontprefs seems to work ok, except in PrefsWindow.
@
text
@d1 2
a2 2
/* RCS Id: $Id: misc.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d211 1
a211 1
    if((n1 = strlen(s1)) == (n2 = strlen(s2)))
d243 44
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
/* RCS Id: $Id: misc.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d31 1
a31 1
	LogWindow=0;
d97 1
a97 1
      PrintConnectStatus("Disconnected (timeout).");
d209 1
a209 1
	int n1, n2;
d211 4
a214 4
	if((n1 = strlen(s1)) == (n2 = strlen(s2)))
		return strnicmp(s1, s2, n1);
	else
		return (n1 < n2 ? -1 : 1);
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Locked version: $Revision$
d5 1
a5 1
#include "ftpwin.h"
d38 2
a39 2
	Write(LogWindow,mess,strlen(mess));
	Write(LogWindow,"\n",1);
d42 1
a42 1
      Write(LogWindow,&c,1);
d61 2
a62 2
    FD_SET(sock,&rd);
    FD_SET(sock,&ex);
d66 1
a66 1
    tcp_waitselect(16,&rd,0L,&ex,&t,(ULONG *)&flgs);
d145 1
a145 1
    char	*str, *tmp;
d184 4
a187 4
				 LBNA_UserData,sn,
				 LBNA_Generation,1,
				 LBNA_Flags,flags,
				 LBNA_Column,0,
d193 3
a195 3
				 LBNA_UserData,sn,
				 LBNA_Generation,sn->sn_MenuType==SLN_CHILD?2:1,
				 LBNA_Column,0,
d201 1
a201 1
	AddTail(list,lbn);
d224 1
a224 1
	GetListBrowserNodeAttrs(lbn,LBNA_UserData,&parent,TAG_DONE);
d228 1
a228 1
		GetListBrowserNodeAttrs(lbn,LBNA_UserData,&sn,TAG_DONE);
d230 3
a232 1
		    SetListBrowserNodeAttrs(lbn,LBNA_Flags,parent->sn_ShowChildren?NULL:LBFLG_HIDDEN,TAG_DONE);
d234 1
a234 1
			GetListBrowserNodeAttrs(lbn,LBNA_UserData,&sn,TAG_DONE);
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
@d218 1
a218 1
    lbn=GetHead(&SiteList);
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d92 2
a93 1
    PrintConnectStatus("Disconnected (timeout).");
d111 2
a112 3
    if (MainWindow) {
	UpdateMainButtons(MB_DISCONNECTED);
    }
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
@a216 1
    ULONG parentshow;
@


1.265
log
@Groups added. Bugs fixed.
@
text
@a168 11
long gadstrlen(char *text)
{
    long l=0;
    while (*text) {
	if (*text!='_')
	  l++;
	text++;
    }
    return l;
}

@


1.200
log
@GETATTR-hit fixed.
@
text
@d183 1
d185 21
a205 6
    lbn=AllocListBrowserNode(1,
			     LBNA_UserData,sn,
			     LBNA_Generation,sn->sn_SubItem+1,
			     LBNA_Column,0,
			     LBNCA_Text, sn->sn_Node.ln_Name,
			     TAG_DONE);
d222 26
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d31 1
a31 1
void LogMessage(char *mess,char c)
d41 1
a41 1
int sgetc(int sock)
d85 1
a85 1
	return (str+1);
d87 1
a87 1
    return (def);
d134 1
a134 1
	return (ETIMEDOUT);
d136 1
a136 1
    return (0);
d150 1
a150 1
	return (NULL);
d158 1
a158 1
	    return (str);
d166 1
a166 1
    return (str);
d177 1
a177 1
    return (l);
d193 1
a193 1
	return (lbn);
d195 11
a205 1
    return (NULL);
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
@a48 1
#ifndef AS225
d51 1
a51 4
#else
    t.tv_secs=120L;
    t.tv_micro=0;
#endif
a61 1
#ifndef AS225
a62 3
#else
    selectwait(16,&rd,0L,&ex,&t,&flgs);
#endif
a99 1
#ifdef SOCKIO
a100 3
#else
    if (!timedout && commandfp)
#endif
a122 1
#ifdef SOCKIO
a123 1
#ifndef AS225
a124 3
#else
	s_close(cout);
#endif
a126 12
#else
    if (commandfp) {
	fflush(commandfp);
	(void) fclose(commandfp);
    }
    commandfp = NULL;
    if (responsefp) {
	fflush(responsefp);
	(void) fclose(responsefp);
    }
    responsefp = NULL;
#endif
@


0.1301
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d67 1
a67 1
    WaitSelect(16,&rd,0L,&ex,&t,(ULONG *)&flgs);
d75 1
a75 1
	  n = recv(sock, &c, 1, 0);
d138 1
a138 1
	CloseSocket(cout);
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d2 1
a7 2
    extern struct Window *mainWin;

d12 3
a14 3
		    mainWin?mainWin->LeftEdge:40,
		    mainWin?mainWin->TopEdge+mainWin->Height:40,
		    mainWin?mainWin->Width:400,
a105 2
    extern BOOL ShowFiles;
    extern struct Window *mainWin;
d116 1
a116 1
    if (mainWin) {
d122 1
a122 2
    ShowFiles=FALSE;
    if (mainWin) {
a123 1
	RefreshWinGad();
d207 18
@


0.814
log
@Added default download-dir.
@
text
@d3 39
@


0.774
log
@Now handles filenames up to 128 chars, atleast in DownloadFile().
@
text
@d29 1
a29 1
    WaitSelect(16,&rd,0L,&ex,&t,&flgs);
@


0.757
log
@Slightly improved timedout-control.
View handles spaces in filenames now (added a pair of \")
@
text
@d85 1
a85 5
/*    if (FileList) {
	free_dirlist(FileList);
	FileList=NULL;
    }
*/
@


0.544
log
@Added gadstrlen() and macro GadgetTextLength() to compute correct strings with _ in labels.
Checks if CTRL-C has been hit before opening window.
@
text
@d91 4
a94 2
    if (mainWin)
      RefreshWinGad();
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d165 11
@


0.322
log
@Dir-cache added.
Delete added.
@
text
@d11 1
d14 5
d28 1
d30 3
d105 1
d107 3
@


0.284
log
@First RCS version.
@
text
@d73 3
a75 1
    if (FileList) {
d79 1
a79 1

@
