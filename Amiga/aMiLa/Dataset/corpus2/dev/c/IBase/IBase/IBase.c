/* IBase.c
 * programmed by DC Ross (e-mail: dcross@mail.netshop.net)
 * 96-11-02
 *
 * Description:
 *   This is a little programme I wrote today to test the functions LockIBase()
 * and UnlockIBase().  By using a copy of IntuitionBase, you can access quite a
 * few useful feature of Intuition, such as the addresses of all Intuition
 * Screens and Windows (should work with CUSTOM and PUBLIC screens; I have only
 * tested PUBLIC).  Handy if you want your window to open on a screen with a
 * specific name.
 *   I haven't bothered to look through my old Workbench 1.3 Includes to see
 * if this can be made to work on Workbench 1.2/1.3.  If I ever feel I need
 * this programme on my Workbench 1.3 A500 I will try to figure it out, but
 * until then, you are on your own for Wb1.3 compatability.
 *   This code was created using the very sparce information in the ROM Kernal
 * Reference Manual: Libraries 3rd Edition for Workbench 2.04.  The information
 * can be found in Chapter 11: Intuition Special Functions on page 283.
 *   Send any comments, bug reports, suggestions, etc. to me via e-mail:
 * dcross@mail.netshop.net.
 *
 * Compiling:
 *   Used SAS/C 6.00 with the default options in SCOptions.  Doesn't need math
 * or any other special options set.
 *
 * Requirements:
 *   Workbench/Kickstart 2.x+ (tested on Wb3.0)
 *   Any CPU
 *   256K+ memory
 *
 * Release Notes:
 *   This small example programme is placed on the Public Domain.  I accept no
 * responsibility for any damage/loss.  Use at your own risk.
 *   Feel free to use any/all of this code in your own work.
 */

#define INTUI_V36_NAMES_ONLY

#include <StdIo.h>
#include <cLib/Exec_protos.h>
#include <Exec/Types.h>
#include <cLib/Intuition_protos.h>
#include <Intuition/IntuitionBase.h>
#include <Intuition/Intuition.h>
#include <Intuition/Screens.h>

UBYTE vers[] = "$VER: IBase (96-11-02)";

struct IntuitionBase *IntuitionBase;	/* needed to open intuition.library */
struct IntuitionBase *CopyIBase;	/* used to store copy of IntuitionBase */
struct Screen *Scrn;	/* used for accessing screen structures */
struct Window *Win;	/* used for accessing window structures */

VOID main(VOID)
{
	ULONG iLock = NULL;	/* needed for LockIBase()/UnlockIBase() */

	if(IntuitionBase = OpenLibrary("intuition.library", 0L))
	{
		iLock = LockIBase(0L);	/* lock IntuitionBase; don't fail if gives zero */
		/* copy all the IntuitionBase data to own structure */
		CopyIBase->ViewLord = IntuitionBase->ViewLord;	/* not sure what this does */
		CopyIBase->ActiveWindow = IntuitionBase->ActiveWindow;
		CopyIBase->ActiveScreen = IntuitionBase->ActiveScreen;
		CopyIBase->FirstScreen = IntuitionBase->FirstScreen;
		CopyIBase->MouseY = IntuitionBase->MouseY;	/* other functions get this information also */
		CopyIBase->MouseX = IntuitionBase->MouseX;	/*                    ""                     */
		CopyIBase->Seconds = IntuitionBase->Seconds;
		CopyIBase->Micros = IntuitionBase->Micros;
		UnlockIBase(iLock);	/* unlock IntuitionBase so other programmes can use Intuition */

		printf("View Lord:  0x%X\n", CopyIBase->ViewLord);
		printf("Active Screen:  %s (0x%X)\n", CopyIBase->ActiveScreen->Title, CopyIBase->ActiveScreen);
		printf("Active Window:  %s (0x%X)\n", CopyIBase->ActiveWindow->Title, CopyIBase->ActiveWindow);
		printf("Mouse X/Y:  0x%X, 0x%X\n", CopyIBase->MouseX, CopyIBase->MouseY);
		printf("Seconds/Micros:  0x%X, 0x%X\n\n", CopyIBase->Seconds, CopyIBase->Micros);

		/* search through the screen & window structures to display info */
		Scrn = CopyIBase->FirstScreen;
		Win = Scrn->FirstWindow;
		while(Scrn != NULL)
		{
			printf("Screen:  %s (0x%X)\n", Scrn->Title, Scrn);

			while(Win != NULL)
			{
				printf(" Window:  %s (0x%X)\n", Win->Title, Win);

				Win = Win->NextWindow;
			};	/* while */

			Scrn = Scrn->NextScreen;
			Win = Scrn->FirstWindow;
		};	/* while */

		CloseLibrary(IntuitionBase);
	};	/* if */
}	/* main() */
