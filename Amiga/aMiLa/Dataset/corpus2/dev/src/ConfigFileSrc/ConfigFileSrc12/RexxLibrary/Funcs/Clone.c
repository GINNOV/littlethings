/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Clone.c
**		$DESCRIPTION: rxcf_Clone#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_CloneArgument ******************************
*
*   NAME
*        cf_CloneArgument -- Copy an argument node with all item nodes.
*
*   SYNOPSIS
*        NewArgNode = cf_CloneArgument(ArgNode)
*
*        NEWARGNODE/N cf_CloneArgument(ARGNODE/N/A)
*
*   FUNCTION
*        This function duplicates an argument node with all item nodes.
*        Note the duplicated ArgNode is not added.
*
*   INPUTS
*        ArgNode - The argument node to clone.
*
*   RESULT
*        NewArgNode - The new argument node or NULL by failure.
*
*   EXAMPLE
*        ...
*        myArgNode = cf_NewArgument(myGrpNode, "ExampleArgument")
*        cf_AddArgument(myGrpNode, cf_CloneArgument(myArgNode))
*        ...
*
*        In the CF file:
*
*        ...
*        [ExampleGroup]
*
*        ...
*        ExampleArgument=
*        ...
*        ExampleArgument=
*        ...
*
*   SEE ALSO
*        cf_CloneGroup(), cf_CloneItem()
*
******************************************************************************
*
*/

UWORD rxcf_CloneArgument ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	CFArgument	* NewArgNode;

	if ( NewArgNode = cf_CloneArgument (ArgNode) )
		*ResStr = CreateNumArgStrP (NewArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_CloneGroup *********************************
*
*   NAME
*        cf_CloneGroup -- Copy a group node with all argument and item nodes.
*
*   SYNOPSIS
*        NewGrpNode = cf_CloneGroup(GrpNode)
*
*        NEWGRPNODE/N cf_CloneGroup(GRPNDE/N/A)
*
*   FUNCTION
*        This function duplicates a group node with all argument and item
*        nodes. Note the duplicated GrpNode is not added.
*
*   INPUTS
*        GrpNode - The group node to clone.
*
*   RESULT
*        NewGrpNode - The new group node or NULL by failure.
*
*   EXAMPLE
*        ...
*        myGrpNode = cf_NewGroup(myHeader, "ExampleGroup")
*        cf_AddGroup(myHeader, cf_CloneGroup(myGrpNode))
*        ...
*
*        In the CF file:
*
*        ...
*        [ExampleGroup]
*        ...
*        [ExampleGroup]
*        ...
*
*   SEE ALSO
*        cf_CloneArgument(), cf_CloneItem()
*
******************************************************************************
*
*/

UWORD rxcf_CloneGroup ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFGroup	* NewGrpNode;

	if ( NewGrpNode = cf_CloneGroup (GrpNode) )
		*ResStr = CreateNumArgStrP (NewGrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_CloneItem **********************************
*
*   NAME
*        cf_CloneItem -- Copy an item node.
*
*   SYNOPSIS
*        NewItemNode = cf_CloneItem(ItemNode)
*
*        NEWITEMNODE/N cf_CloneItem(ITEMNODE/N/A)
*
*   FUNCTION
*        This function duplicates an item node. Note the duplicated ItemNode
*        is not added.
*
*   INPUTS
*        ItemNode - The item node to clone.
*
*   RESULT
*        NewItemNode - The new item node or NULL by failure.
*
*   EXAMPLE
*        ...
*        myItemNode = cf_NewItem(myArgNode, "ExampleItem",ITYP_STRING)
*        cf_AddItem(myArgNode, cf_CloneItem(myItemNode))
*        ...
*
*        In the CF file:
*
*        ...
*        [ExampleGroup]
*
*        ...
*        ExampleArgument="ExampleItem","ExampleItem"
*        ...
*
*   SEE ALSO
*        cf_CloneGroup(), cf_CloneArgument()
*
******************************************************************************
*
*/

UWORD rxcf_CloneItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	CFItem	* NewItemNode;

	if ( NewItemNode = cf_CloneItem (ItemNode) )
		*ResStr = CreateNumArgStrP (NewItemNode);
	return (RC_OK);
}
