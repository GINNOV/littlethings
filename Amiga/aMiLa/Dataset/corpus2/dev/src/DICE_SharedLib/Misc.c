//
//		Example Shared Library Code
//		Compiles with DICE
//		
//		By Wez Furlong <wez@twinklestar.demon.co.uk>
//
//		Based on code by Geert Uytterhoeven and Matt Dillon
//
//		This source was produced:	Monday 23-Jun-1997 
//
//		DISCLAIMER
//
//		Please read the code FULLY before use... I could have put ANYTHING in
//		here; I may have the code format your bootdrive for example.
//
//		NEVER trust example code without fully understanding what it does.
//
//		This code comes with no warranty; I am NOT responsible for any damage
//		that may ensue from its use, be it physical, mental or otherwise.
//
//		This code may be modified, so long as the names of myself, Geert and
//		Matt are mentioned within any release or distribution produced using it,
//		and a copy sent to myself.
//
//		This code may be redistributed freely; no profit is allowed to be made
//		from its distribution.
//
//		This code may be included on an Aminet or Fred Fish CD.
//

/*--- Includes ------------------*/

#include "example.h"

/*--- Prototypes ----------------*/

Prototype BOOL Init(void);
Prototype BOOL CleanUp(void);
Prototype LibCall ULONG LibOBSOLETE(void);

/*--- #defines ------------------*/

/*--- Globals -------------------*/

struct ExecBase *SysBase;
struct LibraryBase *LibraryBase;
struct DosLibrary *DOSBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct Library *UtilityBase = NULL;

/*--- Functions -----------------*/

/*---------------------------------------------------Initialisation--------
-------------------------------------------------------------------------*/


BOOL Init(void)
{

	if (!InitMemory())
		return(FALSE);


	if (!(DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", 37)) ||
		 !(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 37)) ||
		 !(UtilityBase = OpenLibrary("utility.library", 37)) 
		)

		return(FALSE);

	initstuff();
	
	return(TRUE);
}


/*---------------------------------------------------------Clean Up--------
-------------------------------------------------------------------------*/


BOOL CleanUp(void)
{

	CleanUpMemory();

	if (UtilityBase)
		CloseLibrary(UtilityBase);
	if (IntuitionBase)
		CloseLibrary((struct Library *)IntuitionBase);
	if (DOSBase)
		CloseLibrary((struct Library *)DOSBase);

	return(TRUE);
}


/*-----------------------------Entry for Obsolete Library Functions--------
-------------------------------------------------------------------------*/


LibCall ULONG LibOBSOLETE(void)
{
	return(NULL);
}


