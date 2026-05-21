/* RCS Id: $Id: rexx.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
*/

#include "AmiFTP.h"
#include "gui.h"
extern const char Version[];

#define REGA0 register __a0
#define REGA1 register __a1

struct SiteNode curr_rexx;

BOOL ARexxQuitBit=FALSE;
Object *ARexx_Object;

static void __saveds __asm rexx_GetFile(REGA0 struct ARexxCmd *ac,
					REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char *file;
        char *local;
    } *args=(void *)ac->ac_ArgList;
    struct dirlist file;
    struct List filelist;
    struct Node *node;

    NewList(&filelist);
    memset(&file, 0, sizeof (file));
    file.name=args->file;
    file.size=0;
    file.mode=S_IFREG;
    if (connected) {
	if (node=AllocListBrowserNode(1, LBNA_Selected, TRUE, LBNA_Column, 0,
				      LBNCA_Text, file.name, TAG_DONE)) {
	    node->ln_Name=(void *)&file;
	    AddTail(&filelist, node);
	    if (DownloadFile(&filelist,args->local,args->ascii?ASCII:BINARY,0)==TRANS_OK) {
		ac->ac_RC=RC_OK;
	    }
	    else {
		ac->ac_RC=RC_WARN;
	    }
	    FreeListBrowserNode(node);
	}
	else ac->ac_RC=RC_WARN;
    }
    else {
	ac->ac_RC=RC_WARN;
    }
}

static void __saveds __asm rexx_View(REGA0 struct ARexxCmd *ac,
				     REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char *file;
    } *args=(void *)ac->ac_ArgList;
    struct dirlist file;
    struct List filelist;
    struct Node *node;
    char loc_name[200];

    NewList(&filelist);
    memset(&file, 0, sizeof(file));

    file.name=args->file;
    file.size=0;
    file.mode=S_IFREG;
    if (connected) {
	if (node=AllocListBrowserNode(1,
				      LBNA_Selected, TRUE,
				      LBNA_Column, 0,
				      LBNCA_Text, file.name,
				      TAG_DONE)) {
	    node->ln_Name=(void *)&file;
	    AddTail(&filelist, node);
	    if (DownloadFile(&filelist,"T:",args->ascii?ASCII:BINARY,0)==TRANS_OK) {
		strmfp(loc_name, "T:", FilePart(file.name));
		ViewFile(loc_name);
		ac->ac_RC=RC_OK;
	    }
	    else {
		ac->ac_RC=RC_WARN;
	    }
	    FreeListBrowserNode(node);
	}
	else ac->ac_RC=RC_WARN;
    }
    else {
	ac->ac_RC=RC_WARN;
    }
}

static void __saveds __asm rexx_DeleteFile(REGA0 struct ARexxCmd *ac,
					   REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	char **files;
    } *args=(void *)ac->ac_ArgList;
    int i=0;

    if (!connected) {
	ac->ac_RC=RC_WARN;
	return;
    }

    while(args->files[i]) {
	if (!delete_remote(args->files[i], "DELE")) {
	    ac->ac_RC=RC_WARN;
	    return;
	}
	i++;
    }
    ac->ac_RC=RC_OK;
    return;
}

static void __saveds __asm rexx_MGetFile(REGA0 struct ARexxCmd *ac,
					 REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char **files;
    } *args=(void *)ac->ac_ArgList;
    struct dirlist *curr;
    struct List dllist;
    struct Node *node;
    int i=0;

    if (!connected) {
	ac->ac_RC=RC_WARN;
	return;
    }

    NewList(&dllist);

    while(args->files[i]) {
	curr=malloc(sizeof(struct dirlist));
	if (curr) {
	    curr->name=args->files[i];
	    curr->size=0;
	    curr->mode=S_IFREG;
	    if (node=AllocListBrowserNode(1,
					  LBNA_Selected, TRUE,
					  LBNA_Column, 0,
					  LBNCA_Text, curr->name,
					  TAG_DONE)) {
		node->ln_Name=(void *)curr;
		AddTail(&dllist, (struct Node *)node);
	    }
	}
	i++;
    }

    if (DownloadFile(&dllist, NULL, args->ascii?ASCII:BINARY, 0)==TRANS_OK) {
	ac->ac_RC=0;
    }
    else {
	ac->ac_RC=RC_WARN;
    }

    while (node = RemHead(&dllist)) {
	struct dirlist *curr = (void *) node->ln_Name;
	if (curr) {
	    free(curr);
	}
	FreeListBrowserNode(node);
    }

    return;
}

static void __saveds __asm rexx_Connect(REGA0 struct ARexxCmd *ac,
					REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long noscan;
    }*args=(void *)ac->ac_ArgList;
    struct SiteNode sn;

    if (!TCPStack) {
	ac->ac_RC=RC_WARN;
	return;
    }

    if (curr_rexx.sn_Node.ln_Name) {
	strncpy(CurrentState.LastLVSite, curr_rexx.sn_Node.ln_Name, 60);
	if (curr_rexx.sn_SiteAddress)
	  strncpy(CurrentState.CurrentSite, curr_rexx.sn_SiteAddress, 50);
	else
	  CurrentState.CurrentSite[0]=0;
	if (curr_rexx.sn_RemoteDir)
	  strncpy(CurrentState.CurrentRemoteDir, curr_rexx.sn_RemoteDir,
		  MAXPATHLEN+1);
	else
	  CurrentState.CurrentRemoteDir[0]=0;
	if (curr_rexx.sn_LocalDir)
	  strncpy(CurrentState.CurrentDLDir, curr_rexx.sn_LocalDir, 256);
	else
	  CurrentState.CurrentDLDir[0]=0;
	if (curr_rexx.sn_LoginName)
	  strncpy(CurrentState.LoginName, curr_rexx.sn_LoginName, 30);
	else
	  CurrentState.LoginName[0]=0;
	if (curr_rexx.sn_Password)
	  strncpy(CurrentState.Password, curr_rexx.sn_Password, 30);
	else
	  CurrentState.Password[0]=0;

	CurrentState.Proxy=curr_rexx.sn_Proxy;
	CurrentState.Port=curr_rexx.sn_Port;

    }
    if (!strlen(CurrentState.CurrentSite)) {
	ac->ac_RC=RC_WARN;
	return;
    }
    memset(&sn, 0, sizeof(struct SiteNode));
    sn.sn_RemoteDir=strdup(CurrentState.CurrentRemoteDir);
    sn.sn_LocalDir=CurrentState.CurrentDLDir;
    sn.sn_Node.ln_Name=CurrentState.CurrentSite;
    sn.sn_SiteAddress=sn.sn_Node.ln_Name;
    sn.sn_Port=CurrentState.Port?CurrentState.Port:21;
    sn.sn_Proxy=CurrentState.Proxy;
    sn.sn_LoginName=CurrentState.LoginName;
    sn.sn_Password=CurrentState.Password;
    sn.sn_Anonymous=CurrentState.LoginName[0]?0:1;
    if (ConnectSite(&sn,args->noscan)==CONN_OK) {
	ac->ac_RC=RC_OK;
    }
    else {
	ac->ac_RC=RC_WARN;
    }
    if (sn.sn_RemoteDir)
      free(sn.sn_RemoteDir);
    return;
}

static void __saveds __asm rexx_Disconnect(REGA0 struct ARexxCmd *ac,
					   REGA1 struct RexxMsg *rexxmsg)
{
    if (!TCPStack) {
	ac->ac_RC=RC_WARN;
	return;
    }

    quit_ftp();
    UpdateMainButtons(MB_DISCONNECTED);
    ac->ac_RC=RC_OK;
    return;
}

static void __saveds __asm rexx_LCD(REGA0 struct ARexxCmd *ac,
				    REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long parent;
	char *dir;
    } *args=(void *)ac->ac_ArgList;
    if (args->dir) {
	strncpy(CurrentState.CurrentDLDir, args->dir, 100);
	UpdateLocalDir(CurrentState.CurrentDLDir);
    }
    /* Todo: Fix Parent-mode */
    ac->ac_RC=RC_OK;
    return;
}

static void __saveds __asm rexx_CD(REGA0 struct ARexxCmd *ac,
				   REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long noscan;
	long parent;
	char *dir;
    } *args=(void *)ac->ac_ArgList;
    struct List *head;

    if (!args->dir && !args->parent) {
	ac->ac_RC=RC_WARN;
	return;
    }
    if (!connected) {
	ac->ac_RC=RC_WARN;
	  return;
    }
    if (!change_remote_dir(args->parent?"..":args->dir, 0)) {
	if (!args->noscan) {
	    if (head=LookupCache(CurrentState.CurrentRemoteDir)) {
		FileList=head;
	    }
	    else if (head=read_remote_dir()) {
		FileList=head;
		AddCacheEntry(head, CurrentState.CurrentRemoteDir);
	    }
	}
	    
	DetachToolList();
	AttachToolList(TRUE);
	ac->ac_RC=RC_OK;
    }
    else {
	ac->ac_RC=RC_WARN;
	ac->ac_RC2=code;
    }
    UpdateMainButtons(MB_NONESELECTED);
    return;
}

static void __saveds __asm rexx_Site(REGA0 struct ARexxCmd *ac,
				     REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	char *name;
    } *args = (void *)ac->ac_ArgList;
    
    struct SiteNode *sn = NULL;
    struct Node *lbn;

    for (lbn=ListHead(&SiteList);ListEnd(lbn);lbn=ListNext(lbn)) {
	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData,&sn,
				TAG_DONE);
	if (sn) /* Fix: broken */
	  if (!stricmp(args->name, sn->sn_Node.ln_Name) &&
	      strlen(args->name)==strlen(sn->sn_Node.ln_Name))
	    break;
    }
    if (sn) {
	if (connected) {
	    if (curr_rexx.sn_RemoteDir) free(curr_rexx.sn_RemoteDir);
	    if (curr_rexx.sn_LocalDir) free(curr_rexx.sn_LocalDir);
	    if (curr_rexx.sn_DirString) free(curr_rexx.sn_DirString);
	    if (curr_rexx.sn_LoginName) free(curr_rexx.sn_LoginName);
	    if (curr_rexx.sn_Password) free(curr_rexx.sn_Password);
	    if (curr_rexx.sn_Node.ln_Name) free(curr_rexx.sn_Node.ln_Name);
	    memset(&curr_rexx,0,sizeof(curr_rexx));
	    curr_rexx.sn_Flags=sn->sn_Flags;
	    curr_rexx.sn_Port=sn->sn_Port;
	    curr_rexx.sn_Proxy=sn->sn_Proxy;
	    curr_rexx.sn_HotList=sn->sn_HotList;
	    curr_rexx.sn_Anonymous=sn->sn_Anonymous;
	    if (sn->sn_RemoteDir)
	      curr_rexx.sn_RemoteDir=strdup(sn->sn_RemoteDir);
	    if (sn->sn_LocalDir)
	      curr_rexx.sn_LocalDir=strdup(sn->sn_LocalDir);
	    if (sn->sn_DirString)
	      curr_rexx.sn_DirString=strdup(sn->sn_DirString);
	    if (sn->sn_LoginName)
	      curr_rexx.sn_LoginName=strdup(sn->sn_LoginName);
	    if (sn->sn_Password)
	      curr_rexx.sn_Password=strdup(sn->sn_Password);
	    if (sn->sn_SiteAddress)
	      curr_rexx.sn_SiteAddress=strdup(sn->sn_SiteAddress);
	    if (sn->sn_Node.ln_Name)
	      curr_rexx.sn_Node.ln_Name=strdup(sn->sn_Node.ln_Name);
	}
	else {
	    CurrentState.CurrentSite[0]=0;
	    CurrentState.LastLVSite[0]=0;
	    if (curr_rexx.sn_Node.ln_Name) {
		free(curr_rexx.sn_Node.ln_Name);
		curr_rexx.sn_Node.ln_Name=0;
	    }
	    if (sn->sn_RemoteDir)
	      strncpy(CurrentState.CurrentRemoteDir, sn->sn_RemoteDir, 
		      MAXPATHLEN+1);
	    else
	      CurrentState.CurrentRemoteDir[0]=0;
	    if (sn->sn_LocalDir)
	      strncpy(CurrentState.CurrentDLDir, sn->sn_LocalDir, 256);
	    if (sn->sn_LoginName)
	      strncpy(CurrentState.LoginName, sn->sn_LoginName, 30);
	    else
	      CurrentState.LoginName[0]=0;
	    if (sn->sn_Password)
	      strncpy(CurrentState.Password, sn->sn_Password, 30);
	    else
	      CurrentState.Password[0]=0;
	    if (sn->sn_Node.ln_Name)
	      strncpy(CurrentState.LastLVSite, sn->sn_Node.ln_Name, 60);
	    if (sn->sn_SiteAddress)
	      strncpy(CurrentState.CurrentSite, sn->sn_SiteAddress, 50);
	    CurrentState.Proxy=sn->sn_Proxy;
	    CurrentState.Port=sn->sn_Port;
	    if (sn->sn_Anonymous)
	      CurrentState.LoginName[0]=0;
	}
	ac->ac_RC=RC_OK;
    }
    else {
	ac->ac_RC=RC_WARN;
    }
    return;
}

static void __saveds __asm rexx_PutFile(REGA0 struct ARexxCmd *ac,
					REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char *file;
	char *remote;
    } *args=(void *)ac->ac_ArgList;
    struct List UploadList;
    struct Node *node;
    struct dirlist *entry;

    if (!connected) {
	ac->ac_RC=RC_WARN;
	return;
    }

    if (entry=new_direntry(args->file, NULL, NULL, NULL, S_IFREG, 0)) {
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

    if (!EmptyList(&UploadList)) {
	if (UploadFile(&UploadList, args->remote, args->ascii?ASCII:BINARY)==TRANS_OK) {
	    ac->ac_RC=RC_OK;
	}
	else {
	    ac->ac_RC=RC_WARN;
	}
    }

    free_dirlist(&UploadList);
    return;
}

static void __saveds __asm rexx_MPutFile(REGA0 struct ARexxCmd *ac,
					 REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char **files;
    } *args=(void *)ac->ac_ArgList;
    struct List UploadList;
    struct Node *node;
    struct dirlist *entry;
    int i=0;

    if (!connected) {
	ac->ac_RC=RC_WARN;
	return;
    }

    NewList(&UploadList);
    while(args->files[i]) {
	if (entry=new_direntry(args->files[i], NULL, NULL, NULL, S_IFREG, 0)) {
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
	i++;
    }

    if (FirstNode(&UploadList)) {
	if (UploadFile(&UploadList, NULL, args->ascii?ASCII:BINARY)==TRANS_OK) {
	    ac->ac_RC=RC_OK;
	}
	else {
	    ac->ac_RC=RC_WARN;
	}
	free_dirlist(&UploadList);
    }

    return;
}

BOOL SilentMode=FALSE;

static void __saveds __asm rexx_SetAttr(REGA0 struct ARexxCmd *ac, 
					REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	char *host;
	char *port;
	char *proxyhost;
	char *proxyport;
	long useproxy;
	char *remotedir;
	char *localdir;
	char *username;
	char *password;
	long anonymous;
	char *quiet;
    }*args = (void *)ac->ac_ArgList;

    if (args->host) {
	strncpy(CurrentState.CurrentSite, args->host, 50);
	CurrentState.LastLVSite[0]=0;
    }
    if (args->port)
      if (isalpha(args->port[0]))
	CurrentState.Port=atol(args->port);

    if (args->proxyhost);
    if (args->proxyport);
    if (args->useproxy)
      CurrentState.Proxy=1;
    if (args->remotedir)
      strncpy(CurrentState.CurrentRemoteDir, args->remotedir, MAXPATHLEN+1);
    if (args->localdir) {
	strncpy(CurrentState.CurrentDLDir, args->localdir, 256);
	UpdateLocalDir(CurrentState.CurrentDLDir);
    }
    if (args->username)
      strncpy(CurrentState.LoginName, args->username, 30);
    if (args->password)
      strncpy(CurrentState.Password, args->password, 30);

    if (args->quiet) {
	if (strnicmp(args->quiet, "TRUE", 4)==0)
	  SilentMode=TRUE;
	else if (strnicmp(args->quiet, "FALSE", 5)==0)
	  SilentMode=FALSE;
    }

    ac->ac_RC=RC_OK;
    return;
}

static int SetStemVar(struct RexxMsg *rexxmsg, char *value, char *stemname,...)
{
    UBYTE Name[256];
    va_list VarArgs;

    va_start(VarArgs, stemname);
    vsprintf(Name, stemname, VarArgs);
    va_end(VarArgs);

    return SetRexxVar(rexxmsg, Name, value, strlen(value));
}


static void __saveds __asm rexx_GetAttr(REGA0 struct ARexxCmd *ac, 
					REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	char *stem;
	long hotlist;
	long filelist;
    } *args = (void *)ac->ac_ArgList;
    char buff[100];
    long err=0;

    strupr(args->stem);
    err|=SetStemVar(rexxmsg, Version, "%s.VERSION", args->stem);
    err|=SetStemVar(rexxmsg, MainPrefs.mp_PubScreen, "%s.SCREEN", args->stem);
    err|=SetStemVar(rexxmsg, CurrentState.CurrentSite, "%s.HOST", args->stem);
    sprintf(buff, "%ld", CurrentState.Port);
    err|=SetStemVar(rexxmsg, buff, "%s.PORT", args->stem);
    err|=SetStemVar(rexxmsg, MainPrefs.mp_ProxyServer?MainPrefs.mp_ProxyServer:"",
		    "%s.PROXYHOST", args->stem);
    sprintf(buff, "%ld", MainPrefs.mp_ProxyPort);
    err|=SetStemVar(rexxmsg, buff, "%s.PROXYPORT", args->stem);
    err|=SetStemVar(rexxmsg, CurrentState.Proxy?"1":"0", "%s.USEPROXY", args->stem);
    sprintf(buff, "%s.ANONYMOUS", args->stem);
    err|=SetStemVar(rexxmsg, CurrentState.LoginName[0]?"0":"1", "%s.ANONYMOUS",
		    args->stem);
    err|=SetStemVar(rexxmsg, CurrentState.LoginName[0]?CurrentState.LoginName:"",
		    "%s.USERNAME", args->stem);
/*    sprintf(buff, "%s.PASSWORD", args->stem);
    err|=SetStemVar(rexxmsg, buff, "");*/
    err|=SetStemVar(rexxmsg, CurrentState.CurrentDLDir, "%s.LOCALDIR", args->stem);
    err|=SetStemVar(rexxmsg, CurrentState.CurrentRemoteDir, "%s.REMOTEDIR",
		    args->stem);
    err|=SetStemVar(rexxmsg, TCPStack?ping_server()?"0":"1":"0", "%s.CONNECTED", args->stem);
    err|=SetStemVar(rexxmsg, SilentMode?"1":"0", "%s.QUIET", args->stem);
    if (args->hotlist) {
	int i;
	struct SiteNode *sn;
	struct Node *lbn;

	for (i=0,lbn=ListHead(&SiteList);ListEnd(lbn);i++,lbn=ListNext(lbn)) {
	    GetListBrowserNodeAttrs(lbn,
				    LBNA_UserData, &sn,
				    TAG_DONE);
	    err|=SetStemVar(rexxmsg, sn->sn_Node.ln_Name, "%s.HOTLIST.%d.NAME",
			    args->stem, i);
	    err|=SetStemVar(rexxmsg, sn->sn_SiteAddress, "%s.HOTLIST.%d.ADDRESS",
			    args->stem, i);
	    sprintf(buff, "%ld", sn->sn_Port);
	    err|=SetStemVar(rexxmsg, buff, "%s.HOTLIST.%d.PORT", args->stem, i);
	    err|=SetStemVar(rexxmsg, sn->sn_LoginName?sn->sn_LoginName:"",
			    "%s.HOTLIST.%d.USERNAME", args->stem, i);
	    err|=SetStemVar(rexxmsg, "", "%s.HOTLIST.%d.PASSWORD", args->stem, i);
	    err|=SetStemVar(rexxmsg, sn->sn_LoginName?"0":"1",
			    "%s.HOTLIST.%d.ANONYMOUS", args->stem, i);
	    err|=SetStemVar(rexxmsg, sn->sn_RemoteDir?sn->sn_RemoteDir:"",
			    "%s.HOTLIST.%d.REMOTEDIR", args->stem, i);
	    err|=SetStemVar(rexxmsg, sn->sn_LocalDir?sn->sn_LocalDir:"",
			    "%s.HOTLIST.%d.LOCALDIR", args->stem, i);
	    err|=SetStemVar(rexxmsg, sn->sn_Proxy?"1":"0",
			    "%s.HOTLIST.%d.USEPROXY", args->stem, i);
	}
	sprintf(buff, "%ld", i);
	err|=SetStemVar(rexxmsg, buff, "%s.HOTLIST.COUNT", args->stem);
    }
    if (args->filelist) {
	int i;
	struct dirlist *curr;
	struct Node *node;
	if (FileList)
	  for (i=0,node=ListHead(FileList);
	       ListEnd(node);
	       node=ListNext(node),i++) {
	      curr = node->ln_Name;
	      /*kprintf("Rexx: %s %ld\n", curr->name, curr->size);*/
	      err|=SetStemVar(rexxmsg, curr->name, "%s.FILELIST.%d.NAME", args->stem,
			      i);
	      sprintf(buff, "%ld", curr->size);
	      err|=SetStemVar(rexxmsg, buff, "%s.FILELIST.%d.SIZE", args->stem, i);
	      err|=SetStemVar(rexxmsg, S_ISDIR(curr->mode)?"DIR":S_ISLNK(curr->mode)?"LINK":"FILE", "%s.FILELIST.%d.TYPE", args->stem, i);
	  }
	sprintf(buff, "%ld", i);
	err|=SetStemVar(rexxmsg, buff, "%s.FILELIST.COUNT", args->stem);
    }
    if (err)
      ac->ac_RC=RC_WARN;
    else
      ac->ac_RC=RC_OK;
    ac->ac_RC2=err;

    return;
}

static void __saveds __asm rexx_Quit(REGA0 struct ARexxCmd *ac,
				     REGA1 struct RexxMsg *rexxmsg)
{
    ARexxQuitBit=TRUE;
    ac->ac_RC=RC_OK;
    return;
}

static void __saveds __asm rexx_Activate(REGA0 struct ARexxCmd *ac,
					 REGA1 struct RexxMsg *rexxmsg)
{
    ac->ac_RC=RC_OK;
    if (!MainWindow)
      MainWindow=CA_OpenWindow(MainWin_Object);
    return;
}

static void __saveds __asm rexx_Deactivate(REGA0 struct ARexxCmd *ac,
					   REGA1 struct RexxMsg *rexxmsg)
{
    ac->ac_RC=RC_OK;
    if (CA_Iconify(MainWin_Object))
      MainWindow=NULL;
    return;
}

static void __saveds __asm rexx_FTPCommand(REGA0 struct ARexxCmd *ac,
					   REGA1 struct RexxMsg *rexxmsg)
{
    struct ArgStruct {
	char *command;
    } *args = (void *)ac->ac_ArgList;
    char errcode[10];

    if (connected) {
	command(args->command);
	sprintf(errcode, "%ld", code);
	ac->ac_RC=RC_OK;
	SetRexxVar(rexxmsg, "RC2", errcode, strlen(errcode));
    }
    else
      ac->ac_RC=RC_WARN;

    return;
}

enum {REXX_GETFILE, REXX_MGETFILE, REXX_PUTFILE, REXX_MPUTFILE,
      REXX_DELETEFILE, REXX_CONNECT, REXX_DISCONNECT, REXX_LCD,
      REXX_CD, REXX_SITE, REXX_QUIT, REXX_GETATTR, REXX_SETATTR,
      REXX_ACTIVATE, REXX_DEACTIVATE, REXX_VIEW,REXX_FTPCOMMAND};

static struct ARexxCmd ARexxCommands[] =
{
    {"GET",        REXX_GETFILE,   rexx_GetFile,    "ASCII/S,BIN/S,FILE/A,LOCAL", NULL},
    {"MGET",       REXX_MGETFILE,  rexx_MGetFile,   "ASCII/S,BIN/S,FILE/M", NULL},
    {"PUT",        REXX_PUTFILE,   rexx_PutFile,    "ASCII/S,BIN/S,FILE/A,REMOTE", NULL},
    {"MPUT",       REXX_MPUTFILE,  rexx_MPutFile,   "ASCII/S,BIN/S,FILE/M", NULL},
    {"DELETE",     REXX_DELETEFILE,rexx_DeleteFile, "FILE/M", NULL},
    {"CONNECT",    REXX_CONNECT,   rexx_Connect,    "NOSCAN/S", NULL},
    {"DISCONNECT", REXX_DISCONNECT,rexx_Disconnect,  NULL, NULL},
    {"LCD",        REXX_LCD,       rexx_LCD,        "PARENT/S,DIR", NULL},
    {"CD",         REXX_CD,        rexx_CD,         "NOSCAN/S,PARENT/S,DIR", NULL},
    {"SITE",       REXX_SITE,      rexx_Site,       "SITE/A/F", NULL},
    {"QUIT",       REXX_QUIT,      rexx_Quit,        NULL, NULL},
    {"GETATTR",    REXX_GETATTR,   rexx_GetAttr,    "STEM/A,HOTLIST/S,FILELIST/S", NULL},
    {"SETATTR",    REXX_SETATTR,   rexx_SetAttr,    "HOST/K,PORT/K,PROXYHOST/K,PROXYPORT/K,USEPROXY/S,REMOTEDIR/K,LOCALDIR/K,USERNAME/K,PASSWORD/K,ANONYMOUS/S,QUIET/K", NULL},
    {"ACTIVATE",   REXX_ACTIVATE,  rexx_Activate,   NULL, NULL},
    {"DEACTIVATE", REXX_DEACTIVATE,rexx_Deactivate, NULL, NULL},
    {"VIEW",       REXX_VIEW,      rexx_View,       "ASCII/S,BIN/S,FILE/A",NULL},
    {"FTPCOMMAND", REXX_FTPCOMMAND,rexx_FTPCommand, "COMMAND/F",NULL},
    {NULL,NULL,NULL,NULL,NULL,}
};

BOOL InitRexx(void)
{
    int i;
    char portname[50];
    ULONG error;

    if (ARexx_Object = ARexxObject, AREXX_HostName, CurrentState.RexxPort,
                                    AREXX_Commands, ARexxCommands,
                                    AREXX_NoSlot, TRUE,
	                            AREXX_ErrorCode, &error,
                                    End)
      return TRUE;
    else {
	for (i=1;i<100;i++) {
	    sprintf(portname, "%s.%ld", CurrentState.RexxPort, i);
	    if (ARexx_Object = ARexxObject, AREXX_HostName, portname,
		                            AREXX_Commands, ARexxCommands,
		                            AREXX_NoSlot, TRUE,
		                            End) {
		strcpy(CurrentState.RexxPort,portname);
		return TRUE;
	    }
	}
    }
    return FALSE;
}
