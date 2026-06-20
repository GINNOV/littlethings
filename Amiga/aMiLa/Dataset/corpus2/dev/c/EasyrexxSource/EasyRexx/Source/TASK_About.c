/*
 *	File:					TASK_About.c
 *	Description:	About requester window.
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef TASK_ABOUT_C
#define TASK_ABOUT_C

/*** PRIVATE INCLUDES ****************************************************************/
#include "System.h"
#include "AboutLogo.h"
#include "Designer_AREXX.h"
#include "TASK_About.h"

/*** DEFINES *************************************************************************/
#define	GID_ABOUTOK		1

/*** GLOBALS *************************************************************************/
struct egTask		aboutTask;
struct Image		aboutImage;

struct List			*aboutlist;
UBYTE						*abouttext=NULL;

struct egGadget *aboutversion,
								*aboutok,
								*aboutlistview=NULL;
WORD						aboutsize;
ULONG						abouttop=0;

/*** FUNCTIONS ***********************************************************************/

__asm __saveds ULONG RefreshAboutTask(register __a0 struct Hook *hook,
																			register __a2 APTR	      object,
																			register __a1 APTR	      message)
{
#ifdef MYDEBUG_H
	DebugOut("RefreshAboutTask");
#endif
	aboutImage.Width			=ABOUTLOGOWIDTH;
	aboutImage.Height			=ABOUTLOGOHEIGHT;
	aboutImage.Depth			=ABOUTLOGODEPTH;

	aboutImage.ImageData	=AboutLogo;
	aboutImage.PlanePick	=0x3;
	aboutImage.PlaneOnOff	=0x0;
	aboutImage.NextImage	=NULL;

	DrawImage(aboutTask.window->RPort, &aboutImage,
						X1(aboutversion)+(W(aboutversion)-ABOUTLOGOREALWIDTH)/2,
						Y1(aboutversion)-ABOUTLOGOHEIGHT-1);
	return 1L;
}

__asm __saveds ULONG RenderAboutTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();
	{
	WORD  posarray[1], sizearray[1];
	WORD	tmp;

#ifdef MYDEBUG_H
	DebugOut("RenderAboutTask");
#endif

		egCreateContext(eg, &aboutTask);

		sizearray[0]=(ULONG)egTextWidth(eg, egGetString(MSG__OK))+GadHInside*2;
		egSpreadGadgets(	posarray,
											sizearray,
											LeftMargin,
											LeftMargin+aboutsize, 1, TRUE);

		aboutok=egCreateGadget(eg,
									EG_Window,						aboutTask.window,
									EG_TextAttr,					fontattr,
									EG_GadgetKind,				BUTTON_KIND,
									EG_LeftEdge,					posarray[0],
									EG_DefaultHeight,			TRUE,
									EG_PlaceWindowBottom,	TRUE,
									EG_Width,							sizearray[0],
									EG_GadgetText,				egGetString(MSG__OK),
									EG_GadgetID,					GID_ABOUTOK,
									EG_Flags,							0,
									TAG_END);

		aboutlistview=NULL;
		UpdateAboutTask();
		aboutlistview=egCreateGadget(eg,
									EG_GadgetKind,			LISTVIEW_KIND,
									EG_LeftEdge,				tmp=LeftMargin+aboutsize+GadHSpace,
									EG_PlaceWindowTop,	TRUE,
									EG_Width,						aboutTask.window->Width-RightMargin-tmp,
									EG_Height,					Y2(aboutok)-TopMargin,
									EG_GadgetText,			NULL,
									EG_GadgetID,				0,
									GTLV_Labels,				aboutlist,
									GTLV_ReadOnly,			TRUE,
									GTLV_Top,						abouttop,
									TAG_END);

		{
			register UBYTE version[MAXCHARS];

			sprintf(version, egGetString(MSG_VERSION), VERS);
			aboutversion=egCreateGadget(eg,
										EG_GadgetKind,			TEXT_KIND,
										EG_PlaceWindowLeft,	TRUE,
//										EG_TopEdge,					MAX(TopMargin+ABOUTLOGOHEIGHT+GadVSpace, TopMargin+Y2(aboutok)/2+GadVSpace),
//										EG_TopEdge,					MAX(TopMargin+ABOUTLOGOHEIGHT+GadVSpace, (aboutTask.window->Height/2+ABOUTLOGOHEIGHT/2-GadDefHeight)),
//										EG_TopEdge,					MAX(TopMargin+ABOUTLOGOHEIGHT, (aboutTask.window->Height+ABOUTLOGOHEIGHT)/2-GadDefHeight),
										EG_TopEdge,					(aboutTask.window->Height+ABOUTLOGOHEIGHT)/2-GadDefHeight,
										EG_Width,						tmp=egTextWidth(eg, version),
										EG_LeftEdge,				LeftMargin+(ABOUTLOGOREALWIDTH-tmp)/2,
										EG_DefaultHeight,		TRUE,
										GTTX_Text,					version,
										GTTX_CopyText,			TRUE,
										TAG_END);
		}
	}
	return 1L;
}

__asm BYTE TextToList(register __a0 struct List *list,
											register __a1 UBYTE				*text,
											register __d0 UWORD				width)
{
	register BYTE success=FALSE;

#ifdef MYDEBUG_H
	DebugOut("TextToList");
#endif

	if(list && text)
	{
		register UBYTE	*start=text,
										cc,
										*laststop=NULL;

		/* subtract border width */
		width-=25;
		while(*text!='\0')
		{
			while(*text!='\n' && *text!=' ' && *text!='\0')
				text++;

			cc=*text;
			*text='\0';
			if(cc==' ' && TextLength(&eg->RPort, start, text-start)>width)
			{
				if(laststop)
				{
					register UBYTE lcc=*laststop;

					*laststop='\0';
					AddNode(list, NULL, start);
					*laststop=lcc;
					*text=cc;
					text=laststop;
					cc=~0;
					laststop=NULL;
				}
				else
					AddNode(list, NULL, start);
				start=text+1;
			}
			else if(cc=='\n' | cc=='\0')
			{
				if(laststop && TextLength(&eg->RPort, start, text-start)>width)
				{
					register UBYTE lcc=*laststop;

					*laststop='\0';
					AddNode(list, NULL, start);
					*laststop=lcc;
					*text=cc;
					text=laststop;
					cc=~0;
					laststop=NULL;
				}
				else
					AddNode(list, NULL, start);
				start=text+1;
			}
			else
				laststop=text;
			if(cc!=~0)
				*text=cc;
			if(*text!='\0')
				*text++;
		}
		success=TRUE;
	}
	return success;
}

__asm __saveds ULONG CloseAboutTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();

#ifdef MYDEBUG_H
	DebugOut("CloseAboutTask");
#endif

	FreeList(aboutlist);
	FreeVec(abouttext);
	aboutlist=NULL;
	aboutlistview=NULL;
	abouttext=NULL;

	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"WINDOW ABOUT CLOSE",
													TAG_DONE);
	return 1L;
}
__asm __saveds ULONG OpenAboutTask(	register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	geta4();
	{
		WORD minwidth, minheight;
		UBYTE *aboutwintitle=egGetString(MSG_HELPABOUT);

#ifdef MYDEBUG_H
	DebugOut("OpenAboutTask");
#endif

		if(egTaskToFront(&aboutTask))
				return FALSE;

		aboutsize=egMaxLen(eg,	egGetString(MSG_VERSION),
														egGetString(MSG__OK),
														NULL)+GadHInside;
		aboutsize=MAX(aboutsize, ABOUTLOGOWIDTH);

		minwidth=LeftMargin+aboutsize*2+GadHSpace+RightMargin;
		minheight=TopMargin+ABOUTLOGOHEIGHT+GadDefHeight*2+GadVSpace+BottomMargin;

		aboutlist=InitList();

		if(*aboutwintitle!='\0' && (*(aboutwintitle+1)=='\0'))
			aboutwintitle=aboutwintitle+2;

		if(egOpenTask(&aboutTask,
								WA_Title,					aboutwintitle,
								WA_Width,					MAX(minwidth, aboutTask.coords.Width),
								WA_Height,				MAX(minheight, aboutTask.coords.Height),
								WA_MinWidth,			minwidth,
								WA_MinHeight,			minheight,
								WA_MaxWidth,			~0,
								WA_MaxHeight,			~0,
								WA_AutoAdjust,		TRUE,
								WA_Activate,			TRUE,
								WA_DragBar,				TRUE,
								WA_DepthGadget,		TRUE,
								WA_SizeGadget,		TRUE,
								WA_SizeBBottom,		TRUE,
								WA_CloseGadget,		TRUE,
								WA_SimpleRefresh,	env.simplerefresh,
								WA_PubScreen,			mainTask.screen,
								EG_OpenFunc,			(ULONG)OpenAboutTask,
								EG_CloseFunc,			(ULONG)CloseAboutTask,
								EG_RefreshFunc,		(ULONG)RefreshAboutTask,
								EG_RenderFunc,		(ULONG)RenderAboutTask,
								EG_HandleFunc,		(ULONG)HandleAboutTask,
								EG_IDCMP,					IDCMP_CLOSEWINDOW|
																	IDCMP_SIZEVERIFY|
																	SCROLLERIDCMP|
																	ARROWIDCMP|
																	IDCMP_GADGETDOWN|
																	IDCMP_MENUPICK|
																	IDCMP_GADGETUP,
								EG_InitialCentre,	TRUE,
								EG_IconifyGadget,	TRUE,
								EG_HelpNode,			"Description",
								EG_LendMenu,			mainMenu,
								TAG_END))
		{
			if(record)
				SetPointer(	aboutTask.window,
										ER_RecordPointer,
										ER_RECORDPOINTERHEIGHT,
										ER_RECORDPOINTERWIDTH,
										ER_RECORDPOINTEROFFSET,
										0);
			return TRUE;
		}
	}
	return FALSE;
}

__asm __saveds ULONG HandleAboutTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message)
{
	struct IntuiMessage *msg=eg->msg;

	geta4();
	switch(msg->Class)
	{
		case IDCMP_CLOSEWINDOW:
			egCloseTask(&aboutTask);
			break;

		case IDCMP_SIZEVERIFY:
			if(aboutlistview)
				egGetGadgetAttrs(	aboutlistview, aboutTask.window, NULL,
													GTLV_Top,			&abouttop,
													TAG_DONE);
			break;
		case IDCMP_MENUPICK:
			HandleMainMenu(&mainTask, msg->Code);
			break;
		case IDCMP_GADGETUP:
			switch(((struct Gadget *)msg->IAddress)->GadgetID)
			{
				case GID_ABOUTOK:
					egCloseTask(&aboutTask);
					break;
			}
		break;
	}
	return 1L;
}

void UpdateAboutTask(void)
{
	if(aboutlist)
	{
		register UBYTE *portname=(context==NULL ? egGetString(MSG_NOAREXXPORT):context->portname);

		if(abouttext)
			FreeVec(abouttext);
		if(abouttext=AllocVec((strlen(GetString(&li, MSG_ABOUTTEXT))+strlen(NAME)
																													+strlen(VERS)
																													+strlen(COPYRIGHT)
																													+strlen(DATE)
																													+strlen(TIME))
																													+strlen(portname)
																													+strlen(env.pubname)
																													+65, MEMF_CLEAR))
			sprintf(abouttext, egGetString(MSG_ABOUTTEXT), NAME, VERS, COPYRIGHT, DATE, TIME, portname, env.pubname, Count(commandlist));
	}

	if(aboutTask.window)
	{
		ClearList(aboutlist);
		TextToList(	aboutlist,
								abouttext,
								aboutTask.window->Width-RightMargin-(LeftMargin+aboutsize+GadHSpace));

		if(aboutlistview)
		{
			egGetGadgetAttrs(	aboutlistview, aboutTask.window, NULL,
												GTLV_Top,			&abouttop,
												TAG_DONE);
			egSetGadgetAttrs(	aboutlistview, aboutTask.window, NULL,
												GTLV_Labels,	aboutlist,
												GTLV_Top,			abouttop,
												TAG_DONE);
		}
	}
}

#endif
