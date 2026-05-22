;/* FuelGauge Example
gcc -o FuelgaugeExample  fuelgaugeexample.c -lauto -lraauto
quit
*/

/* system includes
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>

enum
{
	GID_GAUGE=0,
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

#define FMIN 0
#define FMAX 100

int main(void)
{
	struct MsgPort *AppPort;

	struct Window *windows[WID_LAST];

	struct Gadget *gadgets[GID_LAST];

	Object *objects[OID_LAST];

	/* make sure our classes opened... */
	if (!ButtonBase || !FuelGaugeBase || !WindowBase || !LayoutBase)
		return(30);
	else if ( AppPort = IExec->CreateMsgPort() )
	{
		/* Create the window object. */
		objects[OID_MAIN] = WindowObject,
			WA_ScreenTitle, "ReAction OS4",
			WA_Title, "ReAction FuelGauge Example",
			WA_Activate, TRUE,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_SizeGadget, TRUE,
			WINDOW_IconifyGadget, TRUE,
			WINDOW_IconTitle, "FuelGauge",
			WINDOW_AppPort, AppPort,
			WINDOW_Position, WPOS_CENTERMOUSE,
			WINDOW_ParentGroup, VGroupObject,
				LAYOUT_SpaceOuter, TRUE,
				LAYOUT_DeferLayout, TRUE,

				LAYOUT_AddChild, gadgets[GID_GAUGE] = FuelGaugeObject,
					GA_ID, GID_GAUGE,
					FUELGAUGE_Orientation, FGORIENT_HORIZ,
					FUELGAUGE_Min, FMIN,
					FUELGAUGE_Max, FMAX,
					FUELGAUGE_Level, 0,
					FUELGAUGE_Percent, TRUE,
					FUELGAUGE_TickSize, 5,
					FUELGAUGE_Ticks, 5,
					FUELGAUGE_ShortTicks, TRUE,
				FuelGaugeEnd,

				LAYOUT_AddChild, VGroupObject,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_VertAlignment, LALIGN_CENTER,
					LAYOUT_HorizAlignment, LALIGN_CENTER,
					LAYOUT_BevelStyle, BVS_FIELD,

					LAYOUT_AddImage, LabelObject,
						LABEL_Text, "The fuelgauge supports optional tickmarks as\n",
						LABEL_Text, "well as vertical and horizontal orientation.\n",
						LABEL_Text, " \n",
						LABEL_Text, "You can set the min/max range, as well as\n",
						LABEL_Text, "options such as varargs ascii display,\n",
						LABEL_Text, "percentage display, and custom pen selection.\n",
					LabelEnd,
				LayoutEnd,


				LAYOUT_AddChild, HGroupObject,
					LAYOUT_SpaceOuter, FALSE,
					LAYOUT_EvenSize, TRUE,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_DOWN,
						GA_RelVerify, TRUE,
						GA_Text,"_Down",
					ButtonEnd,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_UP,
						GA_RelVerify, TRUE,
						GA_Text,"_Up",
					ButtonEnd,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_QUIT,
						GA_RelVerify, TRUE,
						GA_Text,"_Quit",
					ButtonEnd,
				LayoutEnd,
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
										case GID_DOWN:
											{
												int i;

												IIntuition->SetWindowAttr(windows[WID_MAIN], WA_BusyPointer, (APTR) TRUE, 0L );

												for( i = FMAX; i >= FMIN; i -= 5 )
												{
													IIntuition->SetGadgetAttrs(
														gadgets[GID_GAUGE],
														windows[WID_MAIN], NULL,
														FUELGAUGE_Level, i, TAG_DONE);
													IDOS->Delay(3);
												}

												IIntuition->SetWindowAttr(windows[WID_MAIN], WA_BusyPointer, (APTR) FALSE, 0L );

											}
											break;

										case GID_UP:
											{
												int i;

												IIntuition->SetWindowAttr(windows[WID_MAIN], WA_BusyPointer, (APTR) TRUE, 0L );

												for( i = FMIN; i <= FMAX; i += 5 )
												{
													IIntuition->SetGadgetAttrs(
														gadgets[GID_GAUGE],
														windows[WID_MAIN], NULL,
														FUELGAUGE_Level, i, TAG_DONE);
													IDOS->Delay(3);
												}

												IIntuition->SetWindowAttr(windows[WID_MAIN], WA_BusyPointer, (APTR) FALSE, 0L );
											}
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
