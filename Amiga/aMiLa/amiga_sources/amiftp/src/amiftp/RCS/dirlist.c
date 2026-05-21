head	1.795;
access;
symbols;
locks
	lilja:1.795; strict;
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
next	0.1343;

0.1343
date	96.01.20.17.34.39;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.531;

0.531
date	95.09.01.17.25.42;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.326;

0.326
date	95.06.13.12.52.15;	author lilja;	state Exp;
branches;
next	0.305;

0.305
date	95.06.08.16.45.30;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Routines for the directory-LIST
@


1.795
log
@Stuff.
@
text
@/* RCS Id: $Id: dirlist.c 1.730 1996/08/02 21:57:32 lilja Exp lilja $
   Locked version: $Revision: 1.730 $
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
/* RCS Id: $Id: dirlist.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d453 2
a454 1
struct List *sort_filelist(struct List *old_filelist,int sort_mode,int sort_direction)
d469 2
a470 1
	add_direntry_struct(new_filelist,(struct dirlist *)tmp->ln_Name,sort_mode,sort_direction);
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
/* RCS Id: $Id: dirlist.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d103 1
d110 1
d209 1
d216 1
d358 2
a359 1

d399 1
d476 1
a476 1
static char *abbrev_month[] = {
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
@d257 1
a257 1
    for (tmp2=GetHead(filelist);tmp2;tmp2=GetSucc(tmp2)) {
d273 1
a273 1
	if ((struct dirlist *)GetHead(filelist))
d286 1
a286 1
    for (tmp2=GetHead(filelist);tmp2;tmp2=GetSucc(tmp2)) {
d302 1
a302 1
	if ((struct dirlist *)GetHead(filelist))
d316 1
a316 1
    for (tmp2=GetHead(filelist);tmp2;tmp2=GetSucc(tmp2)) {
d324 1
a324 1
	if ((struct dirlist *)GetHead(filelist))
d336 1
a336 1
    for (tmp2 = GetHead(filelist); tmp2; tmp2 = GetSucc(tmp2)) {
d344 1
a344 1
	if ((struct dirlist *)GetHead(filelist))
d357 1
a357 1
    for (tmp2=GetHead(filelist);tmp2;tmp2=GetSucc(tmp2)) {
d365 1
a365 1
	if ((struct dirlist *)GetHead(filelist))
d376 1
a376 1
    for (tmp2=GetHead(filelist);tmp2;tmp2=GetSucc(tmp2)) {
d384 1
a384 1
	if ((struct dirlist *)GetHead(filelist))
d448 1
a448 1
    if (!GetHead(old_filelist))
d454 1
a454 1
    tmp=GetHead(old_filelist);
d456 1
a456 1
	next=GetSucc(tmp);
@


1.265
log
@Groups added. Bugs fixed.
@
text
@a9 2
    char temp[200];
    char *lname;
d233 9
a241 8
	if (tmp->name)
	  free(tmp->name);
	if (tmp->date)
	  free(tmp->date);
	if (tmp->owner)
	  free(tmp->owner);
	if (tmp->group)
	  free(tmp->group);
d243 2
a244 1
	free(tmp);
@


1.200
log
@GETATTR-hit fixed.
@
text
@d22 6
a27 4
    tmp->date = (char *)malloc((unsigned int)(strlen(date) + 1));
    if (tmp->date == NULL) {
	free_direntry(tmp);
	return NULL;
d30 6
a35 4
    tmp->owner = (char *)malloc((unsigned int)(strlen(owner) + 1));
    if (tmp->owner == NULL) {
	free_direntry(tmp);
	return NULL;
d38 6
a43 4
    tmp->group = (char *)malloc((unsigned int)(strlen(group) + 1));
    if (tmp->group == NULL) {
	free_direntry(tmp);
	return NULL;
d55 6
a60 3
    strcpy(tmp->date, date);
    strcpy(tmp->owner, owner);
    strcpy(tmp->group, group);
d180 1
a180 1
			      LBNCA_Justification,LCJ_RIGHT,
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
@d15 1
a15 1
      return(NULL);
d20 1
a20 1
	return (NULL);
d25 1
a25 1
	return (NULL);
d31 1
a31 1
	return (NULL);
d37 1
a37 1
	return (NULL);
d57 1
a57 1
    return (tmp);
d130 2
a131 2
	    Insert(filelist,tmp2,oldprev);
	    return(TRUE);
d134 1
a134 1
    return(FALSE);
d186 1
a186 1
	  tmp = sortupbyname(filelist, dlist->name,ISDIR(dlist->mode));
d188 1
a188 1
	  tmp = sortdownbyname(filelist, dlist->name,ISDIR(dlist->mode));
d192 1
a192 1
	  tmp = sortupbydate(filelist, dlist->date);
d194 1
a194 1
	  tmp = sortdownbydate(filelist, dlist->date);
d198 1
a198 1
	  tmp = sortupbysize(filelist, dlist->size);
d200 1
a200 1
	  tmp = sortdownbysize(filelist, dlist->size);
d262 1
a262 1
      return((struct dirlist *)GetPred((struct Node *)tmp2));
d265 1
a265 1
	  return((struct dirlist *)GetTail(filelist));
d267 1
a267 1
	  return(NULL);
d291 1
a291 1
      return((struct dirlist *)GetPred((struct Node *)tmp2));
d294 1
a294 1
	  return((struct dirlist *)GetTail(filelist));
d296 1
a296 1
	  return(NULL);
d313 1
a313 1
      return((struct dirlist *)GetPred((struct Node *)tmp2));
d316 1
a316 1
	  return((struct dirlist *)GetTail(filelist));
d318 1
a318 1
	  return(NULL);
d333 1
a333 1
      return((struct dirlist *)GetPred((struct Node *)tmp2));
d336 1
a336 1
	  return((struct dirlist *)GetTail(filelist));
d338 1
a338 1
	  return(NULL);
d354 1
a354 1
      return((struct dirlist *)GetPred((struct Node *)tmp2));
d357 1
a357 1
	  return((struct dirlist *)GetTail(filelist));
d359 1
a359 1
	  return(NULL);
d373 1
a373 1
      return((struct dirlist *)GetPred((struct Node *)tmp2));
d376 1
a376 1
	  return((struct dirlist *)GetTail(filelist));
d378 1
a378 1
	  return(NULL);
d415 1
a415 1
    return (tm.tm_min + tm.tm_hour * 60
d417 1
a417 1
	       cummonthdays[tm.tm_mon]) * 1440);
d430 2
a431 2
      return (1);
    return (0);
d440 1
a440 1
      return(old_filelist);
d443 1
a443 1
      return(old_filelist);
d454 1
a454 1
    return(new_filelist);
d464 2
a465 2
	char	month[10];
	int		i;
d467 8
a474 8
	bzero((char *)tm, sizeof (struct tm));
	sscanf(date, "%s%d%d:%d", month, &tm->tm_mday,
		&tm->tm_hour, &tm->tm_min);
	for (i = 0; i < 12; i++)
		if (!strncmp(month, abbrev_month[i], 3))
			break;
	if (i != 12)
		tm->tm_mon = i;
d479 2
a480 2
	char	month[10];
	int		i;
d482 9
a490 9
	bzero((char *)tm, sizeof (struct tm));
	sscanf(date, "%s%d%d", month, &tm->tm_mday, &tm->tm_year);
	for (i = 0; i < 12; i++)
		if (!strncmp(month, abbrev_month[i], 3))
			break;
	if (i != 12)
		tm->tm_mon = i;
	if (tm->tm_year > 1900)
		tm->tm_year -= 1900;
@


0.1343
log
@Removed some redudant things from AllocListbrowserNode()
Gadgets no longer flicker since I keep track of the state. Thought ClassAct did that, but no...
Added one tick to the fuelgauge, now 11 ticks => 10 intervals.
@
text
@d67 1
d70 3
a72 1
      return(TRUE);
d99 1
d104 1
a104 1
					       LBNA_Flags,LBFLG_CUSTOMPENS,
d141 7
d150 1
a150 1
			      LBNA_Flags,LBFLG_CUSTOMPENS,
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@a101 1
					       LBNCA_MaxChars,60,
a105 1
					       LBNCA_MaxChars,10,
a109 1
					       LBNCA_MaxChars,6,
a113 1
					       LBNCA_MaxChars,10,
a115 1
					       LBNCA_MaxChars,8,
a119 1
					       LBNCA_MaxChars,8,
a140 1
			      LBNCA_MaxChars,60,
@


0.814
log
@Added default download-dir.
@
text
@d2 2
d39 1
a43 3
    sprintf(temp,"%-30.30s %8ld %6.6s %12.12s",S_ISLNK(mode)?lname:name,
	    size,
	    mode&0x4000?"(dir)":S_ISLNK(mode)?"(link)":"",date);
d46 1
a46 5
    tmp->listname = strdup(temp);
    if (tmp->listname == NULL) {
	free_direntry(tmp);
	return(NULL);
    }
a51 1
    tmp->dl_Node.ln_Name=tmp->listname;
d59 1
d98 37
a134 2
	Insert(filelist,tmp,oldprev);
	return(TRUE);
d142 32
a173 1
    struct dirlist *tmp;
d199 1
a199 2

    Insert(filelist,dlist,tmp);
a211 2
    if (tmp->listname)
      free(tmp->listname);
d218 1
d220 2
a221 1
    while (tmp=(struct dirlist *)RemHead(filelist)) {
a229 2
	if (tmp->listname)
	  free(tmp->listname);
d232 1
d241 1
d244 2
a245 1
    for (tmp=(struct dirlist *)GetHead(filelist);tmp;tmp=(struct dirlist *)GetSucc((struct Node *)tmp)) {
d257 2
a258 2
    if (tmp)
      return((struct dirlist *)GetPred((struct Node *)tmp));
d269 1
d273 2
a274 1
    for (tmp=(struct dirlist *)GetHead(filelist);tmp;tmp=(struct dirlist *)GetSucc((struct Node *)tmp)) {
d286 2
a287 2
    if (tmp)
      return((struct dirlist *)GetPred((struct Node *)tmp));
d301 1
d303 7
a309 5
    for (tmp=(struct dirlist *)GetHead(filelist);tmp;tmp=(struct dirlist *)GetSucc((struct Node *)tmp))
      if (isearlier(date,tmp->date))
	break;
    if (tmp)
      return((struct dirlist *)GetPred((struct Node *)tmp));
d321 1
d323 2
a324 1
    for (tmp = (struct dirlist *)GetHead(filelist); tmp; tmp = (struct dirlist *)GetSucc((struct Node *)tmp)) {
d328 2
a329 2
    if (tmp)
      return((struct dirlist *)GetPred((struct Node *)tmp));
d343 8
a350 6

    for (tmp=(struct dirlist *)GetHead(filelist);tmp;tmp=(struct dirlist *)GetSucc((struct Node *)tmp))
      if (size<=tmp->size)
	break;
    if (tmp)
      return((struct dirlist *)GetPred((struct Node *)tmp));
d361 1
d363 7
a369 5
    for (tmp=(struct dirlist *)GetHead(filelist);tmp;tmp=(struct dirlist *)GetSucc((struct Node *)tmp))
      if (size>=tmp->size)
	break;
    if (tmp)
      return((struct dirlist *)GetPred((struct Node *)tmp));
d432 1
a432 1
    struct dirlist *tmp,*next;
d434 1
d441 1
a441 1
    tmp=(struct dirlist *)GetHead(old_filelist);
d443 4
a446 3
	next=(struct dirlist *)GetSucc((struct Node *)tmp);
	Remove((struct Node *)tmp);
	add_direntry_struct(new_filelist,tmp,sort_mode,sort_direction);
@


0.531
log
@Resume transfer added (when getting files).
Get-dir-tree is broken.
@
text
@d120 1
a120 1
	  tmp = sortupbyname(filelist, dlist->name);
d122 1
a122 1
	  tmp = sortdownbyname(filelist, dlist->name);
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d37 4
a40 1
    lname=linkname(name);
@


0.326
log
@Links are now parsed to linkname and (link)
Upload via ARexx should be finished now
@
text
@d55 3
@


0.305
log
@Added some casts to avoid compiler warnings
@
text
@d9 1
d37 6
a42 2

    sprintf(temp,"%-30.30s %8ld %5.5s %12.12s",name,size,mode&0x4000?"(dir)":"",date);
@


0.284
log
@First RCS version.
@
text
@d149 1
a149 1
    while (tmp=RemHead(filelist)) {
d172 1
a172 1
    for (tmp=GetHead(filelist);tmp;tmp=GetSucc(tmp)) {
d185 1
a185 1
      return(GetPred(tmp));
d187 2
a188 2
	if (GetHead(filelist))
	  return(GetTail(filelist));
d199 1
a199 1
    for (tmp=GetHead(filelist);tmp;tmp=GetSucc(tmp)) {
d212 1
a212 1
      return(GetPred(tmp));
d214 2
a215 2
	if (GetHead(filelist))
	  return(GetTail(filelist));
d227 1
a227 1
    for (tmp=GetHead(filelist);tmp;tmp=GetSucc(tmp))
d231 1
a231 1
      return(GetPred(tmp));
d233 2
a234 2
	if (GetHead(filelist))
	  return(GetTail(filelist));
d244 1
a244 1
    for (tmp = GetHead(filelist); tmp; tmp = GetSucc(tmp)) {
d249 1
a249 1
      return(GetPred(tmp));
d251 2
a252 2
	if (GetHead(filelist))
	  return(GetTail(filelist));
d264 1
a264 1
    for (tmp=GetHead(filelist);tmp;tmp=GetSucc(tmp))
d268 1
a268 1
      return(GetPred(tmp));
d270 2
a271 2
	if (GetHead(filelist))
	  return(GetTail(filelist));
d280 1
a280 1
    for (tmp=GetHead(filelist);tmp;tmp=GetSucc(tmp))
d284 1
a284 1
      return(GetPred(tmp));
d286 2
a287 2
	if (GetHead(filelist))
	  return(GetTail(filelist));
d355 1
a355 1
    tmp=GetHead(old_filelist);
d357 2
a358 2
	next=GetSucc(tmp);
	Remove(tmp);
@
