/*
** PBar test code
*/

#define Prototype extern

#include <exec/types.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <graphics/gfx.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>

#include "PBar.h"
#include "pbar_protos.h"

main()
{
	APTR pbar;
	struct Window *win;
	struct Screen *scr;
	APTR vi;
	UWORD top;
	BOOL done = FALSE;
	struct IntuiMessage *im;
	ULONG ic;
	
	if(scr = LockPubScreen(NULL))
	{
		if(vi = GetVisualInfo(scr, NULL))
		{
			if(win = OpenWindowTags(NULL, 
						WA_Title,	"PBar Test",
						WA_Width,			250,		WA_Height,			50,
						WA_CloseGadget,		TRUE,		WA_DepthGadget,		TRUE,
						WA_DragBar,			TRUE,		WA_Activate,		TRUE,
						WA_IDCMP,		IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|IDCMP_INTUITICKS,
						TAG_DONE))
			{
				top = scr->RastPort.TxHeight + scr->WBorTop + 1;
				
				/* Cre8 the pbar */
				if(pbar = CreatePBar(
							PB_VisualInfo,		vi,
							PB_LeftEdge,		5,
							PB_TopEdge,			top + 2,
							PB_Width,			200,
							PB_Height,			13,
							PB_BarColour,		3,
							PB_Window,			win,
							TAG_DONE))
				{
					int valu = 1;
					
					while(!done)
					{
						Wait(1L << win->UserPort->mp_SigBit);
						
						while((!done) && (im = (struct IntuiMessage *)GetMsg(win->UserPort)))
						{
							ic = im->Class;
			
							ReplyMsg((struct Message *)im);
							
							switch(ic)
							{
								case IDCMP_CLOSEWINDOW:
									done = TRUE;
									break;
								
								case IDCMP_REFRESHWINDOW:
									RefreshPBar(pbar);
									break;
								
								case IDCMP_INTUITICKS:
									UpdatePBar(pbar, 
										PB_NewValue,		valu,
										TAG_DONE);
									
									valu++;
									if(valu > 100)
									{
										ClearPBar(pbar);
										valu = 1;
									}
									
									break;
							}
						}
					}
					
					FreePBar(pbar);
				}
				
				CloseWindow(win);
			}
			
			FreeVisualInfo(vi);
		}
		
		UnlockPubScreen(NULL, scr);
	}
}
