/*
 *	File:					GroupFrameClassTester.c
 *	Description:	
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#include <exec/types.h>
#include <libraries/gadtools.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <utility/utility.h>
#include <utility/tagitem.h>
#include <intuition/imageclass.h>
#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <pragmas/graphics_pragmas.h>

struct IntuitionBase	*IntuitionBase;
struct GfxBase				*GfxBase;
struct Library				*GadToolsBase,
											*UtilityBase;
#define	LIBVER	37L

#include <string.h>
#include "ProgressClass.c"

/*** FUNCTIONS ***********************************************************************/
void main(void)
{
	Class *frameclass;

	if(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", LIBVER))
	{
		if(UtilityBase=OpenLibrary("utility.library", LIBVER))
		{
			if(GadToolsBase=OpenLibrary("gadtools.library", LIBVER))
			{
				if(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library", LIBVER))
				{
//					if(frameclass=initGroupFrameClass())
					if(frameclass=initProgressGadgetClass(IntuitionBase, UtilityBase, GfxBase))
					{
						struct Window *window;

						if(window=OpenWindowTags(NULL,
												WA_Title,					"GroupFrameTest",
												WA_Width,					320,
												WA_Height,				80,
												WA_AutoAdjust,		TRUE,
												WA_Activate,			TRUE,
												WA_DragBar,				TRUE,
												WA_DepthGadget,		TRUE,
												WA_SizeBBottom,		TRUE,
												WA_CloseGadget,		TRUE,
												WA_IDCMP,					IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
												TAG_DONE))
						{
							struct Gadget *pro, *tmpgad, *glist;

							tmpgad= (struct Gadget *)&glist;

							if(pro=NewObject(frameclass, NULL,
									GA_ID,					1L,
									GA_Top,					window->BorderTop + 2,
									GA_Left,				20,
									GA_Width,				200,
									GA_Height,			17,
//									PRO_Min,				100,
//									PRO_Max,				200,
//									PRO_ShowPercent,TRUE,
									GA_Previous,		tmpgad,
									TAG_END))
							{
								struct IntuiMessage *msg;
								BOOL								done=FALSE;

								AddGList(window, glist, -1, -1, NULL);

								while(!done)
								{
									Wait(1L<<window->UserPort->mp_SigBit);
									msg=GT_GetIMsg(window->UserPort);
							
									switch(msg->Class)
									{
										case IDCMP_REFRESHWINDOW:
											GT_BeginRefresh(window);
											GT_EndRefresh(window, TRUE);
											break;
										case IDCMP_CLOSEWINDOW:
											done=TRUE;
											break;
									}
									GT_ReplyIMsg(msg);
								}
								RemoveGList(window, glist, -1);
								DisposeObject(pro);
							}
							CloseWindow(window);
						}
						FreeClass(frameclass);
					}
					CloseLibrary((struct Library *)GfxBase);
				}
				CloseLibrary(GadToolsBase);
			}
			CloseLibrary(UtilityBase);
		}
		CloseLibrary((struct Library *)IntuitionBase);
	}
}
