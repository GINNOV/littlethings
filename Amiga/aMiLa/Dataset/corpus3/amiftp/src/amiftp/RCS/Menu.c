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
next	1.720;

1.720
date	96.07.27.23.43.40;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.630;

1.630
date	96.07.07.20.10.48;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	;


desc
@Menu-building functions and support functions.
@


1.795
log
@Stuff.
@
text
@/* RCS Id: $Id: Menu.c 1.730 1996/08/02 21:57:32 lilja Exp lilja $
   Locked version: $Revision: 1.730 $
*/

#include "AmiFTP.h"
#include "gui.h"

static int menu_Connect(struct MenuItem *menuitem);
static int menu_Disconnect(struct MenuItem *menuitem);
static int menu_Parent(struct MenuItem *menuitem);
static int menu_Get(struct MenuItem *menuitem);
static int menu_Put(struct MenuItem *menuitem);
static int menu_View(struct MenuItem *menuitem);
static int menu_Quit(struct MenuItem *menuitem);
static int menu_SortByName(struct MenuItem *menuitem);
static int menu_SortByDate(struct MenuItem *menuitem);
static int menu_Iconify(struct MenuItem *menuitem);
static int menu_SelectAll(struct MenuItem *menuitem);
static int menu_UnselectAll(struct MenuItem *menuitem);
static int menu_Delete(struct MenuItem *menuitem);
static int menu_Move(struct MenuItem *menuitem);
static int menu_ClearCache(struct MenuItem *menuitem);
static int menu_HostlistPrefs(struct MenuItem *menuitem);
static int menu_BinaryTransferMode(struct MenuItem *menuitem);
static int menu_AsciiTransferMode(struct MenuItem *menuitem);
static int menu_ResetADT(struct MenuItem *menuitem);
static int menu_ToggleADT(struct MenuItem *menuitem);
static int menu_ToggleDotFiles(struct MenuItem *menuitem);
static int menu_LogWindow(struct MenuItem *menuitem);
static int menu_AddToSitelist(struct MenuItem *menuitem);
static int menu_LoadPrefs(struct MenuItem *menuitem);
static int menu_SavePrefs(struct MenuItem *menuitem);
static int menu_SavePrefsAs(struct MenuItem *menuitem);
static int menu_About(struct MenuItem *menuitem);
static int menu_Reconnect(struct MenuItem *menuitem);
static int menu_OpenPrefsWindow(struct MenuItem *menuitem);
static int menu_PatternSelect(struct MenuItem *menuitem);
static int menu_ViewReadme(struct MenuItem *menuitem);

struct Menu *menu;
extern struct VisualInfo *VisualInfo;

struct CallBackHook menuhooks[]={
    {menu_Connect, AG_MENUCONNECT},
    {menu_Disconnect, AG_MENUDISCONNECT},
    {menu_Reconnect, AG_MENURECONNECT},
    {menu_AddToSitelist, AG_MENUADDTOSITELIST},
    {menu_ResetADT, AG_MENURESETADT},
    {menu_Iconify, AG_MENUICONIFY},
    {menu_About, AG_MENUABOUT},
    {menu_Quit, AG_MENUQUIT},
    {menu_SelectAll, AG_MENUTAGALL},
    {menu_UnselectAll, AG_MENUUNTAGALL},
    {menu_PatternSelect, AG_MENUPATTERN},
    {menu_BinaryTransferMode, AG_MENUTRANSFERMODE},
    {menu_AsciiTransferMode, AG_MENUTRANSFERMODE},
    {menu_ClearCache, AG_MENUCLEARCACHE},
    {menu_Parent, AG_MENUPARENT},
    {menu_Get, AG_MENUGET},
    {menu_Put, AG_MENUPUT},
    {menu_View, AG_MENUVIEW},
    {menu_ViewReadme, AG_MENUVIEWREADME},
    {menu_Delete, AG_MENUDELETE},
    {menu_SortByName, AG_MENUSORT},
    {menu_SortByDate, AG_MENUSORT},
    {menu_OpenPrefsWindow, AG_MENUGLOBAL},
    {menu_HostlistPrefs, AG_MENUSITELIST},
    {menu_LogWindow, AG_MENULOGWINDOW},
    {menu_ToggleDotFiles, AG_MENUTOGGLEDOT},
    {menu_ToggleADT, AG_MENUTOGGLEADT},
    {menu_LoadPrefs, AG_MENULOADSETTINGS},
    {menu_SavePrefs, AG_MENUSAVESETTINGS},
    {menu_SavePrefsAs, AG_MENUSAVESETTINGS}
};

struct NewMenu mainmenus[] = 
{
    {NM_TITLE, NULL, NULL,0,~0,NULL},                /* Project */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[0]}, /* Connect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[1]}, /* Disconnect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[2]}, /* Reconnect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[3]}, /* Add to sitelist */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[4]}, /* Reset ADT-date */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[5]}, /* Iconify */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[6]}, /* About */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[7]}, /* Quit */
    {NM_TITLE, NULL,NULL,0,~0,NULL},                 /* Files */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[8]}, /* Tag all */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[9]}, /* Untag all */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[10]},
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,NULL},                /* Transfer mode */
    {NM_SUB,     NULL,NULL,CHECKIT,~1,&menuhooks[11]},  /* Binary */
    {NM_SUB,     NULL,NULL,0,~2,&menuhooks[12]},        /* ASCII */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[13]},      /* Clear cache */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[14]},      /* Parent */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[15]},      /* Get */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[16]},      /* Put */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[17]},       /* View */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[18]},       /* View readme */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[19]},/* Delete */
/*    {NM_ITEM,    "Move","M",0,~0,(APTR) &menuhooks[9]},*/
    {NM_TITLE, NULL,NULL,0,~0,NULL},                   /* Sort */
    {NM_ITEM,    NULL,NULL,CHECKIT,~1,(APTR)&menuhooks[20]},
    {NM_ITEM,    NULL,NULL,CHECKIT,~2,(APTR)&menuhooks[21]},
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* Settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[22]},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[23]},
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[24]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[25]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[26]}, /* Log window */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[27]},                   /* Load settings... */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[28]},                   /* Save settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[29]},                   /* Save settings as...*/
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* HotList */
    {NM_END}
};

LONG MenuLabels[] =
{
    (LONG)MENU_Project,
    (LONG)MENU_Connect,
    (LONG)MENU_Disconnect,
    (LONG)MENU_Reconnect,
    (LONG)MENU_AddToSiteList,
    (LONG)MENU_ResetADT,
    (LONG)MENU_Iconify,
    (LONG)MENU_About,
    (LONG)MENU_Quit,

    (LONG)MENU_Files,
    (LONG)MENU_TagAll,
    (LONG)MENU_UntagAll,
    (LONG)MENU_PatternSelect,
    (LONG)MENU_TransferMode,
    (LONG)MENU_Binary,
    (LONG)MENU_ASCII,
    (LONG)MENU_ClearCache,
    (LONG)MENU_Parent,
    (LONG)MENU_Get,
    (LONG)MENU_Put,
    (LONG)MENU_View,
    (LONG)MENU_ViewReadme,
    (LONG)MENU_Delete,
    /*MENU_Move,*/

    (LONG)MENU_Sort,
    (LONG)MENU_SortbyName,
    (LONG)MENU_SortbyDate,

    (LONG)MENU_Settings,
    (LONG)MENU_Global,
    (LONG)MENU_Hostlist,
    (LONG)MENU_LogWindow,
    (LONG)MENU_ToggleDotFiles,
    (LONG)MENU_ToggleADTFiles,
    (LONG)MENU_LoadSettings,
    (LONG)MENU_SaveSettings,
    (LONG)MENU_SaveSettingsAs,

    (LONG)MENU_HotList
  };


int BuildMenu(void)
{
    struct NewMenu *NewMenu;
    struct Menu *MenuNew;

    long Count=0,SiteCount=0;
    struct SiteNode *ptr;
    struct Node *lbn;

    while(mainmenus[Count++].nm_Type!=NM_END);

    for (lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData, &ptr,
				TAG_DONE);
	if (ptr) {
	    if (ptr->sn_HotList)
	      SiteCount++;
	}
    }

    if (NewMenu = (struct NewMenu *)AllocVec((Count + SiteCount) * sizeof(struct NewMenu),MEMF_ANY|MEMF_CLEAR)) {
	extern BPTR LogWindow;
	mainmenus[19].nm_Flags=CHECKIT|(TransferMode==BINARY?CHECKED:NULL);
	mainmenus[20].nm_Flags=CHECKIT|(TransferMode==ASCII?CHECKED:NULL);
	mainmenus[31].nm_Flags=CHECKIT|(SortMode==SORTBYNAME?CHECKED:NULL);
	mainmenus[32].nm_Flags=CHECKIT|(SortMode==SORTBYDATE?CHECKED:NULL);
	mainmenus[37].nm_Flags=CHECKIT|MENUTOGGLE|(LogWindow?CHECKED:NULL);
	mainmenus[38].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_Showdotfiles?CHECKED:NULL);
	mainmenus[39].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_ShowAllADTFiles?CHECKED:NULL);

	CopyMem(mainmenus, NewMenu, Count * sizeof(struct NewMenu));
	if (SiteCount) {
	    Count--;
	    SiteCount=0;
	    for (lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
		GetListBrowserNodeAttrs(lbn,
					LBNA_UserData, &ptr,
					TAG_DONE);
		if (ptr) {
		    if (ptr->sn_HotList) {
			if (ptr->sn_MenuType==SLN_CHILD)
			  NewMenu[Count].nm_Type=NM_SUB;
			else 
			  NewMenu[Count].nm_Type=NM_ITEM;

			if (ptr->sn_BarLabel)
			  NewMenu[Count].nm_Label=NM_BARLABEL;
			else
			  NewMenu[Count].nm_Label=ptr->sn_Node.ln_Name;
			NewMenu[Count].nm_UserData=(void *)(SiteCount+1);
			SiteCount++;
			Count++;
		    }
		}
	    }
	    NewMenu[Count].nm_Type=NM_END;
	}
	else
	  NewMenu[Count-2].nm_Type=NM_END;
	if (!(MenuNew = CreateMenus(NewMenu, TAG_DONE))) {
	    FreeVec(NewMenu);
	    return 0;
	    
	}
	if (!LayoutMenus(MenuNew, VisualInfo, GTMN_NewLookMenus, TRUE, TAG_DONE)) {
	    FreeMenus(MenuNew);
	    FreeVec(NewMenu);
	    return 0;
	}
	FreeVec(NewMenu);
	menu=MenuNew;

	return 1;
    }
    else return 0;
}

void UpdateMenus(void)
{
    struct Menu *oldmenu=menu;

    if (!BuildMenu())
      return;
    FreeMenus(oldmenu);
    SetAttrs(MainWin_Object, WINDOW_MenuStrip, menu, TAG_DONE);
}

static int menu_Quit(struct MenuItem *menuitem)
{
    return 0;
}

static int menu_SortByName(struct MenuItem *menuitem)
{
    SortMode=SORTBYNAME;

    ClearMenuStrip(MainWindow);
    menuitem->Flags|=CHECKED;
    ResetMenuStrip(MainWindow, menu);

    if (FileList) {
	LockWindow(MainWin_Object);
	DetachToolList();
	if (!CurrentState.ADTMode)
	  FileList=sort_filelist(FileList, SORTBYNAME, ASCENDING);
	else
	  FileList=sort_ADT(FileList, SORTBYNAME);
	AttachToolList(FALSE);
	UnlockWindow(MainWin_Object);
    }

    return 1;
}

static int menu_SortByDate(struct MenuItem *menuitem)
{
    SortMode=SORTBYDATE;

    ClearMenuStrip(MainWindow);
    menuitem->Flags|=CHECKED;
    ResetMenuStrip(MainWindow, menu);

    if (FileList) {
	LockWindow(MainWin_Object);
	DetachToolList();
	if (!CurrentState.ADTMode) 
	  FileList=sort_filelist(FileList, SORTBYDATE, DESCENDING);
	else
	  FileList=sort_ADT(FileList, SORTBYDATE);
	AttachToolList(FALSE);
	UnlockWindow(MainWin_Object);
    }

    return 1;
}

static int menu_Iconify(struct MenuItem *menuitem)
{
    if (CA_Iconify(MainWin_Object))
      MainWindow=NULL;
    return 2;
}

static int menu_SelectAll(struct MenuItem *menuitem)
{
    struct Node *node;
    ULONG n=0,flags;

    /* Fix disconnect/connect of listview */
    if (FileList) {
	for (node=GetHead(FileList);node;node=GetSucc(node)) {
	    GetListBrowserNodeAttrs(node, LBNA_Flags, &flags, TAG_DONE);
	    if (!(flags&LBFLG_HIDDEN)) {
		SetListBrowserNodeAttrs(node,
					LBNA_Selected, TRUE,
					TAG_DONE);
		n=1;
	    }
	}
	if (n) {
	    RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	    UpdateMainButtons(MB_FILESELECTED);
	}
    }
    UpdateWindowTitle();
    return 1;
}

static int menu_UnselectAll(struct MenuItem *menuitem)
{
    struct Node *node;
    ULONG n=0;

    /* Fix: Add disconnect/connect of listview */
    if (FileList) {
	for (node=GetHead(FileList);node;node=GetSucc(node)) {
	    SetListBrowserNodeAttrs(node,
				    LBNA_Selected, FALSE,
				    TAG_DONE);
	    n=1;
	}
	if (n)
	  RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	UpdateMainButtons(MB_NONESELECTED);
    }
    UpdateWindowTitle();
    return 1;
}

static int menu_Delete(struct MenuItem *menuitem)
{
    struct dirlist *curr;
    struct Node *node,*nnode;
    int t=0;
    int sel=0;
    static ULONG tags[]={
	RTEZ_ReqTitle, NULL,
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END};

    tags[1]=(ULONG)GetAmiFTPString(Str_AmiFTPRequest);
    tags[3]=(ULONG)MainWindow;

    if (FileList) {
	LockWindow(MainWin_Object);
	if (!rtEZRequest(GetAmiFTPString(MW_DeleteRequest),
			 GetAmiFTPString(MW_DeleteCancel), NULL,
			 (struct TagItem *)tags)) {
	    UnlockWindow(MainWin_Object);
	    return 1;
	}
	node=GetHead(FileList);
	while (node) {
	    nnode=GetSucc(node);
	    sel=0;
	    GetListBrowserNodeAttrs(node, LBNA_Selected, &sel, TAG_DONE);
	    if (sel) {
		curr=(void *)node->ln_Name; /* The dirlist-structure is in ln_Name */
		if (curr) {
		    if (delete_remote(curr->name,
				      (!S_ISDIR(curr->mode))?"DELE":"RM")) {
			LBRemNode(MG_List[MG_ListView], MainWindow, NULL, node);
			free_direntry(curr);
		    }
		    else
		      t=1;
		}
	    }
	    node=nnode;
	}
	if (t==0)
	  UpdateMainButtons(MB_NONESELECTED);
	UnlockWindow(MainWin_Object);
    }
    UpdateWindowTitle();
    return 1;
}

static int menu_Move(struct MenuItem *menuitem)
{
    return 1;
}

static int menu_ClearCache(struct MenuItem *menuitem)
{
    ClearCache(FALSE);
    return 1;
}

static int menu_HostlistPrefs(struct MenuItem *menuitem)
{
    LockWindow(MainWin_Object);
    OpenSiteListWindow(FALSE);
    UnlockWindow(MainWin_Object);
    return 1;
}

static int menu_BinaryTransferMode(struct MenuItem *menuitem)
{
    if (TransferMode!=BINARY) {
	TransferMode=BINARY;
	ClearMenuStrip(MainWindow);
	menuitem->Flags|=CHECKED;
	ResetMenuStrip(MainWindow, menu);
    }
    return 1;
}

static int menu_AsciiTransferMode(struct MenuItem *menuitem)
{
    if (TransferMode!=ASCII) {
	TransferMode=ASCII;
	ClearMenuStrip(MainWindow);
	menuitem->Flags|=CHECKED;
	ResetMenuStrip(MainWindow, menu);
    }
    return 1;
}

static int menu_ResetADT(struct MenuItem *menuitem)
{
    MainPrefs.mp_LastAminetDate=0;
    MainPrefs.mp_LastAMOTD=0;
    return 1;
}

static int menu_ToggleADT(struct MenuItem *menuitem)
{
    struct Node *node;
    ULONG attr;

    if (!CurrentState.ADTMode)
      return 1;

    if (menuitem) {
	if (menuitem->Flags&CHECKED) {
	    if (FileList) {
		DetachToolList();
		node=GetTail(FileList);
		if (node->ln_Name==NULL) {
		    Remove(node);
		    FreeListBrowserNode(node);
		}
		for (node=GetHead(FileList);node;node=GetSucc(node)) {
		    SetListBrowserNodeAttrs(node, LBNA_Flags, LBFLG_CUSTOMPENS,
					    TAG_DONE);
		}
		if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
				   LISTBROWSER_Labels, FileList,
				   LISTBROWSER_AutoFit, TRUE,
				   LISTBROWSER_MakeVisible, 0, TAG_DONE))
		  RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
//		AttachToolList(FALSE);
	    }
	    MainPrefs.mp_ShowAllADTFiles=TRUE;
	}
	else {
	    if (FileList) {
		DetachToolList();
		for (node=GetHead(FileList);node;node=GetSucc(node)) {
		    struct dirlist *n=(struct dirlist *)node->ln_Name;
		    if (!n->new || n->hide) {
			SetListBrowserNodeAttrs(node,
						LBNA_Flags, LBFLG_CUSTOMPENS|LBFLG_HIDDEN,
						LBNA_Selected, FALSE,
						TAG_DONE);
		    }
		}
		for (node=GetHead(FileList);node;node=GetSucc(node)) {
		    ULONG flags;

		    GetListBrowserNodeAttrs(node,LBNA_Flags, &flags, TAG_DONE);
		    if (!(flags&LBFLG_HIDDEN))
		      break;
		}
		if (!node) {
		    node=AllocListBrowserNode(6,
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
		      AddTail(FileList,node);
    }
		if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
				   LISTBROWSER_Labels, FileList,
				   LISTBROWSER_AutoFit, TRUE,
				   LISTBROWSER_MakeVisible, 0, TAG_DONE))
		  RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
//		AttachToolList(FALSE);
		GetAttr(LISTBROWSER_Selected, MG_List[MG_ListView], &attr);
		if (attr) {
		    UpdateMainButtons(MB_FILESELECTED);
		}
		else {
		    UpdateMainButtons(MB_NONESELECTED);
		}
	    }
	    MainPrefs.mp_ShowAllADTFiles=FALSE;
	}
    }
    UpdateWindowTitle();
    return 1;
}

static int menu_ToggleDotFiles(struct MenuItem *menuitem)
{
    struct Node *node;
    ULONG attr;

    if (CurrentState.ADTMode)
      return 1;

    if (menuitem) {
	if (menuitem->Flags&CHECKED) {
	    if (FileList) {
		DetachToolList();
		for (node=ListHead(FileList);ListEnd(node);node=ListNext(node)) {
		    SetListBrowserNodeAttrs(node, LBNA_Flags, LBFLG_CUSTOMPENS,
					    TAG_DONE);
		}
		AttachToolList(FALSE);
	    }
	    MainPrefs.mp_Showdotfiles=TRUE;
	}
	else {
	    if (FileList) {
		DetachToolList();
		for (node=ListHead(FileList);ListEnd(node);node=ListNext(node)) {
		    struct dirlist *n=(struct dirlist *)node->ln_Name;
		    if (n->name[0]=='.') {
			SetListBrowserNodeAttrs(node,
						LBNA_Flags, LBFLG_CUSTOMPENS|LBFLG_HIDDEN,
						LBNA_Selected, FALSE, TAG_DONE);
		    }
		}
		AttachToolList(FALSE);
		GetAttr(LISTBROWSER_Selected, MG_List[MG_ListView], &attr);
		if (attr) {
		    UpdateMainButtons(MB_FILESELECTED);
		}
		else {
		    UpdateMainButtons(MB_NONESELECTED);
		}
	    }
	    MainPrefs.mp_Showdotfiles=FALSE;
	}
    }
    return 1;
}

static int menu_LogWindow(struct MenuItem *menuitem)
{
    if (menuitem) {
	if (menuitem->Flags&CHECKED)
	  OpenLogWindow();
	else
	  CloseLogWindow();
    }
    
    return 1;
}

static int menu_AddToSitelist(struct MenuItem *menuitem)
{
    struct SiteNode *sn;

    if (!TCPStack)
      return 1;

    if (CurrentState.CurrentSite[0]==0)
      return 1;

    sn=AllocMem(sizeof(struct SiteNode), MEMF_CLEAR);
    if (sn) {
	sn->sn_Node.ln_Name=strdup(CurrentState.CurrentSite);
	if (!sn->sn_Node.ln_Name) {
	    FreeMem(sn,sizeof(struct SiteNode));
	    return 1;
	}
	sn->sn_SiteAddress=strdup(CurrentState.CurrentSite);
	if (!sn->sn_Node.ln_Name) {
	    free(sn->sn_Node.ln_Name);
	    FreeMem(sn, sizeof(struct SiteNode));
	    return 1;
	}
	sn->sn_RemoteDir=strdup(CurrentState.CurrentRemoteDir);
	if (!sn->sn_RemoteDir) {
	    free(sn->sn_Node.ln_Name);
	    free(sn->sn_SiteAddress);
	    FreeMem(sn, sizeof(struct SiteNode));
	    return 1;
	}
	sn->sn_Port=21;
	sn->sn_Proxy=MainPrefs.mp_DefaultProxy;
	sn->sn_Anonymous=1;
	AddLBNTail(&SiteList, sn);
	ConfigChanged=TRUE;
    }
    return 1;
}

static int menu_LoadPrefs(struct MenuItem *menuitem)
{
    LoadPrefs();
    return 1;
}

static int menu_SavePrefs(struct MenuItem *menuitem)
{
    SavePrefs();
    return 1;
}

static int menu_SavePrefsAs(struct MenuItem *menuitem)
{
    SavePrefsAs();
    return 1;
}

static int menu_About(struct MenuItem *menuitem)
{
    About();
    return 1;
}

static int menu_Reconnect(struct MenuItem *menuitem)
{
    Reconnect();
    return 1;
}

static int menu_OpenPrefsWindow(struct MenuItem *menuitem)
{
    OpenPrefsWindow();
    return 1;
}

static int menu_Connect(struct MenuItem *menuitem)
{
    Connect_clicked();
    return 1;
}

static int menu_Disconnect(struct MenuItem *menuitem)
{
    Disconnect_clicked();
    return 1;
}

static int menu_Parent(struct MenuItem *menuitem)
{
    if (FileList && connected && !CurrentState.ADTMode)
      Parent_clicked();

    return 1;
}

static int menu_Get(struct MenuItem *menuitem)
{
    if (FileList && connected)
      Get_clicked();

    return 1;
}

static int menu_Put(struct MenuItem *menuitem)
{
    if (connected)
      Put_clicked();

    return 1;
}

static int menu_View(struct MenuItem *menuitem)
{
    if (FileList && connected)
      View_clicked(FALSE);

    return 1;
}

static int menu_ViewReadme(struct MenuItem *menuitem)
{
    if (FileList && connected && CurrentState.ADTMode)
      View_clicked(TRUE);

    return 1;
}

static int menu_PatternSelect(struct MenuItem *menuitem)
{
    static ULONG tags[]={
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RTGS_TextFmt, NULL,
	RTGS_Flags, GSREQF_CENTERTEXT,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END
      };
    char patterbuf[50]="";

    if (!FileList || !connected)
      return 1;

    tags[1]=(ULONG)MainWindow;
    tags[5]=(ULONG)GetAmiFTPString(Str_SelectPattern);

    if (rtGetStringA(patterbuf, 50, GetAmiFTPString(Str_PatternRequest), NULL,
		     (struct TagItem *)tags)) {
	char pattern[104];
	struct Node *node;
	ULONG flags;
	int n=0;

	ParsePatternNoCase(patterbuf, pattern, 104);
	for (node=GetHead(FileList); node; node=GetSucc(node)) {
	    GetListBrowserNodeAttrs(node, LBNA_Flags, &flags, TAG_DONE);
	    if (!(flags&LBFLG_HIDDEN)) {
		if (MatchPatternNoCase(pattern, 
				       ((struct dirlist *)node->ln_Name)->name)) {
		    SetListBrowserNodeAttrs(node,
					    LBNA_Selected, TRUE,
					    TAG_DONE);
		    n=1;
		}
	    }
	}

	if (n) {
	    RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	    UpdateMainButtons(MB_FILESELECTED);
	}
    }

    return 1;
}

/* EOF */
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
/* RCS Id: $Id: Menu.c 1.720 1996/07/27 23:43:40 lilja Exp lilja $
   Locked version: $Revision: 1.720 $
d10 1
d38 1
d58 1
d62 1
d102 6
a107 4
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[14]},      /* Get */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[15]},      /* Put */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[16]},       /* View */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[17]},/* Delete */
d110 2
a111 2
    {NM_ITEM,    NULL,NULL,CHECKIT,~1,(APTR)&menuhooks[18]},
    {NM_ITEM,    NULL,NULL,CHECKIT,~2,(APTR)&menuhooks[19]},
d113 2
a114 2
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[20]},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[21]},
a115 2
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[22]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[23]}, /* Log window */
d117 2
d120 3
a122 3
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[25]},                   /* Load settings... */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[26]},                   /* Save settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[27]},                   /* Save settings as...*/
d147 1
d151 1
d198 5
a202 5
	mainmenus[29].nm_Flags=CHECKIT|(SortMode==SORTBYNAME?CHECKED:NULL);
	mainmenus[30].nm_Flags=CHECKIT|(SortMode==SORTBYDATE?CHECKED:NULL);
	mainmenus[35].nm_Flags=CHECKIT|MENUTOGGLE|(LogWindow?CHECKED:NULL);
	mainmenus[36].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_Showdotfiles?CHECKED:NULL);
	mainmenus[37].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_ShowAllADTFiles?CHECKED:NULL);
d695 8
d723 8
@


1.720
log
@Select by pattern added.
DLPath()-function added to save some bytes (200 :).
@
text
@d1 2
a2 2
/* RCS Id: $Id: Menu.c 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
d266 1
a266 1
    if (FileList && !CurrentState.ADTMode) {
d269 4
a272 8
	FileList=sort_filelist(FileList, SORTBYNAME, ASCENDING);
	AttachToolList(FALSE);
	UnlockWindow(MainWin_Object);
    }
    else if (FileList) {
	LockWindow(MainWin_Object);
	DetachToolList();
	FileList=sort_ADT(FileList, SORTBYNAME);
d276 1
d288 1
a288 1
    if (FileList && !CurrentState.ADTMode) {
d291 4
a294 8
	FileList=sort_filelist(FileList, SORTBYDATE, DESCENDING);
	AttachToolList(FALSE);
	UnlockWindow(MainWin_Object);
    }
    else if (FileList) {
	LockWindow(MainWin_Object);
	DetachToolList();
	FileList=sort_ADT(FileList, SORTBYDATE);
d298 1
d370 1
d387 4
a390 17
		    if (!S_ISDIR(curr->mode)) {
			if (delete_remote(curr->name, "DELE")) {
			    LBRemNode(MG_List[MG_ListView], MainWindow, NULL, node);
			    free_direntry(curr);
			}
			else {
			    t=1;
			}
		    }
		    else {
			if (delete_remote(curr->name, "RM")) {
			    LBRemNode(MG_List[MG_ListView], MainWindow, NULL, node);
			    free_direntry(curr);
			}
			else {
			    t=1;
			}
d392 2
d603 3
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id: $Id: Menu.c 1.630 1996/07/07 20:10:48 lilja Exp lilja $
   Locked version: $Revision: 1.630 $
d331 2
a332 3
	if (n)
	  RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	if (GetHead(FileList))
d334 1
d726 43
@


1.630
log
@Added items in the menu to duplicate the buttons.
@
text
@d1 2
a2 2
/* RCS Id: $Id: Menu.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d36 1
d52 1
d90 1
d93 2
a94 2
    {NM_SUB,     NULL,NULL,CHECKIT,~1,&menuhooks[10]},  /* Binary */
    {NM_SUB,     NULL,NULL,0,~2,&menuhooks[11]},        /* ASCII */
d96 1
a96 1
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[12]},      /* Clear cache */
d98 4
a101 4
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[13]},      /* Get */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[14]},      /* Put */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[15]},       /* View */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[16]},/* Delete */
d104 2
a105 2
    {NM_ITEM,    NULL,NULL,CHECKIT,~1,(APTR)&menuhooks[17]},
    {NM_ITEM,    NULL,NULL,CHECKIT,~2,(APTR)&menuhooks[18]},
a106 1
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[19]},
d108 1
a109 1
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[21]}, /* Log window */
d112 1
d114 3
a116 3
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[24]},                   /* Load settings... */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[25]},                   /* Save settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[26]},                   /* Save settings as...*/
d136 1
d188 7
a194 7
	mainmenus[18].nm_Flags=CHECKIT|(TransferMode==BINARY?CHECKED:NULL);
	mainmenus[19].nm_Flags=CHECKIT|(TransferMode==ASCII?CHECKED:NULL);
	mainmenus[28].nm_Flags=CHECKIT|(SortMode==SORTBYNAME?CHECKED:NULL);
	mainmenus[29].nm_Flags=CHECKIT|(SortMode==SORTBYDATE?CHECKED:NULL);
	mainmenus[34].nm_Flags=CHECKIT|MENUTOGGLE|(LogWindow?CHECKED:NULL);
	mainmenus[35].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_Showdotfiles?CHECKED:NULL);
	mainmenus[36].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_ShowAllADTFiles?CHECKED:NULL);
d721 5
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
/* RCS Id: $Id$
   Locked version: $Revision$
d8 5
d41 2
d54 3
d73 4
a76 3
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[0]}, /* Reconnect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[1]}, /* Add to sitelist */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[2]}, /* Reset ADT-date */
d78 1
a78 1
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[3]}, /* Iconify */
d80 1
a80 1
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[4]}, /* About */
d82 3
a84 1
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[5]}, /* Quit */
d86 2
a87 2
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[6]}, /* Tag all */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[7]}, /* Untag all */
d90 2
a91 2
    {NM_SUB,     NULL,NULL,CHECKIT,~1,&menuhooks[8]},  /* Binary */
    {NM_SUB,     NULL,NULL,0,~2,&menuhooks[9]},        /* ASCII */
d93 1
a93 1
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[10]},      /* Clear cache */
d95 4
a98 1
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[11]},/* Delete */
d101 2
a102 2
    {NM_ITEM,    NULL,NULL,CHECKIT,~1,(APTR)&menuhooks[12]},
    {NM_ITEM,    NULL,NULL,CHECKIT,~2,(APTR)&menuhooks[13]},
d104 2
a105 2
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[14]},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[15]},
d107 3
a109 3
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[16]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[17]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[18]}, /* Log window */
d111 3
a113 3
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[19]},                   /* Load settings... */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[20]},                   /* Save settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[21]},                   /* Save settings as...*/
d121 2
d137 3
d184 7
a190 7
	mainmenus[15].nm_Flags=CHECKIT|(TransferMode==BINARY?CHECKED:NULL);
	mainmenus[16].nm_Flags=CHECKIT|(TransferMode==ASCII?CHECKED:NULL);
	mainmenus[22].nm_Flags=CHECKIT|(SortMode==SORTBYNAME?CHECKED:NULL);
	mainmenus[23].nm_Flags=CHECKIT|(SortMode==SORTBYDATE?CHECKED:NULL);
	mainmenus[28].nm_Flags=CHECKIT|MENUTOGGLE|(LogWindow?CHECKED:NULL);
	mainmenus[29].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_Showdotfiles?CHECKED:NULL);
	mainmenus[30].nm_Flags=CHECKIT|MENUTOGGLE|(MainPrefs.mp_ShowAllADTFiles?CHECKED:NULL);
d681 36
@
