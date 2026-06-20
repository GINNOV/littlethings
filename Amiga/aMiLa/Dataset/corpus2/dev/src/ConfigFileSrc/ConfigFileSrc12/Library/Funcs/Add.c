/*
**		$PROJECT: ConfigFile.library
**		$FILE: Add.c
**		$DESCRIPTION: cf_Add#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase	* SysBase;

/****** configfile.library/cf_AddArgument ************************************
*
*   NAME
*        cf_AddArgument -- Adds an argument node to the argument list of a
*                          group node.
*
*   SYNOPSIS
*        cf_AddArgument(GrpNode,ArgNode);
*                       A0      A1
*
*        VOID cf_AddArgument(CFGroup *,CFArgument *);
*
*   FUNCTION
*        This function adds an argument node to the argument list of a
*        group node.
*
*   INPUTS
*        GrpNode - The group node for add to.
*        ArgNode - Pointer to the argument node.
*
*   EXAMPLE
*        CFGroup    * myGrpNode;
*        CFArgument * myArgNode;
*        CFArgument * myNewArgNode;
*
*        ...
*        myNewArgNode = cf_CloneArgument (myArgNode);
*        cf_AddArgument (myGrpNode, myNewArgNode);
*        ...
*
*   SEE ALSO
*        cf_AddGroup(), cf_AddItem()
*
******************************************************************************
*
*/

LibCall VOID cf_AddArgument ( REGA0 iCFGroup * GrpNode , REGA1 iCFArgument * ArgNode )
{
	FuncDe(bug("cf_AddArgument($%08lx,$%08lx)\n{\n", GrpNode, ArgNode));

	if ( ( ArgNode->ExtFlags & CF_EFLG_REMOVED ) &&
			( ArgNode->GrpNode->Header == GrpNode->Header) )
	{
		AddTail ((struct List *) &GrpNode->ArgList, (struct Node *) ArgNode);

		ArgNode->GrpNode			 = GrpNode;
		ArgNode->ExtFlags			&= ~CF_EFLG_REMOVED;
		GrpNode->Header->Flags	|= CF_HFLG_CHANGED;
	}

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_AddGroup ***************************************
*
*   NAME
*        cf_AddGroup -- Adds a group node to the group list of a header.
*
*   SYNOPSIS
*        cf_AddGroup(Header,GrpNode);
*                    A0     A1
*
*        VOID cf_AddGroup(CFHeader *,CFGroup *);
*
*   FUNCTION
*        This function adds a group node to the group list of a header.
*
*   INPUTS
*        Header - Pointer to the Header for add to.
*        GrpNode - Pointer to the group node.
*
*   EXAMPLE
*        CFHeader * myHeader;
*        CFGroup  * myGrpNode;
*        CFGroup  * myNewGrpNode;
*
*        ...
*        myNewGrpNode = cf_CloneGroup (myGrpNode);
*        cf_AddGroup (myHeader, myNewGrpNode);
*        ...
*
*   SEE ALSO
*        cf_AddArgument(), cf_AddItem()
*
******************************************************************************
*
*/

LibCall VOID cf_AddGroup( REGA0 iCFHeader * Header , REGA1 iCFGroup * GrpNode )
{
	FuncDe(bug("cf_AddGroup($%08lx,$%08lx)\n{\n", Header, GrpNode));

	if ( GrpNode->ExtFlags & CF_EFLG_REMOVED && ( Header == GrpNode->Header) )
	{
		AddTail ((struct List *) &Header->GroupList, (struct Node *) GrpNode);

		GrpNode->ExtFlags	&= ~CF_EFLG_REMOVED;
		Header->Flags		|= CF_HFLG_CHANGED;
	}

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_AddItem ****************************************
*
*   NAME
*        cf_AddItem -- Adds an item node to the item list of an argument
*                      node.
*
*   SYNOPSIS
*        cf_AddItem(Argument,ItemNode);
*                   A0       A1
*
*        VOID cf_AddItem(CFArgument *,CFItem *);
*
*   FUNCTION
*        This function adds an item node to the item list of an argument
*        node.
*
*   INPUTS
*        ArgNode - The argument node for add to.
*        ItemNode - Pointer to the item node.
*
*   EXAMPLE
*        CFArgument * myArgNode;
*        CFItem     * myItemNode;
*        CFItem     * myNewItemNode;
*
*        ...
*        myNewItemNode = cf_CloneItem (myItemNode);
*        cf_AddItem (myArgNode, myNewItemNode);
*        ...
*
*   SEE ALSO
*        cf_AddArgument(), cf_AddGroup()
*
******************************************************************************
*
*/

LibCall VOID cf_AddItem ( REGA0 iCFArgument * ArgNode , REGA1 iCFItem * ItemNode )
{
	FuncDe(bug("cf_AddItem($%08lx,$%08lx)\n{\n", ArgNode, ItemNode));

	if ( ArgNode->ExtFlags & CF_EFLG_REMOVED  &&
			( ArgNode->GrpNode->Header == ItemNode->ArgNode->GrpNode->Header) )
	{
		AddTail ((struct List *) &ArgNode->ItemList, (struct Node *) ItemNode);

		ItemNode->ArgNode						 = ArgNode;
		ItemNode->ExtFlags					&= ~CF_EFLG_REMOVED;
		ArgNode->GrpNode->Header->Flags	|= CF_HFLG_CHANGED;
	}

	FuncDe(bug("}\n"));
}
