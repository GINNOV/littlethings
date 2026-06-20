/***********************************************************************
*
*    ---------------
*   * Supra library *
*    ---------------
*
*   - NewImage demo -
*   Demonstration of ObtPens(), RelPens(), MakeNewImg(), FreeNewImg()
*
*   Program will draw two images. The image on top is a normal unmapped
*   image, the one under it is remapped into true colors.
*   This demo requires some free pens in a workbench palette, otherwise
*   colours will not be very exact.
*   It requires version 39 of graphics.library (AGA Amigas have it).
*
*
*   ©1995 by Jure Vrhovnik -- all rights reserved
*   jurev@gea.fer.uni-lj.si
*
***********************************************************************/

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <intuition/intuition.h>
#include <libraries/supra.h>
#include <stdio.h>

extern UWORD data[];
extern ULONG cmap[];
extern struct Image im;

struct Library *GfxBase = NULL;
struct Library *IntuitionBase = NULL;

struct Screen *scr;
struct Window *win;
struct Image *newimg;
ULONG pal[4];

struct TagItem tags[] = {OBP_Precision, PRECISION_EXACT, TAG_DONE};

int main()
{

    if (IntuitionBase = OpenLibrary("intuition.library", 0))
	{
        if (GfxBase = OpenLibrary("graphics.library", 39))
		{
            if (scr = LockPubScreen(NULL))
			{
                if (ObtPens(scr->ViewPort.ColorMap, cmap, pal, tags) == 4)
				{
                    if (win = OpenWindowTags(NULL, WA_Left, 70,
                                                   WA_Top, 70,
                                                   WA_Width, 128,
                                                   WA_Height, 135,
                                                   WA_Title, "New Image Demo",
                                                   TAG_DONE)) {

                        newimg = MakeNewImg(&im, pal);
                        if (newimg)
						{
                            DrawImage(win->RPort, &im, 20, 30);
                            DrawImage(win->RPort, newimg, 20, 80);
                            Delay(200);                                                
							FreeNewImg(newimg);
                        }


                        CloseWindow(win);
                    }
					else printf("Could not open window.\n");

                    RelPens(scr->ViewPort.ColorMap, cmap, pal);
                }
				else printf("Could not allocate pens.\nNot enough colors\n");

                UnlockPubScreen(NULL, scr);
            }
            CloseLibrary(GfxBase);
        }
        CloseLibrary(IntuitionBase);
    }
	return(0);
}
