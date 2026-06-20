;/* Integer Example
gcc -o IntergerExample integerexample.c -lauto -lraauto
quit
*/

/**
 **  IntegerExample.c -- Integer class Example.
 **
 **  This is a simple example testing some of the capabilities of the
 **  Integer gadget class.
 **
 **  This code opens a window and then creates 2 Integer gadgets which
 **  are subsequently attached to the window's gadget list.  One uses
 **  arrows, one does not.  Notice that you can tab cycle between them.
 **/

/* system includes */
#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>
#include <proto/dos.h>


enum
{
	GID_MAIN=0,
	GID_INTEGER1,
	GID_INTEGER2,
	GID_DOWN,
	GID_UP,
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
	if (!ButtonBase || !IntegerBase || !WindowBase || !LayoutBase)
		return(30);
	else if ( AppPort = IExec->CreateMsgPort() )
	{
		/* Create the window object.
		 */
		objects[OID_MAIN] = WindowObject,
			WA_ScreenTitle, "Reaction OS4",
			WA_Title, "ReAction Integer Example",
			WA_Activate, TRUE,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_SizeGadget, TRUE,
			WINDOW_IconifyGadget, TRUE,
			WINDOW_IconTitle, "Integer",
			WINDOW_AppPort, AppPort,
			WINDOW_Position, WPOS_CENTERMOUSE,
			WINDOW_ParentGroup, gadgets[GID_MAIN] = VGroupObject,
				LAYOUT_SpaceOuter, TRUE,
				LAYOUT_DeferLayout, TRUE,

				LAYOUT_AddChild, gadgets[GID_INTEGER1] = IntegerObject,
					GA_ID, GID_INTEGER1,
					GA_RelVerify, TRUE,
					GA_TabCycle, TRUE,
					INTEGER_Arrows, TRUE,
					INTEGER_MaxChars, 3,
					INTEGER_Minimum, -32,
					INTEGER_Maximum, 32,
					INTEGER_Number, 0,
				IntegerEnd,
				CHILD_NominalSize, TRUE,
				CHILD_Label, LabelObject, LABEL_Text, "Integer _1", LabelEnd,

				LAYOUT_AddChild, gadgets[GID_INTEGER2] = IntegerObject,
					GA_ID, GID_INTEGER2,
					GA_RelVerify, TRUE,
					GA_TabCycle, TRUE,
					INTEGER_Arrows, FALSE,
					INTEGER_MaxChars, 6,
					INTEGER_Minimum, 0,
					INTEGER_Maximum, 100000,
					INTEGER_Number, 100,
				IntegerEnd,
				CHILD_Label, LabelObject, LABEL_Text, "Integer _2", LabelEnd,

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

				/* Activate the first integer gadget! */
				ILayout->ActivateLayoutGadget( gadgets[GID_MAIN], windows[WID_MAIN], NULL, (Object)&gadgets[GID_INTEGER1] );

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

		IExec->DeleteMsgPort(AppPort);
	}

	return(0);
}
