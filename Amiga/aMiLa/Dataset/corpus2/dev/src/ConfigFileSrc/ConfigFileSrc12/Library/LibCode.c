/*
**		$PROJECT: ConfigFile.library
**		$FILE: LibCode.c
**		$DESCRIPTION: Code for library init, open and close.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

LibCall struct CFBase *	LibInit ( REGA0 BPTR, REGD0 struct CFBase *, REGA6 struct ExecBase * );
LibCall struct CFBase * LibOpen ( REGA6 struct CFBase * );
LibCall BPTR				LibExpunge ( REGA6 struct CFBase * );
LibCall BPTR				LibClose ( REGA6 struct CFBase * );
LONG 							LibNull ( VOID );

extern UBYTE __far	LibName[],
							LibID[];

struct ExecBase	* SysBase = 0;
struct DosLibrary	* DOSBase = 0;
struct Library		* UtilityBase = 0;

APTR LibVectors[] =
{
	LibOpen,
	LibClose,
	LibExpunge,
	LibNull,

	cf_Open,
	cf_Close,

	cf_Read,
	cf_Write,

	cf_AddGroup,
	cf_AddArgument,
	cf_AddItem,

	cf_NewGroup,
	cf_NewArgument,
	cf_NewItem,
	cf_NewArgItem,

	cf_DisposeGroup,
	cf_DisposeArgument,
	cf_DisposeItem,

	cf_CloneGroup,
	cf_CloneArgument,
	cf_CloneItem,

	cf_RemoveGroup,
	cf_RemoveArgument,
	cf_RemoveItem,

	cf_ClearGrpList,
	cf_ClearArgList,
	cf_ClearItemList,

	cf_ChangeGroup,
	cf_ChangeArgument,
	cf_ChangeItem,

	cf_FindGroup,
	cf_FindArgument,
	cf_FindItem,

	cf_GetItem,
	cf_GetItemNum,

	cf_LockGrpList,
	cf_LockArgList,
	cf_LockItemList,

	cf_UnlockGrpList,
	cf_UnlockArgList,
	cf_UnlockItemList,

	cf_NextGroup,
	cf_NextArgument,
	cf_NextItem,

	cf_LastGroup,
	cf_LastArgument,
	cf_LastItem,

	cf_OpenPS,

	cf_GetItemType,
	cf_GetItemSType,

	cf_GetGrpName,
	cf_GetArgName,

	cf_GetHdrOfGrp,
	cf_GetGrpOfArg,
	cf_GetArgOfItem,

	cf_GetItemOnly,

	(APTR)-1
};

struct { ULONG DataSize; APTR Table; APTR Data; struct CFBase * (*Init)(); }
__aligned LibInitTab =
{
	sizeof(struct CFBase),
	LibVectors,
	NULL,
	LibInit
};

	/* LibInit():
	 *
	 *	Initialize the library.
	 */

LibCall struct CFBase *
LibInit ( REGA0 BPTR LibSegment, REGD0 struct CFBase * CFBase, REGA6 struct ExecBase * ExecBase )
{
	CFBase->LibNode.lib_Node.ln_Type	= NT_LIBRARY;
	CFBase->LibNode.lib_Node.ln_Name	= LibName;
	CFBase->LibNode.lib_Node.ln_Pri	= 100;
	CFBase->LibNode.lib_Flags			= LIBF_CHANGED | LIBF_SUMUSED;
	CFBase->LibNode.lib_Version		= VERSION;
	CFBase->LibNode.lib_Revision		= REVISION;
	CFBase->LibNode.lib_IdString		= LibID;

	CFBase->Segment = LibSegment;

	SysBase = ExecBase;

	if ( SysBase->LibNode.lib_Version < 36 )
		return (NULL);

	return (CFBase);
}

	/* LibOpen():
	 *
	 *	Open the library, as called via OpenLibrary()
	 */

LibCall struct CFBase *
LibOpen ( REGA6 struct CFBase * CFBase )
{
	CFBase->LibNode.lib_OpenCnt++;
	CFBase->LibNode.lib_Flags &= ~LIBF_DELEXP;

	if ( CFBase->LibNode.lib_OpenCnt == 1 )
	{
		DOSBase		= TaggedOpenLibrary (TLIB_DOS);
		UtilityBase	= TaggedOpenLibrary (TLIB_UTILITY);
/*
		Printf ("sizeof(iCFHeader)   = %ld\n", sizeof(iCFHeader));
		Printf ("sizeof(iCFGroup)    = %ld\n", sizeof(iCFGroup));
		Printf ("sizeof(iCFArgument) = %ld\n", sizeof(iCFArgument));
		Printf ("sizeof(iCFItem)     = %ld\n", sizeof(iCFItem));
*/
		return (CFBase);
	}
	else
		return (CFBase);
}

	/* LibExpunge();
	 *
	 *	Expunge the library, remove it from memory
	 */

LibCall BPTR
LibExpunge ( REGA6 struct CFBase * CFBase )
{
	if ( !CFBase->LibNode.lib_OpenCnt ) // If OpenCnt Null
	{
		BPTR TempSegment = CFBase->Segment;

		Remove (CFBase);

		FreeMem ((BYTE *)CFBase-CFBase->LibNode.lib_NegSize,
					CFBase->LibNode.lib_NegSize+CFBase->LibNode.lib_PosSize);

		return (TempSegment);
	}
	else
	{
		CFBase->LibNode.lib_Flags |= LIBF_DELEXP;

		return (NULL);
	}
}

	/* LibClose();
	 *
	 *	Close the library, as called by CloseLibrary()
	 */

LibCall BPTR
LibClose ( REGA6 struct CFBase *CFBase )
{
	if ( CFBase->LibNode.lib_OpenCnt )
		CFBase->LibNode.lib_OpenCnt --;

	if ( !CFBase->LibNode.lib_OpenCnt )
	{
		CloseLibrary (DOSBase);
		CloseLibrary (UtilityBase);

		if ( CFBase->LibNode.lib_Flags & LIBF_DELEXP )
			return (LibExpunge (CFBase));
	}

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
