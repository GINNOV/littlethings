/* RCS Id: $Id: AmiFTP.c 1.815 1996/12/14 12:13:03 lilja Exp lilja $
   Locked version: $Revision: 1.815 $
*/

#include "AmiFTP.h"
#include "gui.h"

extern char *connected_host;
extern struct MsgPort *AppPort;
extern struct CLIArguments *cliargs;

ULONG lsecs,lmics;

void parse_url(char *url, char *site, char *dir, char *userid, int *port)
{
    char *ptr,*ptr1;

    if (strncmp(url,"ftp://",6)==0) { /* URL-type [userid@]site[:port]path*/
	ptr=url+6;
    }
    else
      ptr=url;

    if (strchr(ptr,'@')) {
	strncpy(userid, ptr, strchr(ptr, '@')-ptr);
	ptr=strchr(ptr,'@');
	ptr++;
    }
    ptr1=site;
    while (*ptr!=0 && *ptr!=':' && *ptr!='/') {
	*ptr1=*ptr;
	ptr++;
	ptr1++;
    }
    if (*ptr==':') {
	ptr++;
	*port=atol(ptr);
	while (*ptr!=0 && isdigit(*ptr))
	  ptr++;
    }
    if (*ptr) {
	ptr++;
	if (*ptr)
	  strcpy(dir, ptr);
    }
}

void ftpWindow()
{
    ULONG rexxsignal,mainwinsignal,gotsignal,appsignal;
    int running=1;
    extern Object *ARexx_Object;
    extern BOOL ARexxQuitBit;
    extern struct List DropUploadList;

    NewList(&DropUploadList);

    if (!CurrentState.Iconified) {
	if (!OpenFTPWindow(FALSE)) {
	    Printf("failed to open window\n");
	    return;
	}
    }
    else {
	if ((ULONG)OpenFTPWindow(TRUE)!=1) {
	    Printf("failed\n");
	    return;
	}
    }
    if (cliargs && TCPStack)
      if (cliargs->site) {
	  struct SiteNode sn,*sn1=NULL;
	  struct Node *lbn;

	  LockWindow(MainWin_Object);
	  memset(&sn,0,sizeof(sn));
	  for (lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
	      GetListBrowserNodeAttrs(lbn,
				      LBNA_UserData, &sn1,
				      TAG_DONE);
	      if ((stricmp((char *)cliargs->site, sn1->sn_Node.ln_Name)==0)&&
		  (strlen(sn1->sn_Node.ln_Name)==strlen((char *)cliargs->site)))
		break;
	  }
	  if (!lbn) {
	      char site[100], dirpath[255], userid[30];
	      int port=0;

	      memset(site,0,100);
	      memset(dirpath,0,255);
	      memset(userid,0,30);
	      parse_url(cliargs->site, site, dirpath, userid, &port);
	      sn.sn_SiteAddress=(char *)site;
	      sn.sn_Node.ln_Name=(char *)site;
	      sn.sn_RemoteDir=dirpath[0]?dirpath:NULL;
	      sn.sn_LoginName=userid[0]?userid:NULL;
	      sn.sn_Anonymous=userid[0]?0:1;
	      sn.sn_Proxy=MainPrefs.mp_DefaultProxy;
	      sn.sn_Port=port==0?ftp_port:port;
	      UnlockWindow(MainWin_Object);
	      ConnectSite(&sn, 0);
	  }
	  else {
	      UnlockWindow(MainWin_Object);
	      ConnectSite(sn1, 0);
	  }
      }
    GetAttr(AREXX_SigMask, ARexx_Object, &rexxsignal);
    appsignal=1L<<AppPort->mp_SigBit;

    while (running) {
	fd_set rs;
	int res;

	FD_ZERO(&rs);
	if (cin!=-1)
	  FD_SET(cin, &rs);

	GetAttr(WINDOW_SigMask, MainWin_Object, &mainwinsignal);
	gotsignal=rexxsignal|SIGBREAKF_CTRL_C|AG_Signal|mainwinsignal|appsignal;
	if (TCPStack)
	  res=tcp_waitselect(cin==-1?0:cin+1, &rs, NULL, NULL, NULL, &gotsignal);
	else
	  gotsignal=Wait(rexxsignal|SIGBREAKF_CTRL_C|AG_Signal|mainwinsignal|appsignal);

	if (gotsignal) {
	    if (gotsignal&SIGBREAKF_CTRL_C)
	      break;
	    if (gotsignal&(mainwinsignal|appsignal)) {
		if (HandleMainWindowIDCMP(TRUE))
		  running=FALSE;
	    }
	    if (gotsignal&rexxsignal) {
		ARexxQuitBit=FALSE;
		CA_HandleRexx(ARexx_Object);
		if (ARexxQuitBit)
		  running=FALSE;
	    }
	    if (gotsignal&AG_Signal)
	      HandleAmigaGuide();
	}
	else {
	    if (MainWindow)
	      LockWindow(MainWin_Object);
	    timeout_disconnect();
	    if (MainWindow)
	      UnlockWindow(MainWin_Object);
	}
    }

    if (connected) {
	quit_ftp();
    }

    CloseMainWindow();
}

int Parent_clicked(void)
{
    struct List *head;

    if (!TCPStack)
      return 1;

    LockWindow(MainWin_Object);
    if (!change_remote_dir("..", 0)) {
	if (head=LookupCache(CurrentState.CurrentRemoteDir)) {
	    SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			   LISTBROWSER_Labels, ~0,
			   TAG_DONE);
	    FileList=head;
	    if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			       LISTBROWSER_Labels, FileList,
			       LISTBROWSER_AutoFit, TRUE,
			       LISTBROWSER_ColumnInfo, &columninfo,
			       LISTBROWSER_Selected, -1,
			       LISTBROWSER_MakeVisible, 0,
			       TAG_DONE))
	      RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	}
	else if (head=read_remote_dir()) {
	    AddCacheEntry(head, CurrentState.CurrentRemoteDir);
	    SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			   LISTBROWSER_Labels, ~0,
			   TAG_DONE);
	    FileList=head;
	    if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			       LISTBROWSER_Labels, FileList,
			       LISTBROWSER_AutoFit, TRUE,
			       LISTBROWSER_ColumnInfo, &columninfo,
			       LISTBROWSER_Selected, -1,
			       LISTBROWSER_MakeVisible, 0,
			       TAG_DONE))
	      RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	}
    }
    UpdateMainButtons(MB_NONESELECTED);
    UnlockWindow(MainWin_Object);
    return 1;
}

int Get_clicked(void)
{
    struct Node *node;
    ULONG sel;

    if (!TCPStack)
      return 1;

    for (node=ListHead(FileList);ListEnd(node);node=ListNext(node)) {
	GetListBrowserNodeAttrs(node,
				LBNA_Selected, &sel, TAG_DONE);
	if (sel) break;
    }
    if (node) {
	LockWindow(MainWin_Object);
	if (CurrentState.ADTMode)
	  DownloadFile(FileList, MainPrefs.mp_PreserveAminetDir?"T:":NULL,
		       TransferMode, 0);
	else
	  DownloadFile(FileList, NULL, TransferMode, 0);
	UnlockWindow(MainWin_Object);
    }
    return 1;
}

int DLPath_clicked(void)
{
    if (DLPath(MainWin_Object, &CurrentState.CurrentDLDir[0], 
	       &CurrentState.CurrentDLDir[0])) {
	UpdateLocalDir(CurrentState.CurrentDLDir);
    }
    return 1;
}

int DLPathString_clicked(void)
{
    strncpy(CurrentState.CurrentDLDir, GetString(MG_List[MG_DLString]), 255);
    UpdateWindowTitle();

    return 1;
}

int Put_clicked(void)
{
    struct List UploadList;
    struct Node *node;
    int i;
    struct FileRequester *FileRequester;
    static ULONG put_tags[]={
	ASL_Window, NULL,
	ASLFR_PrivateIDCMP, TRUE,
	ASLFR_SleepWindow, FALSE,
	ASLFR_InitialDrawer, NULL,
	ASLFR_RejectIcons, TRUE,
	ASLFR_TitleText, NULL,
	ASLFR_DoMultiSelect, TRUE,
	ASLFR_DoPatterns, TRUE,
	TAG_END
      };
    char DummyBuffer[1024];

    if (!TCPStack)
      return 1;

    put_tags[1]=(unsigned long)MainWindow;
    put_tags[7]=(unsigned long)CurrentState.CurrentDLDir;
    put_tags[11]=(unsigned long)GetAmiFTPString(Str_SelectULFiles);

    NewList(&UploadList);

    FileRequester=AllocAslRequest(ASL_FileRequest, NULL);
    if (!FileRequester)
      return 1;

    LockWindow(MainWin_Object);

    if (i=AslRequest(FileRequester, (struct TagItem *)put_tags)) {
#define MAX_FILENAME_LENGTH 1024
	for (i=0;i<FileRequester->rf_NumArgs;i++) {
	    if (FileRequester->fr_ArgList[i].wa_Lock) {
		if (!NameFromLock(FileRequester->fr_ArgList[i].wa_Lock,DummyBuffer,MAX_FILENAME_LENGTH))
		  DummyBuffer[0]=0;
	    }
	    else
	      strcpy(DummyBuffer, FileRequester->fr_Drawer);

	    if (FileRequester->fr_ArgList[i].wa_Name) {
		if (!AddPart(DummyBuffer,FileRequester->fr_ArgList[i].wa_Name,MAX_FILENAME_LENGTH))
		  DummyBuffer[0]=0;
	    }

	    if (DummyBuffer[0]) {
		struct FileInfoBlock fib;
		BPTR lock;
		struct dirlist *entry;

		lock=Lock(DummyBuffer, SHARED_LOCK);
		if (lock) {
		    Examine(lock, &fib);
		    UnLock(lock);
		}

		if (entry=new_direntry(DummyBuffer, NULL, NULL, NULL,
				       S_IFREG, fib.fib_Size)) {
		    if (node=AllocListBrowserNode(1,
						  LBNA_UserData, entry,
						  LBNA_Column, 0,
						  LBNCA_Text, entry->name,
						  LBNA_Selected, TRUE,
						  TAG_DONE)) {
			node->ln_Name=(void *)entry;
			AddTail(&UploadList, node);
		    }
		    else free_direntry(entry);
		}
	    }
	    else {
	    }
	}
    }
    else {
	FreeAslRequest(FileRequester);
	UnlockWindow(MainWin_Object);
	return 1;
    }
    FreeAslRequest(FileRequester);

    if (!EmptyList(&UploadList))
      UploadFile(&UploadList, NULL, TransferMode);
    free_dirlist(&UploadList);

    UnlockWindow(MainWin_Object);

    return 1;
}

int Connect_clicked(void)
{
    struct SiteNode *sn;

    if (!TCPStack)
      return 1;

    LockWindow(MainWin_Object);
    if((sn=OpenSiteListWindow(TRUE))) {
	UnlockWindow(MainWin_Object);
	ConnectSite(sn, 0);
	if (connected)
	  strncpy(CurrentState.LastLVSite, sn->sn_Node.ln_Name, 60);
    }
    else
      UnlockWindow(MainWin_Object);

    return 1;
}

int Reconnect(void)
{
    if (!TCPStack)
      return 1;

    geta4();

    if (CurrentState.CurrentSite[0]==0)
      return 1;

    if (CurrentState.LastLVSite[0]) {
	struct SiteNode *sn;
	struct Node *node;
	node=FindName(&SiteList, CurrentState.LastLVSite);
	if (node) {
	    struct SiteNode sn1;
	    GetListBrowserNodeAttrs(node, LBNA_UserData, &sn, TAG_DONE);
	    if (sn) {
		CopyMem(sn, &sn1, sizeof(struct SiteNode));
		sn1.sn_RemoteDir=strdup(CurrentState.CurrentRemoteDir);
		sn1.sn_LocalDir=CurrentState.CurrentDLDir;
		ConnectSite(&sn1,0);
		if (sn1.sn_RemoteDir)
		  free(sn1.sn_RemoteDir);
		strncpy(CurrentState.LastLVSite, sn->sn_Node.ln_Name, 60);
	    }
	}
    }
    else {
	struct SiteNode sn;
	memset(&sn,0,sizeof(struct SiteNode));
	sn.sn_RemoteDir=strdup(CurrentState.CurrentRemoteDir);
	sn.sn_LocalDir=CurrentState.CurrentDLDir;
	sn.sn_Node.ln_Name=CurrentState.CurrentSite;
	sn.sn_SiteAddress=sn.sn_Node.ln_Name;
	sn.sn_Port=ftp_port;
	sn.sn_Proxy=MainPrefs.mp_DefaultProxy;
	ConnectSite(&sn, 0);
	if (sn.sn_RemoteDir)
	  free(sn.sn_RemoteDir);
    }

    return 1;
}

int Disconnect_clicked(void)
{
    if (!TCPStack)
      return 1;

    quit_ftp();
    UpdateMainButtons(MB_DISCONNECTED);
    return 1;
}

char *NameToReadme(char *foo, int readmelen)
{
    char *bar=malloc(strlen(foo)+10);
    if (bar) {
	strcpy(bar, foo);
	strcpy(bar+strlen(bar)-readmelen, ".readme");
	return bar;
    }
    return NULL;
}

int View_clicked(BOOL Readme)
{
    struct dirlist *curr;
    struct Node *node;
    ULONG sel;

    if (!TCPStack)
      return 1;

    for (node=ListHead(FileList);ListEnd(node);node=ListNext(node)) {
	GetListBrowserNodeAttrs(node,
				LBNA_Selected, &sel, TAG_DONE);
	if (sel) break;
    }
    if (node) {
	LockWindow(MainWin_Object);
	curr=(void *)node->ln_Name;
	if (Readme) {
	    char *readmename;

	    if (curr->readmelen) {
		if (readmename=NameToReadme(curr->name, curr->readmelength)) {
		    struct List tlist;
		    struct Node *tmpnode;
		    struct dirlist tmpentry;
		    char fname[200];

		    strmfp(fname,curr->owner, readmename);
		    NewList(&tlist);
		    memset(&tmpentry, 0, sizeof(tmpentry));
		    tmpnode=AllocListBrowserNode(1,
						 LBNA_Column, 0,
						 LBNCA_Text, fname,
						 LBNA_Selected, TRUE,
						 TAG_DONE);
		    if (tmpnode) {
			tmpentry.name=fname;
			tmpentry.size=curr->readmelen;
			tmpnode->ln_Name=(char *)&tmpentry;
			tmpentry.mode=S_IFREG;
			AddTail(&tlist, tmpnode);
			if (!DownloadFile(&tlist, "T:", TransferMode, 0)) {
			    strmfp(fname, "T:", readmename);
			    ViewFile(fname);
			}
		    }
		    free(readmename);
		}
	    }
	} else
	/* Check for link */
	if (S_ISLNK(curr->mode)) {
	    char *name;
	    name = linkname(curr->name);
	    if (name) {
		char loc_name[200];
		struct List tlist;
		struct Node *tmpnode;
		struct dirlist tmpentry;
		CopyMem(curr, &tmpentry, sizeof(struct dirlist));
		NewList(&tlist);
		tmpnode=AllocListBrowserNode(1,
					     LBNA_Column, 0,
					     LBNCA_Text, curr->name,
					     LBNA_Selected, TRUE,
					     TAG_DONE);
		if (tmpnode) {
		    tmpnode->ln_Name=(void *)curr;
		    AddTail(&tlist, tmpnode);
		    if (!DownloadFile(&tlist, "T:", TransferMode, 0)) {
			DetachToolList();
			SetListBrowserNodeAttrs(node, LBNA_Selected, FALSE,
						TAG_DONE);
			AttachToolList(FALSE);
			strmfp(loc_name, "T:", name);
			ViewFile(loc_name);
		    }
		    FreeListBrowserNode(tmpnode);
		}
		free(name);
	    }
	}
	else if (curr->mode&0x4000) {/* Check for file or dir */
	    ShowErrorReq(GetAmiFTPString(Str_CannotDLDirs));
	}
	else {
	    char loc_name[200];
	    struct List tlist;
	    struct Node *tmpnode;
	    NewList(&tlist);
	    if (tmpnode=AllocListBrowserNode(1,
					     LBNA_Column, 0,
					     LBNCA_Text, curr->name,
					     LBNA_Selected, TRUE,
					     TAG_DONE)) {
		tmpnode->ln_Name=(void *)curr;
		AddTail(&tlist,tmpnode);
		if (!DownloadFile(&tlist, "T:", TransferMode, 0)) {
		    DetachToolList();
		    SetListBrowserNodeAttrs(node, LBNA_Selected, FALSE, TAG_DONE);
		    AttachToolList(FALSE);
		    strmfp(loc_name, "T:", curr->name);
		    ViewFile(loc_name);
		}
		FreeListBrowserNode(tmpnode);
	    }
	}
	sel=0;
	for (node=ListHead(FileList);ListEnd(node);node=ListNext(node)) {
	    GetListBrowserNodeAttrs(node,
				    LBNA_Selected, &sel, TAG_DONE);
	    if (sel) break;
	}
	if (sel)
	  UpdateMainButtons(MB_FILESELECTED);
	else
	  UpdateMainButtons(MB_NONESELECTED);
	UnlockWindow(MainWin_Object);
    }
    return 1;
}

void ViewFile(const char *file)
{
    struct Node *node;
    char *str=MainPrefs.mp_ViewCommand;
    char buffer[200];
    char *t=&buffer[0];

    node=malloc(sizeof(struct Node));
    if (node) {
	memset(node, 0, sizeof(struct Node));
	node->ln_Name=strdup(file);
	if (node->ln_Name) {
	    AddTail(&TempList, node);
	}
	else
	  free(node);
    }

    while (*str) {
	if (*str!='%') {
	    *t++ = *str++;
	    continue;
	}
	str+=2;
	switch(str[-1]) {
	  case 'F': 
	    t+=sprintf(t, "\"%s\"", file);
	    break;
	  case 'P':
	    t+=sprintf(t, "\"%s\"", opts[OPT_SCREEN]?(char *)opts[OPT_SCREEN]:"Workbench"); /* Fix this */
	    break;
	  default:
	    *t++=str[-2];
	    *t++=str[-1];
	    break;
	}
    }
    *t=0;
    //		    Printf("Launching '%s'\n",buffer);
    SystemTags(buffer, SYS_Input, NULL, SYS_Output, NULL, SYS_Asynch, TRUE,
	       TAG_DONE);
}

int Site_clicked(void)
{
    if (!TCPStack)
      return 1;

    if (!strlen(GetString(MG_List[MG_SiteName]))) {
	Disconnect_clicked();
	CurrentState.CurrentSite[0]=0;
	return 1;
    }

    {
	struct SiteNode sn;
	char site[100], dirpath[255], userid[30];
	int port=0;

	memset(site, 0, 100);
	memset(dirpath, 0, 255);
	memset(userid, 0, 30);
	memset(&sn, 0, sizeof(sn));

	parse_url(GetString(MG_List[MG_SiteName]), site, dirpath, userid, &port);
	sn.sn_Node.ln_Name=(char *)site;
	sn.sn_SiteAddress=(char *)site;
	sn.sn_Port=port==0?ftp_port:port;
	sn.sn_Proxy=MainPrefs.mp_DefaultProxy;
	sn.sn_Anonymous=userid[0]?0:1;
	sn.sn_LoginName=userid[0]?userid:NULL;
	sn.sn_RemoteDir=dirpath[0]?dirpath:NULL;

	ConnectSite(&sn,0);
	CurrentState.LastLVSite[0]=0;
    }

    return 1;
}

int Dir_clicked(void)
{
    struct List *head;

    if (!TCPStack)
      return 1;

    LockWindow(MainWin_Object);
    if (!change_remote_dir(GetString(MG_List[MG_DirName]), 0)) {
	RemoveCacheEntry(CurrentState.CurrentRemoteDir);
	if (head=read_remote_dir()) {
	    AddCacheEntry(head, CurrentState.CurrentRemoteDir);
	    SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			   LISTBROWSER_Labels, ~0,
			   TAG_DONE);
	    FileList=head;
	    if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			       LISTBROWSER_Labels, FileList,
			       LISTBROWSER_AutoFit, TRUE,
			       LISTBROWSER_ColumnInfo, &columninfo,
			       LISTBROWSER_Selected, -1,
			       LISTBROWSER_MakeVisible, 0,
			       TAG_DONE))
	      RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	    UpdateMainButtons(MB_NONESELECTED);
	}
	UpdateWindowTitle();
	UnlockWindow(MainWin_Object);
    }
    else {
	UpdateRemoteDir(CurrentState.CurrentRemoteDir);
	UnlockWindow(MainWin_Object);
	RemoteCDFailed();
    }
    return 1;
}

void RemoteCDFailed(void)
{
    if (MainWindow)
      if (timedout)
	ShowErrorReq(GetAmiFTPString(Str_CDFailedTimedout));
      else
	ShowErrorReq(GetAmiFTPString(Str_CDFailed));
    if (timedout)
      quit_ftp();
}

void __stdargs ShowErrorReq(char *str,...)
{
    va_list ap;
    static ULONG tags[]={
	RTEZ_ReqTitle, NULL,
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END
    };
    extern BOOL SilentMode;

    if (!MainWindow)
      return;

    if (SilentMode)
      return;

    tags[1]=(ULONG)GetAmiFTPString(Str_AmiFTPError);
    tags[3]=(ULONG)MainWindow;
    va_start(ap, str);
    rtEZRequestA(str, GetAmiFTPString(Str_OK), NULL, ap, (struct TagItem *)tags);
    va_end(ap);
}

char *GetPassword(char *user,char *passbuf)
{
    extern struct Window *ConnectWindow; /* Fix this: Bug in reqtools */
    static ULONG tags[]={
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RTGS_Invisible, TRUE,
	RTGS_TextFmt, NULL,
	RTGS_TextFmtArgs, NULL,
	RTGS_Flags, GSREQF_CENTERTEXT,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END
    };

    tags[1]=(ULONG)ConnectWindow;
    tags[7]=(ULONG)GetAmiFTPString(Str_PasswordEntry);
    tags[9]=(ULONG)&user;

    if (rtGetStringA(passbuf, 24, GetAmiFTPString(Str_PasswordRequest), NULL,
		     (struct TagItem *)tags))
      return passbuf;
    else
      return NULL;
}

extern char *infotext;
UWORD mapping[4];
#include "icons/AmiFTPbrsh.c"
Object *AboutWin_Object;

int About(void)
{
    Object *AboutLayout;
    struct Window *AboutWindow;
    struct Image *l;

    mapping[0]=DrawInfo->dri_Pens[BACKGROUNDPEN];
    mapping[1]=DrawInfo->dri_Pens[SHADOWPEN];
    mapping[2]=DrawInfo->dri_Pens[SHINEPEN];
    mapping[3]=DrawInfo->dri_Pens[FILLPEN];

    AboutLayout=LayoutObject,
                  GA_TextAttr, AmiFTPAttrF,
                  GA_DrawInfo, DrawInfo,
                  LAYOUT_DeferLayout, TRUE,
                  LAYOUT_SpaceOuter, TRUE,
                  LAYOUT_Orientation, LAYOUT_ORIENT_VERT,

                  StartHGroup,
                    LAYOUT_AddImage, l=LabelObject,
                      LABEL_Mapping, mapping,
                      LABEL_Image, &im,
                    LabelEnd,
                    CHILD_MinWidth, im.Width,
                    CHILD_MinHeight, im.Height,
                    CHILD_WeightedWidth, 0,
                    CHILD_WeightedHeight, 0,

                    LAYOUT_AddImage, l=LabelObject,
                      LABEL_DrawInfo, DrawInfo,
                      IA_Font, AmiFTPAttrF,
                      LABEL_Justification, LJ_LEFT,
                      LABEL_Text, infotext,
                      LABEL_Text, CurrentState.RexxPort,
                      LABEL_Text, "\n",
                      LABEL_Text, GetAmiFTPString(Str_Translator),
                    LabelEnd,
                    CHILD_MinWidth, l->Width,
                    CHILD_MinHeight, l->Height,
                    CHILD_WeightedWidth, 0,
                    CHILD_WeightedHeight, 0,
                  EndGroup,
                End;

    if (!AboutLayout)
      return 1;

    AboutWin_Object=WindowObject,
                      WA_Title, GetAmiFTPString(Str_AboutAmiFTP),
                      WA_PubScreen, Screen,
                      WA_Top, MainWindow->TopEdge,
                      WA_Left, MainWindow->LeftEdge,
                      WA_DepthGadget, TRUE,
                      WA_DragBar, TRUE,
                      WA_CloseGadget, TRUE,
                      WA_Activate, TRUE,
                      WA_SmartRefresh, TRUE,
                      WA_IDCMP, IDCMP_RAWKEY,
                      WINDOW_ParentGroup, AboutLayout,
                    EndWindow;
    if (!AboutWin_Object) {
	DisposeObject(AboutLayout);
	return 1;
    }

    LockWindow(MainWin_Object);

    if (AboutWindow=CA_OpenWindow(AboutWin_Object)) {
	ULONG aboutwin,mainwin,mask,done=FALSE;

	GetAttr(WINDOW_SigMask, MainWin_Object, &mainwin);
	GetAttr(WINDOW_SigMask, AboutWin_Object, &aboutwin);
	while (!done) {
	    mask=Wait(aboutwin|mainwin|AG_Signal|SIGBREAKF_CTRL_C);
	    if (mask&SIGBREAKF_CTRL_C)
	      done=TRUE;
	    if (mask&mainwin)
	      HandleMainWindowIDCMP(FALSE);
	    if (mask&AG_Signal)
	      HandleAmigaGuide();
	    if (mask&aboutwin) {
		ULONG result;
		UWORD code=NULL;
		while ((result=CA_HandleInput(AboutWin_Object, &code))!=WMHI_LASTMSG) {
		    switch (result&WMHI_CLASSMASK) {
		      case WMHI_CLOSEWINDOW:
			done=TRUE;
			break;
		      case WMHI_RAWKEY:
			if (code==69) /* Escape-key */
			  done=TRUE;
			else if (code==95) /* HELP-key */
			  SendAGMessage(AG_ABOUTWIN);
			break;
		    }
		}
	    }
	}
    }
    DisposeObject(AboutWin_Object);
    UnlockWindow(MainWin_Object);
    return 1;
}

int SavePrefs(void)
{
    extern char *ConfigName;

    if (ConfigChanged || CurrentState.LeftEdge!=MainWindow->LeftEdge || CurrentState.TopEdge!=MainWindow->TopEdge) {
	LockWindow(MainWin_Object);
	MainPrefs.mp_Height=MainWindow->Height-MainWindow->BorderTop-MainWindow->BorderBottom;
	MainPrefs.mp_Width=MainWindow->Width-MainWindow->BorderLeft-MainWindow->BorderRight;
	MainPrefs.mp_TopEdge=MainWindow->TopEdge+Screen->ViewPort.DyOffset;
	MainPrefs.mp_LeftEdge=MainWindow->LeftEdge+Screen->ViewPort.DxOffset;
	MainPrefs.mp_SortMode=SortMode;
	WriteConfigFile(ConfigName);
	UnlockWindow(MainWin_Object);
	ConfigChanged=FALSE;
    }
    return 1;
}

static ULONG prefs_tags[]={
    ASL_Window, NULL,
    ASLFR_PrivateIDCMP, TRUE,
    ASLFR_SleepWindow, TRUE,
    ASLFR_InitialDrawer, NULL,
    ASLFR_InitialFile, NULL,
    ASLFR_RejectIcons, TRUE,
    ASLFR_TitleText, NULL,
    ASLFR_DoSaveMode, NULL,
    TAG_END
};

int SavePrefsAs(void)
{
    struct FileRequester *FileRequester;
    char tmp[150];

    memset(tmp, 0, 150);
    CopyMem(ConfigName, tmp, (ULONG)PathPart(ConfigName)-(ULONG)ConfigName);

    prefs_tags[1]=(unsigned long)MainWindow;
    prefs_tags[7]=(unsigned long)tmp;
    prefs_tags[9]=(unsigned long)FilePart(ConfigName);
    prefs_tags[13]=(unsigned long)GetAmiFTPString(Str_SelectSettingsFile);
    prefs_tags[15]=(unsigned long)TRUE;

    FileRequester=AllocAslRequest(ASL_FileRequest, NULL);
    if (!FileRequester)
      return 1;
    if (AslRequest(FileRequester, (struct TagItem *)prefs_tags)) {
	strcpy(tmp, FileRequester->fr_Drawer);
	AddPart(tmp, FileRequester->fr_File, sizeof(tmp));
	if (ConfigName)
	  free(ConfigName);
	ConfigName=strdup(tmp);
	MainPrefs.mp_Height=MainWindow->Height-MainWindow->BorderTop-MainWindow->BorderBottom;
	MainPrefs.mp_Width=MainWindow->Width-MainWindow->BorderLeft-MainWindow->BorderRight;
	MainPrefs.mp_TopEdge=MainWindow->TopEdge+Screen->ViewPort.DyOffset;
	MainPrefs.mp_LeftEdge=MainWindow->LeftEdge+Screen->ViewPort.DxOffset;
	MainPrefs.mp_SortMode=SortMode;
	WriteConfigFile(ConfigName);
	ConfigChanged=FALSE;
    }
    FreeAslRequest(FileRequester);

    return 1;
}

int LoadPrefs(void)
{
    struct FileRequester *FileRequester;
    char tmp[150];

    memset(tmp, 0, 150);
    CopyMem(ConfigName, tmp, (ULONG)PathPart(ConfigName)-(ULONG)ConfigName);

    prefs_tags[1]=(unsigned long)MainWindow;
    prefs_tags[7]=(unsigned long)tmp;
    prefs_tags[9]=(unsigned long)FilePart(ConfigName);
    prefs_tags[13]=(unsigned long)GetAmiFTPString(Str_SelectSettingsFile);
    prefs_tags[15]=(unsigned long)FALSE;

    FileRequester=AllocAslRequest(ASL_FileRequest, NULL);
    if (!FileRequester)
      return 1;
    if (AslRequest(FileRequester, (struct TagItem *)prefs_tags)) {
	strcpy(tmp, FileRequester->fr_Drawer);
	AddPart(tmp, FileRequester->fr_File, sizeof(tmp));
	if (ConfigName)
	  free(ConfigName);
	ConfigName=strdup(tmp);
	FreeSiteList(&SiteList);
	NewList(&SiteList);
	if (MainPrefs.mp_LocalDir) {free(MainPrefs.mp_LocalDir);MainPrefs.mp_LocalDir=NULL;}
	if (MainPrefs.mp_AnonymousPW) {free(MainPrefs.mp_AnonymousPW);MainPrefs.mp_AnonymousPW=NULL;}
	if (MainPrefs.mp_LoginName) {free(MainPrefs.mp_LoginName);MainPrefs.mp_LoginName=NULL;}
	if (MainPrefs.mp_DefaultSite) {free(MainPrefs.mp_DefaultSite);MainPrefs.mp_DefaultSite=NULL;}
	if (MainPrefs.mp_ProxyServer) {free(MainPrefs.mp_ProxyServer);MainPrefs.mp_ProxyServer=NULL;}
	if (MainPrefs.mp_ViewCommand) {free(MainPrefs.mp_ViewCommand);MainPrefs.mp_ViewCommand=NULL;}
	ReadConfigFile(ConfigName);
	MenuNeedsUpdate=TRUE;
	ConfigChanged=FALSE;
    }
    FreeAslRequest(FileRequester);
    return 1;
}

void Log(char *file, unsigned long size, unsigned long cps,
	 BOOL download, char *site, BOOL incomplete)
{
    BPTR fh;
#if 0
    if (MainPrefs->Log) {
	if (fh = Open(MainPrefs->LogFile, MODE_READWRITE)) {
	    FPrintf(fh, "Date %s %ld %ld %s %s %s\n",
		    file,
		    size,
		    cps,
		    download?"Down":"Up",
		    site,
		    incomplete?"Incomplete":"");
	    Close(fh);
	}
    }
#endif
}
