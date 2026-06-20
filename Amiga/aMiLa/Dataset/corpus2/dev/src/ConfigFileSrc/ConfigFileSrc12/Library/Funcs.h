/*
**		$PROJECT: ConfigFile.library
**		$FILE: Funcs.h
**		$DESCRIPTION: Prototypes of the library functions.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef FUNCS_H
#define FUNCS_H

/***************************************************************************/

SLibCall iCFHeader * cf_Open ( REGA0 STRPTR, REGD0 ULONG, REGA1 ULONG * );
LibCall VOID cf_Close ( REGA0 iCFHeader * );

/***************************************************************************/

LibCall BOOL cf_Read ( REGA0 iCFHeader *, REGA1 ULONG * );
LibCall BOOL cf_Write ( REGA0 iCFHeader *, REGD0 ULONG, REGA1 ULONG * );

/***************************************************************************/

LibCall VOID cf_AddArgument ( REGA0 iCFGroup *, REGA1 iCFArgument * );
LibCall VOID cf_AddGroup ( REGA0 iCFHeader *, REGA1 iCFGroup * );
LibCall VOID cf_AddItem ( REGA0 iCFArgument *, REGA1 iCFItem * );

/***************************************************************************/

LibCall iCFArgument * cf_NewArgument ( REGA0 iCFGroup *, REGA1 STRPTR );
LibCall iCFGroup * cf_NewGroup ( REGA0 iCFHeader *, REGA1 STRPTR );
LibCall iCFItem * cf_NewItem ( REGA0 iCFArgument *, REGD0 LONG, REGD1 ULONG, REGD2 ULONG );
SLibCall iCFArgument * cf_NewArgItem ( REGA0 iCFGroup *, REGA1 STRPTR, REGD0 LONG, REGD1 ULONG, REGD2 ULONG );

iCFGroup * NewGrp ( iCFHeader * , STRPTR , ULONG );
iCFArgument * NewArg ( iCFGroup * , STRPTR , ULONG );

/***************************************************************************/

LibCall VOID cf_DisposeArgument ( REGA0 iCFArgument * );
LibCall VOID cf_DisposeGroup ( REGA0 iCFGroup * );
LibCall VOID cf_DisposeItem ( REGA0 iCFItem * );

VOID DelArg ( APTR , iCFArgument * );
VOID DelGrp ( APTR , iCFGroup * );
VOID DelItem ( APTR , iCFItem * );

/***************************************************************************/

LibCall iCFArgument * cf_CloneArgument ( REGA0 iCFArgument * );
LibCall iCFGroup * cf_CloneGroup ( REGA0 iCFGroup * );
SLibCall iCFItem * cf_CloneItem ( REGA0 iCFItem * );

/***************************************************************************/

LibCall VOID cf_RemoveArgument ( REGA0 iCFArgument * );
LibCall VOID cf_RemoveGroup ( REGA0 iCFGroup * );
LibCall VOID cf_RemoveItem ( REGA0 iCFItem * );

/***************************************************************************/

LibCall VOID cf_ClearArgList ( REGA0 iCFGroup * );
LibCall VOID cf_ClearGrpList ( REGA0 iCFHeader * );
LibCall VOID cf_ClearItemList ( REGA0 iCFArgument * );

/***************************************************************************/

LibCall VOID cf_ChangeArgument ( REGA0 iCFArgument *, REGA1 STRPTR );
LibCall VOID cf_ChangeGroup ( REGA0 iCFGroup *, REGA1 STRPTR );
LibCall VOID cf_ChangeItem ( REGA0 iCFItem *, REGD0 LONG, REGD1 ULONG, REGD2 ULONG );

/***************************************************************************/

LibCall iCFArgument * cf_FindArgument ( REGA0 iCFGroup *, REGA1 STRPTR );
LibCall iCFGroup * cf_FindGroup ( REGA0 iCFHeader *, REGA1 STRPTR );
SLibCall iCFItem * cf_FindItem ( REGA0 iCFArgument *, REGD0 LONG, REGD1 ULONG );

/***************************************************************************/

SLibCall LONG cf_GetItem ( REGA0 iCFItem *, REGD0 ULONG, REGD1 LONG );
SLibCall LONG cf_GetItemNum ( REGA0 iCFArgument *, REGD0 ULONG, REGD1 ULONG, REGD2 LONG );

/***************************************************************************/

SLibCall iCFArgument * cf_LockArgList ( REGA0 iCFGroup * );
SLibCall iCFGroup * cf_LockGrpList ( REGA0 iCFHeader * );
SLibCall iCFItem * cf_LockItemList ( REGA0 iCFArgument * );

/***************************************************************************/

SLibCall VOID cf_UnlockArgList ( REGA0 iCFGroup * );
SLibCall VOID cf_UnlockGrpList ( REGA0 iCFHeader * );
SLibCall VOID cf_UnlockItemList ( REGA0 iCFArgument * );

#define cf_UnlockArgList(a)
#define cf_UnlockGrpList(a)
#define cf_UnlockItemList(a)

/***************************************************************************/

SLibCall iCFArgument * cf_NextArgument ( REGA0 iCFArgument * );
SLibCall iCFGroup * cf_NextGroup ( REGA0 iCFGroup * );
SLibCall iCFItem * cf_NextItem ( REGA0 iCFItem * );

/***************************************************************************/

SLibCall iCFArgument * cf_LastArgument ( REGA0 iCFArgument * );
SLibCall iCFGroup * cf_LastGroup ( REGA0 iCFGroup * );
SLibCall iCFItem * cf_LastItem ( REGA0 iCFItem * );

/***************************************************************************/

LibCall iCFHeader * cf_OpenPS ( REGA0 STRPTR, REGD0 ULONG, REGA1 ULONG *, REGD1 ULONG );

/***************************************************************************/

SLibCall UBYTE cf_GetItemType ( REGA0 iCFItem * );
SLibCall UBYTE cf_GetItemSType ( REGA0 iCFItem * );

/***************************************************************************/

SLibCall STRPTR cf_GetGrpName ( REGA0 iCFGroup * );
SLibCall STRPTR cf_GetArgName ( REGA0 iCFArgument * );

/***************************************************************************/

SLibCall iCFHeader * cf_GetHdrOfGrp ( REGA0 iCFGroup * );
SLibCall iCFGroup * cf_GetGrpOfArg ( REGA0 iCFArgument * );
SLibCall iCFArgument * cf_GetArgOfItem ( REGA0 iCFItem * );

/***************************************************************************/

SLibCall LONG cf_GetItemOnly ( REGA0 iCFItem * );

/***************************************************************************/

#endif /* FUNCS_H */
