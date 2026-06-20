#ifndef _EXAMPLE_LIB_H
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

//---------		Main header file; include in all your library modules

//--	OS headers

#include <exec/types.h>
#include <exec/exec.h>
#include <exec/execbase.h>
#include <exec/semaphores.h>
#include <exec/alerts.h>
#include <exec/memory.h>
#include <exec/semaphores.h>
#include <exec/initializers.h>
#include <exec/execbase.h>
#include <exec/nodes.h>

#include <dos/dos.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <dos/dosextens.h>
#include <dos/stdio.h>
#include <dos/rdargs.h>
#include <dos/datetime.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <lists.h>
#include <string.h>

#include <utility/tagitem.h>

//---	Stuff

extern char LibName[];
extern char LibIDString[];
extern UWORD LibVersion;
extern UWORD LibRevision;

//--	Private Library Base

struct LibraryBase {

	//-- ALWAYS have these..
	
	struct Library LibNode;
	UBYTE Flags;
	UBYTE Pad;
	BPTR SegList;

	//-- Add your own stuff here

};

extern struct LibraryBase *LibraryBase;


//--- Done
#endif

//----- Automatic Prototyping
//--	Note: all public library calls need to be declared as LibCalls

#ifndef Prototype
#define Prototype extern
#define Local static
#define LibCall __geta4 __saveds
#include "example-protos.h"
#endif

