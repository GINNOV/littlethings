/*
**		$PROJECT: ConfigFile.library
**		$FILE: Get.c
**		$DESCRIPTION: cf_Get#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_GetItem ****************************************
*
*   NAME
*        cf_GetItem -- Get the contents of an item node or the default.
*
*   SYNOPSIS
*        Contents = cf_GetItem(ItemNode,Type,Default);
*        D0                    A0       D0   D1
*
*        LONG cf_GetItem(CFItem *,ULONG,LONG);
*
*   FUNCTION
*        This function gets the contents of an item node. If Type not equal
*        with the type of the item node the functions return the default.
*
*   INPUTS
*        ItemNode - The item node.
*        Type - Contents type (see cf_NewItem()).
*        Default - Default contents.
*
*   RESULT
*        Contents - The contents of the item node or the default.
*
*   SEE ALSO
*        cf_GetItemNum()
*
******************************************************************************
*
*/

SLibCall LONG cf_GetItem ( REGA0 iCFItem * ItemNode , REGD0 ULONG Type , REGD1 LONG Default )
{
	FuncDe(bug("cf_GetItem($%08lx,%ld,[$%08lx,%ld])\n{\n", ItemNode, Type,
			Default, Default));

	FuncDe(bug("   return($%08lx)\n}\n", ( ItemNode->Type == Type )
			? ItemNode->Contents.Number : Default ));

	return (( ItemNode->Type == Type ) ? ItemNode->Contents.Number : Default);
}

/****** configfile.library/cf_GetItemNum *************************************
*
*   NAME
*        cf_GetItemNum -- Get the contents of an item node or the default.
*
*   SYNOPSIS
*        Contents = cf_GetItemNum(ArgNode,Position,Type,Default);
*        D0                       A0      D0       D1   D2
*
*        LONG cf_GetItemNum(CFArgument *,ULONG,ULONG,LONG);
*
*   FUNCTION
*        This function gets the contents of an item node from the specific
*        position. If Type not equal with the type of the item node the
*        function returns the default.
*
*   INPUTS
*        ArgNode - The argument node.
*        Position - Position of the item node (from 1 to X).
*        Type - Contents type (see cf_NewItem()).
*        Default - Default contents.
*
*   RESULT
*        Contents - The contents of the item node or the default.
*
*   SEE ALSO
*        cf_GetItem()
*
******************************************************************************
*
*/

SLibCall LONG cf_GetItemNum ( REGA0 iCFArgument * ArgNode ,
				REGD0 ULONG Position , REGD1 ULONG Type , REGD2 LONG Default )
{
	iCFItem * ItemNode;
	ULONG ActualPosition=0;

	FuncDe(bug("cf_GetItemNum($%08lx,%ld,%ld,[$%08lx,%ld])\n{\n", ArgNode, Position,
			Type, Default, Default));

	if ( ItemNode = cf_LockItemList (ArgNode) )
	{
		while ( ItemNode = cf_NextItem (ItemNode) )
		{
			ActualPosition++;
			if ( ActualPosition == Position )
			{
				if ( ItemNode->Type == Type ) return (ItemNode->Contents.Number);
				else
				{
					FuncDe(bug("   return($%08lx)\n}\n", Default));
					return (Default);
				}
			}
		}
		
		cf_UnlockItemList (ArgNode);
	}

	FuncDe(bug("   return($%08lx)\n}\n", Default));
	return (Default);
}

/****** configfile.library/cf_GetItemType ************************************
*
*   NAME
*        cf_GetItemType -- Get the type of an item node. (V2)
*
*   SYNOPSIS
*        Type = cf_GetItemType(ItemNode);
*        D0                    A0
*
*        UBYTE cf_GetItemType(CFItem *);
*
*   FUNCTION
*        This function returns the contents type of an item node.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        Type - Contents type (see cf_NewItem()).
*
*   SEE ALSO
*        cf_GetItemSType(), cf_NewItem()
*
******************************************************************************
*
*/

SLibCall UBYTE cf_GetItemType ( REGA0 iCFItem * ItemNode )
{
	FuncDe(bug("cf_GetItemType($%08lx)\n{\n   return(%ld)\n}\n",
			ItemNode, ItemNode->Type));

	return (ItemNode->Type);
}

/****** configfile.library/cf_GetItemSType ***********************************
*
*   NAME
*        cf_GetItemSType -- Get the special type of an item node. (V2)
*
*   SYNOPSIS
*        SpecialType = cf_GetItemSType(ItemNode);
*        D0                            A0
*
*        UBYTE cf_GetItemSType(CFItem *);
*
*   FUNCTION
*        This function returns the special type of an item node.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        SpecialType - Special type (see cf_NewItem()).
*
*   SEE ALSO
*        cf_GetItemType(), cf_NewItem()
*
******************************************************************************
*
*/

SLibCall UBYTE cf_GetItemSType ( REGA0 iCFItem * ItemNode )
{
	FuncDe(bug("cf_GetItemSType($%08lx)\n{\n   return(%ld)\n}\n",
			ItemNode, ItemNode->SpecialType));

	return (ItemNode->SpecialType);
}

/****** configfile.library/cf_GetItemOnly ************************************
*
*   NAME
*        cf_GetItemOnly -- Get the contents of an item node. (V2)
*
*   SYNOPSIS
*        Contents = cf_GetItemOnly(ItemNode);
*        D0                        A0
*
*        LONG cf_GetItemOnly(CFItem *);
*
*   FUNCTION
*        This function gets the contents of an item node.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        Contents - The Contents of the item node.
*
*   EXAMPLE
*        CFItem  * myItemNode;
*        LONG      Contents;
*
*        ...
*        Contents = cf_GetItemOnly (myItemNode);
*
*        printf ("The contents of the item node is ");
*
*        if ( cf_GetItemType (myItemNode) == CF_ITYP_STRING )
*           printf ("'%s'\n", Contents);
*        else
*           printf ("%ld\n", Contents);
*        ...
*
*   SEE ALSO
*        cf_GetItemNum(), cf_GetItem()
*
******************************************************************************
*
*/

SLibCall LONG cf_GetItemOnly ( REGA0 iCFItem * ItemNode )
{
	FuncDe(bug("cf_GetItemOnly($%08lx)\n{\n   return([$%08lx,%ld])\n}\n",
			ItemNode, ItemNode->Contents.Number, ItemNode->Contents.Number));

	return (ItemNode->Contents.Number);
}
