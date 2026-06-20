/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: New.c
**		$DESCRIPTION: rxcf_New#?() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library		*RexxSysBase;
IMPORT struct Library		*CFBase;

/****** rexxconfigfile.library/cf_NewArgument ********************************
*
*   NAME
*        cf_NewArgument -- Creates a new argument node.
*
*   SYNOPSIS
*        ArgNode = cf_NewArgument(GrpNode,Name)
*
*        ARGNODE/N cf_NewArgument(GRPNODE/N/A,NAME/A)
*
*   FUNCTION
*        This function creates a new argument node. The GrpNode must be a
*        pointer to a group node. 
*
*   INPUTS
*        GrpNode - The group node for add to. (!!! not NULL !!!)
*        Name - The name of the new argument node.
*
*   RESULT
*        ArgNode - The new argument node or NULL by failure.
*
*   EXAMPLE
*        ...
*        
*        myArgNode = cf_NewArgument(myGrpNode,"ExampleArg")
*        ...
*
*        In the CF file:
*
*        ...
*        ExampleArg=
*        ...
*
*   SEE ALSO
*        cf_NewGroup(), cf_NewItem(), cf_NewArgItem()
*
******************************************************************************
*
*/

UWORD rxcf_NewArgument ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	CFArgument	* NewArgNode;

	if ( IsValidArg (RxMsg, 2) )
	{
		if ( NewArgNode = cf_NewArgument (GrpNode, RXARG2) )
			*ResStr = CreateNumArgStrP (NewArgNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_NewGroup ***********************************
*
*   NAME
*        cf_NewGroup -- Creates a new group node.
*
*   SYNOPSIS
*        GrpNode = cf_NewGroup(Header,Name)
*
*        GRPNODE/N cf_NewGroup(HEADER/N/A,NAME/A)
*
*   FUNCTION
*        This function creates a new group node. The Header must be a
*        pointer to a CFHeader structure.
*
*   INPUTS
*        Header - Pointer to the Header for add to. (!!! not NULL !!!)
*        Name - Name of the new group node.
*
*   RESULT
*        GrpNode - The new group node or NULL by failure.
*
*   EXAMPLE
*        ...
*        
*        myGrpNode = cf_NewGroup(myHeader,"ExampleGroup")
*        cf_NewArgument(myGrpNode,"ExampleArg")
*        ...
*
*        In the CF file:
*
*        ...
*        [ExampleGroup]
*
*        ExampleArg=
*        ...
*
*   SEE ALSO
*        cf_NewArgument(), cf_NewItem(), cf_NewArgItem()
*
******************************************************************************
*
*/

UWORD rxcf_NewGroup ( RX_FUNC_ARGS, CFHeader * Header )
{
	CFGroup	* NewGrpNode;

	if ( IsValidArg (RxMsg, 2) )
	{
		if ( NewGrpNode = cf_NewGroup (Header, RXARG2) )
			*ResStr = CreateNumArgStrP (NewGrpNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_NewItem ************************************
*
*   NAME
*        cf_NewItem -- Creates a new item node.
*
*   SYNOPSIS
*        ItemNode = cf_NewItem(ArgNode,Contents [,Type] [,SpecialType])
*
*        ITEMNODE/N cf_NewItem(ARGNODE/N/A,CONTENTS/A,TYPE,STYPE)
*
*   FUNCTION
*        This function creates a new item node. The ArgNode must be a
*        pointer to a argument node.
*
*   INPUTS
*        ArgNode - The argument node for add to. (!!! not NULL !!!)
*        Contents - The contents of the new item node.
*        Type - Type of the contents.
*
*           ITYP_STRING -- String type (Contents is a NULL-terminated string)
*           ITYP_NUMBER -- Number type (Contents is long value e.g.
*                          44253 or -23456)
*           ITYP_BOOL   -- Bool type   (Contents is long value TRUE or
*                          FALSE)
*        SpecialType - Special types for cf_Write() or NULL for default.
*
*           ITYP_BOOL:
*
*             STYP_BOOL_YES  -- "YES/NO"
*             STYP_BOOL_TRUE -- "TRUE/FALSE"
*             STYP_BOOL_ON   -- "ON/OFF"
*
*           ITYP_NUMBER:
*
*             STYP_NUM_DEC   -- Decimal (e.g 24574)
*             STYP_NUM_HEX   -- Hexdecimal (e.g. $fDe2)
*             STYP_NUM_BIN   -- Binary (e.g. %10111)
*
*   RESULT
*        ItemNode - The new group node or NULL by failure.
*
*   EXAMPLE
*        ...
*        
*        myArgNode = cf_NewArgument(myGrpNode,"ExampleArg")
*        cf_NewItem(myArgNode,"Foo Str",ITYP_STRING)
*        cf_NewItem(myArgNode,5467,ITYP_NUMBER,STYP_NUM_DEC)
*        cf_NewItem(myArgNode,35678,ITYP_NUMBER,STYP_NUM_HEX)
*        cf_NewItem(myArgNode,23,CF_ITYP_NUMBER,STYP_NUM_BIN)
*        cf_NewItem(myArgNode,FALSE,ITYP_BOOL,STYP_NUM_ON)
*        cf_NewItem(myArgNode,TRUE,ITYP_BOOL,STYP_NUM_ON)
*        cf_NewItem(myArgNode,TRUE,ITYP_BOOL,STYP_NUM_YES)
*        ...
*
*        In the CF file:
*
*        ...
*        ExampleArg="Foo Str",5467,$865E,%10111,OFF,ON,YES
*        ...
*
*   SEE ALSO
*        cf_NewArgument(), cf_NewGroup(), cf_Write(), cf_NewArgItem(),
*        <libraries/configfile.h>
*
******************************************************************************
*
*/

UWORD rxcf_NewItem ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	RXCFItemConv  ItemConv;
	CFItem		* ItemNode;

	if ( ConvItemStrings (RxMsg, &ItemConv, 2, 3, 4) )
	{
		if ( ItemNode = cf_NewItem(ArgNode, ItemConv.Contents, ItemConv.Type, ItemConv.SType) )
			*ResStr = CreateNumArgStrP (ItemNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_NewArgItem *********************************
*
*   NAME
*        cf_NewArgItem -- Creates a new argument node and a new item node.
*
*   SYNOPSIS
*        ArgNode = cf_NewArgItem(GrpNode,Name,Contents [,Type][,SpecialType])
*
*        ARGNODE/N cf_NewArgItem(GRPNODE/N/A,NAME/A,CONTENTS/A,TYPE,STYPE)
*
*   FUNCTION
*        This function creates a new argument node and a new item node. The
*        GrpNode must be a pointer to a group node.
*
*   INPUTS
*        GrpNode - The group node for add to. (!!! not NULL !!!)
*        Name - The name of the new argument node.
*        Contents - The contents of the new item node.
*        Type - Type of the contents.
*        SpecialType - Special types for cf_Write() or NULL for default.
*
*   RESULT
*        ArgNode - The new argument node or NULL by failure.
*
*   EXAMPLE
*        ...
*        
*        cf_NewArgItem(myGrpNode,"ExampleArg","FooStr",ITYP_STRING)
*        ...
*
*        In the CF file:
*
*        ...
*        ExampleArg="FooStr"
*        ...
*
*   SEE ALSO
*        cf_NewGroup(), cf_NewItem(), cf_NewArgument()
*
******************************************************************************
*
*/

UWORD rxcf_NewArgItem ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	RXCFItemConv  ItemConv;
	CFArgument	* ArgNode;

	if ( IsValidArg (RxMsg, 2) && ConvItemStrings (RxMsg, &ItemConv, 3, 4, 5) )
	{
		if ( ArgNode = cf_NewArgItem(GrpNode, RXARG2, ItemConv.Contents, ItemConv.Type, ItemConv.SType) )
			*ResStr = CreateNumArgStrP (ArgNode);
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}
