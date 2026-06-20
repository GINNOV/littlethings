/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Next.c
**		$DESCRIPTION: rxcf_Next#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_NextArgument *******************************
*
*   NAME
*        cf_NextArgument -- Returns the next argument node.
*
*   SYNOPSIS
*        NextArgNode = cf_NextArgument(ArgNode)
*
*        NEXTARGNODE/N cf_NextArgument(ARGNODE/N/A)
*
*   FUNCTION
*        This function returns the next argument node, or NULL if there are
*        no more argument nodes in the list.
*
*   INPUTS
*        ArgNode - The argument node.
*
*   RESULT
*        NextArgNode - Next argument node or NULL.
*
*   SEE ALSO
*        cf_NextGroup(), cf_NextItem(), cf_LockArgList()
*
******************************************************************************
*
*/

UWORD rxcf_NextArgument ( RX_FUNC_ARGS, CFArgument	* ArgNode )
{
	CFArgument	* NextArgNode;

	if ( NextArgNode = cf_NextArgument (ArgNode) )
		*ResStr = CreateNumArgStrP (NextArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_NextGroup **********************************
*
*   NAME
*        cf_NextGroup -- Returns the next group node.
*
*   SYNOPSIS
*        NextGrpNode = cf_NextGroup(GrpNode)
*
*        NEXTGRPNODE/N cf_NextGroup(GRPNODE/N/A)
*
*   FUNCTION
*        This function returns the next group node, or NULL if there are no
*        more group nodes in the list.
*
*   INPUTS
*        GrpNode - The group node.
*
*   RESULT
*        NextGrpNode - Next group node or NULL.
*
*   SEE ALSO
*        cf_NextArgument(), cf_NextItem(), cf_LockGrpList()
*
******************************************************************************
*
*/

UWORD rxcf_NextGroup ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFGroup	* NextGrpNode;

	if ( NextGrpNode = cf_NextGroup (GrpNode) )
		*ResStr = CreateNumArgStrP (NextGrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_NextItem ***********************************
*
*   NAME
*        cf_NextItem -- Returns the next item node.
*
*   SYNOPSIS
*        NextItemNode = cf_NextItem(ItemNode)
*
*        NEXTITEMNODE/N cf_NextItem(ITEMNODE/N/A)
*
*   FUNCTION
*        This function returns the next item node, or NULL if there are no
*        more item nodes in the list.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        NextItemNode - Next item node or NULL.
*
*   SEE ALSO
*        cf_NextArgument(), cf_NextGroup(), cf_LockItemList()
*
******************************************************************************
*
*/

UWORD rxcf_NextItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	CFItem	* NextItemNode;

	if ( NextItemNode = cf_NextItem (ItemNode) )
		*ResStr = CreateNumArgStrP (NextItemNode);
	return (RC_OK);
}
