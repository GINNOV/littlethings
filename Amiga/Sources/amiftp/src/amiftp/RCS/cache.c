head	1.692;
access;
symbols;
locks
	lilja:1.692; strict;
comment	@ * @;


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
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1312;

0.1312
date	95.12.14.16.15.31;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.322;

0.322
date	95.06.12.23.14.26;	author lilja;	state Exp;
branches;
next	;


desc
@Cache handling functions.
@


1.692
log
@Speedbar and buttons configurable.
@
text
@/* RCS Id: $Id: cache.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"
#include "gui.h"

static void UpdateCList(void);

static struct List CacheList;
struct List clist;

static numcachedirs;

void InitCache(void)
{
    NewList(&CacheList);
    NewList(&clist);
    if (MainWin_Object) {
	SetAttrs(MG_List[MG_CacheList], CHOOSER_Labels, &clist, TAG_DONE);
    }
    numcachedirs=0;
}

void ClearCache(BOOL all)
{
    struct CacheNode *node;
    while(node=(struct CacheNode *)RemHead(&CacheList))
      if (node->dirlist!=FileList || all) {
	  FreeCacheEntry((struct CacheNode *)node);
	  numcachedirs--;
      }
    if (all && FileList)
      FileList=NULL;
    UpdateCList();
}

void RemoveCacheEntry(char *dirname)
{
    struct Node *cacheentry;
    if (cacheentry=FindName(&CacheList, dirname)) {
	Remove(cacheentry);
	FreeCacheEntry((struct CacheNode *)cacheentry);
	numcachedirs--;
    }
    UpdateCList();
}

void FreeCacheEntry(struct CacheNode *cnode)
{
    if (cnode) {
	free(cnode->cn_Node.ln_Name);
	free_dirlist(cnode->dirlist);
	free(cnode->dirlist);
	free(cnode);
    }
}

void AddCacheEntry(struct List *dirlist, char *name)
{
    struct CacheNode *cnode;
    if (cnode=(struct CacheNode *)FindName(&CacheList, name)) {
	Remove(cnode);
	free(cnode->cn_Node.ln_Name);
	free_dirlist(cnode->dirlist);
	free(cnode->dirlist);
	cnode->cn_Node.ln_Name=strdup(name);
	cnode->dirlist=dirlist;
	AddHead(&CacheList,cnode);
    }
    else {
	if (numcachedirs>=MainPrefs.mp_CacheSize) {
	    cnode=(struct CacheNode *)RemTail(&CacheList);
	    free(cnode->cn_Node.ln_Name);
	    free_dirlist(cnode->dirlist);
	    free(cnode->dirlist);
	    memset(cnode,0,sizeof(struct CacheNode));
	    numcachedirs--;
	}
	if (!cnode)
	  cnode=calloc(sizeof(struct CacheNode), 1);
	if (cnode) {
	    cnode->cn_Node.ln_Name=strdup(name);
	    cnode->dirlist=dirlist;
	    AddHead(&CacheList,cnode);
	    numcachedirs++;
	}
    }
    UpdateCList();
}

struct List *LookupCache(char *name)
{
    struct CacheNode *cnode;
    struct Node *node;

    if (cnode=(struct CacheNode *)FindName(&CacheList, name)) {
	Remove(cnode);
	AddHead(&CacheList, cnode);
	for (node=ListHead(cnode->dirlist);ListEnd(node);node=ListNext(node)) {
	    struct dirlist *n=(struct dirlist *)node->ln_Name;
	    if (MainPrefs.mp_Showdotfiles) {
		SetListBrowserNodeAttrs(node,
					LBNA_Selected, FALSE,
					LBNA_Flags, LBFLG_CUSTOMPENS,
					TAG_DONE);
	    }
	    else {
		if (n->name[0]=='.') {
		    SetListBrowserNodeAttrs(node,
					    LBNA_Selected, FALSE,
					    LBNA_Flags, LBFLG_CUSTOMPENS|LBFLG_HIDDEN,
					    TAG_DONE);
		}
		else {
		    SetListBrowserNodeAttrs(node,
					    LBNA_Selected, FALSE,
					    LBNA_Flags, LBFLG_CUSTOMPENS,
					    TAG_DONE);
		}
	    }
	}
	UpdateCList();
	return cnode->dirlist;
    }
    else
      return NULL;
}

static void UpdateCList()
{
    struct Node *node;
    struct Node *cnode;

    SetAttrs(MG_List[MG_CacheList], CHOOSER_Labels, ~0, TAG_DONE);
    while (node=RemHead(&clist))
      FreeChooserNode(node);
    for (cnode=GetHead(&CacheList); cnode; cnode=GetSucc(cnode)) {
	if (node=AllocChooserNode(CNA_Text, cnode->ln_Name, TAG_DONE))
	  AddTail(&clist, node);
    }

    SetAttrs(MG_List[MG_CacheList], CHOOSER_Labels, &clist,
	     CHOOSER_AutoFit, TRUE, TAG_DONE);
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
/* RCS Id: $Id: cache.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d8 2
d11 2
d18 4
d35 1
d46 1
d89 1
d123 1
d128 17
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


1.531
log
@Lots of stuff
@
text
@d21 2
d85 1
a85 1
	for (node=GetHead(cnode->dirlist);node;node=GetSucc(node)) {
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d26 1
a26 1
    if (cacheentry=FindName(&CacheList,dirname)) {
d43 1
a43 1
void AddCacheEntry(struct List *dirlist,char *name)
d46 1
a46 1
    if (cnode=(struct CacheNode *)FindName(&CacheList,name)) {
d65 1
a65 1
	  cnode=calloc(sizeof(struct CacheNode),1);
d79 2
a80 1
    if (cnode=(struct CacheNode *)FindName(&CacheList,name)) {
d82 1
a82 1
	AddHead(&CacheList,cnode);
d87 2
a88 2
					LBNA_Selected,FALSE,
					LBNA_Flags,LBFLG_CUSTOMPENS,
d93 3
a95 2
		    SetListBrowserNodeAttrs(node,LBNA_Selected,FALSE,
					    LBNA_Flags,LBFLG_CUSTOMPENS|LBFLG_HIDDEN,
d99 3
a101 2
		    SetListBrowserNodeAttrs(node,LBNA_Selected,FALSE,
					    LBNA_Flags,LBFLG_CUSTOMPENS,
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
@d56 1
a56 1
	if (numcachedirs==5) {
d62 1
@


1.200
log
@GETATTR-hit fixed.
@
text
@d83 1
a83 1
	    if (MainPrefs.mp_Showdotfiles==TRUE) {
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
@d102 1
a102 1
	return (cnode->dirlist);
d105 1
a105 1
      return (NULL);
@


0.1312
log
@Fixed NewClicked so it sets the new node as selected+makevisible
@
text
@d81 21
a101 2
	for (node=GetHead(cnode->dirlist);node;node=GetSucc(node))
	  SetListBrowserNodeAttrs(node,LBNA_Selected,FALSE,TAG_DONE);
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d56 1
a56 1
	if (numcachedirs==10) {
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d2 1
d77 1
d81 2
@


0.322
log
@Dir-cache added.
Delete added.
@
text
@d56 1
a56 1
	    cnode=RemTail(&CacheList);
@
