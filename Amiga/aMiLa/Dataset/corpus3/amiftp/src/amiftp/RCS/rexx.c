head	1.795;
access;
symbols;
locks
	lilja:1.795
	lilja:0.667; strict;
comment	@ * @;


1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.736;

1.736
date	96.08.17.18.17.57;	author lilja;	state Exp;
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
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.152;

1.152
date	96.02.12.23.26.47;	author lilja;	state Exp;
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
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.760;

0.760
date	95.09.30.17.13.16;	author lilja;	state Exp;
branches;
next	0.723;

0.723
date	95.09.29.16.48.36;	author lilja;	state Exp;
branches;
next	0.692;

0.692
date	95.09.23.15.20.29;	author lilja;	state Exp;
branches;
next	0.671;

0.671
date	95.09.20.10.15.33;	author lilja;	state Exp;
branches;
next	0.667;

0.667
date	95.09.18.10.34.24;	author lilja;	state Exp;
branches;
next	0.623;

0.623
date	95.09.16.10.54.30;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.326;

0.326
date	95.06.13.12.52.15;	author lilja;	state Exp;
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
@ARexx-interface routines
@


1.795
log
@Stuff.
@
text
@/* RCS Id: $Id: rexx.c 1.736 1996/08/17 18:17:57 lilja Exp lilja $
   Locked version: $Revision: 1.736 $
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
		AddTail(&dllist, (struct Node *)curr);
	    }
	}
	i++;
    }
//    Printf("Getting %s in %s-mode\n",args->files[0],args->ascii?"ascii":"binary");

    if (DownloadFile(&dllist, NULL, args->ascii?ASCII:BINARY, 0)==TRANS_OK) {
	ac->ac_RC=0;
    }
    else {
	ac->ac_RC=RC_WARN;
    }
    for (node=ListHead(&dllist);ListEnd(node);node=ListNext(node)) {
	curr=(void *)node->ln_Name;
	free(curr);
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
    
    struct SiteNode *sn;
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

static int SetStemVar(struct RexxMsg *rexxmsg,char *value,char *stemname,...)
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

	if (FileList)
	  for (i=0,curr=(struct dirlist *)ListHead(FileList);
	       ListEnd((struct Node *)curr);
	       curr=(struct dirlist *)ListNext((struct Node *)curr),i++) {
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
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@d1 2
a2 2
/* RCS Id: $Id: rexx.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d406 2
a407 1
    struct Node Node;
d414 11
a424 6
    memset(&Node, 0, sizeof(struct Node));
    Node.ln_Name=args->file;
    NewList(&UploadList);
    AddHead(&UploadList, &Node);
    if (UploadFile(&UploadList, args->remote, args->ascii?ASCII:BINARY)==TRANS_OK) {
	ac->ac_RC=RC_OK;
d426 8
a433 2
    else {
	ac->ac_RC=RC_WARN;
d435 2
d450 1
d460 11
a470 4
	node=malloc(sizeof(struct Node));
	if (node) {
	    node->ln_Name=args->files[i];
	    AddTail(&UploadList, node);
d474 1
d482 1
a482 2
	while(node=RemHead(&UploadList))
	  free(node);
d484 1
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
/* RCS Id: $Id: rexx.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d180 5
d241 5
d544 1
a544 1
    err|=SetStemVar(rexxmsg, CurrentState.ScreenName, "%s.SCREEN", args->stem);
d563 1
a563 1
    err|=SetStemVar(rexxmsg, ping_server()?"0":"1", "%s.CONNECTED", args->stem);
d655 9
a663 4
    command(args->command);
    sprintf(errcode, "%ld", code);
    ac->ac_RC=RC_OK;
    SetRexxVar(rexxmsg, "RC2", errcode, strlen(errcode));
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
d78 1
a78 1
	    AddTail(&filelist,node);
d80 1
a80 1
		strmfp(loc_name,"T:",FilePart(file.name));
d110 1
a110 1
	if (!delete_remote(args->files[i],"DELE")) {
d145 5
a149 1
	    if (node=AllocListBrowserNode(1,LBNA_Selected,TRUE,LBNA_Column,0,LBNCA_Text,curr->name,TAG_DONE)) {
d151 1
a151 1
		AddTail(&dllist,(struct Node *)curr);
d158 1
a158 1
    if (DownloadFile(&dllist,NULL,args->ascii?ASCII:BINARY,0)==TRANS_OK) {
d181 1
a181 1
	strncpy(CurrentState.LastLVSite,curr_rexx.sn_Node.ln_Name,60);
d183 1
a183 1
	  strncpy(CurrentState.CurrentSite,curr_rexx.sn_SiteAddress,50);
d187 2
a188 1
	  strncpy(CurrentState.CurrentRemoteDir,curr_rexx.sn_RemoteDir,MAXPATHLEN+1);
d192 1
a192 1
	  strncpy(CurrentState.CurrentDLDir,curr_rexx.sn_LocalDir,256);
d196 1
a196 1
	  strncpy(CurrentState.LoginName,curr_rexx.sn_LoginName,30);
d200 1
a200 1
	  strncpy(CurrentState.Password,curr_rexx.sn_Password,30);
d212 1
a212 1
    memset(&sn,0,sizeof(struct SiteNode));
d250 1
a250 1
	strncpy(CurrentState.CurrentDLDir,args->dir,100);
d276 1
a276 1
    if (!change_remote_dir(args->parent?"..":args->dir,0)) {
d283 1
a283 1
		AddCacheEntry(head,CurrentState.CurrentRemoteDir);
d314 2
a315 1
	  if (!stricmp(args->name,sn->sn_Node.ln_Name) && strlen(args->name)==strlen(sn->sn_Node.ln_Name))
d355 2
a356 1
	      strncpy(CurrentState.CurrentRemoteDir,sn->sn_RemoteDir,MAXPATHLEN+1);
d360 1
a360 1
	      strncpy(CurrentState.CurrentDLDir,sn->sn_LocalDir,256);
d362 1
a362 1
	      strncpy(CurrentState.LoginName,sn->sn_LoginName,30);
d366 1
a366 1
	      strncpy(CurrentState.Password,sn->sn_Password,30);
d370 1
a370 1
	      strncpy(CurrentState.LastLVSite,sn->sn_Node.ln_Name,60);
d372 1
a372 1
	      strncpy(CurrentState.CurrentSite,sn->sn_SiteAddress,50);
d403 1
a403 1
    memset(&Node,0,sizeof(struct Node));
d406 2
a407 2
    AddHead(&UploadList,&Node);
    if (UploadFile(&UploadList,args->remote,args->ascii?ASCII:BINARY)==TRANS_OK) {
d438 1
a438 1
	    AddTail(&UploadList,node);
d443 1
a443 1
	if (UploadFile(&UploadList,NULL,args->ascii?ASCII:BINARY)==TRANS_OK) {
d473 1
d475 1
a475 1
	strncpy(CurrentState.CurrentSite,args->host,50);
d487 1
a487 1
      strncpy(CurrentState.CurrentRemoteDir,args->remotedir,MAXPATHLEN+1);
d489 1
a489 1
	strncpy(CurrentState.CurrentDLDir,args->localdir,256);
d493 1
a493 1
      strncpy(CurrentState.LoginName,args->username,30);
d495 1
a495 1
      strncpy(CurrentState.Password,args->password,30);
d498 1
a498 1
	if (strnicmp(args->quiet,"TRUE",4)==0)
d500 1
a500 1
	else if (strnicmp(args->quiet,"FALSE",5)==0)
d513 2
a514 2
    va_start(VarArgs,stemname);
    vsprintf(Name,stemname,VarArgs);
d517 1
a517 1
    return SetRexxVar(rexxmsg,Name,value,strlen(value));
d533 22
a554 18
    err|=SetStemVar(rexxmsg,Version,"%s.VERSION",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.ScreenName,"%s.SCREEN",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.CurrentSite,"%s.HOST",args->stem);
    sprintf(buff,"%ld",CurrentState.Port);
    err|=SetStemVar(rexxmsg,buff,"%s.PORT",args->stem);
    err|=SetStemVar(rexxmsg,MainPrefs.mp_ProxyServer?MainPrefs.mp_ProxyServer:"","%s.PROXYHOST",args->stem);
    sprintf(buff,"%ld",MainPrefs.mp_ProxyPort);
    err|=SetStemVar(rexxmsg,buff,"%s.PROXYPORT",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.Proxy?"1":"0","%s.USEPROXY",args->stem);
    sprintf(buff,"%s.ANONYMOUS",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.LoginName[0]?"0":"1","%s.ANONYMOUS",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.LoginName[0]?CurrentState.LoginName:"","%s.USERNAME",args->stem);
/*    sprintf(buff,"%s.PASSWORD",args->stem);
    err|=SetStemVar(rexxmsg,buff,"");*/
    err|=SetStemVar(rexxmsg,CurrentState.CurrentDLDir,"%s.LOCALDIR",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.CurrentRemoteDir,"%s.REMOTEDIR",args->stem);
    err|=SetStemVar(rexxmsg,ping_server()?"0":"1","%s.CONNECTED",args->stem);
    err|=SetStemVar(rexxmsg,SilentMode?"1":"0","%s.QUIET",args->stem);
d559 1
d564 17
a580 10
	    err|=SetStemVar(rexxmsg,sn->sn_Node.ln_Name,"%s.HOTLIST.%d.NAME",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_SiteAddress,"%s.HOTLIST.%d.ADDRESS",args->stem,i);
	    sprintf(buff,"%ld",sn->sn_Port);
	    err|=SetStemVar(rexxmsg,buff,"%s.HOTLIST.%d.PORT",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_LoginName?sn->sn_LoginName:"","%s.HOTLIST.%d.USERNAME",args->stem,i);
	    err|=SetStemVar(rexxmsg,"","%s.HOTLIST.%d.PASSWORD",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_LoginName?"0":"1","%s.HOTLIST.%d.ANONYMOUS",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_RemoteDir?sn->sn_RemoteDir:"","%s.HOTLIST.%d.REMOTEDIR",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_LocalDir?sn->sn_LocalDir:"","%s.HOTLIST.%d.LOCALDIR",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_Proxy?"1":"0","%s.HOTLIST.%d.USEPROXY",args->stem,i);
d582 2
a583 2
	sprintf(buff,"%ld",i);
	err|=SetStemVar(rexxmsg,buff,"%s.HOTLIST.COUNT",args->stem);
d588 1
d593 5
a597 4
	    err|=SetStemVar(rexxmsg,curr->name,"%s.FILELIST.%d.NAME",args->stem,i);
	    sprintf(buff,"%ld",curr->size);
	    err|=SetStemVar(rexxmsg,buff,"%s.FILELIST.%d.SIZE",args->stem,i);
	    err|=SetStemVar(rexxmsg,S_ISDIR(curr->mode)?"DIR":S_ISLNK(curr->mode)?"LINK":"FILE","%s.FILELIST.%d.TYPE",args->stem,i);
d599 2
a600 2
	sprintf(buff,"%ld",i);
	err|=SetStemVar(rexxmsg,buff,"%s.FILELIST.COUNT",args->stem);
d693 1
a693 1
	    sprintf(portname,"%s.%ld",CurrentState.RexxPort,i);
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
@d156 1
a156 1
    for (node=GetHead(&dllist);node;node=GetSucc(node)) {
d300 1
a300 1
    for (lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
d431 1
a431 1
    if (GetHead(&UploadList)) {
d543 1
a543 1
	for (i=0,lbn=GetHead(&SiteList);lbn;i++,lbn=GetSucc(lbn)) {
d565 3
a567 1
	  for (i=0,curr=(struct dirlist *)GetHead(FileList);curr;curr=(struct dirlist *)GetSucc((struct Node *)curr),i++) {
@


1.200
log
@GETATTR-hit fixed.
@
text
@d13 2
a14 1
static void __saveds __asm rexx_GetFile(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d31 2
a32 1
	if (node=AllocListBrowserNode(1,LBNA_Selected,TRUE,LBNA_Column,0,LBNCA_Text,file.name,TAG_DONE)) {
d34 1
a34 1
	    AddTail(&filelist,node);
d50 2
a51 1
static void __saveds __asm rexx_View(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d68 5
a72 1
	if (node=AllocListBrowserNode(1,LBNA_Selected,TRUE,LBNA_Column,0,LBNCA_Text,file.name,TAG_DONE)) {
d92 2
a93 1
static void __saveds __asm rexx_DeleteFile(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d116 2
a117 1
static void __saveds __asm rexx_MGetFile(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d164 2
a165 1
static void __saveds __asm rexx_Connect(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d224 2
a225 1
static void __saveds __asm rexx_Disconnect(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d233 2
a234 1
static void __saveds __asm rexx_LCD(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d249 2
a250 1
static void __saveds __asm rexx_CD(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d284 1
d290 2
a291 1
static void __saveds __asm rexx_Site(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d375 2
a376 1
static void __saveds __asm rexx_PutFile(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d405 2
a406 1
static void __saveds __asm rexx_MPutFile(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d446 2
a447 1
static void __saveds __asm rexx_SetAttr(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
a492 1
    ac->ac_RC2=0;
d509 2
a510 1
static void __saveds __asm rexx_GetAttr(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d583 2
a584 1
static void __saveds __asm rexx_Quit(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d591 2
a592 1
static void __saveds __asm rexx_Activate(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d600 2
a601 1
static void __saveds __asm rexx_Deactivate(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d609 2
a610 1
static void __saveds __asm rexx_FTPCommand(REGA0 struct ARexxCmd *ac, REGA1 struct RexxMsg *rexxmsg)
d615 1
d618 1
a618 1
    ac->ac_RC2=code;
d620 1
@


1.152
log
@ARexx viewcommand tried to view the wrong file.
@
text
@d5 2
a6 2
#define REG_A0 register __a0
#define REG_A1 register __a1
d13 1
a13 1
void __saveds __asm rexx_GetFile(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d48 1
a48 1
void __saveds __asm rexx_View(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d85 1
a85 1
void __saveds __asm rexx_DeleteFile(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d108 1
a108 1
void __saveds __asm rexx_MGetFile(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d134 1
a134 1
		AddTail(&dllist,curr);
d155 1
a155 1
void __saveds __asm rexx_Connect(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d214 1
a214 1
void __saveds __asm rexx_Disconnect(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d222 1
a222 1
void __saveds __asm rexx_LCD(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d237 1
a237 1
void __saveds __asm rexx_CD(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d276 1
a276 1
void __saveds __asm rexx_Site(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d360 1
a360 1
void __saveds __asm rexx_PutFile(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d389 1
a389 1
void __saveds __asm rexx_MPutFile(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d429 1
a429 1
void __saveds __asm rexx_SetAttr(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d479 1
a479 1
int SetStemVar(struct RexxMsg *rexxmsg,char *value,char *stemname,...)
d488 1
a488 1
    return(SetRexxVar(rexxmsg,Name,value,strlen(value)));
d492 1
a492 1
void __saveds __asm rexx_GetAttr(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d508 1
a508 1
    err|=SetStemVar(rexxmsg,MainPrefs.mp_ProxyServer,"%s.PROXYHOST",args->stem);
d520 1
a520 1
    err|=SetStemVar(rexxmsg,SilentMode?"TRUE":"FALSE","%s.QUIET",args->stem);
d565 1
a565 1
void __saveds __asm rexx_Quit(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d572 1
a572 1
void __saveds __asm rexx_Activate(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d580 1
a580 1
void __saveds __asm rexx_Deactivate(REG_A0 struct ARexxCmd *ac, REG_A1 struct RexxMsg *rexxmsg)
d588 12
d603 1
a603 1
      REXX_ACTIVATE, REXX_DEACTIVATE, REXX_VIEW};
d605 1
a605 1
struct ARexxCmd ARexxCommands[] =
d623 1
d627 1
a627 1
BOOL InitRexx()
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d69 1
a69 1
		strmfp(loc_name,"T:",file.name);
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
@a4 653
#if 0
static LONG rxopts[20];
struct ARCommand {
    char *Command;
    char *Template;
    int (*func)();
};

static int ARGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARMGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARMPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARDeleteFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARConnect(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARDisconnect(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARLcd(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARCd(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARSite(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARQuit(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARGetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARSetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARActivate(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARDeactivate(struct RexxMsg *rexxmsg,long *res1, long *res2);
static int ARTest(struct RexxMsg *rexxmsg, long *res1,long *rest2);

static struct ARCommand arc[]={
    "GETATTR","STEM/A,HOTLIST/S,FILELIST/S",ARGetAttr,
    "SETATTR","HOST/K,PORT/K,PROXYHOST/K,PROXYPORT/K,USEPROXY/S,REMOTEDIR/K,LOCALDIR/K,USERNAME/K,PASSWORD/K,ANONYMOUS/S",ARSetAttr,
    "GET","ASCII/S,BIN/S,FILE/A,LOCAL",ARGetFile,
    "PUT","ASCII/S,BIN/S,FILE,REMOTE",ARPutFile,
    "MGET","ASCII/S,BIN/S,FILE/M",ARMGetFile,
    "MPUT","ASCII/S,BIN/S,FILE/M",ARMPutFile,
    "CONNECT","NOSCAN/S",ARConnect,
    "DISCONNECT",NULL,ARDisconnect,
    "LCD","PARENT/S,DIR",ARLcd,
    "CD","NOSCAN/S,PARENT/S,DIR",ARCd,
    "SITE","SITE/A/F",ARSite,
    "ACTIVATE",NULL,ARActivate,
    "DEACTIVATE",NULL,ARDeactivate,
    "QUIT",NULL,ARQuit,
    "DELETE","FILE/M",ARDeleteFile,
    "CAFE","ASCII/K/N,BIN/K/N",ARTest,
    NULL,NULL,NULL
};

struct SiteNode curr_rexx;

int HandleRexxMsg()
{
    struct RexxMsg *rmptr;
    int end=1;
    struct RDArgs rdargs;

    rmptr=(struct RexxMsg *)GetMsg(RexxPort);
    if (IsRexxMsg(rmptr)) {
	struct ReadArgs *rd;
	struct ARCommand *com=arc;
	char *buf=0,echar[]=" ";
	int res=0;
	long res1=RC_OK,res2=0;
	memset(&rdargs,0,sizeof(rdargs));
	rdargs.RDA_Source.CS_Buffer=strchr(rmptr->rm_Args[0],' ');
	if (rdargs.RDA_Source.CS_Buffer) {
	    rdargs.RDA_Source.CS_Buffer++;
	    buf=malloc(strlen(rdargs.RDA_Source.CS_Buffer)+1);
	    strcpy(buf,rdargs.RDA_Source.CS_Buffer);
	    strcat(buf,"\n");
	    rdargs.RDA_Source.CS_Buffer=buf;
	}
	else rdargs.RDA_Source.CS_Buffer=echar;
	rdargs.RDA_Source.CS_Length=rdargs.RDA_Source.CS_Buffer?strlen(rdargs.RDA_Source.CS_Buffer):0;
	rdargs.RDA_Flags|=RDAF_NOPROMPT;
	rmptr;
	for (;com->Command;com++) {
	    if (strncmp(com->Command,rmptr->rm_Args[0],strlen(com->Command))==0) {
/*		Printf("com->Command '%s' com->Template '%s' rdargs.RDA_Source.CS_Buffer '%s'\n",
		       com->Command,
		       com->Template?com->Template:"NULL",
		       rdargs.RDA_Source.CS_Buffer?rdargs.RDA_Source.CS_Buffer:"NULL");
*/		       
		if (com->Template) {/* && rdargs.RDA_Source.CS_Buffer) {*/
		    memset(&rxopts,0,10*4);
		    if ((rd=ReadArgs(com->Template,&rxopts,&rdargs))) {
			if (com->func)
			  end=com->func(rmptr,&res1,&res2);
			FreeArgs(rd);
//			Printf("res1=%ld @@ %ld\n",res1,__LINE__);
		    }
		    else {
			res1=RC_ERROR;
			res2=IoErr();
//			Printf("res1=%ld @@ %ld\n",res1,__LINE__);
		    }
		}
		else if (!com->Template) {/* && !rdargs.RDA_Source.CS_Buffer) {*/
		    if (com->func)
		      end=com->func(rmptr,&res1,&res2);
//			Printf("res1=%ld @@ %ld\n",res1,__LINE__);
		}
		else {
		    res1=RC_ERROR;
		    res2=ERROR_TOO_MANY_ARGS;
//			Printf("res1=%ld @@ %ld\n",res1,__LINE__);
		}
		goto out; /* Should be a break */
	    }
	}
      out:
//			Printf("res1=%ld @@ %ld\n",res1,__LINE__);
	if (!com->Command)
	  res1 = 1;
//	Printf("res1=%ld @@ %ld\n",res1,__LINE__);
	if (buf)
	  free(buf);
	rmptr->rm_Result1 = res1;
	rmptr->rm_Result2 = res2;
	ReplyMsg((struct Message *)rmptr);
    }
    return(end);
}

static int ARTest(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long ascii;
	long bin;
    } *args=(void *)&rxopts[0];
    *res1=*(long *)args->ascii;
    *res2=*(long *)args->bin;
}

static int ARGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char *file;
        char *local;
    } *args=(void *)&rxopts[0];
    struct dirlist file;
    struct List filelist;
    struct Node *node;

    NewList(&filelist);
    file.name=args->file;
    file.size=0;
    file.mode=S_IFREG;
    if (connected) {
	if (node=AllocListBrowserNode(1,LBNA_Selected,TRUE,LBNA_Column,0,LBNCA_Text,file.name,TAG_DONE)) {
	    node->ln_Name=(void *)&file;
	    AddTail(&filelist,node);
	    if (DownloadFile(&filelist,args->local,args->ascii?ASCII:BINARY,0)==TRANS_OK) {
		*res1=RC_OK;
	    }
	    else {
		*res1=RC_WARN;
	    }
	    FreeListBrowserNode(node);
	}
	else *res1=RC_WARN;
    }
    else {
	*res1=RC_WARN;
    }
    return(1);
}

static int ARDeleteFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	char **files;
    } *args=(void *)&rxopts[0];
    int i=0;

    if (!connected) {
	*res1=RC_WARN;
	return (1);
    }

    while(args->files[i]) {
	if (!delete_remote(args->files[i],"DELE")) {
	    *res1=RC_WARN;
	    return (1);
	}
	i++;
    }
    *res1=RC_OK;
    return (1);
}

static int ARMGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char **files;
    } *args=(void *)&rxopts[0];
    struct dirlist *curr;
    struct List dllist;
    struct Node *node;
    int i=0;

    if (!connected) {
	*res1=RC_WARN;
	return (1);
    }

    NewList(&dllist);
    while(args->files[i]) {
	curr=malloc(sizeof(struct dirlist));
	if (curr) {
	    curr->name=args->files[i];
	    curr->size=0;
	    curr->mode=S_IFREG;
	    if (node=AllocListBrowserNode(1,LBNA_Selected,TRUE,LBNA_Column,0,LBNCA_Text,curr->name,TAG_DONE)) {
		node->ln_Name=(void *)curr;
		AddTail(&dllist,curr);
	    }
	}
	i++;
    }
//    Printf("Getting %s in %s-mode\n",args->files[0],args->ascii?"ascii":"binary");

    if (DownloadFile(&dllist,NULL,args->ascii?ASCII:BINARY,0)==TRANS_OK) {
	*res1=0;
    }
    else {
	*res1=RC_WARN;
    }
    for (node=GetHead(&dllist);node;node=GetSucc(node)) {
	curr=(void *)node->ln_Name;
	free(curr);
	FreeListBrowserNode(node);
    }
    return(1);
}

static int ARConnect(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long noscan;
    }*args=(void *)&rxopts[0];
    struct SiteNode sn;

    if (curr_rexx.sn_Node.ln_Name) {
	strncpy(CurrentState.LastLVSite,curr_rexx.sn_Node.ln_Name,60);
	if (curr_rexx.sn_SiteAddress)
	  strncpy(CurrentState.CurrentSite,curr_rexx.sn_SiteAddress,50);
	else
	  CurrentState.CurrentSite[0]=0;
	if (curr_rexx.sn_RemoteDir)
	  strncpy(CurrentState.CurrentRemoteDir,curr_rexx.sn_RemoteDir,MAXPATHLEN+1);
	else
	  CurrentState.CurrentRemoteDir[0]=0;
	if (curr_rexx.sn_LocalDir)
	  strncpy(CurrentState.CurrentDLDir,curr_rexx.sn_LocalDir,256);
	else
	  CurrentState.CurrentDLDir[0]=0;
	if (curr_rexx.sn_LoginName)
	  strncpy(CurrentState.LoginName,curr_rexx.sn_LoginName,30);
	else
	  CurrentState.LoginName[0]=0;
	if (curr_rexx.sn_Password)
	  strncpy(CurrentState.Password,curr_rexx.sn_Password,30);
	else
	  CurrentState.Password[0]=0;

	CurrentState.Proxy=curr_rexx.sn_Proxy;
	CurrentState.Port=curr_rexx.sn_Port;

    }
    if (!strlen(CurrentState.CurrentSite)) {
	*res1=RC_WARN;
	return(1);
    }
    memset(&sn,0,sizeof(struct SiteNode));
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
	*res1=RC_OK;
    }
    else {
	*res1=RC_WARN;
    }
    if (sn.sn_RemoteDir)
      free(sn.sn_RemoteDir);
    return(1);
}

static int ARDisconnect(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    quit_ftp();
    UpdateMainButtons(MB_DISCONNECTED);
    *res1=0;
    return(1);
}

static int ARLcd(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long parent;
	char *dir;
    } *args=(void *)&rxopts[0];
    if (args->dir) {
	strncpy(CurrentState.CurrentDLDir,args->dir,100);
	UpdateLocalDir(CurrentState.CurrentDLDir);
    }
    /* Todo: Fix Parent-mode */
    *res1=RC_OK;
    return(1);
}

static int ARCd(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long noscan;
	long parent;
	char *dir;
    } *args=(void *)&rxopts[0];
    struct List *head;

    if (!args->dir && !args->parent) {
	*res1=RC_WARN;
	return(1);
    }
    if (!connected) {
	*res1=RC_WARN;
	  return(1);
    }
    if (!change_remote_dir(args->parent?"..":args->dir,0)) {
	if (!args->noscan) {
	    if (head=LookupCache(CurrentState.CurrentRemoteDir)) {
		FileList=head;
	    }
	    else if (head=read_remote_dir()) {
		FileList=head;
		AddCacheEntry(head,CurrentState.CurrentRemoteDir);
	    }
	}
	    
	DetachToolList();
	AttachToolList(TRUE);
	*res1=RC_OK;
    }
    else {
	*res1=RC_WARN;
    }
    UpdateMainButtons(MB_NONESELECTED);
    return(1);
}

static int ARSite(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	char *name;
    } *args = (void *)&rxopts[0];
    
    struct SiteNode *sn;
    struct Node *lbn;

    for (lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData,&sn,
				TAG_DONE);
	if (sn) /* Fix: broken */
	  if (!stricmp(args->name,sn->sn_Node.ln_Name) && strlen(args->name)==strlen(sn->sn_Node.ln_Name))
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
	      strncpy(CurrentState.CurrentRemoteDir,sn->sn_RemoteDir,MAXPATHLEN+1);
	    else
	      CurrentState.CurrentRemoteDir[0]=0;
	    if (sn->sn_LocalDir)
	      strncpy(CurrentState.CurrentDLDir,sn->sn_LocalDir,256);
	    if (sn->sn_LoginName)
	      strncpy(CurrentState.LoginName,sn->sn_LoginName,30);
	    else
	      CurrentState.LoginName[0]=0;
	    if (sn->sn_Password)
	      strncpy(CurrentState.Password,sn->sn_Password,30);
	    else
	      CurrentState.Password[0]=0;
	    if (sn->sn_Node.ln_Name)
	      strncpy(CurrentState.LastLVSite,sn->sn_Node.ln_Name,60);
	    if (sn->sn_SiteAddress)
	      strncpy(CurrentState.CurrentSite,sn->sn_SiteAddress,50);
	    CurrentState.Proxy=sn->sn_Proxy;
	    CurrentState.Port=sn->sn_Port;
	    if (sn->sn_Anonymous)
	      CurrentState.LoginName[0]=0;
	}
	*res1=RC_OK;
    }
    else {
	*res1=RC_WARN;
    }
    return(1);
}

static int ARPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char *file;
	char *remote;
    } *args=(void *)&rxopts[0];
    struct List UploadList;
    struct Node Node;

    if (!connected) {
	*res1=RC_WARN;
	return (1);
    }

    memset(&Node,0,sizeof(struct Node));
    Node.ln_Name=args->file;
    NewList(&UploadList);
    AddHead(&UploadList,&Node);
    if (UploadFile(&UploadList,args->remote,args->ascii?ASCII:BINARY)==TRANS_OK) {
	*res1=RC_OK;
    }
    else {
	*res1=RC_WARN;
    }
    return(1);
}

static int ARMPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char **files;
    } *args=(void *)&rxopts[0];
    struct List UploadList;
    struct Node *node;
    int i=0;

    if (!connected) {
	*res1=RC_WARN;
	return (1);
    }

    NewList(&UploadList);
    while(args->files[i]) {
	node=malloc(sizeof(struct Node));
	if (node) {
	    node->ln_Name=args->files[i];
	    AddTail(&UploadList,node);
	}
	i++;
    }
    if (GetHead(&UploadList)) {
	if (UploadFile(&UploadList,NULL,args->ascii?ASCII:BINARY)==TRANS_OK) {
	    *res1=RC_OK;
	}
	else {
	    *res1=RC_WARN;
	}
	while(node=RemHead(&UploadList))
	  free(node);
    }
    return(1);
}

static int ARSetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2)
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
    }*args = (void *)&rxopts[0];
    if (args->host) {
	strncpy(CurrentState.CurrentSite,args->host,50);
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
      strncpy(CurrentState.CurrentRemoteDir,args->remotedir,MAXPATHLEN+1);
    if (args->localdir)
      strncpy(CurrentState.CurrentDLDir,args->localdir,256);
    if (args->username)
      strncpy(CurrentState.LoginName,args->username,30);
    if (args->password)
      strncpy(CurrentState.Password,args->password,30);
    *res1=RC_OK;
    *res2=0;
    return(1);
}

static int SetStemVar(struct RexxMsg *rexxmsg,char *value,char *stemname,...)
{
    UBYTE Name[256];
    va_list VarArgs;

    va_start(VarArgs,stemname);
    vsprintf(Name,stemname,VarArgs);
    va_end(VarArgs);
    return(SetRexxVar(rexxmsg,Name,value,strlen(value)));
}


static int ARGetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	char *stem;
	long hotlist;
	long filelist;
    } *args = (void *)&rxopts[0];
    char buff[100];
    long err=0;

    Printf("dds\n");
    err|=SetStemVar(rexxmsg,Version,"%s.VERSION",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.ScreenName,"%s.SCREEN",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.CurrentSite,"%s.HOST",args->stem);
    sprintf(buff,"%ld",CurrentState.Port);
    err|=SetStemVar(rexxmsg,buff,"%s.PORT",args->stem);
    err|=SetStemVar(rexxmsg,MainPrefs.mp_ProxyServer,"%s.PROXYHOST",args->stem);
    sprintf(buff,"%ld",MainPrefs.mp_ProxyPort);
    err|=SetStemVar(rexxmsg,buff,"%s.PROXYPORT",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.Proxy?"1":"0","%s.USEPROXY",args->stem);
    sprintf(buff,"%s.ANONYMOUS",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.LoginName[0]?"0":"1","%s.ANONYMOUS",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.LoginName[0]?CurrentState.LoginName:"","%s.USERNAME",args->stem);
/*    sprintf(buff,"%s.PASSWORD",args->stem);
    err|=SetStemVar(rexxmsg,buff,"");*/
    err|=SetStemVar(rexxmsg,CurrentState.CurrentDLDir,"%s.LOCALDIR",args->stem);
    err|=SetStemVar(rexxmsg,CurrentState.CurrentRemoteDir,"%s.REMOTEDIR",args->stem);
    err|=SetStemVar(rexxmsg,ping_server()?"0":"1","%s.CONNECTED",args->stem);
    if (args->hotlist) {
	int i;
	struct SiteNode *sn;
	struct Node *lbn;
	for (i=0,lbn=GetHead(&SiteList);lbn;i++,lbn=GetSucc(lbn)) {
	    GetListBrowserNodeAttrs(lbn,
				    LBNA_UserData, &sn,
				    TAG_DONE);
	    err|=SetStemVar(rexxmsg,sn->sn_Node.ln_Name,"%s.HOTLIST.%d.NAME",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_SiteAddress,"%s.HOTLIST.%d.ADDRESS",args->stem,i);
	    sprintf(buff,"%ld",sn->sn_Port);
	    err|=SetStemVar(rexxmsg,buff,"%s.HOTLIST.%d.PORT",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_LoginName?sn->sn_LoginName:"","%s.HOTLIST.%d.USERNAME",args->stem,i);
	    err|=SetStemVar(rexxmsg,"","%s.HOTLIST.%d.PASSWORD",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_LoginName?"0":"1","%s.HOTLIST.%d.ANONYMOUS",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_RemoteDir?sn->sn_RemoteDir:"","%s.HOTLIST.%d.REMOTEDIR",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_LocalDir?sn->sn_LocalDir:"","%s.HOTLIST.%d.LOCALDIR",args->stem,i);
	    err|=SetStemVar(rexxmsg,sn->sn_Proxy?"1":"0","%s.HOTLIST.%d.USEPROXY",args->stem,i);
	}
	sprintf(buff,"%ld",i);
	err|=SetStemVar(rexxmsg,buff,"%s.HOTLIST.COUNT",args->stem);
    }
    if (args->filelist) {
	int i;
	struct dirlist *curr;
	if (FileList)
	  for (i=0,curr=(struct dirlist *)GetHead(FileList);curr;curr=(struct dirlist *)GetSucc((struct Node *)curr),i++) {
	    err|=SetStemVar(rexxmsg,curr->name,"%s.FILELIST.%d.NAME",args->stem,i);
	    sprintf(buff,"%ld",curr->size);
	    err|=SetStemVar(rexxmsg,buff,"%s.FILELIST.%d.SIZE",args->stem,i);
	    err|=SetStemVar(rexxmsg,S_ISDIR(curr->mode)?"DIR":S_ISLNK(curr->mode)?"LINK":"FILE","%s.FILELIST.%d.TYPE",args->stem,i);
	  }
	sprintf(buff,"%ld",i);
	err|=SetStemVar(rexxmsg,buff,"%s.FILELIST.COUNT",args->stem);
    }
    if (err)
      *res1=RC_WARN;
    else
      *res1=RC_OK;
    *res2=err;
    return(1);
}

static int ARQuit(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    *res1=RC_OK;
    return(0);
}

static int ARActivate(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    *res1=RC_OK;
    if (!MainWindow)
      MainWindow=CA_OpenWindow(MainWin_Object);
    return(1);
}

static int ARDeactivate(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    *res1=RC_OK;
    if (CA_Iconify(MainWin_Object))
      MainWindow=NULL;
    return(1);
}
#else
a639 1
#endif
@


0.1343
log
@Removed some redudant things from AllocListbrowserNode()
Gadgets no longer flicker since I keep track of the state. Thought ClassAct did that, but no...
Added one tick to the fuelgauge, now 11 ticks => 10 intervals.
@
text
@d3 1
d5 1
d575 2
a576 1
    err|=SetStemVar(rexxmsg,"1.0","%s.VERSION",args->stem);
d657 637
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d374 1
a374 1
	if (sn)
@


0.760
log
@Added ARexx DELETE and GETATTR FILELIST.
@
text
@d2 1
d144 2
a149 1
    file.dl_Node.ln_Type=1;
d151 10
a160 6
	AddTail(&filelist,(struct Node *)&file);
	if (DownloadFile(&filelist,args->local,args->ascii?ASCII:BINARY,0)==TRANS_OK) {
	    *res1=RC_OK;
	}
	else {
	    *res1=RC_WARN;
d162 1
d202 1
a215 1
	    curr->dl_Node.ln_Type=1;
d217 4
a220 1
	    AddTail(&dllist,curr);
d232 5
a236 2
    for (curr=(struct dirlist *)GetHead(&dllist);curr;curr=(struct dirlist *)GetSucc((struct Node *)curr))
      free(curr);
d351 1
a351 2
	AttachToolList();
	RefreshWinGad();
d368 10
a377 3
    for (sn=(struct SiteNode *)GetHead(&SiteList);sn;sn=(struct SiteNode *)GetSucc((struct Node *)sn))
      if (!stricmp(args->name,sn->sn_Node.ln_Name) && strlen(args->name)==strlen(sn->sn_Node.ln_Name))
	break;
d593 5
a597 1
	for (i=0,sn=(struct SiteNode *)GetHead(&SiteList);sn;i++,sn=(struct SiteNode *)GetSucc((struct Node *)sn)) {
d642 2
d650 3
a652 1
    return(2);
@


0.723
log
@AmiFTP adds .i if the ARexx-port is present.
@
text
@d14 1
d28 1
a28 1
    "GETATTR","STEM/A,HOTLIST/S",ARGetAttr,
d42 1
d163 23
d549 1
d588 13
@


0.692
log
@Release version.
@
text
@d3 1
a3 1
static LONG rxopts[10];
@


0.671
log
@"View" on links downloaded it twice.
@
text
@d265 1
d280 1
@


0.667
log
@Datatransferred was updated one time too much.
@
text
@d24 1
d41 1
d121 10
d148 9
a156 1
	DownloadFile(&filelist,args->local,args->ascii?ASCII:BINARY,0);
d172 5
d190 7
a196 1
    DownloadFile(&dllist,NULL,args->ascii?ASCII:BINARY,0);
d250 6
a255 1
    ConnectSite(&sn,args->noscan);
d295 4
a298 2
    if (!connected)
      return(1);
d313 4
d391 1
d409 6
d419 6
a424 1
    UploadFile(&UploadList,args->remote,args->ascii?ASCII:BINARY);
d439 5
d454 6
a459 1
	UploadFile(&UploadList,NULL,args->ascii?ASCII:BINARY);
d562 1
a562 1
      *res1=RC_ERROR;
d571 1
d577 1
d583 1
@


0.623
log
@Added menuitem TransferMode->Binary/ASCII
@
text
@d196 5
d216 3
d296 1
d303 1
d312 2
d336 4
d346 2
d432 4
a435 2
    if (args->username);
    if (args->password);
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d132 2
a133 1
    file.mode=S_IFMT|S_IFREG;
d136 1
a136 1
	DownloadFile(&filelist,args->local,args->ascii?0:1,0);
d159 1
a159 1
	    curr->mode=S_IFMT|S_IFREG;
d165 1
a165 1
    DownloadFile(&dllist,NULL,args->ascii?0:1,0);
d352 1
a352 1
    UploadFile(&UploadList,args->remote,args->ascii?0:1);
d377 1
a377 1
	UploadFile(&UploadList,NULL,args->ascii?0:1);
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d128 2
d132 5
a136 2
    if (connected)
      DownloadFile(&file,args->local,NULL,args->ascii?0:1,0);
d158 1
d164 1
a164 1
    DownloadFile(NULL,NULL,&dllist,args->ascii?0:1,0);
@


0.371
log
@Localized source.
@
text
@d357 1
a357 1
    struct Node *node,*next;
d371 2
a372 7
	node=GetHead(&UploadList);
	while(node) {
	    next=GetSucc(node);
	    Remove(node);
	    free(node);
	    node=next;
	}
@


0.326
log
@Links are now parsed to linkname and (link)
Upload via ARexx should be finished now
@
text
@d3 1
a3 1
LONG rxopts[10];
d10 14
a23 14
int ARGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARMGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARMPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARConnect(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARDisconnect(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARLcd(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARCd(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARSite(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARQuit(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARGetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARSetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARActivate(struct RexxMsg *rexxmsg,long *res1, long *res2);
int ARDeactivate(struct RexxMsg *rexxmsg,long *res1, long *res2);
d25 1
a25 1
struct ARCommand arc[]={
d119 1
a119 1
int ARGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
d135 1
a135 1
int ARMGetFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
d164 1
a164 1
int ARConnect(struct RexxMsg *rexxmsg,long *res1, long *res2)
d210 1
a210 1
int ARDisconnect(struct RexxMsg *rexxmsg,long *res1, long *res2)
d217 1
a217 1
int ARLcd(struct RexxMsg *rexxmsg,long *res1, long *res2)
d231 1
a231 1
int ARCd(struct RexxMsg *rexxmsg,long *res1, long *res2)
d265 1
a265 1
int ARSite(struct RexxMsg *rexxmsg,long *res1, long *res2)
d331 1
a331 1
int ARPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
d349 1
a349 1
int ARMPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
d382 1
a382 1
int ARSetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2)
d419 1
a419 1
int SetStemVar(struct RexxMsg *rexxmsg,char *value,char *stemname,...)
d431 1
a431 1
int ARGetAttr(struct RexxMsg *rexxmsg,long *res1, long *res2)
d483 1
a483 1
int ARQuit(struct RexxMsg *rexxmsg,long *res1, long *res2)
d488 1
a488 1
int ARActivate(struct RexxMsg *rexxmsg,long *res1, long *res2)
d493 1
a493 1
int ARDeactivate(struct RexxMsg *rexxmsg,long *res1, long *res2)
a496 1

@


0.322
log
@Dir-cache added.
Delete added.
@
text
@a118 14
int ARPutFile(struct RexxMsg *rexxmsg,long *res1, long *res2)
{
    struct ArgStruct {
	long ascii;
	long bin;
	char *file;
	char *remote;
    } *args=(void *)&rxopts[0];

    Printf("Putting '%s' in %s-mode to '%s'\n",args->file?args->file:"",args->ascii?"ascii":"binary",args->remote?args->remote:"");

    return(1);
}

d331 18
d370 1
a370 1
	UploadFile(&UploadList);
@


0.284
log
@First RCS version.
@
text
@d145 1
a145 1
      DownloadFile(&file,args->local,NULL,args->ascii?0:1);
d172 1
a172 1
    DownloadFile(NULL,NULL,&dllist,args->ascii?0:1);
d262 1
a262 3
	    if (head=read_remote_dir()) {
		free_dirlist(FileList);
		free(FileList);
d265 4
d347 28
@
