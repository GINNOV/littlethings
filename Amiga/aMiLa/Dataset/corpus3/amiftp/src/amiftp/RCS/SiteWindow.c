head	1.692;
access;
symbols;
locks
	lilja:1.692; strict;
comment	@ * @;


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
next	1.607;

1.607
date	96.06.30.12.33.45;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.585;

1.585
date	96.06.13.00.03.21;	author lilja;	state Exp;
branches;
next	1.535;

1.535
date	96.05.29.21.27.37;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
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
next	1.150;

1.150
date	96.02.11.16.38.55;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1343;

0.1343
date	96.01.20.17.34.39;	author lilja;	state Exp;
branches;
next	0.1332;

0.1332
date	95.12.17.13.21.38;	author lilja;	state Exp;
branches;
next	0.1312;

0.1312
date	95.12.14.16.15.31;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	0.753;

0.753
date	95.09.30.13.35.40;	author lilja;	state Exp;
branches;
next	0.588;

0.588
date	95.09.12.16.24.08;	author lilja;	state Exp;
branches;
next	0.567;

0.567
date	95.09.11.17.15.13;	author lilja;	state Exp;
branches;
next	0.563;

0.563
date	95.09.10.20.59.20;	author lilja;	state Exp;
branches;
next	0.544;

0.544
date	95.09.08.14.11.28;	author lilja;	state Exp;
branches;
next	0.534;

0.534
date	95.09.03.18.34.27;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.425;

0.425
date	95.07.24.18.19.29;	author lilja;	state Exp;
branches;
next	0.413;

0.413
date	95.07.23.13.03.53;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.348;

0.348
date	95.06.22.18.56.45;	author lilja;	state Exp;
branches;
next	0.345;

0.345
date	95.06.15.23.29.18;	author lilja;	state Exp;
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
@Code for SiteList/Configuration-windows
@


1.692
log
@Speedbar and buttons configurable.
@
text
@/* RCS Id: $Id: SiteWindow.c 1.630 1996/07/07 20:10:48 lilja Exp lilja $
   Locked version: $Revision: 1.630 $
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
@


1.630
log
@Added items in the menu to duplicate the buttons.
@
text
@d1 2
a2 2
/* RCS Id: $Id: SiteWindow.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d652 1
a1188 2


d1394 1
a1394 1
			    if (child) 
d1400 1
a1400 1
			Insert(&SiteList,node,succnode);
d1404 1
a1404 1
			Insert(&SiteList,node,succnode);
d1411 1
a1411 1
			Insert(&SiteList,child,nchild);
d1419 4
a1422 4
		if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				   LISTBROWSER_Labels,&SiteList,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
d1424 1
a1424 1
		  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
d1428 2
a1429 1
		GetListBrowserNodeAttrs(succnode,LBNA_Flags,&hschld,LBNA_Generation,&thisgen,TAG_DONE);
d1440 1
d1442 3
a1444 1
			    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,LBNCA_Text,&text,TAG_DONE);
d1450 3
a1452 1
					GetListBrowserNodeAttrs(succnode,LBNA_Generation,&thisgen,TAG_DONE);
d1472 2
a1473 2
		SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
			       LISTBROWSER_Labels,~0,
d1477 1
a1477 1
		SetListBrowserNodeAttrs(node,LBNA_Generation,thisgen,TAG_DONE);
d1480 1
a1480 1
		  Insert(&SiteList,node,succnode);
d1482 1
a1482 1
		  AddTail(&SiteList,node);
d1487 4
a1490 4
		if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				   LISTBROWSER_Labels,&SiteList,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
d1492 1
a1492 1
		  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
d1508 1
a1508 1
	     LISTBROWSER_SelectedNode,&node,TAG_DONE);
d1515 2
a1516 1
    GetListBrowserNodeAttrs(node,LBNA_Flags,&haschildren, LBNA_Generation,&thisgen,TAG_DONE);
d1520 2
a1521 2
    SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
		   LISTBROWSER_Labels,~0,
d1526 1
a1526 1
	    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,TAG_DONE);
d1530 1
a1530 1
		AddTail(&childlist,child);
d1533 2
a1534 1
		    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,TAG_DONE);
d1537 1
a1537 1
			AddTail(&childlist,child);
d1546 1
a1546 1
	AddHead(&SiteList,node);
d1550 1
a1550 1
		Insert(&SiteList,child,nchild);
d1557 1
a1557 1
	AddHead(&SiteList,node);
d1559 4
a1562 4
    if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
		       LISTBROWSER_Labels,&SiteList,
		       LISTBROWSER_Selected,0,
		       LISTBROWSER_MakeVisible,0,
d1564 1
a1564 1
      RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
d1577 1
a1577 1
	     LISTBROWSER_SelectedNode,&node,TAG_DONE);
d1584 2
a1585 1
    GetListBrowserNodeAttrs(node,LBNA_Flags,&haschildren, LBNA_Generation,&thisgen,TAG_DONE);
d1589 2
a1590 2
    SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
		   LISTBROWSER_Labels,~0,
d1595 1
a1595 1
	    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,TAG_DONE);
d1599 1
a1599 1
		AddTail(&childlist,child);
d1602 2
a1603 1
		    GetListBrowserNodeAttrs(child,LBNA_Generation,&thisgen,TAG_DONE);
d1606 1
a1606 1
			AddTail(&childlist,child);
d1615 1
a1615 1
	AddTail(&SiteList,node);
d1619 1
a1619 1
		Insert(&SiteList,child,nchild);
d1626 1
a1626 1
	AddTail(&SiteList,node);
d1632 4
a1635 4
    if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
		       LISTBROWSER_Labels,&SiteList,
		       LISTBROWSER_Selected,thisgen,
		       LISTBROWSER_MakeVisible,thisgen,
d1637 1
a1637 1
      RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
d1694 1
a1694 1
    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&lbn);
d1698 1
a1698 1
				LBNA_UserData,&sn,
d1713 3
a1715 1
			    GetListBrowserNodeAttrs(lbnode,LBNA_UserData,&sn,TAG_DONE);
d1719 3
a1721 1
				    GetListBrowserNodeAttrs(lbnode,LBNA_UserData,&sn,TAG_DONE);
d1745 1
a1745 1
    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&lbn);
d1749 1
a1749 1
		       LISTBROWSER_Labels,~0,
d1754 2
a1755 2
		       LISTBROWSER_Labels,&SiteList,
		       LISTBROWSER_Selected,-1,
d1758 1
a1758 1
				LBNA_UserData,&sn,
d1766 1
a1766 1
					    LBNA_UserData,&sn,TAG_DONE);
d1769 1
a1769 1
			SetListBrowserNodeAttrs(lbns,LBNA_Generation,1,TAG_DONE);
d1772 2
a1773 1
			    GetListBrowserNodeAttrs(lbns,LBNA_UserData,&sn,TAG_DONE);
d1784 2
a1785 2
	UpdateSLGGadgets(FALSE,0);
	RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL,1);
d1790 2
d1905 1
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
/* RCS Id: $Id: SiteWindow.c 1.607 1996/06/30 12:33:45 lilja Exp lilja $
   Locked version: $Revision: 1.607 $
d682 1
d690 1
d712 1
d1024 1
d1041 1
d1082 1
@


1.607
log
@Cursor up in sitelistwindow works now.
Fixed closing of sitelist-window when the edit-window was opened,
this is probably a CA-bug.
@
text
@d1 2
a2 2
/* RCS Id: $Id: SiteWindow.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d5 1
a5 1
#include "ftpwin.h"
d74 2
a75 1
PasswordHook(register __a0 struct Hook *Hook,register __a2 struct SGWork *Work,register __a1 ULONG *Msg)
d243 1
a243 1
		    GetAttr(GA_Selected,ESG_List[ESG_Anonymous],&attr);
d247 1
a247 1
		      RefreshGList(ESG_List[ESG_LoginName], EditSiteWindow,NULL,1);
d251 1
a251 1
		      RefreshGList(ESG_List[ESG_Password], EditSiteWindow, NULL,1);
d285 1
a285 1
      strcpy(buf1,sn->sn_Node.ln_Name);
d289 1
a289 1
      strcpy(buf2,sn->sn_SiteAddress);
d293 1
a293 1
      strcpy(buf3,sn->sn_RemoteDir);
d297 1
a297 1
      strcpy(buf4,sn->sn_LocalDir);
d299 1
a299 1
      strcpy(buf4,MainPrefs.mp_LocalDir);
d303 1
a303 1
      strcpy(buf5,sn->sn_LoginName);
d306 2
a307 2
    memset(Original,0,sizeof(Original));
    memset(RealString,0,sizeof(RealString));
d310 3
a312 3
	strcpy(buf6,Original);
	strcpy(Original,sn->sn_Password);
	strcpy(RealString,sn->sn_Password);
d314 1
a314 1
    memset(&EditHook,0,sizeof(EditHook));
d329 1
a329 1
                       GA_TabCycle,TRUE,
d338 1
a338 1
                       GA_TabCycle,TRUE,
d347 1
a347 1
                       GA_TabCycle,TRUE,
d349 2
a350 2
                       INTEGER_Arrows,FALSE,
                       INTEGER_MaxChars,6,
d352 2
a353 2
                       CHILD_NominalSize,TRUE,
                       CHILD_WeightedWidth,0,
d359 2
a360 2
                       GA_TabCycle,TRUE,
                       STRINGA_Buffer,buf3,
d370 1
a370 1
                         GA_TabCycle,TRUE,
d380 2
a381 2
                         CHILD_WeightedWidth,0,
                         CHILD_WeightedHeight,0,
d399 1
a399 1
                         GA_TabCycle,TRUE,
d409 1
a409 1
                         GA_TabCycle,TRUE,
d412 1
a412 1
                         STRINGA_EditHook,(ULONG)&EditHook,
d422 1
a422 1
                         CHOOSER_Active,sn->sn_VMSDIR,
d426 1
a426 1
                         CHILD_WeightedWidth,0,
d452 1
a452 1
                      EndGroup,EndGroup,CHILD_WeightedWidth,0,
d464 1
a464 1
                         GA_RelVerify,TRUE,
d466 2
a467 2
                         CHILD_NominalSize,TRUE,
                         CHILD_WeightedWidth,0,
d472 1
a472 1
                         GA_RelVerify,TRUE,
d474 2
a475 2
                         CHILD_NominalSize,TRUE,
                         CHILD_WeightedWidth,0,
a477 1

d485 1
a485 1
		 LAYOUT_RemoveChild,ESG_List[ESG_LSType],
d488 1
a488 1
		 LAYOUT_RemoveChild,ESG_List[ESG_Proxy],
d491 1
a491 1
		 LAYOUT_RemoveChild,ESG_List[ESG_ADT],
d495 6
a500 6
		 LAYOUT_RemoveChild,ESG_List[ESG_SiteAddress],
		 LAYOUT_RemoveChild,ESG_List[ESG_Port],
		 LAYOUT_RemoveChild,ESG_List[ESG_RemDir],
		 LAYOUT_RemoveChild,l1,
		 LAYOUT_RemoveChild,l2,
		 LAYOUT_RemoveChild,ESG_List[ESG_Anonymous],
d504 1
a504 1
    LayoutLimits((struct Gadget *)EditSiteLayout,&limits,PropFont,Screen);
d510 1
a510 1
                          WA_PubScreen,Screen,
d584 1
a584 1
		GetAttr(GA_Selected,ESG_List[ESG_Anonymous],&attr);
d590 1
a590 1
		GetAttr(GA_Selected, ESG_List[ESG_Proxy],&attr);
d593 1
a593 1
		GetAttr(GA_Selected, ESG_List[ESG_ADT],&attr);
d599 1
a599 1
	    GetAttr(GA_Selected, ESG_List[ESG_HotList],&attr);
a602 1

d617 9
a625 9
	ASL_Window,NULL,
	ASLFR_PrivateIDCMP,TRUE,
	ASLFR_SleepWindow,TRUE,
	ASLFR_InitialDrawer,NULL,
	ASLFR_DrawersOnly,TRUE,
	ASLFR_RejectIcons,TRUE,
	ASLFR_TitleText,NULL,
	ASLFR_InitialLeftEdge,NULL,
	ASLFR_InitialTopEdge,NULL,
d634 1
a634 1
    DirRequester=AllocAslRequest(ASL_FileRequest,NULL);
d638 2
a639 2
	if (SetGadgetAttrs(ESG_List[ESG_LocString],EditSiteWindow,NULL,
				    STRINGA_TextVal,DirRequester->rf_Dir,
d641 1
a641 1
	    RefreshGList(ESG_List[ESG_LocString],EditSiteWindow,NULL,1);
d647 1
d689 1
a689 1
    return stricmp((char *)nodea->ln_Name,(char *)nodeb->ln_Name);
d697 1
a697 1
    while((result=CA_HandleInput(SiteListWin_Object,&code))!=WMHI_LASTMSG) {
d711 2
a712 2
			     LISTBROWSER_Selected,&attr,
			     LISTBROWSER_SelectedNode,&selnode,
d725 2
a726 1
				  GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
d770 1
d772 2
a773 2
			     LISTBROWSER_Selected,&attr,
			     LISTBROWSER_SelectedNode,&selnode,
d778 3
a780 1
			    GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
d784 3
a786 1
				  GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
d797 3
a799 3
		    SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
d801 4
a804 2
		    GetListBrowserNodeAttrs(selnode,LBNA_UserData,&sn,TAG_DONE);
		    UpdateSLGGadgets(TRUE,sn->sn_MenuType);
d834 2
a835 1
		    GetAttrs(SLG_List[SLG_SiteList],LISTBROWSER_RelEvent,&action,TAG_DONE);
d837 4
a840 2
			GetAttrs(SLG_List[SLG_SiteList],LISTBROWSER_SelectedNode,&node,TAG_DONE);
			GetListBrowserNodeAttrs(node,LBNA_UserData,&retnode,TAG_DONE);
d856 3
a858 1
			GetAttrs(SLG_List[SLG_SiteList],LISTBROWSER_SelectedNode,&node,TAG_DONE);
d861 3
a863 1
			    GetListBrowserNodeAttrs(node,LBNA_UserData,&sn,TAG_DONE);
d867 1
a867 1
			  UpdateSLGGadgets(FALSE,0);
a889 37
#if 0
	      case SLG_Sort:
		{
		    ULONG *array,*arrayptr;
		    struct Node *node;
		    int i,numnodes;
		    break;
		    for (i=0,node=GetHead(&SiteList);node;node=GetSucc(node),i++);
		    if (i) {
			numnodes=i;
			array=AllocVec(4*i,MEMF_CLEAR);
			if (array) {
			    SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
					   LISTBROWSER_Labels,~0,
					   TAG_DONE);
			    for (node=GetHead(&SiteList),arrayptr=array;node;arrayptr++,node=GetSucc(node))
			      *arrayptr=(ULONG)node;
			    qsort(array,numnodes,4,SortSiteNodes);
			    NewList(&SiteList);
			    for (arrayptr=array,i=0;i<numnodes;i++,arrayptr++)
			      AddTail(&SiteList,(struct Node *)*arrayptr);
			    if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow, NULL,
					       LISTBROWSER_Labels,&SiteList,
					       LISTBROWSER_Selected,-1,
					       LISTBROWSER_MakeVisible,0,
					       TAG_DONE))
			      RefreshGList(SLG_List[SLG_SiteList],SiteListWindow, NULL,1);
			    UpdateSLGGadgets(FALSE,0);
			    FreeVec(array);
			    ConfigChanged=TRUE;
			    HotListChanged=TRUE;
			}
		    }
		    
		}
		break;
#endif
d898 2
a899 1
		    sn=AllocMem(sizeof (struct SiteNode),MEMF_CLEAR);
d904 2
a905 2
		    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				   LISTBROWSER_Labels,~0,
d907 1
a907 1
		    lbn=AddLBNTail(&SiteList,sn);
d912 3
a914 3
				   LISTBROWSER_Labels,&SiteList,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
d924 2
a925 1
		    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&node);
d927 1
a927 1
					    LBNA_UserData,&retnode,
d970 4
a973 4
                         CHILD_MinWidth,l->Width,
                         CHILD_MinHeight,l->Height,
                         CHILD_WeightedWidth,0,
                         CHILD_WeightedHeight,0,
d980 2
a981 2
                           GA_ID,SLG_SiteList,
                           GA_RelVerify,TRUE,
d984 1
a984 1
			   LISTBROWSER_Hierarchical,TRUE,
d986 2
a987 2
                           CHILD_MinWidth,PropFont->tf_XSize*20,
                           CHILD_MinHeight,PropFont->tf_YSize*9,
d1002 1
a1002 1
			      GA_ID,SLG_AddGroup,
d1038 1
a1038 1
                             CHILD_WeightMinimum,TRUE,
d1040 1
a1040 1
                           CHILD_WeightedHeight,0,
d1045 2
a1046 2
                              GA_Text,GetAmiFTPString(SLW_Top),
                              GA_ID,SLG_Top,
d1052 2
a1053 2
                              GA_Text,GetAmiFTPString(SLW_Up),
                              GA_ID,SLG_Up,
d1059 2
a1060 2
                              GA_Text,GetAmiFTPString(SLW_Down),
                              GA_ID,SLG_Down,
d1066 2
a1067 2
                              GA_Text,GetAmiFTPString(SLW_Bottom),
                              GA_ID,SLG_Bottom,
d1071 1
a1071 7
#if 0
                             StartMember, SLG_List[SLG_Sort]=ButtonObject,
                              GA_Text,GetAmiFTPString(SLW_Sort),
                              GA_ID,SLG_Sort,
                              GA_RelVerify, TRUE,
                             ButtonEnd,
#endif
d1073 2
a1074 2
                              GA_Text,GetAmiFTPString(SLW_AddBar),
                              GA_ID,SLG_BarLabel,
d1088 1
a1088 1
	SetAttrs(l1,LAYOUT_RemoveChild,SLG_List[SLG_Connect],TAG_DONE);	
d1093 1
a1093 1
    LayoutLimits((struct Gadget *)SiteListLayout,&limits,PropFont,Screen);
d1099 1
a1099 1
                           WA_PubScreen,Screen,
d1101 1
a1101 1
                           WA_SizeBBottom,TRUE,
d1109 2
a1110 2
                           WA_InnerHeight,height?height:limits.MinHeight,
                           WA_InnerWidth,width?width:limits.MinWidth,
d1154 1
a1154 1
	    
d1160 1
a1160 1
			   LISTBROWSER_Labels,~0,
d1162 1
a1162 1
	    lbn=AddLBNTail(&SiteList,sn);
d1167 3
a1169 3
			   LISTBROWSER_Labels,&SiteList,
			   LISTBROWSER_Selected,i,
			   LISTBROWSER_MakeVisible,i,
d1174 2
a1175 2
	    UpdateSLGGadgets(TRUE,sn->sn_MenuType);
	    RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
d1177 1
a1177 1
	else FreeMem(sn,sizeof(struct SiteNode));
d1193 1
a1193 1
	     LISTBROWSER_SelectedNode,&node,
d1199 4
a1202 1
	    GetListBrowserNodeAttrs(node,LBNA_Flags,&haschildren,LBNA_Generation,&nodegen,LBNA_UserData,&sn,TAG_DONE);
d1210 2
a1211 1
		    GetListBrowserNodeAttrs(child,LBNA_Generation,&chldgen,TAG_DONE);
d1215 1
a1215 1
			AddTail(&childlist,child);
d1219 3
a1221 1
			    GetListBrowserNodeAttrs(child,LBNA_Generation,&chldgen,TAG_DONE);
d1224 1
a1224 1
				AddTail(&childlist,child);
d1230 2
a1231 1
		GetListBrowserNodeAttrs(prevnode,LBNA_Generation,&thisgen,TAG_DONE);
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
d216 1
d668 1
a668 1
    while (!done) {
d707 1
a707 1
		    ULONG attr;
d714 1
a714 1
		    if (attr!=0) {
d742 2
a743 1
			GetListBrowserNodeAttrs(selnode, LBNA_UserData, &sn, TAG_DONE);
d747 13
d869 6
d1017 1
a1017 1
                               GA_UserData, (ULONG)NewClicked,
d1030 1
a1030 1
                               GA_UserData, (ULONG)EditClicked,
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
@d1 2
a2 2
/* SiteWindow.c

@


1.535
log
@Fixed groupwindow bug. It was caused by a new set of layouts in the window.
@
text
@a25 4
struct Node *GetHead(struct List *);
struct Node *GetSucc(struct Node *);
struct Node *GetPred(struct Node *);

a62 2
static struct Hook SiteListIDCMPHook;

a72 94
static ULONG __asm __saveds SiteListIDCMPHookFunc(register __a0 struct Hook *hook,
						  register __a2 Object *WinObj,
						  register __a1 struct IntuiMessage *msg)
{
    ULONG attr;
    struct Node *selnode;
    struct SiteNode *sn;

    switch (msg->Class) {
      case IDCMP_RAWKEY:
	switch (msg->Code) {
	  case RAWKEY_CURSORUP:
	    if (GetHead(&SiteList)) {
		GetAttrs(SLG_List[SLG_SiteList],
			 LISTBROWSER_Selected,&attr,
			 LISTBROWSER_SelectedNode,&selnode,
			 TAG_DONE);
		if (attr!=0) {
		    struct SiteNode *sn;
		    struct Node *node;
		    ULONG i;

		    if (node=GetPred(selnode)) {
			ULONG flags;
			GetListBrowserNodeAttrs(node, LBNA_Flags, &flags, TAG_DONE);
			while (flags&LBFLG_HIDDEN) {
			    node=GetPred(node);
			    if (node)
			      GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
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

		    GetListBrowserNodeAttrs(selnode, LBNA_UserData, &sn, TAG_DONE);

		    UpdateSLGGadgets(TRUE, sn->sn_MenuType);
		}
	    }
	    break;
	  case RAWKEY_CURSORDOWN:
	    if (GetHead(&SiteList)) {
		ULONG i;
		struct Node *node;
		GetAttrs(SLG_List[SLG_SiteList],
			 LISTBROWSER_Selected,&attr,
			 LISTBROWSER_SelectedNode,&selnode,
			 TAG_DONE);
		if (selnode) {
		    if (node=GetSucc(selnode)) {
			ULONG flags;
			GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
			while (flags&LBFLG_HIDDEN) {
			    node=GetSucc(node);
			    if (node)
			      GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
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
		SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
			       LISTBROWSER_Selected,i,
			       LISTBROWSER_MakeVisible,i,
			       TAG_DONE);
		GetListBrowserNodeAttrs(selnode,LBNA_UserData,&sn,TAG_DONE);
		UpdateSLGGadgets(TRUE,sn->sn_MenuType);
	    }
	    break;
	  case 95:
	    SendAGMessage(AG_SITECONF);
	    break;
	}
	break;
    }
    return 0;
}

d229 6
d517 1
a519 2
                          WINDOW_IDCMPHook,&IDCMPHook,
                          WINDOW_IDCMPHookBits,IDCMP_RAWKEY,
d693 2
a694 1
    ULONG result, code,done=FALSE;
d701 103
a1101 4
    SiteListIDCMPHook.h_Entry=(HOOKFUNC)SiteListIDCMPHookFunc;
    SiteListIDCMPHook.h_SubEntry=NULL;
    SiteListIDCMPHook.h_Data=NULL;

d1116 1
a1118 2
                           WINDOW_IDCMPHook,&SiteListIDCMPHook,
                           WINDOW_IDCMPHookBits,IDCMP_RAWKEY,
d1241 1
a1241 1
		if (GetHead(&childlist)) {
d1401 1
a1401 1
		if (GetHead(&childlist)) {
d1532 1
a1532 1
	if (GetHead(&childlist)) {
d1599 1
a1599 1
	if (GetHead(&childlist)) {
@


1.531
log
@Lots of stuff
@
text
@d366 1
a366 1
    Object *l1,*l2;
d416 1
a416 1
                     StartVGroup, LAYOUT_SpaceOuter, TRUE,
d509 1
a509 1
                       StartVGroup, LAYOUT_SpaceOuter, TRUE, LAYOUT_HorizAlignment, LALIGN_RIGHT,
d521 1
a521 1
                       StartHGroup,Spacing(FALSE),
d529 1
a529 1
                       StartVGroup,
d577 11
a587 1
	SetAttrs(EditSiteLayout,
a593 3
		 LAYOUT_RemoveChild,ESG_List[ESG_LSType],
		 LAYOUT_RemoveChild,ESG_List[ESG_Proxy],
		 LAYOUT_RemoveChild,ESG_List[ESG_ADT],
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
@d103 1
a103 1
			GetListBrowserNodeAttrs(node,LBNA_Flags,&flags,TAG_DONE);
d119 3
a121 3
		    SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				   LISTBROWSER_Selected,i,
				   LISTBROWSER_MakeVisible,i,
d123 4
a126 2
		GetListBrowserNodeAttrs(selnode,LBNA_UserData,&sn,TAG_DONE);
		UpdateSLGGadgets(TRUE,sn->sn_MenuType);
d129 1
a129 1
		break;
d413 1
a413 1
                     LAYOUT_SpaceOuter, TRUE,
d415 3
a417 2
                     LAYOUT_HorizAlignment, LALIGN_RIGHT,
    
d507 1
a507 1
                       EndGroup,
d509 1
d545 1
d551 1
a551 1
                     StartHGroup,EvenSized,
a585 1
#if 1
a586 1
#endif
a679 1
#if 1
d682 1
a682 1
#endif
d1637 1
a1637 1
			   LISTBROWSER_Labels,~0,
d1644 3
a1646 3
			   LISTBROWSER_Labels,&SiteList,
			   LISTBROWSER_Selected,i,
			   LISTBROWSER_MakeVisible,i,
d1651 2
a1652 2
	    UpdateSLGGadgets(TRUE,sn->sn_MenuType);
	    RefreshGList(SLG_List[SLG_SiteList],SiteListWindow,NULL,1);
d1654 1
a1654 1
	else  FreeMem(sn,sizeof(struct SiteNode));
d1678 4
a1681 9
		    SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				   LISTBROWSER_Labels,~0,
				   TAG_DONE);
		    SetListBrowserNodeAttrs(lbn,LBNA_Column,0,LBNCA_Text,sn->sn_Node.ln_Name,TAG_DONE);
		    if (SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
				       LISTBROWSER_Labels,&SiteList,
				       LISTBROWSER_SelectedNode,lbn,
				       TAG_DONE))
		      RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
d1762 3
a1764 1
	if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL, GA_Disabled, TRUE))
d1766 3
a1768 1
	if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL, GA_Disabled, TRUE))
d1770 3
a1772 1
	if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL, GA_Disabled, TRUE))
d1774 3
a1776 1
	if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL, GA_Disabled, TRUE))
d1778 3
a1780 1
	if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL, GA_Disabled, TRUE))
d1782 3
a1784 1
	if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL, GA_Disabled, TRUE))
d1787 3
a1789 1
	    if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL, GA_Disabled, TRUE))
d1797 3
a1799 1
		if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL, GA_Disabled, FALSE))
d1801 3
a1803 1
		if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL, GA_Disabled, FALSE))
d1805 3
a1807 1
		if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL, GA_Disabled, FALSE))
d1809 3
a1811 1
		if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL, GA_Disabled, FALSE))
d1813 3
a1815 1
		if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL, GA_Disabled, FALSE))
d1817 3
a1819 1
		if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL, GA_Disabled, FALSE))
d1825 3
a1827 1
		  if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL, GA_Disabled, TRUE))
d1834 3
a1836 1
		if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL, GA_Disabled, FALSE))
d1838 3
a1840 1
		if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL, GA_Disabled, FALSE))
d1842 3
a1844 1
		if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL, GA_Disabled, FALSE))
d1846 3
a1848 1
		if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL, GA_Disabled, FALSE))
d1850 3
a1852 1
		if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL, GA_Disabled, FALSE))
d1854 3
a1856 1
		if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL, GA_Disabled, FALSE))
d1862 3
a1864 1
		  if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL, GA_Disabled, FALSE))
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d24 1
d414 1
a414 2
//                     LAYOUT_BevelStyle,BVS_THIN,

a505 1

d517 9
a532 9

                       StartMember, ESG_List[ESG_Proxy]=CheckBoxObject,
                         GA_ID, ESG_Proxy,
                         GA_RelVerify, TRUE,
                         GA_Text, GetAmiFTPString(SCW_Proxy),
                         GA_Selected, sn->sn_Proxy,
                         CHECKBOX_TextPlace, PLACETEXT_LEFT,
                         CheckBoxEnd,
#if 1
d536 1
a536 1
                         GA_Text, "ADT", //GetAmiFTPString(SCW_Proxy),
d540 6
a545 1
#endif
d553 2
d561 2
a945 1
//                       LAYOUT_BevelStyle,BVS_THIN,
d1171 1
d1179 1
a1179 1
    ULONG i,flags;
d1308 1
d1314 1
a1314 1
    ULONG i,flags;
d1317 1
a1317 1
    struct SiteNode *sn;
d1472 1
d1484 1
a1484 1
      return;
d1487 1
a1487 1
      return;
d1491 1
a1491 1
      return;
d1539 1
d1551 1
a1551 1
      return;
d1554 1
a1554 1
      return;
d1558 1
a1558 1
      return;
d1610 1
d1711 1
a1711 1
    struct SiteNode *sn;
d1728 1
a1728 1
	GetListBrowserNodeAttrs(lbn,
d1730 2
a1731 1
				TAG_DONE);
@


1.200
log
@GETATTR-hit fixed.
@
text
@d1 2
a2 2
/* site_gui.c
   Must change GT_GetGadgetAttrs() in order to make code valid for pre-v39
d20 8
d32 1
a32 1
    ESG_Proxy, ESG_OK, ESG_Cancel,
d61 1
a61 1
    SLG_Cancel, SLG_Up, SLG_Down, SLG_Top, SLG_Bottom,SLG_Sort,//SLG_SubItem,
a65 8
struct List *gobjlist;

static STRPTR subnames[]=
{
    "ITEM",
    "SUBITEM",
    NULL
  };
d68 1
a68 1
struct Window *OpenSiteWindow(void);
d70 1
a70 1
void UpdateSLGGadgets(const ULONG selected, const int num);
d83 2
d90 35
a124 8
	    GetAttr(LISTBROWSER_Selected,SLG_List[SLG_SiteList],&attr);
	    if (attr!=0) {
		if (attr==-1) attr=0;
		SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
			       LISTBROWSER_Selected,attr>0?attr-1:0,
			       LISTBROWSER_MakeVisible,attr>0?attr-1:0,
			       TAG_DONE);
		UpdateSLGGadgets(TRUE,0);
d126 1
a126 1
	    break;
d129 24
a152 1
		GetAttr(LISTBROWSER_Selected,SLG_List[SLG_SiteList],&attr);
d154 2
a155 2
			       LISTBROWSER_Selected,attr==-1?0:attr+1,
			       LISTBROWSER_MakeVisible,attr==-1?0:attr+1,
d157 2
a158 1
		UpdateSLGGadgets(TRUE,0);
d363 1
d454 1
a454 1
                     StartHGroup, Spacing(FALSE),
d482 1
a482 1
                     StartHGroup,
d533 9
a541 1

d563 16
d624 14
a637 6
	    if (sn->sn_SiteAddress) {
		free(sn->sn_SiteAddress);
		sn->sn_SiteAddress=NULL;
	    }
	    if (strlen(buf2))
	      sn->sn_SiteAddress=strdup(buf2);
d639 6
a644 6
	    if (sn->sn_RemoteDir) {
		free(sn->sn_RemoteDir);
		sn->sn_RemoteDir=NULL;
	    }
	    if (strlen(buf3))
	      sn->sn_RemoteDir=strdup(buf3);
d646 6
a651 6
	    if (sn->sn_LocalDir) {
		free(sn->sn_LocalDir);
		sn->sn_LocalDir=NULL;
	    }
	    if (strlen(buf4))
	      sn->sn_LocalDir=strdup(buf4);
d653 6
a658 6
	    if (sn->sn_LoginName) {
		free(sn->sn_LoginName);
		sn->sn_LoginName=NULL;
	    }
	    if (strlen(buf5))
	      sn->sn_LoginName=strdup(buf5);
d660 2
a661 6
	    if (sn->sn_Password) {
		free(sn->sn_Password);
		sn->sn_Password=NULL;
	    }
	    if (strlen(Original))
	      sn->sn_Password=strdup(RealString);
d663 2
a664 2
	    GetAttr(GA_Selected,ESG_List[ESG_Anonymous],&attr);
	    sn->sn_Anonymous=attr;
d666 10
a675 2
	    GetAttr(INTEGER_Number, ESG_List[ESG_Port], &attr);
	    sn->sn_Port=attr;
a680 5
	    GetAttr(GA_Selected, ESG_List[ESG_Proxy],&attr);
	    sn->sn_Proxy=attr;

	    GetAttr(CHOOSER_Active, ESG_List[ESG_LSType], &attr);
	    sn->sn_VMSDIR=attr;
d737 1
a737 1
    if (!OpenSiteWindow())
d788 14
a801 7
			if (ConnectMode) {
			    done=TRUE;
			    GetListBrowserNodeAttrs(node,LBNA_UserData,&retnode,TAG_DONE);
			}
			else {
			    EditClicked();
			}
d805 5
a809 2
			if (node)
			  UpdateSLGGadgets(TRUE,0);
d817 1
a817 20
		{
		    struct Node *node;
		    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&node);

		    if (node) {
			SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				       LISTBROWSER_Labels,~0,
				       TAG_DONE);
			Remove(node);
			AddHead(&SiteList,node);
			if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow, NULL,
				       LISTBROWSER_Labels,&SiteList,
				       LISTBROWSER_Selected,0,
				       LISTBROWSER_MakeVisible,0,
				       TAG_DONE))
			  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow, NULL,1);
			ConfigChanged=TRUE;
			HotListChanged=TRUE;
		    }
		}
d820 2
a821 23
		{
		    struct Node *node;
		    ULONG i;
		    for (i=0,node=GetHead(&SiteList);node;i++,node=GetSucc(node));

		    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&node);
		    if (node) {
			SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				       LISTBROWSER_Labels,~0,
				       TAG_DONE);
			Remove(node);
			AddTail(&SiteList,node);
			if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow, NULL,
				       LISTBROWSER_Labels,&SiteList,
				       LISTBROWSER_Selected,i>0?i-1:0,
				       LISTBROWSER_MakeVisible,i>0?i-1:0,
				       TAG_DONE))
			  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow, NULL,1);
			ConfigChanged=TRUE;
			HotListChanged=TRUE;
		    }
		    break;
		}
d823 2
a824 25
		{
		    struct Node *node,*pred;
		    ULONG i;
		    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&node);
		    GetAttr(LISTBROWSER_Selected,SLG_List[SLG_SiteList],&i);

		    if (node && (pred=GetPred(node))) {
			SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				       LISTBROWSER_Labels,~0,
				       TAG_DONE);
			pred=GetPred(pred);
			Remove(node);
			Insert(&SiteList,node,pred);
			if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow, NULL,
				       LISTBROWSER_Labels,&SiteList,
				       LISTBROWSER_Selected,i-1,
				       LISTBROWSER_MakeVisible,i-1,
				       TAG_DONE))
			  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow, NULL,1);
			ConfigChanged=TRUE;
			HotListChanged=TRUE;
		    }
		  
		    break;
		}
d826 3
a828 23
		{
		    struct Node *node,*succ;
		    ULONG i;
		    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&node);
		    GetAttr(LISTBROWSER_Selected,SLG_List[SLG_SiteList],&i);

		    if (node && (succ=GetSucc(node))) {
			SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				       LISTBROWSER_Labels,~0,
				       TAG_DONE);
			Remove(node);
			Insert(&SiteList,node,succ);
			if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow, NULL,
				       LISTBROWSER_Labels,&SiteList,
				       LISTBROWSER_Selected,i+1,
				       LISTBROWSER_MakeVisible,i+1,
				       TAG_DONE))
			  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow, NULL,1);
			ConfigChanged=TRUE;
			HotListChanged=TRUE;
		    }
		    break;
		}
d834 1
d864 5
a868 1
/*	      case SLG_SubItem:
a869 1
		    struct Node *node;
d871 25
a895 20
		    ULONG attr1,attr2;

		    GetAttr(LISTBROWSER_SelectedNode,SLG_List[SLG_SiteList],(ULONG *)&node);
		    GetAttr(CHOOSER_Active,SLG_List[SLG_SubItem],&attr1);
		    GetListBrowserNodeAttrs(node,LBNA_Generation,&attr2,LBNA_UserData,&sn,TAG_DONE);
		    if (attr2!=(attr1+1)) {
			SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow,NULL,
				       LISTBROWSER_Labels,~0,
				       TAG_DONE);
			SetListBrowserNodeAttrs(node,LBNA_Generation,attr2==1?2:1,TAG_DONE);
			sn->sn_SubItem=attr2==1?1:0;
			HotListChanged=TRUE;
			ConfigChanged=TRUE;
			if (SetGadgetAttrs(SLG_List[SLG_SiteList],SiteListWindow, NULL,
					   LISTBROWSER_Labels,&SiteList,
					   TAG_DONE))
			  RefreshGList(SLG_List[SLG_SiteList],SiteListWindow, NULL,1);
		    }
		}*/
		case SLG_Connect:
d902 6
a907 1
		    done=TRUE;
d922 1
a922 1
struct Window *OpenSiteWindow(void)
d926 1
a930 4
    gobjlist=ChooserLabelsA(subnames);
    if (!gobjlist)
      return NULL;

d958 1
a958 1
			   LISTBROWSER_Hierarchical,FALSE,
d974 6
d997 1
a997 1
                           StartHGroup, EvenSized, // 5
d1009 1
a1009 1
                               GA_Text, GetAmiFTPString(SLW_Cancel),
d1045 1
a1045 1

d1051 6
a1057 10
/*			     StartMember, SLG_List[SLG_SubItem]=ChooserObject,
			      CHOOSER_Labels,gobjlist,
			      CHOOSER_AutoFit,TRUE,
			      CHOOSER_PopUp,TRUE,
			      CHOOSER_Active,0,
			      GA_ID,SLG_SubItem,
			      GA_RelVerify,TRUE,
			      GA_Disabled,TRUE,
			      ChooserEnd,
			      CHILD_WeightedWidth,0,*/
d1067 6
d1125 474
a1598 3
    if (gobjlist)
      FreeChooserLabels(gobjlist);
    gobjlist=NULL;
d1614 1
d1637 1
a1637 1
	    UpdateSLGGadgets(TRUE,0);
d1659 31
a1689 15
	    /* fix this: (sn) should be a copy of sn */
	    LockWindow(SiteListWin_Object);
	    OpenEditWindow(sn);
	    UnlockWindow(SiteListWin_Object);
	    if (AddToSiteList) {
		SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			       LISTBROWSER_Labels,~0,
			       TAG_DONE);
		SetGadgetAttrs(SLG_List[SLG_SiteList], SiteListWindow, NULL,
			       LISTBROWSER_Labels,&SiteList,
			       LISTBROWSER_SelectedNode,lbn,
			       TAG_DONE);
		RefreshGList(SLG_List[SLG_SiteList], SiteListWindow, NULL, 1);
		ConfigChanged=TRUE;
		HotListChanged=TRUE;
d1700 1
d1710 1
d1719 20
a1738 2
	if (sn)
	  FreeSiteNode(sn);
d1747 1
a1747 1
void UpdateSLGGadgets(const ULONG selected, const int num)
d1751 2
a1752 3
    if (attr!=(!selected)) {

	if (SetGadgetAttrs(SLG_List[SLG_Edit], SiteListWindow, NULL, GA_Disabled, !selected))
d1754 1
a1754 1
	if (SetGadgetAttrs(SLG_List[SLG_Remove], SiteListWindow, NULL, GA_Disabled, !selected))
d1756 1
a1756 1
	if (SetGadgetAttrs(SLG_List[SLG_Top], SiteListWindow, NULL, GA_Disabled, !selected))
d1758 1
a1758 1
	if (SetGadgetAttrs(SLG_List[SLG_Up], SiteListWindow, NULL, GA_Disabled, !selected))
d1760 1
a1760 1
	if (SetGadgetAttrs(SLG_List[SLG_Down], SiteListWindow, NULL, GA_Disabled, !selected))
d1762 1
a1762 1
	if (SetGadgetAttrs(SLG_List[SLG_Bottom], SiteListWindow, NULL, GA_Disabled, !selected))
d1764 52
a1815 2
	if (SetGadgetAttrs(SLG_List[SLG_Connect], SiteListWindow, NULL, GA_Disabled, !selected))
	  RefreshGList(SLG_List[SLG_Connect], SiteListWindow, NULL,1);
a1816 2
/*    if (SetGadgetAttrs(SLG_List[SLG_SubItem],SiteListWindow,NULL,CHOOSER_Active,num,TAG_DONE))
      RefreshGList(SLG_List[SLG_SubItem],SiteListWindow,NULL,1);*/
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d19 1
d70 1
a70 1
void UpdateSLGGadgets(ULONG selected,int num);
d95 1
a95 1
		UpdateSLGGadgets(TRUE);
d105 1
a105 1
		UpdateSLGGadgets(TRUE);
d114 1
a114 1
    return (0);
d135 1
a135 1
		    return(TRUE);
d228 1
a228 1
	return(TRUE);
a238 2
    ULONG result;
    UWORD code=NULL;
d240 1
a240 1
      return(0);
d260 1
a260 1
    return (1);
d304 1
a304 1
    return (done);
d312 1
a312 1
      return (EditSiteWindow);
d316 1
a316 1
      return (NULL);
d499 1
a499 1
      return (NULL);
d522 1
a522 1
      return (NULL);
d525 1
a525 1
	return (EditSiteWindow);
d530 1
a530 1
    return (NULL);
d629 1
a629 1
      return(1);
d638 1
a638 1
    return(1);
d645 1
a645 1
struct SiteNode *OpenSiteListWindow(BOOL Connect)
d653 1
a653 1
      return (NULL);
d674 1
a674 11
    return (retnode);
}

static int strecmp(char *s1, char *s2)
{
	int n1, n2;

	if((n1 = strlen(s1)) == (n2 = strlen(s2)))
		return(strnicmp(s1, s2, n1));
	else
		return(n1 < n2 ? -1 : 1);
d681 1
a681 1
    return(stricmp((char *)nodea->ln_Name,(char *)nodeb->ln_Name));
a683 1

d716 1
a716 1
			  UpdateSLGGadgets(FALSE);
d831 1
a831 1
			      *arrayptr=(ULONG *)node;
d835 1
a835 1
			      AddTail(&SiteList,*arrayptr);
d842 1
a842 1
			    UpdateSLGGadgets(FALSE);
d892 1
a892 1
    return (done);
d902 1
a902 1
      return (SiteListWindow);
d906 1
a906 1
      return (NULL);
d1040 1
a1040 1
      return (NULL);
d1072 1
a1072 1
	return (NULL);
d1075 1
a1075 1
	return (SiteListWindow);
d1081 1
a1081 1
    return (NULL);
d1134 1
a1134 1
	    UpdateSLGGadgets(TRUE);
d1139 1
a1139 1
    return (1);
d1174 1
a1174 1
    return (1);
d1202 1
a1202 1
	UpdateSLGGadgets(FALSE);
d1205 1
a1205 1
    return (1);
d1208 1
a1208 1
void UpdateSLGGadgets(ULONG selected,int num)
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
@a1114 1
    APTR wlock;
d1124 1
a1124 1
	wlock=rtLockWindow(SiteListWindow);
d1126 1
a1126 1
	rtUnlockWindow(SiteListWindow,wlock);
a1157 1
    APTR wlock;
d1169 1
a1169 1
	    wlock=rtLockWindow(SiteListWindow);
d1171 1
a1171 1
	    rtUnlockWindow(SiteListWindow,wlock);
@


0.1343
log
@Removed some redudant things from AllocListbrowserNode()
Gadgets no longer flicker since I keep track of the state. Thought ClassAct did that, but no...
Added one tick to the fuelgauge, now 11 ticks => 10 intervals.
@
text
@d355 1
d502 1
a502 1
    LayoutLimits((struct Gadget *)EditSiteLayout,&limits,ScreenFont,Screen);
d922 1
d949 2
a950 2
                           CHILD_MinWidth,ScreenFont->tf_XSize*20,
                           CHILD_MinHeight,ScreenFont->tf_YSize*9,
d1054 1
a1054 1
    LayoutLimits((struct Gadget *)SiteListLayout,&limits,ScreenFont,Screen);
@


0.1332
log
@Release 1.0
AmiFTP doesn't need amigaguide.library in order to start.
@
text
@d939 2
a940 1
                         StartMember, SLG_List[SLG_SiteList]=ListBrowserObject,
d949 1
a949 1

@


0.1312
log
@Fixed NewClicked so it sets the new node as selected+makevisible
@
text
@d248 3
a250 1
	wait=Wait(esignal|ssignal|mainsignal|AG_Signal);
d661 3
a663 1
	wait=Wait(signal|AG_Signal);
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d147 1
a147 1
		Work -> Code = (WORD)'×';
d149 1
a149 1
		Work -> WorkBuffer[Work -> BufferPos - 1] = (UBYTE)'×';
d159 1
a159 1
		memset(Work -> WorkBuffer,'×',Len);
d343 1
a343 1
	memset(Original, '×', strlen(sn->sn_Password));
d1122 3
d1129 3
d1134 2
a1135 1
			   LISTBROWSER_SelectedNode,lbn,
d1137 1
a1137 1
	    /* Fix: MakeVisible... */
@


0.814
log
@Added default download-dir.
@
text
@a9 25
int SiteLV_clicked(void);
int SiteName_clicked(void);
int New_clicked(void);
int Remove_clicked(void);
int LocPath_clicked(void);
int Connect_scclicked(void);
int Cancel_clicked(void);
int OK_clicked(void);
int Edit_clicked(void);
int VMSDIR_clicked(void);
int LocPathString_clicked(void);
struct SiteNode *co_Connect(void);
void co_Remove(void);
void co_New(void);
void co_Edit(void);
int Anonymous_clicked(void);

enum {CO_SITELIST=0,CO_CONNECT,CO_NEW,CO_EDIT,CO_REMOVE,CO_CANCEL,CO_UP,
	CO_DOWN,CO_TOP,CO_BOTTOM,
	NumGadgets_co};

static struct Gadget *co_Gadgets[NumGadgets_co];

long co_lvord=-1;
BOOL ShowSites=FALSE;
a11 1
extern char www[];
d13 14
a26 13
struct NewGadget co_NewGadgets[] =
{
    {0,0,0,0,NULL,NULL,0,PLACETEXT_ABOVE,NULL,NULL}, /* FTP Sites */
    {0,0,0,0,NULL,NULL,7,PLACETEXT_IN,NULL,NULL},    /* Connect */
    {0,0,0,0,NULL,NULL,1,PLACETEXT_IN,NULL,NULL},    /* New */
    {0,0,0,0,NULL,NULL,3,PLACETEXT_IN,NULL,NULL},    /* Edit */
    {0,0,0,0,NULL,NULL,2,PLACETEXT_IN,NULL,NULL},    /* Remove */
    {0,0,0,0,NULL,NULL,8,PLACETEXT_IN,NULL,NULL},    /* Cancel */
    {0,0,0,0,NULL,NULL,10,PLACETEXT_IN,NULL,NULL},   /* Up */
    {0,0,0,0,NULL,NULL,10,PLACETEXT_IN,NULL,NULL},   /* Down */
    {0,0,0,0,NULL,NULL,10,PLACETEXT_IN,NULL,NULL},   /* Top */
    {0,0,0,0,NULL,NULL,10,PLACETEXT_IN,NULL,NULL}    /* Bottom */
};
d28 1
a28 1
LONG co_GadgetLabels[]=
d30 4
a33 11
    (LONG)SLW_SiteList,
    (LONG)SLW_Connect,
    (LONG)SLW_New,
    (LONG)SLW_Edit,
    (LONG)SLW_Remove,
    (LONG)SLW_Cancel,
    (LONG)SLW_Up,
    (LONG)SLW_Down,
    (LONG)SLW_Top,
    (LONG)SLW_Bottom,
    -1
d36 2
a37 13
static ULONG co_types[] =
{
    LISTVIEW_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND
};
d39 2
a40 42
static ULONG co_tags[] =
{
    /* Listview for sites */
    GTLV_ShowSelected,NULL,
    GTLV_Labels,NULL,
    GTLV_Top,NULL,
    GTLV_Selected,NULL,
    TAG_DONE,
    /* Connect-gadget */
    GT_Underscore,'_',
    TAG_END,
    /* New */
    GT_Underscore,'_',
    TAG_END,
    /* Edit */
    GA_Disabled,TRUE,
    GT_Underscore,'_',
    TAG_END,
    /* Remove */
    GA_Disabled,TRUE,
    GT_Underscore,'_',
    TAG_END,
    /* Cancel */
    GT_Underscore,'_',
    TAG_END,
    /* Up */
    GT_Underscore,'_',
    GA_Disabled,TRUE,
    TAG_END,
    /* Down */
    GT_Underscore,'_',
    GA_Disabled,TRUE,
    TAG_END,
    /* Top */
    GT_Underscore,'_',
    GA_Disabled,TRUE,
    TAG_END,
    /* Bottom */
    GT_Underscore,'_',
    GA_Disabled,TRUE,
    TAG_END
};
d42 1
d44 1
a44 2
static struct Gadget *co_glist;
struct Window *co_Win;
d46 3
a48 2
int Layout_co(struct Gadget **,struct Window *,BOOL);
void ComputeSize_co(UWORD *minwidth,UWORD *minheight);
d50 4
a53 2
enum {SC_ALIASNAME=0,SC_SITENAME,SC_PORT,SC_REMDIR,SC_LOCDIR,SC_LOCDIRGAD,SC_ANONYMOUS,SC_LOGINNAME,
	SC_PASSWORD,SC_OK,SC_CANCEL,SC_VMSDIR,SC_PROXYGAD,SC_HOTLISTGAD,NumGadgets_sc};
d55 1
a55 17
struct NewGadget sc_NewGadgets[]=
{
    {0,0,0,0,NULL,NULL,14,PLACETEXT_LEFT,NULL,NULL},                       /* Name */
    {0,0,0,0,NULL,NULL,10,PLACETEXT_LEFT,NULL,NULL},                       /* Site */
    {0,0,0,0,NULL,NULL,13,PLACETEXT_LEFT,NULL,NULL},                       /* Port */
    {0,0,0,0,NULL,NULL,3,PLACETEXT_LEFT,NULL,NULL},                        /* RemDir */
    {0,0,0,0,NULL,NULL,5,PLACETEXT_LEFT,NULL,(APTR)LocPathString_clicked}, /* Pathstring */
    {0,0,0,0,NULL,NULL,6,PLACETEXT_IN,NULL,(APTR)LocPath_clicked},         /* Download path */
    {0,0,0,0,NULL,NULL,54,PLACETEXT_LEFT,NULL,(APTR)Anonymous_clicked},/* Anonymous */
    {0,0,0,0,NULL,NULL,4,PLACETEXT_LEFT,NULL,NULL},                        /* Login name */
    {0,0,0,0,NULL,NULL,17,PLACETEXT_LEFT,NULL,NULL},                       /* Password */
    {0,0,0,0,NULL,NULL,9,PLACETEXT_IN,NULL,(APTR)OK_clicked},              /* OK */
    {0,0,0,0,NULL,NULL,8,PLACETEXT_IN,NULL,(APTR)Cancel_clicked},          /* Cancel */
    {0,0,26,11,NULL,NULL,12,PLACETEXT_LEFT,NULL,NULL},                     /* OS */
    {0,0,0,0,NULL,NULL,12,PLACETEXT_LEFT,NULL,NULL},                       /* Proxy */
    {0,0,0,0,NULL,NULL,15,PLACETEXT_LEFT,NULL,NULL}                        /* HotList */
};
d57 1
a57 18
LONG sc_GadgetLabels[]=
{
    (LONG)SCW_Name,
    (LONG)SCW_Site,
    (LONG)SCW_Port,
    (LONG)SCW_RemDir,
    NULL,
    (LONG)SCW_LocDir,
    (LONG)SCW_Anonymous,
    (LONG)SCW_LoginName,
    (LONG)SCW_Password,
    (LONG)SCW_OK,
    (LONG)SCW_Cancel,
    (LONG)SCW_OS,
    (LONG)SCW_Proxy,
    (LONG)SCW_HotList,
    -1
};
d59 1
a59 1
static ULONG sc_types[]=
d61 2
a62 20
    STRING_KIND,   /* Name */
    STRING_KIND,   /* Site-name */
    INTEGER_KIND,  /* Port */
    STRING_KIND,   /* Auto-cd */
    STRING_KIND,   /* loc-dir-string */
    BUTTON_KIND,   /* loc-dir-button */
    CHECKBOX_KIND, /* Anonymous */
    STRING_KIND,   /* Loginname */
    STRING_KIND,   /* Password */
    BUTTON_KIND,   /* OK */
    BUTTON_KIND,   /* CANCEL */
    CYCLE_KIND,    /* OS */
    CHECKBOX_KIND, /* Proxy */
    CHECKBOX_KIND  /* Hotlist */
  };

static STRPTR OSTYPES[]={
    "UNIX",
    "VMS",
    "DOS",
d65 1
a65 1
struct Hook EditHook;
d67 48
a114 71
static ULONG sc_tags[] = 
{
    /* sc_AliasName */
    GA_TabCycle,TRUE,
    GTST_MaxChars,50,
    GT_Underscore,'_',
    TAG_END,
    /* sc_SiteName */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    TAG_END,
    /* sc_Port */
    GTIN_Number,21,
    GTIN_MaxChars,6,
    GT_Underscore,'_',
    TAG_END,
    /* Auto-remote dir sc_defremdirgad */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    TAG_END,
    /* sc_DefLocDirGad */
    GA_TabCycle,TRUE,
    TAG_END,
    /* sc_DefLocPathGad */
    GT_Underscore,'_',
    TAG_END,
    /* Anonymous */
    GT_Underscore,'_',
    GTCB_Scaled,TRUE,
    TAG_END,
    /* Login name, sc_LoginName */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    TAG_END,
    /* Password */
    GA_TabCycle,TRUE,
    GTST_MaxChars,100,
    GT_Underscore,'_',
    GTST_EditHook,(ULONG)&EditHook,
    TAG_END,
    /* sc_OKGad */
    GT_Underscore,'_',
    TAG_END,
    /* sc_CancelGad */
    GT_Underscore,'_',
    TAG_END,
    /* sc_VMSDIR */
    GT_Underscore,'_',
    GTCY_Labels,(ULONG)OSTYPES,
    TAG_END,
    /* sc_ProxyGad */
    GT_Underscore,'_',
    GTCB_Scaled,TRUE,
    TAG_END,
    /* sc_HotListGad */
    GT_Underscore,'_',
    GTCB_Scaled,TRUE,
    TAG_END
};

static struct Gadget *sc_Gadgets[NumGadgets_sc];
static char sc_FastKeys[NumGadgets_sc+1];
static char co_FastKeys[NumGadgets_co+1];

struct Gadget *sc_glist;
struct Window *sc_Win;
char RealString[100];
char Original[100];
d121 1
a121 1
//    if(GETOBJECT(Work -> Gadget,Node)) {
d233 1
a233 1
void ComputeSize_sc(UWORD *minwidth,UWORD *minheight);
d235 7
a241 1
struct SiteNode *Curr_sn;
d243 17
a259 100
void ComputeSize_sc(UWORD *minwidth,UWORD *minheight)
{
    long n1,n2;
    char *pwx="×××××××××";
    n1=TextLength(PropRPort,www,20);
    n2=TextLength(PropRPort,pwx,9)+TextLength(PropRPort,www,7)+4*INTERWIDTH+GadgetTextLength(PropRPort,sc_NewGadgets[SC_LOGINNAME])+GadgetTextLength(PropRPort,sc_NewGadgets[SC_PASSWORD]);
    n1=max(n1,n2);
    sc_NewGadgets[SC_ALIASNAME].ng_Width=n1;
    sc_NewGadgets[SC_ALIASNAME].ng_Height=PropFHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_ALIASNAME].ng_TopEdge=INTERHEIGHT/2+INTERHEIGHT;
    sc_NewGadgets[SC_ALIASNAME].ng_LeftEdge=INTERWIDTH+GadgetTextLength(PropRPort,sc_NewGadgets[SC_ALIASNAME])+PropFHigh;

    sc_NewGadgets[SC_SITENAME].ng_Width=sc_NewGadgets[SC_ALIASNAME].ng_Width;
    sc_NewGadgets[SC_SITENAME].ng_Height=PropFHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_SITENAME].ng_TopEdge=sc_NewGadgets[SC_ALIASNAME].ng_TopEdge+sc_NewGadgets[SC_ALIASNAME].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_SITENAME].ng_LeftEdge=INTERWIDTH+GadgetTextLength(PropRPort,sc_NewGadgets[SC_SITENAME]);
    sc_NewGadgets[SC_SITENAME].ng_LeftEdge=max(sc_NewGadgets[SC_SITENAME].ng_LeftEdge,sc_NewGadgets[SC_ALIASNAME].ng_LeftEdge);
    sc_NewGadgets[SC_ALIASNAME].ng_LeftEdge=sc_NewGadgets[SC_SITENAME].ng_LeftEdge;

    sc_NewGadgets[SC_PORT].ng_Width=TextLength(PropRPort,www,7);
    sc_NewGadgets[SC_PORT].ng_Height=sc_NewGadgets[SC_SITENAME].ng_Height;
    sc_NewGadgets[SC_PORT].ng_TopEdge=sc_NewGadgets[SC_SITENAME].ng_TopEdge+sc_NewGadgets[SC_SITENAME].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_PORT].ng_LeftEdge=sc_NewGadgets[SC_SITENAME].ng_LeftEdge+sc_NewGadgets[SC_SITENAME].ng_Width-sc_NewGadgets[SC_PORT].ng_Width;

    sc_NewGadgets[SC_REMDIR].ng_Width=sc_NewGadgets[SC_SITENAME].ng_Width+sc_NewGadgets[SC_SITENAME].ng_LeftEdge-GadgetTextLength(PropRPort,sc_NewGadgets[SC_REMDIR])-PropFHigh-INTERWIDTH;
    sc_NewGadgets[SC_REMDIR].ng_Height=PropFHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_REMDIR].ng_TopEdge=sc_NewGadgets[SC_PORT].ng_TopEdge+sc_NewGadgets[SC_PORT].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_REMDIR].ng_LeftEdge=sc_NewGadgets[SC_SITENAME].ng_LeftEdge+sc_NewGadgets[SC_SITENAME].ng_Width-sc_NewGadgets[SC_REMDIR].ng_Width;

    sc_NewGadgets[SC_LOCDIRGAD].ng_Width=GadgetTextLength(PropRPort,sc_NewGadgets[SC_LOCDIRGAD])+INTERWIDTH;
    sc_NewGadgets[SC_LOCDIRGAD].ng_Height=PropFHigh+INTERHEIGHT*2;
    sc_NewGadgets[SC_LOCDIRGAD].ng_TopEdge=sc_NewGadgets[SC_REMDIR].ng_TopEdge+sc_NewGadgets[SC_REMDIR].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_LOCDIRGAD].ng_LeftEdge=INTERWIDTH;

    sc_NewGadgets[SC_LOCDIR].ng_Width=sc_NewGadgets[SC_SITENAME].ng_Width+sc_NewGadgets[SC_SITENAME].ng_LeftEdge-sc_NewGadgets[SC_LOCDIRGAD].ng_Width-2*INTERWIDTH;
    sc_NewGadgets[SC_LOCDIR].ng_Height=sc_NewGadgets[SC_LOCDIRGAD].ng_Height;
    sc_NewGadgets[SC_LOCDIR].ng_TopEdge=sc_NewGadgets[SC_LOCDIRGAD].ng_TopEdge;
    sc_NewGadgets[SC_LOCDIR].ng_LeftEdge=sc_NewGadgets[SC_LOCDIRGAD].ng_LeftEdge+sc_NewGadgets[SC_LOCDIRGAD].ng_Width+INTERWIDTH;

    sc_NewGadgets[SC_ANONYMOUS].ng_Height=PropFHigh+INTERHEIGHT;
    sc_NewGadgets[SC_ANONYMOUS].ng_Width=2*PropFHigh+INTERWIDTH;
    sc_NewGadgets[SC_ANONYMOUS].ng_TopEdge=sc_NewGadgets[SC_LOCDIR].ng_TopEdge+sc_NewGadgets[SC_LOCDIR].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_ANONYMOUS].ng_LeftEdge=sc_NewGadgets[SC_LOCDIR].ng_LeftEdge+sc_NewGadgets[SC_LOCDIR].ng_Width-sc_NewGadgets[SC_ANONYMOUS].ng_Width;

    sc_NewGadgets[SC_LOGINNAME].ng_Width=2*INTERWIDTH+TextLength(PropRPort,www,7);
    sc_NewGadgets[SC_LOGINNAME].ng_Height=sc_NewGadgets[SC_LOCDIR].ng_Height;
    sc_NewGadgets[SC_LOGINNAME].ng_TopEdge=sc_NewGadgets[SC_ANONYMOUS].ng_TopEdge+sc_NewGadgets[SC_ANONYMOUS].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_LOGINNAME].ng_LeftEdge=2*INTERWIDTH+GadgetTextLength(PropRPort,sc_NewGadgets[SC_LOGINNAME]);

    sc_NewGadgets[SC_PASSWORD].ng_Width=2*INTERWIDTH+TextLength(PropRPort,pwx,9);
    sc_NewGadgets[SC_PASSWORD].ng_Height=sc_NewGadgets[SC_LOCDIR].ng_Height;
    sc_NewGadgets[SC_PASSWORD].ng_TopEdge=sc_NewGadgets[SC_LOGINNAME].ng_TopEdge;
    sc_NewGadgets[SC_PASSWORD].ng_LeftEdge=sc_NewGadgets[SC_LOCDIR].ng_LeftEdge+sc_NewGadgets[SC_LOCDIR].ng_Width-sc_NewGadgets[SC_PASSWORD].ng_Width;

    sc_NewGadgets[SC_VMSDIR].ng_Height=PropFHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_VMSDIR].ng_Width=5*INTERWIDTH+TextLength(PropRPort,OSTYPES[REMOTE_OS_UNIX],strlen(OSTYPES[REMOTE_OS_UNIX]));
    sc_NewGadgets[SC_VMSDIR].ng_TopEdge=sc_NewGadgets[SC_PASSWORD].ng_TopEdge+sc_NewGadgets[SC_PASSWORD].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_VMSDIR].ng_LeftEdge=sc_NewGadgets[SC_PASSWORD].ng_LeftEdge+sc_NewGadgets[SC_PASSWORD].ng_Width-sc_NewGadgets[SC_VMSDIR].ng_Width;

    sc_NewGadgets[SC_HOTLISTGAD].ng_Height=PropFHigh+INTERHEIGHT;
    sc_NewGadgets[SC_HOTLISTGAD].ng_Width=2*PropFHigh+INTERWIDTH;
    sc_NewGadgets[SC_HOTLISTGAD].ng_TopEdge=sc_NewGadgets[SC_VMSDIR].ng_TopEdge+sc_NewGadgets[SC_VMSDIR].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_HOTLISTGAD].ng_LeftEdge=sc_NewGadgets[SC_PORT].ng_LeftEdge+sc_NewGadgets[SC_PORT].ng_Width-sc_NewGadgets[SC_HOTLISTGAD].ng_Width;

    sc_NewGadgets[SC_PROXYGAD].ng_Height=PropFHigh+INTERHEIGHT;
    sc_NewGadgets[SC_PROXYGAD].ng_Width=PropFHigh*2+INTERWIDTH;
    sc_NewGadgets[SC_PROXYGAD].ng_TopEdge=sc_NewGadgets[SC_HOTLISTGAD].ng_TopEdge;
    sc_NewGadgets[SC_PROXYGAD].ng_LeftEdge=sc_NewGadgets[SC_HOTLISTGAD].ng_LeftEdge-3*INTERWIDTH-GadgetTextLength(PropRPort,sc_NewGadgets[SC_HOTLISTGAD])-sc_NewGadgets[SC_PROXYGAD].ng_Width;//TextLength(RPort,sc_NewGadgets[SC_PROXYGAD].ng_GadgetText,strlen(sc_NewGadgets[SC_PROXYGAD].ng_GadgetText))+INTERWIDTH;

    sc_NewGadgets[SC_OK].ng_Width=GadgetTextLength(PropRPort,sc_NewGadgets[SC_CANCEL])+INTERWIDTH;
    sc_NewGadgets[SC_OK].ng_Height=PropFHigh+INTERHEIGHT*2;
    sc_NewGadgets[SC_OK].ng_TopEdge=sc_NewGadgets[SC_HOTLISTGAD].ng_TopEdge+sc_NewGadgets[SC_HOTLISTGAD].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_OK].ng_LeftEdge=INTERWIDTH;

    sc_NewGadgets[SC_CANCEL].ng_Width=sc_NewGadgets[SC_OK].ng_Width;
    sc_NewGadgets[SC_CANCEL].ng_Height=sc_NewGadgets[SC_OK].ng_Height;
    sc_NewGadgets[SC_CANCEL].ng_TopEdge=sc_NewGadgets[SC_OK].ng_TopEdge;
    sc_NewGadgets[SC_CANCEL].ng_LeftEdge=sc_NewGadgets[SC_SITENAME].ng_LeftEdge+sc_NewGadgets[SC_SITENAME].ng_Width-sc_NewGadgets[SC_CANCEL].ng_Width;

    *minwidth=INTERWIDTH+sc_NewGadgets[SC_SITENAME].ng_Width+sc_NewGadgets[SC_SITENAME].ng_LeftEdge;
    *minheight=sc_NewGadgets[SC_CANCEL].ng_TopEdge+sc_NewGadgets[SC_CANCEL].ng_Height+INTERHEIGHT/2;

    /* Set up fastkeys */
    sc_FastKeys[SC_SITENAME]  = FindVanillaKey(sc_NewGadgets[SC_SITENAME].ng_GadgetText);
    sc_FastKeys[SC_REMDIR]    = FindVanillaKey(sc_NewGadgets[SC_REMDIR].ng_GadgetText);
    sc_FastKeys[SC_LOCDIR]    = -1;
    sc_FastKeys[SC_LOCDIRGAD] = FindVanillaKey(sc_NewGadgets[SC_LOCDIRGAD].ng_GadgetText);
    sc_FastKeys[SC_LOGINNAME] = FindVanillaKey(sc_NewGadgets[SC_LOGINNAME].ng_GadgetText);
    sc_FastKeys[SC_PASSWORD]  = FindVanillaKey(sc_NewGadgets[SC_PASSWORD].ng_GadgetText);
    sc_FastKeys[SC_OK]        = FindVanillaKey(sc_NewGadgets[SC_OK].ng_GadgetText);
    sc_FastKeys[SC_ANONYMOUS] = FindVanillaKey(sc_NewGadgets[SC_ANONYMOUS].ng_GadgetText);
    sc_FastKeys[SC_CANCEL]    = FindVanillaKey(sc_NewGadgets[SC_CANCEL].ng_GadgetText);
    sc_FastKeys[SC_VMSDIR]    = FindVanillaKey(sc_NewGadgets[SC_VMSDIR].ng_GadgetText);
    sc_FastKeys[SC_PORT]      = FindVanillaKey(sc_NewGadgets[SC_PORT].ng_GadgetText);
    sc_FastKeys[SC_ALIASNAME] = FindVanillaKey(sc_NewGadgets[SC_ALIASNAME].ng_GadgetText);
    sc_FastKeys[SC_PROXYGAD]  = FindVanillaKey(sc_NewGadgets[SC_PROXYGAD].ng_GadgetText);
    sc_FastKeys[SC_HOTLISTGAD]= FindVanillaKey(sc_NewGadgets[SC_HOTLISTGAD].ng_GadgetText);
    for (n1=0;n1<NumGadgets_sc;n1++)
      if (!sc_FastKeys[n1])
	sc_FastKeys[n1]=-1;
d262 1
a262 1
int OpenSiteWindow(struct SiteNode *sn)
d264 2
a265 5
    UWORD Width,Height;
    struct Gadget *gad;
    struct IntuiMessage *imsg;
    BOOL Continue=TRUE;
    ULONG mask,winmask;
d267 10
a276 21
    memset(&EditHook,0,sizeof(EditHook));
    EditHook.h_Entry=(HOOKFUNC)PasswordHook;
    ComputeSize_sc(&Width,&Height);
    AddToSiteList=FALSE;
    Curr_sn=sn;
    sc_Win = OpenWindowTags(NULL,
//			    WA_AutoAdjust,FALSE,
			    WA_PubScreen,myScn,
			    WA_Top,mainWin->Height>Height?mainWin->TopEdge+(mainWin->Height-Height)/2:mainWin->TopEdge,
			    WA_Left,mainWin->Width?mainWin->LeftEdge+(mainWin->Width-Width-myScn->WBorLeft-myScn->WBorRight)/2:mainWin->LeftEdge,
			    WA_Width,Width+myScn->WBorLeft+myScn->WBorRight,
			    WA_InnerHeight,Height,
			    WA_MinWidth,Width+myScn->WBorLeft+myScn->WBorRight,
			    WA_MinHeight,Height+myScn->WBorTop+myScn->WBorBottom,
			    WA_Title,GetAmiFTPString(SCW_SiteConfigurationWindow),
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|IDCMP_VANILLAKEY|IDCMP_GADGETHELP|IDCMP_RAWKEY,
			    WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
			    TAG_DONE
			    );
    if (!sc_Win)
      return(1);
d278 24
a301 13
    SetFont(sc_Win->RPort,Propdfont);
    gad = CreateContext(&sc_glist);
    if (!gad) {
	StripIntuiMessages(sc_Win->UserPort,sc_Win);
	CloseWindow(sc_Win);
	return(2);
    }
//    if (!Layout_sc(&gad,sc_Win)) {
    if (!Layout(&gad,sc_Win,&sc_NewGadgets[0],&sc_tags[0],&sc_types[0],&sc_Gadgets[0],NumGadgets_sc)) {
	StripIntuiMessages(sc_Win->UserPort,sc_Win);
	CloseWindow(sc_Win);
	FreeGadgets(sc_glist);
	return(3);
d303 9
d313 3
a315 4
    AddGList(sc_Win,sc_glist,~0,-1,NULL);
    RefreshGList(sc_Win->FirstGadget,sc_Win,NULL,-1);
    GT_RefreshWindow(sc_Win,NULL);
    HelpControl(sc_Win,HC_GADGETHELP);
d317 1
d319 3
a321 3
      GT_SetGadgetAttrs(sc_Gadgets[SC_ALIASNAME],sc_Win,NULL,
			GTST_String,sn->sn_Node.ln_Name,
			TAG_END);
d323 3
a325 6
      GT_SetGadgetAttrs(sc_Gadgets[SC_SITENAME],sc_Win,NULL,
			GTST_String,sn->sn_SiteAddress,
			TAG_END);
    GT_SetGadgetAttrs(sc_Gadgets[SC_PORT],sc_Win,NULL,
		      GTIN_Number,sn->sn_Port,
		      TAG_END);
d327 3
a329 3
      GT_SetGadgetAttrs(sc_Gadgets[SC_REMDIR],sc_Win,NULL,
			GTST_String,sn->sn_RemoteDir,
			TAG_END);
d331 1
a331 3
      GT_SetGadgetAttrs(sc_Gadgets[SC_LOCDIR],sc_Win,NULL,
			GTST_String,sn->sn_LocalDir,
			TAG_END);
d333 3
a335 7
      GT_SetGadgetAttrs(sc_Gadgets[SC_LOCDIR],sc_Win,NULL,
			GTST_String,MainPrefs.mp_LocalDir,
			TAG_END);
    GT_SetGadgetAttrs(sc_Gadgets[SC_ANONYMOUS],sc_Win,NULL<
		      GTCB_Checked,sn->sn_Anonymous,
		      TAG_END);

d337 3
a339 3
      GT_SetGadgetAttrs(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL,
			GTST_String,sn->sn_LoginName,
			TAG_END);
d343 2
a344 4
	memset(Original,'×',strlen(sn->sn_Password));
	GT_SetGadgetAttrs(sc_Gadgets[SC_PASSWORD],sc_Win,NULL,
			  GTST_String,Original,
			  TAG_END);
d348 176
a523 10
    if (sn->sn_Anonymous) {
	GT_SetGadgetAttrs(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL,
			  GA_Disabled,TRUE,
			  TAG_END);
	GT_SetGadgetAttrs(sc_Gadgets[SC_PASSWORD],sc_Win,NULL,
			  GA_Disabled,TRUE,
			  TAG_END);
	GT_SetGadgetAttrs(sc_Gadgets[SC_ANONYMOUS],sc_Win,NULL,
			  GTCB_Checked,TRUE,
			  TAG_END);
d525 25
a549 9
    GT_SetGadgetAttrs(sc_Gadgets[SC_VMSDIR],sc_Win,NULL,
		      GTCY_Active,sn->sn_VMSDIR,
		      TAG_END);
    GT_SetGadgetAttrs(sc_Gadgets[SC_PROXYGAD],sc_Win,NULL,
		      GTCB_Checked,sn->sn_Proxy,
		      TAG_END);
    GT_SetGadgetAttrs(sc_Gadgets[SC_HOTLISTGAD],sc_Win,NULL,
		      GTCB_Checked,sn->sn_HotList,
		      TAG_END);
d551 13
a563 1
    winmask=1<<sc_Win->UserPort->mp_SigBit;
d565 6
a570 2
    while (Continue) {
	mask=Wait(winmask|AG_Signal);
d572 3
a574 98
	if (mask&AG_Signal)
	  HandleAmigaGuide();
	if (mask&winmask) {
	    while (imsg=GT_GetIMsg(sc_Win->UserPort)) {
		int (*func)();
		struct IntuiMessage sc_Msg;
		ULONG MsgClass;
		UWORD Code;
		MsgClass = imsg->Class;
		Code     = imsg->Code;
		CopyMem(imsg,&sc_Msg,sizeof(sc_Msg));
		GT_ReplyIMsg(imsg);

		switch(MsgClass) {
		  case IDCMP_CLOSEWINDOW:
		    Continue=FALSE;
		    break;
		  case IDCMP_REFRESHWINDOW:
		    GT_BeginRefresh(sc_Win);
		    GT_EndRefresh(sc_Win,TRUE);
		    break;
		  case IDCMP_GADGETHELP:
		    ag.ag_region=-1;
		    if (sc_Msg.IAddress==(APTR)sc_Win) {
			ag.ag_region=0;
		    }
		    break;
		  case IDCMP_RAWKEY:
		    if (sc_Msg.Code==95) {
			SendAGMessage(AG_SITECONF);
		    }
		    break;
		  case IDCMP_GADGETUP:
		  case IDCMP_GADGETDOWN:
		    if ( ((struct Gadget *)sc_Msg.IAddress)->UserData) {
			func = (void *)((struct Gadget *)sc_Msg.IAddress)->UserData;
			Continue=func();
		    }
		    break;
		  case IDCMP_VANILLAKEY:
		    {
			ULONG num;
			num=MatchVanillaKey(sc_Msg.Code,sc_FastKeys);
			if (num!=-1) {
			    if (num==SC_SITENAME)
			      ActivateGadget(sc_Gadgets[SC_SITENAME],sc_Win,NULL);
			    else if (num==SC_LOGINNAME)
			      ActivateGadget(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL);
			    else if (num==SC_PASSWORD)
			      ActivateGadget(sc_Gadgets[SC_PASSWORD],sc_Win,NULL);
			    else if (num==SC_REMDIR)
			      ActivateGadget(sc_Gadgets[SC_REMDIR],sc_Win,NULL);
			    else if (num==SC_VMSDIR) {
				int res;
				if (GT_GetGadgetAttrs(sc_Gadgets[SC_VMSDIR],sc_Win,NULL,
						      GTCY_Active,&res,TAG_DONE))
				  GT_SetGadgetAttrs(sc_Gadgets[SC_VMSDIR],sc_Win,NULL,
						    GTCY_Active,res==2?0:res+1,TAG_DONE);
			    }
			    else if (num==SC_PORT)
			      ActivateGadget(sc_Gadgets[SC_PORT],sc_Win,NULL);
			    else if (num==SC_ALIASNAME)
			      ActivateGadget(sc_Gadgets[SC_ALIASNAME],sc_Win,NULL);
			    else if (num==SC_PROXYGAD) {
				int res;
				if (GT_GetGadgetAttrs(sc_Gadgets[SC_PROXYGAD],sc_Win,NULL,
						      GTCB_Checked,&res,TAG_DONE))
				  GT_SetGadgetAttrs(sc_Gadgets[SC_PROXYGAD],sc_Win,NULL,
						    GTCB_Checked,res?0:1,TAG_DONE);
			    }
			    else if (num==SC_ANONYMOUS) {
				int res;
				if (GT_GetGadgetAttrs(sc_Gadgets[SC_ANONYMOUS],sc_Win,NULL,
						      GTCB_Checked,&res,TAG_DONE)) {
				    GT_SetGadgetAttrs(sc_Gadgets[SC_PASSWORD],sc_Win,NULL,
						      GA_Disabled,res,TAG_DONE);
				    GT_SetGadgetAttrs(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL,
						      GA_Disabled,res,TAG_DONE);
				}
			    }
			    else if (num==SC_HOTLISTGAD) {
				int res;
				if (GT_GetGadgetAttrs(sc_Gadgets[SC_HOTLISTGAD],sc_Win,NULL,
						      GTCB_Checked,&res,TAG_DONE))
				  GT_SetGadgetAttrs(sc_Gadgets[SC_HOTLISTGAD],sc_Win,NULL,
						    GTCB_Checked,res?0:1,TAG_DONE);
			    }
			    else {
				func = (void *)sc_Gadgets[num]->UserData;
				if ((ULONG)func)
				  Continue=func();
			    }
			}
		    }
		    break;
		  default:
		    break;
		}
d576 18
d595 4
d600 2
a601 4
    StripIntuiMessages(sc_Win->UserPort,sc_Win);
    CloseWindow(sc_Win);
    FreeGadgets(sc_glist);
    return(0);
d619 2
a620 2
    tags[1]=(unsigned long)sc_Win;
    tags[7]=(unsigned long)GetString(sc_Gadgets[SC_LOCDIR]);
d622 2
a623 2
    tags[15]=mainWin->LeftEdge;
    tags[17]=mainWin->TopEdge;
d629 4
a632 1
	GT_SetGadgetAttrs(sc_Gadgets[SC_LOCDIR],sc_Win,NULL,GTST_String,DirRequester->rf_Dir,TAG_END);
d638 4
d643 1
a643 1
int Anonymous_clicked(void)
d645 4
a648 10
    int res;
    if (GT_GetGadgetAttrs(sc_Gadgets[SC_ANONYMOUS],sc_Win,NULL,
			  GTCB_Checked,&res,TAG_DONE)) {
	GT_SetGadgetAttrs(sc_Gadgets[SC_PASSWORD],sc_Win,NULL,
			  GA_Disabled,res,TAG_DONE);
	GT_SetGadgetAttrs(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL,
			  GA_Disabled,res,TAG_DONE);
    }
    return (1);
}
d650 2
a651 4
int LocPathString_clicked(void)
{
    return(1);
}
d653 1
a653 3
int OK_clicked(void)
{
    AddToSiteList=TRUE;
d655 11
a665 3
    if (Curr_sn->sn_Node.ln_Name) {
	free(Curr_sn->sn_Node.ln_Name);
	Curr_sn->sn_Node.ln_Name=NULL;
d667 4
a670 79
    if (strlen(GetString(sc_Gadgets[SC_ALIASNAME]))) {
	Curr_sn->sn_Node.ln_Name=strdup(GetString(sc_Gadgets[SC_ALIASNAME]));
    }
    if (Curr_sn->sn_SiteAddress) {
	free(Curr_sn->sn_SiteAddress);
	Curr_sn->sn_SiteAddress=NULL;
    }
    if (strlen(GetString(sc_Gadgets[SC_SITENAME]))) {
	Curr_sn->sn_SiteAddress=strdup(GetString(sc_Gadgets[SC_SITENAME]));
    }
    Curr_sn->sn_Port=GetNumber(sc_Gadgets[SC_PORT]);
    if (Curr_sn->sn_RemoteDir) {
	free(Curr_sn->sn_RemoteDir);
	Curr_sn->sn_RemoteDir=NULL;
    }
    if (strlen(GetString(sc_Gadgets[SC_REMDIR]))) {
	Curr_sn->sn_RemoteDir=strdup(GetString(sc_Gadgets[SC_REMDIR]));
    }
    if (Curr_sn->sn_LocalDir) {
	free(Curr_sn->sn_LocalDir);
	Curr_sn->sn_LocalDir=NULL;
    }
    if (strlen(GetString(sc_Gadgets[SC_LOCDIR]))) {
	if (MainPrefs.mp_LocalDir) {
	    if (strcmp(GetString(sc_Gadgets[SC_LOCDIR]),MainPrefs.mp_LocalDir)==0 &&
		strlen(GetString(sc_Gadgets[SC_LOCDIR]))==strlen(MainPrefs.mp_LocalDir))
	      Curr_sn->sn_LocalDir=NULL;
	}
	else
	  Curr_sn->sn_LocalDir=strdup(GetString(sc_Gadgets[SC_LOCDIR]));
    }
    if (Curr_sn->sn_LoginName) {
	free(Curr_sn->sn_LoginName);
	Curr_sn->sn_LoginName=NULL;
    }
    if (strlen(GetString(sc_Gadgets[SC_LOGINNAME]))) {
	Curr_sn->sn_LoginName=strdup(GetString(sc_Gadgets[SC_LOGINNAME]));
    }
    if (Curr_sn->sn_Password) {
	free(Curr_sn->sn_Password);
	Curr_sn->sn_Password=NULL;
    }
    if (strlen(GetString(sc_Gadgets[SC_PASSWORD]))) {
	Curr_sn->sn_Password=strdup(RealString);
    }
    if (Curr_sn->sn_DirString) {
	free(Curr_sn->sn_DirString);
	Curr_sn->sn_DirString=NULL;
    }
    {
	long res;
	if (GT_GetGadgetAttrs(sc_Gadgets[SC_PROXYGAD],sc_Win,NULL,
			   GTCB_Checked,&res,
			   TAG_DONE))
	  Curr_sn->sn_Proxy=res;
	if (GT_GetGadgetAttrs(sc_Gadgets[SC_HOTLISTGAD],sc_Win,NULL,
			      GTCB_Checked,&res)) {
	    if (res!=Curr_sn->sn_HotList) {
		HotListChanged=TRUE;
		Curr_sn->sn_HotList=res;
	    }
	}
	if (GT_GetGadgetAttrs(sc_Gadgets[SC_ANONYMOUS],sc_Win,NULL,
			      GTCB_Checked,&res)) {
	    Curr_sn->sn_Anonymous=res;
	}
    }
    {
	/* This code is only valid for V39+ */
	long result;
	long checked;
	ULONG tags[]={GTCY_Active,NULL,TAG_DONE};
	tags[1]=(unsigned long)&checked;
	result=GT_GetGadgetAttrsA(sc_Gadgets[SC_VMSDIR],sc_Win,NULL,
				 (struct TagItem *)tags);
	if (result==1)
	  Curr_sn->sn_VMSDIR=checked;
    }
    return(0);
d673 1
a673 1
int Cancel_clicked(void)
d675 6
a680 2
    AddToSiteList=FALSE;
    return(0);
d683 1
a683 1
void ComputeSize_co(UWORD *minwidth,UWORD *minheight)
d685 3
a687 103
    UWORD n1,n2;

    n1=GadgetTextLength(PropRPort,co_NewGadgets[CO_REMOVE]);
    n2=GadgetTextLength(PropRPort,co_NewGadgets[CO_CONNECT]);
    n1=max(n1,n2);
    n2=GadgetTextLength(PropRPort,co_NewGadgets[CO_CANCEL]);
    n1=max(n1,n2);
    n2=GadgetTextLength(PropRPort,co_NewGadgets[CO_EDIT]);
    n1=max(n1,n2);
    n2=GadgetTextLength(PropRPort,co_NewGadgets[CO_NEW]);
    n1=max(n1,n2)+INTERWIDTH;

    n2=TextLength(PropRPort,www,25)+2*PropFHigh;
    n2=max(3*n1+INTERWIDTH*3,n2);
    co_NewGadgets[CO_SITELIST].ng_Width=n2;
    n2=max(PropFHigh*9+INTERHEIGHT,4*PropFHigh+11*INTERHEIGHT);
    co_NewGadgets[CO_SITELIST].ng_Height=(((n2-INTERHEIGHT)/PropFHigh)+1)*PropFHigh+INTERHEIGHT;
    co_NewGadgets[CO_SITELIST].ng_TopEdge=PropFHigh+INTERHEIGHT+INTERHEIGHT/2;
    co_NewGadgets[CO_SITELIST].ng_LeftEdge=INTERWIDTH;
    co_NewGadgets[CO_SITELIST].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_SITELIST].ng_TextAttr=PropFont;

    co_NewGadgets[CO_TOP].ng_Width=INTERWIDTH+GadgetTextLength(PropRPort,co_NewGadgets[CO_BOTTOM]);
    co_NewGadgets[CO_TOP].ng_Height=PropFHigh+2*INTERHEIGHT;
    co_NewGadgets[CO_TOP].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge+co_NewGadgets[CO_SITELIST].ng_Width+INTERWIDTH;
    co_NewGadgets[CO_TOP].ng_TopEdge=co_NewGadgets[CO_SITELIST].ng_TopEdge;
    co_NewGadgets[CO_TOP].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_TOP].ng_TextAttr=PropFont;

    co_NewGadgets[CO_UP].ng_Width=co_NewGadgets[CO_TOP].ng_Width;
    co_NewGadgets[CO_UP].ng_Height=co_NewGadgets[CO_TOP].ng_Height;
    co_NewGadgets[CO_UP].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge+co_NewGadgets[CO_SITELIST].ng_Width+INTERWIDTH;
    co_NewGadgets[CO_UP].ng_TopEdge=co_NewGadgets[CO_TOP].ng_TopEdge+co_NewGadgets[CO_TOP].ng_Height+INTERHEIGHT;
    co_NewGadgets[CO_UP].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_UP].ng_TextAttr=PropFont;

    co_NewGadgets[CO_DOWN].ng_Width=co_NewGadgets[CO_TOP].ng_Width;
    co_NewGadgets[CO_DOWN].ng_Height=co_NewGadgets[CO_TOP].ng_Height;
    co_NewGadgets[CO_DOWN].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge+co_NewGadgets[CO_SITELIST].ng_Width+INTERWIDTH;
    co_NewGadgets[CO_DOWN].ng_TopEdge=co_NewGadgets[CO_UP].ng_TopEdge+co_NewGadgets[CO_UP].ng_Height+INTERHEIGHT;
    co_NewGadgets[CO_DOWN].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_DOWN].ng_TextAttr=PropFont;

    co_NewGadgets[CO_BOTTOM].ng_Width=co_NewGadgets[CO_TOP].ng_Width;
    co_NewGadgets[CO_BOTTOM].ng_Height=co_NewGadgets[CO_TOP].ng_Height;
    co_NewGadgets[CO_BOTTOM].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge+co_NewGadgets[CO_SITELIST].ng_Width+INTERWIDTH;
    co_NewGadgets[CO_BOTTOM].ng_TopEdge=co_NewGadgets[CO_DOWN].ng_TopEdge+co_NewGadgets[CO_DOWN].ng_Height+INTERHEIGHT;
    co_NewGadgets[CO_BOTTOM].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_BOTTOM].ng_TextAttr=PropFont;

    co_NewGadgets[CO_NEW].ng_Width=n1;
    co_NewGadgets[CO_NEW].ng_Height=PropFHigh+INTERHEIGHT*2;
    co_NewGadgets[CO_NEW].ng_TopEdge=co_NewGadgets[CO_SITELIST].ng_TopEdge+co_NewGadgets[CO_SITELIST].ng_Height+INTERHEIGHT;
    co_NewGadgets[CO_NEW].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge;
    co_NewGadgets[CO_NEW].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_NEW].ng_TextAttr=PropFont;

    co_NewGadgets[CO_EDIT].ng_Width=co_NewGadgets[CO_NEW].ng_Width;
    co_NewGadgets[CO_EDIT].ng_Height=co_NewGadgets[CO_NEW].ng_Height;
    co_NewGadgets[CO_EDIT].ng_TopEdge=co_NewGadgets[CO_NEW].ng_TopEdge;
    co_NewGadgets[CO_EDIT].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_EDIT].ng_TextAttr=PropFont;

    co_NewGadgets[CO_REMOVE].ng_Width=co_NewGadgets[CO_NEW].ng_Width;
    co_NewGadgets[CO_REMOVE].ng_Height=co_NewGadgets[CO_NEW].ng_Height;
    co_NewGadgets[CO_REMOVE].ng_TopEdge=co_NewGadgets[CO_NEW].ng_TopEdge;
    co_NewGadgets[CO_REMOVE].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge+co_NewGadgets[CO_SITELIST].ng_Width-co_NewGadgets[CO_REMOVE].ng_Width;
    co_NewGadgets[CO_REMOVE].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_REMOVE].ng_TextAttr=PropFont;
    co_NewGadgets[CO_EDIT].ng_LeftEdge=co_NewGadgets[CO_NEW].ng_LeftEdge+co_NewGadgets[CO_NEW].ng_Width+(co_NewGadgets[CO_REMOVE].ng_LeftEdge-co_NewGadgets[CO_NEW].ng_LeftEdge-co_NewGadgets[CO_NEW].ng_Width)/2-co_NewGadgets[CO_EDIT].ng_Width/2;


    co_NewGadgets[CO_CONNECT].ng_Width=n1;
    co_NewGadgets[CO_CONNECT].ng_Height=PropFHigh+INTERHEIGHT*2;
    co_NewGadgets[CO_CONNECT].ng_TopEdge=co_NewGadgets[CO_NEW].ng_TopEdge+co_NewGadgets[CO_NEW].ng_Height+INTERHEIGHT;
    co_NewGadgets[CO_CONNECT].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge;
    co_NewGadgets[CO_CONNECT].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_CONNECT].ng_TextAttr=PropFont;

    co_NewGadgets[CO_CANCEL].ng_Width=co_NewGadgets[CO_CONNECT].ng_Width;
    co_NewGadgets[CO_CANCEL].ng_Height=co_NewGadgets[CO_CONNECT].ng_Height;
    co_NewGadgets[CO_CANCEL].ng_TopEdge=co_NewGadgets[CO_CONNECT].ng_TopEdge;
    co_NewGadgets[CO_CANCEL].ng_LeftEdge=co_NewGadgets[CO_SITELIST].ng_LeftEdge+co_NewGadgets[CO_SITELIST].ng_Width-co_NewGadgets[CO_CANCEL].ng_Width;
    co_NewGadgets[CO_CANCEL].ng_VisualInfo=myVisualInfo;
    co_NewGadgets[CO_CANCEL].ng_TextAttr=PropFont;

/*    co_OKGad.ng_Width=co_ConnectGad.ng_Width;
    co_OKGad.ng_Height=co_ConnectGad.ng_Height;
    co_OKGad.ng_TopEdge=co_ConnectGad.ng_TopEdge;
    co_OKGad.ng_LeftEdge=co_ConnectGad.ng_LeftEdge;
    co_OKGad.ng_VisualInfo=myVisualInfo;
    co_OKGad.ng_TextAttr=PropFont;*/
    *minwidth=INTERWIDTH + co_NewGadgets[CO_TOP].ng_LeftEdge+co_NewGadgets[CO_TOP].ng_Width;
    *minheight=co_NewGadgets[CO_CANCEL].ng_TopEdge+co_NewGadgets[CO_CANCEL].ng_Height+INTERHEIGHT/2;
    co_FastKeys[CO_CONNECT] = FindVanillaKey(co_NewGadgets[CO_CONNECT].ng_GadgetText);
    co_FastKeys[CO_NEW] = FindVanillaKey(co_NewGadgets[CO_NEW].ng_GadgetText);
    co_FastKeys[CO_EDIT] = FindVanillaKey(co_NewGadgets[CO_EDIT].ng_GadgetText);
    co_FastKeys[CO_REMOVE] = FindVanillaKey(co_NewGadgets[CO_REMOVE].ng_GadgetText);
    co_FastKeys[CO_CANCEL] = FindVanillaKey(co_NewGadgets[CO_CANCEL].ng_GadgetText);
    co_FastKeys[CO_SITELIST] = -1;
    for (n1=0;n1<NumGadgets_co;n1++)
      if (!co_FastKeys[n1])
	co_FastKeys[n1]=-1;
a689 79
int Layout_co(struct Gadget **gadg, struct Window *window, BOOL Connect)
{
    if (!Connect)
      co_NewGadgets[CO_CONNECT].ng_LeftEdge=co_NewGadgets[CO_EDIT].ng_LeftEdge;
    co_NewGadgets[CO_SITELIST].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_SITELIST].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_TOP].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_TOP].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_UP].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_UP].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_DOWN].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_DOWN].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_BOTTOM].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_BOTTOM].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_NEW].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_NEW].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_EDIT].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_EDIT].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_REMOVE].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_REMOVE].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_CONNECT].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_CONNECT].ng_LeftEdge+=window->BorderLeft;
    co_NewGadgets[CO_CANCEL].ng_TopEdge+=window->BorderTop;
    co_NewGadgets[CO_CANCEL].ng_LeftEdge+=window->BorderLeft;

    if (!(co_Gadgets[CO_SITELIST] = *gadg = CreateGadget(LISTVIEW_KIND,*gadg,&co_NewGadgets[CO_SITELIST],
							 GTLV_ShowSelected,NULL,
							 GTLV_Labels,GetHead(&SiteList)?&SiteList:NULL,
							 V39?GTLV_MakeVisible:GTLV_Top,co_lvord,
							 GTLV_Selected,co_lvord,
							 GTLV_ScrollWidth,max(16,PropFHigh+PropFHigh/2),
							 TAG_DONE)))
      return(FALSE);
    if (!(co_Gadgets[CO_TOP] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_TOP],
						    GA_Disabled,co_lvord==-1?TRUE:FALSE,
						    TAG_END)))
      return(FALSE);
    if (!(co_Gadgets[CO_UP] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_UP],
						    GA_Disabled,co_lvord==-1?TRUE:FALSE,
						    TAG_END)))
      return(FALSE);
    if (!(co_Gadgets[CO_DOWN] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_DOWN],
						    GA_Disabled,co_lvord==-1?TRUE:FALSE,
						    TAG_END)))
      return(FALSE);
    if (!(co_Gadgets[CO_BOTTOM] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_BOTTOM],
						    GA_Disabled,co_lvord==-1?TRUE:FALSE,
						    TAG_END)))
      return(FALSE);

    if (!(co_Gadgets[CO_NEW] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_NEW],
					      GT_Underscore,'_',
					      TAG_END)))
      return(FALSE);
    if (!(co_Gadgets[CO_EDIT] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_EDIT],
						     GA_Disabled,co_lvord==-1?TRUE:FALSE,
						     GT_Underscore,'_',
						     TAG_END)))
      return(FALSE);
    if (!(co_Gadgets[CO_REMOVE] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_REMOVE],
						       GA_Disabled,co_lvord==-1?TRUE:FALSE,
						       GT_Underscore,'_',
						       TAG_END)))
      return(FALSE);
    if (!(co_Gadgets[CO_CONNECT] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_CONNECT],
							GA_Disabled,Connect?co_lvord==-1?TRUE:FALSE:FALSE,
							GT_Underscore,'_',
							TAG_END)))
      return(FALSE);
    if (Connect)
      if (!(co_Gadgets[CO_CANCEL] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_CANCEL],
							 GT_Underscore,'_',
							 TAG_END)))
	return(FALSE);
    return(TRUE);

}
struct IntuiMessage co_Msg;
static BOOL Connectf=FALSE;
d691 1
a691 1
struct SiteNode *OpenSiteListWindow(BOOL Connect)
d693 1
a693 15
    UWORD Width,Height;
    struct Gadget *gad;
    struct IntuiMessage *imsg;
    BOOL Continue=TRUE;
    struct SiteNode *curr_site=NULL;
    ULONG ssecs=0,smics=0;
    ULONG winmask,mask;

    Connectf=Connect;
    if (Connect)
      co_NewGadgets[CO_CONNECT].ng_GadgetText=GetAmiFTPString(SLW_Connect);
    else
      co_NewGadgets[CO_CONNECT].ng_GadgetText=GetAmiFTPString(SLW_OK);
    ComputeSize_co(&Width,&Height);
    HotListChanged=FALSE;
d695 18
a712 88
    co_Win = OpenWindowTags(NULL,
//			    WA_AutoAdjust,FALSE,
			    WA_PubScreen,myScn,
			    WA_Top,mainWin->Height>Height?mainWin->TopEdge+(mainWin->Height-Height)/2:mainWin->TopEdge,
			    WA_Left,mainWin->Width?mainWin->LeftEdge+(mainWin->Width-Width-myScn->WBorLeft-myScn->WBorRight)/2:mainWin->LeftEdge,
			    WA_Width,Width+myScn->WBorLeft+myScn->WBorRight,
			    WA_InnerHeight,Height,
			    WA_MinWidth,Width+myScn->WBorLeft+myScn->WBorRight,
			    WA_MinHeight,Height+myScn->WBorTop+myScn->WBorBottom,
			    WA_Title,GetAmiFTPString(SLW_SiteListWindow),
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|LISTVIEWIDCMP|IDCMP_VANILLAKEY|IDCMP_GADGETHELP|IDCMP_RAWKEY,
			    WA_Flags,WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
			    TAG_DONE
			    );
    if (!co_Win)
      return(0);

    SetFont(co_Win->RPort,Propdfont);
    gad = CreateContext(&co_glist);
    if (!gad) {
	CloseWindow(co_Win);
	return(0);
    }
    if (!Layout_co(&gad,co_Win,Connect)) {
	CloseWindow(co_Win);
	FreeGadgets(co_glist);
	return(0);
    }

    AddGList(co_Win,co_glist,~0,-1,NULL);
    RefreshGList(co_Win->FirstGadget,co_Win,NULL,-1);
    GT_RefreshWindow(co_Win,NULL);
    HelpControl(co_Win,HC_GADGETHELP);
    winmask=1<<co_Win->UserPort->mp_SigBit;

    while (Continue) {
	mask=Wait(winmask|AG_Signal);
	if (mask&AG_Signal)
	  HandleAmigaGuide();
	if (mask&winmask) {
	    while (imsg=GT_GetIMsg(co_Win->UserPort)) {
		int (*func)();
		
		ULONG MsgClass;
		UWORD Code;
		MsgClass = imsg->Class;
		Code     = imsg->Code;
		CopyMem(imsg,&co_Msg,sizeof(co_Msg));
		GT_ReplyIMsg(imsg);

		switch(MsgClass) {
		  case IDCMP_CLOSEWINDOW:
		    curr_site=NULL;
		    Continue=FALSE;
		    break;
		  case IDCMP_REFRESHWINDOW:
		    GT_BeginRefresh(co_Win);
		    GT_EndRefresh(co_Win,TRUE);
		    break;
		  case IDCMP_GADGETHELP:
		    ag.ag_region=-1;
		    if (co_Msg.IAddress==(APTR)co_Win) {
			ag.ag_region=0;
		    }
		    break;
		  case IDCMP_RAWKEY:
		    if (co_Msg.Code==95) {
			SendAGMessage(AG_SITELIST);
		    }
		    break;
		  case IDCMP_GADGETUP:
		  case IDCMP_GADGETDOWN:
		    if ( co_Msg.IAddress==co_Gadgets[CO_SITELIST] ) {
			if ( (co_lvord == co_Msg.Code) && (DoubleClick(ssecs,smics,co_Msg.Seconds,co_Msg.Micros))) {
			    long i;
			    struct SiteNode *sn;

			    if (co_lvord!=-1) {
				for (sn=(struct SiteNode *)GetHead(&SiteList),i=0;sn;sn=(struct SiteNode *)GetSucc((struct Node *)sn),i++)
				  if (i>=co_lvord) break;
				curr_site=sn;
			    }
			    else
			      curr_site=NULL;
			    if (Connect)
			      Continue=FALSE;
			    else
			      co_Edit();
d715 1
a715 8
			    GT_SetGadgetAttrs(co_Gadgets[CO_EDIT],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			    GT_SetGadgetAttrs(co_Gadgets[CO_REMOVE],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			    GT_SetGadgetAttrs(co_Gadgets[CO_CONNECT],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			    GT_SetGadgetAttrs(co_Gadgets[CO_TOP],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			    GT_SetGadgetAttrs(co_Gadgets[CO_UP],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			    GT_SetGadgetAttrs(co_Gadgets[CO_DOWN],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			    GT_SetGadgetAttrs(co_Gadgets[CO_BOTTOM],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);

a716 6
			co_lvord=co_Msg.Code;
			ssecs=co_Msg.Seconds;
			smics=co_Msg.Micros;
		    } 
		    else if (co_Msg.IAddress == co_Gadgets[CO_NEW] ) {
			co_New();
d718 6
a723 2
		    else if (co_Msg.IAddress == co_Gadgets[CO_EDIT] && co_lvord != -1) {
			co_Edit();
d725 22
a746 2
		    else if (co_Msg.IAddress == co_Gadgets[CO_REMOVE] && co_lvord!=-1) {
			co_Remove();
d748 23
a770 3
		    else if (co_Msg.IAddress == co_Gadgets[CO_CONNECT]) {
			curr_site=co_Connect();
			Continue=FALSE;
d772 24
a795 3
		    else if (co_Msg.IAddress == co_Gadgets[CO_CANCEL]) {
			curr_site=NULL;
			Continue=FALSE;
d797 24
a820 13
		    else if (co_Msg.IAddress == co_Gadgets[CO_TOP] && co_lvord!=-1) {
			struct Node *ctmp;
			long i;
			for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
			  if (i>=co_lvord) break;
			if (ctmp) {
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			    Remove(ctmp);
			    AddHead(&SiteList,ctmp);
			    co_lvord=0;
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			    ConfigChanged=TRUE;
			}
d822 29
a850 13
		    else if (co_Msg.IAddress == co_Gadgets[CO_BOTTOM] && co_lvord!=-1) {
			struct Node *ctmp;
			long i;
			for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
			  if (i>=co_lvord) break;
			if (ctmp) {
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			    Remove(ctmp);
			    AddTail(&SiteList,ctmp);
			    ctmp=GetHead(&SiteList);
			    for (i=0;ctmp;i++) ctmp=GetSucc(ctmp);
			    co_lvord=--i;
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
d852 1
d855 24
a878 30
		    else if (co_Msg.IAddress == co_Gadgets[CO_UP]) {
			struct Node *pred;
			struct Node *ctmp;
			long i;
			for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
			  if (i>=co_lvord) break;
			if (ctmp && (pred=GetPred(ctmp))) {
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			    pred=GetPred(pred);
			    Remove(ctmp);
			    Insert(&SiteList,ctmp,pred);
			    co_lvord--;
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			    ConfigChanged=TRUE;
			}
		    }
		    else if (co_Msg.IAddress == co_Gadgets[CO_DOWN]) {
			struct Node *succ;
			struct Node *ctmp;
			long i;
			for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
			  if (i>=co_lvord) break;
			if (ctmp && (succ=GetSucc(ctmp))) {
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			    Remove(ctmp);
			    Insert(&SiteList,ctmp,succ);
			    co_lvord++;
			    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			    ConfigChanged=TRUE;
			}
d880 9
a888 24
		    break;
		  case IDCMP_VANILLAKEY:
		    {
			ULONG num;
			num=MatchVanillaKey(co_Msg.Code,co_FastKeys);
			if (num!=-1) {
			    if (num==CO_EDIT && co_lvord!=-1)
			      co_Edit();
			    else if (num==CO_REMOVE && co_lvord!=-1)
			      co_Remove();
			    else if (num==CO_NEW)
			      co_New();
			    else if (num==CO_CANCEL) {
				curr_site=NULL;
				Continue=FALSE;
			    }
			    else if (num==CO_CONNECT && co_lvord!=-1) {
				curr_site=co_Connect();
				Continue=FALSE;
			    }
			}
		    }
		    break;
		  default:
d891 4
d896 1
d899 203
a1101 6
    CloseWindow(co_Win);
    FreeGadgets(co_glist);
    if (HotListChanged)
      MenuNeedsUpdate=TRUE;
    HotListChanged=FALSE;
    return(curr_site);
d1104 1
a1104 1
void co_New()
d1107 6
a1112 1
    sn=AllocMem(sizeof(struct SiteNode),MEMF_PUBLIC|MEMF_CLEAR);
d1118 3
a1120 1
	OpenSiteWindow(sn);
d1122 9
a1130 4
	    AddTail(&SiteList,sn);
	    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,-1,TAG_DONE);
	    co_lvord=-1;
d1132 3
a1134 7
	    GT_SetGadgetAttrs(co_Gadgets[CO_EDIT],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_REMOVE],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_CONNECT],co_Win,NULL,GA_Disabled,Connectf?TRUE:FALSE,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_TOP],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_UP],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_DOWN],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_BOTTOM],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
d1138 1
a1138 2
    if (DEBUG)
      PrintSiteList();
d1141 1
a1141 1
void co_Edit()
d1143 1
d1145 27
a1171 9
    long i;
    for (sn=(struct SiteNode *)SiteList.lh_Head,i=0;sn;sn=(struct SiteNode *)sn->sn_Node.ln_Succ,i++)
      if (i>=co_lvord) break;
    if (sn) {
	OpenSiteWindow(sn);
	if (AddToSiteList) {
	    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
	    GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,V39?GTLV_MakeVisible:GTLV_Top,co_lvord,TAG_DONE);
	    ConfigChanged=TRUE;
a1172 2
	if (DEBUG)
	PrintSiteList();
d1174 1
d1177 1
a1177 1
void co_Remove()
d1179 1
a1180 1
    long i;
d1182 3
a1184 2
    for(sn=(struct SiteNode *)GetHead(&SiteList),i=0;sn;sn=(struct SiteNode *)GetSucc((struct Node *)sn),i++)
      if (i>=co_lvord) break;
d1186 14
a1199 6
    if (sn) {
	Remove(sn);
	FreeSiteNode(sn);
	GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,-1,TAG_DONE);
	co_lvord=-1;
d1201 3
a1203 9
	GT_SetGadgetAttrs(co_Gadgets[CO_EDIT],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_REMOVE],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_CONNECT],co_Win,NULL,GA_Disabled,Connectf?TRUE:FALSE,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_TOP],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_UP],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_DOWN],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	GT_SetGadgetAttrs(co_Gadgets[CO_BOTTOM],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
	if (DEBUG)
	  PrintSiteList();
d1205 1
a1205 1

d1208 1
a1208 1
struct SiteNode *co_Connect()
d1210 3
a1212 2
    long i;
    struct SiteNode *sn;
d1214 14
a1227 4
    if (co_lvord!=-1) {
	for (sn=(struct SiteNode *)GetHead(&SiteList),i=0;sn;sn=(struct SiteNode *)GetSucc((struct Node *)sn),i++)
	  if (i>=co_lvord) break;
	return(sn);
d1229 2
a1230 1
    return(NULL);
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d562 4
d797 9
a805 2
    if (strlen(GetString(sc_Gadgets[SC_LOCDIR])))
      Curr_sn->sn_LocalDir=strdup(GetString(sc_Gadgets[SC_LOCDIR]));
@


0.753
log
@Improved fastkeys-handling.
@
text
@d499 1
d516 1
a516 1
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|IDCMP_VANILLAKEY,
d541 1
d600 3
d604 1
a604 1
	WaitPort(sc_Win->UserPort);
d606 91
a696 64
	while (imsg=GT_GetIMsg(sc_Win->UserPort)) {
	    int (*func)();
	    struct IntuiMessage sc_Msg;
	    ULONG MsgClass;
	    UWORD Code;
	    MsgClass = imsg->Class;
	    Code     = imsg->Code;
	    CopyMem(imsg,&sc_Msg,sizeof(sc_Msg));
	    GT_ReplyIMsg(imsg);

	    switch(MsgClass) {
	      case IDCMP_CLOSEWINDOW:
		Continue=FALSE;
		break;
	      case IDCMP_REFRESHWINDOW:
		GT_BeginRefresh(sc_Win);
		GT_EndRefresh(sc_Win,TRUE);
		break;
	      case IDCMP_GADGETUP:
	      case IDCMP_GADGETDOWN:
		if ( ((struct Gadget *)sc_Msg.IAddress)->UserData) {
		    func = (void *)((struct Gadget *)sc_Msg.IAddress)->UserData;
		    Continue=func();
		}
		break;
	      case IDCMP_VANILLAKEY:
		{
		    ULONG num;
		    num=MatchVanillaKey(sc_Msg.Code,sc_FastKeys);
		    if (num!=-1) {
			if (num==SC_SITENAME)
			  ActivateGadget(sc_Gadgets[SC_SITENAME],sc_Win,NULL);
			else if (num==SC_LOGINNAME)
			  ActivateGadget(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL);
			else if (num==SC_PASSWORD)
			  ActivateGadget(sc_Gadgets[SC_PASSWORD],sc_Win,NULL);
			else if (num==SC_REMDIR)
			  ActivateGadget(sc_Gadgets[SC_REMDIR],sc_Win,NULL);
			else if (num==SC_VMSDIR) {
			    int res;
			    if (GT_GetGadgetAttrs(sc_Gadgets[SC_VMSDIR],sc_Win,NULL,
						  GTCY_Active,&res,TAG_DONE))
			      GT_SetGadgetAttrs(sc_Gadgets[SC_VMSDIR],sc_Win,NULL,
						GTCY_Active,res==2?0:res+1,TAG_DONE);
			}
			else if (num==SC_PORT)
			  ActivateGadget(sc_Gadgets[SC_PORT],sc_Win,NULL);
			else if (num==SC_ALIASNAME)
			  ActivateGadget(sc_Gadgets[SC_ALIASNAME],sc_Win,NULL);
			else if (num==SC_PROXYGAD) {
			    int res;
			    if (GT_GetGadgetAttrs(sc_Gadgets[SC_PROXYGAD],sc_Win,NULL,
						  GTCB_Checked,&res,TAG_DONE))
			      GT_SetGadgetAttrs(sc_Gadgets[SC_PROXYGAD],sc_Win,NULL,
						GTCB_Checked,res?0:1,TAG_DONE);
			}
			else if (num==SC_ANONYMOUS) {
			    int res;
			    if (GT_GetGadgetAttrs(sc_Gadgets[SC_ANONYMOUS],sc_Win,NULL,
						  GTCB_Checked,&res,TAG_DONE)) {
				GT_SetGadgetAttrs(sc_Gadgets[SC_PASSWORD],sc_Win,NULL,
						  GA_Disabled,res,TAG_DONE);
				GT_SetGadgetAttrs(sc_Gadgets[SC_LOGINNAME],sc_Win,NULL,
						  GA_Disabled,res,TAG_DONE);
a698 12
			else if (num==SC_HOTLISTGAD) {
			    int res;
			    if (GT_GetGadgetAttrs(sc_Gadgets[SC_HOTLISTGAD],sc_Win,NULL,
						  GTCB_Checked,&res,TAG_DONE))
			      GT_SetGadgetAttrs(sc_Gadgets[SC_HOTLISTGAD],sc_Win,NULL,
						GTCB_Checked,res?0:1,TAG_DONE);
			}
			else {
			    func = (void *)sc_Gadgets[num]->UserData;
			    if ((ULONG)func)
			      Continue=func();
			}
d700 3
a703 3
		break;
	      default:
		break;
d1046 2
d1066 1
a1066 1
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|LISTVIEWIDCMP|IDCMP_VANILLAKEY,
d1088 2
d1092 13
a1104 1
	WaitPort(co_Win->UserPort);
d1106 47
a1152 2
	while (imsg=GT_GetIMsg(co_Win->UserPort)) {
	    int (*func)();
d1154 24
a1177 20
	    ULONG MsgClass;
	    UWORD Code;
	    MsgClass = imsg->Class;
	    Code     = imsg->Code;
	    CopyMem(imsg,&co_Msg,sizeof(co_Msg));
	    GT_ReplyIMsg(imsg);

	    switch(MsgClass) {
	      case IDCMP_CLOSEWINDOW:
		curr_site=NULL;
		Continue=FALSE;
		break;
	      case IDCMP_REFRESHWINDOW:
		GT_BeginRefresh(co_Win);
		GT_EndRefresh(co_Win,TRUE);
		break;
	      case IDCMP_GADGETUP:
	      case IDCMP_GADGETDOWN:
		if ( co_Msg.IAddress==co_Gadgets[CO_SITELIST] ) {
		    if ( (co_lvord == co_Msg.Code) && (DoubleClick(ssecs,smics,co_Msg.Seconds,co_Msg.Micros))) {
d1179 9
a1187 6
			struct SiteNode *sn;

			if (co_lvord!=-1) {
			    for (sn=(struct SiteNode *)GetHead(&SiteList),i=0;sn;sn=(struct SiteNode *)GetSucc((struct Node *)sn),i++)
			      if (i>=co_lvord) break;
			    curr_site=sn;
a1188 50
			else
			  curr_site=NULL;
			if (Connect)
			  Continue=FALSE;
			else
			  co_Edit();
		    }
		    else {
			GT_SetGadgetAttrs(co_Gadgets[CO_EDIT],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			GT_SetGadgetAttrs(co_Gadgets[CO_REMOVE],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			GT_SetGadgetAttrs(co_Gadgets[CO_CONNECT],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			GT_SetGadgetAttrs(co_Gadgets[CO_TOP],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			GT_SetGadgetAttrs(co_Gadgets[CO_UP],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			GT_SetGadgetAttrs(co_Gadgets[CO_DOWN],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);
			GT_SetGadgetAttrs(co_Gadgets[CO_BOTTOM],co_Win,NULL,GA_Disabled,FALSE,NULL,TAG_DONE);

		    }
		    co_lvord=co_Msg.Code;
		    ssecs=co_Msg.Seconds;
		    smics=co_Msg.Micros;
		} 
		else if (co_Msg.IAddress == co_Gadgets[CO_NEW] ) {
		    co_New();
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_EDIT] && co_lvord != -1) {
		    co_Edit();
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_REMOVE] && co_lvord!=-1) {
		    co_Remove();
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_CONNECT]) {
		    curr_site=co_Connect();
		    Continue=FALSE;
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_CANCEL]) {
		    curr_site=NULL;
		    Continue=FALSE;
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_TOP] && co_lvord!=-1) {
		    struct Node *ctmp;
		    long i;
		    for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
		      if (i>=co_lvord) break;
		    if (ctmp) {
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			Remove(ctmp);
			AddHead(&SiteList,ctmp);
			co_lvord=0;
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			ConfigChanged=TRUE;
d1190 15
a1204 15
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_BOTTOM] && co_lvord!=-1) {
		    struct Node *ctmp;
		    long i;
		    for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
		      if (i>=co_lvord) break;
		    if (ctmp) {
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			Remove(ctmp);
			AddTail(&SiteList,ctmp);
			ctmp=GetHead(&SiteList);
			for (i=0;ctmp;i++) ctmp=GetSucc(ctmp);
			co_lvord=--i;
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			ConfigChanged=TRUE;
d1206 15
a1220 15
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_UP]) {
		    struct Node *pred;
		    struct Node *ctmp;
		    long i;
		    for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
		      if (i>=co_lvord) break;
		    if (ctmp && (pred=GetPred(ctmp))) {
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			pred=GetPred(pred);
			Remove(ctmp);
			Insert(&SiteList,ctmp,pred);
			co_lvord--;
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			ConfigChanged=TRUE;
d1222 14
a1235 14
		}
		else if (co_Msg.IAddress == co_Gadgets[CO_DOWN]) {
		    struct Node *succ;
		    struct Node *ctmp;
		    long i;
		    for (ctmp=GetHead(&SiteList),i=0;ctmp;ctmp=GetSucc(ctmp),i++)
		      if (i>=co_lvord) break;
		    if (ctmp && (succ=GetSucc(ctmp))) {
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,NULL,TAG_DONE);
			Remove(ctmp);
			Insert(&SiteList,ctmp,succ);
			co_lvord++;
			GT_SetGadgetAttrs(co_Gadgets[CO_SITELIST],co_Win,NULL,GTLV_Labels,&SiteList,GTLV_Selected,co_lvord,TAG_DONE);
			ConfigChanged=TRUE;
d1237 20
a1256 20
		}
		break;
	      case IDCMP_VANILLAKEY:
		{
		    ULONG num;
		    num=MatchVanillaKey(co_Msg.Code,co_FastKeys);
		    if (num!=-1) {
			if (num==CO_EDIT && co_lvord!=-1)
			  co_Edit();
			else if (num==CO_REMOVE && co_lvord!=-1)
			  co_Remove();
			else if (num==CO_NEW)
			  co_New();
			else if (num==CO_CANCEL) {
			    curr_site=NULL;
			    Continue=FALSE;
			}
			else if (num==CO_CONNECT && co_lvord!=-1) {
			    curr_site=co_Connect();
			    Continue=FALSE;
d1259 3
a1262 3
		break;
	      default:
		break;
@


0.588
log
@The GUI now handles proportional fonts. Only the main listview is fixed font.
@
text
@d488 3
d933 3
@


0.567
log
@Fixed busy loop caused by badly timed SetMenuStrip() (In the NextSelect-loop)
@
text
@d394 3
a396 2
    n1=TextLength(RPort,www,40);
    n2=2*(TextLength(RPort,www,9)+2*INTERWIDTH)+GadgetTextLength(RPort,sc_NewGadgets[SC_LOGINNAME])+GadgetTextLength(RPort,sc_NewGadgets[SC_PASSWORD]);
d399 1
a399 1
    sc_NewGadgets[SC_ALIASNAME].ng_Height=FHigh+2*INTERHEIGHT;
d401 1
a401 1
    sc_NewGadgets[SC_ALIASNAME].ng_LeftEdge=INTERWIDTH+GadgetTextLength(RPort,sc_NewGadgets[SC_ALIASNAME])+FHigh;
d404 1
a404 1
    sc_NewGadgets[SC_SITENAME].ng_Height=FHigh+2*INTERHEIGHT;
d406 1
a406 1
    sc_NewGadgets[SC_SITENAME].ng_LeftEdge=INTERWIDTH+GadgetTextLength(RPort,sc_NewGadgets[SC_SITENAME]);
d410 1
a410 1
    sc_NewGadgets[SC_PORT].ng_Width=TextLength(RPort,www,7);
d415 2
a416 2
    sc_NewGadgets[SC_REMDIR].ng_Width=sc_NewGadgets[SC_SITENAME].ng_Width+sc_NewGadgets[SC_SITENAME].ng_LeftEdge-GadgetTextLength(RPort,sc_NewGadgets[SC_REMDIR])-FHigh-INTERWIDTH;
    sc_NewGadgets[SC_REMDIR].ng_Height=FHigh+2*INTERHEIGHT;
d420 2
a421 2
    sc_NewGadgets[SC_LOCDIRGAD].ng_Width=GadgetTextLength(RPort,sc_NewGadgets[SC_LOCDIRGAD])+INTERWIDTH;
    sc_NewGadgets[SC_LOCDIRGAD].ng_Height=FHigh+INTERHEIGHT*2;
d430 2
a431 2
    sc_NewGadgets[SC_ANONYMOUS].ng_Height=FHigh+INTERHEIGHT;
    sc_NewGadgets[SC_ANONYMOUS].ng_Width=2*FHigh+INTERWIDTH;
d435 1
a435 1
    sc_NewGadgets[SC_LOGINNAME].ng_Width=2*INTERWIDTH+TextLength(RPort,www,9);
d438 1
a438 1
    sc_NewGadgets[SC_LOGINNAME].ng_LeftEdge=2*INTERWIDTH+GadgetTextLength(RPort,sc_NewGadgets[SC_LOGINNAME]);
d440 1
a440 1
    sc_NewGadgets[SC_PASSWORD].ng_Width=2*INTERWIDTH+TextLength(RPort,www,9);
d445 2
a446 2
    sc_NewGadgets[SC_VMSDIR].ng_Height=FHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_VMSDIR].ng_Width=5*INTERWIDTH+TextLength(RPort,OSTYPES[REMOTE_OS_UNIX],strlen(OSTYPES[REMOTE_OS_UNIX]));
d450 2
a451 2
    sc_NewGadgets[SC_HOTLISTGAD].ng_Height=FHigh+INTERHEIGHT;
    sc_NewGadgets[SC_HOTLISTGAD].ng_Width=2*FHigh+INTERWIDTH;
d455 2
a456 2
    sc_NewGadgets[SC_PROXYGAD].ng_Height=FHigh+INTERHEIGHT;
    sc_NewGadgets[SC_PROXYGAD].ng_Width=FHigh*2+INTERWIDTH;
d458 1
a458 1
    sc_NewGadgets[SC_PROXYGAD].ng_LeftEdge=sc_NewGadgets[SC_HOTLISTGAD].ng_LeftEdge-3*INTERWIDTH-GadgetTextLength(RPort,sc_NewGadgets[SC_HOTLISTGAD])-sc_NewGadgets[SC_PROXYGAD].ng_Width;//TextLength(RPort,sc_NewGadgets[SC_PROXYGAD].ng_GadgetText,strlen(sc_NewGadgets[SC_PROXYGAD].ng_GadgetText))+INTERWIDTH;
d460 2
a461 2
    sc_NewGadgets[SC_OK].ng_Width=GadgetTextLength(RPort,sc_NewGadgets[SC_CANCEL])+INTERWIDTH;
    sc_NewGadgets[SC_OK].ng_Height=FHigh+INTERHEIGHT*2;
d503 1
a503 1
			    WA_AutoAdjust,FALSE,
d509 2
d519 1
a519 1
    SetFont(sc_Win->RPort,dfont);
d832 2
a833 2
    n1=GadgetTextLength(RPort,co_NewGadgets[CO_REMOVE]);
    n2=GadgetTextLength(RPort,co_NewGadgets[CO_CONNECT]);
d835 1
a835 1
    n2=GadgetTextLength(RPort,co_NewGadgets[CO_CANCEL]);
d837 1
a837 1
    n2=GadgetTextLength(RPort,co_NewGadgets[CO_EDIT]);
d839 1
a839 1
    n2=GadgetTextLength(RPort,co_NewGadgets[CO_NEW]);
d842 1
a842 1
    n2=TextLength(RPort,www,40)+2*FHigh;
d845 3
a847 3
    n2=max(FHigh*9+INTERHEIGHT,4*FHigh+11*INTERHEIGHT);
    co_NewGadgets[CO_SITELIST].ng_Height=(((n2-INTERHEIGHT)/FHigh)+1)*FHigh+INTERHEIGHT;
    co_NewGadgets[CO_SITELIST].ng_TopEdge=FHigh+INTERHEIGHT+INTERHEIGHT/2;
d850 1
a850 1
    co_NewGadgets[CO_SITELIST].ng_TextAttr=Font;
d852 2
a853 2
    co_NewGadgets[CO_TOP].ng_Width=INTERWIDTH+GadgetTextLength(RPort,co_NewGadgets[CO_BOTTOM]);
    co_NewGadgets[CO_TOP].ng_Height=FHigh+2*INTERHEIGHT;
d857 1
a857 1
    co_NewGadgets[CO_TOP].ng_TextAttr=Font;
d864 1
a864 1
    co_NewGadgets[CO_UP].ng_TextAttr=Font;
d871 1
a871 1
    co_NewGadgets[CO_DOWN].ng_TextAttr=Font;
d878 1
a878 1
    co_NewGadgets[CO_BOTTOM].ng_TextAttr=Font;
d881 1
a881 1
    co_NewGadgets[CO_NEW].ng_Height=FHigh+INTERHEIGHT*2;
d885 1
a885 1
    co_NewGadgets[CO_NEW].ng_TextAttr=Font;
d891 1
a891 1
    co_NewGadgets[CO_EDIT].ng_TextAttr=Font;
d898 1
a898 1
    co_NewGadgets[CO_REMOVE].ng_TextAttr=Font;
d903 1
a903 1
    co_NewGadgets[CO_CONNECT].ng_Height=FHigh+INTERHEIGHT*2;
d907 1
a907 1
    co_NewGadgets[CO_CONNECT].ng_TextAttr=Font;
d914 1
a914 1
    co_NewGadgets[CO_CANCEL].ng_TextAttr=Font;
d921 1
a921 1
    co_OKGad.ng_TextAttr=Font;*/
d962 1
a962 1
							 GTLV_ScrollWidth,2*FHigh,
d1029 1
a1029 1
			    WA_AutoAdjust,FALSE,
d1035 2
d1045 1
a1045 1
    SetFont(co_Win->RPort,dfont);
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d1220 1
a1220 1
      UpdateMenus();
@


0.544
log
@Added gadstrlen() and macro GadgetTextLength() to compute correct strings with _ in labels.
Checks if CTRL-C has been hit before opening window.
@
text
@d414 1
a414 1
    sc_NewGadgets[SC_REMDIR].ng_Width=sc_NewGadgets[SC_SITENAME].ng_Width+sc_NewGadgets[SC_SITENAME].ng_LeftEdge-GadgetTextLength(RPort,sc_NewGadgets[SC_REMDIR])-FHigh;
@


0.534
log
@Anonymous flag on per default
@
text
@d395 1
a395 1
    n2=2*(TextLength(RPort,www,9)+2*INTERWIDTH)+TextLength(RPort,sc_NewGadgets[SC_LOGINNAME].ng_GadgetText,strlen(sc_NewGadgets[SC_LOGINNAME].ng_GadgetText))+TextLength(RPort,sc_NewGadgets[SC_PASSWORD].ng_GadgetText,strlen(sc_NewGadgets[SC_PASSWORD].ng_GadgetText));
d400 1
a400 1
    sc_NewGadgets[SC_ALIASNAME].ng_LeftEdge=INTERWIDTH+TextLength(RPort,sc_NewGadgets[SC_ALIASNAME].ng_GadgetText,strlen(sc_NewGadgets[SC_ALIASNAME].ng_GadgetText))+FHigh;
d405 1
a405 1
    sc_NewGadgets[SC_SITENAME].ng_LeftEdge=INTERWIDTH+TextLength(RPort,sc_NewGadgets[SC_SITENAME].ng_GadgetText,strlen(sc_NewGadgets[SC_SITENAME].ng_GadgetText));
d414 1
a414 1
    sc_NewGadgets[SC_REMDIR].ng_Width=sc_NewGadgets[SC_SITENAME].ng_Width+sc_NewGadgets[SC_SITENAME].ng_LeftEdge-TextLength(RPort,sc_NewGadgets[SC_REMDIR].ng_GadgetText,strlen(sc_NewGadgets[SC_REMDIR].ng_GadgetText))-FHigh;
d419 1
a419 1
    sc_NewGadgets[SC_LOCDIRGAD].ng_Width=TextLength(RPort,sc_NewGadgets[SC_LOCDIRGAD].ng_GadgetText,strlen(sc_NewGadgets[SC_LOCDIRGAD].ng_GadgetText))+INTERWIDTH;
d437 1
a437 1
    sc_NewGadgets[SC_LOGINNAME].ng_LeftEdge=2*INTERWIDTH+TextLength(RPort,sc_NewGadgets[SC_LOGINNAME].ng_GadgetText,strlen(sc_NewGadgets[SC_LOGINNAME].ng_GadgetText));
d457 1
a457 1
    sc_NewGadgets[SC_PROXYGAD].ng_LeftEdge=sc_NewGadgets[SC_HOTLISTGAD].ng_LeftEdge-3*INTERWIDTH-TextLength(RPort,sc_NewGadgets[SC_HOTLISTGAD].ng_GadgetText,strlen(sc_NewGadgets[SC_HOTLISTGAD].ng_GadgetText))-sc_NewGadgets[SC_PROXYGAD].ng_Width;//TextLength(RPort,sc_NewGadgets[SC_PROXYGAD].ng_GadgetText,strlen(sc_NewGadgets[SC_PROXYGAD].ng_GadgetText))+INTERWIDTH;
d459 1
a459 1
    sc_NewGadgets[SC_OK].ng_Width=TextLength(RPort,sc_NewGadgets[SC_CANCEL].ng_GadgetText,strlen(sc_NewGadgets[SC_CANCEL].ng_GadgetText))+INTERWIDTH;
d829 2
a830 2
    n1=TextLength(RPort,co_NewGadgets[CO_REMOVE].ng_GadgetText,strlen(co_NewGadgets[CO_REMOVE].ng_GadgetText));
    n2=TextLength(RPort,co_NewGadgets[CO_CONNECT].ng_GadgetText,strlen(co_NewGadgets[CO_CONNECT].ng_GadgetText));
d832 1
a832 1
    n2=TextLength(RPort,co_NewGadgets[CO_CANCEL].ng_GadgetText,strlen(co_NewGadgets[CO_CANCEL].ng_GadgetText));
d834 1
a834 1
    n2=TextLength(RPort,co_NewGadgets[CO_EDIT].ng_GadgetText,strlen(co_NewGadgets[CO_EDIT].ng_GadgetText));
d836 1
a836 1
    n2=TextLength(RPort,co_NewGadgets[CO_NEW].ng_GadgetText,strlen(co_NewGadgets[CO_NEW].ng_GadgetText));
d849 1
a849 1
    co_NewGadgets[CO_TOP].ng_Width=INTERWIDTH+TextLength(RPort,co_NewGadgets[CO_BOTTOM].ng_GadgetText,strlen(co_NewGadgets[CO_BOTTOM].ng_GadgetText));
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d1233 1
@


0.425
log
@Add Settingsmenu with Load/Save settings.
Added Edit hostlist to the settingsmenu.
Changed the search order for the prefs-file.
@
text
@d25 1
d143 1
a143 1
    {0,0,0,0,NULL,NULL,54,PLACETEXT_LEFT,NULL,NULL},                         /* Anonymous */
d228 1
d253 1
d257 1
d393 5
a397 1
    sc_NewGadgets[SC_ALIASNAME].ng_Width=TextLength(RPort,www,40);
d429 2
a430 2
    sc_NewGadgets[SC_ANONYMOUS].ng_Height=FHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_ANONYMOUS].ng_Width=2*FHigh;
d432 1
a432 1
    sc_NewGadgets[SC_ANONYMOUS].ng_LeftEdge=sc_NewGadgets[SC_LOCDIR].ng_LeftEdge+sc_NewGadgets[SC_LOCDIR].ng_Width-sc_NewGadgets[SC_ANONYMOUS].ng_Width-INTERWIDTH-INTERWIDTH/2;
d434 1
a434 1
    sc_NewGadgets[SC_LOGINNAME].ng_Width=sc_NewGadgets[SC_LOCDIR].ng_Width;
d437 1
a437 1
    sc_NewGadgets[SC_LOGINNAME].ng_LeftEdge=sc_NewGadgets[SC_LOCDIR].ng_LeftEdge;
d439 1
a439 1
    sc_NewGadgets[SC_PASSWORD].ng_Width=sc_NewGadgets[SC_LOCDIR].ng_Width;
d441 2
a442 2
    sc_NewGadgets[SC_PASSWORD].ng_TopEdge=sc_NewGadgets[SC_LOGINNAME].ng_TopEdge+sc_NewGadgets[SC_LOGINNAME].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_PASSWORD].ng_LeftEdge=sc_NewGadgets[SC_LOCDIR].ng_LeftEdge;
d449 2
a450 2
    sc_NewGadgets[SC_HOTLISTGAD].ng_Height=FHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_HOTLISTGAD].ng_Width=2*FHigh;
d452 1
a452 1
    sc_NewGadgets[SC_HOTLISTGAD].ng_LeftEdge=sc_NewGadgets[SC_PORT].ng_LeftEdge+sc_NewGadgets[SC_PORT].ng_Width-sc_NewGadgets[SC_HOTLISTGAD].ng_Width-INTERWIDTH-INTERWIDTH/2;
d454 4
a457 4
    sc_NewGadgets[SC_PROXYGAD].ng_Height=FHigh+2*INTERHEIGHT;
    sc_NewGadgets[SC_PROXYGAD].ng_Width=FHigh*2;
    sc_NewGadgets[SC_PROXYGAD].ng_TopEdge=sc_NewGadgets[SC_VMSDIR].ng_TopEdge;
    sc_NewGadgets[SC_PROXYGAD].ng_LeftEdge=TextLength(RPort,sc_NewGadgets[SC_PROXYGAD].ng_GadgetText,strlen(sc_NewGadgets[SC_PROXYGAD].ng_GadgetText))+INTERWIDTH;
d480 1
d554 4
d572 11
d651 10
d719 13
d800 4
d994 1
a994 1
							GA_Disabled,co_lvord==-1?TRUE:FALSE,
d1007 1
d1017 1
a1017 1

d1092 4
a1095 2
			Continue=FALSE;

d1242 1
a1242 1
	    GT_SetGadgetAttrs(co_Gadgets[CO_CONNECT],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
d1289 1
a1289 1
	GT_SetGadgetAttrs(co_Gadgets[CO_CONNECT],co_Win,NULL,GA_Disabled,TRUE,NULL,TAG_DONE);
@


0.413
log
@Added password-gadget.
@
text
@d128 1
a128 1
int Layout_co(struct Gadget **,struct Window *);
d778 2
a779 2
    n1=TextLength(RPort,co_NewGadgets[CO_REMOVE].ng_GadgetText,strlen(co_NewGadgets[CO_REMOVE].ng_GadgetText))+INTERWIDTH;
    n2=TextLength(RPort,co_NewGadgets[CO_CONNECT].ng_GadgetText,strlen(co_NewGadgets[CO_CONNECT].ng_GadgetText))+INTERWIDTH;
d781 1
a781 1
    n2=TextLength(RPort,co_NewGadgets[CO_CANCEL].ng_GadgetText,strlen(co_NewGadgets[CO_CANCEL].ng_GadgetText))+INTERWIDTH;
d783 5
d878 1
a878 1
int Layout_co(struct Gadget **gadg,struct Window *window)
d880 2
d947 5
a951 4
    if (!(co_Gadgets[CO_CANCEL] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGadgets[CO_CANCEL],
						       GT_Underscore,'_',
						       TAG_END)))
      return(FALSE);
d957 1
a957 1
struct SiteNode *OpenSiteListWindow()
d966 4
d994 1
a994 1
    if (!Layout_co(&gad,co_Win)) {
@


0.371
log
@Localized source.
@
text
@d7 2
d131 2
a132 2
enum {SC_ALIASNAME=0,SC_SITENAME,SC_PORT,SC_REMDIR,SC_LOCDIR,SC_LOCDIRGAD,SC_LOGINNAME,SC_OK,
	SC_CANCEL,SC_VMSDIR,SC_PROXYGAD,SC_HOTLISTGAD,NumGadgets_sc};
d142 1
d144 1
d160 1
a160 2
/*    (LONG)SCW_Anonymous,*/
/*    (LONG)SCW_Password,*/
d162 1
d179 1
d181 1
d195 1
d225 3
d233 6
d263 119
d421 5
d428 1
a428 1
    sc_NewGadgets[SC_LOGINNAME].ng_TopEdge=sc_NewGadgets[SC_LOCDIR].ng_TopEdge+sc_NewGadgets[SC_LOCDIR].ng_Height+INTERHEIGHT;
d431 5
d438 2
a439 2
    sc_NewGadgets[SC_VMSDIR].ng_TopEdge=sc_NewGadgets[SC_LOGINNAME].ng_TopEdge+sc_NewGadgets[SC_LOGINNAME].ng_Height+INTERHEIGHT;
    sc_NewGadgets[SC_VMSDIR].ng_LeftEdge=sc_NewGadgets[SC_LOGINNAME].ng_LeftEdge+sc_NewGadgets[SC_LOGINNAME].ng_Width-sc_NewGadgets[SC_VMSDIR].ng_Width;
d470 1
d487 2
d500 1
a500 1
			    WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_GADGETDOWN|IDCMP_GADGETUP|LISTVIEWIDCMP|IDCMP_VANILLAKEY,
d549 10
d605 2
d656 12
a667 1
    ULONG tags[]={ASL_Window,NULL,ASLFR_PrivateIDCMP,TRUE,ASLFR_SleepWindow,TRUE,ASLFR_InitialDrawer,NULL,ASLFR_DrawersOnly,TRUE,ASLFR_RejectIcons,TRUE,ASLFR_TitleText,NULL,ASLFR_InitialLeftEdge,NULL,ASLFR_InitialTopEdge,NULL,TAG_END};
d728 7
@


0.348
log
@Fixed the gadgets in site_gui (functions were messed up)
Enumerated gadgetnumbers to prevent the above in the future.
@
text
@d38 25
a62 10
    {0,0,0,0,"FTP Sites",NULL,0,PLACETEXT_ABOVE,NULL,NULL},
    {0,0,0,0,"_Connect",NULL,7,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"_New",NULL,1,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"_Edit",NULL,3,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"_Remove",NULL,2,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"C_ancel",NULL,8,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"Up",NULL,10,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"Down",NULL,10,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"Top",NULL,10,PLACETEXT_IN,NULL,NULL},
    {0,0,0,0,"Bottom",NULL,10,PLACETEXT_IN,NULL,NULL}
d134 31
a164 12
    {0,0,0,0,"Na_me",NULL,14,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"_Site",NULL,10,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"_Port",NULL,13,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"_Auto-cd to directory",NULL,3,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,NULL,NULL,5,PLACETEXT_LEFT,NULL,(APTR)LocPathString_clicked},
    {0,0,0,0,"_Download path",NULL,6,PLACETEXT_IN,NULL,(APTR)LocPath_clicked},
    {0,0,0,0,"_Login name",NULL,4,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"_OK",NULL,9,PLACETEXT_IN,NULL,(APTR)OK_clicked},
    {0,0,0,0,"Ca_ncel",NULL,8,PLACETEXT_IN,NULL,(APTR)Cancel_clicked},
    {0,0,26,11,"Operating S_ystem",NULL,12,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"Pro_xy",NULL,12,PLACETEXT_LEFT,NULL,NULL},
    {0,0,0,0,"_HotList",NULL,15,PLACETEXT_LEFT,NULL,NULL}
d231 1
a231 1
    GTCY_Labels,OSTYPES,
d351 1
a351 1
			    WA_Title,"AmiFTP Site Configuration",
d499 1
a499 1
    tags[13]=(unsigned long)"Select download path";
d790 1
a790 1
			    WA_Title,"AmiFTP Hotlist window",
d986 1
a986 1
	sn->sn_Node.ln_Name=strdup("(New)");
@


0.345
log
@Upload via ARexx now works
Entering a remotedir in stringgadget results in re-reading it
@
text
@d24 3
a26 11
#define CO_SITELIST 0
#define CO_NEW      1
#define CO_EDIT     2
#define CO_REMOVE   3
#define CO_CONNECT  4
#define CO_CANCEL   5
#define CO_UP       6
#define CO_DOWN     7
#define CO_TOP      8
#define CO_BOTTOM   9
#define NumGadgets_co 10
d28 1
a28 1
struct Gadget *co_Gadgets[NumGadgets_co];
d50 1
a50 1
ULONG co_types[] =
d64 1
a64 1
ULONG co_tags[] =
d108 1
a108 1
struct Gadget *co_glist;
d114 2
a115 14
#define SC_ALIASNAME   0
#define SC_SITENAME    1
#define SC_PORT        2
#define SC_REMDIR      3
#define SC_LOCDIR      4
#define SC_LOCDIRGAD   5
#define SC_LOGINNAME   6
#define SC_OK          7
#define SC_CANCEL      8
#define SC_VMSDIR      9
#define SC_PROXYGAD   10
#define SC_HOTLISTGAD 11
#define NumGadgets_sc 12

d133 1
a133 1
ULONG sc_types[]=
d149 1
a149 1
STRPTR OSTYPES[]={
d156 1
a156 1
ULONG sc_tags[] = 
d207 1
a207 1
struct Gadget *sc_Gadgets[NumGadgets_sc];
a209 1

@


0.305
log
@Added some casts to avoid compiler warnings
@
text
@a43 12
struct NewGadget co_SiteList = {0,0,0,0,"FTP Sites",NULL,0,PLACETEXT_ABOVE,NULL,NULL};
struct NewGadget co_ConnectGad= {0,0,0,0,"_Connect",NULL,7,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_NewGad   = {0,0,0,0,"_New",NULL,1,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_EditGad   = {0,0,0,0,"_Edit",NULL,3,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_RemoveGad= {0,0,0,0,"_Remove",NULL,2,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_CancelGad={0,0,0,0,"C_ancel",NULL,8,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_OKGad={0,0,0,0,"_OK",NULL,9,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_UpGad={0,0,0,0,"Up",NULL,10,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_DownGad={0,0,0,0,"Down",NULL,10,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_TopGad={0,0,0,0,"Top",NULL,10,PLACETEXT_IN,NULL,NULL};
struct NewGadget co_BotGad={0,0,0,0,"Bottom",NULL,10,PLACETEXT_IN,NULL,NULL};

d585 80
a664 70
    co_SiteList.ng_Width=TextLength(RPort,www,40)+16;
    co_SiteList.ng_Height=FHigh*9+INTERHEIGHT;
    co_SiteList.ng_TopEdge=FHigh+INTERHEIGHT+INTERHEIGHT/2;
    co_SiteList.ng_LeftEdge=INTERWIDTH;
    co_SiteList.ng_VisualInfo=myVisualInfo;
    co_SiteList.ng_TextAttr=Font;

    co_TopGad.ng_Width=INTERWIDTH+TextLength(RPort,co_BotGad.ng_GadgetText,strlen(co_BotGad.ng_GadgetText));
    co_TopGad.ng_Height=FHigh+2*INTERHEIGHT;
    co_TopGad.ng_LeftEdge=co_SiteList.ng_LeftEdge+co_SiteList.ng_Width+INTERWIDTH;
    co_TopGad.ng_TopEdge=co_SiteList.ng_TopEdge;
    co_TopGad.ng_VisualInfo=myVisualInfo;
    co_TopGad.ng_TextAttr=Font;

    co_UpGad.ng_Width=co_TopGad.ng_Width;
    co_UpGad.ng_Height=FHigh+INTERHEIGHT;
    co_UpGad.ng_LeftEdge=co_SiteList.ng_LeftEdge+co_SiteList.ng_Width+INTERWIDTH;
    co_UpGad.ng_TopEdge=co_TopGad.ng_TopEdge+co_TopGad.ng_Height+INTERHEIGHT;
    co_UpGad.ng_VisualInfo=myVisualInfo;
    co_UpGad.ng_TextAttr=Font;

    co_DownGad.ng_Width=co_TopGad.ng_Width;
    co_DownGad.ng_Height=FHigh+INTERHEIGHT;
    co_DownGad.ng_LeftEdge=co_SiteList.ng_LeftEdge+co_SiteList.ng_Width+INTERWIDTH;
    co_DownGad.ng_TopEdge=co_UpGad.ng_TopEdge+co_UpGad.ng_Height+INTERHEIGHT;
    co_DownGad.ng_VisualInfo=myVisualInfo;
    co_DownGad.ng_TextAttr=Font;

    co_BotGad.ng_Width=co_TopGad.ng_Width;
    co_BotGad.ng_Height=FHigh+INTERHEIGHT;
    co_BotGad.ng_LeftEdge=co_SiteList.ng_LeftEdge+co_SiteList.ng_Width+INTERWIDTH;
    co_BotGad.ng_TopEdge=co_DownGad.ng_TopEdge+co_DownGad.ng_Height+INTERHEIGHT;
    co_BotGad.ng_VisualInfo=myVisualInfo;
    co_BotGad.ng_TextAttr=Font;

    co_NewGad.ng_Width=TextLength(RPort,co_RemoveGad.ng_GadgetText,strlen(co_RemoveGad.ng_GadgetText))+INTERWIDTH;
    co_NewGad.ng_Height=FHigh+INTERHEIGHT*2;
    co_NewGad.ng_TopEdge=co_SiteList.ng_TopEdge+co_SiteList.ng_Height+INTERHEIGHT;
    co_NewGad.ng_LeftEdge=co_SiteList.ng_LeftEdge;
    co_NewGad.ng_VisualInfo=myVisualInfo;
    co_NewGad.ng_TextAttr=Font;

    co_EditGad.ng_Width=co_NewGad.ng_Width;
    co_EditGad.ng_Height=co_NewGad.ng_Height;
    co_EditGad.ng_TopEdge=co_NewGad.ng_TopEdge;
    co_EditGad.ng_VisualInfo=myVisualInfo;
    co_EditGad.ng_TextAttr=Font;

    co_RemoveGad.ng_Width=co_NewGad.ng_Width;
    co_RemoveGad.ng_Height=co_NewGad.ng_Height;
    co_RemoveGad.ng_TopEdge=co_NewGad.ng_TopEdge;
    co_RemoveGad.ng_LeftEdge=co_SiteList.ng_LeftEdge+co_SiteList.ng_Width-co_RemoveGad.ng_Width;
    co_RemoveGad.ng_VisualInfo=myVisualInfo;
    co_RemoveGad.ng_TextAttr=Font;
    co_EditGad.ng_LeftEdge=co_NewGad.ng_LeftEdge+co_NewGad.ng_Width+(co_RemoveGad.ng_LeftEdge-co_NewGad.ng_LeftEdge-co_NewGad.ng_Width)/2-co_EditGad.ng_Width/2;


    co_ConnectGad.ng_Width=TextLength(RPort,co_ConnectGad.ng_GadgetText,strlen(co_ConnectGad.ng_GadgetText))+INTERWIDTH;
    co_ConnectGad.ng_Height=FHigh+INTERHEIGHT*2;
    co_ConnectGad.ng_TopEdge=co_NewGad.ng_TopEdge+co_NewGad.ng_Height+INTERHEIGHT;
    co_ConnectGad.ng_LeftEdge=co_SiteList.ng_LeftEdge;
    co_ConnectGad.ng_VisualInfo=myVisualInfo;
    co_ConnectGad.ng_TextAttr=Font;

    co_CancelGad.ng_Width=co_ConnectGad.ng_Width;
    co_CancelGad.ng_Height=co_ConnectGad.ng_Height;
    co_CancelGad.ng_TopEdge=co_ConnectGad.ng_TopEdge;
    co_CancelGad.ng_LeftEdge=co_SiteList.ng_LeftEdge+co_SiteList.ng_Width-co_CancelGad.ng_Width;
    co_CancelGad.ng_VisualInfo=myVisualInfo;
    co_CancelGad.ng_TextAttr=Font;
d666 1
a666 1
    co_OKGad.ng_Width=co_ConnectGad.ng_Width;
d671 8
a678 8
    co_OKGad.ng_TextAttr=Font;
    *minwidth=INTERWIDTH + co_TopGad.ng_LeftEdge+co_TopGad.ng_Width;
    *minheight=co_CancelGad.ng_TopEdge+co_CancelGad.ng_Height+INTERHEIGHT/2;
    co_FastKeys[CO_CONNECT] = FindVanillaKey(co_ConnectGad.ng_GadgetText);
    co_FastKeys[CO_NEW] = FindVanillaKey(co_NewGad.ng_GadgetText);
    co_FastKeys[CO_EDIT] = FindVanillaKey(co_EditGad.ng_GadgetText);
    co_FastKeys[CO_REMOVE] = FindVanillaKey(co_RemoveGad.ng_GadgetText);
    co_FastKeys[CO_CANCEL] = FindVanillaKey(co_CancelGad.ng_GadgetText);
d684 20
a703 22
    co_SiteList.ng_TopEdge+=window->BorderTop;
    co_SiteList.ng_LeftEdge+=window->BorderLeft;
    co_TopGad.ng_TopEdge+=window->BorderTop;
    co_TopGad.ng_LeftEdge+=window->BorderLeft;
    co_UpGad.ng_TopEdge+=window->BorderTop;
    co_UpGad.ng_LeftEdge+=window->BorderLeft;
    co_DownGad.ng_TopEdge+=window->BorderTop;
    co_DownGad.ng_LeftEdge+=window->BorderLeft;
    co_BotGad.ng_TopEdge+=window->BorderTop;
    co_BotGad.ng_LeftEdge+=window->BorderLeft;
    co_NewGad.ng_TopEdge+=window->BorderTop;
    co_NewGad.ng_LeftEdge+=window->BorderLeft;
    co_EditGad.ng_TopEdge+=window->BorderTop;
    co_EditGad.ng_LeftEdge+=window->BorderLeft;
    co_RemoveGad.ng_TopEdge+=window->BorderTop;
    co_RemoveGad.ng_LeftEdge+=window->BorderLeft;
    co_ConnectGad.ng_TopEdge+=window->BorderTop;
    co_ConnectGad.ng_LeftEdge+=window->BorderLeft;
    co_CancelGad.ng_TopEdge+=window->BorderTop;
    co_CancelGad.ng_LeftEdge+=window->BorderLeft;
    co_OKGad.ng_TopEdge+=window->BorderTop;
    co_OKGad.ng_LeftEdge+=window->BorderLeft;
d705 1
a705 1
    if (!(co_Gadgets[CO_SITELIST] = *gadg = CreateGadget(LISTVIEW_KIND,*gadg,&co_SiteList,
d710 1
d713 1
a713 1
    if (!(co_Gadgets[CO_TOP] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_TopGad,
d717 1
a717 1
    if (!(co_Gadgets[CO_UP] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_UpGad,
d721 1
a721 1
    if (!(co_Gadgets[CO_DOWN] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_DownGad,
d725 1
a725 1
    if (!(co_Gadgets[CO_BOTTOM] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_BotGad,
d730 1
a730 1
    if (!(co_Gadgets[CO_NEW] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_NewGad,
d734 1
a734 1
    if (!(co_Gadgets[CO_EDIT] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_EditGad,
d739 1
a739 1
    if (!(co_Gadgets[CO_REMOVE] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_RemoveGad,
d744 1
a744 1
    if (!(co_Gadgets[CO_CONNECT] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_ConnectGad,
d749 1
a749 1
    if (!(co_Gadgets[CO_CANCEL] = *gadg = CreateGadget(BUTTON_KIND,*gadg,&co_CancelGad,
@


0.284
log
@First RCS version.
@
text
@d496 3
a498 3
    tags[1]=sc_Win;
    tags[7]=GetString(sc_Gadgets[SC_LOCDIR]);
    tags[13]="Select download path";
d505 1
a505 1
    if (AslRequest(DirRequester,tags)) {
d580 1
a580 1
	tags[1]=&checked;
d582 1
a582 1
				 tags);
@
