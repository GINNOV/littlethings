;/* execute me to compile
gcc -o GlyphExample GlyphExample.c -lauto -lraauto
quit
*/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/icon.h>
#include <proto/intuition.h>
#include <stdio.h>
#include <string.h>


/* Here's where it all starts. */
main()
{
	struct Screen *screen = NULL;

	if (!ButtonBase) return(20);

	/* We'll just open up on the default public screen, and use its screen font. */
	if (screen = IIntuition->LockPubScreen(NULL))
	{
		struct DrawInfo *drinfo = IIntuition->GetScreenDrawInfo(screen);
		Object *layout;

		if (layout = LayoutObject,
						GA_DrawInfo, drinfo,
						LAYOUT_DeferLayout, TRUE,	/* Layout refreshes done on
												 * task's context (by the
												 * window class) */
						LAYOUT_SpaceOuter, TRUE,
						LAYOUT_AddChild, LayoutObject,
							LAYOUT_VertAlignment, LAYOUT_ALIGN_TOP,
							LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
							LAYOUT_BevelStyle, BVS_GROUP,
							LAYOUT_Label, "Available Glyphs",

							LAYOUT_AddChild, LayoutObject,
								LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
								LAYOUT_HorizAlignment, LAYOUT_ALIGN_RIGHT,
								LAYOUT_SpaceOuter, TRUE,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_DOWNARROW,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Down Arrow:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_UPARROW,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Up Arrow:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_LEFTARROW,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Left Arrow:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_RIGHTARROW,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Right Arrow:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_DROPDOWN,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Drop Down:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_CHECKMARK,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Check Mark:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_RADIOBUTTON,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Radio Button:",
										LabelEnd,
								LayoutEnd,
	
							LAYOUT_AddChild, LayoutObject,
								LAYOUT_SpaceOuter, TRUE,
								LAYOUT_AddImage, BevelObject,
									GA_DrawInfo, drinfo,
									BEVEL_Style, BVS_SBAR_HORIZ,
									BevelEnd,
								LayoutEnd,
								CHILD_MinWidth, 4,
								CHILD_WeightedWidth, 0,

							LAYOUT_AddChild, LayoutObject,
								LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
								LAYOUT_VertAlignment, LAYOUT_ALIGN_CENTER,
								LAYOUT_SpaceOuter, TRUE,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_POPUP,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Pop Up:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_POPFONT,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Pop Font:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_POPFILE,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Pop File:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_POPDRAWER,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Pop Drawer:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_POPSCREENMODE,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Pop Screen Mode:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_POPTIME,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Pop Time:",
										LabelEnd,
	
								LAYOUT_AddImage, GlyphObject,
									GLYPH_Glyph, GLYPH_RETURNARROW,
									GlyphEnd,
									CHILD_MinWidth, 12,
									CHILD_MinHeight, 12,
									CHILD_Label, LabelObject,
										LABEL_Text, "Return Arrow:",
										LabelEnd,
								LayoutEnd,
							LayoutEnd,
						LayoutEnd)
		{
			struct MsgPort *app_port;
			Object *window_obj;

			/* Create a message port for App* messages.  This is needed for
			 * iconification.  We're being a touch naughty by not checking
			 * the return code, but that just means that iconification won't
			 * work, nothing really bad will happen.
			 */
			app_port = IExec->CreateMsgPort();

			/* Create the window object */
			if (window_obj = WindowObject,
								WA_Left, 0,
								WA_Top, screen->Font->ta_YSize + 3,
								WA_CustomScreen, screen,
								WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW,
								WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET |
											WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH,
								WA_Title, "Glyph class example",
								WA_NewLookMenus, TRUE,
								WINDOW_ParentGroup, layout,
								WINDOW_IconifyGadget, TRUE,
								WINDOW_Icon, IIcon->GetDiskObject("PROGDIR:GlyphExample"),
								WINDOW_IconTitle, "GlyphExample",
								WINDOW_AppPort, app_port,
								TAG_DONE))
			{
				struct Window *win;

				/*  Open the window. */
				if (win = (struct Window *)RA_OpenWindow(window_obj))
				{
					ULONG signal;
					BOOL ok = TRUE;

					/* Obtain the window wait signal mask. */
					IIntuition->GetAttr(WINDOW_SigMask, window_obj, &signal);

					/* Input Event Loop */
					while (ok)
					{
						ULONG result;

						IExec->Wait(signal | (1L << app_port->mp_SigBit));

						/* RA_HandleInput() returns the gadget ID of a clicked
						 * gadget, or one of several pre-defined values.  For
						 * this demo, we're only actually interested in a
						 * close window and a couple of gadget clicks.
						 */
						while ((result = RA_HandleInput(window_obj, NULL)) != WMHI_LASTMSG)
						{
							switch(result & WMHI_CLASSMASK)
							{
								case WMHI_CLOSEWINDOW:
									ok = FALSE;
									break;

								case WMHI_GADGETUP:
									switch (result & WMHI_GADGETMASK)
									{
										default:
											break;
									}
									break;

								case WMHI_ICONIFY:
									if (RA_Iconify(window_obj))
										win = NULL;
									break;
							 
								case WMHI_UNICONIFY:
									win = RA_OpenWindow(window_obj);
									break;

								default:
									break;
							}
						}
					}
 				}
				else
					IDOS->PutStr("ERROR: failed to start.  Couldn't open window\n");

				/* Disposing of the window object will also close the
				 * window if it is already opened and it will dispose of
				 * all objects attached to it.
				 */
				IIntuition->DisposeObject(window_obj);
			}
			else
				IDOS->PutStr("ERROR: failed to start.  Couldn't create window\n");

			/* Lose the App* message port. */
			if (app_port)
				IExec->DeleteMsgPort(app_port);
		}
		else
			IDOS->PutStr("ERROR: failed to start.  Couldn't create layout\n");

		if (drinfo)
			IIntuition->FreeScreenDrawInfo(screen, drinfo);

	    	IIntuition->UnlockPubScreen(0, screen);
	}
	else
		IDOS->PutStr("ERROR: failed to start.  Couldn't lock destination screen\n");

	exit(0);
}
