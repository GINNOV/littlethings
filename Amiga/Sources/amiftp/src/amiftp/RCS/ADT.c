head	1.795;
access;
symbols;
locks
	lilja:1.795; strict;
comment	@ * @;


1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
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
next	;


desc
@Aminet Download Tool support functions.
@


1.795
log
@Stuff.
@
text
@/* RCS Id:  $Id: ADT.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"
#include "gui.h"

static void CloseRecent(const int sin);
static int OpenRecent(void);
static void ParseRecentLine(long *date, long *length, long *readmelen,
			    long *readmesize, char *dir, char *name, 
			    char *desc, char *buf);
static int ParseADT(struct List *list, char *buffer);

static ULONG lastscanned;
static char *Pattern;

ULONG MOTDDate;
struct Node *GetHead(struct List *);
struct Node *GetSucc(struct Node *);

struct List *ReadRecentList(void)
{
    struct List *filelist;
    struct Node *node;
    int din=-1;

    filelist=(struct List *)malloc(sizeof(struct List));
    if (!filelist) {
	ShowErrorReq(GetAmiFTPString(Str_Outofmem));
	return NULL;
    }
    NewList(filelist);

    din=OpenRecent();
    if (din == -1)
      return filelist;

    if (MainPrefs.mp_HideADTPattern) {
	Pattern=malloc(strlen(MainPrefs.mp_HideADTPattern)*2+2);
	if (Pattern) 
	  ParsePatternNoCase(MainPrefs.mp_HideADTPattern, Pattern,
			     strlen(MainPrefs.mp_HideADTPattern)*2+2);
    }
    else Pattern=NULL;
    lastscanned=MainPrefs.mp_LastAminetDate;

    for (;;) {
	if (next_remote_line(din) == NULL)
	  goto out;

	if (response_line[0]=='#') {
	    if (strncmp(&response_line[1], "adt-v2", 6)==0) {
//		Printf("This is ADT-v2\n");
	    }
	    else if (strncmp(&response_line[1], "amotd=", 6)==0) {
//		Printf("The motd-file is from %ld\n", atol(&response_line[7]));
                MOTDDate=atol(&response_line[7]);
	    }
	    else if (strncmp(&response_line[1], "lmotd=", 6)==0) {
//		Printf("The lmotd-file is from %ld\n", atol(&response_line[7]));
	    }
	    else if (strncmp(&response_line[1], "sites=", 6)==0) {
//		Printf("Sitefile from %ld\n", atol(&response_line[7]));
	    }
	}
	else
	  if (ParseADT(filelist, response_line)) {
	      while (sgetc(din) != -1);

	      CloseRecent(din);
	      din=-1;
	      if (Pattern)
		free(Pattern);
	      return filelist;
	  }
    }
  out:
    if (din >=0)
      CloseRecent(din);
    if (timedout) {
	free_dirlist(filelist);
	free(filelist);
	timeout_disconnect();
	if (Pattern)
	  free(Pattern);
	return NULL;
    }
    if (lastscanned!=MainPrefs.mp_LastAminetDate) {
	MainPrefs.mp_LastAminetDate=lastscanned;
	ConfigChanged=TRUE;
    }

    if (Pattern)
      free(Pattern);

    for (node=GetHead(filelist);node;node=GetSucc(node)) {
	ULONG flags;
	GetListBrowserNodeAttrs(node, LBNA_Flags, &flags, TAG_DONE);
	if (!(flags&LBFLG_HIDDEN))
	  break;
    }
    if (!node) {
	node=AllocListBrowserNode(6,
				  LBNA_Flags, LBFLG_READONLY,
				  LBNA_Column, 0,
				  LBNCA_Text, GetAmiFTPString(Str_NoNewAminetFiles),
				  LBNA_Column, 1,
				  LBNCA_Text, "",
				  LBNA_Column, 2,
				  LBNCA_Text, "",
				  LBNA_Column, 3,
				  LBNCA_Text, "",
				  LBNA_Column, 4,
				  LBNCA_Text, "",
				  LBNA_Column, 5,
				  LBNCA_Text, "",
				  TAG_DONE);
	if (node)
	  AddTail(filelist, node);
    }
    return filelist;
}

static int OpenRecent(void)
{
    char *cmd;
    int sin=0;

    cmd= "RETR info/adt/ADT_RECENT_7";

    settype(ASCII);

    if (initconn()) {
	code=-1;
	return -1;
    }
    if (command("%s", cmd) != PRELIM) {
	if (code == 530) {
	}
	else if (code == 550) {
	}
	else {
	}
	return -1;
    }
    sin=dataconn();
    if (sin == -1)
      return -1;
    return sin;
}

static void CloseRecent(const int sin)
{
    tcp_shutdown(sin, 1+1);
    tcp_closesocket(sin);

    (void) getreply(0);

    return;
}

static void ParseRecentLine(long *date, long *length, long *readmelen,
			    long *readmesize, char *dir, char *name,
			    char *desc, char *buf)
{
    *date=atol(buf);
    while (isdigit(*buf) && (*buf)) {
	buf++;
    }
    buf++;
    while (*buf!='@@' && (*buf)) {
	*dir=*buf;
	buf++;
	dir++;
    }
    *dir=0;
    buf++;
    while (*buf!='@@' && (*buf)) {
	*name=*buf;
	buf++;
	name++;
    }
    *name=0;
    buf++;
    *length=atol(buf);
    while (isdigit(*buf) && (*buf)) {
	buf++;
    }
    buf++;
    *readmelen=atol(buf);
    while (isdigit(*buf) && (*buf)) {
	buf++;
    }
    buf++;
    *readmesize=atol(buf);
    while (isdigit(*buf) && (*buf)) {
	buf++;
    }
    buf++;

    while ((*buf!='@@') && (*buf)) {
	buf++;
    }
    buf++;
    while (*buf!='@@' && (*buf)) {
	*desc=*buf;
	buf++;
	desc++;
    }
    *desc=0;
}

static int ParseADT(struct List *list, char *buffer)
{
    long date, length, a, b;
    char dir[100], name[100], desc[100];
    struct dirlist *entry;
    struct Node *node;

    memset(dir,0,100);
    memset(name,0,100);
    memset(desc,0,100);

    ParseRecentLine(&date, &length, &a, &b, dir, name, desc, buffer);
    if (entry=new_direntry(name, NULL, dir, desc, S_IFREG, length)) {
	struct Node *tmp;
	entry->adt=1;
	entry->readmelength=a;
	entry->readmelen=b;
	entry->adtdate=date;

	if (date > MainPrefs.mp_LastAminetDate)
	  entry->new=1;
	if (tmp=AllocListBrowserNode(6,
				     LBNA_UserData, entry,
				     LBNA_Column, 0,
				     LBNCA_Text, entry->name,
				     LBNA_Column, 1,
				     LBNCA_Integer, &entry->size,
				     LBNCA_Justification, LCJ_RIGHT,
				     LBNA_Column, 2,
				     LBNCA_Text, entry->owner,
				     LBNA_Column, 3,
				     LBNCA_Text, entry->group,
				     LBNA_Column, 4,
				     LBNCA_CopyText, TRUE,
				     LBNCA_Text, "",
				     LBNA_Column,5,
				     LBNCA_CopyText, TRUE,
				     LBNCA_Text, "",
				     TAG_DONE)) {
	    if (SortMode==SORTBYNAME) {
		for (node=GetHead(list); node; node=GetSucc(node))
		  if (strcmp(((struct dirlist *)node->ln_Name)->owner, entry->owner)>=0)
		    break;
		if (node) {
		    if (strcmp(((struct dirlist *)node->ln_Name)->owner, entry->owner)==0) {
			if (stricmp(((struct dirlist *)node->ln_Name)->name, entry->name)<0) {
			    struct Node *node1;
			    for (node1=GetSucc(node); node1; node1=GetSucc(node1)) {
				if (strcmp(((struct dirlist *)node1->ln_Name)->owner, entry->owner)!=0) {
				    break;
				}
				else if (stricmp(((struct dirlist *)node1->ln_Name)->name, entry->name)>=0)
				  break;
			    }
			    if (node1)
			      Insert(list, tmp, GetPred(node1));
			    else AddTail(list, tmp);
			} else Insert(list, tmp, GetPred(node));
		    }
		    else Insert(list, tmp, GetPred(node));
		}
		else
		  AddTail(list, tmp);
	    }
	    else {
		for (node=GetHead(list); node; node=GetSucc(node))
		  if (((struct dirlist *)node->ln_Name)->adtdate < entry->adtdate)
		    break;
		if (node)
		  Insert(list, tmp, GetPred(node));
		else
		  AddTail(list, tmp);
	    }
	    tmp->ln_Name=(void *)entry;
	    if (date <= MainPrefs.mp_LastAminetDate && !MainPrefs.mp_ShowAllADTFiles)
	      SetListBrowserNodeAttrs(tmp,
				      LBNA_Flags, LBFLG_HIDDEN,
				      TAG_DONE);
	    if (Pattern)
	      if (MatchPatternNoCase(Pattern,dir)) {
		  SetListBrowserNodeAttrs(tmp,
					  LBNA_Flags, LBFLG_HIDDEN,
					  TAG_DONE);
		  entry->hide=1;
	      }
	    if (date>lastscanned)
	      lastscanned=date;
	    return 0;
	}
    }
    return 1;
}

static int SortADTNodesAlpha(const void *a, const void *b)
{
    struct dirlist *nodea=(struct dirlist *)((struct Node *)*(ULONG *)a)->ln_Name;
    struct dirlist *nodeb=(struct dirlist *)((struct Node *)*(ULONG *)b)->ln_Name;
    int res;

    res=stricmp(nodea->owner, nodeb->owner);

    if (!res)
      return stricmp(nodea->name, nodeb->name);
    else
      return res;
}

static int SortADTNodesDate(const void *a, const void *b)
{
    struct dirlist *nodea=(struct dirlist *)((struct Node *)*(ULONG *)a)->ln_Name;
    struct dirlist *nodeb=(struct dirlist *)((struct Node *)*(ULONG *)b)->ln_Name;

    return (int)(nodeb->adtdate-nodea->adtdate);
}

struct List *sort_ADT(struct List *list, int type)
{
    int numnodes, i;
    struct Node *node;
    ULONG *array, *arrayptr;

    for (numnodes=0, node=GetHead(list);
	 node;
	 node=GetSucc(node), numnodes++);
    if (numnodes > 1) {
	if ((array=AllocVec(4*numnodes, MEMF_CLEAR))) {
	    for (node=GetHead(list), arrayptr=array;
		 node;
		 arrayptr++, node=GetSucc(node))
	      *arrayptr=(ULONG)node;

	    qsort(array, numnodes, 4,
		  type==SORTBYNAME?SortADTNodesAlpha:SortADTNodesDate);
	    NewList(list);
	    for (arrayptr=array, i=0; i<numnodes; i++, arrayptr++)
	      AddTail(list, (struct Node *)*arrayptr);
	    FreeVec(array);
	}
    }
    return list;
}
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
/* RCS Id:  $Id: ADT.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d280 1
a280 1
		  if (((struct dirlist *)node->ln_Name)->adtdate > entry->adtdate)
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
@d1 4
@


1.531
log
@Lots of stuff
@
text
@d15 2
d331 3
a333 1
    for (numnodes=0, node=GetHead(list);node;node=GetSucc(node), numnodes++);
d336 3
a338 1
	    for (node=GetHead(list), arrayptr=array; node; arrayptr++, node=GetSucc(node))
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@a3 1
#if 1
d13 1
a13 1
char *nonewfiles="No new files since last Aminet visit";
d36 2
a37 1
	  ParsePatternNoCase(MainPrefs.mp_HideADTPattern, Pattern, strlen(MainPrefs.mp_HideADTPattern)*2+2);
d47 1
a47 1
	    if (strncmp(&response_line[1],"adt-v2",6)==0) {
d50 2
a51 2
	    else if (strncmp(&response_line[1],"amotd=",6)==0) {
//		Printf("The motd-file is from %ld\n",atol(&response_line[7]));
d54 2
a55 2
	    else if (strncmp(&response_line[1],"lmotd=",6)==0) {
//		Printf("The lmotd-file is from %ld\n",atol(&response_line[7]));
d57 2
a58 2
	    else if (strncmp(&response_line[1],"sites=",6)==0) {
//		Printf("Sitefile from %ld\n",atol(&response_line[7]));
d63 2
a64 2
	      while (sgetc(din) != -1)
		;
d99 13
a111 12
				  LBNA_Column,0,
				  LBNCA_Text,nonewfiles,
				  LBNA_Column,1,
				  LBNCA_Text,"",
				  LBNA_Column,2,
				  LBNCA_Text,"",
				  LBNA_Column,3,
				  LBNCA_Text,"",
				  LBNA_Column,4,
				  LBNCA_Text,"",
				  LBNA_Column,5,
				  LBNCA_Text,"",
d149 1
a149 1
    tcp_shutdown(sin,1+1);
d230 5
a234 5
				     LBNA_UserData,entry,
				     LBNA_Column,0,
				     LBNCA_Text,entry->name,
				     LBNA_Column,1,
				     LBNCA_Integer,&entry->size,
d236 7
a242 7
				     LBNA_Column,2,
				     LBNCA_Text,entry->owner,
				     LBNA_Column,3,
				     LBNCA_Text,entry->group,
				     LBNA_Column,4,
				     LBNCA_CopyText,TRUE,
				     LBNCA_Text,"",
d244 2
a245 2
				     LBNCA_CopyText,TRUE,
				     LBNCA_Text,"",
d247 14
a260 10
	    for (node=GetHead(list);node;node=GetSucc(node))
	      if (strcmp(((struct dirlist *)node->ln_Name)->owner, entry->owner)>=0)
		break;
	    if (node) {
		if (strcmp(((struct dirlist *)node->ln_Name)->owner, entry->owner)==0) {
		    if (stricmp(((struct dirlist *)node->ln_Name)->name, entry->name)<0) {
			struct Node *node1;
			for (node1=GetSucc(node);node1;node1=GetSucc(node1)) {
			    if (strcmp(((struct dirlist *)node1->ln_Name)->owner, entry->owner)!=0) {
				break;
d262 6
a267 7
			    else if (stricmp(((struct dirlist *)node1->ln_Name)->name, entry->name)>=0)
			      break;
			}
			if (node1)
			  Insert(list, tmp, GetPred(node1));
			else AddTail(list, tmp);
		    } else Insert(list, tmp, GetPred(node));
d269 11
a279 1
		else Insert(list, tmp, GetPred(node));
a280 2
	    else
	      AddTail(list, tmp);
d320 1
a320 1
    return (int)(nodea->adtdate-nodeb->adtdate);
d335 2
a336 1
	    qsort(array, numnodes, 4, type==SORTBYNAME?SortADTNodesAlpha:SortADTNodesDate);
a344 8

#else
struct List *read_recent_list(void)
{
    return NULL;
}

#endif
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
@d224 2
d287 44
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d4 8
a11 3
#if 0
static void close_recent(const int sin);
static int open_recent();
d14 2
d17 1
a17 1
struct List *read_recent_list(void)
d20 1
d30 1
a30 1
    din=open_recent();
d40 1
d52 1
d62 1
a62 1
	  if (parse_adt(filelist, response_line)) {
d65 1
a65 1
	      close_recent(din);
d74 1
a74 1
      close_recent(din);
d90 25
d118 1
a118 1
static int open_recent()
a119 1
    char *ftperr;
d131 1
a131 1
    if (command("%s",cmd) != PRELIM) {
d146 1
a146 1
static void close_recent(const int sin)
d156 3
a158 2
void parse_adtline(long *date, long *length, long *readmelen, long *readmesize,
		   char *dir, char *name, char *desc, char *buf)
d207 1
a207 1
int parse_adt(struct List *list, char *buffer)
d212 1
d218 2
a219 5
    parse_adtline(&date,&length,&a,&b,dir,name,desc,buffer);
    if (Pattern)
      if (MatchPatternNoCase(Pattern,dir))
	return 0;
    if (entry=new_direntry(name,NULL,dir,desc,S_IFREG,length)) {
d222 4
d244 23
a266 1
	    AddTail(list,tmp);
d268 1
a268 1
	    if (date < MainPrefs.mp_LastAminetDate && !MainPrefs.mp_ShowAllADTFiles)
d270 1
a270 1
				      LBNA_Flags,LBFLG_HIDDEN,
d272 7
@
