;/* CheckBox Example
gcc -o CheckBoxExample checkboxexample_os4.c -lauto -lraauto
quit
*/

/**
 **  CheckBoxExample.c -- CheckBox class Example.
 **
 **  This is a simple example testing some of the capabilities of the
 **  CheckBox gadget class.
 **
 **  This code opens a window and then creates 2 CheckBox gadgets which
 **  are subsequently attached to the window's gadget list.  One uses
 **  arrows, one does not.  Notice that you can tab cycle between them.
 **/

/* system includes
 */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/window.h>
#include <proto/layout.h>
#include <proto/button.h>
#include <proto/checkbox.h>
#include <proto/label.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <classes/window.h>
#include <gadgets/checkbox.h>
#include <images/label.h>
#include <reaction/reaction_macros.h>
#include <libraries/gadtools.h>

enum
{
	GID_MAIN2=0,
	GID_CHECKBOX1,
	GID_CHECKBOX2,
	GID_DOWN,
	GID_UP,
	GID_QUIT,
	GID_LAST2
};

enum
{
	WID_INFO=0,
	WID_LAST
};

enum
{
	OID_INFO=0,
	OID_LAST
};

int main(void)
{
	struct MsgPort *AppPort;

	struct Window *windows[WID_LAST];

	struct Gadget *gadgets[GID_LAST2];

	Object *objects[OID_LAST];

	/* make sure our classes opened... */
	if (!ButtonBase || !CheckBoxBase || !WindowBase || !LayoutBase)
		return(30);
	else if ( AppPort = (struct MsgPort *)IExec->CreateMsgPort() )
	{
		/* Create the window object. */
		objects[OID_INFO] = WindowObject,
			WA_ScreenTitle, "ClassAct Release 2.0",
			WA_Title, "ClassAct CheckBox Example",
			WA_Activate, TRUE,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_SizeGadget, TRUE,
			WINDOW_IconifyGadget, TRUE,
			WINDOW_IconTitle, "CheckBox",
			WINDOW_AppPort, AppPort,
			WINDOW_Position, WPOS_CENTERMOUSE,
			WINDOW_ParentGroup, gadgets[GID_MAIN2] = VGroupObject,
				LAYOUT_SpaceOuter, TRUE,
				LAYOUT_DeferLayout, TRUE,

				LAYOUT_AddChild, gadgets[GID_CHECKBOX1] = CheckBoxObject,
					GA_ID, GID_CHECKBOX1,
					GA_RelVerify, TRUE,
					GA_Text, "CheckBox _1",
					CHECKBOX_TextPlace, PLACETEXT_RIGHT,
				CheckBoxEnd,
				CHILD_NominalSize, TRUE,

				LAYOUT_AddChild, gadgets[GID_CHECKBOX2] = CheckBoxObject,
					GA_ID, GID_CHECKBOX2,
					GA_RelVerify, TRUE,
					GA_Text, "CheckBox _2",
					CHECKBOX_TextPlace, PLACETEXT_LEFT,
				CheckBoxEnd,

				LAYOUT_AddChild, VGroupObject,
					GA_BackFill, NULL,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_VertAlignment, LALIGN_CENTER,
					LAYOUT_HorizAlignment, LALIGN_CENTER,
					LAYOUT_BevelStyle, BVS_FIELD,

					LAYOUT_AddImage, LabelObject,
						LABEL_Text, "The checkbox may have its label placed\n",
						LABEL_Text, "either on the left or right side.\n",
						LABEL_Text, " \n",
						LABEL_Text, "You may click the label text as well\n",
						LABEL_Text, "as the check box itself.\n",
					LabelEnd,
				LayoutEnd,

				LAYOUT_AddChild, ButtonObject,
					GA_ID, GID_QUIT,
					GA_RelVerify, TRUE,
					GA_Text,"_Quit",
				ButtonEnd,
				CHILD_WeightedHeight, 0,

			LayoutEnd,
		WindowEnd;

	 	/*  Object creation sucessful? */
		if (objects[OID_INFO])
		{
			/*  Open the window. */
			if (windows[WID_INFO] = (struct Window *) RA_OpenWindow(objects[OID_INFO]))
			{
				ULONG wait, signal, app = (1L << AppPort->mp_SigBit);
				ULONG done = FALSE;
				ULONG result;
				UWORD code;

			 	/* Obtain the window wait signal mask. */
				IIntuition->GetAttr(WINDOW_SigMask, objects[OID_INFO], &signal);

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
						while ( (result = RA_HandleInput(objects[OID_INFO], &code) ) != WMHI_LASTMSG )
						{
							switch (result & WMHI_CLASSMASK)
							{
								case WMHI_CLOSEWINDOW:
									windows[WID_INFO] = NULL;
									done = TRUE;
									break;

								case WMHI_GADGETUP:
									switch (result & WMHI_GADGETMASK)
									{
										case GID_CHECKBOX1:
											/* code is TRUE or FALSE depending on check state */
											break;

										case GID_CHECKBOX2:
											/* code is TRUE or FALSE depending on check state */
											break;

										case GID_QUIT:
											done = TRUE;
											break;
									}
									break;

								case WMHI_ICONIFY:
									RA_Iconify(objects[OID_INFO]);
									windows[WID_INFO] = NULL;
									break;

								case WMHI_UNICONIFY:
									windows[WID_INFO] = (struct Window *) RA_OpenWindow(objects[OID_INFO]);

									if (windows[WID_INFO])
									{
										IIntuition->GetAttr(WINDOW_SigMask, objects[OID_INFO], &signal);
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
			IIntuition->DisposeObject(objects[OID_INFO]);
		}

		IExec->DeleteMsgPort(AppPort);
	}

	return(0);
}
