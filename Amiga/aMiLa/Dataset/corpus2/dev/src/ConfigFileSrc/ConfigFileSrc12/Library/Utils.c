/*
**		$PROJECT: ConfigFile.library
**		$FILE: Utils.c
**		$DESCRIPTION: Misc functions.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#include "LibBase.h"
#include "Funcs/GlobalVars.h"
#include "Utils.h"

IMPORT struct ExecBase		*SysBase;
IMPORT struct DosLibrary	*DOSBase;

/**************************************************************************/

	/* GetFileSize():
	 *
	 *	return the length of the file.
	 */

LONG GetFileSize ( BPTR FH )
{
	struct FileInfoBlock FIB;

	ExamineFH (FH, &FIB);

	return(FIB.fib_Size);
}

/**************************************************************************/

	/* NewStr():
	 *
	 *	allocate a new string.
	 */

STRPTR NewStr ( APTR MemPool, UBYTE Length )
{
	UBYTE *Ret;

	if ( Ret = (UBYTE *) MyAllocPooled (MemPool,
					( Length + (sizeof(UBYTE) * 2) ) ) )
	{
		*Ret = Length;
		return ((STRPTR) ( Ret + 1 ));
	}

	return (FALSE);
}

	/* DelStr():
	 *
	 *	dispose the string.
	 */

VOID DelStr ( APTR MemPool, STRPTR String )
{
	String--;
	MyFreePooled (MemPool, String, (*String + (sizeof(UBYTE) * 2)));
}

STRPTR DupStr ( APTR MemPool, STRPTR String )
{
	STRPTR	Str;

	Str = NewStr (MemPool, StrLen (String));
	StrCpy (Str, String);

	return (Str);
}

/*
STRPTR DupStrF ( STRPTR String )
{
	STRPTR	Str;

	Str = NewStr (*( String - 1 ));
	StrCpy (Str, String);

	return (Str);
}
*/
/**************************************************************************/

/* Debug Functions */

#define DEBUGFILE	"RAM:CFDebugFile"

#if (CF_FUNC_DEBUG || CF_STEP_DEBUG || CF_MEMA_DEBUG)

SaveDS VOID bug ( STRPTR Fmt , ... )
{
	BPTR	FH = Open (DEBUGFILE, MODE_READWRITE);
	Seek (FH, 0, OFFSET_END);
	VFPrintf (FH, Fmt, (ULONG *)&Fmt+1);
	Close (FH);
}

#endif

/**************************************************************************/

#ifdef CF_MEMA_DEBUG

#undef MyAllocPooled
#undef MyCreatePool
#undef MyDeletePool
#undef MyFreePooled

#ifndef POOLS_V39

#define MyAllocPooled(a,b)		AsmAllocPooled (a, b, SysBase)
#define MyCreatePool(a,b,c)	AsmCreatePool (a, b, c, SysBase)
#define MyDeletePool(a)			AsmDeletePool (a, SysBase)
#define MyFreePooled(a,b,c)	AsmFreePooled (a, b, c, SysBase)

#else

#define MyAllocPooled(a,b)		AllocPooled (a, b)
#define MyCreatePool(a,b,c)	CreatePool (a, b, c)
#define MyDeletePool(a)			DeletePool (a)
#define MyFreePooled(a,b,c)	FreePooled (a, b, c)

#endif

APTR DEBAllocPooled ( APTR MemPool , ULONG Size )
{
	APTR	NewMem = MyAllocPooled(MemPool,Size);
	bug("   $%08lx = AllocPooled($%08lx,%ld)\n", NewMem, MemPool, Size);
	return (NewMem);
}

APTR DEBCreatePool ( ULONG MemAttrs , ULONG PuddleSize , ULONG ThreshSize )
{
	APTR	NewPool = MyCreatePool(MemAttrs, PuddleSize, ThreshSize);
	bug("   $%08lx = CreatePool($%lx,%ld,%ld)\n", NewPool, MemAttrs, PuddleSize, ThreshSize);
	return (NewPool);
}

VOID DEBDeletePool ( APTR MemPool )
{
	bug("   DeletePool($%08lx)\n", MemPool);
	MyDeletePool(MemPool);
}

VOID DEBFreePooled ( APTR MemPool , APTR Mem , ULONG Size )
{
	bug("   FreePooled($%08lx,$%08lx,%ld)\n", MemPool, Mem, Size);
	MyFreePooled(MemPool, Mem, Size);
}

#endif
