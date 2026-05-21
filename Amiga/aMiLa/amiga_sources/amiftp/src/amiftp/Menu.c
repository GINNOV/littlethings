/* RCS Id: $Id: Menu.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
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
static int menu_CreateDir(struct MenuItem *menuitem);
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
static int menu_RawCommand(struct MenuItem *menuitem);
static int menu_Rename(struct MenuItem *menuitem);

struct Menu *menu;
extern struct VisualInfo *VisualInfo;
enum {
    MNU_ProjectTitle=0,
    MNU_Connect,
    MNU_Disconnect,
    MNU_Reconnect,
    MNU_RawCommand,
    MNU_AddToSiteList,
    MNU_BarLabel1,
    MNU_ResetADT,
    MNU_BarLabel2,
    MNU_Iconify,
    MNU_BarLabel3,
    MNU_About,
    MNU_BarLabel4,
    MNU_Quit,
    MNU_FilesTitle,
    MNU_SelectAll,
    MNU_UnselectAll,
    MNU_PatternSelect,
    MNU_BarLabel5,
    MNU_TransferMode,
    MNU_BinaryTransferMode,
    MNU_AsciiTransferMode,
    MNU_BarLabel6,
    MNU_ClearCache,
    MNU_BarLabel7,
    MNU_Parent,
    MNU_Get,
    MNU_Put,
    MNU_View,
    MNU_ViewReadme,
    MNU_CreateDir,
    MNU_Delete,
    MNU_Rename,
    MNU_SortTitle,
    MNU_SortByName,
    MNU_SortByDate,
    MNU_SettingsTitle,
    MNU_OpenPrefsWindow,
    MNU_HostlistPrefs,
    MNU_BarLabel8,
    MNU_LogWindow,
    MNU_ToggleDotFiles,
    MNU_ToggleADT,
    MNU_BarLabel9,
    MNU_LoadPrefs,
    MNU_SavePrefs,
    MNU_SavePrefsAs,
    MNU_HotListTitle,
};

struct CallBackHook menuhooks[]={
    {0,0},
    {menu_Connect, AG_MENUCONNECT},
    {menu_Disconnect, AG_MENUDISCONNECT},
    {menu_Reconnect, AG_MENURECONNECT},
    {menu_RawCommand, AG_MENURAWCOMMAND},
    {menu_AddToSitelist, AG_MENUADDTOSITELIST},
    {0,0},
    {menu_ResetADT, AG_MENURESETADT},
    {0,0},
    {menu_Iconify, AG_MENUICONIFY},
    {0,0},
    {menu_About, AG_MENUABOUT},
    {0,0},
    {menu_Quit, AG_MENUQUIT},
    {0,0},
    {menu_SelectAll, AG_MENUTAGALL},
    {menu_UnselectAll, AG_MENUUNTAGALL},
    {menu_PatternSelect, AG_MENUPATTERN},
    {0,0},
    {0,0},
    {menu_BinaryTransferMode, AG_MENUTRANSFERMODE},
    {menu_AsciiTransferMode, AG_MENUTRANSFERMODE},
    {0,0},
    {menu_ClearCache, AG_MENUCLEARCACHE},
    {0,0},
    {menu_Parent, AG_MENUPARENT},
    {menu_Get, AG_MENUGET},
    {menu_Put, AG_MENUPUT},
    {menu_View, AG_MENUVIEW},
    {menu_ViewReadme, AG_MENUVIEWREADME},
    {menu_CreateDir, AG_MENUCREATEDIR},
    {menu_Delete, AG_MENUDELETE},
    {menu_Rename, AG_MENURENAME},
    {0,0},
    {menu_SortByName, AG_MENUSORT},
    {menu_SortByDate, AG_MENUSORT},
    {0,0},
    {menu_OpenPrefsWindow, AG_MENUGLOBAL},
    {menu_HostlistPrefs, AG_MENUSITELIST},
    {0,0},
    {menu_LogWindow, AG_MENULOGWINDOW},
    {menu_ToggleDotFiles, AG_MENUTOGGLEDOT},
    {menu_ToggleADT, AG_MENUTOGGLEADT},
    {0,0},
    {menu_LoadPrefs, AG_MENULOADSETTINGS},
    {menu_SavePrefs, AG_MENUSAVESETTINGS},
    {menu_SavePrefsAs, AG_MENUSAVESETTINGS},
    {0,0}
};

struct NewMenu mainmenus[] = 
{
    {NM_TITLE, NULL, NULL,0,~0,NULL},                /* Project */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_Connect]}, /* Connect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_Disconnect]}, /* Disconnect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_Reconnect]}, /* Reconnect */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_RawCommand]}, /* Rawcommand */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_AddToSiteList]}, /* Add to sitelist */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_ResetADT]}, /* Reset ADT-date */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_Iconify]}, /* Iconify */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_About]}, /* About */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_Quit]}, /* Quit */
    {NM_TITLE, NULL,NULL,0,~0,NULL},                 /* Files */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_SelectAll]}, /* Tag all */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_UnselectAll]}, /* Untag all */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_PatternSelect]},
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,NULL},                /* Transfer mode */
    {NM_SUB,     NULL,NULL,CHECKIT,~1,&menuhooks[MNU_BinaryTransferMode]},  /* Binary */
    {NM_SUB,     NULL,NULL,0,~2,&menuhooks[MNU_AsciiTransferMode]},        /* ASCII */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_ClearCache]},      /* Clear cache */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_Parent]},      /* Parent */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_Get]},      /* Get */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_Put]},      /* Put */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_View]},       /* View */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_ViewReadme]},       /* View readme */
    {NM_ITEM,    NULL,NULL,0,~0,&menuhooks[MNU_CreateDir]},       /* Create dir */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[MNU_Delete]},/* Delete */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR) &menuhooks[MNU_Rename]},/* Delete */
/*    {NM_ITEM,    "Move","M",0,~0,(APTR) &menuhooks[9]},*/
    {NM_TITLE, NULL,NULL,0,~0,NULL},                   /* Sort */
    {NM_ITEM,    NULL,NULL,CHECKIT,~1,(APTR)&menuhooks[MNU_SortByName]},
    {NM_ITEM,    NULL,NULL,CHECKIT,~2,(APTR)&menuhooks[MNU_SortByDate]},
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* Settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_OpenPrefsWindow]}, /* Global */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_HostlistPrefs]}, /* Sites */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[MNU_LogWindow]}, /* Log window */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[MNU_ToggleDotFiles]}, /* dotfiles */
    {NM_ITEM,    NULL,NULL,CHECKIT|MENUTOGGLE,0,(APTR)&menuhooks[MNU_ToggleADT]}, /* ADT */
    {NM_ITEM,    NM_BARLABEL,NULL,0,~0,NULL},
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_LoadPrefs]},                   /* Load settings... */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_SavePrefs]},                   /* Save settings */
    {NM_ITEM,    NULL,NULL,0,~0,(APTR)&menuhooks[MNU_SavePrefsAs]},                   /* Save settings as...*/
    {NM_TITLE, NULL,NULL,0,~0,NULL},                     /* HotList */
    {NM_END}
};

LONG MenuLabels[] =
{
    (LONG)MENU_Project,
    (LONG)MENU_Connect,
    (LONG)MENU_Disconnect,
    (LONG)MENU_Reconnect,
    (LONG)MENU_RawCommand,
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
    (LONG)MENU_CreateDir,
    (LONG)MENU_Delete,
    (LONG)MENU_Rename,
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
	mainmenus[MNU_BinaryTransferMode].nm_Flags=
	  CHECKIT|(TransferMode==BINARY?CHECKED:NULL);
	mainmenus[MNU_AsciiTransferMode].nm_Flags=
	  CHECKIT|(TransferMode==ASCII?CHECKED:NULL);
	mainmenus[MNU_SortByName].nm_Flags=
	  CHECKIT|(SortMode==SORTBYNAME?CHECKED:NULL);
	mainmenus[MNU_SortByDate].nm_Flags=CHECKIT|(SortMode==SORTBYDATE?CHECKED:NULL);
	mainmenus[MNU_LogWindow].nm_Flags=
	  CHECKIT|MENUTOGGLE|(LogWindow?CHECKED:NULL);
	mainmenus[MNU_ToggleDotFiles].nm_Flags=
	  CHECKIT|MENUTOGGLE|(MainPrefs.mp_Showdotfiles?CHECKED:NULL);
	mainmenus[MNU_ToggleADT].nm_Flags=
	  CHECKIT|MENUTOGGLE|(MainPrefs.mp_ShowAllADTFiles?CHECKED:NULL);

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

static int menu_CreateDir(struct MenuItem *menuitem)
{
    static ULONG tags[]={
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RTGS_TextFmt, NULL,
	RTGS_Flags, GSREQF_CENTERTEXT,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END
    };
    char dirname[256];

    if (!connected)
      return 1;

    memset(dirname,0,256);

    tags[1]=(ULONG)MainWindow;
    tags[5]=(ULONG)GetAmiFTPString(Str_RemoteDir);

    if (rtGetStringA(dirname, 250, GetAmiFTPString(Str_AmiFTPRequest), NULL,
		     (struct TagItem *)tags)) {
	char comm[270];
	sprintf(comm, "MKD %s", dirname);
	if (command(comm)==ERROR) {
	    ShowErrorReq("Couldn't create directory");
	}
    }

    return 1;
}

static int menu_RawCommand(struct MenuItem *menuitem)
{
    static ULONG tags[]={
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RTGS_TextFmt, NULL,
	RTGS_Flags, GSREQF_CENTERTEXT,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END
    };
    char comm[256];

    if (!connected)
      return 1;

    memset(comm, 0, sizeof(comm));

    tags[1]=(ULONG)MainWindow;
    tags[5]=(ULONG)"Enter FTP-command:";

    if (rtGetStringA(comm, 255, "AmiFTP Request", NULL,
		     (struct TagItem *)tags)) {
	if (command(comm) == ERROR) {
	    ShowErrorReq("Command returned an error.");
	}
    }
    return 1;
}

static int menu_Rename(struct MenuItem *menuitem)
{
    static ULONG tags[]={
	RT_Window, NULL,
	RT_LockWindow, TRUE,
	RTGS_TextFmt, NULL,
	RTGS_Flags, GSREQF_CENTERTEXT,
	RT_ReqPos, REQPOS_CENTERWIN,
	TAG_END
    };
    char comm[256];
    char oldname[256], newname[256];
    struct Node *node;
    ULONG sel;

    if (!connected || !FileList)
      return 1;

    memset(newname, 0, sizeof(newname));

    tags[1]=(ULONG)MainWindow;

    for (node = GetHead(FileList); node; node = GetSucc(node)) {
	GetListBrowserNodeAttrs(node, LBNA_Selected, &sel, TAG_DONE);
	if (sel) {
	    char *filename = ((struct dirlist  *)(node->ln_Name))->name;
	    sprintf(oldname, "Old name %s:\nEnter new name", filename);
	    tags[5] = oldname;
	    if (rtGetStringA(newname, 255, "AmiFTP Request", NULL,
			     (struct TagItem *)tags)) {
		sprintf(comm, "RNFR %s", filename);
		if (command(comm) == ERROR) {
		    ShowErrorReq("Couldn't rename file.");
		}
		else {
		    sprintf(comm, "RNTO %s", newname);
		    if (command(comm) == ERROR) {
			ShowErrorReq("Couldn't rename file.");
		    }
		}
	    }
	}
    }
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
    return 17;
}

static int menu_OpenPrefsWindow(struct MenuItem *menuitem)
{
    OpenPrefsWindow();
    return 1;
}

static int menu_Connect(struct MenuItem *menuitem)
{
    Connect_clicked();
    return 17;
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
