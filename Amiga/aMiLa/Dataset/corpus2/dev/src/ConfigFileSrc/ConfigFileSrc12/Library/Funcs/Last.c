/*
**		$PROJECT: ConfigFile.library
**		$FILE: Last.c
**		$DESCRIPTION: cf_Last#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_LastArgument ***********************************
*
*   NAME
*        cf_LastArgument -- Returns the previous argument node.
*
*   SYNOPSIS
*        LastArgNode = cf_LastArgument(ArgNode);
*        D0                            A0
*
*        CFArgument * cf_LastArgument(CFArgument *);
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

SLibCall iCFArgument * cf_LastArgument ( REGA0 iCFArgument * ArgNode )
{ return (ArgNode->LastArg->LastArg ? ArgNode->LastArg : NULL); }

/****** configfile.library/cf_LastGroup **************************************
*
*   NAME
*        cf_LastGroup -- Returns the previous group node.
*
*   SYNOPSIS
*        LastGrpNode = cf_LastGroup(GrpNode);
*        D0                         A0
*
*        CFGroup * cf_LastGroup(CFGroup *);
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

SLibCall iCFGroup * cf_LastGroup ( REGA0 iCFGroup * GrpNode )
{ return (GrpNode->LastGrp->LastGrp ? GrpNode->LastGrp : NULL); }

/****** configfile.library/cf_LastItem ***************************************
*
*   NAME
*        cf_LastItem -- Returns the previous item node.
*
*   SYNOPSIS
*        LastItemNode = cf_LastItem(ItemNode);
*        D0                         A0
*
*        CFItem * cf_LastItem(CFArgument *);
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

SLibCall iCFItem * cf_LastItem ( REGA0 iCFItem * ItemNode )
{ return (ItemNode->LastItem->LastItem ? ItemNode->LastItem : NULL); }
