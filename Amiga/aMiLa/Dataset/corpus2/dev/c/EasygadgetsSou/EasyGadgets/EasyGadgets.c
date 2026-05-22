/*
 *	File:					EasyGadgets.c
 *	Description:	Functions to easy create and handle graphic user interface
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#define LIBCODE 1

#ifndef EASYGADGETS_H
#define	EASYGADGETS_H

#define	SETTAG(array,tag,data)	array.ti_Tag=tag;array.ti_Data=data 

/*** PRIVATE INCLUDES ****************************************************************/
#include <exec/types.h>
#include <libraries/gadtools.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <utility/utility.h>
#include <utility/tagitem.h>
#include <utility/hooks.h>
#include <intuition/imageclass.h>
#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>
#include <libraries/amigaguide.h>
#include <libraries/diskfont.h>
#include <workbench/workbench.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>
#include <clib/keymap_protos.h>
#include <clib/amigaguide_protos.h>
#include <clib/alib_stdio_protos.h>
#include <clib/alib_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/wb_protos.h>

/*** ScreenNotify.library support ***************************************************/
#include <libraries/screennotify.h>
#include <clib/screennotify_protos.h>
#include <pragmas/screennotify_pragmas.h>

struct IntuitionBase	*IntuitionBase;
struct GfxBase				*GfxBase;
struct Library				*GadToolsBase,
											*DOSBase,
											*UtilityBase,
											*AmigaGuideBase,
											*KeymapBase,
											*DiskfontBase,
											*WorkbenchBase,
											*SysBase,
											*ScreenNotifyBase;

#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/keymap_pragmas.h>
#include <pragmas/amigaguide_pragmas.h>
#include <pragmas/diskfont_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/locale_pragmas.h>
#include <pragmas/keymap_pragmas.h>

#include <stdlib.h>
#include <clib/macros.h>
#include "myinclude:BitMacros.h"

/*** DEFINES *************************************************************************/
#define LIBVER	37L
#define	EG_LIB	1

#define	EG_Underscorechar		'_'
#define	EG_Underscorestring	"_"

#define	every_task					task=eg->tasklist; task; task=task->nexttask

/*** PROTOTYPES **********************************************************************/
__asm BYTE IsNil(register __a0 struct List *list);

/*** PRIVATE INCLUDES ****************************************************************/

#define USEFAILREQUEST
#ifdef USEFAILREQUEST
LONG FailRequest(UBYTE *format, APTR arg1, ...);
#endif

#include "easygadgets_rev.h"
#include "myinclude:BitMacros.h"
#include <libraries/EasyGadgets.h>
#include <clib/EasyGadgets_protos.h>
#include "myinclude:myString.h"
#include "myinclude:CloseWindowSafely.h"
#include "menu.c"
#include "Help.c"
#include "HandleKeys.c"
#include "Gadgets.c"
#include "Windows.c"
#include "Task.c"
#include "Requesters.c"
#include "IconifyButtonClass.c"
#include "GroupFrameClass.c"

/*** LIBRARY INIT ********************************************************************/
void __saveds __UserLibCleanup(void)
{
	if(ScreenNotifyBase)
		CloseLibrary(ScreenNotifyBase);
	if(WorkbenchBase)
		CloseLibrary(WorkbenchBase);
	if(DiskfontBase)
		CloseLibrary(DiskfontBase);
	if(KeymapBase)
		CloseLibrary(KeymapBase);
	if(DOSBase)
		CloseLibrary(DOSBase);
	if(GfxBase)
		CloseLibrary((struct Library *)GfxBase);
	if(GadToolsBase)
		CloseLibrary(GadToolsBase);
	if(UtilityBase)
		CloseLibrary(UtilityBase);
	if(IntuitionBase)
		CloseLibrary((struct Library *)IntuitionBase);
}

int __saveds __UserLibInit(void)
{
	SysBase=*((void **)4L);

	ScreenNotifyBase=OpenLibrary(SCREENNOTIFY_NAME, SCREENNOTIFY_VERSION);

	if(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", LIBVER))
		if(UtilityBase=OpenLibrary("utility.library", LIBVER))
			if(GadToolsBase=OpenLibrary("gadtools.library", LIBVER))
				if(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library", LIBVER))
					if(DOSBase=OpenLibrary("dos.library", LIBVER))
						if(KeymapBase=OpenLibrary("keymap.library", 0L))
							if(DiskfontBase=OpenLibrary("diskfont.library", LIBVER))
								if(WorkbenchBase=OpenLibrary(WORKBENCH_NAME, LIBVER))
									return 0;
	__UserLibCleanup();
	return 1;
}

/*** FUNCTIONS ***********************************************************************/

#ifdef USEFAILREQUEST
LONG FailRequestA(UBYTE *format, APTR *args)
{
	struct EasyStruct myES;

	myES.es_StructSize		=sizeof(struct EasyStruct);
	myES.es_Title					=NAME " " VERS;
	myES.es_TextFormat		=format;
	myES.es_GadgetFormat	="OK";

	return EasyRequestArgs(NULL, &myES, NULL, args);
}

LONG FailRequest(UBYTE *format, APTR arg1, ...)
{
	return FailRequestA(format, &arg1);
}
#endif

/*** FUNCTIONS ***********************************************************************/
__asm __saveds WORD egTextWidth(register __a0 struct EasyGadgets	*eg,
																register __a1 STRPTR							text)
{
	register WORD		length;

#ifdef MYDEBUG_H
	DebugOut("egNewTextWidth");
#endif

	length=TextLength(&eg->RPort, text, StrLen(text));

	if(StrChr(text, EG_Underscorechar))
		length-=TextLength(&eg->RPort, EG_Underscorestring, 1);
	return length;
}

__asm __saveds WORD egMaxLenA(register __a1 struct EasyGadgets	*eg,
															register __a0 UBYTE								**array)
{
	register WORD		maxlen=0;
	register ULONG	i=0;
	register char		*c;

#ifdef MYDEBUG_H
	DebugOut("egMaxLenA");
#endif

	while(c=array[i++])
		maxlen=MAX(maxlen, egTextWidth(eg, c));

	return maxlen;
}

__asm __saveds void egSpreadGadgets(register __a0 WORD *posarray,
																		register __a1 WORD *sizearray,
																		register __d0 WORD x1,
																		register __d1 WORD x2,
																		register __d2 ULONG count,
																		register __d3 BYTE space)
{
	register	WORD	totalsize=0, width=x2-x1, gadspace=0;
	register	ULONG last=count-1, i;

#ifdef MYDEBUG_H
	DebugOut("egSpreadGadgets");
#endif

	if(count==1)
		posarray[0]=x1+(((x2-x1)-sizearray[0])/2);
	else
	{
		for(i=0; i<count; i++)
			totalsize+=sizearray[i];
		if(space==TRUE)
			gadspace=(width-totalsize)/(count-1);

		posarray[0]=x1;

		if(count>2)
			for(i=1; i<last; i++)
				posarray[i]=posarray[i-1]+sizearray[i-1]+gadspace;

		posarray[last]=x2-sizearray[last];
	}
}

__asm __saveds void egInitialize(	register __a0 struct EasyGadgets	*eg,
																	register __a1 struct Screen				*screen,
																	register __a2 struct TextFont			*font)
{
	register struct Window	*window;
	register BYTE islaced=(BYTE)egIsDisplay(screen, DIPF_IS_LACE);

#ifdef MYDEBUG_H
	DebugOut("egInitialize");
#endif

	eg->screen	=screen;
	eg->font		=font;
	SetFont(&eg->RPort, font);

	eg->FontHeight				=font->tf_YSize+1;
	eg->ScreenBarHeight		=screen->BarHeight+1;
	eg->GadgetKind				=BUTTON_KIND;

	eg->VInside						=eg->HSpace=4;
	eg->HInside						=15;

	eg->GroupBorderLeft		=7;
	eg->GroupBorderRight	=5;

	eg->SliderHeight			=MAX(8,								eg->FontHeight+2);
	eg->SliderWidth				=MAX(16,							eg->SliderHeight);

	if(window=OpenWindowTags(NULL,
								WA_Title,					"Be nice",
								WA_Width,					1,
								WA_Height,				1,
								WA_CustomScreen,	screen,
								WA_SizeGadget,		TRUE,
								WA_SizeBBottom,		TRUE,
								TAG_END))
	{
		eg->LeftMargin	=4+window->BorderLeft;
		eg->RightMargin	=4+window->BorderRight;

		eg->TopMargin			=2+window->BorderTop;
		eg->BottomMargin	=2+window->BorderBottom;

		CloseWindow(window);
	}
	if(window=OpenWindowTags(NULL,
								WA_Title,					":-þ",
								WA_Width,					1,
								WA_Height,				1,
								WA_CustomScreen,	screen,
								TAG_END))
	{
		eg->BottomMarginNoSize=2+window->BorderBottom;
		CloseWindow(window);
	}

	if(islaced)
	{
		eg->VSpace							=4;
		eg->GroupBorderTop			=3+font->tf_YSize/2;
		eg->GroupBorderBottom		=6;
		eg->GroupBorderLeft			=7;
		eg->GroupBorderRight		=7;

		eg->TopMargin						+=2;
		eg->BottomMargin				+=2;
		eg->BottomMarginNoSize	+=2;
	}
	else
	{
		eg->VSpace							=2;
		eg->GroupBorderTop			=2+font->tf_YSize/2;
		eg->GroupBorderBottom		=5;
		eg->GroupBorderLeft			=10;
		eg->GroupBorderRight		=10;
	}

	eg->CheckboxHeight=MAX(CHECKBOX_HEIGHT, eg->FontHeight+2);
	eg->MXHeight			=MAX(MX_HEIGHT,				eg->FontHeight);

	if(KickStart>38)
	{
		register WORD	medchar=TextLength(&eg->RPort, "abcdefghijklmnopqrstuvwxyz", 26)/26;

		if(islaced && eg->FontHeight>8)
		{
			eg->CheckboxWidth	=eg->CheckboxHeight+2;
			eg->MXWidth				=eg->MXHeight+2;
		}
		else
		{
			eg->CheckboxWidth	=MIN(CHECKBOX_WIDTH,	medchar*3+2);
			eg->MXWidth				=MIN(MX_WIDTH,				medchar*3);
		}
	}
	else
	{
		eg->CheckboxWidth	=CHECKBOX_WIDTH;
		eg->MXWidth				=MX_WIDTH;
	}

	eg->DefaultHeight		=eg->FontHeight+eg->VInside;
}

__asm void egSafeDeleteMsgPort(register __a0 struct MsgPort *port)
{
	if(port)
	{
		register struct Message *msg;

		while(msg=GetMsg(port))
			ReplyMsg(msg);
		DeleteMsgPort(port);
	}
}

__asm __saveds void egFreeEasyGadgets(register __a0 struct EasyGadgets *eg)
{
#ifdef MYDEBUG_H
	DebugOut("egFreeEasyGadgets");
#endif

	if(eg)
	{
		egCloseAllTasks(eg);

		if(eg->iconifyclass)
			FreeClass(eg->iconifyclass);

		if(eg->groupframeclass)
			FreeClass(eg->groupframeclass);

		if(eg->helpdoc!=NULL)
		{
			egCloseAmigaGuide(eg);
			FreeVec(eg->helpdoc);
		}
		if(eg->basename!=NULL)
			FreeVec(eg->basename);
		eg->AmigaGuideSignal=0L;
		FreeVec(eg->msg);

		egSafeDeleteMsgPort(eg->msgport);

		if(eg->wbhandle)
			while(!RemWorkbenchClient(eg->wbhandle))
				Delay(10);
		egSafeDeleteMsgPort(eg->notifyport);

		FreeVec(eg);
	}
}

__asm __saveds struct EasyGadgets *egAllocEasyGadgetsA(register __a0 struct TagItem *taglist)
{
	register struct EasyGadgets	*eg;

#ifdef MYDEBUG_H
	DebugOut("egAllocEasyGadgetsA");
#endif

	if(eg=(struct EasyGadgets *)AllocVec(sizeof(struct EasyGadgets), MEMF_CLEAR|MEMF_PUBLIC))
		if(eg->msg=(struct IntuiMessage *)AllocVec(sizeof(struct IntuiMessage), NULL))
			if(eg->msgport=CreateMsgPort())
			{
				struct TagItem	*tstate=taglist;
				register struct TagItem	*tag;

				InitRastPort(&eg->RPort);

				eg->iconifyclass=initIconifyButtonClass();
				eg->groupframeclass=initGroupFrameClass();

				if(ScreenNotifyBase)
					eg->notifyport=CreateMsgPort();

				while(tag=NextTagItem(&tstate))
					switch(tag->ti_Tag)
					{
						case EG_HelpDocument:
							eg->helpdoc=StrDup((UBYTE *)tag->ti_Data);
							break;
						case EG_Basename:
							eg->basename=StrDup((UBYTE *)tag->ti_Data);
							break;
						case EG_AppIcon:
							eg->diskobj=(struct DiskObject *)tag->ti_Data;
							break;
						case EG_WorkbenchNotify:
							if(eg->notifyport && tag->ti_Data)
								eg->wbhandle=AddWorkbenchClient(eg->notifyport, 0);
							break;
					}
			}
	return eg;
}

#define	ID_APPICON	1
#define	ID_APPMENU	2

__asm __saveds BYTE egIconify(register __a0 struct EasyGadgets	*eg,
															register __d0 BYTE								doit)
{
	register BYTE success=FALSE;

	if(doit)
	{
		if(ISBITCLEARED(eg->flags, EG_ICONIFIED))
		{
			register struct Message *msg;

			eg->appicon=NULL;
			if(eg->diskobj)
			{
				if(eg->appicon=AddAppIconA(	ID_APPICON, 0L,
																		eg->basename,
																		eg->msgport,
																		NULL, eg->diskobj, NULL))
				{
					SETBIT(eg->flags, EG_ICONIFIED);
					egCloseAllTasks(eg);
					success=TRUE;
				}
			}
			while(msg=GetMsg(eg->msgport))
				ReplyMsg(msg);
		}
	}
	else if(eg->appicon)
	{
		egOpenAllTasks(eg);
		RemoveAppIcon(eg->appicon);
		CLEARBIT(eg->flags, EG_ICONIFIED);
		success=TRUE;
	}
	return success;
}

#endif
