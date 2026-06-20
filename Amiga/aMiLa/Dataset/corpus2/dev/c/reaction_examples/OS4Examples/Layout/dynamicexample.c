;/* Dynamic Example
gcc -o dynamicexample dynamicexample.c -lauto -lraauto
quit
*/

/* system includes */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>
#include <proto/intuition.h>
#include <proto/exec.h>

#include <libraries/gadtools.h>


enum
{
	GID_MAIN=0,
	GID_ADDBUTTON,
	GID_REMBUTTON,
	GID_REPLACE,
	GID_ADDED,
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

	/* we must initialize this pointer! */
	gadgets[GID_ADDED] = NULL;

	/* make sure our classes opened... */
	if (!ButtonBase || !CheckBoxBase || !WindowBase || !LayoutBase)
		return(30);
	else if ( AppPort = IExec->CreateMsgPort() )
	{
		/* Create the window object. */
		objects[OID_MAIN] = WindowObject,
			WA_ScreenTitle, "Reaction OS4",
			WA_Title, "ClassAct Dynamic Layout Example",
			WA_Activate, TRUE,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_SizeGadget, TRUE,
			WINDOW_IconifyGadget, TRUE,
			WINDOW_IconTitle, "Dynamic Iconified",
			WINDOW_AppPort, AppPort,
			WINDOW_Position, WPOS_CENTERMOUSE,
			WINDOW_ParentGroup, gadgets[GID_MAIN] = VGroupObject,
				LAYOUT_DeferLayout, TRUE,
				LAYOUT_SpaceOuter, TRUE,

				LAYOUT_AddChild, HGroupObject,
					LAYOUT_EvenSize, TRUE,
					LAYOUT_AddChild, gadgets[GID_ADDBUTTON] = ButtonObject,
						GA_ID, GID_ADDBUTTON,
						GA_RelVerify, TRUE,
						GA_Text, "_AddChild",
					ButtonEnd,

					LAYOUT_AddChild, gadgets[GID_REMBUTTON] = ButtonObject,
						GA_ID, GID_REMBUTTON,
						GA_RelVerify, TRUE,
						GA_Text, "_RemoveChild",
						GA_Disabled, TRUE,
					ButtonEnd,

					LAYOUT_AddChild, gadgets[GID_REPLACE] = ButtonObject,
						GA_ID, GID_REPLACE,
						GA_RelVerify, TRUE,
						GA_Text, "Replace",
						GA_Disabled, TRUE,
					ButtonEnd,

					LAYOUT_AddChild, gadgets[GID_QUIT] = ButtonObject,
						GA_ID, GID_QUIT,
						GA_RelVerify, TRUE,
						GA_Text,"_Quit",
					ButtonEnd,
				LayoutEnd,

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
										case GID_ADDBUTTON:
											if (gadgets[GID_ADDED] == NULL)
											{
												IIntuition->SetGadgetAttrs(gadgets[GID_ADDBUTTON], windows[WID_MAIN], NULL,
													GA_Disabled, TRUE,
													TAG_DONE);
												IIntuition->SetGadgetAttrs(gadgets[GID_REMBUTTON], windows[WID_MAIN], NULL,
													GA_Disabled, FALSE,
													TAG_DONE);
												IIntuition->SetGadgetAttrs(gadgets[GID_REPLACE], windows[WID_MAIN], NULL,
													GA_Disabled, FALSE,
													TAG_DONE);

												/* add a new child! */
												IIntuition->SetGadgetAttrs(gadgets[GID_MAIN], windows[WID_MAIN], NULL,
													LAYOUT_Inverted, TRUE,	// Causes AddHead vs. AddTail!
													LAYOUT_AddChild, gadgets[GID_ADDED] = ButtonObject,
														GA_ID, GID_ADDED,
														GA_RelVerify, TRUE,
														GA_Text, "Peekaboo!",
													ButtonEnd,
													TAG_DONE);

												/* rethink the window layout */
												if (IIntuition->IDoMethod(objects[OID_MAIN], WM_RETHINK) == 0)
													IIntuition->IDoMethod(objects[OID_MAIN], WM_NEWPREFS);
											}
											break;

										case GID_REMBUTTON:
											if (gadgets[GID_ADDED] != NULL)
											{
												IIntuition->SetGadgetAttrs(gadgets[GID_ADDBUTTON], windows[WID_MAIN], NULL,
													GA_Disabled, FALSE,
													TAG_DONE);
												IIntuition->SetGadgetAttrs(gadgets[GID_REMBUTTON], windows[WID_MAIN], NULL,
													GA_Disabled, TRUE,
													TAG_DONE);
												IIntuition->SetGadgetAttrs(gadgets[GID_REPLACE], windows[WID_MAIN], NULL,
													GA_Disabled, TRUE,
													TAG_DONE);

												/* remove the child! */
												IIntuition->SetGadgetAttrs(gadgets[GID_MAIN], windows[WID_MAIN], NULL,
													LAYOUT_RemoveChild, gadgets[GID_ADDED],
													TAG_DONE);

												/* clear the pointer */
												gadgets[GID_ADDED] = NULL;
												
												/* bring the window back to minimum size again */
												IIntuition->SizeWindow( windows[WID_MAIN], 64000, 64000 );

												/* rethink the window layout */
												if (IIntuition->IDoMethod(objects[OID_MAIN], WM_RETHINK) == 0)
													IIntuition->IDoMethod(objects[OID_MAIN], WM_NEWPREFS);
											}
											break;

										case GID_REPLACE:
											if (gadgets[GID_ADDED] != NULL)
											{
												struct Gadget *temp = NULL;

												IIntuition->SetGadgetAttrs(gadgets[GID_REPLACE], windows[WID_MAIN], NULL,
													GA_Disabled, TRUE,
													TAG_DONE);

												/* replace the child! */
												IIntuition->SetGadgetAttrs(gadgets[GID_MAIN], windows[WID_MAIN], NULL,
													LAYOUT_ModifyChild, gadgets[GID_ADDED],
														CHILD_ReplaceObject, temp = CheckBoxObject,
															GA_ID, GID_ADDED,
															GA_RelVerify, TRUE,
															GA_Text, "Peekaboo!",
															CHECKBOX_TextPlace, PLACETEXT_RIGHT,
														CheckBoxEnd,
													TAG_DONE);

												gadgets[GID_ADDED] = temp;

												/* rethink the window layout */
												if (IIntuition->IDoMethod(objects[OID_MAIN], WM_RETHINK) == 0)
													IIntuition->IDoMethod(objects[OID_MAIN], WM_NEWPREFS);
											}
											break;

										case GID_ADDED:
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
