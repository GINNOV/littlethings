/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: LibCode.c
**		$DESCRIPTION: Code for library init, open and close.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#include "RexxConfigFile.library_rev.h"

LibCall  struct RXCFBase *	LibInit ( REGA0 BPTR, REGD0 struct RXCFBase *, REGA6 struct ExecBase * );
SLibCall struct RXCFBase *	LibOpen ( REGA6 struct RXCFBase * );
LibCall  BPTR					LibExpunge ( REGA6 struct RXCFBase * );
SLibCall BPTR					LibClose ( REGA6 struct RXCFBase * );
LONG 								LibNull ( VOID );

__stdargs __saveds ULONG RexxDispatch ( struct RexxMsg *, UBYTE ** );
__stdargs VOID AsmRexxDispatch ( VOID );

#include "Funcs.h"

extern UWORD __far	LibVersion,
							LibRevision;

extern UBYTE __far	LibName[],
							LibID[];

struct ExecBase	*SysBase = 0;
struct DosLibrary	*DOSBase = 0;
struct Library		*RexxSysBase = 0;
struct Library		*CFBase = 0;

IMPORT UBYTE OpenCount;

APTR LibVectors[] =
{
	LibOpen,
	LibClose,
	LibExpunge,
	LibNull,

	AsmRexxDispatch,

	(APTR)-1
};

struct { ULONG DataSize; APTR Table; APTR Data; struct RXCFBase * (*Init)(); }
__aligned LibInitTab =
{
	sizeof(struct RXCFBase),
	LibVectors,
	NULL,
	LibInit
};

	/* LibInit():
	 *
	 *	Initialize the library.
	 */

LibCall struct RXCFBase *
LibInit ( REGA0 BPTR LibSegment, REGD0 struct RXCFBase * RXCFBase, REGA6 struct ExecBase * ExecBase )
{
	RXCFBase->LibNode.lib_Node.ln_Type	= NT_LIBRARY;
	RXCFBase->LibNode.lib_Node.ln_Name	= LibName;
	RXCFBase->LibNode.lib_Node.ln_Pri	= 100;
	RXCFBase->LibNode.lib_Flags			= LIBF_CHANGED | LIBF_SUMUSED;
	RXCFBase->LibNode.lib_Version			= LibVersion;
	RXCFBase->LibNode.lib_Revision		= LibRevision;
	RXCFBase->LibNode.lib_IdString		= LibID;

	RXCFBase->Segment = LibSegment;

	SysBase = ExecBase;

	if ( CFBase = OpenLibrary (CF_NAME, CF_VERSION) )
	{
		if ( RexxSysBase = OpenLibrary ("rexxsyslib.library", 36L) )
		{
			DOSBase = (struct DosLibrary *) TaggedOpenLibrary (TLIB_DOS);
			return (RXCFBase);
		}
	}

	return (NULL);
}

	/* LibOpen():
	 *
	 *	Open the library, as called via OpenLibrary()
	 */

SLibCall struct RXCFBase *
LibOpen ( REGA6 struct RXCFBase * RXCFBase )
{
	RXCFBase->LibNode.lib_OpenCnt++;
	RXCFBase->LibNode.lib_Flags &= ~LIBF_DELEXP;

	return (RXCFBase);
}

	/* LibExpunge();
	 *
	 *	Expunge the library, remove it from memory
	 */

LibCall BPTR
LibExpunge ( REGA6 struct RXCFBase * RXCFBase )
{
	if ( !RXCFBase->LibNode.lib_OpenCnt && !OpenCount ) // If OpenCnt Null
	{
		BPTR TempSegment = RXCFBase->Segment;

		CloseLibrary (CFBase);
		CloseLibrary (RexxSysBase);
		CloseLibrary (DOSBase);

		Remove (RXCFBase);

		FreeMem ((BYTE *)RXCFBase-RXCFBase->LibNode.lib_NegSize,
					RXCFBase->LibNode.lib_NegSize+RXCFBase->LibNode.lib_PosSize);

		return (TempSegment);
	}
	else
	{
		RXCFBase->LibNode.lib_Flags |= LIBF_DELEXP;

		return (NULL);
	}
}

	/* LibClose();
	 *
	 *	Close the library, as called by CloseLibrary()
	 */

SLibCall BPTR
LibClose ( REGA6 struct RXCFBase * RXCFBase )
{
	RXCFBase->LibNode.lib_OpenCnt--;

	if ( RXCFBase->LibNode.lib_Flags & LIBF_DELEXP )
			return (LibExpunge (RXCFBase));

	return (NULL);
}

	/* LibNull();
	 *
	 *	Mandatory dummy function
	 */

LONG LibNull (VOID)
{
	return (NULL);
}

/***************************************************************************/

#define	BUILTIN_FUNCS		60

typedef struct FuncListEntry
{
	STRPTR	String;
	UBYTE		MinArgs;
	UBYTE		MaxArgs;
	UWORD		(*Function)( struct RexxMsg *, UBYTE **, VOID * );
} FuncListEntry;

struct FuncListEntry  FuncList[BUILTIN_FUNCS] =
{
	"OPEN"				,1,4,rxcf_Open,
	"CLOSE"				,1,1,rxcf_Close,

	"READ"				,1,1,rxcf_Read,
	"WRITE"				,1,3,rxcf_Write,

	"NEWARGUMENT"		,2,2,rxcf_NewArgument,
	"NEWGROUP"			,2,2,rxcf_NewGroup,
	"NEWITEM"			,2,4,rxcf_NewItem,
	"NEWARGITEM"		,3,5,rxcf_NewArgItem,

	"GETITEM"			,3,3,rxcf_GetItem,
	"GETITEMNUM"		,4,4,rxcf_GetItemNum,

	"LOCKARGLIST"		,1,1,rxcf_LockArgList,
	"LOCKGRPLIST"		,1,1,rxcf_LockGrpList,
	"LOCKITEMLIST"		,1,1,rxcf_LockItemList,

	"UNLOCKARGLIST"	,1,1,rxcf_UnlockArgList,
	"UNLOCKGRPLIST"	,1,1,rxcf_UnlockGrpList,
	"UNLOCKITEMLIST"	,1,1,rxcf_UnlockItemList,

	"NEXTARGUMENT"		,1,1,rxcf_NextArgument,
	"NEXTGROUP"			,1,1,rxcf_NextGroup,
	"NEXTITEM"			,1,1,rxcf_NextItem,

	"LASTARGUMENT"		,1,1,rxcf_LastArgument,
	"LASTGROUP"			,1,1,rxcf_LastGroup,
	"LASTITEM"			,1,1,rxcf_LastItem,

	"DISPOSEARGUMENT"	,1,1,rxcf_DisposeArgument,
	"DISPOSEGROUP"		,1,1,rxcf_DisposeGroup,
	"DISPOSEITEM"		,1,1,rxcf_DisposeItem,

	"CLONEARGUMENT"	,1,1,rxcf_CloneArgument,
	"CLONEGROUP"		,1,1,rxcf_CloneGroup,
	"CLONEITEM"			,1,1,rxcf_CloneItem,

	"CLEARARGLIST"		,1,1,rxcf_ClearArgList,
	"CLEARGRPLIST"		,1,1,rxcf_ClearGrpList,
	"CLEARITEMLIST"	,1,1,rxcf_ClearItemList,

	"CHANGEARGUMENT"	,2,2,rxcf_ChangeArgument,
	"CHANGEGROUP"		,2,2,rxcf_ChangeGroup,
	"CHANGEITEM"		,2,4,rxcf_ChangeItem,

	"FINDARGUMENT"		,2,2,rxcf_FindArgument,
	"FINDGROUP"			,2,2,rxcf_FindGroup,
	"FINDITEM"			,3,3,rxcf_FindItem,

	"ADDARGUMENT"		,2,2,rxcf_AddArgument,
	"ADDGROUP"			,2,2,rxcf_AddGroup,
	"ADDITEM"			,2,2,rxcf_AddItem,

	"REMOVEARGUMENT"	,1,1,rxcf_RemoveArgument,
	"REMOVEGROUP"		,1,1,rxcf_RemoveGroup,
	"REMOVEITEM"		,1,1,rxcf_RemoveItem,

	"GETITEMTYPE"		,1,1,rxcf_GetItemType,
	"GETITEMSTYPE"		,1,1,rxcf_GetItemSType,

	"GETGRPNAME"		,1,1,rxcf_GetGrpName,
	"GETARGNAME"		,1,1,rxcf_GetArgName,

	"GETHDROFGRP"		,1,1,rxcf_GetHdrOfGrp,
	"GETGRPOFARG"		,1,1,rxcf_GetGrpOfArg,
	"GETARGOFITEM"		,1,1,rxcf_GetArgOfItem,

	"GETITEMONLY"		,1,1,rxcf_GetItemOnly,

	"GETOMODE"			,1,1,rxcf_GetOMode,
	"GETWBUFSIZE"		,1,1,rxcf_GetWBufSize,
	"GETPUDDLESIZE"	,1,1,rxcf_GetPuddleSize,

	"CHKHDRFLAG"		,2,2,rxcf_ChkHdrFlag,
	"ADDHDRFLAG"		,2,2,rxcf_AddHdrFlag,
	"REMHDRFLAG"		,2,2,rxcf_RemHdrFlag,
	"SETWBUFSIZE"		,2,2,rxcf_SetWBufSize
};

__stdargs __saveds ULONG RexxDispatch ( struct RexxMsg * RxMsg, UBYTE ** ResultStr )
{
	ULONG	Result = RXERR_FUNC_NOT_FOUND;

	if ( IsRexxMsg(RxMsg) || ( (RXCODEMASK & RxMsg->rm_Action) != RXFUNC ) )
	{
		UBYTE		NumEntry, NumArgs;
		STRPTR	FuncName = ARG0(RxMsg);
		STRPTR	ResStr = NULL;
		FuncListEntry *FuncEntry = 0;

		if ( ( *((ULONG *)FuncName) & 0xFFFFFF00L ) != 0x43465F00 ) // If 'CF_ '
			goto OnError;

		FuncName += 3;

		for (NumEntry = 0; NumEntry < BUILTIN_FUNCS; NumEntry ++ )
		{
			if ( !StrCmp (FuncName, FuncList[NumEntry].String) )
			{
				FuncEntry = &FuncList[NumEntry];
				break;
			}
		}

//		if ( NumEntry == BUILTIN_FUNCS )	goto OnError;
		if ( !FuncEntry )	goto OnError;

		NumArgs = RxMsg->rm_Action & RXARGMASK;

		if ( (NumArgs < FuncEntry->MinArgs) || (NumArgs > FuncEntry->MaxArgs) )
			return (RXERR_WRONG_NUM_ARGS);

		if ( !RXARG1 )	return (RXERR_INVALID_ARG);

		if ( !NumEntry ) // FuncEntry->MaxArgs & NOFIRST_ADR_ARG
			Result = (FuncEntry->Function) (RxMsg, &ResStr, RXARG1);
		else
		{
			VOID *FirstAdrArg;

			if ( StrToLong (RXARG1, (LONG *)&FirstAdrArg) != -1 )
				Result = (FuncEntry->Function) (RxMsg, &ResStr, FirstAdrArg);
			else return (RXERR_INVALID_ARG);
		}

		if ( Result == RC_OK )
		{
/*
			if ( !( *ResultStr = ResStr ? ResStr : CreateArgstring("",0) ) )
				return (RXERR_NO_MEMORY);
*/
			if ( !( *ResultStr = ResStr ? ResStr : SetRC_FALSE () ) )
				return (RXERR_NO_MEMORY);
		}
	}
	else Result = RXERR_INVALID_MSGPKT;

OnError:
	return (Result);
}
