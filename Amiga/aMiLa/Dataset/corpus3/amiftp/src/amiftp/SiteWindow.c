/* RCS Id: $Id: SiteWindow.c 1.692 1996/07/20 00:28:38 lilja Exp $
   Locked version: $Revision: 1.692 $
*/

#include "AmiFTP.h"
#include "gui.h"
#include <intuition/sghooks.h>

extern void PrintSiteList(void);
BOOL AddToSiteList=FALSE;
BOOL HotListChanged=FALSE;

struct Window *EditSiteWindow;
Object *EditSiteLayout;
Object *EditSiteWin_Object;

struct Window *OpenEditSiteWindow(struct SiteNode *sn);
void CloseEditSiteWindow(struct SiteNode *sn);
int LocPath_clicked(void);
int SL_Up(void);
int SL_Down(void);
int SL_Top(void);
int SL_Bottom(void);
int NewGroup(void);

enum {
    ESG_SiteName=0, ESG_SiteAddress, ESG_Port, ESG_RemDir, ESG_LocString, ESG_LocGad,
    ESG_Anonymous, ESG_LoginName, ESG_Password, ESG_LSType, ESG_HotList,
    ESG_Proxy, ESG_OK, ESG_Cancel, ESG_ADT,
    NumGadgets_ESG};

struct Gadget *ESG_List[NumGadgets_ESG];

static STRPTR lsnames[]=
{
    "UNIX",
    "VMS",
    "DOS",
    NULL
};

struct List *objlist;
struct Hook EditHook;

char RealString[100];
char Original[100];

struct SiteNode *Curr_sn;

/* SiteList window */

struct Window *SiteListWindow;
Object *SiteListLayout;
Object *SiteListWin_Object;

enum {
    SLG_SiteList=0, SLG_Connect, SLG_New, SLG_Edit, SLG_Remove, 
    SLG_Cancel, SLG_Up, SLG_Down, SLG_Top, SLG_Bottom,SLG_AddGroup, SLG_BarLabel,
    NumGadgets_SLG};

struct Gadget *SLG_List[NumGadgets_SLG];

struct Window *OpenSiteWindow(const BOOL Connect);
void CloseSiteListWindow(void);
void UpdateSLGGadgets(const ULONG selected, const int type);

int EditClicked(void);
int RemoveClicked(void);
int NewClicked(void);

static ULONG lsecs,lmics;

ULONG __asm __saveds
PasswordHook(register __a0 struct Hook *Hook, register __a2 struct SGWork *Work,
	     register __a1 ULONG *Msg)
{
//    ObjectNode *Node;

/*    if(GETOBJECT(Work -> Gadget,Node)) { */
	STRPTR	Buffer		= RealString; //Node -> Special . String . RealString;
	STRPTR	original	= Original; //Node -> Special . String . Original;
	WORD	Len;

	if(Work -> IEvent -> ie_Code == 0x5F) {
	    /*	    LayoutHandle *Handle = Hook -> h_Data;
		    
		    if(Handle -> HelpHook)
		    {
		    Work -> Code	= 0x5F;
		    Work -> Actions	= (Work -> Actions & ~SGA_BEEP) | SGA_END | SGA_USE;
		    
		    return TRUE;
		    }*/
	}

	switch(*Msg) {
	  case SGH_KEY:

	    switch(Work -> EditOp) {
	      case EO_INSERTCHAR:

		Buffer[Work -> BufferPos - 1]	= Work -> Code;
		Buffer[Work -> NumChars]	= 0;

		Work -> Code = (WORD)'·';

		Work -> WorkBuffer[Work -> BufferPos - 1] = (UBYTE)'·';

		break;

	      case EO_RESET:

		Len = strlen(original);

		strcpy(Buffer,original);

		memset(Work -> WorkBuffer,'·',Len);

		Work -> WorkBuffer[Len] = 0;

		Work -> NumChars	= Len;
		Work -> BufferPos	= Len;
		Work -> EditOp		= EO_BIGCHANGE;

		break;

	      case EO_CLEAR:

		Work -> WorkBuffer[0]	= 0;
		Work -> NumChars	= 0;
		Work -> BufferPos	= 0;
		Work -> EditOp		= EO_BIGCHANGE;

		Buffer[0] = 0;

		break;

	      case EO_DELBACKWARD:

		Buffer[Work -> NumChars] = 0;
		break;

	      case EO_NOOP:

		break;

	      case EO_ENTER:

		strcpy(original,Buffer);

		if(!(Work -> IEvent -> ie_Qualifier & (IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT)))
		{
//		    if(!Node -> Special . String . LastGadget && Node -> Special . String . LayoutHandle -> AutoActivate)
//		      Work -> Actions |= SGA_NEXTACTIVE;

		    if(!(Work -> Actions & SGA_NEXTACTIVE))
		      Work -> Code = '\r';
		}

		break;

	      case EO_MOVECURSOR:
	      case EO_DELFORWARD:

		Work -> Actions &= ~SGA_USE;
		break;

	      default:

		Work -> Actions &= ~SGA_USE;
		Work -> Actions |=  SGA_BEEP;
		break;
	    }

	    break;

	  case SGH_CLICK:

	    Work -> BufferPos	= Work -> NumChars;
	    Work -> EditOp		= EO_BIGCHANGE;

	    break;
	}

	return TRUE;
/*    }
    else
      return(FALSE);*/
}

static char buf1[100],buf2[100],buf3[100],buf4[100],buf5[100],buf6[100];

int OpenEditWindow(struct SiteNode *sn)
{
    ULONG wait, esignal,ssignal, mainsignal,done=FALSE;
    if (!OpenEditSiteWindow(sn))
      return 0;

    GetAttr(WINDOW_SigMask, EditSiteWin_Object, &esignal);
    GetAttr(WINDOW_SigMask, SiteListWin_Object, &ssignal);
    GetAttr(WINDOW_SigMask, MainWin_Object, &mainsignal);

    while (!done) {
	wait=Wait(esignal|ssignal|mainsignal|AG_Signal|SIGBREAKF_CTRL_C);
	if (wait & SIGBREAKF_CTRL_C)
	  done=TRUE;
	if (wait & AG_Signal)
	  HandleAmigaGuide();
	if (wait & esignal)
	  done=HandleEditSiteIDCMP();
	if (wait & ssignal)
	  HandleSiteListIDCMP();
	if (wait & mainsignal)
	  HandleMainWindowIDCMP(FALSE);
    }
    CloseEditSiteWindow(sn);

    return 1;
}

ULONG HandleEditSiteIDCMP(void)
{
    ULONG result, done=FALSE;
    UWORD code=NULL;

    while ((result=CA_HandleInput(EditSiteWin_Object, &code))!=WMHI_LASTMSG) {
	switch (result & WMHI_CLASSMASK) {
	  case WMHI_CLOSEWINDOW:
	    done=TRUE;
	    break;
	  case WMHI_RAWKEY:
	    if (code==69)
	      done=TRUE;
	    else if (code==95)
	      SendAGMessage(AG_SITECONF);
	    break;
	  case WMHI_GADGETUP:
	    switch (result & WMHI_GADGETMASK) {
	      case ESG_Anonymous:
		{
		    ULONG attr;

		    GetAttr(GA_Selected,ESG_List[ESG_Anonymous], &attr);
		    if (SetGadgetAttrs(ESG_List[ESG_LoginName], EditSiteWindow, NULL,
				       GA_Disabled, attr,
				       TAG_DONE))
		      RefreshGList(ESG_List[ESG_LoginName], EditSiteWindow, NULL, 1);
		    if (SetGadgetAttrs(ESG_List[ESG_Password], EditSiteWindow, NULL,
				       GA_Disabled, attr,
				       TAG_DONE))
		      RefreshGList(ESG_List[ESG_Password], EditSiteWindow, NULL, 1);
		}
		break;
	      case ESG_LocGad:
		LocPath_clicked();
		break;
	      case ESG_OK:
		AddToSiteList=TRUE;
		done=TRUE;
		break;
	      case ESG_Cancel:
		done=TRUE;
		break;
	    }
	    break;
	}
    }
    return done;
}

struct Window *OpenEditSiteWindow(struct SiteNode *sn)
{
    struct LayoutLimits limits;
    Object *l1,*l2, *l3, *l4, *l5, *l6;

    if (EditSiteWindow)
      return EditSiteWindow;

    objlist=ChooserLabelsA(lsnames);
    if (!objlist)
      return NULL;

    AddToSiteList=FALSE;
    if (sn->sn_Node.ln_Name)
      strcpy(buf1, sn->sn_Node.ln_Name);
    else
      buf1[0]=0;
    if (sn->sn_SiteAddress)
      strcpy(buf2, sn->sn_SiteAddress);
    else
      buf2[0]=0;
    if (sn->sn_RemoteDir)
      strcpy(buf3, sn->sn_RemoteDir);
    else
      buf3[0]=0;
    if (sn->sn_LocalDir)
      strcpy(buf4, sn->sn_LocalDir);
    else if (MainPrefs.mp_LocalDir)
      strcpy(buf4, MainPrefs.mp_LocalDir);
    else
      buf4[0]=0;
    if (sn->sn_LoginName)
      strcpy(buf5, sn->sn_LoginName);
    else
      buf5[0]=0;
    memset(Original, 0, sizeof(Original));
    memset(RealString, 0, sizeof(RealString));
    if (sn->sn_Password) {
	memset(Original, '·', strlen(sn->sn_Password));
	strcpy(buf6, Original);
	strcpy(Original, sn->sn_Password);
	strcpy(RealString, sn->sn_Password);
    }
    memset(&EditHook, 0, sizeof(EditHook));
    EditHook.h_Entry=(HOOKFUNC)PasswordHook;

    EditSiteLayout=LayoutObject,
                     GA_DrawInfo, DrawInfo,
                     GA_TextAttr, AmiFTPAttrF,
                     LAYOUT_DeferLayout, TRUE,
                     LAYOUT_SpaceOuter, FALSE,
                     LAYOUT_Orientation, LAYOUT_ORIENT_VERT,

                     LAYOUT_AddChild, l3=VLayoutObject, LAYOUT_SpaceOuter, TRUE,

                     StartMember, ESG_List[ESG_SiteName]=StringObject,
                       GA_ID, ESG_SiteName,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, buf1,
                       STRINGA_MaxChars, 50,
                       StringEnd,
                       Label(GetAmiFTPString(SCW_Name)),

                     StartMember, ESG_List[ESG_SiteAddress]=StringObject,
                       GA_ID, ESG_SiteAddress,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, buf2,
                       STRINGA_MaxChars, 100,
                       StringEnd,
                       Label(GetAmiFTPString(SCW_Site)),

                     StartMember, ESG_List[ESG_Port]=IntegerObject,
                       GA_ID, ESG_Port,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       INTEGER_Number, sn->sn_Port,
                       INTEGER_Arrows, FALSE,
                       INTEGER_MaxChars, 6,
                       IntegerEnd,
                       CHILD_NominalSize, TRUE,
                       CHILD_WeightedWidth, 0,
                       Label(GetAmiFTPString(SCW_Port)),

                     StartMember, ESG_List[ESG_RemDir]=StringObject,
                       GA_ID, ESG_RemDir,
                       GA_RelVerify, TRUE,
                       GA_TabCycle, TRUE,
                       STRINGA_Buffer, buf3,
                       STRINGA_MaxChars, 100,
                       StringEnd,
                       Label(GetAmiFTPString(SCW_RemDir)),

                     LAYOUT_AddChild, l1=HLayoutObject, Spacing(FALSE),

                       StartMember, ESG_List[ESG_LocString]=StringObject,
                         GA_ID, ESG_LocString,
                         GA_RelVerify, TRUE,
                         GA_TabCycle, TRUE,
                         STRINGA_Buffer, buf4,
                         STRINGA_MaxChars, 50,
                         StringEnd,

                       StartMember, ESG_List[ESG_LocGad]=ButtonObject,
                         BUTTON_AutoButton, BAG_POPDRAWER,
                         GA_ID, ESG_LocGad,
                         GA_RelVerify, TRUE,
                         ButtonEnd,
                         CHILD_WeightedWidth, 0,
                         CHILD_WeightedHeight, 0,
                       EndGroup,
                       Label(GetAmiFTPString(SCW_LocDir)),

                     StartMember, ESG_List[ESG_Anonymous]=CheckBoxObject,
                       GA_ID, ESG_Anonymous,
                       GA_RelVerify, TRUE,
                       GA_Text, GetAmiFTPString(SCW_Anonymous),
                       GA_Selected, sn->sn_Anonymous,
                       CHECKBOX_TextPlace, PLACETEXT_LEFT,
                       CheckBoxEnd,

                     LAYOUT_AddChild,l2=HLayoutObject,

                       StartMember, ESG_List[ESG_LoginName]=StringObject,
                         GA_ID, ESG_LoginName,
                         GA_RelVerify, TRUE,
                         GA_Disabled, sn->sn_Anonymous,
                         GA_TabCycle, TRUE,
                         STRINGA_Buffer, buf5,
                         STRINGA_MaxChars, 20,
                         StringEnd,
                         Label(GetAmiFTPString(SCW_LoginName)),

                       StartMember, ESG_List[ESG_Password]=StringObject,
                         GA_ID, ESG_Password,
                         GA_RelVerify, TRUE,
                         GA_Disabled, sn->sn_Anonymous,
                         GA_TabCycle, TRUE,
                         STRINGA_Buffer, buf6,
                         STRINGA_MaxChars, 20,
                         STRINGA_EditHook, (ULONG)&EditHook,
                         StringEnd,
                         Label(GetAmiFTPString(SCW_Password)),
                       EndGroup, EndGroup,

                       LAYOUT_AddChild, l4=VLayoutObject, LAYOUT_SpaceOuter, TRUE, LAYOUT_HorizAlignment, LALIGN_RIGHT,
                       StartMember, ESG_List[ESG_LSType]=ChooserObject,
                         CHOOSER_Labels, objlist,
                         CHOOSER_AutoFit, TRUE,
                         CHOOSER_PopUp, TRUE,
                         CHOOSER_Active, sn->sn_VMSDIR,
                         GA_ID, ESG_LSType,
                         GA_RelVerify, TRUE,
                         ChooserEnd,
                         CHILD_WeightedWidth, 0,
                         Label(GetAmiFTPString(SCW_OS)),

                       LAYOUT_AddChild, l5=HLayoutObject, Spacing(FALSE),
                       StartMember, ESG_List[ESG_Proxy]=CheckBoxObject,
                         GA_ID, ESG_Proxy,
                         GA_RelVerify, TRUE,
                         GA_Text, GetAmiFTPString(SCW_Proxy),
                         GA_Selected, sn->sn_Proxy,
                         CHECKBOX_TextPlace, PLACETEXT_LEFT,
                         CheckBoxEnd,
                       LAYOUT_AddChild, l6=VLayoutObject, 
                       StartMember, ESG_List[ESG_HotList]=CheckBoxObject,
                         GA_ID, ESG_HotList,
                         GA_RelVerify, TRUE,
                         GA_Text, GetAmiFTPString(SCW_HotList),
                         GA_Selected, sn->sn_HotList,
                         CHECKBOX_TextPlace, PLACETEXT_LEFT,
                         CheckBoxEnd,
                       StartMember, ESG_List[ESG_ADT]=CheckBoxObject,
                         GA_ID, ESG_ADT,
                         GA_RelVerify, TRUE,
                         GA_Text, GetAmiFTPString(SCW_AminetMode),
                         GA_Selected, sn->sn_ADT,
                         CHECKBOX_TextPlace, PLACETEXT_LEFT,
                         CheckBoxEnd,
                      EndGroup,EndGroup,CHILD_WeightedWidth, 0,
                      EndGroup,

                       LAYOUT_AddImage, BevelObject,
                         BEVEL_Style, BVS_SBAR_VERT,
                       BevelEnd,

                     StartHGroup,EvenSized, LAYOUT_SpaceOuter, TRUE,

                       StartMember, ESG_List[ESG_OK]=ButtonObject,
                         GA_Text, GetAmiFTPString(SCW_OK),
                         GA_ID, ESG_OK,
                         GA_RelVerify, TRUE,
                         ButtonEnd,
                         CHILD_NominalSize, TRUE,
                         CHILD_WeightedWidth, 0,

                       StartMember, ESG_List[ESG_Cancel]=ButtonObject,
                         GA_Text, GetAmiFTPString(SCW_Cancel),
                         GA_ID, ESG_Cancel,
                         GA_RelVerify, TRUE,
                         ButtonEnd,
                         CHILD_NominalSize, TRUE,
                         CHILD_WeightedWidth, 0,
                       EndGroup,
                       CHILD_WeightMinimum, TRUE,
                   LayoutEnd;

    if (!EditSiteLayout)
      return NULL;

    if (sn->sn_MenuType==SLN_PARENT) {
	SetAttrs(l4,
		 LAYOUT_RemoveChild, ESG_List[ESG_LSType],
		 TAG_DONE);
	SetAttrs(l5,
		 LAYOUT_RemoveChild, ESG_List[ESG_Proxy],
		 TAG_DONE);
	SetAttrs(l6,
		 LAYOUT_RemoveChild, ESG_List[ESG_ADT],
		 TAG_DONE);

	SetAttrs(l3,
		 LAYOUT_RemoveChild, ESG_List[ESG_SiteAddress],
		 LAYOUT_RemoveChild, ESG_List[ESG_Port],
		 LAYOUT_RemoveChild, ESG_List[ESG_RemDir],
		 LAYOUT_RemoveChild, l1,
		 LAYOUT_RemoveChild, l2,
		 LAYOUT_RemoveChild, ESG_List[ESG_Anonymous],
		 TAG_DONE);
    }

    LayoutLimits((struct Gadget *)EditSiteLayout, &limits, PropFont, Screen);
    limits.MinHeight+=Screen->WBorTop+Screen->WBorBottom;
    limits.MinWidth+=Screen->WBorLeft+Screen->WBorRight;

    EditSiteWin_Object = WindowObject,
                          WA_Title, GetAmiFTPString(SCW_SiteConfigurationWindow),
                          WA_PubScreen, Screen,
                          WA_DepthGadget, TRUE,
                          WA_DragBar, TRUE,
                          WA_CloseGadget, TRUE,
                          WA_Activate, TRUE,
                          WA_SmartRefresh, TRUE,
                          WA_Top, MainWindow->TopEdge+(MainWindow->Height-limits.MinHeight)/2,
                          WA_Left, MainWindow->LeftEdge+(MainWindow->Width-limits.MinWidth)/2,
                          WA_IDCMP, IDCMP_RAWKEY,
                          WINDOW_ParentGroup, EditSiteLayout,
                          WINDOW_InterpretUserData, WGUD_FUNC,
                        EndWindow;

    if (!EditSiteWin_Object)
      return NULL;

    if (EditSiteWindow=CA_OpenWindow(EditSiteWin_Object)) {
	return EditSiteWindow;
    }
    DisposeObject(EditSiteLayout);
    EditSiteLayout=NULL;

    return NULL;
}

void CloseEditSiteWindow(struct SiteNode *sn)
{
    ULONG attr;

    if (EditSiteWin_Object) {
	if (AddToSiteList) {
	    if (sn->sn_Node.ln_Name) {
		free(sn->sn_Node.ln_Name);
		sn->sn_Node.ln_Name=NULL;
	    }
	    if (strlen(buf1))
	      sn->sn_Node.ln_Name=strdup(buf1);

	    if (sn->sn_MenuType!=SLN_PARENT) {
		if (sn->sn_SiteAddress) {
		    free(sn->sn_SiteAddress);
		    sn->sn_SiteAddress=NULL;
		}
		if (strlen(buf2))
		  sn->sn_SiteAddress=strdup(buf2);

		if (sn->sn_RemoteDir) {
		    free(sn->sn_RemoteDir);
		    sn->sn_RemoteDir=NULL;
		}
		if (strlen(buf3))
		  sn->sn_RemoteDir=strdup(buf3);

		if (sn->sn_LocalDir) {
		    free(sn->sn_LocalDir);
		    sn->sn_LocalDir=NULL;
		}
		if (strlen(buf4))
		  sn->sn_LocalDir=strdup(buf4);

		if (sn->sn_LoginName) {
		    free(sn->sn_LoginName);
		    sn->sn_LoginName=NULL;
		}
		if (strlen(buf5))
		  sn->sn_LoginName=strdup(buf5);

		if (sn->sn_Password) {
		    free(sn->sn_Password);
		    sn->sn_Password=NULL;
		}
		if (strlen(Original))
		  sn->sn_Password=strdup(RealString);

		GetAttr(GA_Selected, ESG_List[ESG_Anonymous], &attr);
		sn->sn_Anonymous=attr;

		GetAttr(INTEGER_Number, ESG_List[ESG_Port], &attr);
		sn->sn_Port=attr;

		GetAttr(GA_Selected, ESG_List[ESG_Proxy], &attr);
		sn->sn_Proxy=attr;

		GetAttr(GA_Selected, ESG_List[ESG_ADT], &attr);
		sn->sn_ADT=attr;

		GetAttr(CHOOSER_Active, ESG_List[ESG_LSType], &attr);
		sn->sn_VMSDIR=attr;
	    }
	    GetAttr(GA_Selected, ESG_List[ESG_HotList], &attr);
	    if (sn->sn_HotList!=attr)
	      HotListChanged=TRUE;
	    sn->sn_HotList=attr;
	}
	DisposeObject(EditSiteWin_Object);
	EditSiteWindow=NULL;
	EditSiteWin_Object=NULL;
	EditSiteLayout=NULL;
    }
    FreeChooserLabels(objlist);
    objlist=NULL;
}

int LocPath_clicked(void)
{
    struct FileRequester *DirRequester;
    static ULONG tags[]={
	ASL_Window, NULL,
	ASLFR_PrivateIDCMP, TRUE,
	ASLFR_SleepWindow, TRUE,
	ASLFR_InitialDrawer, NULL,
	ASLFR_DrawersOnly, TRUE,
	ASLFR_RejectIcons, TRUE,
	ASLFR_TitleText, NULL,
	ASLFR_InitialLeftEdge, NULL,
	ASLFR_InitialTopEdge, NULL,
	TAG_END
    };
    tags[1]=(unsigned long)EditSiteWindow;
    tags[7]=(unsigned long)buf4;
    tags[13]=(unsigned long)GetAmiFTPString(Str_SelectDLPath);
    tags[15]=MainWindow->LeftEdge;
    tags[17]=MainWindow->TopEdge;

    DirRequester=AllocAslRequest(ASL_FileRequest, NULL);
    if (!DirRequester)
      return 1;
    if (AslRequest(DirRequester,(struct TagItem *)tags)) {
	if (SetGadgetAttrs(ESG_List[ESG_LocString], EditSiteWindow, NULL,
				    STRINGA_TextVal, DirRequester->rf_Dir,
				    TAG_END))
	    RefreshGList(ESG_List[ESG_LocString], EditSiteWindow, NULL, 1);
    }
    FreeAslRequest(DirRequester);

    return 1;
}

static struct SiteNode *retnode;
static BOOL ConnectMode;
static ULONG lsel;
static WORD width=0,height=0;
static struct SiteNode *lastnode;

struct SiteNode *OpenSiteListWindow(const BOOL Connect)
{
    ULONG signal,wait,mainsignal,done=FALSE;

    retnode=NULL;
    ConnectMode=Connect;

    if (!OpenSiteWindow(Connect))
      return NULL;

    HotListChanged=FALSE;

    GetAttr(WINDOW_SigMask, SiteListWin_Object, &signal);
    GetAttr(WINDOW_SigMask, MainWin_Object, &mainsignal);
    lsel=-1;
    while (done==0) {
	wait=Wait(signal|AG_Signal|SIGBREAKF_CTRL_C);
	if (SIGBREAKF_CTRL_C)
	  done=TRUE;
	if (wait & AG_Signal)
	  HandleAmigaGuide();
	if (wait & signal)
	  done=HandleSiteListIDCMP();
	if (wait & mainsignal)
	  HandleMainWindowIDCMP(FALSE);
    }
    CloseSiteListWindow();
    if (HotListChanged)
      UpdateMenus();

    return retnode;
}

static int SortSiteNodes(const void *a,const void *b)
{
    const struct Node *nodea=(struct Node *)*(ULONG *)a;
    const struct Node *nodeb=(struct Node *)*(ULONG *)b;

    return stricmp((char *)nodea->ln_Name, (char *)nodeb->ln_Name);
}

ULONG HandleSiteListIDCMP(void)
{
    ULONG result, done=FALSE;
    UWORD code=NULL;

    while((result=CA_HandleInput(SiteListWin_Object, &code))!=WMHI_LASTMSG) {
	switch (result & WMHI_CLASSMASK) {
	  case WMHI_CLOSEWINDOW:
	    done=TRUE;
	    break;
	  case WMHI_RAWKEY:
	    if (code==69)
		done=TRUE;
	    else if (code==RAWKEY_CURSORUP) {
		if (FirstNode(&SiteList)) {
		    LONG attr;
		    struct Node *selnode;
		    struct SiteNode *sn;

		    GetAttrs(SLG_List[SLG_SiteList],
			     LISTBROWSER_Selected, &attr,
			     LISTBROWSER_SelectedNode, &selnode,
			     TAG_DONE);
		    if (attr>0) { /* Kolla på attr==-1, annars blir det en hit */
			struct SiteNode *sn;
			struct Node *node;
			ULONG i;

			if (node=GetPred(selnode)) {
			    ULONG flags;
			    GetListBrowserNodeAttrs(node, LBNA_Flags, &flags, TAG_DONE);
			    while (flags&LBFLG_HIDDEN) {
				node=GetPred(node);
				if (node)
				  GetListBrowserNodeAttrs(node, LBNA_Flags, &flags,
							  TAG_DONE);
				else
				  flags=NULL;
			    }
			    if (node)
			      selnode=node;
			}
			else selnode=GetHead(&SiteList);

			for (i=0,node=GetHead(&SiteList);node;node=GetSucc(node),i++)
			  if (selnode==node) break;

			SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				       LISTBROWSER_Selected, i,
				       LISTBROWSER_MakeVisible, i,
				       TAG_DONE);

			GetListBrowserNodeAttrs(selnode, LBNA_UserData, &sn,
						TAG_DONE);

			UpdateSLGGadgets(TRUE, sn->sn_MenuType);
		    }
		    else if (attr == -1) {
			struct SiteNode *sn;
			struct Node *selnode;

			selnode=FirstNode(&SiteList);
			GetListBrowserNodeAttrs(selnode, LBNA_UserData, &sn,
						TAG_DONE);
			SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				       LISTBROWSER_Selected, 0,
				       LISTBROWSER_MakeVisible, 0,
				       TAG_DONE);
			UpdateSLGGadgets(TRUE, sn->sn_MenuType);
		    }
		}
	    }
	    else if (code==RAWKEY_CURSORDOWN) {
		if (FirstNode(&SiteList)) {
		    ULONG attr;
		    struct Node *selnode;
		    struct SiteNode *sn;
		    ULONG i;
		    struct Node *node;

		    GetAttrs(SLG_List[SLG_SiteList],
			     LISTBROWSER_Selected, &attr,
			     LISTBROWSER_SelectedNode, &selnode,
			     TAG_DONE);
		    if (selnode) {
			if (node=GetSucc(selnode)) {
			    ULONG flags;
			    GetListBrowserNodeAttrs(node,
						    LBNA_Flags, &flags,
						    TAG_DONE);
			    while (flags&LBFLG_HIDDEN) {
				node=GetSucc(node);
				if (node)
				  GetListBrowserNodeAttrs(node,
							  LBNA_Flags, &flags,
							  TAG_DONE);
				else
				  flags=NULL;
			    }
			    if (node)
			      selnode=node;
			}
		    }
		    else selnode=GetHead(&SiteList);
		    for (i=0,node=GetHead(&SiteList);node;node=GetSucc(node),i++)
		      if (selnode==node) break;
		    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				   LISTBROWSER_Selected, i,
				   LISTBROWSER_MakeVisible, i,
				   TAG_DONE);
		    GetListBrowserNodeAttrs(selnode,
					    LBNA_UserData, &sn,
					    TAG_DONE);
		    UpdateSLGGadgets(TRUE, sn->sn_MenuType);
		}
	    }
	    else if (code==95)
		SendAGMessage(AG_SITECONF);
	    else if (code==68) {
		struct Node *node;
		
		GetAttrs(SLG_List[SLG_SiteList], LISTBROWSER_SelectedNode, &node,
			 TAG_DONE);
		if (node) {
		    GetListBrowserNodeAttrs(node, LBNA_UserData, &retnode,
					    TAG_DONE);
		    if (!retnode->sn_BarLabel && retnode->sn_MenuType!=SLN_PARENT)
		      done=TRUE;
		    else {
			done=FALSE;
			retnode=NULL;
		    }
		}
		else retnode=FALSE;
	    }
	    break;
	  case WMHI_GADGETUP:
	    switch (result & WMHI_GADGETMASK) {
	      case SLG_SiteList:
		{
		    ULONG action;
		    struct Node *node;
		    
		    GetAttrs(SLG_List[SLG_SiteList], LISTBROWSER_RelEvent, &action,
			     TAG_DONE);
		    if (action&LBRE_DOUBLECLICK && lsel==code) {
			GetAttrs(SLG_List[SLG_SiteList],
				 LISTBROWSER_SelectedNode, &node, TAG_DONE);
			GetListBrowserNodeAttrs(node, LBNA_UserData, &retnode,
						TAG_DONE);
			if (!retnode->sn_BarLabel) {
			    if (ConnectMode) {
				if (retnode->sn_MenuType!=SLN_PARENT)
				  done=TRUE;
				else {
				    done=FALSE;
				    retnode=NULL;
				}
			    }
			    else {
				EditClicked();
			    }
			} else retnode=NULL;
		    }
		    else if (action&LBRE_NORMAL) {
			GetAttrs(SLG_List[SLG_SiteList],
				 LISTBROWSER_SelectedNode, &node,
				 TAG_DONE);
			if (node) {
			    struct SiteNode *sn;
			    GetListBrowserNodeAttrs(node,
						    LBNA_UserData, &sn,
						    TAG_DONE);
			    UpdateSLGGadgets(TRUE,sn->sn_BarLabel?SLN_BARLABEL:sn->sn_MenuType);
			}
			else
			  UpdateSLGGadgets(FALSE, 0);
		    }
		    lsel=code;
		}
		break;
	      case SLG_Top:
		SL_Top();
		break;
	      case SLG_Bottom:
		SL_Bottom();
		break;
	      case SLG_Up:
		SL_Up();
		break;
	      case SLG_Down:
		SL_Down();
		break;
	      case SLG_Edit:
		EditClicked();
		break;
	      case SLG_New:
		NewClicked();
		break;
	      case SLG_AddGroup:
		NewGroup();
		break;
	      case SLG_BarLabel:
		{
		    struct SiteNode *sn;
		    struct Node *lb,*lbn;
		    ULONG i;

		    sn=AllocMem(sizeof (struct SiteNode), MEMF_CLEAR);
		    sn->sn_BarLabel=1;
		    sn->sn_HotList=1;
		    sn->sn_MenuType=SLN_REGULAR;
		    sn->sn_Node.ln_Name=strdup("===============");
		    SetGadgetAttrs(SLG_List[SLG_SiteList],  SiteListWindow, NULL,
				   LISTBROWSER_Labels, ~0,
				   TAG_DONE);
		    lbn=AddLBNTail(&SiteList, sn);
		    for (i=0,lb=GetHead(&SiteList);lb;i++,lb=GetSucc(lb))
		      if (lb==lbn)
			break;
		    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				   LISTBROWSER_Labels, &SiteList,
				   LISTBROWSER_Selected, i,
				   LISTBROWSER_MakeVisible, i,
				   TAG_DONE);
		    ConfigChanged=TRUE;
		    HotListChanged=TRUE;
		    UpdateSLGGadgets(TRUE,sn->sn_MenuType);
		}
		break;
	      case SLG_Connect:
		{
		    struct Node *node;
		    GetAttr(LISTBROWSER_SelectedNode,
			    SLG_List[SLG_SiteList], (ULONG *)&node);
		    GetListBrowserNodeAttrs(node,
					    LBNA_UserData, &retnode,
					    TAG_DONE);
		    if (retnode->sn_MenuType!=SLN_PARENT && !retnode->sn_BarLabel)
		      done=TRUE;
		    else {
			done=FALSE;
			retnode=NULL;
		    }
		    break;
		}
	      case SLG_Cancel:
		done=TRUE;
		retnode=NULL;
		break;
	    }
	    break;
	}
    }
    return done;
}


struct Window *OpenSiteWindow(const BOOL Connect)
{
    struct Image *l;
    struct LayoutLimits limits;
    Object *l1;

    if (SiteListWindow)
      return SiteListWindow;

    SiteListLayout = LayoutObject,
                       GA_DrawInfo, DrawInfo,
                       GA_TextAttr, AmiFTPAttrF,
                       LAYOUT_DeferLayout, FALSE,
                       LAYOUT_SpaceOuter, TRUE,
                       LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
                       LAYOUT_HorizAlignment, LALIGN_CENTRE,

                       StartImage, l=LabelObject,
                         LABEL_Justification, LABEL_CENTRE,
                         LABEL_Text, GetAmiFTPString(SLW_SiteList),
                         LabelEnd,
                         CHILD_MinWidth, l->Width,
                         CHILD_MinHeight, l->Height,
                         CHILD_WeightedWidth, 0,
                         CHILD_WeightedHeight, 0,

                       StartHGroup, // 1
                         StartVGroup, // 2

                         StartVGroup,CLASSACT_BackFill,LAYERS_BACKFILL,
                           StartMember, SLG_List[SLG_SiteList]=ListBrowserObject,
                           GA_ID, SLG_SiteList,
                           GA_RelVerify, TRUE,
                           LISTBROWSER_Labels, (ULONG)&SiteList,
                           LISTBROWSER_ShowSelected, TRUE,
			   LISTBROWSER_Hierarchical, TRUE,
                           ListBrowserEnd,
                           CHILD_MinWidth, PropFont->tf_XSize*20,
                           CHILD_MinHeight, PropFont->tf_YSize*9,
                          EndGroup, // Classact bugfix
                         StartVGroup, EvenSized, // 3

                           StartHGroup, EvenSized, // 4

                             StartMember, SLG_List[SLG_New]=ButtonObject,
                               GA_ID, SLG_New,
                               GA_RelVerify, TRUE,
                               GA_Text, GetAmiFTPString(SLW_New),
//                               GA_UserData, (ULONG)NewClicked,
                               ButtonEnd,

			     StartMember, SLG_List[SLG_AddGroup]=ButtonObject,
			      GA_Text, GetAmiFTPString(SLW_NewGroup),
			      GA_ID, SLG_AddGroup,
			      GA_RelVerify, TRUE,
			     ButtonEnd,

                             StartMember, SLG_List[SLG_Edit]=ButtonObject,
                               GA_ID, SLG_Edit,
                               GA_RelVerify, TRUE,
                               GA_Text, GetAmiFTPString(SLW_Edit),
//                               GA_UserData, (ULONG)EditClicked,
			       GA_Disabled, TRUE,
                               ButtonEnd,

                             StartMember, SLG_List[SLG_Remove]=ButtonObject,
                               GA_ID, SLG_Remove,
                               GA_RelVerify, TRUE,
                               GA_Text, GetAmiFTPString(SLW_Remove),
                               GA_UserData, (ULONG)RemoveClicked,
			       GA_Disabled, TRUE,
                               ButtonEnd,
			       CHILD_NominalSize, TRUE,
                             EndGroup, /* End of New/edit/remove-group */ // -4

                           LAYOUT_AddChild, l1=HLayoutObject, EvenSized, // 5

                             StartMember, SLG_List[SLG_Connect]=ButtonObject,
                               GA_ID, SLG_Connect,
                               GA_RelVerify, TRUE,
                               GA_Text, GetAmiFTPString(SLW_Connect),
			       GA_Disabled, TRUE,
                               ButtonEnd,

                             StartMember, SLG_List[SLG_Cancel]=ButtonObject,
                               GA_ID, SLG_Cancel,
                               GA_RelVerify, TRUE,
                               GA_Text, Connect?GetAmiFTPString(SLW_Cancel):"OK",
                               ButtonEnd,
			       CHILD_NominalSize, TRUE,
                             EndGroup, /* End of connect/disconnect-group */ //-5
                             CHILD_WeightMinimum, TRUE,
                           EndGroup, /* End of two row button-group */ //-3
                           CHILD_WeightedHeight, 0,
                         EndGroup, /* End of listlist/button group */ //-2

                           StartVGroup, EvenSized,
                             StartMember, SLG_List[SLG_Top]=ButtonObject,
                              GA_Text, GetAmiFTPString(SLW_Top),
                              GA_ID, SLG_Top,
                              GA_RelVerify, TRUE,
			      GA_Disabled, TRUE,
                             ButtonEnd,

                             StartMember, SLG_List[SLG_Up]=ButtonObject,
                              GA_Text, GetAmiFTPString(SLW_Up),
                              GA_ID, SLG_Up,
                              GA_RelVerify, TRUE,
			      GA_Disabled, TRUE,
                             ButtonEnd,

                             StartMember, SLG_List[SLG_Down]=ButtonObject,
                              GA_Text, GetAmiFTPString(SLW_Down),
                              GA_ID, SLG_Down,
                              GA_RelVerify, TRUE,
			      GA_Disabled, TRUE,
                             ButtonEnd,

                             StartMember, SLG_List[SLG_Bottom]=ButtonObject,
                              GA_Text, GetAmiFTPString(SLW_Bottom),
                              GA_ID, SLG_Bottom,
                              GA_RelVerify, TRUE,
			      GA_Disabled, TRUE,
                             ButtonEnd,

                             StartMember, SLG_List[SLG_BarLabel]=ButtonObject,
                              GA_Text, GetAmiFTPString(SLW_AddBar),
                              GA_ID, SLG_BarLabel,
                              GA_RelVerify, TRUE,
                             ButtonEnd,
			     CHILD_NominalSize, TRUE,

                           EndGroup, /* End of Button-group */
                           CHILD_WeightedWidth, 0,
                           CHILD_WeightedHeight, 0,
			   EndGroup,
		       LayoutEnd; /* End of Layoutobject */

    if (!SiteListLayout)
      return NULL;

    if (!Connect) {
	SetAttrs(l1, LAYOUT_RemoveChild, SLG_List[SLG_Connect], TAG_DONE);	
	SLG_List[SLG_Connect]=NULL;
	SLG_List[SLG_Cancel]=NULL;
    }
    
    LayoutLimits((struct Gadget *)SiteListLayout, &limits, PropFont, Screen);
    limits.MinHeight+=Screen->WBorTop+Screen->WBorBottom;
    limits.MinWidth+=Screen->WBorLeft+Screen->WBorRight;

    SiteListWin_Object = WindowObject,
                           WA_Title, GetAmiFTPString(SLW_SiteListWindow),
                           WA_PubScreen, Screen,
                           WA_SizeGadget, TRUE,
                           WA_SizeBBottom, TRUE,
                           WA_DepthGadget, TRUE,
                           WA_DragBar, TRUE,
                           WA_CloseGadget, TRUE,
                           WA_Activate, TRUE,
                           WA_SmartRefresh, TRUE,
                           WA_Top, MainWindow->TopEdge+(MainWindow->Height-limits.MinHeight)/2,
                           WA_Left, MainWindow->LeftEdge+(MainWindow->Width-limits.MinWidth)/2,
                           WA_InnerHeight, height?height:limits.MinHeight,
                           WA_InnerWidth, width?width:limits.MinWidth,
                           WA_IDCMP, IDCMP_RAWKEY,
                           WINDOW_ParentGroup, SiteListLayout,
	                   WINDOW_InterpretUserData, WGUD_FUNC,
                         EndWindow;

    if (!SiteListWin_Object) {
	DisposeObject(SiteListLayout);
	return NULL;
    }
    if (SiteListWindow=CA_OpenWindow(SiteListWin_Object)) {
	return SiteListWindow;
    }
    DisposeObject(SiteListWin_Object);
    SiteListWin_Object=NULL;
    SiteListLayout=NULL;

    return NULL;
}

void CloseSiteListWindow(void)
{
    if (SiteListWin_Object) {
	height=SiteListWindow->Height-SiteListWindow->BorderBottom-SiteListWindow->BorderTop;
	width=SiteListWindow->Width-SiteListWindow->BorderLeft-SiteListWindow->BorderRight;
	DisposeObject(SiteListWin_Object);
	SiteListLayout=NULL;
	SiteListWin_Object=NULL;
	SiteListWindow=NULL;
    }
}

int NewGroup(void)
{
    struct SiteNode *sn;

    sn=AllocMem(sizeof(struct SiteNode), MEMF_CLEAR);
    if (sn) {
	struct Node *lb,*lbn;
	ULONG i;

	sn->sn_Node.ln_Name=strdup(GetAmiFTPString(SLW_Newstring));
	sn->sn_MenuType=SLN_PARENT;
	sn->sn_HotList=TRUE;

	LockWindow(SiteListWin_Object);
	OpenEditWindow(sn);
	UnlockWindow(SiteListWin_Object);
	if (AddToSiteList) {
	    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			   LISTBROWSER_Labels, ~0,
			   TAG_DONE);
	    lbn=AddLBNTail(&SiteList, sn);
	    for (i=0,lb=GetHead(&SiteList);lb;i++,lb=GetSucc(lb))
	      if (lb==lbn)
		break;
	    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			   LISTBROWSER_Labels, &SiteList,
			   LISTBROWSER_Selected, i,
			   LISTBROWSER_MakeVisible, i,
			   TAG_DONE);

	    ConfigChanged=TRUE;
	    HotListChanged=TRUE;
	    UpdateSLGGadgets(TRUE, sn->sn_MenuType);
	    RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
	}
	else FreeMem(sn, sizeof(struct SiteNode));
    }
    return 1;
}

int SL_Up(void)
{
    ULONG thisgen, hidden, haschildren,nodegen;
    ULONG i;
    struct Node *node,*prevnode;
    struct SiteNode *sn;
    struct List childlist;

    GetAttrs(SLG_List[SLG_SiteList],
	     LISTBROWSER_SelectedNode, &node,
	     TAG_DONE);
    if (node) {
	if (node==GetHead(&SiteList))
	  return 1;
	if (prevnode=GetPred(node)) {
	    GetListBrowserNodeAttrs(node, LBNA_Flags, &haschildren,
				    LBNA_Generation, &nodegen,
				    LBNA_UserData, &sn,
				    TAG_DONE);
	    haschildren=haschildren&LBFLG_HASCHILDREN;
	    if (haschildren) {
		struct Node *child,*nchild;
		ULONG chldgen;

		NewList(&childlist);
		if (child=GetSucc(node)) {
		    GetListBrowserNodeAttrs(child, LBNA_Generation, &chldgen,
					    TAG_DONE);
		    if (chldgen==2) {
			nchild=GetSucc(child);
			Remove(child);
			AddTail(&childlist, child);
			while (nchild) {
			    child=nchild;
			    nchild=GetSucc(child);
			    GetListBrowserNodeAttrs(child, 
						    LBNA_Generation, &chldgen,
						    TAG_DONE);
			    if (chldgen==2) {
				Remove(child);
				AddTail(&childlist, child);
			    }
			    else nchild=NULL;
			}
		    }
		}
		GetListBrowserNodeAttrs(prevnode, LBNA_Generation, &thisgen,
					TAG_DONE);
		while (thisgen == 2 && prevnode) {
		    prevnode=GetPred(prevnode);
		    if (prevnode) {
			GetListBrowserNodeAttrs(prevnode,LBNA_Generation,&thisgen,TAG_DONE);
		    }
		}
		SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
			       LISTBROWSER_Labels,~0,
			       TAG_DONE);
		Remove(node);
		Insert(&SiteList,node,prevnode?GetPred(prevnode):NULL);
		if (FirstNode(&childlist)) {
		    nchild=node;
		    while (child=RemHead(&childlist)) {
			Insert(&SiteList,child,nchild);
			nchild=child;
		    }
		}

		for (i=0,child=GetHead(&SiteList);child;child=GetSucc(child),i++)
		  if (child==node) break;

		if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				   LISTBROWSER_Labels,&SiteList,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
	    }
	    else {
		GetListBrowserNodeAttrs(prevnode,LBNA_Flags,&hidden,LBNA_Generation,&thisgen,TAG_DONE);

		if (hidden&LBFLG_HIDDEN) {
		    while (hidden && prevnode) {
			prevnode=GetPred(prevnode);
			if (prevnode) {
			    GetListBrowserNodeAttrs(prevnode,LBNA_Flags,&hidden,TAG_DONE);
			    GetListBrowserNodeAttrs(node,LBNA_Generation,&thisgen,TAG_DONE);
			    hidden=hidden&LBFLG_HIDDEN;
			}
		    }
		    prevnode=GetPred(prevnode);
		    thisgen=1;
		}
		else if (hidden&LBFLG_HASCHILDREN) {
		    if (hidden&LBFLG_SHOWCHILDREN) {
			if (nodegen==2) {
			    thisgen=1;
			    prevnode=GetPred(prevnode);
			}
			else {
			    thisgen=2;
			}
		    }
		    else {
			prevnode=GetPred(prevnode);
			thisgen=1;
		    }
		}
		else {
		    if (nodegen == 1 && thisgen == 2) {
			thisgen=2;
		    }
		    else if (nodegen==2 && thisgen == 2)
		      prevnode=GetPred(prevnode);
		    else if (nodegen==1 && thisgen ==1)
		      prevnode=GetPred(prevnode);
		}

		SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
			       LISTBROWSER_Labels,~0,
			       TAG_DONE);
		SetListBrowserNodeAttrs(node,LBNA_Generation,thisgen,TAG_DONE);
		sn->sn_MenuType=thisgen==1?SLN_REGULAR:SLN_CHILD;
		Remove(node);
		Insert(&SiteList,node,prevnode);

		for (i=0,prevnode=GetHead(&SiteList);prevnode;prevnode=GetSucc(prevnode),i++)
		  if (prevnode==node) break;
		
		if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				   LISTBROWSER_Labels,&SiteList,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
	    }
	}
	HotListChanged=TRUE;
	ConfigChanged=TRUE;
    }
    return 1;
}

int SL_Down(void)
{
    struct Node *node,*succnode;
    ULONG i;
    struct List childlist;
    ULONG haschildren,hschld,thisgen,nodegen;
    struct SiteNode *sn=NULL;

    GetAttrs(SLG_List[SLG_SiteList],
	     LISTBROWSER_SelectedNode,&node,
	     TAG_DONE);
    if (node) {
	if (succnode=GetSucc(node)) {
	    GetListBrowserNodeAttrs(node,LBNA_Flags,&haschildren,LBNA_Generation,&nodegen,LBNA_UserData,&sn,TAG_DONE);
	    haschildren=haschildren&LBFLG_HASCHILDREN;
	    if (haschildren) {
		struct Node *child,*nchild;
		ULONG chldgen;

		NewList(&childlist);
		SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
			       LISTBROWSER_Labels,~0,
			       TAG_DONE);
		
		/* First we need to check if this parent has any children and if so
		   remove them from the list */
		if (child=GetSucc(node)) {
		    GetListBrowserNodeAttrs(child,LBNA_Generation,&chldgen,TAG_DONE);
		    if (chldgen==2) {
			nchild=GetSucc(child);
			Remove(child);
			AddTail(&childlist,child);
			while (child=nchild) {
			    nchild=GetSucc(child);
			    GetListBrowserNodeAttrs(child,LBNA_Generation,&chldgen,TAG_DONE);
			    if (chldgen==2) {
				Remove(child);
				AddTail(&childlist,child);
			    }
			    else {
				nchild=NULL;
			    }
			}
		    }
		}

		/* Since we haven't removed the parent we can check which node is
		   the successor. We need to check if it is a parent and has children
		   too. The output from this part should be the succnode that we
		   should insert the node we are moving. */
		succnode=GetSucc(node);
		if (succnode) {
		    GetListBrowserNodeAttrs(succnode,LBNA_Flags,&hschld,TAG_DONE);
		    if (hschld&LBFLG_HASCHILDREN) {
			child=GetSucc(succnode);
			if (child) {
			    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,TAG_DONE);
			    while (thisgen==2 && child) {
				child=GetSucc(child);
				if (child) {
				    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,TAG_DONE);
				}
			    }
			    if (child)
			      succnode=GetPred(child);
			    else
			      succnode=GetTail(&SiteList);
			}
			Remove(node);
			Insert(&SiteList, node, succnode);
		    }
		    else {
			Remove(node);
			Insert(&SiteList, node, succnode);
		    }
		}

		if (FirstNode(&childlist)) {
		    nchild=node;
		    while (child=RemHead(&childlist)) {
			Insert(&SiteList, child, nchild);
			nchild=child;
		    }
		}

		for (i=0,child=GetHead(&SiteList);child;child=GetSucc(child),i++)
		  if (child==node) break;

		if (SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				   LISTBROWSER_Labels, &SiteList,
				   LISTBROWSER_Selected, i,
				   LISTBROWSER_MakeVisible, i,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);

	    }
	    else {
		GetListBrowserNodeAttrs(succnode, LBNA_Flags, &hschld,
					LBNA_Generation, &thisgen, TAG_DONE);

		if (hschld&LBFLG_HASCHILDREN) {
		    if (nodegen==2) {
			thisgen=1;
			succnode=GetPred(node);
		    }
		    else if (!(hschld&LBFLG_SHOWCHILDREN)) {
			if (GetSucc(succnode)) {
			    struct Node *child;
			    char *text;

			    child=GetSucc(succnode);
			    GetListBrowserNodeAttrs(child,
						    LBNA_Generation, &thisgen,
						    LBNCA_Text, &text, TAG_DONE);
			    if (thisgen!=1) {
				succnode=child;
				while (thisgen==2 && succnode) {
				    succnode=GetSucc(succnode);
				    if (succnode) {
					GetListBrowserNodeAttrs(succnode,
								LBNA_Generation, &thisgen,
								TAG_DONE);
				    }
				}
				if (succnode)
				  succnode=GetPred(succnode);
				else
				  succnode=GetTail(&SiteList);
			    }
			}
			thisgen=1;
		    }
		    else
		      thisgen=2;
		}
		else {
		    if (nodegen==2 && thisgen==1) {
			thisgen=1;
			succnode=GetPred(node);
		    }
		}
		SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			       LISTBROWSER_Labels, ~0,
			       TAG_DONE);

		Remove(node);
		SetListBrowserNodeAttrs(node, LBNA_Generation, thisgen, TAG_DONE);
		sn->sn_MenuType=thisgen==1?SLN_REGULAR:SLN_CHILD;
		if (succnode)
		  Insert(&SiteList, node, succnode);
		else
		  AddTail(&SiteList, node);
		
		for (i=0,succnode=GetHead(&SiteList);succnode;succnode=GetSucc(succnode),i++)
		  if (succnode==node) break;

		if (SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				   LISTBROWSER_Labels, &SiteList,
				   LISTBROWSER_Selected, i,
				   LISTBROWSER_MakeVisible, i,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
	    }
	}
	HotListChanged=TRUE;
	ConfigChanged=TRUE;
    }
    return 1;
}

int SL_Top(void)
{
    struct Node *node,*child,*nchild;
    struct List childlist;
    ULONG haschildren,thisgen;

    GetAttrs(SLG_List[SLG_SiteList],
	     LISTBROWSER_SelectedNode, &node, TAG_DONE);
    if (!node)
      return 1;

    if (GetHead(&SiteList)==node)
      return 1;

    GetListBrowserNodeAttrs(node, LBNA_Flags, &haschildren, 
			    LBNA_Generation, &thisgen,TAG_DONE);
    if (thisgen!=1)
      return 1;

    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
		   LISTBROWSER_Labels, ~0,
		   TAG_DONE);
    NewList(&childlist);
    if (haschildren&LBFLG_HASCHILDREN) {
	if (child=GetSucc(node)) {
	    GetListBrowserNodeAttrs(child, LBNA_Generation, &thisgen, TAG_DONE);
	    if (thisgen==2) {
		nchild=GetSucc(child);
		Remove(child);
		AddTail(&childlist, child);
		while (child=nchild) {
		    nchild=GetSucc(child);
		    GetListBrowserNodeAttrs(child, LBNA_Generation, &thisgen,
					    TAG_DONE);
		    if (thisgen==2) {
			Remove(child);
			AddTail(&childlist, child);
		    }
		    else {
			nchild=NULL;
		    }
		}
	    }
	}
	Remove(node);
	AddHead(&SiteList, node);
	if (FirstNode(&childlist)) {
	    nchild=node;
	    while (child=RemHead(&childlist)) {
		Insert(&SiteList, child, nchild);
		nchild=child;
	    }
	}
    }
    else {
	Remove(node);
	AddHead(&SiteList, node);
    }
    if (SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
		       LISTBROWSER_Labels, &SiteList,
		       LISTBROWSER_Selected, 0,
		       LISTBROWSER_MakeVisible, 0,
		       TAG_DONE))
      RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
    HotListChanged=TRUE;
    ConfigChanged=TRUE;
    return 1;
}

int SL_Bottom(void)
{
    struct Node *node,*child,*nchild;
    struct List childlist;
    ULONG haschildren,thisgen;

    GetAttrs(SLG_List[SLG_SiteList],
	     LISTBROWSER_SelectedNode, &node, TAG_DONE);
    if (!node)
      return 1;

    if (GetTail(&SiteList)==node)
      return 1;

    GetListBrowserNodeAttrs(node, LBNA_Flags, &haschildren,
			    LBNA_Generation, &thisgen, TAG_DONE);
    if (thisgen!=1)
      return 1;

    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
		   LISTBROWSER_Labels, ~0,
		   TAG_DONE);
    NewList(&childlist);
    if (haschildren&LBFLG_HASCHILDREN) {
	if (child=GetSucc(node)) {
	    GetListBrowserNodeAttrs(child, LBNA_Generation, &thisgen, TAG_DONE);
	    if (thisgen==2) {
		nchild=GetSucc(child);
		Remove(child);
		AddTail(&childlist, child);
		while (child=nchild) {
		    nchild=GetSucc(child);
		    GetListBrowserNodeAttrs(child, LBNA_Generation, &thisgen,
					    TAG_DONE);
		    if (thisgen==2) {
			Remove(child);
			AddTail(&childlist, child);
		    }
		    else {
			nchild=NULL;
		    }
		}
	    }
	}
	Remove(node);
	AddTail(&SiteList, node);
	if (FirstNode(&childlist)) {
	    nchild=node;
	    while (child=RemHead(&childlist)) {
		Insert(&SiteList, child, nchild);
		nchild=child;
	    }
	}
    }
    else {
	Remove(node);
	AddTail(&SiteList, node);
    }

    for (thisgen=0,child=GetHead(&SiteList);child;child=GetSucc(child),thisgen++)
      if (child==node) break;

    if (SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
		       LISTBROWSER_Labels, &SiteList,
		       LISTBROWSER_Selected, thisgen,
		       LISTBROWSER_MakeVisible, thisgen,
		       TAG_DONE))
      RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
    HotListChanged=TRUE;
    ConfigChanged=TRUE;
    return 1;
}

int NewClicked(void)
{
    struct SiteNode *sn;
    struct Node *lbn;

    geta4();
    
    sn=AllocMem(sizeof(struct SiteNode), MEMF_CLEAR);
    if (sn) {
	sn->sn_Node.ln_Name=strdup(GetAmiFTPString(SLW_Newstring));
	sn->sn_Port=21;
	sn->sn_Proxy=MainPrefs.mp_DefaultProxy;
	sn->sn_Anonymous=1;
	sn->sn_MenuType=SLN_REGULAR;
	LockWindow(SiteListWin_Object);
	OpenEditWindow(sn);
	UnlockWindow(SiteListWin_Object);
	if (AddToSiteList) {
	    long i;
	    struct Node *lb;

	    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			   LISTBROWSER_Labels, ~0,
			   TAG_DONE);
	    lbn=AddLBNTail(&SiteList,sn);
	    for (i=0,lb=GetHead(&SiteList);lb;i++,lb=GetSucc(lb))
	      if (lb==lbn)
		break;
	    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			   LISTBROWSER_Labels, &SiteList,
			   LISTBROWSER_Selected, i,
			   LISTBROWSER_MakeVisible, i,
			   TAG_DONE);

	    ConfigChanged=TRUE;
	    HotListChanged=TRUE;
	    UpdateSLGGadgets(TRUE, sn->sn_MenuType);
	    RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
	}
	else  FreeMem(sn, sizeof(struct SiteNode));
    }
    return 1;
}

int EditClicked(void)
{
    struct Node *lbn;
    struct SiteNode *sn;

    geta4();

    GetAttr(LISTBROWSER_SelectedNode, SLG_List[SLG_SiteList], (ULONG *)&lbn);

    if (lbn) {
	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData, &sn,
				TAG_DONE);
	if (sn) {
	    if (!sn->sn_BarLabel) {
		/* fix this: (sn) should be a copy of sn */
		LockWindow(SiteListWin_Object);
		OpenEditWindow(sn);
		if (AddToSiteList) {
		    LBEditNode(SLG_List[SLG_SiteList], SiteListWindow, NULL, lbn,
			       LBNA_Column, 0,
			       LBNCA_Text, sn->sn_Node.ln_Name,
			       TAG_DONE);
		    if (!sn->sn_HotList) {
			struct Node *lbnode=GetSucc(lbn);
			if (lbnode) {
			    GetListBrowserNodeAttrs(lbnode,
						    LBNA_UserData, &sn,
						    TAG_DONE);
			    while (sn->sn_MenuType==SLN_CHILD) {
				sn->sn_HotList=FALSE;
				if (lbnode=GetSucc(lbnode)) {
				    GetListBrowserNodeAttrs(lbnode,
							    LBNA_UserData, &sn,
							    TAG_DONE);
				}
				else break;
			    }
			}
		    }
		    ConfigChanged=TRUE;
		    HotListChanged=TRUE;
		}
		UnlockWindow(SiteListWin_Object);
	    }
	}
    }
    return 1;
}

int RemoveClicked(void)
{
    struct Node *lbn;
    struct SiteNode *sn=NULL;
    struct Node *lbns;

    geta4();

    GetAttr(LISTBROWSER_SelectedNode, SLG_List[SLG_SiteList], (ULONG *)&lbn);

    if (lbn) {
	SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
		       LISTBROWSER_Labels, ~0,
		       TAG_DONE);
	lbns=GetSucc(lbn);
	Remove(lbn);
	SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
		       LISTBROWSER_Labels, &SiteList,
		       LISTBROWSER_Selected, -1,
		       TAG_DONE);
/*	GetListBrowserNodeAttrs(lbn,
				LBNA_UserData, &sn,
				TAG_DONE);*/
//	LBRemNode(SLG_List[SLG_SiteList], SiteListWindow, NULL, lbn);
	if (sn) {
	    if (sn->sn_MenuType==SLN_PARENT) {
		FreeSiteNode(sn);
		if (lbns) {
		    GetListBrowserNodeAttrs(lbns,
					    LBNA_UserData, &sn, TAG_DONE);
		    while (sn->sn_MenuType==SLN_CHILD) {
			sn->sn_MenuType=SLN_REGULAR;
			SetListBrowserNodeAttrs(lbns, LBNA_Generation, 1, TAG_DONE);
			lbns=GetSucc(lbns);
			if (lbns) {
			    GetListBrowserNodeAttrs(lbns, LBNA_UserData, &sn,
						    TAG_DONE);
			}
			else break;
		    }
		}
	    }
	    else
	      FreeSiteNode(sn);
	}
	ConfigChanged=TRUE;
	HotListChanged=TRUE;
	UpdateSLGGadgets(FALSE, 0);
	RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
    }
    return 1;
}

#define DisableGadget(gadget, disable) if (SetGadgetAttrs(gadget, SiteListWindow, NULL, GA_Disabled, disable, TAG_DONE) && SiteListWindow) RefreshGList(gadget, SiteListWindow, NULL, 1);

void UpdateSLGGadgets(const ULONG selected, const int type)
{
    ULONG attr=(((struct Gadget *)SLG_List[SLG_Edit])->Flags & GFLG_DISABLED);

    if (!selected) {
	if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL, 
			   GA_Disabled, TRUE,
			   TAG_DONE))
	  RefreshGList(SLG_List[SLG_Edit], SiteListWindow, NULL,1);
	if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL,
			   GA_Disabled, TRUE,
			   TAG_DONE))
	  RefreshGList(SLG_List[SLG_Remove], SiteListWindow, NULL,1);
	if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL,
			   GA_Disabled, TRUE,
			   TAG_DONE))
	  RefreshGList(SLG_List[SLG_Top], SiteListWindow, NULL,1);
	if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL,
			   GA_Disabled, TRUE,
			   TAG_DONE))
	  RefreshGList(SLG_List[SLG_Up], SiteListWindow, NULL,1);
	if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL,
			   GA_Disabled, TRUE,
			   TAG_DONE))
	  RefreshGList(SLG_List[SLG_Down], SiteListWindow, NULL,1);
	if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL,
			   GA_Disabled, TRUE,
			   TAG_DONE))
	  RefreshGList(SLG_List[SLG_Bottom], SiteListWindow, NULL,1);
	if (SLG_List[SLG_Connect]) {
	    if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL,
			       GA_Disabled, TRUE,
			       TAG_DONE))
	      RefreshGList(SLG_List[SLG_Connect], SiteListWindow, NULL,1);
	}
    }
    else {
	if (type==SLN_PARENT) {
	    attr=(((struct Gadget *)SLG_List[SLG_Edit])->Flags & GFLG_DISABLED);
	    if (attr) {
		if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Edit], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Remove], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Top], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Up], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Down], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Bottom], SiteListWindow, NULL,1);
	    }
	    if (SLG_List[SLG_Connect]) {
		attr=(((struct Gadget *)SLG_List[SLG_Connect])->Flags & GFLG_DISABLED);
		if (!attr)
		  if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL,
				     GA_Disabled, TRUE,
				     TAG_DONE))
		    RefreshGList(SLG_List[SLG_Connect], SiteListWindow, NULL,1);
	    }
	}
	else {
	    attr=(((struct Gadget *)SLG_List[SLG_Edit])->Flags & GFLG_DISABLED);
	    if (attr) {
		if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Edit], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Remove], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Top], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Up], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Down], SiteListWindow, NULL,1);
		if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL,
				   GA_Disabled, FALSE,
				   TAG_DONE))
		  RefreshGList(SLG_List[SLG_Bottom], SiteListWindow, NULL,1);
	    }
	    if (SLG_List[SLG_Connect]) {
		attr=(((struct Gadget *)SLG_List[SLG_Connect])->Flags & GFLG_DISABLED);
		if (attr)
		  if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL,
				     GA_Disabled, FALSE,
				     TAG_DONE))
		    RefreshGList(SLG_List[SLG_Connect], SiteListWindow, NULL,1);
	    }
	}
    }
}
#undef DisableGadget
