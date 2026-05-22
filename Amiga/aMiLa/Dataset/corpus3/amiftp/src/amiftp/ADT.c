/* RCS Id:  $Id: ADT.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
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
//		KDEBUG("This is ADT-v2\n");
	    }
	    else if (strncmp(&response_line[1], "amotd=", 6)==0) {
//		KDEBUG("The motd-file is from %ld\n", atol(&response_line[7]));
                MOTDDate=atol(&response_line[7]);
	    }
	    else if (strncmp(&response_line[1], "lmotd=", 6)==0) {
//		KDEBUG("The lmotd-file is from %ld\n", atol(&response_line[7]));
	    }
	    else if (strncmp(&response_line[1], "sites=", 6)==0) {
//		KDEBUG("Sitefile from %ld\n", atol(&response_line[7]));
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
    while (*buf!='@' && (*buf)) {
	*dir=*buf;
	buf++;
	dir++;
    }
    *dir=0;
    buf++;
    while (*buf!='@' && (*buf)) {
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

    while ((*buf!='@') && (*buf)) {
	buf++;
    }
    buf++;
    while (*buf!='@' && (*buf)) {
	*desc=*buf;
	buf++;
	desc++;
    }
    *desc=0;
}

static int ParseADT(struct List *list, char *buffer)
{
    long date, length, a, b;
    char dir[256], name[256], desc[256];
    struct dirlist *entry;
    struct Node *node;

    memset(dir,0,256);
    memset(name,0,256);
    memset(desc,0,256);

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
