/*
**		$PROJECT: ConfigFile.library
**		$FILE: Next.c
**		$DESCRIPTION: cf_Next#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_NextArgument ***********************************
*
*   NAME
*        cf_NextArgument -- Returns the next argument node.
*
*   SYNOPSIS
*        NextArgNode = cf_NextArgument(ArgNode);
*        D0                            A0
*
*        CFArgument * cf_NextArgument(CFArgument *);
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

SLibCall iCFArgument * cf_NextArgument ( REGA0 iCFArgument * ArgNode )
{ return (ArgNode->NextArg->NextArg ? ArgNode->NextArg : NULL); }

/****** configfile.library/cf_NextGroup **************************************
*
*   NAME
*        cf_NextGroup -- Returns the next group node.
*
*   SYNOPSIS
*        NextGrpNode = cf_NextGroup(GrpNode);
*        D0                         A0
*
*        CFGroup * cf_NextGroup(CFGroup *);
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

SLibCall iCFGroup * cf_NextGroup( REGA0 iCFGroup * GrpNode )
{ return (GrpNode->NextGrp->NextGrp ? GrpNode->NextGrp : NULL); }

/****** configfile.library/cf_NextItem ***************************************
*
*   NAME
*        cf_NextItem -- Returns the next item node.
*
*   SYNOPSIS
*        NextItemNode = cf_NextItem(ItemNode);
*        D0                         A0
*
*        CFItem * cf_NextItem(CFArgument *);
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

SLibCall iCFItem * cf_NextItem ( REGA0 iCFItem * ItemNode )
{ return (ItemNode->NextItem->NextItem ? ItemNode->NextItem : NULL); }
