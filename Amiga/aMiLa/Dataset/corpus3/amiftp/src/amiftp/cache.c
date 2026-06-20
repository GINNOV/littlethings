/* RCS Id: $Id: cache.c 1.692 1996/07/20 00:28:38 lilja Exp $
   Locked version: $Revision: 1.692 $
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
