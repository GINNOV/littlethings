/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Unlock.c
**		$DESCRIPTION: rxcf_Unlock#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_UnlockArgList ******************************
*
*   NAME
*        cf_UnlockArgList -- Unlocks the argument list of the group node.
*
*   SYNOPSIS
*        cf_UnlockArgList(GrpNode)
*
*        cf_UnlockArgList(GRPNODE/N/A)
*
*   FUNCTION
*        This function unlocks the access on the argument list.
*
*   INPUTS
*        GrpNode - The group node for the argument list.
*
*   SEE ALSO
*        cf_UnlockGrpList(), cf_UnlockItemList(), cf_LockArgList()
*
******************************************************************************
*
*/

UWORD rxcf_UnlockArgList ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	cf_UnlockArgList (GrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_UnlockGrpList ******************************
*
*   NAME
*        cf_UnlockGrpList -- Unlocks the group list of the header.
*
*   SYNOPSIS
*        cf_UnlockGrpList(Header)
*
*        cf_UnlockGrpList(HEADER/N/A)
*
*   FUNCTION
*        This function unlocks the access on the group list.
*
*   INPUTS
*        Header - Pointer to the CFHeader structure.
*
*   SEE ALSO
*        cf_UnlockArgList(), cf_UnlockItemList(), cf_LockGrpList()
*
******************************************************************************
*
*/

UWORD rxcf_UnlockGrpList ( RX_FUNC_ARGS, CFHeader * Header )
{
	cf_UnlockGrpList (Header);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_UnlockItemList ******************************
*
*   NAME
*        cf_UnlockItemList -- Unlocks the item list of the argument node.
*
*   SYNOPSIS
*        cf_UnlockItemList(ArgNode)
*
*        cf_UnlockItemList(ARGNODE/N/A)
*
*   FUNCTION
*        This function unlocks the access on the item list.
*
*   INPUTS
*        ArgNode - The argument node for item list.
*
*   SEE ALSO
*        cf_UnlockArgList(), cf_UnlockGrpList(), cf_LockItemList()
*
******************************************************************************
*
*/

UWORD rxcf_UnlockItemList ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	cf_UnlockItemList (ArgNode);
	return (RC_OK);
}
