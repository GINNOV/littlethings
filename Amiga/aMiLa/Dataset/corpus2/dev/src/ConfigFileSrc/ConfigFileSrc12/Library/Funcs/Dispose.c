/*
**		$PROJECT: ConfigFile.library
**		$FILE: Dispose.c
**		$DESCRIPTION: cf_Dispose#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase	* SysBase;

/****** configfile.library/cf_DisposeArgument ********************************
*
*   NAME
*        cf_DisposeArgument -- Remove and dispose an argument node.
*
*   SYNOPSIS
*        cf_DisposeArgument(ArgNode);
*                           A0
*
*        VOID cf_DisposeArgument(CFArgument *);
*
*   FUNCTION
*        This function remove and dispose an argument node. The item list
*        will also be cleared.
*
*   INPUTS
*        ArgNode - The argument node to remove and dispose.
*
*   NOTES
*        If the ArgNode already removed, the function dispose the
*        argument node only.
*
*   SEE ALSO
*        cf_DisposeGroup(), cf_DisposeItem()
*
******************************************************************************
*
*/

LibCall VOID cf_DisposeArgument ( REGA0 iCFArgument * ArgNode )
{
	APTR MemPool;

	FuncDe(bug("cf_DisposeArgument($%08lx)\n{\n", ArgNode));

	MemPool = ArgNode->GrpNode->Header->MemPool;

	if ( !( ArgNode->ExtFlags & CF_EFLG_REMOVED ) )
		Remove ((struct Node *) ArgNode);

	DelArg (MemPool, ArgNode);

	ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;
	FuncDe(bug("}\n"));
}

VOID DelArg ( APTR MemPool , iCFArgument *ArgNode )
{
	cf_ClearItemList (ArgNode);

	if ( ArgNode->ExtFlags & CF_EFLG_EXTERN_STRING )
		DelStr (MemPool, ArgNode->Name);

	MyFreePooled (MemPool, ArgNode, ArgNode->StructSize);
}

/****** configfile.library/cf_DisposeGroup ***********************************
*
*   NAME
*        cf_DisposeGroup -- Remove and dispose a group node.
*
*   SYNOPSIS
*        cf_DisposeGroup(GrpNode);
*                        A0
*
*        VOID cf_DisposeGroup(CFGroup *);
*
*   FUNCTION
*        This function remove and dispose a group node. All argument nodes
*        will also be cleared.
*
*   INPUTS
*        GrpNode - The group node to remove and dispose.
*
*   NOTES
*        If the GrpNode already removed, the function dispose the
*        group node only.
*
*   SEE ALSO
*        cf_DisposeArgument(), cf_DisposeItem()
*
******************************************************************************
*
*/

LibCall VOID cf_DisposeGroup( REGA0 iCFGroup * GrpNode )
{
	APTR MemPool;

	FuncDe(bug("cf_DisposeGroup($%08lx)\n{\n", GrpNode));

	MemPool = GrpNode->Header->MemPool;

	if ( !( GrpNode->ExtFlags & CF_EFLG_REMOVED ) )
		Remove ((struct Node *) GrpNode);

	DelGrp (MemPool, GrpNode);

	GrpNode->Header->Flags |= CF_HFLG_CHANGED;
	FuncDe(bug("}\n"));
}

VOID DelGrp ( APTR MemPool , iCFGroup * GrpNode )
{
	cf_ClearArgList (GrpNode);

	if ( GrpNode->ExtFlags & CF_EFLG_EXTERN_STRING )
		DelStr (MemPool, GrpNode->Name);

	MyFreePooled (MemPool, GrpNode, GrpNode->StructSize);
}

/****** configfile.library/cf_DisposeItem ************************************
*
*   NAME
*        cf_DisposeItem -- Remove and dispose an item node.
*
*   SYNOPSIS
*        cf_DisposeItem(ItemNode);
*                       A0
*
*        VOID cf_DisposeItem(CFItem *);
*
*   FUNCTION
*        This function remove and dispose an item node.
*
*   INPUTS
*        ItemNode - The item node to remove and dispose.
*
*   NOTES
*        If the ItemNode already removed, the function dispose the
*        item node only.
*
*   SEE ALSO
*        cf_DisposeGroup(), cf_DisposeArgument()
*
******************************************************************************
*
*/

LibCall VOID cf_DisposeItem ( REGA0 iCFItem * ItemNode )
{
	APTR MemPool;

	FuncDe(bug("cf_DisposeItem($%08lx)\n{\n", ItemNode));

	MemPool = ItemNode->ArgNode->GrpNode->Header->MemPool;

	if ( !( ItemNode->ExtFlags & CF_EFLG_REMOVED ) )
		Remove ((struct Node *) ItemNode);

	DelItem (MemPool, ItemNode);

	ItemNode->ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;
	FuncDe(bug("}\n"));
}

VOID DelItem ( APTR MemPool , iCFItem * ItemNode )
{
	if ( ItemNode->ExtFlags & CF_EFLG_EXTERN_STRING )
		DelStr (MemPool, ItemNode->Contents.String);

	MyFreePooled (MemPool, ItemNode, ItemNode->StructSize);
}
