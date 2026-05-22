/*
**		$PROJECT: ConfigFile.library
**		$FILE: GetOf.c
**		$DESCRIPTION: cf_Get#?Of#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_GetHdrOfGrp ************************************
*
*   NAME
*        cf_GetHdrOfGrp -- Get the parent node of a group node. (V2)
*
*   SYNOPSIS
*        Header = cf_GetHdrOfArg(GrpNode);
*        D0                      A0
*
*        CFHeader * cf_GetHdrOfGrp(CFGroup *);
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

SLibCall iCFHeader * cf_GetHdrOfGrp ( REGA0 iCFGroup * GrpNode )
{
	FuncDe(bug("cf_GetHdrOfGrp($%08lx)\n{\n   return($%08lx)\n}\n",
			GrpNode, GrpNode->Header));

	return (GrpNode->Header);
}

/****** configfile.library/cf_GetGrpOfArg ************************************
*
*   NAME
*        cf_GetGrpOfArg -- Get the parent node of an argument node. (V2)
*
*   SYNOPSIS
*        GrpNode = cf_GetGrpOfArg(ArgNode);
*        D0                       A0
*
*        CFGroup * cf_GetGrpOfArg(CFArgument *);
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

SLibCall struct iCFGroup * cf_GetGrpOfArg ( REGA0 struct iCFArgument *ArgNode )
{
	FuncDe(bug("cf_GetGrpOfArg($%08lx)\n{\n   return($%08lx)\n}\n",
			ArgNode, ArgNode->GrpNode));

	return (ArgNode->GrpNode);
}

/****** configfile.library/cf_GetArgOfItem ***********************************
*
*   NAME
*        cf_GetArgOfItem -- Get the parent node of an item node. (V2)
*
*   SYNOPSIS
*        ArgNode = cf_GetArgOfItem(ItemNode);
*        D0                        A0
*
*        CFArgument * cf_GetArgOfItem(CFItem *);
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

SLibCall iCFArgument * cf_GetArgOfItem ( REGA0 iCFItem * ItemNode )
{
	FuncDe(bug("cf_GetArgOfItem($%08lx)\n{\n   return($%08lx)\n}\n",
			ItemNode, ItemNode->ArgNode));

	return (ItemNode->ArgNode);
}
