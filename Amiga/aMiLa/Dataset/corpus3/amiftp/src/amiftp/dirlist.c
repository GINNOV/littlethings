/* RCS Id: $Id: dirlist.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
*/

#include "AmiFTP.h"
#include "gui.h"

#define ISDIR(x) (x)&0x4000

struct dirlist *new_direntry(char *name,char *date,char *owner,
			     char *group,mode_t mode,size_t size)
{
    struct dirlist *tmp;

    tmp = (struct dirlist *)malloc(sizeof(struct dirlist));
    if (!tmp)
      return NULL;
    bzero((char *)tmp,sizeof(struct dirlist));
    tmp->name = (char *)malloc((unsigned int)(strlen(name) + 1));
    if (tmp->name == NULL) {
	free_direntry(tmp);
	return NULL;
    }
    if (date) {
	tmp->date = (char *)malloc((unsigned int)(strlen(date) + 1));
	if (tmp->date == NULL) {
	    free_direntry(tmp);
	    return NULL;
	}
    }

    if (owner) {
	tmp->owner = (char *)malloc((unsigned int)(strlen(owner) + 1));
	if (tmp->owner == NULL) {
	    free_direntry(tmp);
	    return NULL;
	}
    }

    if (group) {
	tmp->group = (char *)malloc((unsigned int)(strlen(group) + 1));
	if (tmp->group == NULL) {
	    free_direntry(tmp);
	    return NULL;
	}
    }
/* Fix: Add tmp->lname=linkname(name); plus null-terminate tmp->name before the ->
    if (S_ISLNK(mode))
      lname=linkname(name);
    else
      lname=NULL;
    if (lname)
      free(lname);
*/

    strcpy(tmp->name, name);
    if (date)
      strcpy(tmp->date, date);
    if (owner)
      strcpy(tmp->owner, owner);
    if (group)
      strcpy(tmp->group, group);
    tmp->mode = mode;
//    tmp->link = S_ISLNK(mode);
//    tmp->dir  = S_ISDIR(mode);
//    tmp->file = S_ISREG(mode);
    tmp->size = size;
    return tmp;
}
char donk[]="donk";

BOOL add_direntry(struct List *filelist, char *name, char *date,
		  char *owner, char *group, mode_t mode, size_t size, 
		  int sort_mode, int sort_direction)
{
    struct dirlist *tmp;
    struct dirlist *oldprev=NULL;
    ULONG flags;

    if ((!MainPrefs.mp_Showdotfiles) && name[0]=='.')
      flags=LBFLG_CUSTOMPENS|LBFLG_HIDDEN;
    else
      flags=LBFLG_CUSTOMPENS;

    if (non_unix)
      sort_mode = SORTBYNAME;
    switch (sort_mode) {
      default:
//	Printf("Unknown sort mode in add_dirname.\n");
	/* Fall through */
      case SORTBYNAME:
	if (sort_direction == ASCENDING)
	  oldprev = sortupbyname(filelist, name, ISDIR(mode));
	else
	  oldprev = sortdownbyname(filelist, name, ISDIR(mode));
	break;
      case SORTBYDATE:
	if (sort_direction == ASCENDING)
	  oldprev = sortupbydate(filelist, date);
	else
	  oldprev = sortdownbydate(filelist, date);
	break;
#if 0
      case SORTBYSIZE:
	if (sort_direction == ASCENDING)
	  oldprev = sortupbysize(filelist, size);
	else
	  oldprev = sortdownbysize(filelist, size);
	break;
#endif
    }
    
    tmp = new_direntry(name, date, owner, group, mode, size);
    if (tmp) {
	struct Node *tmp2=AllocListBrowserNode(6,
					       LBNA_Column,0,
					       LBNA_Flags,flags,
					       LBNCA_Text,tmp->name,
					       LBNCA_FGPen,tmp->mode&0x4000?2:1,
					       LBNA_Column,1,
					       LBNCA_Integer,&tmp->size,
					       LBNCA_Justification,LCJ_RIGHT,
					       LBNCA_FGPen,tmp->mode&0x4000?2:1,
					       LBNA_Column,2,
					       LBNCA_Text,tmp->mode&0x4000?"(dir)":S_ISLNK(tmp->mode)?"(link)":"",
					       LBNCA_Justification,LCJ_RIGHT,
					       LBNCA_FGPen,tmp->mode&0x4000?2:1,
					       LBNA_Column,3,
					       LBNCA_Text,tmp->date,
					       LBNCA_Justification,LCJ_RIGHT,
					       LBNCA_FGPen,tmp->mode&0x4000?2:1,
					       LBNA_Column,4,
					       LBNCA_FGPen,tmp->mode&0x4000?2:1,
					       LBNCA_Justification,LCJ_RIGHT,	
					       LBNCA_Text,tmp->owner,
					       LBNA_Column,5,
					       LBNCA_Justification,LCJ_RIGHT,
					       LBNCA_FGPen,tmp->mode&0x4000?2:1,
					       LBNCA_Text,tmp->group,
					       TAG_DONE);
	if (tmp2) {
	    tmp2->ln_Name=(void *)tmp;
	    Insert(filelist,tmp2,(struct Node *)oldprev);
	    return TRUE;
	}
    }
    return FALSE;
}

void add_direntry_struct(struct List *filelist,
	struct dirlist *dlist, int sort_mode, int sort_direction)
{
    struct Node *tmp,*tmp2;
    ULONG flags;

    if ((!MainPrefs.mp_Showdotfiles) && dlist->name[0]=='.')
      flags=LBFLG_CUSTOMPENS|LBFLG_HIDDEN;
    else
      flags=LBFLG_CUSTOMPENS;

    tmp2=AllocListBrowserNode(6,
			      LBNA_Column,0,
			      LBNA_Flags,flags,
			      LBNCA_Text,dlist->name,
			      LBNCA_FGPen,dlist->mode&0x4000?2:1,
			      LBNA_Column,1,
			      LBNCA_Integer,&dlist->size,
			      LBNCA_Justification,LCJ_RIGHT,
			      LBNCA_FGPen,dlist->mode&0x4000?2:1,
			      LBNA_Column,2,
			      LBNCA_Text,dlist->mode&0x4000?"(dir)":S_ISLNK(dlist->mode)?"(link)":"",
			      LBNCA_Justification,LCJ_RIGHT,
			      LBNCA_FGPen,dlist->mode&0x4000?2:1,
			      LBNA_Column,3,
			      LBNCA_Text,dlist->date,
			      LBNCA_Justification,LCJ_RIGHT,
			      LBNCA_FGPen,dlist->mode&0x4000?2:1,
			      LBNA_Column,4,
			      LBNCA_Text,dlist->owner,
			      LBNCA_Justification,LCJ_RIGHT,
			      LBNCA_FGPen,dlist->mode&0x4000?2:1,
			      LBNA_Column,5,
			      LBNCA_Text,dlist->group,
			      LBNCA_Justification,LCJ_LEFT,
			      LBNCA_FGPen,dlist->mode&0x4000?2:1,
			      TAG_DONE);
    if (!tmp2)
      return;

    tmp2->ln_Name=(void *)dlist;

    if (non_unix)
      sort_mode = SORTBYNAME;
    switch (sort_mode) {
      default:
	/* Fall through */
      case SORTBYNAME:
	if (sort_direction == ASCENDING)
	  tmp = (struct Node *)sortupbyname(filelist, dlist->name,ISDIR(dlist->mode));
	else
	  tmp = (struct Node *)sortdownbyname(filelist, dlist->name,ISDIR(dlist->mode));
	break;
      case SORTBYDATE:
	if (sort_direction == ASCENDING)
	  tmp = (struct Node *)sortupbydate(filelist, dlist->date);
	else
	  tmp = (struct Node *)sortdownbydate(filelist, dlist->date);
	break;
#if 0
      case SORTBYSIZE:
	if (sort_direction == ASCENDING)
	  tmp = (struct Node *)sortupbysize(filelist, dlist->size);
	else
	  tmp = (struct Node *)sortdownbysize(filelist, dlist->size);
	break;
#endif
    }
    Insert(filelist,tmp2,tmp);
}

void free_direntry(struct dirlist *tmp)
{
    if (tmp->name)
      free(tmp->name);
    if (tmp->date)
      free(tmp->date);
    if (tmp->owner)
      free(tmp->owner);
    if (tmp->group)
      free(tmp->group);

    free(tmp);
}

void free_dirlist(struct List *filelist)
{
    struct Node *node;
    struct dirlist *tmp;
    while (node=RemHead(filelist)) {
	tmp=(void *)node->ln_Name;
	if (tmp) {
	    if (tmp->name)
	      free(tmp->name);
	    if (tmp->date)
	      free(tmp->date);
	    if (tmp->owner)
	      free(tmp->owner);
	    if (tmp->group)
	      free(tmp->group);

	    free(tmp);
	}
	FreeListBrowserNode(node);
    }
    NewList(filelist);
}

/* alphabetical order */
struct dirlist *sortupbyname(struct List *filelist,char *name, int dir)
{
    struct dirlist *tmp;
    struct Node *tmp2;
    int rval;

    for (tmp2=ListHead(filelist);ListEnd(tmp2);tmp2=ListNext(tmp2)) {
	tmp=(void *)tmp2->ln_Name;
	if ((dir)==(ISDIR(tmp->mode))) {
	    if (MainPrefs.mp_IgnoreCase)
	      rval=stricmp(name,tmp->name);
	    else
	      rval=strcmp(name,tmp->name);
	    if (rval < 0)
	      break;
	}
	else if (dir)
	  break;
    }
    if (tmp2)
      return (struct dirlist *)GetPred((struct Node *)tmp2);
    else {
	if (!EmptyList(filelist))
	  return (struct dirlist *)GetTail(filelist);
	else
	  return NULL;
    }
}

struct dirlist *sortdownbyname(struct List *filelist,char *name,int dir)
{
    struct Node *tmp2;
    struct dirlist *tmp;
    int rval;

    for (tmp2=ListHead(filelist);ListEnd(tmp2);tmp2=ListNext(tmp2)) {
	tmp=(void *)tmp2->ln_Name;
	if ((dir)==(ISDIR(tmp->mode))) {
	    if (MainPrefs.mp_IgnoreCase)
	      rval=stricmp(name,tmp->name);
	    else
	      rval=strcmp(name,tmp->name);
	    if (rval > 0)
	      break;
	}
	else if (dir)
	  break;
    }
    if (tmp2)
      return (struct dirlist *)GetPred((struct Node *)tmp2);
    else {
	if (!EmptyList(filelist))
	  return (struct dirlist *)GetTail(filelist);
	else
	  return NULL;
    }
}

/* least recently modified */

struct dirlist *sortupbydate(struct List *filelist,char *date)
{
    struct dirlist *tmp;
    struct Node *tmp2;

    for (tmp2=ListHead(filelist);ListEnd(tmp2);tmp2=ListNext(tmp2)) {
	tmp=(void *)tmp2->ln_Name;
	if (isearlier(date,tmp->date))
	  break;
    }
    if (tmp2)
      return (struct dirlist *)GetPred((struct Node *)tmp2);
    else {
	if (!EmptyList(filelist))
	  return (struct dirlist *)GetTail(filelist);
	else
	  return NULL;
    }
}

struct dirlist *sortdownbydate(struct List *filelist, char *date)
{
    struct dirlist *tmp;
    struct Node *tmp2;

    for (tmp2 = ListHead(filelist); ListEnd(tmp2); tmp2 = ListNext(tmp2)) {
	tmp=(void *)tmp2->ln_Name;
	if (!isearlier(date, tmp->date))
	  break;		/* need to go before next entry. */
    }
    if (tmp2)
      return (struct dirlist *)GetPred((struct Node *)tmp2);
    else {
	if (!EmptyList(filelist))
	  return (struct dirlist *)GetTail(filelist);
	else
	  return NULL;
    }
}
#if 0
/* Not used at the moment */
/* smallest to largest */

struct dirlist *sortupbysize(struct List *filelist,size_t size)
{
    struct dirlist *tmp;
    struct Node *tmp2;
    for (tmp2=ListHead(filelist);ListEnd(tmp2);tmp2=ListNext(tmp2)) {
	tmp=(void *)tmp2->ln_Name;
	if (size<=tmp->size)
	  break;
    }
    if (tmp2)
      return (struct dirlist *)GetPred((struct Node *)tmp2);
    else {
	if (!EmptyList(filelist))
	  return (struct dirlist *)GetTail(filelist);
	else
	  return NULL;
    }
}
struct dirlist *sortdownbysize(struct List *filelist,size_t size)
{
    struct dirlist *tmp;
    struct Node *tmp2;

    for (tmp2=ListHead(filelist);ListEnd(tmp2);tmp2=ListNext(tmp2)) {
	tmp=(void *)tmp2->ln_Name;
	if (size>=tmp->size)
	  break;
    }
    if (tmp2)
      return (struct dirlist *)GetPred((struct Node *)tmp2);
    else {
	if (!EmptyList(filelist))
	  return (struct dirlist *)GetTail(filelist);
	else
	  return NULL;
    }
}
#endif

int cummonthdays[] = {
	0,
	31,
	59,
	90,
	120,
	151,
	181,
	212,
	243,
	273,
	304,
	334
};

long	datetotime(char *date)
{
    struct tm tm;

    /* "Aug 19 19:47" */
    /* "Jan 10  1990" */

    if (index(date, ':')) {
	hour_time(date, &tm);
	if (tm.tm_mon > current_month)
	  tm.tm_year = current_year - 1;
	else
	  tm.tm_year = current_year;
    } else {
	year_time(date, &tm);
	tm.tm_hour = 0;
	tm.tm_min = 0;
    }
    return tm.tm_min + tm.tm_hour * 60
	    + (tm.tm_year * 365 + tm.tm_mday +
	       cummonthdays[tm.tm_mon]) * 1440;
}

int isearlier(char *date1, char *date2)
{
    long	time1;
    long	time2;


    time1 = datetotime(date1);
    time2 = datetotime(date2);

    if (time1 < time2)
      return 1;
    return 0;
}

struct List *sort_filelist(struct List *old_filelist, int sort_mode,
			   int sort_direction)
{
    struct Node *tmp,*next;
    struct List *new_filelist;

    if (!FirstNode(old_filelist))
      return old_filelist;
    new_filelist=malloc(sizeof(struct List));
    if (!new_filelist)
      return old_filelist;
    NewList(new_filelist);
    tmp=FirstNode(old_filelist);
    while(tmp) {
	next=NextNode(tmp);
	Remove(tmp);
	add_direntry_struct(new_filelist, (struct dirlist *)tmp->ln_Name,
			    sort_mode, sort_direction);
	FreeListBrowserNode(tmp);
	tmp=next;
    }
    free(old_filelist);
    return new_filelist;
}

char *abbrev_month[] = {
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
};

void hour_time(char *date, struct tm *tm)
{
    char	month[10];
    int		i;

    bzero((char *)tm, sizeof (struct tm));
    sscanf(date, "%s%d%d:%d", month, &tm->tm_mday,
	   &tm->tm_hour, &tm->tm_min);
    for (i = 0; i < 12; i++)
      if (!strncmp(month, abbrev_month[i], 3))
	break;
    if (i != 12)
      tm->tm_mon = i;
}

void year_time(char *date, struct tm *tm)
{
    char	month[10];
    int		i;

    bzero((char *)tm, sizeof (struct tm));
    sscanf(date, "%s%d%d", month, &tm->tm_mday, &tm->tm_year);
    for (i = 0; i < 12; i++)
      if (!strncmp(month, abbrev_month[i], 3))
	break;
    if (i != 12)
      tm->tm_mon = i;
    if (tm->tm_year > 1900)
      tm->tm_year -= 1900;
}
