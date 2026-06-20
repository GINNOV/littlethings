/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Add.c
**		$DESCRIPTION: rxcf_Add#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_AddArgument ********************************
*
*   NAME
*        cf_AddArgument -- Adds an argument node to the argument list of a
*                          group node.
*
*   SYNOPSIS
*        cf_AddArgument(GrpNode,ArgNode)
*
*        cf_AddArgument(GRPNODE/N/A,ARGNODE/N/A)
*
*   FUNCTION
*        This function adds an argument node to the argument list of a
*        group node.
*
*   INPUTS
*        GrpNode - The group node for add to.
*        ArgNode - Pointer to the argument node.
*
*   EXAMPLE
*        ...
*        myNewArgNode = cf_CloneArgument(myArgNode)
*        cf_AddArgument(myGrpNode, myNewArgNode)
*        ...
*
*   SEE ALSO
*        cf_AddGroup(), cf_AddItem()
*
******************************************************************************
*
*/

UWORD rxcf_AddArgument ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFArgument	* ArgNode;

	if ( ArgNode = GetAdrArg (RxMsg, 2) )
	{
		cf_AddArgument (GrpNode, ArgNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_AddGroup ***********************************
*
*   NAME
*        cf_AddGroup -- Adds a group node to the grouplist of a header.
*
*   SYNOPSIS
*        cf_AddGroup(Header,GrpNode)
*
*        cf_AddGroup(HEADER/N/A,GRPNODE/N/A)
*
*   FUNCTION
*        This function adds a group node to the group list of a header.
*
*   INPUTS
*        Header - Pointer to the Header for add to.
*        GrpNode - Pointer to the group node.
*
*   EXAMPLE
*        ...
*        myNewGrpNode = cf_CloneGroup(myGrpNode)
*        cf_AddGroup(myHeader, myNewGrpNode)
*        ...
*
*   SEE ALSO
*        cf_AddArgument(), cf_AddItem()
*
******************************************************************************
*
*/

UWORD rxcf_AddGroup ( RX_FUNC_ARGS, CFHeader	* Header )
{
	CFGroup 	* GrpNode;

	if ( GrpNode = GetAdrArg (RxMsg, 2) )
	{
		cf_AddGroup (Header, GrpNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_AddItem ************************************
*
*   NAME
*        cf_AddItem -- Adds an item node to the item list of an argument
*                      node.
*
*   SYNOPSIS
*        cf_AddItem(ArgNode,ItemNode)
*
*        cf_AddItem(ARGNODE/N/A,ITEMNODE/N/A)
*
*   FUNCTION
*        This function adds an item node to the item list of an argument
*        node.
*
*   INPUTS
*        ArgNode - The argument node for add to.
*        ItemNode - Pointer to the item node.
*
*   EXAMPLE
*        ...
*        myNewItemNode = cf_CloneItem(myItemNode)
*        cf_AddItem(myArgNode, myNewItemNode)
*        ...
*
*   SEE ALSO
*        cf_AddArgument(), cf_AddGroup()
*
******************************************************************************
*
*/

UWORD rxcf_AddItem ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	CFItem * ItemNode;

	if ( ItemNode = GetAdrArg (RxMsg, 2) )
	{
		cf_AddItem (ArgNode, ItemNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}
