/* ------------------------------------------------------------------ */
/* $VER: MyGuiTest.main.c 39.01 (12.12.1999)                          */
/*                                                                    */
/* Function handling within program                                   */
/* Advanced demo program for easyaudio.library                        */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#include <stdio.h>

#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/easyaudio_protos.h>

#include <dos/dos.h>
#include <exec/types.h>
#include <easyaudio/easyaudio.h>
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>


#include "MyGuiTest.h"

UBYTE *vers = "$VER: EasyAudio Test v39.1 - © Matthew J Fletcher 2000";

/* ------------------------------------------------------------- */
/* Please note that, this code has been written under gcc libnix */
/* as such it uses auto-library opening and other nice features  */
/* that some amiga compilers do not support. I have explicitly   */
/* opened libs that are not in 3.x ROM, as thats the minimum     */
/* that any decent compiler should support. DICE / GCC-Libnix /  */
/* StormC and perhaps others (allthough i cant be sure) will be  */
/* just fine. -matt                                              */
/* ------------------------------------------------------------- */

int wbmain(void)
{ /* dummy to call main from workbench */
	main();
}


int main(void)
{ /* workbench startup & entry point */
int result;

	/* ------------------------ */
	/* open in nice safe manner */
	/* ------------------------ */

	if (SetupScreen() != 0) /* something broke */
	   {
	   CloseDownScreen();
	   exit(20);
	   } /* close anything we might have opened */

	if (OpenEasyAudioTestWindow() !=0 )
	   {
	   CloseEasyAudioTestWindow();
	   CloseDownScreen();
	   exit(20);
	   } /* close anything we might have opened */

	/* ------------------------ */
	/* watch what the user does */
	/* ------------------------ */

	/* we will quit when we get -1 (they clicked quit gadget) */

	do { /* while they did something */
	   result = HandleEasyAudioTestIDCMP();

	   if ((result == 0 ) ||
		   (result == 4194304)
		  ) /* normal return */
	   {
	   /* do nothing */
	   }
	   else
	   printf("idcmp = %d\n",result);

	   } while (result != -1); /* a break */


   /* a seperate procedure will have to call CloseWindow */
   /* to quit - WE dont handle it here */
   EasyAudioTestCloseWindow();
   exit(0);
}


int EasyAudioTestCloseWindow( void )
{ /* routine for "IDCMP_CLOSEWINDOW". */

	CloseEasyAudioTestWindow();
	CloseDownScreen();
	return(-1);

	/* returns -1, cos we presume this is called normaly */
}


int EasyAudioTestIDCMPUpdate( void )
{ /* routine for "IDCMP_IDCMPUPDATE". */
}


int EasyAudioTestIntuiTicks( void )
{ /* routine for "IDCMP_INTUITICKS". */
}


int list1Clicked( void )
{ /* routine when gadget "" is clicked. */
}

int button1Clicked( void )
{ /* routine when gadget "Speak !" is clicked. */
STRPTR buffer;
long result = 0;

/* get our string from the gadget */
buffer = GT_GetGadgetAttrs(2,
						   EasyAudioTestWnd,
						   NULL,
						   GTST_String, &buffer,
						   TAG_DONE );

/* now blank out the gadget */
/*GT_SetGadgetAttrs(2,
				  EasyAudioTestWnd,
				  NULL,
				  GD_Disabled, TRUE,
				  TAG_DONE );
*/


 /* open EA_Speech() & speek */

 EasyaudioBase = (APTR) OpenLibrary("easyaudio.library", 39);
 if(!EasyaudioBase)
   {
	printf("\nEasyaudio.library opening failed\n");

	/* failure & quit */
	EasyAudioTestCloseWindow();
	return(-1);
   }

   /* call the speach function */

   if (EA_Speech(buffer) ==1)
	   printf("Ough shit, the speech broke !\n");


   CloseLibrary((APTR) EasyaudioBase);

   /* thats that */
}


int button2Clicked( void )
{ /* routine when gadget "Get File" is clicked. */
STRPTR buffer;

  /* get a file name/path */
  buffer = OpenASL();
  printf("path/file: %s\n",buffer);

  return(-2);
}


int string1Clicked( void )
{/* routine when string gadget is clicked. */
}


int check1Clicked( void )
{/* routine when gadget "Stereo" is clicked. */
}


int check2Clicked( void )
{/* routine when gadget "AHI Calibrated" is clicked. */
}

int check3Clicked( void )
{ /* routine when gadget "14 Bit Calibrated" is clicked. */
}


int button3Clicked( void )
{ /* routine when gadget "Play !" is clicked. */
}


int EasyAudioTestItem0( void )
{ /* routine when (sub)item "About" is selected. */

 EasyaudioBase = (APTR) OpenLibrary("easyaudio.library", 39);
 if(!EasyaudioBase)
   {
	printf("\nEasyaudio.library opening failed\n");

	/* failure & quit */
	EasyAudioTestCloseWindow();
	return(-1);
   }

   /* call the requestor function */
   EA_Request("About EasyAudio",
			  "This is a slightly more advanced\nexample, showing a more real\nusage of the library,\n\n© Matthew J Fletcher 1999-2000",
			  "OK");

   CloseLibrary((APTR) EasyaudioBase);
   return(-3);
}


int EasyAudioTestItem1( void )
{ /* routine when (sub)item "Quit" is selected. */
int result;

 EasyaudioBase = (APTR) OpenLibrary("easyaudio.library", 39);
 if(!EasyaudioBase)
   {
	printf("\nEasyaudio.library opening failed\n");

	/* failure & quit */
	EasyAudioTestCloseWindow();
	return(-1);
   }

   /* call the requestor function */
   result = EA_Request("Quit ?",
					   "Are you sure you want to quit ?",
					   "OK|Cancel");


   if (result == 1) /* ok - quit */
		{
		CloseLibrary((APTR) EasyaudioBase);

		/* user WANTS to quit */
		EasyAudioTestCloseWindow();
		return(-1);
		} /* we are gone */

   /* else we get to play some more */

   CloseLibrary((APTR) EasyaudioBase);
   return(-4);
}





