/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Clear.c
**		$DESCRIPTION: rxcf_Clear#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_ClearArgList *******************************
*
*   NAME
*        cf_ClearArgList -- Clears all argument and item nodes of a
*                           group node.
*
*   SYNOPSIS
*        cf_ClearArgList(GrpNode)
*
*        cf_ClearArgList(GRPNODE/N/A)
*
*   FUNCTION
*        This function clears all argument and item nodes of a group node.
*
*   INPUTS
*        GrpNode - The group node for the argument list.
*
*   SEE ALSO
*        cf_ClearGrpList(), cf_ClearItemList()
*
******************************************************************************
*
*/

UWORD rxcf_ClearArgList ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	cf_ClearArgList (GrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_ClearGrpList *******************************
*
*   NAME
*        cf_ClearGrpList -- Clears all group/argument/item nodes.
*
*   SYNOPSIS
*        cf_ClearGrpList(Header)
*
*        cf_ClearGrpList(HEADER/N/A)
*
*   FUNCTION
*        This function clears all group/argument/item nodes.
*
*   INPUTS
*        Header - The Header for group list.
*
*   SEE ALSO
*        cf_ClearArgList(), cf_ClearItemList()
*
******************************************************************************
*
*/

UWORD rxcf_ClearGrpList ( RX_FUNC_ARGS, CFHeader * Header )
{
	cf_ClearGrpList (Header);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_ClearItemList ******************************
*
*   NAME
*        cf_ClearItemList -- Clears all item nodes of an argument node.
*
*   SYNOPSIS
*        cf_ClearItemList(ArgNode)
*
*        cf_ClearItemList(ARGNODE/N/A)
*
*   FUNCTION
*        This function clears all item nodes of an argument node.
*
*   INPUTS
*        ArgNode - The argument node for the item list.
*
*   SEE ALSO
*        cf_ClearArgList(), cf_ClearGrpList()
*
******************************************************************************
*
*/

UWORD rxcf_ClearItemList ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	cf_ClearItemList (ArgNode);
	return (RC_OK);
}
