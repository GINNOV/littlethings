/*
 *	File:					TASK_Assign.c
 *	Description:	Assign window which displays credits and information
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef	TASK_ASSIGN_C
#define	TASK_ASSIGN_C

/*** PRIVATE INCLUDES ****************************************************************/
#include "System.h"
#include "TASK_Assign.h"
#include "MainMenu.h"
#include "Asl.h"
#include "Designer_AREXX.h"

/*** DEFINES *************************************************************************/
#define	GID_RUNMACRO1		1
#define	GID_RUNMACRO2		2
#define	GID_RUNMACRO3		3
#define	GID_RUNMACRO4		4
#define	GID_RUNMACRO5		5
#define	GID_RUNMACRO6		6
#define	GID_RUNMACRO7		7
#define	GID_RUNMACRO8		8
#define	GID_RUNMACRO9		9
#define	GID_RUNMACRO10	10

#define	GID_MACRO1			11
#define	GID_MACRO2			12
#define	GID_MACRO3			13
#define	GID_MACRO4			14
#define	GID_MACRO5			15
#define	GID_MACRO6			16
#define	GID_MACRO7			17
#define	GID_MACRO8			18
#define	GID_MACRO9			19
#define	GID_MACRO10			20

#define	GID_GETMACRO1		21
#define	GID_GETMACRO2		22
#define	GID_GETMACRO3		23
#define	GID_GETMACRO4		24
#define	GID_GETMACRO5		25
#define	GID_GETMACRO6		26
#define	GID_GETMACRO7		27
#define	GID_GETMACRO8		28
#define	GID_GETMACRO9		29
#define	GID_GETMACRO10	30

/*** GLOBALS *************************************************************************/
struct egTask		assignTask;
struct egGadget	*runmacro[MAXMACROS],
								*macrostring[MAXMACROS];
WORD						macronumsize;

/*** FUNCTIONS ***********************************************************************/

__asm __saveds ULONG RenderAssignTask(register __a0 struct Hook *hook,
																			register __a2 APTR	      object,
																			register __a1 APTR	      message)
{
	geta4();
	{
	register BYTE i, gid=GID_RUNMACRO1;
	register UBYTE *notassigned=egGetString(MSG_NOTASSIGNED);
	struct egGadget	*getmacro[MAXMACROS];

#ifdef MYDEBUG_H
	DebugOut("RenderAssignTask");
#endif

	egCreateContext(eg, &assignTask);

	runmacro[0]=egCreateGadget(eg,
								EG_Window,				assignTask.window,
								EG_TextAttr,			fontattr,
								EG_GadgetKind,		BUTTON_KIND,
								EG_LeftEdge,			LeftMargin,
								EG_TopEdge,				TopMargin,
								EG_DefaultHeight,	TRUE,
								EG_Width,					macronumsize,
								EG_GadgetText,		macros[0].macrokey,
								EG_GadgetID,			gid++,
								EG_Flags,					0L,
								GA_Disabled, 			0==Stricmp(macros[0].name, notassigned),
								TAG_END);
	for(i=1; i<MAXMACROS; i++)
		runmacro[i]=egCreateGadget(eg,
									EG_PlaceBelow,		runmacro[i-1],
									EG_GadgetText,		macros[i].macrokey,
									EG_GadgetID,			gid++,
									GA_Disabled, 			0==Stricmp(macros[i].name, notassigned),
									TAG_END);

	macrostring[0]=egCreateGadget(eg,
								EG_GadgetKind,		STRING_KIND,
								EG_LeftEdge,			X2(runmacro[0])+GadHSpace,
								EG_TopEdge,				TopMargin,
								EG_Width,					assignTask.window->Width-LeftMargin-macronumsize-EG_GetfileWidth-RightMargin-GadHSpace,
								EG_GadgetID,			gid++,
								EG_GadgetText,		NULL,
								GTST_String,			macros[0].fullname,
								TAG_END);
	for(i=1; i<MAXMACROS; i++)
		macrostring[i]=egCreateGadget(eg,
									EG_PlaceBelow,		macrostring[i-1],
									EG_GadgetID,			gid++,
									GTST_String,			macros[i].fullname,
									TAG_END);

	getmacro[0]=egCreateGadget(eg,
								EG_GadgetKind,		EG_GETFILE_KIND,
								EG_LeftEdge,			X2(macrostring[0]),
								EG_AlignTop,			macrostring[0],
								EG_Width,					EG_GetfileWidth,
								EG_GadgetID,			gid++,
								TAG_END);
	for(i=1; i<MAXMACROS; i++)
		getmacro[i]=egCreateGadget(eg,
									EG_PlaceBelow,		getmacro[i-1],
									EG_GadgetID,			gid++,
									TAG_END);
	}
	return 1L;
}

__asm __saveds ULONG CloseAssignTask(	register __a0 struct Hook *hook,
																			register __a2 APTR	      object,
																			register __a1 APTR	      message)
{
	geta4();

#ifdef MYDEBUG_H
	DebugOut("CloseAssignTask");
#endif

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"WINDOW ASSIGN CLOSE",
													TAG_DONE);
	return 1L;
}

__asm __saveds ULONG OpenAssignTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	WORD minwidth, minheight;

	geta4();

#ifdef MYDEBUG_H
	DebugOut("OpenAssignTask");
#endif

	macronumsize=egTextWidth(eg, "1234567890")/10+GadHInside;
	minwidth=LeftMargin+macronumsize+23*4+MAX(egTextWidth(eg, egGetString(MSG_NOTASSIGNED)),
																						egTextWidth(eg, egGetString(MSG_ASSIGNMACROS)))
																				+EG_GetfileWidth+RightMargin;
	minheight=TopMargin+GadDefHeight*10+GadVSpace*9+BottomMargin;

	if(egOpenTask(&assignTask,
							WA_Title,					egGetString(MSG_ASSIGNMACROS),
							WA_Width,					MAX(minwidth, assignTask.coords.Width),
							WA_Height,				minheight,
							WA_MinWidth,			minwidth,
							WA_MinHeight,			minheight,
							WA_MaxWidth,			~0,
							WA_MaxHeight,			minheight,
							WA_AutoAdjust,		TRUE,
							WA_Activate,			TRUE,
							WA_DragBar,				TRUE,
							WA_DepthGadget,		TRUE,
							WA_SimpleRefresh,	env.simplerefresh,
							WA_SizeGadget,		TRUE,
							WA_SizeBBottom,		TRUE,
							WA_CloseGadget,		TRUE,
							WA_PubScreen,			mainTask.screen,
							EG_LendMenu,			mainMenu,
							EG_IDCMP,					IDCMP_MENUPICK		|
																IDCMP_CLOSEWINDOW	|
																GADGETUP					|
																STRINGIDCMP,
							EG_RenderFunc,		(ULONG)RenderAssignTask,
							EG_HandleFunc,		(ULONG)HandleAssignTask,
							EG_OpenFunc,			(ULONG)OpenAssignTask,
							EG_CloseFunc,			(ULONG)CloseAssignTask,
							EG_IconifyGadget,	TRUE,
							EG_InitialCentre,	TRUE,
							EG_HelpNode,			"MacroWindow",
							TAG_END))
	{
		if(record)
			SetPointer(	assignTask.window,
									ER_RecordPointer,
									ER_RECORDPOINTERHEIGHT,
									ER_RECORDPOINTERWIDTH,
									ER_RECORDPOINTEROFFSET,
									0);
		return TRUE;
	}
	return FALSE;
}

__asm __saveds ULONG HandleAssignTask(register __a0 struct Hook *hook,
																			register __a2 APTR	      object,
																			register __a1 APTR	      message)
{
	geta4();
	{
	struct IntuiMessage *msg=eg->msg;
	register BYTE	id;

	switch(msg->Class)
	{
		case IDCMP_CLOSEWINDOW:
			egCloseTask(&assignTask);
			break;

		case IDCMP_MENUPICK:
			HandleMainMenu(&assignTask, msg->Code);
			break;

		case IDCMP_GADGETUP:
			switch(id=((struct Gadget *)msg->IAddress)->GadgetID)
			{
				case GID_RUNMACRO1:
				case GID_RUNMACRO2:
				case GID_RUNMACRO3:
				case GID_RUNMACRO4:
				case GID_RUNMACRO5:
				case GID_RUNMACRO6:
				case GID_RUNMACRO7:
				case GID_RUNMACRO8:
				case GID_RUNMACRO9:
				case GID_RUNMACRO10:
					id-=GID_RUNMACRO1;
					if(0==RunARexxMacro(context,
												ER_MacroFile,	macros[id].fullname,
												TAG_DONE))
						FailRequest(mainTask.window, MSG_NOTFOUND, (APTR)macros[id].fullname, NULL);
					break;
				case GID_MACRO1:
				case GID_MACRO2:
				case GID_MACRO3:
				case GID_MACRO4:
				case GID_MACRO5:
				case GID_MACRO6:
				case GID_MACRO7:
				case GID_MACRO8:
				case GID_MACRO9:
				case GID_MACRO10:
					id-=GID_MACRO1;
					EnterMacroName(id, String(macrostring[id]));
					break;
				case GID_GETMACRO1:
				case GID_GETMACRO2:
				case GID_GETMACRO3:
				case GID_GETMACRO4:
				case GID_GETMACRO5:
				case GID_GETMACRO6:
				case GID_GETMACRO7:
				case GID_GETMACRO8:
				case GID_GETMACRO9:
				case GID_GETMACRO10:
					{
						register UBYTE name[MAXCHARS];

						id-=GID_GETMACRO1;
						strcpy(name, String(macrostring[id]));
						if(FileRequest(	assignTask.window,
														MSG_K_OPENMACROS,
														name,
														NULL,
														NULL,
														MSG__OK))
							EnterMacroName(id, name);
					}
					break;
			}
			break;
	}
	}
	return 1L;
}

void UpdateAssignTask(void)
{
#ifdef MYDEBUG_H
	DebugOut("UpdateAssignTask");
#endif

	if(assignTask.window)
	{
		register UBYTE	*notassigned=egGetString(MSG_NOTASSIGNED),
										i;
	
		for(i=0; i<MAXMACROS; i++)
		{
			egSetGadgetAttrs(	runmacro[i], assignTask.window, NULL,
												GA_Disabled,	0==Stricmp(macros[i].name, notassigned),
												TAG_DONE);
			egSetGadgetAttrs(	macrostring[i], assignTask.window, NULL,
												GTST_String, macros[i].fullname,
												TAG_DONE);
		}
		UpdateMacroMenu();
	}
}

void EnterMacroName(BYTE id, UBYTE *name)
{
	strcpy(macros[id].fullname, name);
	if(*(macros[id].fullname)=='\0')
		strcpy(macros[id].fullname, egGetString(MSG_NOTASSIGNED));
	strcpy(macros[id].name, FilePart(macros[id].fullname));
	UpdateAssignTask();

	if(record)
	{
		register UBYTE command[512];

		sprintf(command, "SETATTR 'MACRO=%ld NAME=%s'", id, name);
		AddARexxMacroCommand(	macro,
													ER_Command,	command,
													TAG_DONE);
	}
}
#endif
