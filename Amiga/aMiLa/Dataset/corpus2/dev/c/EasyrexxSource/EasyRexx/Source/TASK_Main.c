/*
 *	File:					TASK_Main.c
 *	Description:	Main window of ARexx Interface Designer
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef	TASK_MAIN_C
#define	TASK_MAIN_C

/*** PRIVATE INCLUDES ****************************************************************/
#include "System.h"
#include "GUI_Environment.h"
#include "TASK_About.h"
#include "TASK_Assign.h"
#include "TASK_Code.h"
#include "HandleFlags.h"
#include "myinclude:ISortList.h"
#include "Asl.h"
#include "GenerateCSource.h"
#include "Designer_AREXX.h"

/*** DEFINES *************************************************************************/
#define	GID_COMMANDS				1
#define	GID_COMMANDSTRING		2
#define	GID_ADDCOMMAND			3
#define	GID_COPYCOMMAND			4
#define	GID_CUTCOMMAND			5
#define	GID_PASTECOMMAND		6
#define	GID_UPCOMMAND				7
#define	GID_DOWNCOMMAND			8
#define	GID_ARGUMENTS				9
#define	GID_ARGUMENTSTRING	10
#define	GID_ADDARGUMENT			11
#define	GID_COPYARGUMENT		12
#define	GID_CUTARGUMENT			13
#define	GID_PASTEARGUMENT		14
#define	GID_UPARGUMENT			15
#define	GID_DOWNARGUMENT		16
#define	GID_ALWAYS					17
#define	GID_KEYWORD					18
#define	GID_NUMBER					19
#define	GID_SWITCH					20
#define	GID_TOGGLE					21
#define	GID_MULTIPLE				22
#define	GID_FINAL						23

#define	IDCMP_LISTVIEWCURSOR	~0

/*** GLOBALS *************************************************************************/
struct egTask		mainTask;
struct egGadget	*commands,
								*commandstring,
								*addcommand,
								*cutcommand,
								*pastecommand,
								*upcommand,
								*downcommand,
								*copycommand,
								*arguments,
								*argumentstring,
								*addargument,
								*cutargument,
								*pasteargument,
								*upargument,
								*downargument,
								*copyargument,
								*always,
								*keyword,
								*number,
								*sswitch,
								*toggle,
								*multiple,
								*final,
								*comgroup,
								*arggroup,
								*flagsgroup;

struct CommandNode	*commandnode		=NULL,
										*oldcommandnode	=NULL,
										*commandbuffer	=NULL;
struct Node					*argumentnode		=NULL,
										*argumentbuffer	=NULL;
struct List					*commandlist,
										*argumentlist;

UWORD								activecommand=~0,
										activeargument=~0,
										commandgadsize,
										switchgadsize,
										pens[]={~0};
UBYTE								commandname[MAXCHARS],
										argumentname[MAXCHARS],
										windowtitle[MAXCHARS],
										assign=FALSE,
										reset=FALSE,
										flagrecord[]="SETATTR '%s=%ld'";
BYTE								oldnoargument=~0,
										oldflags=0,
										oldflagsdisabled=~0;
ULONG								closemsg;

/*** FUNCTIONS ***********************************************************************/

#ifndef INTUITION_SGHOOKS_H
#include <intuition/sghooks.h>
#endif

struct Hook upperHook;

__asm __saveds ULONG upperHookFunc(	register __a0 struct Hook		*hook,
																		register __a2 struct SGWork	*sgw,
																		register __a1 ULONG					*msg)
{
	ULONG return_code=0L;

	if(*msg==SGH_KEY)
		switch(sgw->EditOp)
		{
			case EO_REPLACECHAR:
			case EO_INSERTCHAR:
				if(sgw->Code<'0' ||
					(sgw->Code>'9' & sgw->Code<'A') ||
					(sgw->Code>'Z' & sgw->Code<'_') ||
					(sgw->Code=='`') ||
					sgw->Code>'z')
					sgw->Actions=SGA_REUSE|SGA_BEEP;
				else
					sgw->WorkBuffer[sgw->BufferPos-1]=ToUpper(sgw->Code);
				break;
			default:
				switch(sgw->IEvent->ie_Code)
				{
					case CURSORUP:
					case CURSORDOWN:
						{
							struct IntuiMessage *msg;

							if(msg=(struct IntuiMessage *)AllocVec(sizeof(struct IntuiMessage), MEMF_CLEAR))
							{
								msg->Qualifier		=sgw->IEvent->ie_Qualifier;
								msg->Code					=sgw->IEvent->ie_Code;
								msg->Class				=IDCMP_LISTVIEWCURSOR;
								msg->IAddress			=(APTR)sgw->Gadget;
								msg->IDCMPWindow	=mainTask.window;
								msg->ExecMessage.mn_Node.ln_Type	=EG_INTUIMSG;
								PutMsg(eg->msgport, (struct Message *)msg);
							}
						}
						break;
				}
				break;
		}
	return return_code;
}

__asm __saveds ULONG RenderMainTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();
	{
	WORD	groupwidth, tmp,
				posarray[3], sizearray[3];
	register BYTE	nocommand		=(commandnode==NULL),
								noargument	=(argumentnode==NULL),
								thickframe	=!egIsDisplay(mainTask.screen, DIPF_IS_LACE);
	register LONG flags=(argumentnode ? argumentnode->ln_Pri:0L);


#ifdef MYDEBUG_H
	DebugOut("RenderMainTask");
#endif

	egCreateContext(eg, &mainTask);

 	always=egCreateGadget(eg,
								EG_Window,				mainTask.window,
								EG_TextAttr,			fontattr,
								EG_GadgetKind,		CHECKBOX_KIND,
								EG_LeftEdge,			tmp=mainTask.window->Width-RightMargin-switchgadsize-GBR,
								EG_TopEdge,				TopMargin+GBTFONT,
								EG_DefaultHeight,	TRUE,
								EG_DefaultWidth,	TRUE,
								EG_GadgetID,			GID_ALWAYS,
								EG_GadgetText,		egGetString(MSG__ALWAYS),
								EG_Flags,					PLACETEXT_RIGHT,
								EG_HelpNode,			"Always",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, ALWAYS),
								TAG_END);
	keyword=egCreateGadget(eg,
								EG_PlaceBelow,		always,
								EG_GadgetText,		egGetString(MSG__KEYWORD),
								EG_GadgetID,			GID_KEYWORD,
								EG_HelpNode,			"Keyword",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, KEYWORD),
								TAG_END);
	number=egCreateGadget(eg,
								EG_PlaceBelow,		keyword,
								EG_GadgetText,		egGetString(MSG__NUMBER),
								EG_GadgetID,			GID_NUMBER,
								EG_HelpNode,			"Number",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, NUMBER),
								TAG_END);
	sswitch=egCreateGadget(eg,
								EG_PlaceBelow,		number,
								EG_GadgetText,		egGetString(MSG__SWITCH),
								EG_GadgetID,			GID_SWITCH,
								EG_HelpNode,			"Switch",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, SWITCH),
								TAG_END);
	toggle=egCreateGadget(eg,
								EG_PlaceBelow,		sswitch,
								EG_GadgetText,		egGetString(MSG__TOGGLE),
								EG_GadgetID,			GID_TOGGLE,
								EG_HelpNode,			"Toggle",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, TOGGLE),
								TAG_END);
	multiple=egCreateGadget(eg,
								EG_PlaceBelow,		toggle,
								EG_GadgetText,		egGetString(MSG__MULTIPLE),
								EG_GadgetID,			GID_MULTIPLE,
								EG_HelpNode,			"Multiple",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, MULTIPLE),
								TAG_END);
	final=egCreateGadget(eg,
								EG_PlaceBelow,		multiple,
								EG_GadgetText,		egGetString(MSG__FINAL),
								EG_GadgetID,			GID_FINAL,
								EG_HelpNode,			"Final",
								GA_Disabled,			noargument,
								GTCB_Checked,			ISBITSET(flags, FINAL),
								TAG_END);
/*
	flagsgroup=egCreateGadget(eg,
							EG_GadgetKind,			EG_DUMMY_KIND,
							EG_AlignTop,				always,
							EG_AlignLeft,				always,
							EG_Width,						switchgadsize,
							EG_Height,					Y2(final)-Y1(always),
							EG_HelpNode,				"Switches",
							EG_GadgetText,			NULL,
							TAG_DONE);
*/
	groupwidth=(tmp-LeftMargin-GBR-GadHSpace*5-GBL-RightMargin)/2;

	commands=egCreateGadget(eg,
							EG_GadgetKind,	LISTVIEW_KIND,
							EG_LeftEdge,		LeftMargin+GBL,
							EG_TopEdge,			Y1(always),
							EG_Width,				groupwidth,
							EG_Height,			mainTask.window->Height-BottomMargin-GBB-GadVSpace*2-GadDefHeight*3-Y1(always),
							EG_GadgetText,	NULL,
							EG_GadgetID,		GID_COMMANDS,
							EG_Arrows,			TRUE,
							EG_HelpNode,		"Commands",
							EG_VanillaKey,	egFindVanillaKey(egGetString(MSG__COMMANDS)),
							GTLV_Labels,		commandlist,
							GTLV_Selected,	activecommand,
							GTLV_MakeVisible,		activecommand,
							(KickStart>38 ? GTLV_ShowSelected:TAG_IGNORE),	NULL,
							TAG_END);

	if(nocommand)
		*commandname='\0';
	else
		strcpy(commandname, (nocommand ? NULL:commandnode->nn_Node.ln_Name));
	commandstring=egCreateGadget(eg,
							EG_GadgetKind,		STRING_KIND,
							EG_TopEdge,				Y2(commands),
							EG_DefaultHeight,	TRUE,
							EG_GadgetID,			GID_COMMANDSTRING,
							GTST_String,			commandname,
							GA_Disabled,			nocommand,
							GTST_EditHook,		(ULONG)&upperHook,
							GTST_MaxChars,		MAXNAMELEN,
							TAG_END);

	sizearray[0]=sizearray[1]=sizearray[2]=(groupwidth-GadHSpace*2)/3;
	egSpreadGadgets(posarray, sizearray, X1(commands), X2(commands), 3, TRUE);

	copycommand=egCreateGadget(eg,
							EG_GadgetKind,	BUTTON_KIND,
							EG_PlaceWindowBottom,	TRUE,
							EG_VSpace,			-GBB,
							EG_LeftEdge,		posarray[0],
							EG_Width,				sizearray[0],
							EG_GadgetText,	egGetString(MSG__COPYCOMMAND),
							EG_GadgetID,		GID_COPYCOMMAND,
							EG_Flags,				0,
							GA_Disabled,		nocommand,
							TAG_END);
	pastecommand=egCreateGadget(eg,
							EG_LeftEdge,		posarray[1],
							EG_GadgetText,	egGetString(MSG__PASTECOMMAND),
							EG_GadgetID,		GID_PASTECOMMAND,
							GA_Disabled,		commandbuffer==NULL,
							TAG_END);
	downcommand=egCreateGadget(eg,
							EG_LeftEdge,		posarray[2],
							EG_GadgetText,	egGetString(MSG__DOWNCOMMAND),
							EG_GadgetID,		GID_DOWNCOMMAND,
							GA_Disabled,		(nocommand || commandnode==(struct CommandNode *)GetTail(commandlist)),
							TAG_END);
	addcommand=egCreateGadget(eg,
							EG_PlaceOver,		copycommand,
							EG_LeftEdge,		posarray[0],
							EG_GadgetText,	egGetString(MSG__ADDCOMMAND),
							EG_GadgetID,		GID_ADDCOMMAND,
							TAG_END);
 	cutcommand=egCreateGadget(eg,
							EG_LeftEdge,		posarray[1],
							EG_GadgetText,	egGetString(MSG__CUTCOMMAND),
							EG_GadgetID,		GID_CUTCOMMAND,
							GA_Disabled,		nocommand,
							TAG_END);
	upcommand=egCreateGadget(eg,
							EG_LeftEdge,		posarray[2],
							EG_GadgetText,	egGetString(MSG__UPCOMMAND),
							EG_GadgetID,		GID_UPCOMMAND,
							GA_Disabled,		(nocommand || commandnode==(struct CommandNode *)GetHead(commandlist)),
							TAG_END);
	comgroup=egCreateGadget(eg,
							EG_GadgetKind,	EG_GROUP_KIND,
							EG_LeftEdge,		LeftMargin,
							EG_TopEdge,			tmp=Y1(always)-GBT,
							EG_Width,				X2(commands)+GBR-LeftMargin,
							EG_Height,			Y2(copycommand)+GBB-tmp,
							EG_Title,				egGetString(MSG__COMMANDS),
							EG_ThickFrame,	thickframe,
							EG_Shadow,			TRUE,
							EG_Font,				font,
							TAG_DONE);

	arguments=egCreateGadget(eg,
							EG_GadgetKind,	LISTVIEW_KIND,
							EG_LeftEdge,		X2(commands)+GBR+GadHSpace+GBL,
							EG_TopEdge,			Y1(always),
							EG_Width,				groupwidth,
							EG_Height,			H(commands),
							EG_GadgetText,	NULL,
							EG_GadgetID,		GID_ARGUMENTS,
							EG_HelpNode,		"Arguments",
							EG_VanillaKey,	egFindVanillaKey(egGetString(MSG__ARGUMENTS)),
							GTLV_Selected,	activeargument,
							GTLV_Labels,		argumentlist,
							GTLV_MakeVisible,		activeargument,
							(KickStart>38 ? GTLV_ShowSelected:TAG_IGNORE),	NULL,
							TAG_END);

	if(noargument)
		*argumentname='\0';
	else
		strcpy(argumentname, (noargument ? NULL:StripFlags(argumentnode->ln_Name)));
	argumentstring=egCreateGadget(eg,
							EG_GadgetKind,	STRING_KIND,
							EG_TopEdge,			Y1(commandstring),
							EG_DefaultHeight,	TRUE,
							EG_GadgetID,		GID_ARGUMENTSTRING,
							GTST_String,		argumentname,
							GTST_EditHook,	(ULONG)&upperHook,
							GTST_MaxChars,		MAXNAMELEN,
							GA_Disabled,		noargument,
							TAG_END);

	egSpreadGadgets(posarray, sizearray, X1(arguments), X2(arguments), 3, TRUE);
	copyargument=egCreateGadget(eg,
							EG_GadgetKind,	BUTTON_KIND,
							EG_PlaceWindowBottom,	TRUE,
							EG_VSpace,			-GBB,
							EG_LeftEdge,		posarray[0],
							EG_Width,				sizearray[0],
							EG_GadgetText,	egGetString(MSG__COPYARGUMENT),
							EG_GadgetID,		GID_COPYARGUMENT,
							GA_Disabled,		noargument,
							TAG_END);
	pasteargument=egCreateGadget(eg,
							EG_LeftEdge,		posarray[1],
							EG_GadgetText,	egGetString(MSG__PASTEARGUMENT),
							EG_GadgetID,		GID_PASTEARGUMENT,
							GA_Disabled,		argumentbuffer==NULL | commandnode==NULL,
							TAG_END);
	downargument=egCreateGadget(eg,
							EG_LeftEdge,		posarray[2],
							EG_GadgetText,	egGetString(MSG__DOWNARGUMENT),
							EG_GadgetID,		GID_DOWNARGUMENT,
							GA_Disabled,		(noargument || argumentnode==GetTail(argumentlist)),
							TAG_END);
	addargument=egCreateGadget(eg,
							EG_PlaceOver,		copyargument,
							EG_LeftEdge,		posarray[0],
							EG_GadgetText,	egGetString(MSG__ADDARGUMENT),
							EG_GadgetID,		GID_ADDARGUMENT,
							GA_Disabled,		nocommand,
							TAG_END);
 	cutargument=egCreateGadget(eg,
							EG_LeftEdge,		posarray[1],
							EG_GadgetText,	egGetString(MSG__CUTARGUMENT),
							EG_GadgetID,		GID_CUTARGUMENT,
							GA_Disabled,		noargument,
							TAG_END);
	upargument=egCreateGadget(eg,
							EG_LeftEdge,		posarray[2],
							EG_GadgetText,	egGetString(MSG__UPARGUMENT),
							EG_GadgetID,		GID_UPARGUMENT,
							GA_Disabled,		(noargument || argumentnode==GetHead(argumentlist)),
							TAG_END);
	arggroup=egCreateGadget(eg,
							EG_GadgetKind,	EG_GROUP_KIND,
							EG_LeftEdge,		tmp=X2(commands)+GBR+GadHSpace,
							EG_Width,				mainTask.window->Width-RightMargin-tmp,
							EG_TopEdge,			tmp=Y1(always)-GBT,
							EG_Height,			Y2(copyargument)+GBB-tmp,
							EG_Title,				egGetString(MSG__ARGUMENTS),
							EG_ThickFrame,	thickframe,
							EG_Shadow,			TRUE,
							EG_Font,				font,
							TAG_DONE);
	}
	return 1L;
}

__asm __saveds ULONG CloseGUIMainTask(register __a0 struct Hook *hook,
																			register __a2 APTR	      object,
																			register __a1 APTR	      message)
{
	geta4();

#ifdef MYDEBUG_H
	DebugOut("CloseGUIMainTask");
#endif

	if(!env.lockedscreen)
		CloseScreen(mainTask.screen);

	return 1L;
}

__asm __saveds ULONG CloseMainTask(	register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	register BYTE doit=TRUE;
	geta4();

#ifdef MYDEBUG_H
	DebugOut("CloseMainTask");
#endif

	if(closemsg!=MSG_QUIT)
		doit=SafeToQuit(closemsg, FALSE);
	if(ISBITSET(eg->flags, EG_ICONIFIED))
		closemsg=MSG_ICONIFY;

	if(doit)
	{
		if(font)
			CloseFont(font);

		return 1L;
	}
	return 0L;
}

__asm __saveds ULONG OpenMainTask(register __a0 struct Hook *hook,
																	register __a2 APTR	      object,
																	register __a1 APTR	      message)
{
	WORD minwidth, minheight;
	register BYTE backdrop=(env.ownscreen && env.backdrop),
								success=FALSE;
	geta4();

#ifdef MYDEBUG_H
	DebugOut("OpenMainTask");
#endif

		upperHook.h_Entry			=(HOOKFUNC)upperHookFunc;
    upperHook.h_SubEntry	=NULL;
    upperHook.h_Data			=NULL;

	if(egTaskToFront(&mainTask))
			return FALSE;

	mainTask.screen=NULL;

	if(!env.ownscreen)
	{
		env.lockedscreen=TRUE;

		if(NULL==(mainTask.screen=LockPubScreen(env.pubname)))
		{
			if(NULL==(mainTask.screen=LockPubScreen(NULL)))
			{
				env.ownscreen=TRUE;
				env.lockedscreen=FALSE;
			}
		}
		GetPubScreenName(mainTask.screen, env.pubname);
	}

	fontattr=&env.textAttr;
	if(!env.ownscreen && env.usescreenfont)
		fontattr=mainTask.screen->Font;

	if(OpenDiskFont(fontattr))
		font=OpenFont(fontattr);
	
	if(env.ownscreen)
	{
		mainTask.screen=OpenScreenTags(NULL,
				SA_Title,					(env.backdrop ? MakeMainTitle():(UBYTE *)NAME),
				SA_DisplayID,			env.screeninfo.DisplayID,
				SA_Width,					env.screeninfo.DisplayWidth,
				SA_Height,				env.screeninfo.DisplayHeight,
				SA_Depth,					env.screeninfo.DisplayDepth,
				SA_AutoScroll,		env.screeninfo.AutoScroll,
				SA_Overscan,			env.screeninfo.OverscanType,
				SA_Type,					PUBLICSCREEN,
				SA_PubName,				GetUniquePubScreenName(env.pubname, NAME),
				SA_Font,					fontattr,
				SA_Interleaved,		TRUE,
				SA_MinimizeISG,		TRUE,
				SA_LikeWorkbench,	TRUE,
				SA_SharePens,			TRUE,
				(KickStart<39 ? SA_Pens:TAG_IGNORE), pens,
				TAG_DONE);
		LoadRGB4(&mainTask.screen->ViewPort, env.colors, MAXCOLORS);
		env.lockedscreen=FALSE;

		DefaultPubScreen(mainTask.screen, env.pubname, env.shanghai);
	}

	if(mainTask.screen)
	{
		egInitialize(eg, mainTask.screen, font);

		switchgadsize=egMaxLen(eg,	egGetString(MSG__ALWAYS),
																egGetString(MSG__KEYWORD),
																egGetString(MSG__NUMBER),
																egGetString(MSG__SWITCH),
																egGetString(MSG__TOGGLE),
																egGetString(MSG__MULTIPLE),
																egGetString(MSG__FINAL),
																NULL)+EG_LabelSpace+CheckboxWidth;
		commandgadsize=egMaxLen(eg,	egGetString(MSG__ADDCOMMAND),
																egGetString(MSG__CUTCOMMAND),
																egGetString(MSG__PASTECOMMAND),
																egGetString(MSG__UPCOMMAND),
																egGetString(MSG__DOWNCOMMAND),
																egGetString(MSG__COPYCOMMAND),
																NULL)+GadHInside;

		if(backdrop)
		{
			mainTask.coords.LeftEdge=0;
			mainTask.coords.TopEdge	=0;
			mainTask.coords.Width		=mainTask.screen->Width;
			mainTask.coords.Height	=mainTask.screen->Height;
		}
		else
		{
			minwidth=LeftMargin+GBL*2+commandgadsize*6+GBR*2+GadHSpace+switchgadsize+RightMargin;
			minheight=TopMargin+GBTFONT+GadDefHeight*7+GadVSpace*6+GBB+BottomMargin;
		}

		if(egOpenTask(&mainTask,
								(backdrop ? TAG_IGNORE:WA_Title),					MakeMainTitle(),
								(backdrop ? TAG_IGNORE:WA_Width),					MAX(minwidth, mainTask.coords.Width),
								(backdrop ? TAG_IGNORE:WA_Height),				MAX(minheight, mainTask.coords.Height),
								(backdrop ? TAG_IGNORE:WA_MinWidth),			minwidth,
								(backdrop ? TAG_IGNORE:WA_MinHeight),			minheight,
								(backdrop ? TAG_IGNORE:WA_MaxWidth),			~0,
								(backdrop ? TAG_IGNORE:WA_MaxHeight),			~0,
								WA_AutoAdjust,		TRUE,
								(backdrop ? TAG_IGNORE:WA_DragBar),				TRUE,
								(backdrop ? TAG_IGNORE:WA_DepthGadget),		TRUE,
								(backdrop ? TAG_IGNORE:WA_SizeGadget),		TRUE,
								(backdrop ? TAG_IGNORE:WA_SizeBBottom),		TRUE,
								(backdrop ? TAG_IGNORE:WA_CloseGadget),		TRUE,
								(backdrop ? WA_Backdrop:TAG_IGNORE),			TRUE,
								(backdrop ? WA_Borderless:TAG_IGNORE),		TRUE,
								WA_PubScreen,			mainTask.screen,
								WA_SimpleRefresh,	env.simplerefresh,
								WA_Activate,			TRUE,
								EG_Menu,					mainMenu,
//								EG_HelpMenu,			TRUE,
								EG_IDCMP,					IDCMP_MENUPICK		|
																	IDCMP_CLOSEWINDOW	|
																	LISTVIEWIDCMP			|
																	CHECKBOXIDCMP			|
																	GADGETUP					|
																	GADGETDOWN				|
																	STRINGIDCMP,
								EG_CloseGUIFunc,	(ULONG)CloseGUIMainTask,
								EG_OpenFunc,			(ULONG)OpenMainTask,
								EG_CloseFunc,			(ULONG)CloseMainTask,
								EG_RenderFunc,		(ULONG)RenderMainTask,
								EG_HandleFunc,		(ULONG)HandleMainTask,
								(backdrop ? TAG_IGNORE:EG_IconifyGadget),	TRUE,
								(backdrop ? TAG_IGNORE:EG_InitialUpperLeft),	TRUE,
								TAG_END))
		{
			if(env.lockedscreen)
				UnlockPubScreen(NULL, mainTask.screen);
			ScreenToFront(mainTask.screen);
			UpdateMainMenu();
			oldnoargument=~0;
			closemsg=MSG_QUIT;

			SetAllPointers();
			success=TRUE;
		}
	}
	return success;
}

__asm __saveds ULONG HandleMainTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	struct IntuiMessage *msg;

	geta4();

	msg=eg->msg;
	if(msg)
		switch(msg->Class)
		{
			case EGIDCMP_NOTIFY:
				if(env.lockedscreen)
					switch(msg->Code)
					{
						case SCREENNOTIFY_TYPE_WORKBENCH:
							if(0==Stricmp(env.pubname, "Workbench"))
								switch((BYTE)msg->IAddress)
								{
									case FALSE:
										SETBIT(eg->flags, EG_RESET);
										egCloseAllTasks(eg);
										break;
									case TRUE:
										if(!ISBITSET(eg->flags, EG_ICONIFIED))
										{
											egOpenAllTasks(eg);
											CLEARBIT(eg->flags, EG_RESET);
										}
										break;
								}
							break;
						case SCREENNOTIFY_TYPE_CLOSESCREEN:
							if(((struct Screen *)msg->IAddress)==mainTask.screen)
							{
								egCloseAllTasks(eg);
								Delay(50L);
								egOpenAllTasks(eg);
							}
							break;
						case SCREENNOTIFY_TYPE_PRIVATESCREEN:
							if(((struct PubScreenNode *)msg->IAddress)->psn_Screen==mainTask.screen)
							{
								egCloseAllTasks(eg);
								Delay(50L);
								egOpenAllTasks(eg);
							}
							break;
					}
				break;
			case IDCMP_LISTVIEWCURSOR:
				switch(((struct Gadget *)msg->IAddress)->GadgetID)
				{
					case GID_COMMANDSTRING:
						if(Stricmp(String(commandstring), commandnode->nn_Node.ln_Name))
							RenameCommand(String(commandstring));
						egHandleListviewArrows(commands, mainTask.window, msg);
						GetSelectedCommand(commands->active);
						egActivateGadget(commandstring, mainTask.window, NULL);
						break;
					case GID_ARGUMENTSTRING:
						if(Stricmp(String(argumentstring), argumentnode->ln_Name))
							RenameArgument(String(argumentstring));
						egHandleListviewArrows(arguments, mainTask.window, msg);
						GetSelectedArgument(arguments->active);
						egActivateGadget(argumentstring, mainTask.window, NULL);
						break;
				}
				break;

			case IDCMP_CLOSEWINDOW:
				Quit();
				break;

			case IDCMP_MENUPICK:
				HandleMainMenu(&mainTask, msg->Code);
				break;

			case IDCMP_GADGETDOWN:
			case IDCMP_GADGETUP:
				switch(((struct Gadget *)msg->IAddress)->GadgetID)
				{
					case GID_COMMANDS:
						GetSelectedCommand(msg->Code);
						break;
					case GID_ADDCOMMAND:
						AddCommand("\0");
						break;
					case GID_COMMANDSTRING:
						RenameCommand(String(commandstring));
						break;
					case GID_COPYCOMMAND:
						CopyCommand();
						break;
					case GID_CUTCOMMAND:
						CutCommand();
						break;
					case GID_PASTECOMMAND:
						PasteCommand();
						break;
					case GID_UPCOMMAND:
						MoveCommandUp();
						break;
					case GID_DOWNCOMMAND:
						MoveCommandDown();
						break;

					case GID_ARGUMENTS:
						GetSelectedArgument(msg->Code);
						break;
					case GID_ARGUMENTSTRING:
						RenameArgument(String(argumentstring));
						break;
					case GID_ADDARGUMENT:
						AddArgument("\0");
						break;
					case GID_COPYARGUMENT:
						CopyArgument();
						break;
					case GID_CUTARGUMENT:
						CutArgument();
						break;
					case GID_PASTEARGUMENT:
						PasteArgument();
						break;
					case GID_UPARGUMENT:
						MoveArgumentUp();
						break;
					case GID_DOWNARGUMENT:
						MoveArgumentDown();
						break;

					case GID_ALWAYS:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, ALWAYS);
						PutFlags(argumentnode);
						++env.changes;
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"ALWAYS",
																									ISBITSET(argumentnode->ln_Pri, ALWAYS),
																		TAG_DONE);
						break;
					case GID_KEYWORD:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, KEYWORD);
						PutFlags(argumentnode);
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"KEYWORD",
																									ISBITSET(argumentnode->ln_Pri, KEYWORD),
																		TAG_DONE);
						++env.changes;
						break;
					case GID_NUMBER:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, NUMBER);
						PutFlags(argumentnode);
						++env.changes;
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"NUMBER",
																									ISBITSET(argumentnode->ln_Pri, NUMBER),
																		TAG_DONE);
						break;
					case GID_SWITCH:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, SWITCH);
						PutFlags(argumentnode);
						++env.changes;
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"SWITCH",
																									ISBITSET(argumentnode->ln_Pri, SWITCH),
																		TAG_DONE);
						break;
					case GID_TOGGLE:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, TOGGLE);
						PutFlags(argumentnode);
						++env.changes;
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"TOGGLE",
																									ISBITSET(argumentnode->ln_Pri, TOGGLE),
																		TAG_DONE);
						break;
					case GID_MULTIPLE:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, MULTIPLE);
						PutFlags(argumentnode);
						++env.changes;
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"MULTIPLE",
																									ISBITSET(argumentnode->ln_Pri, MULTIPLE),
																		TAG_DONE);
						break;
					case GID_FINAL:
						IFTRUESETBIT(msg->Code, argumentnode->ln_Pri, FINAL);
						PutFlags(argumentnode);
						++env.changes;
						if(record)
							AddARexxMacroCommand(	macro,
																		ER_Command,		flagrecord,
																		ER_Arguments,	"FINAL",
																									ISBITSET(argumentnode->ln_Pri, FINAL),
																		TAG_DONE);
						break;
				}
				break;
		}

	return 1L;
}

void ResetMainTask(void)
{
#ifdef MYDEBUG_H
	DebugOut("ResetMainTask");
#endif
	argumentlist=NULL;
	oldcommandnode=commandnode=NULL;
	argumentnode=NULL;
	activecommand=activeargument=~0;
}

void GetFirstCommand(void)
{
#ifdef MYDEBUG_H
	DebugOut("GetFirstCommand");
#endif
	if(!IsNil(commandlist) && (oldcommandnode=commandnode=(struct CommandNode *)GetHead(commandlist)))
	{
#ifdef MYDEBUG_H
	DebugOut("** got first command");
#endif
		argumentlist=commandnode->argumentlist;
		activecommand=0;
	}
	else
	{
#ifdef MYDEBUG_H
	DebugOut("** could not get first command");
#endif
		argumentlist=NULL;
		commandnode=NULL;
		activecommand=~0;
	}
}

void GetFirstArgument(void)
{
#ifdef MYDEBUG_H
	DebugOut("GetFirstArgument");
#endif

	if(commandnode && (argumentnode=GetHead(argumentlist=commandnode->argumentlist)))
		activeargument=0;
	else
	{
		argumentnode=NULL;
		activeargument=~0;
	}
}

void RenameCommand(UBYTE *name)
{
#ifdef MYDEBUG_H
	DebugOut("RenameCommand");
#endif

	if(commandnode)
	{
		RenameNode((struct Node *)commandnode, name);

		if(record)
		{
			if(	macro->list->lh_TailPred					&&
					macro->list->lh_TailPred->ln_Pred	&&
					0==Stricmp(macro->list->lh_TailPred->ln_Name, "ADD"))
			{
				struct Node *node=macro->list->lh_TailPred;

				FreeVec(node->ln_Name);
				Remove(node);
				FreeVec(node);
				AddARexxMacroCommand(	macro,
															ER_Command,		"ADD '%s'",
															ER_Argument,	name,
															TAG_DONE);

			}
			else
				AddARexxMacroCommand(	macro,
															ER_Command,		"RENAME '%s'",
															ER_Argument,	name,
															TAG_DONE);
		}
	}
	UpdateMainTask(FALSE);
}

void RenameArgument(UBYTE *name)
{
#ifdef MYDEBUG_H
	DebugOut("ArgumentStringClicked");
#endif

	if(argumentnode)
	{
		RenameNode(argumentnode, name);
		PutFlags(argumentnode);

		if(record)
		{
			if(	macro->list->lh_TailPred					&&
					macro->list->lh_TailPred->ln_Pred	&&
					0==Stricmp(macro->list->lh_TailPred->ln_Name, "ADD"))
			{
				struct Node *node=macro->list->lh_TailPred;

				FreeVec(node->ln_Name);
				Remove(node);
				FreeVec(node);
				AddARexxMacroCommand(	macro,
															ER_Command,		"ADD ARGUMENT '%s'",
															ER_Argument,	name,
															TAG_DONE);

			}
			else
				AddARexxMacroCommand(	macro,
															ER_Command,		"RENAME ARGUMENT '%s'",
															ER_Argument,	String(argumentstring),
															TAG_DONE);
		}
	}
	++env.changes;
}

void UpdateMainTask(BYTE argumentsonly)
{
#ifdef MYDEBUG_H
	DebugOut("UpdateMainTask");
#endif

	if(mainTask.window)
	{
		register BYTE	nocommand		=(commandnode==NULL),
									noargument	=(argumentnode==NULL);
		register LONG flags=(argumentnode ? argumentnode->ln_Pri:0L);
				

		if(!argumentsonly)
		{
			egSetGadgetAttrs(	commands, mainTask.window, NULL,
												GTLV_Labels,			commandlist,
												GTLV_Selected,		activecommand,
												GTLV_MakeVisible,	activecommand,
												TAG_DONE);

			if(commandnode && commandnode->nn_Node.ln_Name)
				strcpy(commandname, commandnode->nn_Node.ln_Name);
			else
				*commandname='\0';
			egSetGadgetAttrs(	commandstring, mainTask.window, NULL,
												GTST_String,		commandname,
												GA_Disabled,		nocommand,
												TAG_DONE);
			egSetGadgetAttrs(	copycommand, mainTask.window, NULL,
												GA_Disabled,		nocommand,
												TAG_DONE);
			egSetGadgetAttrs(	cutcommand, mainTask.window, NULL,
												GA_Disabled,		nocommand,
												TAG_DONE);
			egSetGadgetAttrs(	pastecommand, mainTask.window, NULL,
												GA_Disabled,		commandbuffer==NULL,
												TAG_DONE);
			egSetGadgetAttrs(	upcommand, mainTask.window, NULL,
												GA_Disabled,		(nocommand || commandnode==(struct CommandNode *)GetHead(commandlist)),
												TAG_DONE);
			egSetGadgetAttrs(	downcommand, mainTask.window, NULL,
												GA_Disabled,		(nocommand || commandnode==(struct CommandNode *)GetTail(commandlist)),
												TAG_DONE);
		}
		egSetGadgetAttrs(	arguments, mainTask.window, NULL,
										GTLV_Labels,			argumentlist,
										GTLV_Selected,		activeargument,
										GTLV_MakeVisible,	activeargument,
										TAG_DONE);

		egSetGadgetAttrs(	addargument, mainTask.window, NULL,
											GA_Disabled,		nocommand,
											TAG_DONE);
		egSetGadgetAttrs(	pasteargument, mainTask.window, NULL,
											GA_Disabled,		argumentbuffer==NULL | commandnode==NULL,
											TAG_DONE);

		if(noargument && oldnoargument==noargument)
		{
			UpdateMainMenu();
			return;
		}
		oldnoargument=noargument;

		if(argumentnode && argumentnode->ln_Name)
			strcpy(argumentname, (noargument ? NULL:StripFlags(argumentnode->ln_Name)));
		else
			*argumentname='\0';

		egSetGadgetAttrs(	argumentstring, mainTask.window, NULL,
											GTST_String,		argumentname,
											GA_Disabled,		noargument,
											TAG_DONE);
		egSetGadgetAttrs(	copyargument, mainTask.window, NULL,
											GA_Disabled,		noargument,
											TAG_DONE);
		egSetGadgetAttrs(	cutargument, mainTask.window, NULL,
											GA_Disabled,		noargument,
											TAG_DONE);
		egSetGadgetAttrs(	upargument, mainTask.window, NULL,
											GA_Disabled,		(noargument || argumentnode==GetHead(argumentlist)),
											TAG_DONE);
		egSetGadgetAttrs(	downargument, mainTask.window, NULL,
											GA_Disabled,		(noargument || argumentnode==GetTail(argumentlist)),
											TAG_DONE);

		if(flags!=oldflags | oldflagsdisabled!=noargument)
		{
			egSetGadgetAttrs(	always, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, ALWAYS),
												TAG_DONE);
			egSetGadgetAttrs(	keyword, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, KEYWORD),
												TAG_DONE);
			egSetGadgetAttrs(	number, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, NUMBER),
												TAG_DONE);
			egSetGadgetAttrs(	sswitch, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, SWITCH),
												TAG_DONE);
			egSetGadgetAttrs(	toggle, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, TOGGLE),
												TAG_DONE);
			egSetGadgetAttrs(	multiple, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, MULTIPLE),
												TAG_DONE);
			egSetGadgetAttrs(	final, mainTask.window, NULL,
												GA_Disabled,		noargument,
												GTCB_Checked,		ISBITSET(flags, FINAL),
												TAG_DONE);
			oldflags=flags;
			oldflagsdisabled=noargument;
		}
		UpdateMainMenu();
	}
}

UWORD SortCommands(void)
{
	DetachList(commands, mainTask.window);
	ISortList(commandlist);

	if(commandnode)
	{
		register struct Node	*node;
		register UWORD				newpos=0;

		for(node=commandlist->lh_Head; node->ln_Succ!=NULL & node!=(struct CommandNode *)commandnode; node=node->ln_Succ)
			++newpos;
		activecommand=newpos;
	}
	UpdateMainTask(FALSE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"SORT",
													TAG_DONE);
	return activecommand;
}

UWORD SortArguments(void)
{
	DetachList(arguments, mainTask.window);
	ISortList(argumentlist);

	if(argumentnode)
	{
		register struct Node	*node;
		register UWORD				newpos=0;

		for(node=argumentlist->lh_Head; node->ln_Succ!=NULL & node!=argumentnode; node=node->ln_Succ)
			++newpos;
		activeargument=newpos;
	}
	else
		ResetMainTask();
	UpdateMainTask(FALSE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"SORT ARGUMENTS",
													TAG_DONE);
	return activeargument;
}

void GetSelectedCommand(UWORD code)
{
	if(oldcommandnode!=(commandnode=(struct CommandNode *)egGetNode(commandlist, activecommand=code)))
	{
		GetFirstArgument();
		UpdateMainTask(FALSE);
		oldcommandnode=commandnode;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,		"ACTIVATE %ld",
														ER_Arguments,	activecommand+1,
														TAG_DONE);
	}
}

void GetSelectedArgument(UWORD code)
{
	argumentnode=egGetNode(argumentlist, activeargument=code);
	UpdateMainTask(TRUE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,		"ACTIVATE ARGUMENT %ld",
													ER_Argument,	activeargument+1,
													TAG_DONE);
}

void CutCommand(void)
{
	if(commandnode)
	{
		if(oldcommandnode=commandnode=(struct CommandNode *)CutNode(commandlist, &commandbuffer, commandnode))
			activecommand=(UWORD)egSetGadgetAttrs(commands, mainTask.window, NULL,
																						GTLV_SelectedNode,	commandnode,
																						TAG_DONE);
		if(commandnode==NULL)
			argumentlist=NULL;
		GetFirstArgument();
		oldnoargument=~0;
		UpdateMainTask(FALSE);
		UpdateAboutTask();
		++env.changes;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"CUT",
														TAG_DONE);
	}
}

void CutArgument(void)
{
	if(argumentnode)
	{
		if(argumentnode=CutNode(argumentlist, &argumentbuffer, argumentnode))
			activeargument=(UWORD)egSetGadgetAttrs(arguments, mainTask.window, NULL,
																						GTLV_SelectedNode,	argumentnode,
																						TAG_DONE);
		UpdateMainTask(TRUE);
		++env.changes;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"CUT ARGUMENT",
														TAG_DONE);
	}
}

void PasteCommand(void)
{
	if(commandbuffer)
	{
		if(activecommand==~0)
			activecommand=Count(commandlist);
		oldcommandnode=commandnode=(struct CommandNode *)PasteNode(commandlist, commandbuffer, commandnode);
		GetFirstArgument();
		oldnoargument=~0;
		UpdateMainTask(FALSE);
		UpdateAboutTask();
		++env.changes;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"PASTE",
														TAG_DONE);
	}
}

void PasteArgument(void)
{
	if(argumentbuffer)
	{
		if(activeargument==~0)
			activeargument=Count(argumentlist);
		argumentnode=PasteNode(argumentlist, argumentbuffer, argumentnode);
		UpdateMainTask(TRUE);
		++env.changes;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"PASTE ARGUMENT",
														TAG_DONE);
	}
}

void MoveCommandDown(void)
{
	Down(mainTask.window, commands, commandlist, (struct Node *)commandnode);
	activecommand=MIN(Count(commandlist)-1, activecommand+1);
	UpdateMainTask(FALSE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"MOVE UP",
													TAG_DONE);
}

void MoveCommandUp(void)
{
	Up(mainTask.window, commands, commandlist, (struct Node *)commandnode);
	activecommand=MAX(0, activecommand-1);
	UpdateMainTask(FALSE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"MOVE DOWN",
													TAG_DONE);
}

void MoveArgumentUp(void)
{
	Up(mainTask.window, arguments, commandnode->argumentlist, argumentnode);
	activeargument=MAX(0, activeargument-1);
	UpdateMainTask(TRUE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"MOVE ARGUMENT UP",
													TAG_DONE);
}

void MoveArgumentDown(void)
{
	Down(mainTask.window, arguments, commandnode->argumentlist, argumentnode);
	activeargument=MIN(Count(argumentlist), activeargument+1);
	UpdateMainTask(TRUE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"MOVE ARGUMENT DOWN",
													TAG_DONE);
}

void CopyCommand(void)
{
	CopyNode(commandlist, &commandbuffer, (struct Node *)commandnode);
	UpdateMainTask(FALSE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"COPY",
													TAG_DONE);
}

void CopyArgument(void)
{
	CopyNode(argumentlist, &argumentbuffer, argumentnode);
	UpdateMainTask(FALSE);

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"COPY ARGUMENT",
													TAG_DONE);
}

UBYTE *MakeMainTitle(void)
{
	sprintf(windowtitle, "%s - %s", NAME, FilePart(project));
	if(mainTask.window)
		SetWindowTitles(mainTask.window, windowtitle, (UBYTE *)~0);

	if(env.ownscreen && env.backdrop)
	{
		register struct egTask *task;

		for(task=eg->tasklist; task; task=task->nexttask)
			if(task->window)
				SetWindowTitles(task->window, (UBYTE *)~0, windowtitle);
	}
	return windowtitle;
}

void AddCommand(UBYTE *name)
{
	if(oldcommandnode=commandnode=AddCommandNode(commandlist, (struct Node *)commandnode, name))
	{
		argumentlist=commandnode->argumentlist;
		argumentnode=NULL;
		activeargument=~0;
		if(activecommand==~0)
			activecommand=MAX(0, Count(commandlist)-1);
		UpdateMainTask(TRUE);
		UpdateAboutTask();
		++env.changes;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"ADD",
														TAG_DONE);
		else
			egActivateGadget(commandstring, mainTask.window, NULL);
	}
}

void AddArgument(UBYTE *name)
{
	if(argumentnode=AddNode(argumentlist, argumentnode, name))
	{
		if(activeargument==~0)
			activeargument=MAX(0, Count(argumentlist)-1);
		UpdateMainTask(TRUE);
		++env.changes;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"ADD ARGUMENT",
														TAG_DONE);
		else
			egActivateGadget(argumentstring, mainTask.window, NULL);
	}
}

#endif
