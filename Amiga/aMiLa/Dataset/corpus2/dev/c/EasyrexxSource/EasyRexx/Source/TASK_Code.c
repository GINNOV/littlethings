/*
 *	File:					TASK_Code.c
 *	Description:	Code generator window.
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef	TASK_CODE_C
#define	TASK_CODE_C

/*** PRIVATE INCLUDES ****************************************************************/
#include "System.h"
#include "TASK_Code.h"
#include "Designer_AREXX.h"

/*** DEFINES *************************************************************************/
#define	GID_CODEPAGE				1
#define	GID_MAIN						2
#define	GID_AREXXHANDLER		3
#define	GID_TEMPLATES				4
#define	GID_HANDLE					5
#define	GID_AUTHOR					6
#define	GID_COPYRIGHT				7
#define	GID_VERSION					8
#define	GID_PORTNAME				9

/*** GLOBALS *************************************************************************/
struct egTask		codeTask;
struct egGadget	*codepage,
								*mmain,
								*arexxhandler,
								*templates,
								*generategroup,
								*handle,
								*handlegroup,
								*author,
								*copyright,
								*version,
								*portname,
								*generalgroup;

UBYTE generatefile[MAXCHARS],
			setattr[]="SETATTR '%s=%ld'";

struct CodeData code;

WORD	generatesize,
			generalsize;

STRPTR	codepages[]		={"General", "C", NULL},
				handlelabels[]	={"", "", NULL};
/*** FUNCTIONS ***********************************************************************/
__asm __saveds ULONG RenderCodeTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();
	{
	register UWORD	tmp;
	register BYTE		thickframe	=!egIsDisplay(mainTask.screen, DIPF_IS_LACE);

#ifdef MYDEBUG_H
	DebugOut("RenderCodeTask");
#endif

	egCreateContext(eg, &codeTask);

	mmain=egCreateGadget(eg,
								EG_Window,				codeTask.window,
								EG_TextAttr,			fontattr,
								EG_GadgetKind,		CHECKBOX_KIND,
								EG_LeftEdge,			LeftMargin+GBL,
								EG_TopEdge,				TopMargin+GBTFONT,
								EG_DefaultHeight,	TRUE,
								EG_DefaultWidth,	TRUE,
								EG_GadgetText,		egGetString(MSG__MAIN),
								EG_GadgetID,			GID_MAIN,
								EG_Flags,					PLACETEXT_RIGHT,
								GTCB_Checked,			code.main,
								TAG_END);
	arexxhandler=egCreateGadget(eg,
								EG_PlaceBelow,		mmain,
								EG_GadgetID,			GID_AREXXHANDLER,
								EG_GadgetText,		egGetString(MSG__AREXXHANDLER),
								GTCB_Checked,			code.arexxhandler,
								TAG_END);
	templates=egCreateGadget(eg,
								EG_PlaceBelow,		arexxhandler,
								EG_GadgetID,			GID_TEMPLATES,
								EG_GadgetText,		egGetString(MSG__TEMPLATES),
								GTCB_Checked,			code.templates,
								GA_Disabled,			code.handle==HANDLE_IDS,
								TAG_END);
	generategroup=egCreateGadget(eg,
								EG_GadgetKind,		EG_GROUP_KIND,
								EG_LeftEdge,			LeftMargin,
								EG_TopEdge,				tmp=Y1(mmain)-GBT,
								EG_Width,					generatesize+GBL+GBR,
								EG_Height,				Y2(templates)+GBB-tmp,
								EG_Title,					egGetString(MSG_GENERATE),
								EG_Shadow,				TRUE,
								EG_Font,					font,
								EG_ThickFrame,		thickframe,
								TAG_END);

	handle=egCreateGadget(eg,
								EG_GadgetKind,		MX_KIND,
								EG_LeftEdge,			LeftMargin+GBL,
								EG_TopEdge,				codeTask.window->Height-BottomMargin-GBB-MXHeight*2-GadVSpace,
								EG_GadgetID,			GID_HANDLE,
								EG_DefaultWidth,	TRUE,
								EG_DefaultHeight,	TRUE,
								EG_VanillaKey,		egFindVanillaKey(egGetString(MSG__HANDLE)),
								EG_GadgetText,		NULL,
								GTMX_Labels,			handlelabels,
								GTMX_Active,			code.handle,
								GTMX_TitlePlace,	PLACETEXT_RIGHT,
								TAG_END);
	handlegroup=egCreateGadget(eg,
								EG_GadgetKind,		EG_GROUP_KIND,
								EG_LeftEdge,			LeftMargin,
								EG_TopEdge,				tmp=Y1(handle)-GBT,
								EG_CloneWidth,		generategroup,
								EG_Height,				codeTask.window->Height-BottomMargin-tmp,
								EG_Title,					egGetString(MSG__HANDLE),
								EG_Shadow,				TRUE,
								EG_Font,					font,
								EG_ThickFrame,		thickframe,
								TAG_END);

	author=egCreateGadget(eg,
								EG_GadgetKind,		STRING_KIND,
								EG_LeftEdge,			tmp=X2(generategroup)+GadHSpace+GBL+generalsize,
								EG_TopEdge,				TopMargin+GBTFONT,
								EG_AlignTop,			mmain,
								EG_Width,					codeTask.window->Width-RightMargin-GBR-tmp,
								EG_DefaultHeight,	TRUE,
								EG_GadgetText,		egGetString(MSG__AUTHOR),
								EG_GadgetID,			GID_AUTHOR,
								EG_Flags,					PLACETEXT_LEFT,
								GTST_String,			code.author,
								GTST_MaxChars,		MAXDATALEN,
								TAG_END);
	copyright=egCreateGadget(eg,
								EG_PlaceBelow,		author,
								EG_GadgetText,		egGetString(MSG__COPYRIGHT),
								EG_GadgetID,			GID_COPYRIGHT,
								GTST_String,			code.copyright,
								GTST_MaxChars,		MAXDATALEN,
								TAG_END);
	version=egCreateGadget(eg,
								EG_PlaceBelow,		copyright,
								EG_GadgetText,		egGetString(MSG__VERSION),
								EG_GadgetID,			GID_VERSION,
								GTST_String,			code.version,
								GTST_MaxChars,		MAXDATALEN,
								TAG_END);
	portname=egCreateGadget(eg,
								EG_PlaceWindowBottom,	TRUE,
								EG_VSpace,				-GBB,
								EG_GadgetText,		egGetString(MSG__PORTNAME),
								EG_GadgetID,			GID_PORTNAME,
								GTST_String,			code.portname,
								GTST_EditHook,		(ULONG)&upperHook,
								GTST_MaxChars,		MAXDATALEN,
								TAG_END);
	generalgroup=egCreateGadget(eg,
								EG_GadgetKind,		EG_GROUP_KIND,
								EG_LeftEdge,			tmp=X1(author)-generalsize-GBL,
								EG_AlignTop,			generategroup,
								EG_Width,					codeTask.window->Width-RightMargin-tmp,
								EG_Height,				Y2(handlegroup)-Y1(generategroup),
								EG_Title,					egGetString(MSG_GENERAL),
								EG_Shadow,				TRUE,
								EG_Font,					font,
								EG_ThickFrame,		thickframe,
								TAG_END);

	}
	return 1L;
}

__asm __saveds ULONG CloseCodeTask(	register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();

#ifdef MYDEBUG_H
	DebugOut("CloseAssignTask");
#endif

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"WINDOW CODE CLOSE",
													TAG_DONE);
	return 1L;
}

__asm __saveds ULONG OpenCodeTask(register __a0 struct Hook *hook,
																	register __a2 APTR	      object,
																	register __a1 APTR	      message)
{
	int minwidth, minheight;
#ifdef MYDEBUG_H
	DebugOut("OpenCodeTask");
#endif

	geta4();
	if(egTaskToFront(&codeTask))
		return FALSE;

	handlelabels[0]=egGetString(MSG_BYIDS);
	handlelabels[1]=egGetString(MSG_CALLFUNCTIONS);

	generatesize=egMaxLen(eg,
											egGetString(MSG_GENERATE),
											egGetString(MSG__MAIN),
											egGetString(MSG__AREXXHANDLER),
											egGetString(MSG__TEMPLATES),
											egGetString(MSG__HANDLE),
											egGetString(MSG_BYIDS),
											egGetString(MSG_CALLFUNCTIONS),
											NULL)+EG_LabelSpace+MAX(MXWidth, CheckboxWidth);
	generalsize=egMaxLen(eg,
											egGetString(MSG__AUTHOR),
											egGetString(MSG__COPYRIGHT),
											egGetString(MSG__VERSION),
											egGetString(MSG__PORTNAME),
											NULL)+EG_LabelSpace;

	minwidth=LeftMargin+GBL*2+generatesize+GadHSpace+generalsize*2+GBR*2+RightMargin;
	minheight=TopMargin+GBTFONT+GBT+MAX(MXHeight*2+CheckboxHeight*3+GadVSpace*4+GBTFONT, GadDefHeight*4+GadVSpace*3)+GBB+BottomMargin;

	if(egOpenTask(&codeTask,
							WA_Title,					egGetString(MSG_CODESETTINGS),
							WA_Width,					MAX(minwidth, codeTask.coords.Width),
							WA_Height,				minheight,
							WA_MinWidth,			minwidth,
							WA_MinHeight,			minheight,
							WA_MaxWidth,			~0,
							WA_MaxHeight,			minheight,
							WA_AutoAdjust,		TRUE,
							WA_Activate,			TRUE,
							WA_DragBar,				TRUE,
							WA_DepthGadget,		TRUE,
							WA_SizeGadget,		TRUE,
							WA_SizeBBottom,		TRUE,
							WA_CloseGadget,		TRUE,
							WA_CustomScreen,	mainTask.screen,
							EG_LendMenu,			mainMenu,
							EG_IDCMP,					IDCMP_MENUPICK		|
																IDCMP_CLOSEWINDOW	|
																IDCMP_GADGETUP		|
																IDCMP_GADGETDOWN	|
																CHECKBOXIDCMP			|
																STRINGIDCMP,
							EG_OpenFunc,			(ULONG)OpenCodeTask,
							EG_CloseFunc,			(ULONG)CloseCodeTask,
							EG_RenderFunc,		(ULONG)RenderCodeTask,
							EG_HandleFunc,		(ULONG)HandleCodeTask,
							EG_InitialCentre,	TRUE,
							EG_IconifyGadget,	TRUE,
							EG_HelpNode,			"CodeWindow",
							TAG_END))
	{
		if(record)
			SetPointer(	codeTask.window,
									ER_RecordPointer,
									ER_RECORDPOINTERHEIGHT,
									ER_RECORDPOINTERWIDTH,
									ER_RECORDPOINTEROFFSET,
									0);
		return TRUE;
	}
	return FALSE;
}

__asm __saveds ULONG HandleCodeTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();
	{
	register struct IntuiMessage *msg=eg->msg;
#ifdef MYDEBUG_H
	DebugOut("HandleCodeTask");
#endif

	switch(msg->Class)
	{
		case IDCMP_CLOSEWINDOW:
			egCloseTask(&codeTask);
			break;

		case IDCMP_MENUPICK:
			HandleMainMenu(&codeTask, msg->Code);
			break;

		case IDCMP_MOUSEMOVE:
		case IDCMP_GADGETDOWN:
		case IDCMP_GADGETUP:
			switch(((struct Gadget *)msg->IAddress)->GadgetID)
			{
				case GID_MAIN:
					code.main=(BYTE)msg->Code;
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"MAIN",
																								code.main,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_AREXXHANDLER:
					code.arexxhandler=(BYTE)msg->Code;
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"AREXXHANDLER",
																								code.arexxhandler,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_TEMPLATES:
					code.templates=(BYTE)msg->Code;
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"TEMPLATES",
																								code.templates,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_HANDLE:
					code.handle=(BYTE)msg->Code;
					UpdateCodeTask();
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"HANDLERTYPE",
																								code.handle,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_AUTHOR:
					strcpy(code.author, String(author));
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"AUTHOR",
																								code.author,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_COPYRIGHT:
					strcpy(code.copyright, String(copyright));
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"COPYRIGHT",
																								code.copyright,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_VERSION:
					strcpy(code.version, String(version));
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"VERSION",
																								code.version,
																	TAG_DONE);
					++env.changes;
					break;
				case GID_PORTNAME:
					strcpy(code.portname, String(portname));
					if(record)
						AddARexxMacroCommand(	macro,
																	ER_Command,		setattr,
																	ER_Argument,	"PORTNAME",
																								code.portname,
																	TAG_DONE);
					++env.changes;
					break;
			}
			break;
	}
	}
	return 1L;
}

void UpdateCodeTask(void)
{
#ifdef MYDEBUG_H
	DebugOut("UpdateCodeTask");
#endif

	if(codeTask.window)
	{
		egSetGadgetAttrs(	mmain, codeTask.window, NULL,
											GTCB_Checked,	code.main,
											TAG_DONE);
		egSetGadgetAttrs(	arexxhandler, codeTask.window, NULL,
											GTCB_Checked,	code.arexxhandler,
											TAG_DONE);
		egSetGadgetAttrs(	templates, codeTask.window, NULL,
											GTCB_Checked,	code.templates,
											GA_Disabled,	code.handle==HANDLE_IDS,
											TAG_DONE);

		egSetGadgetAttrs(	handle, codeTask.window, NULL,
											GTMX_Active,	code.handle,
											TAG_DONE);

		egSetGadgetAttrs(	author, codeTask.window, NULL,
											GTST_String,	code.author,
											TAG_DONE);
		egSetGadgetAttrs(	copyright, codeTask.window, NULL,
											GTST_String,	code.copyright,
											TAG_DONE);
		egSetGadgetAttrs(	version, codeTask.window, NULL,
											GTST_String,	code.version,
											TAG_DONE);
		egSetGadgetAttrs(	portname, codeTask.window, NULL,
											GTST_String,	code.portname,
											TAG_DONE);
	}
}

#endif
