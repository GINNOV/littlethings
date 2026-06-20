/* RCS Id: $Id: misc.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
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
