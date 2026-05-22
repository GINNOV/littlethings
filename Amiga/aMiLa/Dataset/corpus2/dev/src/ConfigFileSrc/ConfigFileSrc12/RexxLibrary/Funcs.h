/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Funcs.h
**		$DESCRIPTION: Prototypes of the library functions.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef FUNCS_H
#define FUNCS_H

/***************************************************************************/

UWORD rxcf_Open	( RX_PFUNC_ARGS );
UWORD rxcf_Close	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_Read	( RX_PFUNC_ARGS );
UWORD rxcf_Write	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_AddArgument	( RX_PFUNC_ARGS );
UWORD rxcf_AddGroup		( RX_PFUNC_ARGS );
UWORD rxcf_AddItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_NewArgument	( RX_PFUNC_ARGS );
UWORD rxcf_NewGroup		( RX_PFUNC_ARGS );
UWORD rxcf_NewItem		( RX_PFUNC_ARGS );
UWORD rxcf_NewArgItem	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_DisposeArgument	( RX_PFUNC_ARGS );
UWORD rxcf_DisposeGroup		( RX_PFUNC_ARGS );
UWORD rxcf_DisposeItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_CloneArgument	( RX_PFUNC_ARGS );
UWORD rxcf_CloneGroup		( RX_PFUNC_ARGS );
UWORD rxcf_CloneItem			( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_RemoveArgument	( RX_PFUNC_ARGS );
UWORD rxcf_RemoveGroup		( RX_PFUNC_ARGS );
UWORD rxcf_RemoveItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_ClearArgList		( RX_PFUNC_ARGS );
UWORD rxcf_ClearGrpList		( RX_PFUNC_ARGS );
UWORD rxcf_ClearItemList	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_ChangeArgument	( RX_PFUNC_ARGS );
UWORD rxcf_ChangeGroup		( RX_PFUNC_ARGS );
UWORD rxcf_ChangeItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_FindArgument	( RX_PFUNC_ARGS );
UWORD rxcf_FindGroup		( RX_PFUNC_ARGS );
UWORD rxcf_FindItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_GetItem		( RX_PFUNC_ARGS );
UWORD rxcf_GetItemNum	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_LockArgList		( RX_PFUNC_ARGS );
UWORD rxcf_LockGrpList		( RX_PFUNC_ARGS );
UWORD rxcf_LockItemList		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_UnlockArgList	( RX_PFUNC_ARGS );
UWORD rxcf_UnlockGrpList	( RX_PFUNC_ARGS );
UWORD rxcf_UnlockItemList	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_NextArgument	( RX_PFUNC_ARGS );
UWORD rxcf_NextGroup		( RX_PFUNC_ARGS );
UWORD rxcf_NextItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_LastArgument	( RX_PFUNC_ARGS );
UWORD rxcf_LastGroup		( RX_PFUNC_ARGS );
UWORD rxcf_LastItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_GetItemType	( RX_PFUNC_ARGS );
UWORD rxcf_GetItemSType	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_GetGrpName	( RX_PFUNC_ARGS );
UWORD rxcf_GetArgName	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_GetHdrOfGrp		( RX_PFUNC_ARGS );
UWORD rxcf_GetGrpOfArg		( RX_PFUNC_ARGS );
UWORD rxcf_GetArgOfItem		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_GetItemOnly	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_GetOMode			( RX_PFUNC_ARGS );
UWORD rxcf_GetWBufSize		( RX_PFUNC_ARGS );
UWORD rxcf_GetPuddleSize	( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_ChkHdrFlag		( RX_PFUNC_ARGS );
UWORD rxcf_AddHdrFlag		( RX_PFUNC_ARGS );
UWORD rxcf_RemHdrFlag		( RX_PFUNC_ARGS );
UWORD rxcf_SetHdrFlag		( RX_PFUNC_ARGS );

/***************************************************************************/

UWORD rxcf_SetWBufSize		( RX_PFUNC_ARGS );

/***************************************************************************/

#endif /* FUNCS_H */
