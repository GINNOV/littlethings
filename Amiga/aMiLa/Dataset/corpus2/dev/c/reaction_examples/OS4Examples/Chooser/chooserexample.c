;/* Chooser Example
gcc -o chooserexample chooserexample.c -lauto -lraauto
quit
*/

/**
 **  ChoosserExample.c -- chooser class example.
 **
 **  This is a simple example testing some of the capabilities of the
 **  chooser gadget class.
  **/

/* system includes */
#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//#include <exec/types.h>
//#include <exec/memory.h>
//#include <intuition/intuition.h>
//#include <intuition/gadgetclass.h>
//#include <graphics/gfxbase.h>
//#include <graphics/text.h>
//#include <graphics/gfxmacros.h>
//#include <utility/tagitem.h>
//#include <workbench/startup.h>
//#include <workbench/workbench.h>

#include <proto/intuition.h>
//#include <proto/graphics.h>
#include <proto/exec.h>
#include <proto/dos.h>
//#include <proto/utility.h>
//#include <proto/wb.h>
//#include <proto/icon.h>

/* ClassAct includes
 */
//#include <classact.h>

/* button option texts */
UBYTE *chooser[] =
{
	"1200",
	"2400",
	"4800",
	"9600",
	"19200",
	"38400",
	"57600",
	"115200",
	"230400",
	NULL
};

enum
{
	GID_MAIN=0,
	GID_CHOOSER1,
	GID_QUIT,
	GID_LAST
};

enum
{
	WID_MAIN=0,
	WID_LAST
};

enum
{
	OID_MAIN=0,
	OID_LAST
};

int main(void)
{
	struct MsgPort *AppPort;

	struct Window *windows[WID_LAST];

	struct Gadget *gadgets[GID_LAST];

	Object *objects[OID_LAST];

	/* make sure our classes opened... */
	if (!ButtonBase || !ChooserBase || !WindowBase || !LayoutBase)
		return(30);
	else if ( AppPort = IExec->CreateMsgPort() )
	{
		/* Create chooser label list. */
		STRPTR chooserlist1[] = { "1200","2400","4800","9600","19200","38400","57600", NULL };

		if (chooserlist1)
		{
			/* Create the window object. */
			objects[OID_MAIN] = WindowObject,
				WA_ScreenTitle, "Reaction OS4",
				WA_Title, "ReAction Chooser Example",
				WA_Activate, TRUE,
				WA_DepthGadget, TRUE,
				WA_DragBar, TRUE,
				WA_CloseGadget, TRUE,
				WA_SizeGadget, TRUE,
				WINDOW_IconifyGadget, TRUE,
				WINDOW_IconTitle, "Chooser",
				WINDOW_AppPort, AppPort,
				WINDOW_Position, WPOS_CENTERMOUSE,
				WINDOW_ParentGroup, gadgets[GID_MAIN] = VGroupObject,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_DeferLayout, TRUE,

					LAYOUT_AddChild, gadgets[GID_CHOOSER1] = ChooserObject,
						GA_ID, GID_CHOOSER1,
						GA_RelVerify, TRUE,
						CHOOSER_LabelArray, chooserlist1,
						CHOOSER_Selected, 0,
					ChooserEnd,
					CHILD_NominalSize, TRUE,
					CHILD_Label, LabelObject, LABEL_Text, "_Baud Rate", LabelEnd,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_QUIT,
						GA_RelVerify, TRUE,
						GA_Text,"_Quit",
					ButtonEnd,
					CHILD_WeightedHeight, 0,

				EndGroup,
			EndWindow;

	 	 	/*  Object creation sucessful? */
			if (objects[OID_MAIN])
			{
				/*  Open the window. */
				if (windows[WID_MAIN] = (struct Window *) RA_OpenWindow(objects[OID_MAIN]))
				{
					ULONG wait, signal, app = (1L << AppPort->mp_SigBit);
					ULONG done = FALSE;
					ULONG result;
					UWORD code;

				 	/* Obtain the window wait signal mask. */
					IIntuition->GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);

					/* Input Event Loop */
					while (!done)
					{
						wait = IExec->Wait( signal | SIGBREAKF_CTRL_C | app );

						if ( wait & SIGBREAKF_CTRL_C )
						{
							done = TRUE;
						}
						else
						{
							while ( (result = RA_HandleInput(objects[OID_MAIN], &code) ) != WMHI_LASTMSG )
							{
								switch (result & WMHI_CLASSMASK)
								{
									case WMHI_CLOSEWINDOW:
										windows[WID_MAIN] = NULL;
										done = TRUE;
										break;

									case WMHI_GADGETUP:
										switch (result & WMHI_GADGETMASK)
										{
											case GID_QUIT:
												done = TRUE;
												break;
										}
										break;

									case WMHI_ICONIFY:
										RA_Iconify(objects[OID_MAIN]);
										windows[WID_MAIN] = NULL;
										break;

									case WMHI_UNICONIFY:
										windows[WID_MAIN] = (struct Window *) RA_OpenWindow(objects[OID_MAIN]);

										if (windows[WID_MAIN])
										{
											IIntuition->GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);
										}
										else
										{
											done = TRUE;	// error re-opening window!
										}
									 	break;
								}
							}
						}
					}
				}

				/* Disposing of the window object will also close the window if it is
				 * already opened, and it will dispose of the layout object attached to it.
				 */
				IIntuition->DisposeObject(objects[OID_MAIN]);
			}

		}

		IExec->DeleteMsgPort(AppPort);
	}

	return(0);
}
