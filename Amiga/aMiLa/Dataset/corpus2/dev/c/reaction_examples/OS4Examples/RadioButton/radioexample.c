;/* RadioButton Example
gcc -o RadioButton radioexample.c -lauto -lraauto
quit
*/

/**
 **  RadioExample.c -- radiobutton class example.
 **
 **  This is a simple example testing some of the capabilities of the
 **  radiobutton gadget class.
 **
 **  This opens a window with radio button gadget. We will use ReAction's
 **  new GA_Text tag to create the item labels.
 **
 **/

/* system includes
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>
#include <proto/exec.h>
#include <proto/intuition.h>

enum
{
	GID_MAIN=0,
	GID_RADIOBUTTON,
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

#define FMIN 0
#define FMAX 100

int main(void)
{
	struct MsgPort *AppPort;

	struct Window *windows[WID_LAST];

	struct Gadget *gadgets[GID_LAST];

	Object *objects[OID_LAST];

	/* make sure our classes opened... */
	if (!ButtonBase || !RadioButtonBase || !WindowBase || !LayoutBase)
		return(30);
	else if ( AppPort = IExec->CreateMsgPort() )
	{
		/* Create radiobutton label list. */
		UBYTE *radiolist[] = {"1200","2400","4800","9600","19200","38400","57600", NULL };

			/* Create the window object. */
			objects[OID_MAIN] = WindowObject,
				WA_ScreenTitle, "ReAction OS4",
				WA_Title, "ReAction RadioButton Example",
				WA_Activate, TRUE,
				WA_DepthGadget, TRUE,
				WA_DragBar, TRUE,
				WA_CloseGadget, TRUE,
				WA_SizeGadget, TRUE,
				WINDOW_IconifyGadget, TRUE,
				WINDOW_IconTitle, "RadioButton",
				WINDOW_AppPort, AppPort,
				WINDOW_Position, WPOS_CENTERMOUSE,
				WINDOW_ParentGroup, gadgets[GID_MAIN] = VGroupObject,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_DeferLayout, TRUE,

					LAYOUT_AddChild, VGroupObject,
						LAYOUT_SpaceOuter, TRUE,
						LAYOUT_BevelStyle, BVS_GROUP,
						LAYOUT_Label, "Baud Rate",

						LAYOUT_AddChild, gadgets[GID_RADIOBUTTON] = RadioButtonObject,
							GA_ID, GID_RADIOBUTTON,
							GA_RelVerify, TRUE,
							GA_Text, radiolist,
							RADIOBUTTON_Selected, 0,
						RadioButtonEnd,
					LayoutEnd,

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
			/*  Open the window.*/
			if (windows[WID_MAIN] = (struct Window *) RA_OpenWindow(objects[OID_MAIN]))
			{
				ULONG wait, signal, app = (1L << AppPort->mp_SigBit);
				ULONG done = FALSE;
				ULONG result;
				UWORD code;

			 	/* Obtain the window wait signal mask.*/
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
										case GID_RADIOBUTTON:
											printf("You selected item: %d\n", (int)code );
											break;

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

		
		IExec->DeleteMsgPort(AppPort);
	}

	return(0);
}
