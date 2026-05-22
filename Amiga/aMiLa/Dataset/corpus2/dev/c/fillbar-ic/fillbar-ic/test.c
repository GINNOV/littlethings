/*****************************************************************************
 * test program for fillbar.image 
 *
 */

#include <dos/dos.h>
#include <exec/types.h>
#include <exec/libraries.h>
#include <intuition/intuition.h>
#include <intuition/imageclass.h>
#include <intuition/intuitionbase.h>
#include <stdlib.h>
#include <stdio.h>

#include <clib/macros.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>

#include "include/images/fillbar.h"

/*****************************************************************************/

#define	IDCMP_FLAGS	IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_GADGETUP | IDCMP_GADGETDOWN \
			| IDCMP_MOUSEMOVE | IDCMP_INTUITICKS | IDCMP_MOUSEBUTTONS

/*****************************************************************************/

extern struct Library *SysBase, *DOSBase;
struct Library *IntuitionBase;

/*struct IntuitionBase *IntuitionBase;*/

/*****************************************************************************/

struct ClassLibrary *openclass (STRPTR name, ULONG version);

/*****************************************************************************/

void main (int argc, char **argv)
{
    struct ClassLibrary *imageLib;
    struct IntuiMessage *imsg;
    struct Screen *scr;
    struct Window *win;
    struct Image *im;
    BOOL going = TRUE;
    ULONG sigr;

    if (IntuitionBase = OpenLibrary ("intuition.library", 37))
    {
	scr = ((struct IntuitionBase *)IntuitionBase)->FirstScreen;

	if (imageLib = openclass ("images/fillbar.image", 37))
	{
	    if (win = OpenWindowTags (NULL,
				      WA_Title,		"fillbar.image Test",
				      WA_InnerWidth,	340,
				      WA_InnerHeight,	48,
				      WA_IDCMP,		IDCMP_FLAGS,
				      WA_DragBar,	TRUE,
				      WA_DepthGadget,	TRUE,
				      WA_CloseGadget,	TRUE,
				      WA_SimpleRefresh,	TRUE,
				      WA_NoCareRefresh,	TRUE,
				      WA_Activate,	TRUE,
				      WA_CustomScreen,	scr,
				      TAG_DONE))
	    {
		/* Create the fillbar image */
		if (im = NewObject (NULL, "fillbar.image",
					SYSIA_DrawInfo,			GetScreenDrawInfo (win->WScreen),
					IA_FGPen,				1,
					IA_BGPen,				0,
					IA_Left,				(340 - 320) / 2,
					IA_Top,					win->BorderTop + 4,
					IA_Width,				320,
//					IA_Height,				22,
					/*FILLBAR_FillPen,		3,*/
					FILLBAR_LabelLeft,		TRUE,
					FILLBAR_LabelRight,		TRUE,
					FILLBAR_LabelInside,	TRUE,
					FILLBAR_FrameAround,	TRUE,
					FILLBAR_FrameInside,	TRUE,
					TAG_DONE))
		{
			LONG val;
			LONG x;
			
			x = 1;
			val = 0;
			
		    /* Draw the image */
		    DrawImage (win->RPort, im, 0, 0);

		    while (going)
		    {
			sigr = Wait ((1L << win->UserPort->mp_SigBit | SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_F));

			SetAttrs (im, FILLBAR_Value, val, TAG_DONE);
			
			val += x;
			
			if (val == 100) {
				x = -1;
			}
			
			if (val == 0) {
				x = 1;
			}

		    /* Draw the image */
		    DrawImage (win->RPort, im, 0, 0);

			if (sigr & SIGBREAKF_CTRL_C)
			    going = FALSE;

			while (imsg = (struct IntuiMessage *) GetMsg (win->UserPort))
			{
			    switch (imsg->Class)
			    {
				case IDCMP_CLOSEWINDOW:
				    going = FALSE;
				    break;

				case IDCMP_VANILLAKEY:
				    switch (imsg->Code)
				    {
					case  27:
					case 'q':
					case 'Q':
					    going = FALSE;
					    break;
				    }
				    break;

			    }

			    ReplyMsg ((struct Message *) imsg);
			}
		    }
		    DisposeObject (im);
		}

		CloseWindow (win);
	    }
	    else
		Printf ("couldn't open the window\n");

	    CloseLibrary ((struct Library *) imageLib);
	}
	else
	    Printf ("couldn't open fillbar.image\n");

	CloseLibrary (IntuitionBase);
    }
}


/*****************************************************************************/

/* Try opening the class library from a number of common places */
struct ClassLibrary *openclass (STRPTR name, ULONG version)
{
    struct Library *retval;
    UBYTE buffer[256];

    if ((retval = OpenLibrary (name, version)) == NULL)
    {
	sprintf (buffer, ":classes/%s", name);
	if ((retval = OpenLibrary (buffer, version)) == NULL)
	{
	    sprintf (buffer, "classes/%s", name);
	    if ((retval = OpenLibrary (buffer, version)) == NULL) {
	    	sprintf (buffer, "classes/gadgets/%s", name);
	    	if ((retval = OpenLibrary (buffer, version)) == NULL) {
	    		sprintf (buffer, ":classes/gadgets/%s", name);
	    		if ((retval = OpenLibrary (buffer, version)) == NULL) {
	    			sprintf (buffer, "classes/images/%s", name);
	    			if ((retval = OpenLibrary (buffer, version)) == NULL) {
	    				sprintf (buffer, ":classes/images/%s", name);
	    				retval = OpenLibrary (buffer, version);
	    			}
	    		}
	    	}
	    }
	    
	}
    }
    return (struct ClassLibrary *) retval;
}
