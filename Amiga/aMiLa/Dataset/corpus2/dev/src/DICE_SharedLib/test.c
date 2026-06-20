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

//		Test Code:	Just to make sure it all works :)

//		To build:	dcc -Iobjects/ test.c
//			run dmake first though; you will need a library to open :)

#include "example.h"

#include "example_pragmas.h"

LONG main(int ac, char **av[])
{
	struct LibraryBase *LibraryBase;

	if (LibraryBase = (struct LibraryBase*)OpenLibrary("distribution/example.library",39))
	{
		char buf[20];
		
		puts((STRPTR)"Posting 'wibble'");
		PostString((STRPTR)"wibble");
		puts((STRPTR)"Posting 'wobble'");
		PostString((STRPTR)"wobble");
		puts((STRPTR)"Posting 'spoink'");
		PostString((STRPTR)"spoink");
		puts((STRPTR)"\nRecalling strings...");
		
		GetString((STRPTR)&buf, 20);
		puts((STRPTR)&buf);
		
		GetString((STRPTR)&buf, 20);
		puts((STRPTR)&buf);

		GetString((STRPTR)&buf, 20);
		puts((STRPTR)&buf);

		puts((STRPTR)"\nDone.\nClosing Library");

		CloseLibrary((struct Library*)LibraryBase);
	}
	else
	{
		puts((STRPTR)"Unable to open the library!!");
		exit(20);
	}
	exit(0);
}

