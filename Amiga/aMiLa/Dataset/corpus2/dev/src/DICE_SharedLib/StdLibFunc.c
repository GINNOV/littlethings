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

//----------	Standard Library Functions

/*--- Includes ------------------*/

#include "example.h"

/*--- Prototypes ----------------*/

Prototype LibCall struct LibraryBase *LibInit(__D0 struct LibraryBase *base, __A0 BPTR seglist, __A6 struct ExecBase *sysbase);
Prototype LibCall struct LibraryBase *LibOpen(__A6 struct LibraryBase *LibraryBase);
Prototype LibCall BPTR LibClose(__A6 struct LibraryBase *LibraryBase);
Prototype LibCall BPTR LibExpunge(__A6 struct LibraryBase *LibraryBase);
Prototype LibCall ULONG LibExtFunc(void);

/*--- Globals -------------------*/

/*--- Functions -----------------*/

//		Exec has set a Forbid() for the duration of these calls...
//		WE MUST NOT DO ANY IO, Wait(), OR TAKE A LONG TIME

/*-------------------------------------------Library initialisation--------
-------------------------------------------------------------------------*/


LibCall struct LibraryBase *LibInit(__D0 struct LibraryBase *base,
												 __A0 BPTR seglist,
												 __A6 struct ExecBase *sysbase)
{
	SysBase = sysbase;
	LibraryBase = base;
	LibraryBase->LibNode.lib_Node.ln_Type = NT_LIBRARY;
	LibraryBase->LibNode.lib_Node.ln_Name = LibName;
	LibraryBase->LibNode.lib_Flags = LIBF_SUMUSED|LIBF_CHANGED;
	LibraryBase->LibNode.lib_Version = LibVersion;
	LibraryBase->LibNode.lib_Revision = LibRevision;
	LibraryBase->LibNode.lib_IdString = LibIDString;
	LibraryBase->SegList = seglist;

	if (!Init()) {
		CleanUp();
		FreeMem((APTR)((ULONG)LibraryBase-(ULONG)(LibraryBase->LibNode.lib_NegSize)),
				  LibraryBase->LibNode.lib_NegSize+LibraryBase->LibNode.lib_PosSize);
		return(NULL);
	} else
		return(base);
}


/*-------------------------Library Open() (Called by OpenLibrary())--------
                                                  Standard Library Function
-------------------------------------------------------------------------*/


LibCall struct LibraryBase *LibOpen(__A6 struct LibraryBase *LibraryBase)
{
	LibraryBase->LibNode.lib_OpenCnt++;
	LibraryBase->Flags &= -1-LIBF_DELEXP;
	return(LibraryBase);
}


/*-----------------------Library Close() (Called by CloseLibrary())--------
                                                  Standard Library Function
-------------------------------------------------------------------------*/


LibCall BPTR LibClose(__A6 struct LibraryBase *LibraryBase)
{
	--LibraryBase->LibNode.lib_OpenCnt
	return(NULL);
	
	//--	Note: if you don't want the library to be a delayed expunge, 
	//--	call LibExpunge, returning what it returns, but only if the open
	//--	count is zero (0)!
}

/*-----------------------Library Expunge() (Called by RemLibrary())--------
                                                  Standard Library Function
-------------------------------------------------------------------------*/

LibCall BPTR LibExpunge(__A6 struct LibraryBase *LibraryBase)
{
	if (LibraryBase->LibNode.lib_OpenCnt == 0)
	{

		/* we are alone - lets go */

		//-- Unlink from the Exec List
		Remove((struct Node*)LibraryBase);

		/* save seglist */
		BPTR Seglist;
		Seglist = LibraryBase->SegList;

		CleanUp();
		FreeMem((APTR)((ULONG)LibraryBase-(ULONG)(LibraryBase->LibNode.lib_NegSize)),
			LibraryBase->LibNode.lib_NegSize+LibraryBase->LibNode.lib_PosSize);

		//-- Exec will now unloadseg any seglist we return
		return(Seglist);
	}

	//--	Ignore this next line if you don't want delayed expunge
	
	LibraryBase->Flags |= LIBF_DELEXP;
	return(NULL);

}

/*---------------------------------Library ExtFunc() (Called by ??)--------
                                                  Standard Library Function
-------------------------------------------------------------------------*/


LibCall ULONG LibExtFunc(void)
{
	return(NULL);
}

