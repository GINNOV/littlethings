/*
**		$PROJECT: ConfigFile.library
**		$FILE: Clone.c
**		$DESCRIPTION: cf_Clone#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase	* SysBase;

/****** configfile.library/cf_CloneArgument **********************************
*
*   NAME
*        cf_CloneArgument -- Copy an argument node with all item nodes.
*
*   SYNOPSIS
*        NewArgNode = cf_CloneArgument(ArgNode);
*        D0                            A0
*
*        CFArgument * cf_CloneArgument(CFArgument *);
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
*        CFGroup    * myGrpNode;
*        CFArgument * myArgNode;
*
*        ...
*        myArgNode = cf_NewArgument (myGrpNode, "ExampleArgument");
*        cf_AddArgument (myGrpNode, cf_CloneArgument (myArgNode));
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

LibCall iCFArgument * cf_CloneArgument ( REGA0 iCFArgument * ArgNode )
{
	iCFArgument	*NewArgNode;
	iCFItem		*ItemNode;

	FuncDe(bug("cf_CloneArgument($%08lx)\n{\n", ArgNode));

	ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;

	if ( NewArgNode = NewArg (ArgNode->GrpNode, ArgNode->Name, *(ArgNode->Name - 1)) )
	{
		Remove ((struct Node *) NewArgNode);
		NewArgNode->ExtFlags	|= CF_EFLG_REMOVED;

		if ( ItemNode = cf_LockItemList (ArgNode) )
		{
			while ( ItemNode = cf_NextItem (ItemNode) )
				AddTail ((struct List *) &NewArgNode->ItemList,
					(struct Node *) cf_CloneItem (ItemNode));

			cf_UnlockItemList (ArgNode);
		}
		
		FuncDe(bug("   return($%08lx)\n}\n", NewArgNode));
		return (NewArgNode);
	}
	
	FuncDe(bug("   return(NULL)\n}\n"));
	return (NULL);
}

/****** configfile.library/cf_CloneGroup *************************************
*
*   NAME
*        cf_CloneGroup -- Copy a group node with all argument and item nodes.
*
*   SYNOPSIS
*        NewGrpNode = cf_CloneGroup(GrpNode);
*        D0                         A0
*
*        CFGroup * cf_CloneGroup(CFGroup *);
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
*        CFHeader * myHeader;
*        CFGroup  * myGrpNode;
*
*        ...
*        myGrpNode = cf_NewGroup (myHeader, "ExampleGroup");
*        cf_AddGroup (myHeader, cf_CloneGroup (myGrpNode));
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

LibCall iCFGroup * cf_CloneGroup ( REGA0 iCFGroup * GrpNode )
{
	iCFGroup		*NewGrpNode;
	iCFArgument	*ArgNode;

	FuncDe(bug("cf_CloneGroup($%08lx)\n{\n", GrpNode));

	GrpNode->Header->Flags |= CF_HFLG_CHANGED;

	if ( NewGrpNode = NewGrp (GrpNode->Header, GrpNode->Name, *(GrpNode->Name - 1)) )
	{
		Remove ((struct Node *) NewGrpNode);
		NewGrpNode->ExtFlags	|= CF_EFLG_REMOVED;

		if ( ArgNode = cf_LockArgList (GrpNode) )
		{
			while ( ArgNode = cf_NextArgument (ArgNode) )
				AddTail ((struct List *) &NewGrpNode->ArgList,
					(struct Node *) cf_CloneArgument (ArgNode));
			
			cf_UnlockArgList (GrpNode);
		}

		FuncDe(bug("   return($%08lx)\n}\n", NewGrpNode));
		return (NewGrpNode);
	}

	FuncDe(bug("   return(NULL)\n}\n"));
	return (NULL);
}

/****** configfile.library/cf_CloneItem **************************************
*
*   NAME
*        cf_CloneItem -- Copy an item node.
*
*   SYNOPSIS
*        NewItemNode = cf_CloneItem(ItemNode);
*        D0                         A0
*
*        CFItem * cf_CloneItem(CFItem *);
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
*        CFArgument * myArgNode;
*        CFItem     * myItemNode;
*
*        ...
*        myItemNode = cf_NewItem (myArgNode, (LONG) "ExampleItem", 
*                        CF_ITYP_STRING, NULL);
*        cf_AddItem (myArgNode, cf_CloneItem (myItemNode));
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

SLibCall iCFItem * cf_CloneItem( REGA0 iCFItem * ItemNode )
{
	iCFItem	*NewItemNode;

	FuncDe(bug("cf_CloneItem($%08lx)\n{\n", ItemNode));

	NewItemNode = cf_NewItem (ItemNode->ArgNode, ItemNode->Contents.Number,
			ItemNode->Type, ItemNode->SpecialType);

	Remove ((struct Node *) NewItemNode);
	NewItemNode->ExtFlags	|= CF_EFLG_REMOVED;

	FuncDe(bug("   return($%08lx)\n}\n", NewItemNode));
	return (NewItemNode);
}
