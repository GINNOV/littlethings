/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: GetOf.c
**		$DESCRIPTION: rxcf_Get#?Of#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_GetHdrOfGrp ********************************
*
*   NAME
*        cf_GetHdrOfGrp -- Get the parent node of a group node.
*
*   SYNOPSIS
*        Header = cf_GetHdrOfGrp(GrpNode)
*
*        HEADER/N cf_GetHdrOfGrp(GRPNODE/N/A)
*
*   FUNCTION
*        This function gets the parent node (Header) of a group node.
*
*   INPUTS
*        GrpNode - The group node.
*
*   RESULT
*        Header - Pointer to the header.
*
*   SEE ALSO
*        cf_GetGrpOfArg(), cf_GetArgOfItem()
*
******************************************************************************
*
*/

UWORD rxcf_GetHdrOfGrp ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFHeader	* Header;

	if ( Header = cf_GetHdrOfGrp (GrpNode) )
		*ResStr = CreateNumArgStrP (Header);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetGrpOfArg ********************************
*
*   NAME
*        cf_GetGrpOfArg -- Get the parent node of an argument node.
*
*   SYNOPSIS
*        GrpNode = cf_GetGrpOfArg(ArgNode)
*
*        GRPNODE/N cf_GetGrpOfArg(ARGNODE/N/A)
*
*   FUNCTION
*        This function gets the parent node (GrpNode) of an argument node.
*
*   INPUTS
*        ArgNode - The argument node.
*
*   RESULT
*        GrpNode - Pointer to the group node.
*
*   SEE ALSO
*        cf_GetHdrOfGrp(), cf_GetArgOfItem()
*
******************************************************************************
*
*/

UWORD rxcf_GetGrpOfArg ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	CFGroup	* GrpNode;

	if ( GrpNode = cf_GetGrpOfArg (ArgNode) )
		*ResStr = CreateNumArgStrP (GrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetArgOfItem *******************************
*
*   NAME
*        cf_GetArgOfItem -- Get the parent node of an item node.
*
*   SYNOPSIS
*        ArgNode = cf_GetArgOfItem(ItemNode)
*
*        ARGNODE/N cf_GetArgOfItem(ITEMNODE/N/A)
*
*   FUNCTION
*        This function gets the parent node (ArgNode) of an item node.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        ArgNode - Pointer to the argument node.
*
*   SEE ALSO
*        cf_GetGrpOfArg(), cf_GetHdrOfGrp()
*
******************************************************************************
*
*/

UWORD rxcf_GetArgOfItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	CFArgument	* ArgNode;

	if ( ArgNode = cf_GetArgOfItem (ItemNode) )
		*ResStr = CreateNumArgStrP (ArgNode);
	return (RC_OK);
}
