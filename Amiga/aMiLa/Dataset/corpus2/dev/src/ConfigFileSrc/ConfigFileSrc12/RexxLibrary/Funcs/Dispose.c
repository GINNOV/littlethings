/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Dispose.c
**		$DESCRIPTION: rxcf_Dispose#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_DisposeArgument ****************************
*
*   NAME
*        cf_DisposeArgument -- Remove and dispose an argument node.
*
*   SYNOPSIS
*        cf_DisposeArgument(ArgNode)
*
*        cf_DisposeArgument(ARGNODE/N/A)
*
*   FUNCTION
*        This function remove and dispose an argument node. The item list
*        will also be cleared.
*
*   INPUTS
*        ArgNode - The argument node to remove and dispose.
*
*   NOTES
*        If the ArgNode already removed, the function only dispose the
*        argument node.
*
*   SEE ALSO
*        cf_DisposeGroup(), cf_DisposeItem()
*
******************************************************************************
*
*/

UWORD rxcf_DisposeArgument ( RX_FUNC_ARGS, CFArgument	* ArgNode )
{
	cf_DisposeArgument (ArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_DisposeGroup *******************************
*
*   NAME
*        cf_DisposeGroup -- Remove and dispose a group node.
*
*   SYNOPSIS
*        cf_DisposeGroup(GrpNode)
*
*        cf_DisposeGroup(GRPNODE/N/A)
*
*   FUNCTION
*        This function remove and dispose a group node. All argument nodes
*        will also be cleared.
*
*   INPUTS
*        GrpNode - The group node to remove and dispose.
*
*   NOTES
*        If the GrpNode already removed, the function only dispose the
*        group node.
*
*   SEE ALSO
*        cf_DisposeArgument(), cf_DisposeItem()
*
******************************************************************************
*
*/

UWORD rxcf_DisposeGroup ( RX_FUNC_ARGS, CFGroup	* GrpNode )
{
	cf_DisposeGroup (GrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_DisposeItem ********************************
*
*   NAME
*        cf_DisposeItem -- Remove and dispose an item node.
*
*   SYNOPSIS
*        cf_DisposeItem(ItemNode)
*
*        cf_DisposeItem(ITEMNODE/N/A)
*
*   FUNCTION
*        This function remove and dispose an item node.
*
*   INPUTS
*        ItemNode - The item node to remove and dispose.
*
*   NOTES
*        If the ItemNode already removed, the function only dispose the
*        item node.
*
*   SEE ALSO
*        cf_DisposeGroup(), cf_DisposeArgument()
*
******************************************************************************
*
*/

UWORD rxcf_DisposeItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	cf_DisposeItem (ItemNode);
	return (RC_OK);
}
