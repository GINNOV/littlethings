/*
**		$PROJECT: ConfigFile.library
**		$FILE: Change.c
**		$DESCRIPTION: cf_Change#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_ChangeArgument *********************************
*
*   NAME
*        cf_ChangeArgument -- Changes the name of an argument node.
*
*   SYNOPSIS
*        cf_ChangeArgument(ArgNode,Name);
*                          A0      A1
*
*        VOID cf_ChangeArgument(CFArgument *,STRPTR);
*
*   FUNCTION
*        This function changes the name of an argument node.
*
*   INPUTS
*        ArgNode - The argument node.
*        Name - The new name for the argument node.
*
*   SEE ALSO
*        cf_ChangeGroup(), cf_ChangeItem()
*
******************************************************************************
*
*/

LibCall VOID cf_ChangeArgument ( REGA0 iCFArgument * ArgNode , REGA1 STRPTR Name )
{
	APTR	MemPool;

	FuncDe(bug("cf_ChangeArgument($%08lx,\"%ls\")\n{\n", ArgNode, Name));

	MemPool = ArgNode->GrpNode->Header->MemPool;

	if ( ArgNode->ExtFlags & CF_EFLG_EXTERN_STRING )
		DelStr (MemPool, ArgNode->Name);
	else
		ArgNode->ExtFlags	|= CF_EFLG_EXTERN_STRING;
	
	ArgNode->Name = DupStr (MemPool, Name);

	ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_ChangeGroup ************************************
*
*   NAME
*        cf_ChangeGroup -- Changes the name of a groupnode.
*
*   SYNOPSIS
*        cf_ChangeGroup(GrpNode,Name);
*                       A0      A1
*
*        VOID cf_ChangeGroup(CFGroup *,STRPTR);
*
*   FUNCTION
*        This function changes the name of a group node.
*
*   INPUTS
*        GrpNode - The group node for add to.
*        Name - The new name for the group node.
*
*   SEE ALSO
*        cf_ChangeArgument(), cf_ChangeItem()
*
******************************************************************************
*
*/

LibCall VOID cf_ChangeGroup ( REGA0 iCFGroup * GrpNode , REGA1 STRPTR Name )
{
	APTR	MemPool;

	FuncDe(bug("cf_ChangeGroup($%08lx,\"%ls\")\n{\n", GrpNode, Name));

	MemPool = GrpNode->Header->MemPool;

	if ( GrpNode->ExtFlags & CF_EFLG_EXTERN_STRING )
		DelStr (MemPool, GrpNode->Name);
	else
		GrpNode->ExtFlags	|= CF_EFLG_EXTERN_STRING;
	
	GrpNode->Name = DupStr (MemPool, Name);

	GrpNode->Header->Flags |= CF_HFLG_CHANGED;

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_ChangeItem *************************************
*
*   NAME
*        cf_ChangeItem -- Changes the contents of an item node.
*
*   SYNOPSIS
*        cf_ChangeItem(ItemNode,Contents,Type,SpecialType);
*                      A0       D0       D1   D2
*
*        VOID cf_ChangeItem(CFItem *,LONG,ULONG,ULONG);
*
*   FUNCTION
*        This function changes the contents of an item node.
*
*   INPUTS
*        ItemNode - The item node for the changes.
*        Contents - The new contents.
*        Type - The new type (see cf_NewItem()).
*        SpecialType - The new special type (see cf_NewItem()).
*
*   EXAMPLE
*        CFArgument * myArgNode;
*        CFItem     * myItemNode;
*
*        ...
*        myItemNode = cf_NewItem (myArgNode, 1234567, CF_ITYP_NUMBER, 0);
*        cf_ChangeItem (myItemNode, TRUE, CF_ITYP_BOOL, CF_STYP_BOOL_OFF);
*        ...
*
*        In the CF file:
*
*        [ExampleGroup]
*        ...
*        ExampleArg=ON
*        ...
*
*   SEE ALSO
*        cf_ChangeArgument(), cf_ChangeGroup(), cf_NewItem()
*
******************************************************************************
*
*/

LibCall VOID cf_ChangeItem ( REGA0 iCFItem * ItemNode ,
			REGD0 LONG Contents , REGD1 ULONG Type , REGD2 ULONG SpecialType )
{
	APTR	MemPool;

	FuncDe(bug("cf_ChangeItem($%08lx,[$%08lx,%ld],%ld,%ld)\n{\n", ItemNode,
			Contents, Contents, Type, SpecialType));

	MemPool = ItemNode->ArgNode->GrpNode->Header->MemPool;

	ItemNode->ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;

	if ( ItemNode->ExtFlags & CF_EFLG_EXTERN_STRING )
	{
		DelStr (MemPool, ItemNode->Contents.String);
		ItemNode->ExtFlags &= ~CF_EFLG_EXTERN_STRING;
	}

	ItemNode->Type				= Type;
	ItemNode->SpecialType	= SpecialType ? SpecialType : CF_STYP_NUM_DEC;

	if ( Type == CF_ITYP_STRING )
	{
		ItemNode->Contents.String = DupStr (MemPool, (STRPTR) Contents);
		ItemNode->ExtFlags |= CF_EFLG_EXTERN_STRING;
	}
	else if ( Type == CF_ITYP_NUMBER )
		ItemNode->Contents.Number	= Contents;
	else if ( Type == CF_ITYP_BOOL )
		ItemNode->Contents.Bool		= Contents ? TRUE : FALSE;

	FuncDe(bug("}\n"));
}
