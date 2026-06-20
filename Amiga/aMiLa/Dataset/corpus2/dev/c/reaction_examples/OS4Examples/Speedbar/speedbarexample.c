;/* SpeedBar Example
gcc -o SpeedBar speedbarexample.c -lauto -lraauto
quit
*/

// system includes
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>

/* Local function prototypes.*/
BOOL make_speedbar_list(struct List *, struct Image *, UBYTE **);
VOID free_speedbar_list(struct List *);


/* Image data definitions. */
UWORD sb_data[][64] =
{
	/* Cut */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0e01, 0xc000, 0x1107, 0x8000,
		0x191e, 0x0000, 0x0f78, 0x0000,
		0x01e0, 0x0000, 0x0f78, 0x0000,
		0x191e, 0x0000, 0x1107, 0x8000,
		0x0e01, 0xc000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Copy */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x01fe, 0x0000, 0x0186, 0x0000,
		0x01fe, 0x0000, 0x0630, 0x8000,
		0x1fff, 0xe000, 0x1f87, 0xe000,
		0x1f03, 0xe000, 0x1f03, 0xe000,
		0x1f03, 0xe000, 0x1f87, 0xe000,
		0x1fff, 0xe000, 0x1fff, 0xe000,
		0x0000, 0x0000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0078, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0060, 0x0000, 0x0044, 0x0000,
		0x0004, 0x0000, 0x0018, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Paste */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x003f, 0x0000,
		0x0021, 0x0000, 0x007f, 0x8000,
		0x0080, 0x4000, 0x0081, 0xc000,
		0x0780, 0x4000, 0x0861, 0xc000,
		0x0f20, 0x4000, 0x0891, 0xc000,
		0x0950, 0x4000, 0x0251, 0xc000,
		0x05e0, 0x4000, 0x0880, 0xc000,
		0x307f, 0x8000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0006, 0x0000, 0x0000, 0x0000,
		0x0007, 0x0000, 0x0002, 0x0000,
		0x0002, 0x0000, 0x0782, 0x0000,
		0x00c2, 0x0000, 0x0062, 0x0000,
		0x0222, 0x0000, 0x0422, 0x0000,
		0x0802, 0x0000, 0x1002, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Erase */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x002e, 0xb800,
		0x005d, 0x7800, 0x00ba, 0xf800,
		0x01f5, 0xf000, 0x03eb, 0xe000,
		0x05f7, 0xc000, 0x08ff, 0x8000,
		0x107f, 0x0000, 0x103e, 0x0000,
		0x101c, 0x0000, 0x0828, 0x0000,
		0x0450, 0x0000, 0x02a0, 0x0000,
		0x01ff, 0xf800, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x001a, 0xa800,
		0x0035, 0x5000, 0x006a, 0xa000,
		0x0015, 0x4000, 0x000a, 0x8000,
		0x0205, 0x0000, 0x0502, 0x0000,
		0x0a80, 0x0000, 0x0540, 0x0000,
		0x0aa0, 0x0000, 0x0540, 0x0000,
		0x0280, 0x0000, 0x0100, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Mail */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0800, 0xd000,
		0x0094, 0xd000, 0x0000, 0x1000,
		0x0060, 0x1000, 0x0000, 0x1000,
		0x00d0, 0x1000, 0x0000, 0x1000,
		0x1fff, 0xf000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0018, 0x0000, 0x007c, 0x0000,
		0x01ca, 0x0000, 0x0515, 0x0000,
		0x3fff, 0xe000, 0x2bff, 0xe000,
		0x3e97, 0xe000, 0x3fff, 0xe000,
		0x3f6f, 0xe000, 0x3fff, 0xe000,
		0x3fd7, 0xe000, 0x3fff, 0xe000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Time */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x0070, 0x0000,
		0x0376, 0x0000, 0x06db, 0x0000,
		0x0505, 0x0000, 0x0262, 0x0000,
		0x0421, 0x0000, 0x0421, 0x0000,
		0x0439, 0x0000, 0x0401, 0x0000,
		0x0401, 0x0000, 0x0202, 0x0000,
		0x0104, 0x0000, 0x01fc, 0x0000,
		0x0306, 0x0000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0020, 0x0000,
		0x0000, 0x0000, 0x0098, 0x0000,
		0x01dc, 0x0000, 0x01dc, 0x0000,
		0x01c4, 0x0000, 0x01fc, 0x0000,
		0x01fc, 0x0000, 0x00f8, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Date */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x037b, 0x0000,
		0x0285, 0x8000, 0x0201, 0x8000,
		0x0201, 0x8000, 0x0299, 0x8000,
		0x02a7, 0x8000, 0x052b, 0x8000,
		0x0535, 0x8000, 0x080d, 0x8000,
		0x1ff5, 0x8000, 0x0205, 0x8000,
		0x0201, 0x8000, 0x03ff, 0x8000,
		0x01ff, 0x8000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x017a, 0x0000, 0x01fe, 0x0000,
		0x01fe, 0x0000, 0x0166, 0x0000,
		0x0158, 0x0000, 0x02d4, 0x0000,
		0x02c8, 0x0000, 0x07f2, 0x0000,
		0x0000, 0x0000, 0x00aa, 0x0000,
		0x0154, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	},
	/* Disk */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x0038, 0x0000,
		0x0054, 0x0000, 0x008e, 0x0000,
		0x0107, 0x0000, 0x0207, 0x8000,
		0x040b, 0xc000, 0x0417, 0xe000,
		0x0e29, 0xe000, 0x0750, 0xc000,
		0x03a0, 0x8000, 0x01d9, 0x8000,
		0x00eb, 0x0000, 0x0076, 0x0000,
		0x003c, 0x0000, 0x0010, 0x0000,
		/* Plane 1 */
		0x0020, 0x0000, 0x0070, 0x0000,
		0x00c0, 0x0000, 0x01a4, 0x0000,
		0x0352, 0x0000, 0x06ab, 0x0000,
		0x0d53, 0x8000, 0x12a1, 0xc000,
		0x1d46, 0xc000, 0x0e89, 0x0000,
		0x0710, 0x0000, 0x03ac, 0x8000,
		0x01d1, 0x0000, 0x00e2, 0x0000,
		0x0074, 0x0000, 0x0000, 0x0000 
	},
	/* Spray Paint */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x0186, 0xc000,
		0x01bf, 0x0000, 0x07ec, 0xc000,
		0x0423, 0x0000, 0x0ff0, 0xc000,
		0x1008, 0x0000, 0x1078, 0x0000,
		0x1078, 0x0000, 0x1078, 0x0000,
		0x1078, 0x0000, 0x1078, 0x0000,
		0x1008, 0x0000, 0x1038, 0x0000,
		0x1008, 0x0000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0006, 0xc000,
		0x003f, 0x0000, 0x000c, 0xc000,
		0x0243, 0x0000, 0x0000, 0xc000,
		0x02e0, 0x0000, 0x0440, 0x0000,
		0x0470, 0x0000, 0x0440, 0x0000,
		0x0470, 0x0000, 0x0440, 0x0000,
		0x0440, 0x0000, 0x0440, 0x0000,
		0x0440, 0x0000, 0x0000, 0x0000 
	},
	/* Print */
	{
		/* Plane 0 */
		0x0000, 0x0000, 0x03fe, 0x0000,
		0x0205, 0x0000, 0x02a7, 0x0000,
		0x0201, 0x0000, 0x02d5, 0x0000,
		0x0201, 0x0000, 0x0601, 0x8000,
		0x1fff, 0xe000, 0x2000, 0x1000,
		0x2803, 0xd000, 0x2000, 0x1000,
		0x3fff, 0xf000, 0x1fff, 0xe000,
		0x0fff, 0xc000, 0x0000, 0x0000,
		/* Plane 1 */
		0x0000, 0x0000, 0x0000, 0x0000,
		0x01fa, 0x0000, 0x0118, 0x0000,
		0x01fe, 0x0000, 0x0102, 0x0000,
		0x01fe, 0x0000, 0x01fe, 0x0000,
		0x0000, 0x0000, 0x1555, 0x4000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000,
		0x0000, 0x0000, 0x0000, 0x0000 
	}
};

/* Image structures for above data.
 */
struct Image sb_images[] =
{
	{ 0, 0, 22, 16, 2, sb_data[0], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[1], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[2], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[3], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[4], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[5], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[6], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[7], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[8], 0x03, 0x00, NULL },
	{ 0, 0, 22, 16, 2, sb_data[9], 0x03, 0x00, NULL },
};

/* speedbar window-title help strings. */
UBYTE *help_strs[] =
{
	"Erase block and copy it to the clipboard",
	"Copy block to the clipboard",
	"Paste from clipboard to your project",
	"Erase block",
	"Mail someone",
	"Insert current time",
	"Insert current date",
	"Disk",
	"Spray Paint",
	"Print project",
	NULL
};

/* object/gadget/button id's */

enum
{
	SBID_ERASECLIP=0,
	SBID_COPYCLIP,
	SBID_PASTECLIP,
	SBID_DELETE,
	SBID_EMAIL,
	SBID_INSTIME,
	SBID_INSDATE,
	SBID_SAVEDISK,
	SBID_PAINT,
	SBID_PRINT,
	SBID_LAST
};

enum
{
	GID_SPEEDBAR=0,
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


/* Create the SpeedBar Exec list. */
BOOL make_speedbar_list(struct List *list, struct Image *images, UBYTE **help)
{
	struct Node *node;
	WORD i = SBID_ERASECLIP;

	IExec->NewList(list);

	while (i < SBID_LAST)
	{
		if (node = (struct Node *)ISpeedBar->AllocSpeedButtonNode(
			i, /* speed button id! */
			SBNA_Image, images,
			SBNA_Help, *help,
			SBNA_Enabled, TRUE,
			SBNA_Spacing, 2,
			SBNA_Highlight, SBH_RECESS,
			TAG_DONE))
		{
			IExec->AddTail(list, node);
		}
		else
		{
			IDOS->PutStr("Allocation failed\n");
			return (FALSE);
		}

		images++;
		i++;
		help++;
	}
	return(TRUE);
}


/* Function to free a SpeedBar Exec List.
 */
VOID free_speedbar_list(struct List *list)
{
	struct Node *node, *nextnode;

	node = list->lh_Head;
	while (nextnode = node->ln_Succ)
	{
		ISpeedBar->FreeSpeedButtonNode(node);
		node = nextnode;
	}
	IExec->NewList(list);
}



int main(void)
{
	struct MsgPort *AppPort;

	struct Window *windows[WID_LAST];

	struct Gadget *gadgets[GID_LAST];

	Object *objects[OID_LAST];

	struct List speedbar_list;

	/* make sure our classes opened... */
	if (!ButtonBase || !SpeedBarBase || !WindowBase || !LayoutBase)
		return(30);

	if ( make_speedbar_list(&speedbar_list, sb_images, help_strs) )
	{
		if ( AppPort = IExec->CreateMsgPort() )	// this msgport is used for iconification. Create it before the window
		{
			/* Create the window object. */
			objects[OID_MAIN] = WindowObject,
				WA_ScreenTitle, "ReAction OS4",
				WA_Title, "ReAction SpeedBar Example",
				WA_Activate, TRUE,
				WA_DepthGadget, TRUE,
				WA_DragBar, TRUE,
				WA_CloseGadget, TRUE,
				WA_SizeGadget, TRUE,
				WINDOW_IconifyGadget, TRUE,
				WINDOW_IconTitle, "SpeedBar",
				WINDOW_AppPort, AppPort,
				WINDOW_Position, WPOS_CENTERMOUSE,
				WINDOW_ParentGroup, VGroupObject,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_DeferLayout, TRUE,

					LAYOUT_AddChild, gadgets[GID_SPEEDBAR] = SpeedBarObject,
						GA_ID, GID_SPEEDBAR,
						GA_RelVerify, TRUE,
						SPEEDBAR_Orientation, SPEEDBAR_HORIZONTAL,
						SPEEDBAR_Buttons, &speedbar_list,
						SPEEDBAR_Background, 4,		// this sets the background colour of the bar
					SpeedBarEnd,
					CHILD_MinWidth, 160,

					LAYOUT_AddChild, VGroupObject,
						LAYOUT_SpaceOuter, TRUE,
						LAYOUT_VertAlignment, LALIGN_CENTER,
						LAYOUT_HorizAlignment, LALIGN_CENTER,
						LAYOUT_BevelStyle, BVS_FIELD,

						LAYOUT_AddImage, LabelObject,
							LABEL_Text, "The speedbar supports a scrolling list of image\n",
							LABEL_Text, "buttons. When more buttons are available than\n",
							LABEL_Text, "the visible space, you may scroll the list by\n",
							LABEL_Text, "pressing the SHIFT key while clicking the LMB\n",
							LABEL_Text, "and dragging the mouse. The speedbar also\n",
							LABEL_Text, "supports several options such boolean buttons,\n",
							LABEL_Text, "and MX groups!\n",
						LabelEnd,
					LayoutEnd,


					LAYOUT_AddChild, gadgets[GID_QUIT] = ButtonObject,
						GA_ID, GID_QUIT,
						GA_RelVerify, TRUE,
						GA_Text,"_Quit",
					ButtonEnd,
					CHILD_WeightedHeight, 0,

				EndGroup,
			EndWindow;

		 	/*  Object creation sucessfull? */
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
											case GID_SPEEDBAR:
												printf("Speed Button Selected: %d\n", (int)code );
												switch ((int)code)
												{
													case SBID_ERASECLIP:
														break;

													case SBID_COPYCLIP:
														break;

													case SBID_PASTECLIP:
														break;
													/* ... */
												}
												break;

											case GID_QUIT:
												done = TRUE;
												break;
										}
										break;

									case WMHI_ICONIFY:
										RA_Iconify(objects[OID_MAIN]);
										IIntuition->SetAttrs(gadgets[GID_SPEEDBAR], SPEEDBAR_Window, NULL, TAG_DONE);
										windows[WID_MAIN] = NULL;
										break;

									case WMHI_UNICONIFY:
										windows[WID_MAIN] = (struct Window *) RA_OpenWindow(objects[OID_MAIN]);

										if (windows[WID_MAIN])
										{
											IIntuition->GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);

											if (gadgets[GID_SPEEDBAR])
											{
												IIntuition->SetAttrs(gadgets[GID_SPEEDBAR], SPEEDBAR_Window, windows[WID_MAIN], TAG_DONE);
											}
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

				/* Disposing of the window object will
				 * also close the window if it is
				 * already opened and it will dispose of
				 * all objects attached to it.
				 */
				IIntuition->DisposeObject(objects[OID_MAIN]);
			}

			IExec->DeleteMsgPort(AppPort);
		}
	}

	free_speedbar_list(&speedbar_list);

	return(0);
}
