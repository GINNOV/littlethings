head	1.795;
access;
symbols;
locks
	lilja:1.795
	lilja:0.588; strict;
comment	@ * @;


1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.730;

1.730
date	96.08.02.21.57.32;	author lilja;	state Exp;
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
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
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
next	0.671;

0.671
date	95.09.20.10.15.33;	author lilja;	state Exp;
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
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.413;

0.413
date	95.07.23.13.03.53;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.350;

0.350
date	95.06.22.19.23.19;	author lilja;	state Exp;
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
@Connect-GUI
@


1.795
log
@Stuff.
@
text
@/* RCS Id: $Id: ConnectWindow.c 1.730 1996/08/02 21:57:32 lilja Exp lilja $
   Locked version: $Revision: 1.730 $
*/

#include "AmiFTP.h"
#include "gui.h"

struct Window *ConnectWindow;
Object *ConnectLayout;
Object *ConnectWin_Object;

struct Window *OpenConnectWindow(void);
void CloseConnectWindow(void);

enum {
    CG_Host=0, CG_Status, CG_Abort,
    NumGadgets_CG};

struct Gadget *CG_List[NumGadgets_CG];

int ConnectSite(struct SiteNode *sn, const BOOL noscan)
{
    BOOL Continue=TRUE;
    ULONG wmask,signal,mainwinsignal,done=FALSE;
    struct List *head;
    int retcode, result;
    extern BOOL SilentMode;
    extern ULONG MOTDDate;

    if (MainWindow)
      if (!OpenConnectWindow())
	return CONN_GUI;

    LockWindow(MainWin_Object);
    if (ConnectWindow) {
	if (SetGadgetAttrs(CG_List[CG_Status], ConnectWindow, NULL,
			   GA_Text,GetAmiFTPString(CW_Connecting),
			   TAG_END))
	  RefreshGList(CG_List[CG_Status],ConnectWindow,NULL,1);
	if (SetGadgetAttrs(CG_List[CG_Host],ConnectWindow, NULL,
			   GA_Text,sn->sn_Node.ln_Name?sn->sn_Node.ln_Name:sn->sn_SiteAddress,
			   TAG_END))
	  RefreshGList(CG_List[CG_Host],ConnectWindow,NULL,1);
    }

    if ((result=doconnect(sn))==CONN_OK) {
	strncpy(CurrentState.CurrentSite, sn->sn_SiteAddress, 50);
	UpdateSiteName(CurrentState.CurrentSite);
	remote_os_type=sn->sn_VMSDIR;

	if (sn->sn_RemoteDir) {
	    PrintConnectStatus(GetAmiFTPString(CW_ChangingDirectory));
	    change_remote_dir(sn->sn_RemoteDir, 0);
	}

	ClearCache(TRUE);
	InitCache();
	if (!noscan) {
	    if (ConnectWindow) 
	      if (SetGadgetAttrs(CG_List[CG_Status], ConnectWindow, NULL,
				 GA_Text, GetAmiFTPString(CW_ReadingDir),
				 TAG_END))
		RefreshGList(CG_List[CG_Status], ConnectWindow, NULL, 1);
	    if (head=sn->sn_ADT?ReadRecentList():read_remote_dir()) {
		if (MainWindow)
		  SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
				 LISTBROWSER_Labels, ~0, TAG_DONE);
		else
		  SetAttrs(MG_List[MG_ListView], LISTBROWSER_Labels, ~0, TAG_DONE);
		if (CurrentState.ADTMode!=sn->sn_ADT) {
		    CurrentState.ADTMode=sn->sn_ADT;
		    ChangeAmiFTPMode();
		}
		AddCacheEntry(head, CurrentState.CurrentRemoteDir);
		FileList=head;
		if (MainWindow)
		  if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
				     LISTBROWSER_Labels, FileList,
				     LISTBROWSER_AutoFit, TRUE,
				     LISTBROWSER_ColumnInfo, &columninfo,
				     LISTBROWSER_MakeVisible, 0,
				     LISTBROWSER_Selected, -1,
				     TAG_DONE))
		    RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
		else
		  SetAttrs(MG_List[MG_ListView],
			   LISTBROWSER_Labels, FileList,
			   LISTBROWSER_AutoFit, TRUE,
			   LISTBROWSER_ColumnInfo, &columninfo,
			   LISTBROWSER_MakeVisible, 0,
			   LISTBROWSER_Selected, -1,
			   TAG_DONE);
		Continue=FALSE;
	    }
	    else Continue=TRUE;
	}
	else Continue=FALSE;
	if (sn->sn_LocalDir)
	  UpdateLocalDir(sn->sn_LocalDir);
	else if (MainPrefs.mp_LocalDir)
	  UpdateLocalDir(MainPrefs.mp_LocalDir);
	UpdateMainButtons(MB_NONESELECTED);
    }

    if (result==CONN_ABORTED) {
	CloseConnectWindow();
	UnlockWindow(MainWin_Object);
	return CONN_ERROR;
    }

    if (Continue) {
	char *text=NULL;

	if (timedout)
	  text=GetAmiFTPString(Str_ConnectionTimedOut);
	if (text && ConnectWindow)
	  if (SetGadgetAttrs(CG_List[CG_Status], ConnectWindow, NULL,
			     GA_Text, text,
			     TAG_DONE))
	    RefreshGList(CG_List[CG_Status], ConnectWindow, NULL, 1);
	retcode=CONN_ERROR;
    }
    else retcode=CONN_OK;

    if (ConnectWindow) {
	if  (SetGadgetAttrs(CG_List[CG_Abort], ConnectWindow, NULL,
			    GA_Disabled, TRUE,
			    TAG_DONE))
	  RefreshGList(CG_List[CG_Abort], ConnectWindow, NULL, 1);
	done=Continue?FALSE:TRUE;
	GetAttr(WINDOW_SigMask, ConnectWin_Object, &signal);
	GetAttr(WINDOW_SigMask, MainWin_Object, &mainwinsignal);

	if (!SilentMode) {
	    while (!done) {
		wmask=Wait(signal|mainwinsignal|AG_Signal);
		if (wmask&AG_Signal)
		  HandleAmigaGuide();
		if (wmask&signal)
		  done=HandleConnectIDCMP();
		if (wmask&mainwinsignal)
		  HandleMainWindowIDCMP(FALSE);
	    }
	}
	CloseConnectWindow();
	UpdateMainButtons(connected?MB_NONESELECTED:MB_DISCONNECTED);
    }
    if (retcode==CONN_OK && CurrentState.ADTMode && MainPrefs.mp_ShowMOTD) {
	if (MOTDDate>MainPrefs.mp_LastAMOTD) {
	    struct List flist;
	    struct Node *node;
	    struct dirlist file;

	    NewList(&flist);
	    memset(&file, 0, sizeof (file));
	    file.name="info/adt/aminet-motd";
	    file.size=0;
	    file.mode=S_IFREG;
	    if (node=AllocListBrowserNode(1,
					  LBNA_Selected, TRUE,
					  LBNA_Column, 0,
					  LBNCA_Text, file.name,
					  TAG_DONE)) {
		node->ln_Name=(void *)&file;
		AddTail(&flist, node);
		if (DownloadFile(&flist, "T:", ASCII, 0)==TRANS_OK) {
		    ViewFile("T:aminet-motd");
		    MainPrefs.mp_LastAMOTD=MOTDDate;
		    ConfigChanged=TRUE;
		}
		FreeListBrowserNode(node);
	    }
	}
    }
    UnlockWindow(MainWin_Object);
    return retcode;
}

ULONG HandleConnectIDCMP()
{
    ULONG result,done=FALSE;
    UWORD code=NULL;

    while ((result=CA_HandleInput(ConnectWin_Object, &code))!=WMHI_LASTMSG) {
	switch (result & WMHI_CLASSMASK) {
	  case WMHI_CLOSEWINDOW:
	    done=TRUE;
	    break;
	  case WMHI_GADGETUP:
	    done=TRUE;
	    break;
	  case WMHI_RAWKEY:
	    if (code==95)
	      SendAGMessage(AG_CONNECTWIN);
	    break;
	}
    }
    return done;
}

struct Window *OpenConnectWindow()
{
    struct LayoutLimits limits;

    if (ConnectWindow)
      return ConnectWindow;

    ConnectLayout=LayoutObject,
                     GA_DrawInfo, DrawInfo,
                     GA_TextAttr, AmiFTPAttrF,
                     LAYOUT_DeferLayout, TRUE,
                     LAYOUT_SpaceOuter, TRUE,
                     LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                     LAYOUT_HorizAlignment, LALIGN_CENTRE,

                     StartMember, CG_List[CG_Host]=ButtonObject,
                       GA_ID, CG_Host,
                       GA_RelVerify, TRUE,
                       GA_ReadOnly, TRUE,
                       GA_Text, " ",
                       BUTTON_Justification, BCJ_LEFT,
                       StringEnd,
                       CHILD_MinWidth, PropFont->tf_XSize*30,
                       Label(GetAmiFTPString(CW_Site)),

                     StartMember, CG_List[CG_Status]=ButtonObject,
                       GA_ID, CG_Status,
                       GA_RelVerify, TRUE,
                       GA_ReadOnly, TRUE,
                       GA_Text, " ",
                       BUTTON_Justification, BCJ_LEFT,
                       StringEnd,
                       CHILD_MinWidth, PropFont->tf_XSize*30,
                       Label(GetAmiFTPString(CW_Status)),

                     StartMember, CG_List[CG_Abort]=ButtonObject,
                       GA_ID, CG_Abort,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(CW_Abort),
                       ButtonEnd,
                       CHILD_WeightedWidth, 0,
                       CHILD_NominalSize, TRUE,
                   LayoutEnd;

    if (!ConnectLayout)
      return NULL;

    LayoutLimits((struct Gadget *)ConnectLayout, &limits, PropFont,Screen);

    limits.MinWidth+=Screen->WBorLeft+Screen->WBorRight;
    limits.MinHeight+=Screen->WBorTop+Screen->WBorBottom;
    
    ConnectWin_Object = WindowObject,
                          WA_Title, GetAmiFTPString(CW_WinTitle),
                          WA_PubScreen, Screen,
                          WA_DepthGadget, TRUE,
                          WA_DragBar, TRUE,
                          WA_CloseGadget, TRUE,
                          WA_Activate, TRUE,
                          WA_SmartRefresh, TRUE,
                          WA_Top, MainWindow->TopEdge+(MainWindow->Height-limits.MinHeight)/2,
                          WA_Left, MainWindow->LeftEdge+(MainWindow->Width-limits.MinWidth)/2,
                          WINDOW_ParentGroup, ConnectLayout,
                          WA_IDCMP, IDCMP_RAWKEY,
                        EndWindow;

    if (!ConnectWin_Object)
      return NULL;

    if (ConnectWindow=CA_OpenWindow(ConnectWin_Object)) {
	return ConnectWindow;
    }
    DisposeObject(ConnectLayout);
    ConnectLayout=NULL;

    return NULL;
}

void CloseConnectWindow(void)
{
    if (ConnectWin_Object) {
	DisposeObject(ConnectWin_Object);
	ConnectWindow=NULL;
	ConnectWin_Object=NULL;
	ConnectLayout=NULL;
    }
}

void PrintConnectStatus(char *text)
{
    char *s=text;
    
    if (CurrentState.Iconified)
      return;
    while(*s++)
      if (*s=='\n'||*s=='\r')
	*s=' ';
    
    if (ConnectWindow) {
	if (SetGadgetAttrs(CG_List[CG_Status], ConnectWindow, NULL,
			   GA_Text, text,
			   TAG_END))
	  RefreshGList(CG_List[CG_Status], ConnectWindow, NULL, 1);
    }
    else if (!SilentMode)
      ShowErrorReq(text);
}
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
/* RCS Id: $Id: ConnectWindow.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d80 1
d89 1
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
/* RCS Id: $Id: ConnectWindow.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
a7 1

d47 1
a47 1
	strncpy(CurrentState.CurrentSite,sn->sn_SiteAddress,50);
d53 1
a53 1
	    change_remote_dir(sn->sn_RemoteDir,0);
d60 2
a61 2
	      if (SetGadgetAttrs(CG_List[CG_Status],ConnectWindow,NULL,
				 GA_Text,GetAmiFTPString(CW_ReadingDir),
d63 1
a63 1
		RefreshGList(CG_List[CG_Status],ConnectWindow,NULL,1);
d66 2
a67 1
		  SetGadgetAttrs(MG_List[MG_ListView],MainWindow,NULL,LISTBROWSER_Labels,~0,TAG_DONE);
d69 1
a69 1
		  SetAttrs(MG_List[MG_ListView],LISTBROWSER_Labels,~0,TAG_DONE);
d74 1
a74 1
		AddCacheEntry(head,CurrentState.CurrentRemoteDir);
d77 7
a83 6
		  if (SetGadgetAttrs(MG_List[MG_ListView],MainWindow,NULL,
				     LISTBROWSER_Labels,FileList,
				     LISTBROWSER_AutoFit,TRUE,
				     LISTBROWSER_MakeVisible,0,
				     LISTBROWSER_Selected,-1,TAG_DONE))
		    RefreshGList(MG_List[MG_ListView],MainWindow,NULL,1);
d86 5
a90 4
			   LISTBROWSER_Labels,FileList,
			   LISTBROWSER_AutoFit,TRUE,
			   LISTBROWSER_MakeVisible,0,
			   LISTBROWSER_Selected,-1,TAG_DONE);
d111 1
d115 2
a116 2
	  if (SetGadgetAttrs(CG_List[CG_Status],ConnectWindow,NULL,
			     GA_Text,text,
d118 1
a118 1
	    RefreshGList(CG_List[CG_Status],ConnectWindow,NULL,1);
d124 2
a125 2
	if  (SetGadgetAttrs(CG_List[CG_Abort],ConnectWindow,NULL,
			    GA_Disabled,TRUE,
d127 1
a127 1
	  RefreshGList(CG_List[CG_Abort],ConnectWindow,NULL,1);
d129 2
a130 2
	GetAttr(WINDOW_SigMask,ConnectWin_Object,&signal);
	GetAttr(WINDOW_SigMask,MainWin_Object,&mainwinsignal);
d157 5
a161 1
	    if (node=AllocListBrowserNode(1,LBNA_Selected,TRUE,LBNA_Column,0,LBNCA_Text,file.name,TAG_DONE)) {
d164 1
a164 1
		if (DownloadFile(&flist,"T:", ASCII,0)==TRANS_OK) {
d182 1
a182 1
    while ((result=CA_HandleInput(ConnectWin_Object,&code))!=WMHI_LASTMSG) {
a208 1
//                     CLASSACT_TextAttr,AmiFTPAttrF,
a212 1
//                     LAYOUT_BevelStyle,BVS_THIN,
d217 1
a217 1
                       GA_ReadOnly,TRUE,
d221 1
a221 1
                       CHILD_MinWidth,PropFont->tf_XSize*30,
d231 1
a231 1
                       CHILD_MinWidth,PropFont->tf_XSize*30,
d239 1
a239 1
                       CHILD_WeightedWidth,0,
d246 1
a246 1
    LayoutLimits((struct Gadget *)ConnectLayout, &limits,PropFont,Screen);
d253 1
a253 1
                          WA_PubScreen,Screen,
d298 2
a299 2
	if (SetGadgetAttrs(CG_List[CG_Status],ConnectWindow,NULL,
			   GA_Text,text,
d301 1
a301 1
	  RefreshGList(CG_List[CG_Status],ConnectWindow,NULL,1);
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
@d1 2
a2 2
/* connect_gui.c
   Code should work with v38
@


1.531
log
@Lots of stuff
@
text
@d183 4
d257 1
a257 2
                          WINDOW_IDCMPHook,&IDCMPHook,
                          WINDOW_IDCMPHookBits,IDCMP_RAWKEY,
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
@d27 1
a27 1
    int retcode;
d47 1
a47 1
    if (doconnect(sn)) {
d100 7
d150 1
d231 1
a231 1
                       CHILD_WeightMinimum, TRUE,
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d29 1
d65 1
a65 1
	    if (head=sn->sn_ADT?read_recent_list():read_remote_dir()) {
d136 22
a159 1

a181 1
    struct Image *l;
@


1.200
log
@GETATTR-hit fixed.
@
text
@d34 1
d64 1
a64 1
	    if (head=read_remote_dir()) {
d69 4
d135 1
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
@d22 1
a22 1
int ConnectSite(struct SiteNode *sn, BOOL noscan)
d32 1
a32 1
	return (CONN_GUI);
d130 1
a130 1
    return (retcode);
d149 1
a149 1
    return (done);
d158 1
a158 1
      return (ConnectWindow);
d200 1
a200 1
      return (NULL);
d223 1
a223 1
      return (NULL);
d226 1
a226 1
	return (ConnectWindow);
d231 1
a231 1
    return (NULL);
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d28 1
d115 11
a125 8
	while (!done) {
	    wmask=Wait(signal|mainwinsignal|AG_Signal);
	    if (wmask&AG_Signal)
	      HandleAmigaGuide();
	    if (wmask&signal)
	      done=HandleConnectIDCMP();
	    if (wmask&mainwinsignal)
	      HandleMainWindowIDCMP(FALSE);
d162 2
d177 1
a177 1
                       CHILD_MinWidth,ScreenFont->tf_XSize*30,
d187 1
a187 1
                       CHILD_MinWidth,ScreenFont->tf_XSize*30,
d202 1
a202 1
    LayoutLimits((struct Gadget *)ConnectLayout, &limits,ScreenFont,Screen);
d247 1
a247 1

d253 8
a260 7

    if (ConnectWindow)
      if (SetGadgetAttrs(CG_List[CG_Status],ConnectWindow,NULL,
			 GA_Text,text,
			 TAG_END))
	RefreshGList(CG_List[CG_Status],ConnectWindow,NULL,1);
    else
@


0.814
log
@Added default download-dir.
@
text
@a7 2
enum {CONNECT_ABORT=0,CONNECT_SITE,CONNECT_STATUS,
	NumGadgets_connect};
d9 3
a11 1
struct Gadget *connect_Gadgets[NumGadgets_connect];
d13 2
a14 5
struct NewGadget connect_NewGadgets[]={
    {0,0,0,0,NULL,NULL,0,PLACETEXT_IN,NULL},   /* Abort */
    {0,0,0,0,NULL,NULL,1,PLACETEXT_LEFT,NULL}, /* Site */
    {0,0,0,0,NULL,NULL,2,PLACETEXT_LEFT,NULL}  /* Status */
};
d16 3
a18 33
LONG connect_GadgetLabels[]=
{
    (LONG)CW_Abort,
    (LONG)CW_Site,
    (LONG)CW_Status,
    -1
};


ULONG connect_ngtags[] = {
    /* Abort */
    TAG_DONE,
    /* Site */
    GTTX_Border,TRUE,
    TAG_DONE,
    /* Status */
    GTTX_Border,TRUE,
    TAG_DONE
};

ULONG connect_types[] = {
    BUTTON_KIND,
    TEXT_KIND,
    TEXT_KIND
  };
  
struct Gadget *connect_glist;
struct Window *connect_Win;

void ComputeSize_connect(UWORD *minwidth,UWORD *minheight)
{
    UWORD n1,n2;
    extern char www[];
d20 1
a20 28
    n1 = TextLength(PropRPort,www,25);
    connect_NewGadgets[CONNECT_SITE].ng_Width=n1;
    connect_NewGadgets[CONNECT_SITE].ng_Height=PropFHigh+2*INTERHEIGHT;
    n1=GadgetTextLength(PropRPort,connect_NewGadgets[CONNECT_SITE]);
    n2=GadgetTextLength(PropRPort,connect_NewGadgets[CONNECT_STATUS]);
    n1=max(n1,n2);
    connect_NewGadgets[CONNECT_SITE].ng_LeftEdge=n1+INTERWIDTH*2;
    connect_NewGadgets[CONNECT_SITE].ng_TopEdge=INTERHEIGHT/2;
    connect_NewGadgets[CONNECT_SITE].ng_VisualInfo=myVisualInfo;
    connect_NewGadgets[CONNECT_SITE].ng_TextAttr=PropFont;

    connect_NewGadgets[CONNECT_STATUS].ng_Width=connect_NewGadgets[CONNECT_SITE].ng_Width;
    connect_NewGadgets[CONNECT_STATUS].ng_Height=connect_NewGadgets[CONNECT_SITE].ng_Height;
    connect_NewGadgets[CONNECT_STATUS].ng_LeftEdge=connect_NewGadgets[CONNECT_SITE].ng_LeftEdge;
    connect_NewGadgets[CONNECT_STATUS].ng_TopEdge=connect_NewGadgets[CONNECT_SITE].ng_TopEdge+connect_NewGadgets[CONNECT_SITE].ng_Height+INTERHEIGHT;
    connect_NewGadgets[CONNECT_STATUS].ng_VisualInfo=myVisualInfo;
    connect_NewGadgets[CONNECT_STATUS].ng_TextAttr=PropFont;

    connect_NewGadgets[CONNECT_ABORT].ng_Width=GadgetTextLength(PropRPort,connect_NewGadgets[CONNECT_ABORT])+2*INTERWIDTH;
    connect_NewGadgets[CONNECT_ABORT].ng_Height=connect_NewGadgets[CONNECT_STATUS].ng_Height;
    connect_NewGadgets[CONNECT_ABORT].ng_TopEdge=connect_NewGadgets[CONNECT_STATUS].ng_TopEdge+connect_NewGadgets[CONNECT_STATUS].ng_Height+INTERHEIGHT;
    connect_NewGadgets[CONNECT_ABORT].ng_LeftEdge=(connect_NewGadgets[CONNECT_STATUS].ng_LeftEdge+connect_NewGadgets[CONNECT_STATUS].ng_Width-connect_NewGadgets[CONNECT_ABORT].ng_Width)/2;
    connect_NewGadgets[CONNECT_ABORT].ng_VisualInfo=myVisualInfo;
    connect_NewGadgets[CONNECT_ABORT].ng_TextAttr=PropFont;

    *minwidth=connect_NewGadgets[CONNECT_STATUS].ng_LeftEdge+connect_NewGadgets[CONNECT_STATUS].ng_Width+2*INTERWIDTH;
    *minheight=connect_NewGadgets[CONNECT_ABORT].ng_TopEdge+connect_NewGadgets[CONNECT_ABORT].ng_Height+INTERHEIGHT/2;
}
d22 1
a22 5

#ifndef AS225
#include <amitcp/socketbasetags.h>
#endif
int ConnectSite(struct SiteNode *sn,BOOL noscan)
a23 3
    UWORD Width,Height;
    struct Gadget *gad;
    struct IntuiMessage *imsg;
d25 1
a26 3
    ULONG omask=0,mask=0;
    ULONG winmask,wmask;

a27 66
    static ULONG connect_tags[]={
/*	WA_AutoAdjust,FALSE,*/
	WA_PubScreen,NULL,
	WA_Top,NULL,
	WA_Left,NULL,
	WA_Width,NULL,
	WA_InnerHeight,NULL,
	WA_MinWidth,NULL,
	WA_MinHeight,NULL,
	WA_Title,NULL,
	WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP,
	WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH,
	TAG_DONE
    };

#ifndef AS225
    SocketBaseTags(SBTM_GETREF(SBTC_BREAKMASK),&omask,TAG_END);
#endif

    if (mainWin) {
	ComputeSize_connect(&Width,&Height);
	connect_tags[1]=(ULONG)myScn;
	connect_tags[3]=mainWin->Height>Height?mainWin->TopEdge+(mainWin->Height-Height)/2:mainWin->TopEdge;
	connect_tags[5]=mainWin->Width?mainWin->LeftEdge+(mainWin->Width-Width-myScn->WBorLeft-myScn->WBorRight)/2:mainWin->LeftEdge;
	connect_tags[7]=Width+myScn->WBorLeft+myScn->WBorRight;
	connect_tags[9]=Height;
	connect_tags[11]=Width+myScn->WBorLeft+myScn->WBorRight;
	connect_tags[13]=Height+myScn->WBorTop+myScn->WBorBottom;
	connect_tags[15]=GetAmiFTPString(CW_WinTitle);
	connect_tags[19]|=(mainWin->Flags&WFLG_WINDOWACTIVE)?WFLG_ACTIVATE:0;
	connect_Win = OpenWindowTagList(NULL,(struct TagItem *)connect_tags);
	if (!connect_Win)
	    return(CONN_GUI);

	SetFont(connect_Win->RPort,NonPropdfont);
	gad = CreateContext(&connect_glist);
	if (!gad) {
	    StripIntuiMessages(connect_Win->UserPort,connect_Win);
	    CloseWindow(connect_Win);
	    return(CONN_GUI);
	}
	if (!Layout(&gad,connect_Win,&connect_NewGadgets[0],&connect_ngtags[0],&connect_types[0],
		    &connect_Gadgets[0],NumGadgets_connect)) {
	    StripIntuiMessages(connect_Win->UserPort,connect_Win);
	    CloseWindow(connect_Win);
	    FreeGadgets(connect_glist);
	    return(CONN_GUI);
	}
	
	AddGList(connect_Win,connect_glist,~0,-1,NULL);
	RefreshGList(connect_Win->FirstGadget,connect_Win,NULL,-1);
	GT_RefreshWindow(connect_Win,NULL);
	
	GT_SetGadgetAttrs(connect_Gadgets[CONNECT_SITE],connect_Win,NULL,
			  GTTX_Text,sn->sn_Node.ln_Name?sn->sn_Node.ln_Name:sn->sn_SiteAddress,
			  GTTX_CopyText,TRUE,
			  TAG_END);
	GT_SetGadgetAttrs(connect_Gadgets[CONNECT_STATUS],connect_Win,NULL,
			  GTTX_Text,GetAmiFTPString(CW_Connecting),
			  GTTX_CopyText,TRUE,
			  TAG_END);

#ifndef AS225
	mask = omask | 1<<connect_Win->UserPort->mp_SigBit;
	SocketBaseTags(SBTM_SETREF(SBTC_BREAKMASK),&mask,TAG_END);
#endif
d29 13
d43 1
d48 4
a51 5
	if (mainWin) {
	    GT_SetGadgetAttrs(connect_Gadgets[CONNECT_STATUS],connect_Win,NULL,
			      GTTX_Text,GetAmiFTPString(CW_ReadingDir),
			      GTTX_CopyText,TRUE,
			      TAG_END);
a52 2
	if (sn->sn_RemoteDir)
	  change_remote_dir(sn->sn_RemoteDir,0);
d57 5
a61 1

d63 4
a66 2
		if (mainWin)
		  GT_SetGadgetAttrs(mainGadgets[GD_Files_LV],mainWin,NULL,GTLV_Labels,NULL,TAG_DONE);
d69 13
a81 3
		if (mainWin)
		  GT_SetGadgetAttrs(mainGadgets[GD_Files_LV],mainWin,NULL,GTLV_Labels,FileList,TAG_DONE);
		RefreshWinGad();
d84 1
a84 2
	    else
	      Continue=TRUE; /* Fix this: Problem here... */
d86 1
a86 2
	else
	  Continue=FALSE;
d91 1
a91 1
	UpdateMainButtons(MB_DISCONNECTED);
d97 5
a101 5
	if (text && mainWin)
	  GT_SetGadgetAttrs(connect_Gadgets[CONNECT_STATUS],connect_Win,NULL,
			    GTTX_Text,text,
			    GTTX_CopyText,TRUE,
			    TAG_END);
d106 10
a115 10
    if (mainWin) {
#ifndef AS225
	SocketBaseTags(SBTM_SETREF(SBTC_BREAKMASK),&omask,TAG_END);
#endif
	GT_SetGadgetAttrs(connect_Gadgets[CONNECT_ABORT],connect_Win,NULL,
			  GA_Disabled,TRUE,
			  TAG_END);
	winmask=1<<connect_Win->UserPort->mp_SigBit;
	while (Continue) {
	    wmask=Wait(winmask|AG_Signal);
d118 11
a128 1
	    if (wmask&winmask) {
d130 13
a142 42
		while (imsg = GT_GetIMsg(connect_Win->UserPort)) {
		    int (*func)();
		    struct IntuiMessage connect_Msg; 
		    ULONG MsgClass;
		    UWORD Code;
		    MsgClass= imsg->Class;
		    Code    = imsg->Code;
		    CopyMem(imsg,&connect_Msg,sizeof(connect_Msg));
		
		    GT_ReplyIMsg(imsg);
		
		    switch(MsgClass) {
		      case IDCMP_CLOSEWINDOW:
			Continue=FALSE;
			break;
		      case IDCMP_REFRESHWINDOW:
			GT_BeginRefresh(connect_Win);
			GT_EndRefresh(connect_Win,TRUE);
			break;
/*		      case IDCMP_GADGETHELP:
			ag.ag_region=-1;
			if (connect_Msg.IAddress==(APTR)connect_Win) {
			    ag.ag_region=0;
			}
			break;
		      case IDCMP_RAWKEY:
			if (connect_Msg.Code==95) {
			    SendAGMessage(AG_CONNECTWIN);
			}
			break;*/
		      case IDCMP_GADGETUP:
		      case IDCMP_GADGETDOWN:
			func = (void *)((struct Gadget *)connect_Msg.IAddress)->UserData;
			if (func) {
			    func();
			}
			break;
		      default:
			break;
		    }
		}
	    }
a143 4
	StripIntuiMessages(connect_Win->UserPort,connect_Win);
	CloseWindow(connect_Win);
	FreeGadgets(connect_glist);
	UpdateMainButtons(connected?MB_NONESELECTED:MB_DISCONNECTED);
d145 91
a235 2
    connect_Win=NULL;
    return(retcode);
d248 5
a252 5
    if (connect_Win)
      GT_SetGadgetAttrs(connect_Gadgets[CONNECT_STATUS],connect_Win,NULL,
			GTTX_Text,text,
			GTTX_CopyText,TRUE,
			TAG_END);
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d199 2
@


0.774
log
@Now handles filenames up to 128 chars, atleast in DownloadFile().
@
text
@d94 2
d221 1
d223 13
a235 10
	    WaitPort(connect_Win->UserPort);

	    while (imsg = GT_GetIMsg(connect_Win->UserPort)) {
		int (*func)();
		struct IntuiMessage connect_Msg; 
		ULONG MsgClass;
		UWORD Code;
		MsgClass= imsg->Class;
		Code    = imsg->Code;
		CopyMem(imsg,&connect_Msg,sizeof(connect_Msg));
d237 1
a237 1
		GT_ReplyIMsg(imsg);
d239 28
a266 13
		switch(MsgClass) {
		  case IDCMP_CLOSEWINDOW:
		    Continue=FALSE;
		    break;
		  case IDCMP_REFRESHWINDOW:
		    GT_BeginRefresh(connect_Win);
		    GT_EndRefresh(connect_Win,TRUE);
		    break;
		  case IDCMP_GADGETUP:
		  case IDCMP_GADGETDOWN:
		    func = (void *)((struct Gadget *)connect_Msg.IAddress)->UserData;
		    if (func) {
			func();
a267 3
		    break;
		  default:
		    break;
@


0.671
log
@"View" on links downloaded it twice.
@
text
@d166 1
a166 9
/*	if (sn->sn_DirString) {
	    if (other_dir_pattern) {
		free(other_dir_pattern);
		other_dir_pattern=NULL;
	    }
	    remote_os_type=REMOTE_OS_OTHER;
	    other_dir_pattern=dir_parse_to_pattern(sn->sn_DirString);
	}
	else*/ remote_os_type=sn->sn_VMSDIR;
@


0.588
log
@The GUI now handles proportional fonts. Only the main listview is fixed font.
@
text
@d94 1
d127 1
a127 1
	    return(1);
d134 1
a134 1
	    return(2);
d141 1
a141 1
	    return(3);
d216 1
d218 2
d267 1
a267 1
    return(0);
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d53 1
a53 1
    n1 = TextLength(RPort,www,40);
d55 3
a57 3
    connect_NewGadgets[CONNECT_SITE].ng_Height=FHigh+2*INTERHEIGHT;
    n1=GadgetTextLength(RPort,connect_NewGadgets[CONNECT_SITE]);
    n2=GadgetTextLength(RPort,connect_NewGadgets[CONNECT_STATUS]);
d62 1
a62 1
    connect_NewGadgets[CONNECT_SITE].ng_TextAttr=Font;
d69 1
a69 1
    connect_NewGadgets[CONNECT_STATUS].ng_TextAttr=Font;
d71 1
a71 1
    connect_NewGadgets[CONNECT_ABORT].ng_Width=GadgetTextLength(RPort,connect_NewGadgets[CONNECT_ABORT])+2*INTERWIDTH;
d76 1
a76 1
    connect_NewGadgets[CONNECT_ABORT].ng_TextAttr=Font;
d95 1
a95 1
	WA_AutoAdjust,FALSE,
d101 2
d115 9
a123 7
	connect_tags[3]=(ULONG)myScn;
	connect_tags[5]=mainWin->Height>Height?mainWin->TopEdge+(mainWin->Height-Height)/2:mainWin->TopEdge;
	connect_tags[7]=mainWin->Width?mainWin->LeftEdge+(mainWin->Width-Width-myScn->WBorLeft-myScn->WBorRight)/2:mainWin->LeftEdge;
	connect_tags[9]=Width+myScn->WBorLeft+myScn->WBorRight;
	connect_tags[11]=Height;
	connect_tags[13]=GetAmiFTPString(CW_WinTitle);
	connect_tags[17]|=(mainWin->Flags&WFLG_WINDOWACTIVE)?WFLG_ACTIVATE:0;
d128 1
a128 1
	SetFont(connect_Win->RPort,dfont);
@


0.544
log
@Added gadstrlen() and macro GadgetTextLength() to compute correct strings with _ in labels.
Checks if CTRL-C has been hit before opening window.
@
text
@d118 1
a118 1
	connect_tags[13]="AmiFTP Connect window";
d148 1
a148 1
			  GTTX_Text,"Connecting...",
d172 1
a172 1
			      GTTX_Text,"Reading directory...",
d205 1
a205 1
	  text="Connection timedout";
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d56 2
a57 2
    n1=TextLength(RPort,connect_NewGadgets[CONNECT_SITE].ng_GadgetText,strlen(connect_NewGadgets[CONNECT_SITE].ng_GadgetText));
    n2=TextLength(RPort,connect_NewGadgets[CONNECT_STATUS].ng_GadgetText,strlen(connect_NewGadgets[CONNECT_STATUS].ng_GadgetText));
d71 1
a71 1
    connect_NewGadgets[CONNECT_ABORT].ng_Width=TextLength(RPort,connect_NewGadgets[CONNECT_ABORT].ng_GadgetText,strlen(connect_NewGadgets[CONNECT_ABORT].ng_GadgetText))+2*INTERWIDTH;
@


0.413
log
@Added password-gadget.
@
text
@d28 1
a28 1
ULONG connect_tags[] = {
a29 1
    GA_Disabled,FALSE,
a81 22
int Layout_connect(struct Gadget **gadg,struct Window *window)
{
    connect_NewGadgets[CONNECT_SITE].ng_TopEdge+=window->BorderTop;
    connect_NewGadgets[CONNECT_SITE].ng_LeftEdge+=window->BorderLeft;
    connect_NewGadgets[CONNECT_STATUS].ng_TopEdge+=window->BorderTop;
    connect_NewGadgets[CONNECT_STATUS].ng_LeftEdge+=window->BorderLeft;
    connect_NewGadgets[CONNECT_ABORT].ng_TopEdge+=window->BorderTop;
    connect_NewGadgets[CONNECT_ABORT].ng_LeftEdge+=window->BorderLeft;

    if (!(connect_Gadgets[CONNECT_SITE] = *gadg = CreateGadget(TEXT_KIND,*gadg,&connect_NewGadgets[CONNECT_SITE],
							       GTTX_Border,TRUE,
							       TAG_END)))
      return(FALSE);
    if (!(connect_Gadgets[CONNECT_STATUS] = *gadg = CreateGadget(TEXT_KIND,*gadg,&connect_NewGadgets[CONNECT_STATUS],
								 GTTX_Border,TRUE,
								 TAG_END)))
      return(FALSE);
    if (!(connect_Gadgets[CONNECT_ABORT] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&connect_NewGadgets[CONNECT_ABORT],
								TAG_END)))
      return(FALSE);
    return(TRUE);
}
d131 1
a131 2
//	if (!Layout_connect(&gad,connect_Win)) {
	if (!Layout(&gad,connect_Win,&connect_NewGadgets[0],&connect_tags[0],&connect_types[0],
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d28 1
a28 1
ULONG connect_ngtags[] = {
d30 2
a31 1
    TAG_END,
d40 1
a40 1
ULONG connect_ngtypes[] = {
a108 12
static ULONG connect_tags[]={
    WA_AutoAdjust,FALSE,
    WA_PubScreen,NULL,
    WA_Top,NULL,
    WA_Left,NULL,
    WA_Width,NULL,
    WA_InnerHeight,NULL,
    WA_Title,NULL,
    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP,
    WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH,
    TAG_DONE
};
d117 12
d154 3
a156 1
	if (!Layout_connect(&gad,connect_Win)) {
@


0.371
log
@Localized source.
@
text
@d8 1
a8 1
enum {CONNECT_SITE=0,CONNECT_STATUS,CONNECT_ABORT,
d56 4
a59 1
    connect_NewGadgets[CONNECT_SITE].ng_LeftEdge=TextLength(RPort,connect_NewGadgets[CONNECT_SITE].ng_GadgetText,strlen(connect_NewGadgets[CONNECT_SITE].ng_GadgetText))+INTERWIDTH*2;
d64 1
a64 1
    connect_NewGadgets[CONNECT_STATUS].ng_Width=n1;
d108 12
a119 1

d135 10
a145 15
	connect_Win = OpenWindowTags(NULL,
				     WA_AutoAdjust,FALSE,
				     WA_PubScreen,myScn,
				     WA_Top,mainWin->Height>Height?mainWin->TopEdge+(mainWin->Height-Height)/2:mainWin->TopEdge,
				     WA_Left,mainWin->Width?mainWin->LeftEdge+(mainWin->Width-Width-myScn->WBorLeft-myScn->WBorRight)/2:mainWin->LeftEdge,
				     WA_Width,Width+myScn->WBorLeft+myScn->WBorRight,
				     WA_InnerHeight,Height,
				     WA_Title,"AmiFTP Connect window",
				     WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP,
				     WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
				     TAG_DONE
				     );
	if (!connect_Win) {
	    return(1);
	}
d182 1
a182 1
	if (sn->sn_DirString) {
d190 1
a190 1
	else remote_os_type=sn->sn_VMSDIR;
@


0.350
log
@Enumerated gadgetnumbers
@
text
@a12 3
struct NewGadget connect_Abort = {0,0,0,0,"Abort",NULL,0,PLACETEXT_IN,NULL};
struct NewGadget connect_Site  = {0,0,0,0,"Site:",NULL,1,PLACETEXT_LEFT,NULL};
struct NewGadget connect_Status= {0,0,0,0,"Status:",NULL,2,PLACETEXT_LEFT,NULL};
d14 3
a16 3
    {0,0,0,0,"Abort",NULL,0,PLACETEXT_IN,NULL},
    {0,0,0,0,"Site:",NULL,1,PLACETEXT_LEFT,NULL},
    {0,0,0,0,"Status:",NULL,2,PLACETEXT_LEFT,NULL}
d19 9
d54 20
a73 20
    connect_Site.ng_Width=n1;
    connect_Site.ng_Height=FHigh+2*INTERHEIGHT;
    connect_Site.ng_LeftEdge=TextLength(RPort,connect_Status.ng_GadgetText,strlen(connect_Status.ng_GadgetText))+INTERWIDTH*2;
    connect_Site.ng_TopEdge=INTERHEIGHT/2;
    connect_Site.ng_VisualInfo=myVisualInfo;
    connect_Site.ng_TextAttr=Font;

    connect_Status.ng_Width=n1;
    connect_Status.ng_Height=connect_Site.ng_Height;
    connect_Status.ng_LeftEdge=connect_Site.ng_LeftEdge;
    connect_Status.ng_TopEdge=connect_Site.ng_TopEdge+connect_Site.ng_Height+INTERHEIGHT;
    connect_Status.ng_VisualInfo=myVisualInfo;
    connect_Status.ng_TextAttr=Font;

    connect_Abort.ng_Width=TextLength(RPort,connect_Abort.ng_GadgetText,strlen(connect_Abort.ng_GadgetText))+2*INTERWIDTH;
    connect_Abort.ng_Height=connect_Status.ng_Height;
    connect_Abort.ng_TopEdge=connect_Status.ng_TopEdge+connect_Status.ng_Height+INTERHEIGHT;
    connect_Abort.ng_LeftEdge=(connect_Status.ng_LeftEdge+connect_Status.ng_Width-connect_Abort.ng_Width)/2;
    connect_Abort.ng_VisualInfo=myVisualInfo;
    connect_Abort.ng_TextAttr=Font;
d75 2
a76 2
    *minwidth=connect_Status.ng_LeftEdge+connect_Status.ng_Width+2*INTERWIDTH;
    *minheight=connect_Abort.ng_TopEdge+connect_Abort.ng_Height+INTERHEIGHT/2;
d81 6
a86 6
    connect_Site.ng_TopEdge+=window->BorderTop;
    connect_Site.ng_LeftEdge+=window->BorderLeft;
    connect_Status.ng_TopEdge+=window->BorderTop;
    connect_Status.ng_LeftEdge+=window->BorderLeft;
    connect_Abort.ng_TopEdge+=window->BorderTop;
    connect_Abort.ng_LeftEdge+=window->BorderLeft;
d88 1
a88 1
    if (!(connect_Gadgets[CONNECT_SITE] = *gadg = CreateGadget(TEXT_KIND,*gadg,&connect_Site,
d92 1
a92 1
    if (!(connect_Gadgets[CONNECT_STATUS] = *gadg = CreateGadget(TEXT_KIND,*gadg,&connect_Status,
d96 1
a96 1
    if (!(connect_Gadgets[CONNECT_ABORT] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&connect_Abort,
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d8 3
a10 4
#define CONNECT_SITE       0
#define CONNECT_STATUS     1
#define CONNECT_ABORT      2
#define NumGadgets_connect 3
@


0.322
log
@Dir-cache added.
Delete added.
@
text
@d97 1
d99 2
d109 2
d112 1
d158 2
a159 1
	
d162 2
d220 1
d222 1
@


0.284
log
@First RCS version.
@
text
@d176 3
a178 1
	       
d180 1
d184 1
a184 4
		if (FileList) {
		    free_dirlist(FileList);
		    free(FileList);
		}
@
