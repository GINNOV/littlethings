/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Remove.c
**		$DESCRIPTION: rxcf_Remove#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library	*CFBase;

/****** rexxconfigfile.library/cf_RemoveArgument *****************************
*
*   NAME
*        cf_RemoveArgument -- Remove an argument node.
*
*   SYNOPSIS
*        cf_RemoveArgument(ArgNode)
*
*        cf_RemoveArgument(ARGNODE/N/A)
*
*   FUNCTION
*        This function remove an argument node. Note don't adds the removed
*        ArgNode to another open CF file.
*
*   INPUTS
*        ArgNode - The argument node to remove.
*
*   SEE ALSO
*        cf_RemoveGroup(), cf_RemoveItem()
*
******************************************************************************
*
*/

UWORD rxcf_RemoveArgument ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	cf_RemoveArgument (ArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_RemoveGroup ********************************
*
*   NAME
*        cf_RemoveGroup -- Remove a group node.
*
*   SYNOPSIS
*        cf_RemoveGroup(GrpNode)
*
*        cf_RemoveGroup(GRPNODE/N/A)
*
*   FUNCTION
*        This function remove a group node. Note don't adds the removed 
*        GrpNode to another open CF file.
*
*   INPUTS
*        GrpNode - The group node to remove.
*
*   SEE ALSO
*        cf_RemoveArgument(), cf_RemoveItem()
*
******************************************************************************
*
*/

UWORD rxcf_RemoveGroup ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	cf_RemoveGroup (GrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_RemoveItem *********************************
*
*   NAME
*        cf_RemoveItem -- Remove an item node.
*
*   SYNOPSIS
*        cf_RemoveItem(ItemNode)
*
*        cf_RemoveItem(ITEMNODE/N/A)
*
*   FUNCTION
*        This function remove an item node. Note don't adds the removed 
*        ItemNode to another open CF file.
*
*   INPUTS
*        ItemNode - The item node to remove.
*
*   SEE ALSO
*        cf_RemoveGroup(), cf_RemoveArgument()
*
******************************************************************************
*
*/

UWORD rxcf_RemoveItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	cf_RemoveItem (ItemNode);
	return (RC_OK);
}
