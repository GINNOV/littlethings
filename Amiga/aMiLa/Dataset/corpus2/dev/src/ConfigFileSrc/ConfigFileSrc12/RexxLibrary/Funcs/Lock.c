/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Lock.c
**		$DESCRIPTION: rxcf_Lock#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_LockArgList ********************************
*
*   NAME
*        cf_LockArgList -- Locks the argument list of a group node for use.
*
*   SYNOPSIS
*        FirstArgNode = cf_LockArgList(GrpNode)
*
*        FIRSTARGNODE/N cf_LockArgList(GRPNODE/N/A)
*
*   FUNCTION
*        This function locks the argument list of a group node for use, or
*        NULL if the group node has no argument nodes. The pointer returned
*        by this is NOT an actual ArgNode pointer - you should use one of the
*        other ArgNode calls to get actual pointers to ArgNode structures
*        (such as cf_NextArgument()), passing the value returned by
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
*        ...
*        myArgNode = cf_LockArgList(myGrpNode)
*        If myArgNode ~= 0 Then Do
*          Do While myArgNode ~= 0
*            myArgNode = cf_NextArgument(myArgNode)
*            ...
*          End
*          cf_UnlockArgList(myGrpNode)
*        End
*        ...
*
*   SEE ALSO
*        cf_LockGrpList(), cf_LockItemList(), cf_UnlockArgList(),
*        cf_NextArgument()
*
******************************************************************************
*
*/

UWORD rxcf_LockArgList ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFArgument	* FirstArgNode;

	if ( FirstArgNode = cf_LockArgList (GrpNode) )
		*ResStr = CreateNumArgStrP (FirstArgNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_LockGrpList ********************************
*
*   NAME
*        cf_LockGrpList -- Locks the group list of the header for use.
*
*   SYNOPSIS
*        FirstGrpNode = cf_LockGrpList(Header)
*
*        FIRSTGRPNODE/N cf_LockGrpList(HEADER/N/A)
*
*   FUNCTION
*        This function locks the group list of the header for use, or NULL
*        if the header has no group nodes. The pointer returned by this is
*        NOT an actual GrpNode pointer - you should use one of the other
*        GrpNode calls to get actual pointers to GrpNode structures (such as
*        cf_NextGroup()), passing the value returned by cf_LockGrpList()
*        as the GrpNode value.
*
*   INPUTS
*        Header - Pointer to the Header.
*
*   RESULT
*        FirstGrpNode - First group node of the header or NULL.
*                       NOT a valid node!
*
*   EXAMPLE
*        ...
*        myGrpNode = cf_LockGrpList(myHeader)
*        If myGrpNode ~= 0 Then Do
*          Do While myGrpNode ~= 0
*            myGrpNode = cf_NextGroup(myGrpNode)
*            ...
*          End
*          cf_UnlockGrpList(myHeader)
*        End
*        ...
*
*   SEE ALSO
*        cf_LockArgList(), cf_LockItemList(), cf_UnlockGrpList(),
*        cf_NextGroup()
*
******************************************************************************
*
*/

UWORD rxcf_LockGrpList ( RX_FUNC_ARGS, CFHeader * Header )
{
	CFGroup	* FirstGrpNode;

	if ( FirstGrpNode = cf_LockGrpList (Header) )
		*ResStr = CreateNumArgStrP (FirstGrpNode);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_LockItemList *******************************
*
*   NAME
*        cf_LockItemList -- Locks the item list of an argument node for use.
*
*   SYNOPSIS
*        FirstItemNode = cf_LockItemList(ArgNode)
*
*        FIRSTITEMNODE/N cf_LockItemList(ARGNODE/N/A)
*
*   FUNCTION
*        This function locks the item list of an argument node for use, or
*        NULL if the argument node has no item nodes. The pointer returned by
*        this is NOT an actual ItemNode pointer - you should use one of the
*        other ItemNode calls to get actual pointers to ItemNode structures
*        (such as cf_NextItem()), passing the value returned by
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
*        ...
*        myItemNode = cf_LockItemList(myArgNode)
*        If myItemNode ~= 0 Then Do
*          Do While myItemNode ~= 0
*            myItemNode = cf_NextItem(myItemNode)
*            ...
*          End
*          cf_UnlockItemList(myArgNode)
*        End
*        ...
*
*   SEE ALSO
*        cf_LockArgList(), cf_LockGrpList(), cf_UnlockItemList(),
*        cf_NextItem()
*
******************************************************************************
*
*/

UWORD rxcf_LockItemList ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	CFItem	* FirstItemNode;

	if ( FirstItemNode = cf_LockItemList (ArgNode) )
		*ResStr = CreateNumArgStrP (FirstItemNode);
	return (RC_OK);
}
