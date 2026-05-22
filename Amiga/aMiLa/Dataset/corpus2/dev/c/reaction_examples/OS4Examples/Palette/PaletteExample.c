;/* Execute me to compile
gcc -o PaletteExample PaletteExample.c -lauto 
quit
;
/**
 **  PaletteExample.c -- Palette class example.
 **
 **  This is a simple example testing some of the capabilities of the
 **  Palette gadget class.
 **
 **  This code opens a simple window and then creates a Palette gadget.
 **
 **  Note that we are not using window or layout class here, we are 
 **  using the gadget in a fairly direct form, but that's perfectly legal.
 **
 **/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <gadgets/palette.h>

/* Function prototypes. */
struct Library * OpenClass(STRPTR, ULONG);

/* Global variables. */
struct Library *PaletteBase;
struct PaletteIFace *IPalette;
struct Gadget *palette_gad;


/* This is the start of our programme. */
main()
{
	if (!(PaletteBase = IExec->OpenLibrary( "sys:classes/gadgets/palette.gadget", 51 ))) {
		printf("Failed to open palette gadget as a library\n");
		return 30;
	}

	if (!(IPalette = (struct PaletteIFace *)IExec->GetInterface( PaletteBase, "main", 1L, NULL ))) {
		printf("Failed to get palette interface\n");
		return 30;
	}

	struct Screen *screen = NULL;

	/* We'll just open up on the Workbench screen, and use its screen font */
	if (screen = IIntuition->LockPubScreen("Workbench"))
	{
		struct Window *win = NULL;

		/* Open the window, note how we size the window to perfectly fit
		 * all the gadgets.
		 */
		if (win = IIntuition->OpenWindowTags(NULL,
			WA_Left, 0,
			WA_Top, screen->Font->ta_YSize + 3,
			WA_Width, 200,
			WA_Height, (screen->WBorTop) + 5 + screen->Font->ta_YSize + 100,
			WA_IDCMP, IDCMP_GADGETUP | IDCMP_REFRESHWINDOW |
						IDCMP_CLOSEWINDOW | IDCMP_GADGETDOWN,
			WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET |
						WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH,
			WA_Title, "ReAction Palette Demo",
			WA_MinWidth, 60,
			WA_MinHeight, (screen->WBorTop) + 5 + screen->Font->ta_YSize + 60,
			WA_MaxWidth, -1,
			WA_MaxHeight, -1,
			TAG_DONE))
		{
			IDOS->PutStr("Creating Palette class\n");
			if (PaletteBase = OpenClass("gadgets/palette.gadget", 0))
			{
				IDOS->PutStr("Creating Palette gadget 1\n");
				if (palette_gad = (struct Gadget *)IIntuition->NewObject(IPalette->PALETTE_GetClass(), NULL,
														GA_ID, 2,
														GA_Top, (win->BorderTop) + 5,
														GA_Left, 10,
														GA_RelWidth, -36,
														GA_RelHeight, -(win->BorderTop + win->BorderBottom + 10),
														GA_RelVerify, TRUE,
														PALETTE_NumColours, 1 << screen->RastPort.BitMap->Depth,
														TAG_END))
				{
					struct IntuiMessage *imsg;
					BOOL ok = TRUE;
		
					IIntuition->AddGList(win, palette_gad, -1, -1, NULL);
					IIntuition->RefreshGList(palette_gad, win, NULL, -1);

					/* Just wait around until the close gadget is pressed. */
					while (ok)
					{
						struct Gadget *gadget;
		
						IExec->WaitPort(win->UserPort);
						while (imsg = (struct IntuiMessage *)IExec->GetMsg(win->UserPort))
						{
							switch(imsg->Class)
							{
								case IDCMP_CLOSEWINDOW:
									ok = FALSE;
									break;
		
								case IDCMP_GADGETUP:
									gadget = (struct Gadget *)imsg->IAddress;
									IDOS->Printf("Gadget: %ld  Code: %ld\n",
									(LONG)gadget->GadgetID, (LONG)imsg->Code );
		
									break;
		
								default:
									break;
							}
							IExec->ReplyMsg((struct Message *)imsg);
						}
					}
					IIntuition->RemoveGList(win, palette_gad, -1);
					IIntuition->DisposeObject(palette_gad);
				}
				else
					IDOS->PutStr("ERROR: Couldn't create Palette gadget\n");

				/* Free the class.
				 */
				IDOS->PutStr("Freeing Palette class\n");
				IExec->CloseLibrary((struct Library *)PaletteBase);
			}
			else
				IDOS->PutStr("ERROR: Couldn't create Palette class\n");

			IIntuition->CloseWindow(win);
		}
		else
			IDOS->PutStr("ERROR: Couldn't open window\n");

	    IIntuition->UnlockPubScreen(0, screen);
	}
	else
		IDOS->PutStr("ERROR: Couldn't lock public screen\n");
}


/* Open a class library. */
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
