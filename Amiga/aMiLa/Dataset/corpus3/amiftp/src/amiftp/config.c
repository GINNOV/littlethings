/* RCS Id: $Id: config.c 1.815 1996/12/14 12:13:03 lilja Exp lilja $
   Locked version: $Revision: 1.815 $
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
