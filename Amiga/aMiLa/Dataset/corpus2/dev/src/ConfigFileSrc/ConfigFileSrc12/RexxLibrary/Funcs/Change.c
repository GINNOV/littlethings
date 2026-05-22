/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Change.c
**		$DESCRIPTION: rxcf_Change#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_ChangeArgument *****************************
*
*   NAME
*        cf_ChangeArgument -- Changes the name of an argument node.
*
*   SYNOPSIS
*        cf_ChangeArgument(ArgNode,Name)
*
*        cf_ChangeArgument(ARGNODE/N/A,NAME/A)
*
*   FUNCTION
*        This function changes the name of an argument node.
*
*   INPUTS
*        ArgNode - The argument node.
*        Name - The new name for the argument node.
*
*   SEE ALSO
*        cf_ChangeGroup(), cf_ChangeItem()
*
******************************************************************************
*
*/

UWORD rxcf_ChangeArgument ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	if ( IsValidArg (RxMsg, 2) )
	{
		cf_ChangeArgument (ArgNode, RXARG2);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_ChangeGroup ********************************
*
*   NAME
*        cf_ChangeGroup -- Changes the name of a groupnode.
*
*   SYNOPSIS
*        cf_ChangeGroup(GrpNode,Name)
*
*        cf_ChangeGroup(GRPNODE/N/A,NAME/A)
*
*   FUNCTION
*        This function changes the name of a group node.
*
*   INPUTS
*        GrpNode - The group node for add to.
*        Name - The new name for the group node.
*
*   SEE ALSO
*        cf_ChangeArgument(), cf_ChangeItem()
*
******************************************************************************
*
*/

UWORD rxcf_ChangeGroup ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	if ( IsValidArg (RxMsg, 2) )
	{
		cf_ChangeGroup (GrpNode, RXARG2);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_ChangeItem *********************************
*
*   NAME
*        cf_ChangeItem -- Changes the contents of an item node.
*
*   SYNOPSIS
*        cf_ChangeItem(ItemNode,Contents [,Type] [,SpecialType])
*
*        cf_ChangeItem(ITEMNODE/N/A,CONTENTS/A,TYPE,STYPE)
*
*   FUNCTION
*        This function changes the contents of an item node.
*
*   INPUTS
*        ItemNode - The item node for the changes.
*        Contents - The new contents.
*        Type - The new type (see cf_NewItem()).
*        SpecialType - The new special type (see cf_NewItem()).
*
*   EXAMPLE
*        ...
*        myItemNode = cf_NewItem(myArgNode, 1234567, CF_ITYP_NUMBER)
*        cf_ChangeItem(myItemNode, 1, CF_ITYP_BOOL, CF_STYP_BOOL_ON)
*        ...
*
*        In the CF file:
*
*        [ExampleGroup]
*        ...
*        ExampleArg=ON
*        ...
*
*   SEE ALSO
*        cf_ChangeArgument(), cf_ChangeGroup(), cf_NewItem()
*
******************************************************************************
*
*/

UWORD rxcf_ChangeItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	RXCFItemConv ItemConv;
	
	if ( ConvItemStrings (RxMsg, &ItemConv, 2, 3, 4) )
	{
		cf_ChangeItem (ItemNode, ItemConv.Contents, ItemConv.Type, ItemConv.SType);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}
/*
		Printf (" Contents 0x%lx %ld Type 0x%lx SType 0x%lx\n",
		ItemConv.Contents, ItemConv.Contents, ItemConv.Type, ItemConv.SType);
*/