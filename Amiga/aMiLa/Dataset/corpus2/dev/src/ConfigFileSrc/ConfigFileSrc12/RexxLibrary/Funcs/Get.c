/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Get.c
**		$DESCRIPTION: rxcf_Get#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library		*DOSBase;
IMPORT struct Library		*RexxSysBase;
IMPORT struct Library		*CFBase;

/****** rexxconfigfile.library/cf_GetItem ************************************
*
*   NAME
*        cf_GetItem -- Get the contents of an item node or the default.
*
*   SYNOPSIS
*        Contents = cf_GetItem(ItemNode,Type,Default)
*
*        CONTENTS cf_GetItem(ITEMNODE/N/A,TYPE/A,STYPE/A)
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

UWORD rxcf_GetItem ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	RXCFItemConv ItemConv;
	ULONG			 Contents;

	if ( IsValidArg (RxMsg, 3) )
	{
		if ( ConvItemStrings (RxMsg, &ItemConv, 0, 2, 0) )
		{
			if ( Contents = cf_GetItem (ItemNode, ItemConv.Type, (LONG)RXARG3) )
			{
				if ( ItemConv.Type == CF_ITYP_STRING )
					*ResStr = CreateArgstring ((STRPTR)Contents, *((STRPTR)Contents-1));
				else
					*ResStr = CreateNumArgStr (Contents);
			}
			return (RC_OK);
		}
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_GetItemNum *********************************
*
*   NAME
*        cf_GetItemNum -- Get the contents of an item node or the default.
*
*   SYNOPSIS
*        Contents = cf_GetItemNum(ArgNode,Position,Type,Default)
*
*        CONTENTS cf_GetItemNum(ARGNODE/N/A,POSITION/A,TYPE/A,STYPE/A)
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

UWORD rxcf_GetItemNum ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	RXCFItemConv ItemConv;
	ULONG			 Contents, Position;

	if ( IsValidArg (RxMsg, 4) )
	{
		if ( IsValidArg (RxMsg, 2) && ( StrToLong(RXARG2, (LONG *)&Position) != -1 ) )
		{
			if ( ConvItemStrings (RxMsg, &ItemConv, 0, 2, 0) )
			{
				if ( Contents = cf_GetItemNum (ArgNode, Position, ItemConv.Type, (LONG)RXARG4) )
				{
					if ( ItemConv.Type == CF_ITYP_STRING )
						*ResStr = CreateArgstring ((STRPTR)Contents, *((STRPTR)Contents-1));
					else
						*ResStr = CreateNumArgStr (Contents);
				}
				return (RC_OK);
			}
		}
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_GetItemType ********************************
*
*   NAME
*        cf_GetItemType -- Get the type of an item node.
*
*   SYNOPSIS
*        Type = cf_GetItemType(ItemNode)
*
*        TYPE cf_GetItemType(ITEMNODE/N/A)
*
*   FUNCTION
*        This function returns the contents type of an item node.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        Type - Contents type (see cf_NewItem()) or ITYP_UNKOWN for
*               an unkown specialtype.
*
*   SEE ALSO
*        cf_GetItemSType(), cf_NewItem()
*
******************************************************************************
*
*/

UWORD rxcf_GetItemType ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	RXCFStrConv	TypeConv;

	TypeToStr (&TypeConv, cf_GetItemType (ItemNode));

	*ResStr = CreateArgstring (TypeConv.Str, TypeConv.Len);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetItemSType *******************************
*
*   NAME
*        cf_GetItemSType -- Get the special type of an item node.
*
*   SYNOPSIS
*        SpecialType = cf_GetItemSType(ItemNode)
*
*        STYPE cf_GetItemSType(ITEMNODE/N/A)
*
*   FUNCTION
*        This function returns the special type of an item node.
*
*   INPUTS
*        ItemNode - The item node.
*
*   RESULT
*        SpecialType - Special type (see cf_NewItem()) or STYP_UNKOWN for
*                      an unkown specialtype.
*
*   SEE ALSO
*        cf_GetItemType(), cf_NewItem()
*
******************************************************************************
*
*/

UWORD rxcf_GetItemSType ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	RXCFStrConv	STypeConv;
	UBYTE	Type  = cf_GetItemType  (ItemNode),
			SType = cf_GetItemSType (ItemNode);

	if ( Type == CF_ITYP_NUMBER )
		STypeNumToStr  (&STypeConv, SType);
	else // if ( Type == CF_ITYP_BOOL )
		STypeBoolToStr (&STypeConv, SType);

	*ResStr = CreateArgstring (STypeConv.Str, STypeConv.Len);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetItemOnly ********************************
*
*   NAME
*        cf_GetItemOnly -- Get the contents of an item node.
*
*   SYNOPSIS
*        Contents = cf_GetItemOnly(ItemNode)
*
*        CONTENTS cf_GetItemOnly(ITEMNODE/N/A)
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
*        ...
*        Contents = cf_GetItemOnly(myItemNode)
*        Type = cf_GetItemType(myItemNode)
*
*        SAY 'The contents of the item node is' Contents
*        ...
*
*   SEE ALSO
*        cf_GetItemNum(), cf_GetItem()
*
******************************************************************************
*
*/

UWORD rxcf_GetItemOnly ( RX_FUNC_ARGS, CFItem * ItemNode )
{
	ULONG Contents	= cf_GetItemOnly (ItemNode);
	UBYTE	Type		= cf_GetItemType (ItemNode);

	if ( Type == CF_ITYP_STRING )
		*ResStr = CreateArgstring ((STRPTR)Contents, StrLen ((STRPTR)Contents));

	else if ( Type == CF_ITYP_NUMBER )
		*ResStr = CreateNumArgStr (Contents);

	else if ( Type == CF_ITYP_BOOL )
	{
		if ( Contents )
			*ResStr = SetRC_TRUE  ();
		else
			*ResStr = SetRC_FALSE ();
	}

	return (RC_OK);
}
