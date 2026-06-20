;/* Execute me to compile
gcc -o LabelExample LabelExample.c -lauto -lraauto
quit
:*/

/**
 **  LabelExample.c -- Label class example.
 **
 **  This is a simple example testing some of the capabilities of the
 **  Label image class.
 **
 **  This code opens a simple window and then creates a Label image,
 **  combining text, font changes and images.  It then draws the image in
 **  both its regular and selected state.
 **
 **  Note that we are not using window or layout class here, we are 
 **  using the gadget in a fairly direct form, but that's perfectly legal.
 **
 **/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
//#include <reaction/reaction_macros.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <libraries/gadtools.h>


struct Library *LabelBase;

struct Library * OpenClass(STRPTR, ULONG);


UWORD image_data[] =
{
	/* Plane 0 */
	0x0000, 0x0000,
	0x7F00, 0x0000,
	0x4180, 0x0000,
	0x4140, 0x0000,
	0x4120, 0x4000,
	0x41F0, 0x6000,
	0x401B, 0xF000,
	0x401B, 0xF800,
	0x401B, 0xF000,
	0x4018, 0x6000,
	0x4018, 0x4000,
	0x4018, 0x0000,
	0x4018, 0x0000,
	0x7FF8, 0x0000,
	0x1FF8, 0x0000,
	0x0000, 0x0000,
	/* Plane 1 */
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x3E00, 0x0000,
	0x3E80, 0x0000,
	0x3EC0, 0x0000,
	0x3E00, 0x0000,
	0x3FE0, 0x0000,
	0x3FE0, 0x0000,
	0x3FE0, 0x0000,
	0x3FE0, 0x0000,
	0x3FE0, 0x0000,
	0x3FE0, 0x0000,
	0x3FE0, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000
};

struct Image image =
{
	0, 0, 22, 16, 2, image_data, 0x03, 0x00, NULL
};

struct TextAttr emerald17 = { (STRPTR)"emerald.font", 18, FS_NORMAL, 0x01 };


/* This is the start of our programme. */
main()
{
	struct Screen *screen = NULL;

	/* We'll just open up on the default public screen, and use its screen font. */
	if (screen = IIntuition->LockPubScreen(NULL))
	{
		struct DrawInfo *drinfo = NULL;

		if (drinfo = IIntuition->GetScreenDrawInfo(screen))
		{
			/* Open the BOOPSI class library. */
			IDOS->PutStr("Opening class\n");

			if (LabelBase = OpenClass("images/label.image", 0))
			{
				struct Image *label_image;
				UWORD mapping[4];

				/* Setup the mapping.  This is a pretty standard map for
				 * a 4 colour image.
				 */
				mapping[0] = drinfo->dri_Pens[BACKGROUNDPEN];
				mapping[1] = drinfo->dri_Pens[SHADOWPEN];
				mapping[2] = drinfo->dri_Pens[SHINEPEN];
				mapping[3] = drinfo->dri_Pens[FILLPEN];

				/* Create a label image.  Here we make use of underscoring,
				 * multiple lines, images, different pens, different fonts
				 * and right justification.
				 */
				IDOS->PutStr("Creating object\n");
				if (label_image = (struct Image *)IIntuition->NewObject(ILabel->LABEL_GetClass(), NULL,
													IA_Font, screen->Font,
													LABEL_Justification, LABEL_CENTRE,
													LABEL_Text, "_Under-scored\nNot under-scored\n",
													LABEL_Text, "An image: ",
													LABEL_Mapping, mapping,
													LABEL_Image, &image,
													IA_FGPen, 3,
													IA_Font, &emerald17,
													LABEL_Text, "\nChange fonts,\n",
													IA_FGPen, 2,
													IA_Font, screen->Font,
													LABEL_Text, "and colours, ",
													LABEL_SoftStyle, FSF_BOLD,
													LABEL_Text, " and styles",
													TAG_END))
				{
					struct Window *win = NULL;

					IDOS->Printf("Image size -- width: %ld  height: %ld\n",
						(LONG)label_image->Width, (LONG)label_image->Height);

					/* Open a simple window. */
					if (win = IIntuition->OpenWindowTags(NULL,
						WA_Left, 0,
						WA_Top, screen->Font->ta_YSize + 3,
						WA_InnerWidth, label_image->Width + INTERWIDTH * 2,
						WA_InnerHeight, (label_image->Height + INTERHEIGHT * 2) * 2,
						WA_IDCMP, IDCMP_GADGETUP | IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW,
						WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET |
									WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH,
						WA_Title, "Label Class Demo",
						WA_MinWidth, label_image->Width + INTERWIDTH * 2 + 20,
						WA_MinHeight, (label_image->Height + INTERHEIGHT * 2) * 2 + screen->Font->ta_YSize + 10,
						WA_MaxWidth, -1,
						WA_MaxHeight, -1,
						TAG_DONE))
					{
						struct RastPort *rport = win->RPort;
						struct IntuiMessage *imsg;
						UWORD top = win->BorderTop + INTERHEIGHT;
						UWORD left = win->BorderLeft + INTERWIDTH;
						BOOL ok = TRUE;

						IDOS->PutStr("Drawing image\n");

						IIntuition->DrawImageState(rport, label_image, left, top,
							IDS_NORMAL, drinfo);
						IIntuition->DrawImageState(rport, label_image, left, top + label_image->Height + INTERHEIGHT,
							IDS_SELECTED, drinfo);

						/* Just wait around until the close gadget is pressed. */
						while (ok)
						{
							IExec->WaitPort(win->UserPort);
							while (imsg = (struct IntuiMessage *)IExec->GetMsg(win->UserPort))
							{
								switch(imsg->Class)
								{
									case IDCMP_REFRESHWINDOW:
										IIntuition->DrawImageState(rport, label_image, left, top,
											IDS_NORMAL, drinfo);
										IIntuition->DrawImageState(rport, label_image, left, top + label_image->Height + INTERHEIGHT,
											IDS_SELECTED, drinfo);
										break;

									case IDCMP_CLOSEWINDOW:
										ok = FALSE;
										break;

									default:
										break;
								}
								IExec->ReplyMsg((struct Message *)imsg);
							}
						}
						/* Done.
						 */
						IIntuition->CloseWindow(win);
					}
					else
						IDOS->PutStr("ERROR: Couldn't open window\n");

					IDOS->PutStr("Disposing image\n");
					IIntuition->DisposeObject(label_image);
				}
				else
					IDOS->PutStr("ERROR: Couldn't create image\n");

				IDOS->PutStr("Closing class\n");
				IExec->CloseLibrary((struct Library *)LabelBase);
			}
			else
				IDOS->PutStr("ERROR: Couldn't open class\n");

			IIntuition->FreeScreenDrawInfo(screen, drinfo);
		}
		else
			IDOS->PutStr("ERROR: Couldn't get DrawInfo\n");

		IIntuition->UnlockPubScreen(0, screen);
	}
	else
		IDOS->PutStr("ERROR: Couldn't lock public screen\n");
}


/* Function to open a BOOPSI class library. */
struct Library * OpenClass(STRPTR name, ULONG version)
{
	struct Library *retval;
	UBYTE buffer[256];

	if ((retval = IExec->OpenLibrary(name, version)) == NULL)
	{
		sprintf (buffer, ":classes/%s", name);
		if ((retval = IExec->OpenLibrary(buffer, version)) == NULL)
		{
			sprintf(buffer, "classes/%s", name);
			retval = IExec->OpenLibrary(buffer, version);
		}
	}
	return((struct Library *)retval);
}
