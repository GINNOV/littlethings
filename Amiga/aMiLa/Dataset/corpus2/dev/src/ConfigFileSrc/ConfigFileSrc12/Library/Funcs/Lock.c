/*
**		$PROJECT: ConfigFile.library
**		$FILE: Lock.c
**		$DESCRIPTION: cf_Lock#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_LockArgList ************************************
*
*   NAME
*        cf_LockArgList -- Locks the argument list of a group node for use.
*
*   SYNOPSIS
*        FirstArgNode = cf_LockArgList(GrpNode);
*        D0                            A0
*
*        CFArgument * cf_LockArgList(CFGroup *);
*
*   FUNCTION
*        This function locks the argument list of a group node for use, or
*        NULL if the group node has no argument nodes. The pointer returned
*        by this is NOT an actual ArgNode pointer - you should use one of the
*        other ArgNode calls to get actual pointers to ArgNode structures
*        (such as cf_NextArgNode()), passing the value returned by
*        cf_LockArgList() as the ArgNode value.
*
*   INPUTS
*        GrpNode - The group node for the argument list.
*
*   RESULT
*        FirstArgNode - First argument node of the group node or NULL.
*                       NOT a valid node!
*
*   EXAMPLE
*        CFGroup    * myGrpNode;
*        CFArgument * myArgNode;
*
*        ...
*
*        if ( myArgNode = cf_LockArgList (myGrpNode) )
*        {
*           while ( myArgNode = cf_NextArgument (myArgNode) )
*           {
*              ...
*           }
*
*           cf_UnlockArgList(myGrpNode);
*        }
*        ...
*
*   SEE ALSO
*        cf_LockGrpList(), cf_LockItemList(), cf_UnlockArgList(),
*        cf_NextArgument()
*
******************************************************************************
*
*/

SLibCall iCFArgument * cf_LockArgList ( REGA0 iCFGroup * GrpNode )
{ return (IsMListEmpty (&GrpNode->ArgList) ? NULL :
				(iCFArgument *) &GrpNode->ArgList); }

/****** configfile.library/cf_LockGrpList ************************************
*
*   NAME
*        cf_LockGrpList -- Locks the group list of the header for use.
*
*   SYNOPSIS
*        FirstGrpNode = cf_LockGrpList(Header);
*        D0                            A0
*
*        CFGroup * cf_LockGrpList(CFHeader *);
*
*   FUNCTION
*        This function locks the group list of the header for use, or NULL
*        if the header has no group nodes. The pointer returned by this is
*        NOT an actual GrpNode pointer - you should use one of the other
*        GrpNode calls to get actual pointers to GrpNode structures (such as
*        cf_NextGrpNode()), passing the value returned by cf_LockGrpList()
*        as the GrpNode value.
*
*   INPUTS
*        Header - Pointer to the CFHeader structure.
*
*   RESULT
*        FirstGrpNode - First group node of the header or NULL.
*                       NOT a valid node!
*
*   EXAMPLE
*        CFHeader * myHeader;
*        CFGroup  * myGrpNode;
*
*        ...
*
*        if ( myGrpNode = cf_LockGrpList (myHeader) )
*        {
*           while ( myGrpNode = cf_NextGroup (myGrpNode) )
*           {
*              ...
*           }
*
*           cf_UnlockGrpList(myHeader);
*        }
*        ...
*
*   SEE ALSO
*        cf_LockArgList(), cf_LockItemList(), cf_UnlockGrpList(),
*        cf_NextGroup()
*
******************************************************************************
*
*/

SLibCall iCFGroup * cf_LockGrpList( REGA0 iCFHeader * Header )
{ return (IsMListEmpty (&Header->GroupList) ? NULL :
				(iCFGroup *) &Header->GroupList); }

/****** configfile.library/cf_LockItemList ***********************************
*
*   NAME
*        cf_LockItemList -- Locks the item list of an argument node for use.
*
*   SYNOPSIS
*        FirstItemNode = cf_LockItemList(ArgNode);
*        D0                              A0
*
*        CFItem * cf_LockItemList(CFArgument *);
*
*   FUNCTION
*        This function locks the item list of an argument node for use, or
*        NULL if the argument node has no item nodes. The pointer returned by
*        this is NOT an actual ItemNode pointer - you should use one of the
*        other ItemNode calls to get actual pointers to ItemNode structures
*        (such as cf_NextItemNode()), passing the value returned by
*        cf_LockItemList() as the ItemNode value.
*
*   INPUTS
*        ArgNode - The argument node for item list.
*
*   RESULT
*        FirstItemNode - First item node of the argument node or NULL.
*                        NOT a valid node!
*
*   EXAMPLE
*        CFArgument * myArgNode;
*        CFItem     * myItemNode;
*
*        ...
*
*        if ( myItemNode = cf_LockItemList (myArgNode) )
*        {
*           while ( myItemNode = cf_NextItem (myItemNode) )
*           {
*              ...
*           }
*
*           cf_UnlockItemList(myItemNode);
*        }
*        ...
*
*   SEE ALSO
*        cf_LockArgList(), cf_LockGrpList(), cf_UnlockItemList(),
*        cf_NextItem()
*
******************************************************************************
*
*/

SLibCall iCFItem * cf_LockItemList ( REGA0 iCFArgument * ArgNode )
{ return (IsMListEmpty (&ArgNode->ItemList) ? NULL :
				(iCFItem *) &ArgNode->ItemList); }
