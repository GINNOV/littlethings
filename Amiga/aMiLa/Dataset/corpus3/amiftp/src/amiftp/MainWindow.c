/* RCS Id: $Id: MainWindow.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Locked version: $Revision: 1.795 $
*/

#include "AmiFTP.h"
#include "gui.h"

struct Window *MainWindow;
struct Screen *Screen;
struct DrawInfo *DrawInfo;
struct VisualInfo *VisualInfo;
static struct TextFont *ScreenFont;
static struct TextFont *AmiFTPFont;
static struct TextFont *ListViewFont;
struct TextAttr AmiFTPAttr = {NULL, 0, FS_NORMAL, FPF_PROPORTIONAL};
struct TextAttr ListViewAttr = {NULL, 0, FS_NORMAL, FPF_PROPORTIONAL};
struct TextAttr *AmiFTPAttrF;
struct TextAttr *ListViewAttrF;
struct TextFont *PropFont;
struct TextFont *LBFont;

static ULONG lsel=-1;
static struct Gadget *pagelayout;
extern struct Menu *menu;
extern struct List clist;

int prev_state=-1;

Object *MainWin_Object;
Object *MainWindowLayout;

struct Gadget *MG_List[NumGadgets_main];
extern struct MsgPort *AppPort; /* Move to .h */

static UBYTE sitenamebuffer[100], remotedirbuffer[100], localdirbuffer[100];
struct ColumnInfo columninfo[]={
    {0, NULL, 0},
    {0, NULL, 0},
    {0, NULL, 0},
    {0, NULL, 0},
    {0, NULL, 0},
    {0, NULL, 0},
    {-1, (STRPTR)~0, -1}
};

struct ColumnInfo dummycolumninfo[]={
    {0, NULL, 0},
    {-1, (STRPTR)~0, -1}
};

extern char *wintitle;

static BOOL Upload=FALSE;
struct List DropUploadList;

static void ScrollListbrowser(ULONG direction);
void FreeInfoList(struct List *list);
void CreateInfoList(struct List *list);

ULONG HandleMainWindowIDCMP(const BOOL AllowIconify)
{
    ULONG result,done=FALSE;
    UWORD code=NULL;
    Upload=FALSE;

    while (MainWin_Object &&
	   (result=CA_HandleInput(MainWin_Object,&code))!=WMHI_LASTMSG) {
	switch (result & WMHI_CLASSMASK) {
	  case WMHI_CLOSEWINDOW:
	    done=TRUE;
	    break;
	  case WMHI_GADGETUP:
	    switch (result & WMHI_GADGETMASK) {
	      case MG_ListView: {
		  struct Node *node;
		  ULONG attr;
		  if (FileList) {
		      for (node=GetHead(FileList);node;node=GetSucc(node)) {
			  GetListBrowserNodeAttrs(node,
						  LBNA_Selected, &attr, TAG_DONE);
			  if (attr) break;
		      }
		      if (node) {
			  UpdateMainButtons(MB_FILESELECTED);
		      }
		      else {
			  UpdateMainButtons(MB_NONESELECTED);
		      }
		      if (code!=-1) {
			  ULONG attr=0;
			  ULONG action=0;
			  GetAttrs(MG_List[MG_ListView],
				   LISTBROWSER_NumSelected, &attr,
				   LISTBROWSER_RelEvent, &action,
				   LISTBROWSER_SelectedNode, &node,
				   TAG_DONE);
			  if (attr&&node) {
			      if (action&LBRE_DOUBLECLICK && lsel==code) {
				  struct dirlist *curr=(void *)node->ln_Name;
				  struct List *head;
				  
				  LockWindow(MainWin_Object);
				  if (curr->mode&0x4000) {
				      if (!change_remote_dir(curr->name, 0)) {
					  if (head=LookupCache(CurrentState.CurrentRemoteDir)) {
					      DetachToolList();
					      FileList=head;
					      AttachToolList(TRUE);
					      UpdateMainButtons(MB_NONESELECTED);
					  }
					  else if (head=read_remote_dir()) {
					      DetachToolList();
					      AddCacheEntry(head,CurrentState.CurrentRemoteDir);
					      FileList=head;
					      AttachToolList(TRUE);
					      UpdateMainButtons(MB_NONESELECTED);
					  }
					  else
					    ShowErrorReq(Str_ErrorReadingDir);
				      }
				      else {
					  RemoteCDFailed();
				      }
				  }
				  else if (S_ISLNK(curr->mode)) {
				      char *name;
				      struct List *head;
				      name = linkname(curr->name);
				      
				      if (name) {
					  if (change_remote_dir(name,0)==ENOTDIR) {
					      DownloadFile(FileList,NULL,TransferMode,0);
					  }
					  else {
					      if (head=LookupCache(CurrentState.CurrentRemoteDir)) {
						  DetachToolList();
						  FileList=head;
						  AttachToolList(TRUE);
						  UpdateMainButtons(MB_NONESELECTED);
					      }
					      else if (head=read_remote_dir()) {
						  DetachToolList();
						  AddCacheEntry(head,CurrentState.CurrentRemoteDir);
						  FileList=head;
						  AttachToolList(TRUE);
						  UpdateMainButtons(MB_NONESELECTED);
					      }
					      else
						ShowErrorReq(GetAmiFTPString(Str_ErrorReadingDir));
					  }
					  free(name);
				      }
				  }
				  else {
				      DownloadFile(FileList, NULL, TransferMode, 0);
				  }
				  
				  UnlockWindow(MainWin_Object);
			      }
			  }
			  lsel=code;
		      }
		  }
	      }
		break;
	      case MG_CacheList:
		{
		    struct Node *node;
		    struct List *head;
		    int i;
		    char *dir;

		    for (i=0, node=GetHead(&clist); node; node=GetSucc(node), i++)
		      if (code==i) break;
		    GetChooserNodeAttrs(node, CNA_Text, &dir, TAG_DONE);
		    if (!change_remote_dir(dir, 0)) {
			if (head=LookupCache(CurrentState.CurrentRemoteDir)) {
			    DetachToolList();
			    FileList=head;
			    AttachToolList(TRUE);
			    UpdateMainButtons(MB_NONESELECTED);
			}
		    }
		    else {
			RemoteCDFailed();
		    }
		}
		break;
	      case MG_SpeedBar:
		if (!HandleSpeedBar(code))
		  done=TRUE;
		break;
	      case MG_Get:
	      case MG_Get2:
		Get_clicked();
		break;
	      case MG_Put:
	      case MG_Put2:
		Put_clicked();
		break;
	      case MG_View:
	      case MG_View2:
		View_clicked(FALSE);
		break;
	      case MG_Parent:
		Parent_clicked();
		break;
	      case MG_Readme:
		View_clicked(TRUE);
		break;
	      case MG_DLButton:
		DLPath_clicked();
		break;
	      case MG_DLString:
		DLPathString_clicked();
		break;
	      case MG_Connect:
		Connect_clicked();
		break;
	      case MG_Disconnect:
		Disconnect_clicked();
		break;
	      case MG_Reload:
		Dir_clicked();
		break;
	      case MG_DirName:
		Dir_clicked();
		break;
	      case MG_SiteName:
		Site_clicked();
	      default:
		break;
	    }
	    break;
	  case WMHI_MENUPICK: {
	      USHORT menunum=code;
	      struct CallBackHook *cbh;
	      struct Window *win = MainWindow;

	      while (MainWindow==win && menunum!=MENUNULL) {
		  struct MenuItem *menuitem = ItemAddress(menu, menunum);
		  cbh=(void *)GTMENUITEM_USERDATA(menuitem);
		  if ((ULONG)cbh > 100) {
		      if (cbh->cbh_func) {
			  int ret = cbh->cbh_func(menuitem);
			  if (ret == 17)
			    break;
			  else if (ret == 0)
			    done = TRUE;
		      }
		  }
		  else {	/* Hotlist item selected */
		      int hnum=(int)cbh,i;
		      struct SiteNode *ptr=NULL;
		      struct Node *lbn;
		      hnum--;
		      for (i=0,lbn=GetHead(&SiteList);lbn;lbn=GetSucc(lbn)) {
			  GetListBrowserNodeAttrs(lbn,
						  LBNA_UserData,&ptr,
						  TAG_DONE);
			  if (ptr) {
			      if (ptr->sn_HotList) {
				  if (i==hnum)
				    break;
				  i++;
			      }
			  }
		      }
		      if (ptr && (i==hnum) && ptr->sn_MenuType!=SLN_PARENT && !ptr->sn_BarLabel) {
			  ConnectSite(ptr,0);
			  if (connected)
			    strncpy(CurrentState.LastLVSite,ptr->sn_Node.ln_Name,60);
		      }
		  }
		  menunum=menuitem->NextSelect;
	      }
	      break;
	  }
	  case WMHI_MENUHELP: {
	      struct CallBackHook *cbh;
	      struct MenuItem *menuitem=ItemAddress(menu,result&WMHI_MENUMASK);

	      if (menuitem) {
		  cbh=(void *)GTMENUITEM_USERDATA(menuitem);
		  if (cbh) {
		      if ((LONG)cbh>100)
			SendAGMessage(cbh->cbh_aguide);
		      else
			SendAGMessage(AG_MENUHOTLIST);
		  }
	      }
	  }
	    break;
	  case WMHI_ICONIFY:
	    if (AllowIconify)
	      if (CA_Iconify(MainWin_Object))
		MainWindow=NULL;
	    break;
	  case WMHI_UNICONIFY:
	    MainWindow=CA_OpenWindow(MainWin_Object);
	    break;
	  case WMHI_RAWKEY:
//	    kprintf("key: %ld\n", code);
	    break;
	}
	if (MenuNeedsUpdate) {
	    UpdateMenus();
	    MenuNeedsUpdate=FALSE;
	}
    }

    if (Upload) {
	struct Node *node;
	LockWindow(MainWin_Object);
	UploadFile(&DropUploadList, NULL, TransferMode);
	Upload=FALSE;
	free_dirlist(&DropUploadList);
	UnlockWindow(MainWin_Object);
    }

    return done;
}


struct List dummy_list;
static struct Hook MainIDCMPHook;

static ULONG __asm __saveds MainIDCMPHookFunc(register __a0 struct Hook *hook,
					      register __a2 Object *WinObj,
					      register __a1 struct IntuiMessage *msg)
{
    switch (msg->Class) {
      case IDCMP_RAWKEY:
	switch (msg->Code) {
	  case 95:
	    SendAGMessage(AG_MAINWIN);
	    break;
	  case CURSORUP:
	    if (msg->Qualifier & (IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
	      ScrollListbrowser(LBP_PAGEUP);
	    else if (msg->Qualifier & (IEQUALIFIER_LALT|IEQUALIFIER_RALT))
	      ScrollListbrowser(LBP_TOP);
	    else
	      ScrollListbrowser(LBP_LINEUP);
	    break;
	  case CURSORDOWN:
	    if (msg->Qualifier & (IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
	      ScrollListbrowser(LBP_PAGEDOWN);
	    else if (msg->Qualifier & (IEQUALIFIER_LALT|IEQUALIFIER_RALT))
	      ScrollListbrowser(LBP_BOTTOM);
	    else
	      ScrollListbrowser(LBP_LINEDOWN);
	    break;
	}
	break;
    }
    return 0;
}

static struct Hook AppMessageHook;
static ULONG __asm __saveds AppMessageHookFunc(register __a0 struct Hook *hook,
					       register __a2 Object *WinObj,
					       register __a1 struct AppMessage *msg)
{
    int i;
    struct Node *node;
    extern Object *AboutWin_Object;
    extern Object *EditSiteWin_Object;
    extern Object *TransferWin_Object;
    extern Object *SiteListWin_Object;
    extern Object *MainPrefsWin_Object;

    if (!connected || TransferWin_Object || AboutWin_Object || EditSiteWin_Object ||
	SiteListWin_Object || MainPrefsWin_Object)
      return 0;

    while (node=RemHead(&DropUploadList)) {
	free(node->ln_Name);
	FreeMem(node, sizeof(struct Node));
    }

    for (i=0; i<msg->am_NumArgs; i++) {
	if (msg->am_ArgList[i].wa_Lock && msg->am_ArgList[i].wa_Name) {
	    char path[300];
	    BPTR lock;
	    struct FileInfoBlock fib;

	    NameFromLock(msg->am_ArgList[i].wa_Lock, path, 300);
	    AddPart(path, msg->am_ArgList[i].wa_Name, 300);

	    lock=Lock(path, ACCESS_READ);
	    if (lock) {
		if (Examine(lock, &fib)) {
		    if (fib.fib_DirEntryType<0) {
			struct dirlist *entry;
			struct Node *node;

			if (entry=new_direntry(path, NULL, NULL, NULL,
					       S_IFREG, fib.fib_Size)) {
			    if (node=AllocListBrowserNode(1,
							  LBNA_UserData, entry,
							  LBNA_Column, 0,
							  LBNCA_Text, entry->name,
							  LBNA_Selected, TRUE,
							  TAG_DONE)) {
				node->ln_Name=(void *)entry;
				AddTail(&DropUploadList, node);
				Upload=TRUE;
			    }
			    else
			      free_direntry(entry);
			}
		    }
		}
		UnLock(lock);
	    }
	}
    }
    return 0;
}

struct RastPort *ARPort,rastport;
extern struct List SpeedBarList;

struct Window *OpenFTPWindow(const BOOL StartIconified)
{
    struct Object *g1,*g2, *g3, *but1, *but2, *buttonlayout;

    Screen=LockPubScreen(MainPrefs.mp_OpenOnDefaultScreen?NULL:MainPrefs.mp_PubScreen);
    if (!Screen) {
	char pubname[256];
	Screen=LockPubScreen(NULL);
/*	GetDefaultPubScreen(pubname);
	if (MainPrefs.mp_PubScreen)
	  free(MainPrefs.mp_PubScreen);
	MainPrefs.mp_PubScreen=strdup(pubname);*/
    }
    ScreenFont=OpenFont(Screen->Font);

    AmiFTPAttr.ta_Name=Screen->Font->ta_Name;
    AmiFTPAttr.ta_YSize=Screen->Font->ta_YSize;
    ListViewAttr.ta_Name=Screen->Font->ta_Name;
    ListViewAttr.ta_YSize=Screen->Font->ta_YSize;

    if (!MainPrefs.mp_UseDefaultFonts) {
	if (MainPrefs.mp_FontName && MainPrefs.mp_FontSize > 0) {
	    AmiFTPAttr.ta_Name=MainPrefs.mp_FontName;
	    AmiFTPAttr.ta_YSize=MainPrefs.mp_FontSize;
	}
	if (MainPrefs.mp_ListFontName && MainPrefs.mp_ListFontSize > 0) {
	    ListViewAttr.ta_Name=MainPrefs.mp_ListFontName;
	    ListViewAttr.ta_YSize=MainPrefs.mp_ListFontSize;
	}
    }

    if (AmiFTPFont=OpenDiskFont(&AmiFTPAttr)) {
	AmiFTPAttrF=&AmiFTPAttr;
	PropFont=AmiFTPFont;
    }
    else {
	AmiFTPAttrF=Screen->Font;
	PropFont=ScreenFont;
    }

    if (ListViewFont=OpenDiskFont(&ListViewAttr)) {
	ListViewAttrF=&ListViewAttr;
	LBFont=ListViewFont;
    }
    else {
	ListViewAttrF=AmiFTPAttrF;
	LBFont=PropFont;
    }

    InitRastPort(&rastport);
    SetFont(&rastport, PropFont);
    ARPort=&rastport;
    TextLength(&rastport, "0", 1);
    DrawInfo=GetScreenDrawInfo(Screen);
    VisualInfo=GetVisualInfo(Screen, TAG_DONE);

    InitSpeedBarList();

    CreateInfoList(&dummy_list);

    lsel=-1;
    MainWindowLayout=LayoutObject,
    	               GA_DrawInfo, DrawInfo,
                       GA_TextAttr, AmiFTPAttrF,
	               LAYOUT_DeferLayout, TRUE,//FALSE,
	               LAYOUT_SpaceOuter, TRUE,
	               LAYOUT_HorizAlignment, LALIGN_RIGHT,
	               LAYOUT_Orientation, LAYOUT_ORIENT_VERT,

	               StartMember,g1=LayoutObject,LAYOUT_Orientation,LAYOUT_ORIENT_VERT,
                         StartMember, MG_List[MG_SiteName]=StringObject,
	                   GA_ID,MG_SiteName,
	                   GA_RelVerify, TRUE,
                           STRINGA_Buffer,sitenamebuffer,
	                   STRINGA_MaxChars, 99,
                         StringEnd,Label(GetAmiFTPString(MW_SiteName)),
                       EndGroup,CHILD_WeightedHeight,0,

	               StartHGroup,Spacing(FALSE),
                         StartMember, g2=VGroupObject,
                           StartMember, MG_List[MG_DirName]=StringObject,
	                     GA_ID,MG_DirName,
	                     GA_RelVerify, TRUE,
                             GA_Disabled,TRUE,
                             STRINGA_Buffer,remotedirbuffer,
	                     STRINGA_MaxChars, 120,
                           StringEnd,Label(GetAmiFTPString(MW_DirName)),
                         EndGroup,

                         StartMember, MG_List[MG_CacheList]=ChooserObject,
                           GA_ID, MG_CacheList,
                           GA_RelVerify, TRUE,
//                           GA_Width, 20,
                           GA_Disabled, TRUE,
                           CHOOSER_Labels, &clist,
                           CHOOSER_AutoFit, TRUE,
                           CHOOSER_DropDown, TRUE,
                         ChooserEnd,
                         CHILD_WeightedWidth, 0,

                         StartMember, MG_List[MG_Reload]=ButtonObject,
	                   GA_Text,GetAmiFTPString(MW_Reload),
	                   GA_ID, MG_Reload,
	                   GA_RelVerify, TRUE,
                           GA_Disabled, TRUE,
	                 ButtonEnd,
                         CHILD_WeightedWidth, 0,
                       EndGroup, CHILD_WeightedHeight, 0,

                       StartMember, MG_List[MG_SpeedBar]=SpeedBarObject,
                           GA_ID, MG_SpeedBar,
                           GA_RelVerify, TRUE,
                           SPEEDBAR_Buttons, &SpeedBarList,
                       SpeedBarEnd,

	               StartVGroup, CLASSACT_BackFill, LAYERS_BACKFILL, StartMember,
                         MG_List[MG_ListView]=ListBrowserObject,
	                 GA_ID, MG_ListView,
	                 GA_RelVerify, TRUE,
                         GA_TextAttr, ListViewAttrF,
	                 LISTBROWSER_Labels, (ULONG)FileList?FileList:&dummy_list,
	                 LISTBROWSER_MultiSelect, TRUE,
	                 LISTBROWSER_ShowSelected, TRUE,
                         LISTBROWSER_ColumnInfo, (ULONG)FileList?&columninfo:&dummycolumninfo,
                         LISTBROWSER_Separators, FALSE,
                         LISTBROWSER_AutoFit, TRUE,
                         LISTBROWSER_HorizontalProp, TRUE,
	               ListBrowserEnd,
                       CHILD_MinHeight, LBFont->tf_YSize*6,
                       EndGroup, 

	               LAYOUT_AddChild, g3=VLayoutObject, EvenSized,

  	                 StartHGroup, StartHGroup, Spacing(FALSE),

	                   StartMember, MG_List[MG_DLString]=StringObject,
	                     GA_ID, MG_DLString,
	                     GA_RelVerify, TRUE,
                             STRINGA_Buffer, localdirbuffer,
	                     STRINGA_MaxChars, 80,
	                   StringEnd,

	                   StartMember, MG_List[MG_DLButton]=ButtonObject,
	                     BUTTON_AutoButton, BAG_POPDRAWER,
	                     GA_ID, MG_DLButton,
	                     GA_RelVerify, TRUE,
	                     ButtonEnd,
	                     CHILD_WeightedWidth, 0,
	                     CHILD_WeightedHeight, 0,
	                 EndGroup,
                         CHILD_WeightedHeight, 0,
	                 Label(GetAmiFTPString(MW_DownloadDir)),
                         EndGroup, CHILD_WeightedHeight, 0,

	                 LAYOUT_AddChild, but1=HLayoutObject, EvenSized,
                         LAYOUT_AddChild, pagelayout=LayoutObject,
                         LAYOUT_AddChild, MG_List[MG_Page2]=PageObject,
                         PAGE_Add, LayoutObject,

  	                   StartMember, MG_List[MG_Parent]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_Parent),
	                     GA_ID, MG_Parent,
	                     GA_RelVerify, TRUE,
                             GA_Disabled, TRUE,
	                   ButtonEnd,
                         LayoutEnd,
                         PAGE_Add, LayoutObject,
                           StartMember, MG_List[MG_Readme]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_ViewReadme),
	                     GA_ID, MG_Readme,
	                     GA_RelVerify, TRUE,
                             GA_Disabled, TRUE,
	                   ButtonEnd,
                         LayoutEnd,
                         LayoutEnd,
                         LayoutEnd,
	                   StartMember, MG_List[MG_Get]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_Get),
	                     GA_ID, MG_Get,
	                     GA_RelVerify, TRUE,
                             GA_Disabled, TRUE,
	                   ButtonEnd,
	                   StartMember, MG_List[MG_Put]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_Put),
	                     GA_ID, MG_Put,
	                     GA_RelVerify, TRUE,
                             GA_Disabled, TRUE,
	                   ButtonEnd,
	                   StartMember, MG_List[MG_View]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_View),
	                     GA_ID, MG_View,
	                     GA_RelVerify, TRUE,
                             GA_Disabled, TRUE,
	                   ButtonEnd,
	                 EndGroup,
                         CHILD_WeightedHeight, 0,

	                 LAYOUT_AddChild, but2=HLayoutObject, EvenSized,

	                   StartMember, MG_List[MG_Connect]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_Connect),
	                     GA_ID, MG_Connect,
	                     GA_RelVerify, TRUE,
	                   ButtonEnd,

	                   StartMember, MG_List[MG_Disconnect]=ButtonObject,
	                     GA_Text, GetAmiFTPString(MW_Disconnect),
	                     GA_ID, MG_Disconnect,
	                     GA_RelVerify, TRUE,
                             GA_Disabled, TRUE,
	                   ButtonEnd,
	                 EndGroup,
                         CHILD_WeightedHeight, 0,
                       EndGroup,
                       CHILD_WeightedHeight, 0,
	             LayoutEnd;
    if (!MainWindowLayout) {
//	Printf("Failed to create layout\n");
	return 0;
    }

    SetAttrs(g1, LAYOUT_AlignLabels, g2, TAG_DONE);
    SetAttrs(g2, LAYOUT_AlignLabels, g1, TAG_DONE);

    MainIDCMPHook.h_Entry=(HOOKFUNC)MainIDCMPHookFunc;
    MainIDCMPHook.h_SubEntry=NULL;
    MainIDCMPHook.h_Data=NULL;

    AppMessageHook.h_Entry=(HOOKFUNC)AppMessageHookFunc;
    AppMessageHook.h_SubEntry=NULL;
    AppMessageHook.h_Data=NULL;

    if (!MainPrefs.mp_ShowButtons) {
	SetAttrs(g3,
		 LAYOUT_RemoveChild, but1,
		 LAYOUT_RemoveChild, but2,
		 TAG_DONE);
	MG_List[MG_Parent]=MG_List[MG_Get]=MG_List[MG_Put]=MG_List[MG_View]=
	  MG_List[MG_Readme]=MG_List[MG_Get2]=MG_List[MG_Put2]=MG_List[MG_View2]=
	    MG_List[MG_Connect]=MG_List[MG_Disconnect]=NULL;
    }
    if (!MainPrefs.mp_ShowToolBar) {
	SetAttrs(MainWindowLayout,
		 LAYOUT_RemoveChild, MG_List[MG_SpeedBar],
		 TAG_DONE);
	FreeSpeedBarList();
    }

    MainWin_Object = WindowObject,
                       WA_Title, wintitle,
                       WA_ScreenTitle, wintitle,
                       WA_PubScreen, Screen,
                       WA_SizeGadget, TRUE,
                       WA_SizeBBottom, TRUE,
                       WA_Top, CurrentState.TopEdge?CurrentState.TopEdge:MainPrefs.mp_TopEdge-Screen->ViewPort.DyOffset,
                       WA_Left, CurrentState.LeftEdge?CurrentState.LeftEdge:MainPrefs.mp_LeftEdge-Screen->ViewPort.DxOffset,
                       WA_InnerHeight, CurrentState.Height?CurrentState.Height:MainPrefs.mp_Height,
                       WA_InnerWidth, CurrentState.Width?CurrentState.Width:MainPrefs.mp_Width,
                       WA_DepthGadget, TRUE,
                       WA_DragBar, TRUE,
                       WA_CloseGadget, TRUE,
                       WA_Activate, TRUE,
                       WA_SmartRefresh, TRUE,
                       WA_MenuHelp, TRUE,
                       WA_IDCMP, IDCMP_MENUHELP,
                       WINDOW_IconifyGadget, TRUE,
                       WINDOW_IconTitle, "AmiFTP",
                       WINDOW_Icon, GetDiskObject("PROGDIR:AMIFTP"),
                       WINDOW_AppPort, AppPort,
                       WINDOW_AppWindow, TRUE,
                       WINDOW_AppMsgHook, &AppMessageHook,
                       WINDOW_ParentGroup, MainWindowLayout,
                       WINDOW_IDCMPHook, &MainIDCMPHook,
                       WINDOW_IDCMPHookBits, IDCMP_RAWKEY,
                     EndWindow;

    if (!MainWin_Object) {
//	Printf("Failed to create WinObject\n");
	DisposeObject(MainWindowLayout);
	return 0;
    }

    UpdateMenus();

    {
	int state=prev_state==-1?MB_DISCONNECTED:prev_state;
	prev_state=-1;

	UpdateMainButtons(state);
    }

    if (StartIconified) {
	MainWindow=NULL;
	CA_Iconify(MainWin_Object);
	return (struct Window *)1;
    }

    if (MainWindow=CA_OpenWindow(MainWin_Object)) {
	UpdateWindowTitle();
	UnlockPubScreen(NULL, Screen);
	return MainWindow;
    }

    UnlockPubScreen(NULL, Screen);

    DisposeObject(MainWin_Object);
    MainWin_Object=NULL;
    MainWindowLayout=NULL;
    CloseFont(ScreenFont);
    ScreenFont=NULL;
    if (ListViewFont)
      CloseFont(ListViewFont);
    if (AmiFTPFont)
      CloseFont(AmiFTPFont);
    FreeInfoList(&dummy_list);
    ListViewFont=NULL;
    AmiFTPFont=NULL;

    return NULL;
}

void CloseMainWindow()
{
    if (MainWin_Object) {
/*	LONG w,h,l,t;

	GetAttrs(MainWin_Object,
		 WA_InnerWidth, &w, WA_InnerHeight, &h,
		 TAG_DONE);*/
	CurrentState.Width=MainWindow->Width-MainWindow->BorderLeft-MainWindow->BorderRight;
	CurrentState.Height=MainWindow->Height-MainWindow->BorderTop-MainWindow->BorderBottom;
	CurrentState.TopEdge=MainWindow->TopEdge;
	CurrentState.LeftEdge=MainWindow->LeftEdge;
/*	kprintf("%ld %ld %ld %ld\n", CurrentState.Width, CurrentState.Height,
		CurrentState.TopEdge, CurrentState.LeftEdge);*/
	DisposeObject(MainWin_Object);
	MainWin_Object=NULL;
	MainWindowLayout=NULL;
	MainWindow=NULL;
    }
    if (ScreenFont) {
	CloseFont(ScreenFont);
	ScreenFont=NULL;
    }
    if (ListViewFont) {
	CloseFont(ListViewFont);
	ListViewFont=NULL;
    }
    if (AmiFTPFont) {
	CloseFont(AmiFTPFont);
	AmiFTPFont=NULL;
    }
    if (VisualInfo) {
	FreeVisualInfo(VisualInfo);
	VisualInfo=NULL;
    }
    FreeSpeedBarList();
    FreeInfoList(&dummy_list);
}


#define DisableGadget(gadget, disable) if (SetGadgetAttrs(gadget, MainWindow, NULL, GA_Disabled, disable, TAG_DONE) && MainWindow) RefreshGList(gadget, MainWindow, NULL, 1);

void UpdateMainButtons(const int state)
{
    UpdateWindowTitle();

    if (state == prev_state)
      return;

    switch (state) {
      case MB_DISCONNECTED:
	if (MainPrefs.mp_ShowButtons) {
	    if (CurrentState.ADTMode) {
		DisableGadget(MG_List[MG_Readme], TRUE)
	      }
	    else {
		DisableGadget(MG_List[MG_Parent], TRUE);
	    }
	    DisableGadget(MG_List[MG_Get], TRUE);
	    DisableGadget(MG_List[MG_Put], TRUE);
	    DisableGadget(MG_List[MG_View], TRUE);
	    DisableGadget(MG_List[MG_Get2], TRUE);
	    DisableGadget(MG_List[MG_Put2], TRUE);
	    DisableGadget(MG_List[MG_View2], TRUE);
	    DisableGadget(MG_List[MG_Disconnect], TRUE);
	}

	DisableGadget(MG_List[MG_DirName], TRUE);
	DisableGadget(MG_List[MG_CacheList], TRUE);
	DisableGadget(MG_List[MG_Reload], TRUE);
	if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			   LISTBROWSER_Labels, &dummy_list,
			   LISTBROWSER_ColumnInfo, &dummycolumninfo,
			   LISTBROWSER_AutoFit, TRUE,
			   TAG_DONE) && MainWindow)
	  RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
	lsel=-1;
	break;
      case MB_NONESELECTED:
	if (CurrentState.ADTMode) {
	    if (MainPrefs.mp_ShowButtons)
	      DisableGadget(MG_List[MG_Readme], TRUE);
	    DisableGadget(MG_List[MG_DirName], TRUE);
	    DisableGadget(MG_List[MG_CacheList], TRUE);
	    DisableGadget(MG_List[MG_Reload], TRUE);
	}
	else {
	    if (MainPrefs.mp_ShowButtons)
	      DisableGadget(MG_List[MG_Parent], FALSE);
	    DisableGadget(MG_List[MG_DirName], FALSE);
	    DisableGadget(MG_List[MG_CacheList], FALSE);
	    DisableGadget(MG_List[MG_Reload], FALSE);
	}
	if (MainPrefs.mp_ShowButtons) {
	    DisableGadget(MG_List[MG_Get], TRUE);
	    DisableGadget(MG_List[MG_Put], FALSE);
	    DisableGadget(MG_List[MG_View], TRUE);
	    DisableGadget(MG_List[MG_Get2], TRUE);
	    DisableGadget(MG_List[MG_Put2], FALSE);
	    DisableGadget(MG_List[MG_View2], TRUE);
	    DisableGadget(MG_List[MG_Disconnect], FALSE);
	}
	lsel=-1;
	break;
	  case MB_FILESELECTED:
	if (CurrentState.ADTMode) {
	    if (MainPrefs.mp_ShowButtons)
	      DisableGadget(MG_List[MG_Readme], FALSE);
	    DisableGadget(MG_List[MG_DirName], TRUE);
	    DisableGadget(MG_List[MG_CacheList], TRUE);
	    DisableGadget(MG_List[MG_Reload], TRUE);
	}
	else {
	    if (MainPrefs.mp_ShowButtons)
	      DisableGadget(MG_List[MG_Parent], FALSE);
	    DisableGadget(MG_List[MG_DirName], FALSE);
	    DisableGadget(MG_List[MG_Reload], FALSE);
	    DisableGadget(MG_List[MG_CacheList], FALSE);
	}

	if (MainPrefs.mp_ShowButtons) {
	    DisableGadget(MG_List[MG_Get], FALSE);
	    DisableGadget(MG_List[MG_Put], FALSE);
	    DisableGadget(MG_List[MG_Disconnect], FALSE);
	    DisableGadget(MG_List[MG_View], FALSE);
	    DisableGadget(MG_List[MG_Get2], FALSE);
	    DisableGadget(MG_List[MG_Put2], FALSE);
	    DisableGadget(MG_List[MG_View2], FALSE);
	}
	break;
      default:
	break;
    }

    if (MainPrefs.mp_ShowToolBar)
      UpdateSpeedBar(state);

    prev_state=state;

    if (MainWindow)
      RefreshGList(MG_List[MG_CacheList], MainWindow, NULL, 1);
}
#undef DisableGadget

void AttachToolList(const BOOL NoneSelected)
{
    if (MainWindow) {
	if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			   LISTBROWSER_Labels, FileList,
			   LISTBROWSER_ColumnInfo, &columninfo,
			   NoneSelected?LISTBROWSER_AutoFit:TAG_IGNORE, TRUE,
			   NoneSelected?LISTBROWSER_Selected:TAG_IGNORE, -1,
			   NoneSelected?LISTBROWSER_MakeVisible:TAG_IGNORE, 0,
			   TAG_DONE))
	  RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
    }
    else
      SetAttrs(MG_List[MG_ListView],
	       LISTBROWSER_Labels, FileList,
	       LISTBROWSER_ColumnInfo, &columninfo,
	       NoneSelected?LISTBROWSER_AutoFit:TAG_IGNORE, TRUE,
	       NoneSelected?LISTBROWSER_Selected:TAG_IGNORE, -1,
	       NoneSelected?LISTBROWSER_MakeVisible:TAG_IGNORE, 0,
	       TAG_DONE);
    if (NoneSelected) lsel=-1;
}

void DetachToolList(void)
{
    if (MainWindow)
      if (SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			 LISTBROWSER_Labels, ~0,
			 LISTBROWSER_AutoFit, TRUE,
			 TAG_DONE))
	RefreshGList(MG_List[MG_ListView], MainWindow, NULL, 1);
    else
      SetAttrs(MG_List[MG_ListView], LISTBROWSER_Labels, ~0, TAG_DONE);
}

void UpdateRemoteDir(const char *dir)
{
    if (dir) 
      if (dir!=&CurrentState.CurrentRemoteDir[0])
	strncpy(CurrentState.CurrentRemoteDir, dir, 255);
    if (MainWindow) {
	if (SetGadgetAttrs(MG_List[MG_DirName], MainWindow, NULL,
			   STRINGA_TextVal, dir,
			   TAG_END))
	  RefreshGList(MG_List[MG_DirName], MainWindow, NULL, 1);
    }
    UpdateWindowTitle();
}

void UpdateLocalDir(const char *dir)
{
    if (dir!=&CurrentState.CurrentDLDir[0])
      strncpy(CurrentState.CurrentDLDir, dir, 255);
    if (MainWindow) {
	if (SetGadgetAttrs(MG_List[MG_DLString], MainWindow, NULL,
			   STRINGA_TextVal, dir,
			   TAG_END))
	    RefreshGList(MG_List[MG_DLString], MainWindow, NULL, 1);
    }
    UpdateWindowTitle();
}

void UpdateSiteName(const char *site)
{
    if (site!=CurrentState.CurrentSite)
      strncpy(CurrentState.CurrentSite, site, 50);
    if (MainWindow) {
	if (SetGadgetAttrs(MG_List[MG_SiteName], MainWindow, NULL,
			   STRINGA_TextVal, site,
			   TAG_END))
	    RefreshGList(MG_List[MG_SiteName], MainWindow, NULL, 1);
    }
}

void LockWindow(Object *window_object)
{
    if (window_object==MainWin_Object)
      ClearMenuStrip(MainWindow);
    SetAttrs(window_object,
	     WA_BusyPointer, TRUE,
	     TAG_DONE);
}

void UnlockWindow(Object *window_object)
{
    SetAttrs(window_object,
	     WA_BusyPointer, FALSE,
	     TAG_DONE);

    if (window_object==MainWin_Object) {
	struct Menu *mmenu=menu->NextMenu; /* The files menu */
	struct MenuItem *menuitem;

	menuitem=mmenu->FirstItem;
	menuitem=mmenu->FirstItem;
	menuitem=mmenu->FirstItem;
	menuitem=mmenu->FirstItem;
	
	menuitem->Flags|=TransferMode==BINARY?CHECKED:NULL;
	menuitem=menuitem->NextItem;
	menuitem->Flags|=TransferMode==ASCII?CHECKED:NULL;

	mmenu=mmenu->NextMenu; /* The sort menu */
	menuitem=mmenu->FirstItem;
	menuitem->Flags|=SortMode==SORTBYNAME?CHECKED:NULL;
	menuitem=menuitem->NextItem;
	menuitem->Flags|=SortMode==SORTBYDATE?CHECKED:NULL;

	mmenu=mmenu->NextMenu; /* The settings menu */
	menuitem=mmenu->FirstItem;
	menuitem=menuitem->NextItem;
	menuitem=menuitem->NextItem;

	menuitem=menuitem->NextItem;
	menuitem->Flags|=LogWindow?CHECKED:NULL;

	menuitem=menuitem->NextItem;
	menuitem->Flags|=MainPrefs.mp_Showdotfiles?CHECKED:NULL;

	menuitem=menuitem->NextItem;
	menuitem->Flags|=MainPrefs.mp_ShowAllADTFiles?CHECKED:NULL;
	if (MainWindow)
	  ResetMenuStrip(MainWindow, menu);
	else
	  SetAttrs(window_object,
		   WINDOW_MenuStrip, menu,
		   TAG_DONE);
    }

    return;
}

void ChangeAmiFTPMode(void)
{
    if (CurrentState.ADTMode) {
	SetGadgetAttrs(MG_List[MG_Page2], MainWindow, NULL,
		       PAGE_Current, 1, TAG_DONE);
	RethinkLayout(pagelayout, MainWindow, NULL, TRUE);
    }
    else {
	SetGadgetAttrs(MG_List[MG_Page2], MainWindow, NULL,
		       PAGE_Current, 0, TAG_DONE);
	RethinkLayout(pagelayout, MainWindow, NULL, TRUE);
    }
    RefreshGList(pagelayout, MainWindow, NULL, 1);
}

void UpdateWindowTitle()
{
    static char title[100];
    int numselfiles=0, numselbytes=0;
    char *bytes="kB";
    int freebytes=0;
    char *fbytes="kB";
    struct InfoData info;
    BPTR lock;

    if (lock=Lock(CurrentState.CurrentDLDir, ACCESS_READ)) {
	char pathname[256];
	int i;

	NameFromLock(lock, pathname, 256);
	UnLock(lock);
	i=0;
	while (pathname[i]!=':' && pathname[i]) {
	    i++;
	}
	i++;
	pathname[i]='\0';

	if (!getdfs(pathname, &info)) {
	    freebytes=(info.id_NumBlocks-info.id_NumBlocksUsed)*info.id_BytesPerBlock;
	    if (freebytes < 1000000) {
		freebytes/=1024;
		fbytes="kB";
	    }
	    else {
		freebytes/=(1024*1024);
		fbytes="MB";
	    }
	}
    }

    if (FileList) {
	struct Node *node;

	for (node=FirstNode(FileList); node; node=NextNode(node)) {
	    ULONG sel;
	    struct dirlist *ptr;

	    GetListBrowserNodeAttrs(node, LBNA_Selected, &sel, TAG_DONE);
	    if (sel && (ptr=(void *)node->ln_Name)) {
		numselfiles++;
		numselbytes+=ptr->size==-1?0:ptr->size;
	    }
	}
	if (numselbytes < 1000000) {
	    numselbytes/=1024;
	    bytes="kB";
	}
	else {
	    numselbytes/=(1024*1024);
	    bytes="MB";
	}
    }
    sprintf(title, GetAmiFTPString(Str_WindowTitle),
	    numselfiles, numselbytes, bytes, freebytes, fbytes);
    SetAttrs(MainWin_Object,
	     WA_Title, title,
	     TAG_DONE);
}

static void ScrollListbrowser(ULONG direction)
{
    if (FileList) {
	if (!EmptyList(FileList)) {
	    SetGadgetAttrs(MG_List[MG_ListView], MainWindow, NULL,
			   LISTBROWSER_Position, direction,
			   TAG_DONE);
	}
    }
}

static struct Image *listimage;
static UWORD listmapping[4];

void CreateInfoList(struct List *list)
{
    struct Node *node;
    extern struct Image im;
    extern char *linfotext;
    int i;
    char *infostrings[4]={NULL, "Copyright © 1995-1998 by Magnus Lilja", "<lilja@lysator.liu.se>","All Rights Reserved"};

    infostrings[0]=linfotext;

    NewList(list);

    listmapping[0]=DrawInfo->dri_Pens[BACKGROUNDPEN];
    listmapping[1]=DrawInfo->dri_Pens[SHADOWPEN];
    listmapping[2]=DrawInfo->dri_Pens[SHINEPEN];
    listmapping[3]=DrawInfo->dri_Pens[FILLPEN];

    if (listimage=(struct Image *)NewObject(LABEL_GetClass(), NULL,
					   LABEL_Mapping, listmapping,
					   LABEL_Image, &im,
					   TAG_END))
      if (node=AllocListBrowserNode(1,
				    LBNA_Flags, LBFLG_READONLY,
				    LBNA_Column, 0,
				    LBNCA_Image, (ULONG)listimage,
				    LBNCA_Justification, LCJ_CENTRE,
				    TAG_END))
	AddTail(list, node);
    
    for (i=0; i<4; i++)
      if (node=AllocListBrowserNode(1,
				    LBNA_Flags, LBFLG_READONLY,
				    LBNA_Column, 0,
				    LBNCA_Text, infostrings[i],
				    LBNCA_Justification, LCJ_CENTRE,
				    TAG_DONE))
	AddTail(list, node);
}

void FreeInfoList(struct List *list)
{
    FreeListBrowserList(list);
    if (listimage)
      DisposeObject(listimage);
}

/* EOF */
