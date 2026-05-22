/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Find.c
**		$DESCRIPTION: rxcf_Find#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_FindArgument *******************************
*
*   NAME
*        cf_FindArgument -- Finds a specfic argument node. (case sensitive)
*
*   SYNOPSIS
*        ArgNode = cf_FindArgument(GrpNode,Name)
*
*        ARGNODE/N cf_FindArgument(GRPNODE/N/A,NAME/A)
*
*   FUNCTION
*        This function finds a specfic argument node.
*
*   INPUTS
*        GrpNode - The group node of the argument list to search.
*        Name - Name of the argument node. 
*
*   RESULT
*        ArgNode - The argument node or NULL.
*
*   SEE ALSO
*        cf_FindGroup(), cf_FindItem()
*
******************************************************************************
*
*/

UWORD rxcf_FindArgument ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFArgument * ArgNode;

	if ( ArgNode = cf_FindArgument (GrpNode, RXARG2) )
		*ResStr = CreateNumArgStrP (ArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_FindGroup **********************************
*
*   NAME
*        cf_FindGroup -- Finds a specfic group node. (case sensitive)
*
*   SYNOPSIS
*        GrpNode = cf_FindGroup(Header,Name)
*
*        GRPNODE/N cf_FindGroup(HEADER/N/A,NAME/A)
*
*   FUNCTION
*        This function finds a specfic group node.
*
*   INPUTS
*        Header - A pointer to the Header of the group list to search.
*        Name - Name of the group node.
*
*   RESULT
*        GrpNode - The group node or NULL.
*
*   SEE ALSO
*        cf_FindArgument(), cf_FindItem()
*
******************************************************************************
*
*/

UWORD rxcf_FindGroup ( RX_FUNC_ARGS, CFHeader * Header )
{
	CFGroup	* GrpNode;

	if ( GrpNode = cf_FindGroup (Header, RXARG2) )
		*ResStr = CreateNumArgStrP (GrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_FindItem ***********************************
*
*   NAME
*        cf_FindItem -- Finds a specfic item node.
*
*   SYNOPSIS
*        ItemNode = cf_FindItem(ArgNode,Contents,Type)
*
*        ITEMNODE/A cf_FindItem(ARGNODE/N/A,CONTENTS/A,TYPE/A)
*
*   FUNCTION
*        This function finds a specfic item node.
*
*   INPUTS
*        ArgNode - The argument node of the item list to search.
*        Contents - Contents of the item node.
*        Type - The type of contents (see cf_NewItem()).
*
*   RESULT
*        ItemNode - The item node or NULL.
*
*   SEE ALSO
*        cf_FindArgument(), cf_FindGroup(), cf_NewItem()
*
******************************************************************************
*
*/

UWORD rxcf_FindItem ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	RXCFItemConv  ItemConv;
	CFItem		* ItemNode;

	if ( ConvItemStrings (RxMsg, &ItemConv, 2, 3, 0) )
	{
		if ( ItemNode = cf_FindItem (ArgNode, ItemConv.Contents, ItemConv.Type) )
			*ResStr = CreateNumArgStrP (ItemNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}
