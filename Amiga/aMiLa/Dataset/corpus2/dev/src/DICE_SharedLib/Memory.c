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

//--------- Memory handling: provides memory pools for the library, making it
//---------	more memory efficient.

#include "example.h"

//--	Function Prototypes

//--	Use these routines for memory allocation

Prototype APTR MAlloc(ULONG size);
Prototype void Free(APTR block, ULONG size);
Prototype APTR MAllocV(ULONG size);
Prototype void FreeV(APTR block);

Local BOOL InitMemory(void);
Local void CleanUpMemory(void);

//-- Should fit in a 4K memory page

#define MEM_PUDDLESIZE	4000
#define MEM_THRESHSIZE	4000

//-- Note: substitute for LibAllocPooled etc. if your target is <3.0

APTR CreatePool(ULONG, ULONG, ULONG);
void DeletePool(APTR);
APTR AllocPooled(APTR, ULONG);
void FreePooled(APTR, APTR, ULONG);

//--	Our Private Memory Pool

APTR Pool = NULL;

//--	Access Control Semaphore

struct SignalSemaphore Semaphore;

//--	Initialisation

BOOL InitMemory(void)
{
	InitSemaphore(&Semaphore);
	ObtainSemaphore(&Semaphore);
	Pool = CreatePool(MEMF_PUBLIC, MEM_PUDDLESIZE, MEM_THRESHSIZE);
	ReleaseSemaphore(&Semaphore);
	return((BOOL)(Pool ? TRUE : FALSE));
}


//--	Clean Up

void CleanUpMemory(void)
{
	ObtainSemaphore(&Semaphore);
	if (Pool) {
		DeletePool(Pool);
		Pool = NULL;
	}
	ReleaseSemaphore(&Semaphore);
}


//--	Replacement for AllocMem()

APTR MAlloc(ULONG size)
{
	ULONG *block;

	ObtainSemaphore(&Semaphore);
	if (block = AllocPooled(Pool, size))
		memset(block, NULL, size);
	ReleaseSemaphore(&Semaphore);
	return(block);
}


//--	Replacement for FreeMem()

void Free(APTR block, ULONG size)
{
	if (block) {
		ObtainSemaphore(&Semaphore);
		FreePooled(Pool, block, size);
		ReleaseSemaphore(&Semaphore);
	}
}


//--	Replacement for AllocVec()

APTR MAllocV(ULONG size)
{
	ULONG *block;

	ObtainSemaphore(&Semaphore);
	if (block = AllocPooled(Pool, size+4)) {
		*(block++) = size;
		memset(block, NULL, size);
	}
	ReleaseSemaphore(&Semaphore);
	return(block);
}


//--	Replacement for FreeVec()

void FreeV(APTR block)
{
	if (block) {
		ObtainSemaphore(&Semaphore);
		FreePooled(Pool, (APTR)((ULONG)block-4), *(ULONG *)((ULONG)block-4));
		ReleaseSemaphore(&Semaphore);
	}
}

