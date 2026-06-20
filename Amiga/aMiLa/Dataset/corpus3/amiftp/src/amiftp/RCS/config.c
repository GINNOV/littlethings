head	1.815;
access;
symbols;
locks
	lilja:1.815; strict;
comment	@ * @;


1.815
date	96.12.14.12.13.03;	author lilja;	state Exp;
branches;
next	1.795;

1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.736;

1.736
date	96.08.17.18.17.57;	author lilja;	state Exp;
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
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
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
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.728;

0.728
date	95.09.30.10.27.47;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.425;

0.425
date	95.07.24.18.19.29;	author lilja;	state Exp;
branches;
next	0.413;

0.413
date	95.07.23.13.03.53;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
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
@Read/write AmiFTP.prefs
@


1.815
log
@Fixed the proxy-port settings.
Replaced % with @@ since the proxy actually seems to work with other
ftpproxies.
Fixed the Height/Width save-problem.
@
text
@/* RCS Id: $Id: config.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
*/

#include "AmiFTP.h"
#include "gui.h"

extern BOOL DEBUG;

#define FWPREFSVERSION 0

#define BUFSIZE 20480
#define ID_FWSO MAKE_ID('F','W','S','O')
#define ID_FWPR MAKE_ID('F','W','P','R')
#define FWSO 1L
#define FWPR 2L

ULONG stopchunks[]={
    ID_PREF,ID_FWSO,
    ID_PREF,ID_FWPR
  };
#define FWOBJECTS 2

struct PrefHeader PrefHdrChunk={FWPREFSVERSION,0,0};

struct SitePrefsObject {
    ULONG spo_StringBits;
    ULONG spo_Flags;
    int   spo_OsType:3;
    int   spo_Port:16;
    int   spo_Proxy:1;
    int   spo_HotList:1;
    int   spo_Anonymous:1;
    int   spo_MenuType:2;
    int   spo_ShowChildren:1;
    int   spo_BarLabel:1;
    int   spo_ADT:1;
    int   spo_unused:5;
    ULONG spo_lunused[4];
};

#define FWSO_NAME      (1L<<0)
#define FWSO_REMOTEDIR (1L<<1)
#define FWSO_LOCALDIR  (1L<<2)
#define FWSO_DIRSTRING (1L<<3)
#define FWSO_LOGINNAME (1L<<4)
#define FWSO_PASSWORD  (1L<<5)
#define FWSO_ALIASNAME (1L<<6)

struct MainPrefs MainPrefs;

struct MainPrefsObject {
    ULONG mpo_StringBits;
    int   mpo_Showdotfiles:1;
    int   mpo_ProxyPort:16;
    int   mpo_DefaultProxy:1;
    int   mpo_IgnoreCase:1;
    int   mpo_Cookie:8;
    int   mpo_CacheSize:4;
    int   mpo_ShowAllADTFiles:1;
    WORD  mpo_LeftEdge;
    WORD  mpo_TopEdge;
    WORD  mpo_Width;
    WORD  mpo_Height;
    ULONG mpo_LastAminetDate;
    ULONG mpo_BufferSize;
    int   mpo_PreserveAminetDir:1;
    int   mpo_DeleteFiles:1;
    int   mpo_DisplayBeep:1;
    int   mpo_ShowMOTD:1;
    int   mpo_GetReadme:1;
    int   mpo_SortMode:4;
    int   mpo_ShowButtons:1;
    int   mpo_ShowToolBar:1;
    int   mpo_UseCustomFonts:1;
    int   mpo_OpenOnNamedScreen:1;
    int   mpo_unused:19;
    ULONG mpo_LastAMOTD;
    ULONG mpo_Reserved[1];
};

#define FWPR_LOCALDIR     (1L<<0)
#define FWPR_ANONPW       (1L<<1)
#define FWPR_LOGINNAME    (1L<<2)
#define FWPR_DEFSITE      (1L<<3)
#define FWPR_PROXYHOST    (1L<<4)
#define FWPR_VIEWCMD      (1L<<5)
#define FWPR_ADTPATTERN   (1L<<6)
#define FWPR_FONTNAME     (1L<<7)
#define FWPR_LISTFONTNAME (1L<<8)
#define FWPR_PUBSCREEN    (1L<<9)

struct List SiteList;
char *fontname;
char *listfontname;

BOOL WriteConfigFile(char *filename);
BOOL ReadConfigFile(char *filename);
UBYTE GetPWCookie(void);

static struct Node *ReadSiteNode(UBYTE *buf);
static BOOL WriteSiteNode(struct IFFHandle *iff, UBYTE *buf, struct Node *node);
void FreeSiteNode(struct SiteNode *sn);
static char *GetConfigStr(UBYTE **buf);
static BOOL PutConfigStr(char *s, UBYTE **buf);
static void ReadMainPrefs(UBYTE *buf);
static BOOL WriteMainPrefs(struct IFFHandle *iff, UBYTE *buf, struct MainPrefs *mp);
static char *ConvertFontName(UWORD *size, char *source);

BOOL ReadConfigFile(char *filename)
{
    UBYTE *configbuf;
    BOOL rc=FALSE;

    if (configbuf=malloc(BUFSIZE)) {
	struct IFFHandle *iff;
	if (iff=AllocIFF()) {
	    rc=TRUE;

	    if (iff->iff_Stream=Open(filename,MODE_OLDFILE)) {
		InitIFFasDOS(iff);

		if (!OpenIFF(iff,IFFF_READ)) {
		    if (!ParseIFF(iff,IFFPARSE_STEP)) {
			struct ContextNode *cn;

			if ((cn=CurrentChunk(iff)) && (cn->cn_ID==ID_FORM) &&
			    (cn->cn_Type==ID_PREF) &&
			    !PropChunk(iff,ID_PREF,ID_PRHD) &&
			    !StopChunks(iff,(LONG *)stopchunks,FWOBJECTS) &&
			    !StopOnExit(iff,ID_PREF,ID_FORM) &&
			    !ParseIFF(iff,IFFPARSE_SCAN)) {
			    struct StoredProperty *sp;
			    if (sp=FindProp(iff,ID_PREF,ID_PRHD)) {
				struct PrefHeader *ph=(struct PrefHeader *)sp->sp_Data;
				if (ph->ph_Version==FWPREFSVERSION) {
				    do {
					if (cn=CurrentChunk(iff)) {
					    LONG type;

					    switch(cn->cn_ID) {
					      case ID_FWSO:
						type = FWSO;
						break;
					      case ID_FWPR:
						type = FWPR;
						break;
					      default:
						type=-1;
						break;
					    }

					    if (type!=-1) {
						ULONG size=cn->cn_Size;

						if (ReadChunkBytes(iff,configbuf,size)==size) {
						    struct SiteNode *node;
						    if (type == FWPR)
						      ReadMainPrefs(configbuf);
						    else {
							if (node=(struct SiteNode *)ReadSiteNode(configbuf)) {
							    if (!node->sn_Node.ln_Name) {
								if (node->sn_SiteAddress)
								  node->sn_Node.ln_Name=strdup(node->sn_SiteAddress);
								else
								  node->sn_Node.ln_Name=strdup("");
							    }
							    AddLBNTail(&SiteList,node);
							}
						    }
						}
					    }
					}
				    } while(!ParseIFF(iff,IFFPARSE_SCAN));
				    if (GetHead(&SiteList))
				      FixSiteList();
				}
			    }
			}
		    }
		    CloseIFF(iff);
		}
		Close(iff->iff_Stream);
	    }
	    FreeIFF(iff);
	}
	free(configbuf);
    }

    if (fontname) {
	MainPrefs.mp_FontName=ConvertFontName(&MainPrefs.mp_FontSize, fontname);
	free(fontname);
	fontname=NULL;
    }

    if (listfontname) {
	MainPrefs.mp_ListFontName=ConvertFontName(&MainPrefs.mp_ListFontSize, listfontname);
	free(listfontname);
	listfontname=NULL;
    }
    return rc;
}

BOOL WriteConfigFile(char *filename)
{
    UBYTE *configbuf;	
    BOOL rc=FALSE;

    if (configbuf=malloc(BUFSIZE)) {
	struct IFFHandle *iff;

	if (iff=AllocIFF()) {
	    if (iff->iff_Stream=Open(filename,MODE_NEWFILE)) {
		InitIFFasDOS(iff);
		if (!OpenIFF(iff,IFFF_WRITE)) {

		    /* Push FORM IFF chunk */
		    if (!PushChunk(iff,ID_PREF,ID_FORM,IFFSIZE_UNKNOWN)) {

			/* Write PRHD IFF chunk */
			if (!PushChunk(iff,0,ID_PRHD,sizeof(struct PrefHeader)) &&
			    (WriteChunkBytes(iff,(UBYTE *)&PrefHdrChunk,sizeof(struct PrefHeader))==sizeof(struct PrefHeader)) &&
			    !PopChunk(iff))
			  rc=TRUE;

			if (rc) {
			    struct SiteNode *node;
			    struct Node *lbn;
			    WriteMainPrefs(iff,configbuf,&MainPrefs);
			    lbn=GetHead(&SiteList);
			    while(lbn&&rc) {
				ULONG flags;
				GetListBrowserNodeAttrs(lbn,
							LBNA_UserData, &node,
							LBNA_Flags,&flags,
							TAG_DONE);
				if (node) {
				    node->sn_ShowChildren=flags&LBFLG_SHOWCHILDREN?1:0;
				    rc = WriteSiteNode(iff,configbuf,(struct Node *)node);
				}
				lbn=GetSucc((struct Node *)lbn);
			    }
			}
		    }
		    CloseIFF(iff);
		}
		Close(iff->iff_Stream);
		SetProtection(filename,FIBF_EXECUTE);
	    }
	    FreeIFF(iff);
	}
	free(configbuf);
    }
    return rc;
}

static struct Node *ReadSiteNode(UBYTE *buf)
{
    struct SiteNode *sn;

    if (sn=AllocMem(sizeof(struct SiteNode),MEMF_PUBLIC|MEMF_CLEAR)) {
	struct SitePrefsObject *spo=(struct SitePrefsObject *) buf;
	ULONG sbits=spo->spo_StringBits;
	UBYTE *ptr=(UBYTE *)&spo[1];

	if ((!(sbits & FWSO_NAME) || (sn->sn_SiteAddress=GetConfigStr(&ptr))) &&
	    (!(sbits & FWSO_REMOTEDIR) || (sn->sn_RemoteDir=GetConfigStr(&ptr))) &&
	    (!(sbits & FWSO_LOCALDIR) || (sn->sn_LocalDir=GetConfigStr(&ptr))) &&
	    (!(sbits & FWSO_DIRSTRING) || (sn->sn_DirString=GetConfigStr(&ptr))) &&
	    (!(sbits & FWSO_LOGINNAME) || (sn->sn_LoginName=GetConfigStr(&ptr))) &&
	    (!(sbits & FWSO_PASSWORD) || (sn->sn_Password=GetConfigStr(&ptr))) &&
	    (!(sbits & FWSO_ALIASNAME) || (sn->sn_Node.ln_Name=GetConfigStr(&ptr)))) {
	    sn->sn_Flags=spo->spo_Flags;
	    sn->sn_VMSDIR=spo->spo_OsType;
	    sn->sn_Port=spo->spo_Port;
	    sn->sn_Proxy=spo->spo_Proxy;
	    sn->sn_HotList=spo->spo_HotList;
	    sn->sn_MenuType=spo->spo_MenuType;
	    sn->sn_ShowChildren=spo->spo_ShowChildren;
	    sn->sn_BarLabel=spo->spo_BarLabel;
	    sn->sn_ADT=spo->spo_ADT;

	    if (spo->spo_Anonymous)
	      sn->sn_Anonymous=1;
	    else {
		if (sn->sn_LoginName)
		  sn->sn_Anonymous=0;
		else
		  sn->sn_Anonymous=1;
	    }
	    if (sn->sn_Password) {
		int i;
		for (i=0;i<strlen(sn->sn_Password);i++)
		  sn->sn_Password[i]=sn->sn_Password[i]^MainPrefs.mp_Cookie;
	    }
	    return (struct Node *)sn;
	}
	FreeSiteNode(sn);
    }
    return NULL;
}

static BOOL WriteSiteNode(struct IFFHandle *iff, UBYTE *buf, struct Node *node)
{
    struct SiteNode *sn=(struct SiteNode *)node;
    struct SitePrefsObject *spo=(struct SitePrefsObject *)buf;
    ULONG sbits=0;
    UBYTE *ptr=(UBYTE *)&spo[1];

    memset(spo, 0, sizeof(struct SitePrefsObject));
    if (sn->sn_Password) {
	int i;
	for (i=0;i<strlen(sn->sn_Password);i++)
	  sn->sn_Password[i]=sn->sn_Password[i]^MainPrefs.mp_Cookie;
    }
    if (PutConfigStr(sn->sn_SiteAddress, &ptr)) sbits|=FWSO_NAME;
    if (PutConfigStr(sn->sn_RemoteDir, &ptr)) sbits|=FWSO_REMOTEDIR;
    if (PutConfigStr(sn->sn_LocalDir, &ptr)) sbits|=FWSO_LOCALDIR;
    if (PutConfigStr(sn->sn_DirString, &ptr)) sbits|=FWSO_DIRSTRING;
    if (PutConfigStr(sn->sn_LoginName, &ptr)) sbits|=FWSO_LOGINNAME;
    if (PutConfigStr(sn->sn_Password, &ptr)) sbits|=FWSO_PASSWORD;
    if (PutConfigStr(sn->sn_Node.ln_Name, &ptr)) sbits|=FWSO_ALIASNAME;

    if (sn->sn_Password) {
	int i;
	for (i=0;i<strlen(sn->sn_Password);i++)
	  sn->sn_Password[i]=sn->sn_Password[i]^MainPrefs.mp_Cookie;
    }

    spo->spo_StringBits=sbits;
    spo->spo_Flags=sn->sn_Flags;
    spo->spo_OsType=sn->sn_VMSDIR;
    spo->spo_Port=sn->sn_Port;
    spo->spo_Proxy=sn->sn_Proxy;
    spo->spo_HotList=sn->sn_HotList;
    spo->spo_Anonymous=sn->sn_Anonymous;
    spo->spo_MenuType=sn->sn_MenuType;
    spo->spo_ShowChildren=sn->sn_ShowChildren;
    spo->spo_BarLabel=sn->sn_BarLabel;
    spo->spo_ADT=sn->sn_ADT;

    sbits=ptr-buf;

    if (PushChunk(iff, 0, ID_FWSO, sbits)) 
      return FALSE;

    if (WriteChunkBytes(iff, buf, sbits)!=sbits) 
      return FALSE;

    if (PopChunk(iff))
      return FALSE;

    return TRUE;
}

void FreeSiteNode(struct SiteNode *sn)
{
    if (!sn)
      return;

    if (sn->sn_Node.ln_Name)
      free(sn->sn_Node.ln_Name);
    if (sn->sn_RemoteDir)
      free(sn->sn_RemoteDir);
    if (sn->sn_LocalDir)
      free(sn->sn_LocalDir);
    if (sn->sn_DirString)
      free(sn->sn_DirString);
    if (sn->sn_LoginName)
      free(sn->sn_LoginName);

    FreeMem(sn,sizeof(struct SiteNode));
}

void FreeSiteList(struct List *list)
{
    struct SiteNode *sn;
    struct Node *lbn;

    if (!list)
      return;

    while(lbn=RemHead(list)) {
	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData, &sn,
				TAG_DONE);
	if (sn)
	  FreeSiteNode(sn);
	FreeListBrowserNode(lbn);
    }
    NewList(list);
}

static void ReadMainPrefs(UBYTE *buf)
{
    struct MainPrefsObject *mpo=(struct MainPrefsObject *) buf;
    ULONG sbits=mpo->mpo_StringBits;
    UBYTE *ptr=(UBYTE *)&mpo[1];

    if ((!(sbits & FWPR_LOCALDIR) || (MainPrefs.mp_LocalDir=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_ANONPW) || (MainPrefs.mp_AnonymousPW=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_LOGINNAME) || (MainPrefs.mp_LoginName=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_DEFSITE) || (MainPrefs.mp_DefaultSite=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_PROXYHOST) || (MainPrefs.mp_ProxyServer=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_VIEWCMD) || (MainPrefs.mp_ViewCommand=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_ADTPATTERN) || (MainPrefs.mp_HideADTPattern=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_FONTNAME) || (fontname=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_LISTFONTNAME) || (listfontname=GetConfigStr(&ptr))) &&
	(!(sbits & FWPR_PUBSCREEN) || (MainPrefs.mp_PubScreen=GetConfigStr(&ptr))))  {
	MainPrefs.mp_Showdotfiles=mpo->mpo_Showdotfiles;
	MainPrefs.mp_ProxyPort=mpo->mpo_ProxyPort?mpo->mpo_ProxyPort:21;
	MainPrefs.mp_DefaultProxy=mpo->mpo_DefaultProxy;
	MainPrefs.mp_IgnoreCase=mpo->mpo_IgnoreCase;
	MainPrefs.mp_Cookie=mpo->mpo_Cookie;
	MainPrefs.mp_CacheSize=mpo->mpo_CacheSize;
	MainPrefs.mp_LeftEdge=mpo->mpo_LeftEdge;
	MainPrefs.mp_TopEdge=mpo->mpo_TopEdge;
	MainPrefs.mp_Width=mpo->mpo_Width;
	MainPrefs.mp_Height=mpo->mpo_Height;
	MainPrefs.mp_LastAminetDate=mpo->mpo_LastAminetDate;
	MainPrefs.mp_ShowAllADTFiles=mpo->mpo_ShowAllADTFiles;
	MainPrefs.mp_PreserveAminetDir=mpo->mpo_PreserveAminetDir;
	MainPrefs.mp_DeleteFiles=mpo->mpo_DeleteFiles;
	MainPrefs.mp_CacheSize=mpo->mpo_CacheSize;
	MainPrefs.mp_BufferSize=mpo->mpo_BufferSize;
	MainPrefs.mp_DisplayBeep=mpo->mpo_DisplayBeep;
	MainPrefs.mp_LastAMOTD=mpo->mpo_LastAMOTD;
	MainPrefs.mp_ShowMOTD=mpo->mpo_ShowMOTD;
	MainPrefs.mp_GetReadme=mpo->mpo_GetReadme;
	MainPrefs.mp_SortMode=SortMode=mpo->mpo_SortMode;
	MainPrefs.mp_ShowButtons=!mpo->mpo_ShowButtons;
	MainPrefs.mp_ShowToolBar=!mpo->mpo_ShowToolBar;
	MainPrefs.mp_UseDefaultFonts=!mpo->mpo_UseCustomFonts;
	MainPrefs.mp_OpenOnDefaultScreen=!mpo->mpo_OpenOnNamedScreen;

	if (MainPrefs.mp_CacheSize==0)
	  MainPrefs.mp_CacheSize=5;
	else if (MainPrefs.mp_CacheSize<1)
	  MainPrefs.mp_CacheSize=1;
	if (MainPrefs.mp_BufferSize==0)
	  MainPrefs.mp_BufferSize=8192;
	else if (MainPrefs.mp_BufferSize<512)
	  MainPrefs.mp_BufferSize=512;
	return;
    }
    return;
}

static BOOL WriteMainPrefs(struct IFFHandle *iff, UBYTE *buf, struct MainPrefs *mp)
{
    struct MainPrefsObject *mpo=(struct MainPrefsObject *)buf;
    ULONG sbits=0;
    UBYTE *ptr=(UBYTE *)&mpo[1];

    if (PutConfigStr(mp->mp_LocalDir, &ptr)) sbits|=FWPR_LOCALDIR;
    if (PutConfigStr(mp->mp_AnonymousPW, &ptr)) sbits|=FWPR_ANONPW;
    if (PutConfigStr(mp->mp_LoginName, &ptr)) sbits|=FWPR_LOGINNAME;
    if (PutConfigStr(mp->mp_DefaultSite, &ptr)) sbits|=FWPR_DEFSITE;
    if (PutConfigStr(mp->mp_ProxyServer, &ptr)) sbits|=FWPR_PROXYHOST;
    if (PutConfigStr(mp->mp_ViewCommand, &ptr)) sbits|=FWPR_VIEWCMD;
    if (PutConfigStr(mp->mp_HideADTPattern, &ptr)) sbits|=FWPR_ADTPATTERN;

    if (mp->mp_FontName) {
	char temp[40];
	sprintf(temp, "%s/%ld", mp->mp_FontName, mp->mp_FontSize);
	if (PutConfigStr(temp, &ptr)) sbits|=FWPR_FONTNAME;
    }
    if (mp->mp_ListFontName) {
	char temp[40];
	sprintf(temp, "%s/%ld", mp->mp_ListFontName, mp->mp_ListFontSize);
	if (PutConfigStr(temp, &ptr)) sbits|=FWPR_LISTFONTNAME;
    }
    if (PutConfigStr(mp->mp_PubScreen, &ptr)) sbits|=FWPR_PUBSCREEN;

    memset(mpo, 0, sizeof(struct MainPrefsObject));
    mpo->mpo_StringBits=sbits;
    mpo->mpo_Showdotfiles=MainPrefs.mp_Showdotfiles;
    mpo->mpo_ProxyPort=MainPrefs.mp_ProxyPort?MainPrefs.mp_ProxyPort:21;
    mpo->mpo_DefaultProxy=MainPrefs.mp_DefaultProxy;
    mpo->mpo_IgnoreCase=MainPrefs.mp_IgnoreCase;
    mpo->mpo_Cookie=MainPrefs.mp_Cookie=GetPWCookie();
    mpo->mpo_CacheSize=MainPrefs.mp_CacheSize;
    mpo->mpo_LeftEdge=MainPrefs.mp_LeftEdge;
    mpo->mpo_TopEdge=MainPrefs.mp_TopEdge;
    mpo->mpo_Width=MainPrefs.mp_Width;
    mpo->mpo_Height=MainPrefs.mp_Height;
    mpo->mpo_LastAminetDate=MainPrefs.mp_LastAminetDate;
    mpo->mpo_ShowAllADTFiles=MainPrefs.mp_ShowAllADTFiles;
    mpo->mpo_PreserveAminetDir=MainPrefs.mp_PreserveAminetDir;
    mpo->mpo_DeleteFiles=MainPrefs.mp_DeleteFiles;
    mpo->mpo_CacheSize=MainPrefs.mp_CacheSize;
    mpo->mpo_BufferSize=MainPrefs.mp_BufferSize;
    mpo->mpo_DisplayBeep=MainPrefs.mp_DisplayBeep;
    mpo->mpo_LastAMOTD=MainPrefs.mp_LastAMOTD;
    mpo->mpo_ShowMOTD=MainPrefs.mp_ShowMOTD;
    mpo->mpo_GetReadme=MainPrefs.mp_GetReadme;
    mpo->mpo_SortMode=MainPrefs.mp_SortMode;
    mpo->mpo_ShowButtons=!MainPrefs.mp_ShowButtons;
    mpo->mpo_ShowToolBar=!MainPrefs.mp_ShowToolBar;
    mpo->mpo_UseCustomFonts=!MainPrefs.mp_UseDefaultFonts;

    mpo->mpo_OpenOnNamedScreen=!MainPrefs.mp_OpenOnDefaultScreen;

    sbits=ptr-buf;

    if (PushChunk(iff,0,ID_FWPR,sbits)) 
      return FALSE;

    if (WriteChunkBytes(iff,buf,sbits)!=sbits) 
      return FALSE;

    if (PopChunk(iff))
      return FALSE;

    return TRUE;
}

/* Read one config string and correct pointer */
static char *GetConfigStr(UBYTE **buf)
{
    char *s=*buf;
    char *new;
    ULONG len=strlen(s)+1;

    /* Allocate string buffer */
    if (new=malloc(len)) {
	/* Copy string */
	strcpy(new,s);

	/* Correct pointer */
	*buf+=len;
    }
    return new;
}

/* Write one config string and correct pointer */
static BOOL PutConfigStr(char *s, UBYTE **buf)
{
    /* string valid? */
    if (s) {
	/* Copy string to buffer */
	strcpy(*buf,s);

	/* Correct pointer */
	*buf+=strlen(s)+1;
	return TRUE;
    }
    return FALSE;
}

UBYTE GetPWCookie(void)
{
    UBYTE j;

    srand(time(NULL));
    do {
	j=rand();
    } while (j==0);
    return (UBYTE)(j&255);
}

static char *ConvertFontName(UWORD *size, char *source)
{
    char *ptr;
    if ((ptr=strstr(source, "/"))) {
	*ptr=0;
	ptr++;
	if (*ptr) {
	    if (isdigit(*ptr)) {
		*size=atol(ptr);
		return strdup(source);
	    }
	}
    }
}
@


1.795
log
@Stuff.
@
text
@d1 2
a2 2
/* RCS Id: $Id: config.c 1.736 1996/08/17 18:17:57 lilja Exp lilja $
   Locked version: $Revision: 1.736 $
d431 4
a434 4
	MainPrefs.mp_ShowButtons=~mpo->mpo_ShowButtons;
	MainPrefs.mp_ShowToolBar=~mpo->mpo_ShowToolBar;
	MainPrefs.mp_UseDefaultFonts=~mpo->mpo_UseCustomFonts;
	MainPrefs.mp_OpenOnDefaultScreen=~mpo->mpo_OpenOnNamedScreen;
d498 5
a502 4
    mpo->mpo_ShowButtons=~MainPrefs.mp_ShowButtons;
    mpo->mpo_ShowToolBar=~MainPrefs.mp_ShowToolBar;
    mpo->mpo_UseCustomFonts=~MainPrefs.mp_UseDefaultFonts;
    mpo->mpo_OpenOnNamedScreen=~MainPrefs.mp_OpenOnDefaultScreen;
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@d1 2
a2 2
/* RCS Id: $Id: config.c 1.710 1996/07/25 00:21:30 lilja Exp lilja $
   Locked version: $Revision: 1.710 $
d76 2
a77 1
    int   mpo_unused:20;
d431 2
a432 2
	MainPrefs.mp_ShowButtons=mpo->mpo_ShowButtons;
	MainPrefs.mp_ShowToolBar=mpo->mpo_ShowToolBar;
d434 1
d498 2
a499 2
    mpo->mpo_ShowButtons=MainPrefs.mp_ShowButtons;
    mpo->mpo_ShowToolBar=MainPrefs.mp_ShowToolBar;
d501 1
@


1.710
log
@Fontprefs seems to work ok, except in PrefsWindow.
@
text
@d1 2
a2 2
/* RCS Id: $Id: config.c 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
d81 8
a88 8
#define FWPR_LOCALDIR   (1L<<0)
#define FWPR_ANONPW     (1L<<1)
#define FWPR_LOGINNAME  (1L<<2)
#define FWPR_DEFSITE    (1L<<3)
#define FWPR_PROXYHOST  (1L<<4)
#define FWPR_VIEWCMD    (1L<<5)
#define FWPR_ADTPATTERN (1L<<6)
#define FWPR_FONTNAME   (1L<<7)
d90 1
d407 2
a408 1
	(!(sbits & FWPR_LISTFONTNAME) || (listfontname=GetConfigStr(&ptr))))  {
d453 8
a460 7
    if (PutConfigStr(mp->mp_LocalDir,&ptr)) sbits|=FWPR_LOCALDIR;
    if (PutConfigStr(mp->mp_AnonymousPW,&ptr)) sbits|=FWPR_ANONPW;
    if (PutConfigStr(mp->mp_LoginName,&ptr)) sbits|=FWPR_LOGINNAME;
    if (PutConfigStr(mp->mp_DefaultSite,&ptr)) sbits|=FWPR_DEFSITE;
    if (PutConfigStr(mp->mp_ProxyServer,&ptr)) sbits|=FWPR_PROXYHOST;
    if (PutConfigStr(mp->mp_ViewCommand,&ptr)) sbits|=FWPR_VIEWCMD;
    if (PutConfigStr(mp->mp_HideADTPattern,&ptr)) sbits|=FWPR_ADTPATTERN;
d471 2
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id: $Id: config.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d75 2
a76 1
    int   mpo_unused:21;
d88 2
d92 2
d106 1
d187 12
d404 3
a406 1
	(!(sbits & FWPR_ADTPATTERN) || (MainPrefs.mp_HideADTPattern=GetConfigStr(&ptr))))  {
d430 1
d445 1
a445 1
static BOOL WriteMainPrefs(struct IFFHandle *iff,UBYTE *buf,struct MainPrefs *mp)
d458 11
a468 2

    memset(mpo,0,sizeof(struct MainPrefsObject));
d493 1
d545 1
d551 15
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
/* RCS Id: $Id: config.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d73 3
a75 1
    int   mpo_unused:23;
d408 2
d461 2
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
a7 13
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>/*
#include <prefs/prefhdr.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/iffparse_protos.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/iffparse_pragmas.h>
#include <libraries/iffparse.h>
#include <stdlib.h>
#include <string.h>*/
@


1.531
log
@Lots of stuff
@
text
@d1 4
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
@d80 3
a82 1
    int   mpo_unused:28;
d99 4
a102 2
struct Node *ReadSiteNode(UBYTE *buf);
BOOL WriteSiteNode(struct IFFHandle *iff,UBYTE *buf,struct Node *node);
d104 4
a107 5
char *GetConfigStr(UBYTE **buf);
BOOL PutConfigStr(char *s,UBYTE **buf);
void ReadMainPrefs(UBYTE *buf);
BOOL WriteMainPrefs(struct IFFHandle *iff,UBYTE *buf,struct MainPrefs *mp);
UBYTE GetPWCookie(void);
d244 1
a244 1
struct Node *ReadSiteNode(UBYTE *buf)
d290 1
a290 1
BOOL WriteSiteNode(struct IFFHandle *iff,UBYTE *buf,struct Node *node)
d296 2
a297 1
    memset(spo,0,sizeof(struct SitePrefsObject));
d303 8
a310 7
    if (PutConfigStr(sn->sn_SiteAddress,&ptr)) sbits|=FWSO_NAME;
    if (PutConfigStr(sn->sn_RemoteDir,&ptr)) sbits|=FWSO_REMOTEDIR;
    if (PutConfigStr(sn->sn_LocalDir,&ptr)) sbits|=FWSO_LOCALDIR;
    if (PutConfigStr(sn->sn_DirString,&ptr)) sbits|=FWSO_DIRSTRING;
    if (PutConfigStr(sn->sn_LoginName,&ptr)) sbits|=FWSO_LOGINNAME;
    if (PutConfigStr(sn->sn_Password,&ptr)) sbits|=FWSO_PASSWORD;
    if (PutConfigStr(sn->sn_Node.ln_Name,&ptr)) sbits|=FWSO_ALIASNAME;
d331 1
a331 1
    if (PushChunk(iff,0,ID_FWSO,sbits)) 
d334 1
a334 1
    if (WriteChunkBytes(iff,buf,sbits)!=sbits) 
d372 1
a372 1
				LBNA_UserData,&sn,
d381 1
a381 1
void ReadMainPrefs(UBYTE *buf)
d413 3
d429 1
a429 1
BOOL WriteMainPrefs(struct IFFHandle *iff,UBYTE *buf,struct MainPrefs *mp)
d464 3
d482 1
a482 1
char *GetConfigStr(UBYTE **buf)
d500 1
a500 1
BOOL PutConfigStr(char *s, UBYTE **buf)
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d69 1
a69 1
    int   mpo_unused:1;
d75 8
a82 1
    ULONG mpo_Reserved[4];
d85 8
a92 6
#define FWPR_LOCALDIR  (1L<<0)
#define FWPR_ANONPW    (1L<<1)
#define FWPR_LOGINNAME (1L<<2)
#define FWPR_DEFSITE   (1L<<3)
#define FWPR_PROXYHOST (1L<<4)
#define FWPR_VIEWCMD   (1L<<5)
d244 1
a244 2
    if (DEBUG)
      Printf("Reading sitenode\n");
d328 1
a328 2
    if (DEBUG)
      Printf("Writing site-node (%ld bytes)\n",sbits);
d381 1
a381 2
    if (DEBUG)
      Printf("Reading mainprefs\n");
d387 2
a388 1
	(!(sbits & FWPR_VIEWCMD) || (MainPrefs.mp_ViewCommand=GetConfigStr(&ptr))))  {
d400 16
d433 2
a434 8
    if (DEBUG) {
	Printf("mp->mp_LocalDir=%lx\n",mp->mp_LocalDir);
	Printf("mp->mp_Anonymous=%lx\n",mp->mp_AnonymousPW);
	Printf("mp->mp_LoginName=%lx\n",mp->mp_LoginName);
	Printf("mp->mp_DefaultSite=%lx\n",mp->mp_DefaultSite);
	Printf("mp->mp_ProxyServer=(%lx)\n",mp->mp_ProxyServer);
	Printf("mp->mp_ViewCommand=(%lx)\n",mp->mp_ViewCommand);
    }
d448 8
a455 1

d460 1
a460 2
    if (DEBUG)
      Printf("Writing mainprefs (%ld bytes)\n",sbits);
a483 2
	if (DEBUG)
	  Printf("Getting '%s' from config\n",new);
a492 2
	if (DEBUG)
	  Printf("Putting '%s' in config\n",s);
d510 1
a510 1
    return (UBYTE)j&255;
@


1.200
log
@GETATTR-hit fixed.
@
text
@d43 5
a47 1
    int   spo_unused:10;
d74 2
a75 1
    ULONG mpo_Reserved[5];
d162 2
d207 1
d210 1
d212 4
a215 2
				if (node)
				  rc = WriteSiteNode(iff,configbuf,(struct Node *)node);
d254 5
d311 5
d392 1
d430 1
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d112 1
a112 1
			    !StopChunks(iff,stopchunks,FWOBJECTS) &&
d169 1
a169 1
    return(rc);
a194 1
			    ULONG i;
d218 1
a218 1
    return(rc);
d256 1
a256 1
	    return((struct Node *)sn);
d260 1
a260 1
    return(NULL);
d298 1
a298 1
      return(FALSE);
d302 1
a302 1
      return(FALSE);
d305 1
a305 1
      return(FALSE);
d307 1
a307 1
    return(TRUE);
d345 1
a345 1
    memset(list,0,sizeof(*list));
d412 1
a412 1
      return(FALSE);
d416 1
a416 1
      return(FALSE);
d419 1
a419 1
      return(FALSE);
d421 1
a421 1
    return(TRUE);
d441 1
a441 1
    return(new);
d456 1
a456 1
	return(TRUE);
d458 1
a458 1
    return(FALSE);
d468 1
a468 1
    return (j&255);
@


0.814
log
@Added default download-dir.
@
text
@d2 1
d64 2
a65 1
    int   mpo_unused:5;
d150 1
a150 1
							    AddTail(&SiteList,node);
d197 1
d199 8
a206 4
			    node=(struct SiteNode *)GetHead(&SiteList);
			    while(node&&rc) {
				rc = WriteSiteNode(iff,configbuf,(struct Node *)node);
				node=(struct SiteNode *)GetSucc((struct Node *)node);
d333 2
d338 8
a345 2
    while(sn=(struct SiteNode *)RemHead(list))
      FreeSiteNode(sn);
d367 1
d404 1
@


0.728
log
@Save settings also saves the window position.
@
text
@a76 17
/*
struct SiteNode {
    struct Node sn_Node;
    ULONG       sn_Flags;
    int         sn_VMSDIR:3;
    int         sn_Port:16;
    int         sn_Proxy:1;
    int         sn_HotList:1;
    int         sn_unused:11;
    char       *sn_RemoteDir;
    char       *sn_LocalDir;
    char       *sn_DirString;
    char       *sn_LoginName;
    char       *sn_SiteAddress;
    char       *sn_Password;
};
*/
a78 4
/*extern struct SiteNode *GetSucc(struct SiteNode *);
extern struct SiteNode *GetHead(struct List *);
extern struct Library *IFFParseBase;
*/
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d53 1
a53 15
/*
struct MainPrefs {
    char       *mp_LocalDir;
    char       *mp_AnonymousPW;
    char       *mp_LoginName;
    char       *mp_DefaultSite;
    char       *mp_ProxyServer;
    char       *mp_ViewCommand;
    int         mp_Showdotfiles:1;
    int         mp_ProxyPort:16;
    int         mp_DefaultProxy:1;
    int         mp_IgnoreCase:1;
    int         mp_unused:13;
};
*/
d373 4
d409 5
@


0.425
log
@Add Settingsmenu with Load/Save settings.
Added Edit hostlist to the settingsmenu.
Changed the search order for the prefs-file.
@
text
@d41 2
a42 1
    int   spo_unused:11;
d76 2
a77 1
    int   mpo_unused:13;
d123 1
d272 13
d299 5
d311 5
d323 1
d386 1
d418 1
d471 9
@


0.413
log
@Added password-gadget.
@
text
@d333 1
a333 1
    struct SiteNode *sn,*next;
d337 2
a338 6
    sn=(struct SiteNode *)GetHead(list);
    while(sn) {
	next=(struct SiteNode *)GetSucc((struct Node *)sn);
	FreeSiteNode(sn);
	sn=next;
    }
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d262 1
d288 1
@


0.305
log
@Added some casts to avoid compiler warnings
@
text
@d1 2
d5 1
a5 1
#include <dos/dos.h>
d15 1
a15 1
#include <string.h>
@


0.303
log
@Prepared mpo for size/position
@
text
@d171 1
a171 1
							if (node=ReadSiteNode(configbuf)) {
d229 1
a229 1
				node=(struct SiteNode *)GetSucc(node);
d333 1
a333 1
    sn=GetHead(list);
d335 1
a335 1
	next=GetSucc(sn);
@


0.284
log
@First RCS version.
@
text
@d50 1
a50 1

d64 1
a64 1

d74 5
a78 1
    ULONG mpo_Reserved[7];
d87 1
a87 1

d103 1
a103 1

d106 1
a106 1
extern struct SiteNode *GetSucc(struct SiteNode *);
d109 1
a109 1

@
