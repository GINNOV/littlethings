;/* Execute me to compile
gcc -o PrintReqExample PrintReqExample.c -lauto -lraauto
quit
:*/

#include <stdio.h>
#include <string.h>
#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/icon.h>


enum { 
	GAD_FROM = 0, 
	GAD_TO, 
	GAD_COPIES, 
	GAD_COLLATE 
};

long easy_req(struct Window *, char *, char *, char *, ...);
//void draw_collate(struct Window *, BOOL);

/* Image for the no-collate image. */
UWORD nocollate_data[450] =
{
	/* Plane 0 */
	0x0003, 0xFFFF, 0xC000, 0x07FF, 0xFF80,
	0x0002, 0x0000, 0x4000, 0x0400, 0x0080,
	0x0002, 0x0002, 0x6000, 0x0400, 0x04C0,
	0x0002, 0x5806, 0x6000, 0x04B0, 0x0CC0,
	0x01FF, 0xFFE2, 0x6003, 0xFFFF, 0xC4C0,
	0x0100, 0x0027, 0x6002, 0x0000, 0x4EC0,
	0x0100, 0x0330, 0x6002, 0x0006, 0x60C0,
	0x012E, 0x00B4, 0x6002, 0x5C01, 0x68C0,
	0xFFFF, 0xF130, 0x61FF, 0xFFE2, 0x60C0,
	0x8000, 0x13B0, 0x6100, 0x0027, 0x60C0,
	0x8001, 0x9830, 0x6100, 0x0330, 0x60C0,
	0x9700, 0x5E30, 0x612E, 0x00BC, 0x60C0,
	0x8000, 0x9830, 0x6100, 0x0130, 0x60C0,
	0x9400, 0x5834, 0x6128, 0x00B0, 0x68C0,
	0x8001, 0x9830, 0x6100, 0x0330, 0x60C0,
	0x8B5F, 0x1830, 0x6116, 0xBE30, 0x60C0,
	0x8000, 0x1830, 0x6100, 0x0030, 0x60C0,
	0x97B6, 0x1E30, 0x612F, 0x6C3C, 0x60C0,
	0x8000, 0x1830, 0x6100, 0x0030, 0x60C0,
	0x8BA8, 0x1830, 0x6117, 0x5030, 0x60C0,
	0x8000, 0x183F, 0xE100, 0x0030, 0x7FC0,
	0x9BF7, 0x183F, 0xE137, 0xEE30, 0x7FC0,
	0x8000, 0x1830, 0x0100, 0x0030, 0x6000,
	0x9400, 0x1830, 0x0128, 0x0030, 0x6000,
	0x8000, 0x1FF0, 0x0100, 0x003F, 0xE000,
	0x9B00, 0x1FF0, 0x0136, 0x003F, 0xE000,
	0x8000, 0x1800, 0x0100, 0x0030, 0x0000,
	0x8000, 0x1800, 0x0100, 0x0030, 0x0000,
	0xFFFF, 0xF800, 0x01FF, 0xFFF0, 0x0000,
	0x3FFF, 0xF800, 0x007F, 0xFFF0, 0x0000,
	/* Plane 1 */
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x0001, 0xFFFF, 0x8000, 0x03FF, 0xFF00,
	0x0001, 0xFFFD, 0x8000, 0x03FF, 0xFB00,
	0x0001, 0xDBF9, 0x8000, 0x03B7, 0xF300,
	0x0000, 0x001D, 0x8000, 0x0000, 0x3B00,
	0x00FF, 0xFFD8, 0x8001, 0xFFFF, 0xB100,
	0x00FF, 0xFCCF, 0x8001, 0xFFF9, 0x9F00,
	0x00ED, 0xFF47, 0x8001, 0xDBFE, 0x8F00,
	0x0000, 0x0ECF, 0x8000, 0x001D, 0x9F00,
	0x7FFF, 0xEC47, 0x80FF, 0xFFD8, 0x8F00,
	0x7FFE, 0x67CF, 0x80FF, 0xFCCF, 0x9F00,
	0x76FF, 0xA7CF, 0x80ED, 0xFF4F, 0x9F00,
	0x7FFF, 0x67CF, 0x80FF, 0xFECF, 0x9F00,
	0x77FF, 0xA3C7, 0x80EF, 0xFF47, 0x8F00,
	0x7FFE, 0x67CF, 0x80FF, 0xFCCF, 0x9F00,
	0x6BDF, 0xE7CF, 0x80D7, 0xBFCF, 0x9F00,
	0x7FFF, 0xE7CF, 0x80FF, 0xFFCF, 0x9F00,
	0x76F5, 0xE7CF, 0x80ED, 0xEBCF, 0x9F00,
	0x7FFF, 0xE7CF, 0x80FF, 0xFFCF, 0x9F00,
	0x6BEF, 0xE7CF, 0x80D7, 0xDFCF, 0x9F00,
	0x7FFF, 0xE7C0, 0x00FF, 0xFFCF, 0x8000,
	0x7AF7, 0xE7C0, 0x00F5, 0xEFCF, 0x8000,
	0x7FFF, 0xE7C0, 0x00FF, 0xFFCF, 0x8000,
	0x77FF, 0xE7C0, 0x00EF, 0xFFCF, 0x8000,
	0x7FFF, 0xE000, 0x00FF, 0xFFC0, 0x0000,
	0x7BFF, 0xE000, 0x00F7, 0xFFC0, 0x0000,
	0x7FFF, 0xE000, 0x00FF, 0xFFC0, 0x0000,
	0x7FFF, 0xE000, 0x00FF, 0xFFC0, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
};

struct Image nocollate_image =
{
	0, 0, 74, 30, 2, &nocollate_data[0], 0x3, 0x0, NULL
};

/* Image for the no-collate image. */
UWORD collate_data[468] =
{
	/* Plane 0 */
	0x01FF, 0xFFE0, 0x07FF, 0xFF80, 0x1FFF, 0xFE00,
	0x0100, 0x0020, 0x0400, 0x0080, 0x1000, 0x0200,
	0x0100, 0x0130, 0x0400, 0x0CC0, 0x1000, 0x3300,
	0x012C, 0x0330, 0x04B0, 0x02C0, 0x12C0, 0x0B00,
	0xFFFF, 0xF133, 0xFFFF, 0xC4CF, 0xFFFF, 0x1300,
	0x8000, 0x13B2, 0x0000, 0x4EC8, 0x0001, 0x0B00,
	0x8000, 0x9832, 0x0006, 0x60C8, 0x0019, 0xB300,
	0x9701, 0x9A32, 0x5C01, 0x68C9, 0x7005, 0xA300,
	0x8000, 0x9832, 0x0002, 0x60C8, 0x0009, 0x8300,
	0x9401, 0xD832, 0x5007, 0x60C9, 0x4005, 0x8300,
	0x8000, 0x1832, 0x0000, 0x60C8, 0x0019, 0x8300,
	0x8B5F, 0x1832, 0x2D7C, 0x60C8, 0xB5F1, 0x8300,
	0x8000, 0x1832, 0x0000, 0x60C8, 0x0001, 0x8300,
	0x97B4, 0x1A32, 0x5ED0, 0x68C9, 0x7B41, 0xA300,
	0x8000, 0x1832, 0x0000, 0x60C8, 0x0001, 0x8300,
	0x8BA8, 0x1832, 0x2EA0, 0x60C8, 0xBA81, 0x8300,
	0x8000, 0x1832, 0x0000, 0x60C8, 0x0001, 0x8300,
	0x9BF7, 0x1832, 0x6FDC, 0x60C9, 0xBF71, 0x8300,
	0x8000, 0x1832, 0x0000, 0x60C8, 0x0001, 0x8300,
	0x9400, 0x1832, 0x5000, 0x60C9, 0x4001, 0x8300,
	0x8000, 0x1FF2, 0x0000, 0x7FC8, 0x0001, 0xFF00,
	0x9B00, 0x1FF2, 0x6C00, 0x7FC9, 0xB001, 0xFF00,
	0x8000, 0x1802, 0x0000, 0x6008, 0x0001, 0x8000,
	0x8000, 0x1802, 0x0000, 0x6008, 0x0001, 0x8000,
	0xFFFF, 0xF803, 0xFFFF, 0xE00F, 0xFFFF, 0x8000,
	0x3FFF, 0xF800, 0xFFFF, 0xE003, 0xFFFF, 0x8000,
	/* Plane 1 */
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x00FF, 0xFFC0, 0x03FF, 0xFF00, 0x0FFF, 0xFC00,
	0x00FF, 0xFEC0, 0x03FF, 0xF300, 0x0FFF, 0xCC00,
	0x00ED, 0xFCC0, 0x03B7, 0xFD00, 0x0EDF, 0xF400,
	0x0000, 0x0EC0, 0x0000, 0x3B00, 0x0000, 0xEC00,
	0x7FFF, 0xEC41, 0xFFFF, 0xB107, 0xFFFE, 0xF400,
	0x7FFF, 0x67C1, 0xFFF9, 0x9F07, 0xFFE6, 0x4C00,
	0x76FE, 0x63C1, 0xDBFE, 0x8F07, 0x6FFA, 0x3C00,
	0x7FFF, 0x67C1, 0xFFFD, 0x9F07, 0xFFF6, 0x7C00,
	0x77FE, 0x23C1, 0xDFF8, 0x8F07, 0x7FFA, 0x3C00,
	0x7FFF, 0xE7C1, 0xFFFF, 0x9F07, 0xFFE6, 0x7C00,
	0x6BDF, 0xE7C1, 0xAF7F, 0x9F06, 0xBDFE, 0x7C00,
	0x7FFF, 0xE7C1, 0xFFFF, 0x9F07, 0xFFFE, 0x7C00,
	0x76F5, 0xE3C1, 0xDBD7, 0x8F07, 0x6F5E, 0x3C00,
	0x7FFF, 0xE7C1, 0xFFFF, 0x9F07, 0xFFFE, 0x7C00,
	0x6BEF, 0xE7C1, 0xAFBF, 0x9F06, 0xBEFE, 0x7C00,
	0x7FFF, 0xE7C1, 0xFFFF, 0x9F07, 0xFFFE, 0x7C00,
	0x7AF7, 0xE7C1, 0xEBDF, 0x9F07, 0xAF7E, 0x7C00,
	0x7FFF, 0xE7C1, 0xFFFF, 0x9F07, 0xFFFE, 0x7C00,
	0x77FF, 0xE7C1, 0xDFFF, 0x9F07, 0x7FFE, 0x7C00,
	0x7FFF, 0xE001, 0xFFFF, 0x8007, 0xFFFE, 0x0000,
	0x7BFF, 0xE001, 0xEFFF, 0x8007, 0xBFFE, 0x0000,
	0x7FFF, 0xE001, 0xFFFF, 0x8007, 0xFFFE, 0x0000,
	0x7FFF, 0xE001, 0xFFFF, 0x8007, 0xFFFE, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
};

struct Image collate_image =
{
	0, 0, 88, 26, 2, &collate_data[0], 0x3, 0x0, NULL
};

/* Here's where it all starts. */
main()
{
	struct Screen *screen = NULL;

	if (!ButtonBase) return(20);

	/* We'll just open up on the default public screen, and use its screen font */
	if (screen = IIntuition->LockPubScreen(NULL))
	{
		struct DrawInfo *drinfo = IIntuition->GetScreenDrawInfo(screen);
		struct Image   *collate_limage, *nocollate_limage;
		struct Gadget *collate_gad, *nocollate_gad;
		Object *layout, *collate_layout;
		UWORD mapping[4];

		/* Setup a simple mapping.*/
		mapping[0] = drinfo->dri_Pens[BACKGROUNDPEN];
		mapping[1] = drinfo->dri_Pens[SHADOWPEN];
		mapping[2] = drinfo->dri_Pens[SHINEPEN];
		mapping[3] = drinfo->dri_Pens[FILLPEN];

		/* Create radio button labels. */
		STRPTR radio_list[] =  { "All Pages", "Odd Pages", "Even Pages", "Current Page", "Range of Pages:", NULL };

		nocollate_limage = LabelObject,
			LABEL_Image, &nocollate_image,
		LabelEnd;
		collate_limage = LabelObject,	
			LABEL_Image, &collate_image,
		LabelEnd;

		if (layout = LayoutObject,
						GA_DrawInfo, drinfo,
						LAYOUT_DeferLayout, TRUE,	/* Layout refreshes done on
												 * task's context (by the
												 * window class) */
						LAYOUT_SpaceOuter, TRUE,
						LAYOUT_ShrinkWrap, TRUE,
						LAYOUT_VertAlignment, LAYOUT_ALIGN_TOP,
						LAYOUT_Orientation, LAYOUT_ORIENT_VERT,

						LAYOUT_AddChild, LayoutObject,
							LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
							LAYOUT_VertAlignment, LAYOUT_ALIGN_CENTER,
							LAYOUT_SpaceOuter, TRUE,

							LAYOUT_AddImage,  LabelObject,
								IA_Font, screen->Font,
								LABEL_Text, "Driver:",
							LabelEnd,
						
							CHILD_WeightedWidth, 0,
							CHILD_WeightedHeight, 0,

							LAYOUT_AddChild, ButtonObject,
								GA_Text, "EpsonX",
								GA_ReadOnly, TRUE,
								ButtonEnd,
							LayoutEnd,
						CHILD_WeightedHeight, 0,

						LAYOUT_AddChild, LayoutObject,
							LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,

							LAYOUT_AddChild, LayoutObject,
								LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
								LAYOUT_SpaceOuter, TRUE,
								LAYOUT_BevelStyle, BVS_GROUP,
								LAYOUT_Label, "Page Range",

								LAYOUT_AddChild, RadioButtonObject,
									GA_DrawInfo, drinfo,
									GA_Text, radio_list,
									RADIOBUTTON_Spacing, 3,
								RadioButtonEnd,
	
								LAYOUT_AddChild, LayoutObject,
									LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
									LAYOUT_VertAlignment, LAYOUT_ALIGN_CENTER,
	
									CHILD_WeightedWidth, 0,
									CHILD_WeightedHeight, 0,
	
									LAYOUT_AddChild, IntegerObject,
										INTEGER_Number, 1,
										INTEGER_Minimum, 0,
									IntegerEnd,

									CHILD_Label, LabelObject, 
										IA_Font, screen->Font,
										LABEL_Text, "from:",
									LabelEnd,
									
									CHILD_WeightedHeight, 0,
	
									LAYOUT_AddChild, IntegerObject,
										INTEGER_Number, 1,
										INTEGER_Minimum, 0,
									IntegerEnd,

									CHILD_Label, LabelObject,
										IA_Font, screen->Font,
										LABEL_Text, " to:",
									LabelEnd,

									CHILD_WeightedHeight, 0,

								LayoutEnd,
							LayoutEnd,
	
							LAYOUT_AddChild, LayoutObject,
								LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
								LAYOUT_SpaceOuter, TRUE,
								LAYOUT_BevelStyle, BVS_GROUP,
								LAYOUT_Label, "Copies",
								LAYOUT_VertAlignment, LAYOUT_ALIGN_TOP,
								LAYOUT_ShrinkWrap, TRUE,
	
								LAYOUT_AddChild, LayoutObject,
									LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
									LAYOUT_VertAlignment, LAYOUT_ALIGN_CENTER,
	
									LAYOUT_AddImage, LabelObject,
										IA_Font, screen->Font,
										LABEL_Text, "Number of Copies:",
									LabelEnd,
								
									CHILD_WeightedWidth, 0,
									CHILD_WeightedHeight, 0,
	
									LAYOUT_AddChild, IntegerObject,
										INTEGER_Number, 1,
										INTEGER_Minimum, 0,
									IntegerEnd,
	
								LayoutEnd,
	
								LAYOUT_AddChild, LayoutObject,
									LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
									LAYOUT_VertAlignment, LAYOUT_ALIGN_CENTER,
	
									LAYOUT_AddChild, CheckBoxObject,
										GA_ID, GAD_COLLATE,
										GA_Text, "Collate Pages?",
										GA_RelVerify, TRUE,
									CheckBoxEnd,
									CHILD_MinHeight, screen->Font->ta_YSize + 6,
	
								LayoutEnd,
	
								LAYOUT_AddChild, collate_layout = LayoutObject,
									LAYOUT_HorizAlignment, LAYOUT_ALIGN_CENTER,
									LAYOUT_AddChild, collate_gad = ButtonObject,
										GA_Image, nocollate_limage,
										GA_ReadOnly, TRUE,
									ButtonEnd,
									CHILD_MinWidth, 100,
									CHILD_MinHeight, 40,
									CHILD_WeightedWidth, 0,
								LayoutEnd,
	
							LayoutEnd,
						LayoutEnd,
						CHILD_WeightedHeight, 0,

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

			/* Create the window object. */
			if (window_obj = WindowObject,
								WA_Left, 0,
								WA_Top, screen->Font->ta_YSize + 3,
								WA_CustomScreen, screen,
								WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW,
								WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET |
											WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH,
								WA_Title, "Print Requester example",
								WA_NewLookMenus, TRUE,
								WINDOW_ParentGroup, layout,
								WINDOW_IconifyGadget, TRUE,
								WINDOW_Icon, IIcon->GetDiskObject("PROGDIR:PrintReq"),
								WINDOW_IconTitle, "PrintReq",
								WINDOW_AppPort, app_port,
								WINDOW_LockHeight, TRUE,
								TAG_DONE))
			{
				struct Window *win;

				/*  Open the window. */
				if (win = (struct Window *)RA_OpenWindow(window_obj))
				{
					ULONG signal;
					BOOL ok = TRUE, collate = FALSE;

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
										case GAD_COLLATE:
											collate = !collate;
											if (collate)
											{
												IIntuition->SetGadgetAttrs(collate_gad, win, NULL,
													GA_Image, collate_limage,
													TAG_DONE);
											}
											else
											{
												IIntuition->SetGadgetAttrs(collate_gad, win, NULL,
													GA_Image, nocollate_limage,
													TAG_DONE);
											}
											ILayout->RethinkLayout((struct Gadget *)collate_layout, win, NULL, TRUE);
											break;

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
					easy_req(NULL, "PrintReq failed to start\nCouldn't open window", "Quit", "");

				/* Disposing of the window object will also close the
				 * window if it is already opened and it will dispose of
				 * all objects attached to it.
				 */
				IIntuition->DisposeObject(window_obj);
			}
			else
				easy_req(NULL, "PrintReq failed to start\nCouldn't create window", "Quit", "");

			/* Loose the App* message port.	 */
			if (app_port)
				IExec->DeleteMsgPort(app_port);
		}
		else
			easy_req(NULL, "PrintReq failed to start\nCouldn't create layout", "Quit", "");

		/* Get rid of our images. */
		if (collate_limage)
			IIntuition->DisposeObject(collate_limage);
		if (nocollate_limage)
			IIntuition->DisposeObject(nocollate_limage);

		if (drinfo)
			IIntuition->FreeScreenDrawInfo(screen, drinfo);

	    IIntuition->UnlockPubScreen(0, screen);
	}
	else
		easy_req(NULL, "PrintReq failed to start\nCouldn't lock destination screen", "Quit", "");

	exit(0);
}

/* Do an easy requester. */
long easy_req(struct Window *win, char *reqtext, char *reqgads, char *reqargs, ...)
{
	struct EasyStruct general_es =
	{
		sizeof(struct EasyStruct),
		0,
		"SBGen",
		NULL,
		NULL
	};

	general_es.es_TextFormat = reqtext;
	general_es.es_GadgetFormat = reqgads;

	return(IIntuition->EasyRequestArgs(win, &general_es, NULL, &reqargs));
}
