/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Last.c
**		$DESCRIPTION: rxcf_Last#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_LastArgument *******************************
*
*   NAME
*        cf_LastArgument -- Returns the previous argument node.
*
*   SYNOPSIS
*        LastArgNode = cf_LastArgument(ArgNode)
*
*        LASTARGNODE/N cf_LastArgument(ARGNODE/N/A)
*
*   FUNCTION
*        This function returns the previous argument node, or NULL if there
*        are no more argument nodes in the list.
*
*   INPUTS
*        ArgNode - The argument node.
*
*   RESULT
*        LastArgNode - Last argument node or NULL.
*
*   SEE ALSO
*        cf_LastGroup(), cf_LastItem(), cf_LockArgList()
*
******************************************************************************
*
*/

UWORD rxcf_LastArgument ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	CFArgument	* LastArgNode;

	if ( LastArgNode = cf_LastArgument (ArgNode) )
		*ResStr = CreateNumArgStrP (LastArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_LastGroup **********************************
*
*   NAME
*        cf_LastGroup -- Returns the previous group node.
*
*   SYNOPSIS
*        LastGrpNode = cf_LastGroup(GrpNode)
*
*        LASTGRPNODE/N cf_LastGroup(GRPNODE/N/A)
*
*   FUNCTION
*        This function returns the previous group node, or NULL if there are
*        no more group nodes in the list.
*
*   INPUTS
*        GrpNode - The group node.
*
*   RESULT
*        LastGrpNode - Last group node or NULL.
*
*   SEE ALSO
*        cf_LastArgument(), cf_LastItem(), cf_LockGrpList()
*
******************************************************************************
*
*/

UWORD rxcf_LastGroup ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFGroup	* LastGrpNode;

	if ( LastGrpNode = cf_LastGroup (GrpNode) )
		*ResStr = CreateNumArgStrP (LastGrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_LastItem ***********************************
*
*   NAME
*        cf_LastItem -- Returns the previous item node.
*
*   SYNOPSIS
*        LastItemNode = cf_LastItem(ItemNode)
*
*        LASTITEMNODE/N cf_LastItem(ITEMNODE/N/A)
*
*   FUNCTION
*        This function returns the previous item node, or NULL if there are
*        no more item nodes in the list.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        LastItemNode - Last item node or NULL.
*
*   SEE ALSO
*        cf_LastArgument(), cf_LastGroup(), cf_LockItemList()
*
******************************************************************************
*
*/

UWORD rxcf_LastItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	CFItem	* LastItemNode;

	if ( LastItemNode = cf_LastItem (ItemNode) )
		*ResStr = CreateNumArgStrP (LastItemNode);
	return (RC_OK);
}
