/*
**		$PROJECT: ConfigFile.library
**		$FILE: Clear.c
**		$DESCRIPTION: cf_Clear#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase	* SysBase;

/****** configfile.library/cf_ClearArgList ***********************************
*
*   NAME
*        cf_ClearArgList -- Clears all argument and item nodes of a
*                           group node.
*
*   SYNOPSIS
*        cf_ClearArgList(GrpNode);
*                        A0
*
*        VOID cf_ClearArgList(CFGroup *);
*
*   FUNCTION
*        This function clears all argument and item nodes of a group node.
*
*   INPUTS
*        GrpNode - The group node for the argument list.
*
*   SEE ALSO
*        cf_ClearGrpList(), cf_ClearItemList()
*
******************************************************************************
*
*/

LibCall VOID cf_ClearArgList ( REGA0 iCFGroup * GrpNode )
{
	iCFArgument	*ArgNode;
	iCFArgument	*NextArgNode;
	APTR			 MemPool;

	FuncDe(bug("cf_ClearArgList($%08lx)\n{\n", GrpNode));

	MemPool = GrpNode->Header->MemPool;

	if ( ArgNode = cf_LockArgList (GrpNode) )
	{
		GrpNode->Header->Flags |= CF_HFLG_CHANGED;
		
		ArgNode = (iCFArgument *) (GrpNode->ArgList.mlh_Head);

		while ( NextArgNode = (iCFArgument *) (ArgNode->NextArg) )
		{
			DelArg (MemPool, ArgNode);

			ArgNode = NextArgNode;
		}

		cf_UnlockArgList (GrpNode);
	}

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_ClearGrpList ***********************************
*
*   NAME
*        cf_ClearGrpList -- Clears all group/argument/item nodes.
*
*   SYNOPSIS
*        cf_ClearGrpList(Header);
*                        A0
*
*        VOID cf_ClearGrpList(CFHeader *);
*
*   FUNCTION
*        This function clears all group/argument/item nodes.
*
*   INPUTS
*        Header - Pointer to the CFHeader structure.
*
*   SEE ALSO
*        cf_ClearArgList(), cf_ClearItemList()
*
******************************************************************************
*
*/

LibCall VOID cf_ClearGrpList ( REGA0 iCFHeader * Header )
{
	iCFGroup	*GrpNode;
	iCFGroup	*NextGrpNode;
	APTR		 MemPool;

	FuncDe(bug("cf_ClearGrpList($%08lx)\n{\n", Header));

	MemPool = Header->MemPool;

	if ( GrpNode = cf_LockGrpList (Header) )
	{
		Header->Flags |= CF_HFLG_CHANGED;

		GrpNode = (iCFGroup *) (Header->GroupList.mlh_Head);

		while ( NextGrpNode = (iCFGroup *) (GrpNode->NextGrp) )
		{
			DelGrp (MemPool, GrpNode);

			GrpNode = NextGrpNode;
		}

		cf_UnlockGrpList (Header);
	}

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_ClearItemList **********************************
*
*   NAME
*        cf_ClearItemList -- Clears all item nodes of an argument node.
*
*   SYNOPSIS
*        cf_ClearItemList(ArgNode);
*                         A0
*
*        VOID cf_ClearItemList(CFArgument *);
*
*   FUNCTION
*        This function clears all item nodes of an argument node.
*
*   INPUTS
*        ArgNode - The argument node for item list.
*
*   EXAMPLE
*        CFGroup    * myGrpNode;
*        CFArgument * myArgNode;
*
*        ...
*        myArgNode = cf_NewArgument (myGrpNode, "ExampleArgument");
*        myItemNode = cf_NewString (myArgNode, "ExampleString");
*        myItemNode = cf_NewNum (myArgNode, 463256);
*        cf_ClearItemList (myArgNode);
*        ...
*
*        In the CF file:
*
*        [ExampleGroup]
*        ...
*        ExampleArgument=
*        ...
*
*   SEE ALSO
*        cf_ClearArgList(), cf_ClearGrpList()
*
******************************************************************************
*
*/

LibCall VOID cf_ClearItemList ( REGA0 iCFArgument * ArgNode )
{
	iCFItem	*ItemNode;
	iCFItem	*NextItemNode;
	APTR		 MemPool;

	FuncDe(bug("cf_ClearItemList($%08lx)\n{\n", ArgNode));

	MemPool = ArgNode->GrpNode->Header->MemPool;

	if ( ItemNode = cf_LockItemList (ArgNode) )
	{
		ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;

		ItemNode = (iCFItem *) (ArgNode->ItemList.mlh_Head);

		while ( NextItemNode = (iCFItem *) (ItemNode->NextItem) )
		{
			DelItem (MemPool, ItemNode);

			ItemNode = NextItemNode;
		}

		cf_UnlockItemList (ArgNode);
	}

	FuncDe(bug("}\n"));
}
