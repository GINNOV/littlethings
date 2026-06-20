/*
**		$PROJECT: ConfigFile.library
**		$FILE: New.c
**		$DESCRIPTION: cf_New#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase	* SysBase;

/****** configfile.library/cf_NewArgument ************************************
*
*   NAME
*        cf_NewArgument -- Creates a new argument node.
*
*   SYNOPSIS
*        ArgNode = cf_NewArgument(GrpNode,Name);
*        D0                       A0      A1
*
*        CFArgument * cf_NewArgument(CFGroup *,STRPTR);
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
*        CFGroup    * myGrpNode;
*        CFArgument * myArgNode;
*
*        ...
*        
*        myArgNode = cf_NewArgument(myGrpNode,"ExampleArg");
*        ...
*
*        In the CF file:
*
*        ...
*        ExampleArg=
*        ...
*
*   NOTES
*        The version 2 of the ConfigFile.library didn't support anymore a
*        NULL pointer by GrpNode.
*
*   SEE ALSO
*        cf_NewGroup(), cf_NewItem(), cf_NewArgItem()
*
******************************************************************************
*
*/

LibCall iCFArgument * cf_NewArgument ( REGA0 iCFGroup * GrpNode , REGA1 STRPTR Name )
{
	if ( GrpNode )
	{
		GrpNode->Header->Flags |= CF_HFLG_CHANGED;

		return (NewArg (GrpNode, Name, StrLen (Name)));
	}

	return (NULL);
}

	/* NewArg():
	 *
	 *	create a new Argument.
	 */

IMPORT struct DosLibrary	* DOSBase;

iCFArgument * NewArg ( iCFGroup * GrpNode , STRPTR Name , ULONG Length )
{
	iCFArgument *ArgNode;
	UBYTE			 StructLen = sizeof (iCFArgument) + Length + 2;

	ArgNode = MyAllocPooled (GrpNode->Header->MemPool, StructLen);

	ArgNode->Name				= (STRPTR) ( (ULONG) ArgNode + sizeof (iCFArgument) );
	ArgNode->Name[0]			= Length;
	ArgNode->Name ++;
	ArgNode->Name[Length]	= 0;

	ArgNode->GrpNode		= GrpNode;
	ArgNode->StructSize	= StructLen;

	ArgNode->ExtFlags		= 0;

	MemCpy (ArgNode->Name, Name, Length);
	NewList ((struct List *) &ArgNode->ItemList);
	AddTail ((struct List *) &GrpNode->ArgList, (struct Node *) ArgNode);

	return (ArgNode);
}

/****** configfile.library/cf_NewGroup ***************************************
*
*   NAME
*        cf_NewGroup -- Creates a new group node.
*
*   SYNOPSIS
*        GrpNode = cf_NewGroup(Header,Name);
*        D0                    A0    A1
*
*        CFGroup * cf_NewGroup(CFHeader *,STRPTR);
*
*   FUNCTION
*        This function creates a new group node. The Header must be a
*        pointer to a CFHeader structure.
*
*   INPUTS
*        Header - Pointer to the CFHeader structure for add to.
*                 (!!! not NULL !!!)
*        Name - Name of the new group node.
*
*   RESULT
*        GrpNode - The new group node or NULL by failure.
*
*   EXAMPLE
*        CFHeader * myHeader;
*        CFGroup * myGrpNode;
*
*        ...
*        
*        myGrpNode = cf_NewGroup(myHeader,"ExampleGroup");
*        cf_NewArgument(myGrpNode,"ExampleArg");
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
*   NOTES
*        The version 2 of the ConfigFile.library didn't support anymore a
*        NULL pointer by Header.
*
*   SEE ALSO
*        cf_NewArgument(), cf_NewItem(), cf_NewArgItem()
*
******************************************************************************
*
*/

LibCall iCFGroup * cf_NewGroup ( REGA0 iCFHeader * Header , REGA1 STRPTR Name )
{
	if ( Header )
	{
		Header->Flags |= CF_HFLG_CHANGED;

		return (NewGrp (Header, Name, StrLen (Name)));
	}

	return (NULL);
}

	/* NewGrp():
	 *
	 *	create a new Group.
	 */

iCFGroup * NewGrp ( iCFHeader * Header , STRPTR Name , ULONG Length )
{
	iCFGroup *GrpNode;
	UBYTE		 StructLen = sizeof (iCFGroup) + Length + 2;
	
	GrpNode = MyAllocPooled (Header->MemPool, StructLen);

	GrpNode->Name				= (STRPTR) ( (ULONG) GrpNode + sizeof (iCFGroup) );
	GrpNode->Name[0]			= Length;
	GrpNode->Name ++;
	GrpNode->Name[Length]	= 0;

	GrpNode->Header		= Header;
	GrpNode->StructSize	= StructLen;

	GrpNode->ExtFlags		= 0;

	MemCpy (GrpNode->Name, Name, Length);
	NewList ((struct List *) &GrpNode->ArgList);
	AddTail ((struct List *) &Header->GroupList, (struct Node *) GrpNode);

	return (GrpNode);
}

/****** configfile.library/cf_NewItem ****************************************
*
*   NAME
*        cf_NewItem -- Creates a new item node.
*
*   SYNOPSIS
*        ItemNode = cf_NewItem(ArgNode,Contents,Type,SpecialType);
*        D0                    A0      D0       D1   D2
*
*        CFItem * cf_NewItem(CFArgument *,LONG,ULONG,ULONG);
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
*           CF_ITYP_STRING -- String type (Contents is a pointer to a
*                             NULL-terminated string)
*           CF_ITYP_NUMBER -- Number type (Contents is long value e.g.
*                             44253 or -23456)
*           CF_ITYP_BOOL   -- Bool type   (Contents is long value TRUE or
*                             FALSE)
*        SpecialType - Special types for cf_Write() or NULL for default.
*
*           CF_ITYP_BOOL:
*
*             CF_STYP_BOOL_YES  -- "YES/NO"
*             CF_STYP_BOOL_TRUE -- "TRUE/FALSE"
*             CF_STYP_BOOL_ON   -- "ON/OFF"
*
*           CF_ITYP_NUMBER:
*
*             CF_STYP_NUM_DEC   -- Decimal (e.g 24574)
*             CF_STYP_NUM_HEX   -- Hexdecimal (e.g. $fDe2)
*             CF_STYP_NUM_BIN   -- Binary (e.g. %10111)
*
*   RESULT
*        ItemNode - The new group node or NULL by failure.
*
*   EXAMPLE
*        CFArgument * myArgNode;
*
*        ...
*        
*        myArgNode = cf_NewArgument(NULL,"ExampleArg");
*        cf_NewItem(myArgNode,(LONG)"Foo Str",CF_ITYP_STRING,NULL);
*        cf_NewItem(myArgNode,5467,CF_ITYP_NUMBER,CF_STYP_NUM_DEC);
*        cf_NewItem(myArgNode,35678,CF_ITYP_NUMBER,CF_STYP_NUM_HEX);
*        cf_NewItem(myArgNode,23,CF_ITYP_NUMBER,CF_STYP_NUM_BIN);
*        cf_NewItem(myArgNode,FALSE,CF_ITYP_BOOL,CF_STYP_NUM_ON);
*        cf_NewItem(myArgNode,TRUE,CF_ITYP_BOOL,CF_STYP_NUM_ON);
*        cf_NewItem(myArgNode,TRUE,CF_ITYP_BOOL,CF_STYP_NUM_YES);
*        ...
*
*        In the CF file:
*
*        ...
*        ExampleArg="Foo Str",5467,$865E,%10111,OFF,ON,YES
*        ...
*
*   NOTES
*        The version 2 of the ConfigFile.library didn't support anymore a
*        NULL pointer by ArgNode.
*
*   SEE ALSO
*        cf_NewArgument(), cf_NewGroup(), cf_Write(), cf_NewArgItem(),
*        <libraries/configfile.h>
*
******************************************************************************
*
*/

LibCall iCFItem * cf_NewItem ( REGA0 iCFArgument * ArgNode ,
			REGD0 LONG Contents , REGD1 ULONG Type , REGD2 ULONG SpecialType )
{
	iCFItem *ItemNode = NULL;
	APTR		MemPool;
	UBYTE		Length, StructLen = sizeof (iCFItem);

	if ( ArgNode)
	{
		MemPool = ArgNode->GrpNode->Header->MemPool;

		ArgNode->GrpNode->Header->Flags |= CF_HFLG_CHANGED;

		if ( Type == CF_ITYP_STRING )
			StructLen += 2 + ( Length = StrLen ((STRPTR) Contents) );

		ItemNode = MyAllocPooled (MemPool, StructLen);

		ItemNode->ArgNode			= ArgNode;
		ItemNode->StructSize		= StructLen;
		ItemNode->Type				= Type;
		ItemNode->SpecialType	= SpecialType ? SpecialType : CF_STYP_NUM_DEC;
		ItemNode->ExtFlags		= 0;

		if ( Type == CF_ITYP_STRING )
		{
			ItemNode->Contents.String		= (STRPTR) ( (ULONG) ItemNode + sizeof (iCFItem) );
			ItemNode->Contents.String[0]	= Length;
			ItemNode->Contents.String ++;
			ItemNode->Contents.String[Length]	= 0;

			MemCpy (ItemNode->Contents.String, (STRPTR) Contents, Length);
		}
		else if ( Type == CF_ITYP_BOOL )
			ItemNode->Contents.Bool		= Contents ? TRUE : FALSE;

		else if ( Type == CF_ITYP_NUMBER )
			ItemNode->Contents.Number	= Contents;

		else
		{
			MyFreePooled (MemPool, ItemNode, sizeof(iCFItem));

			return (NULL);
		}

		AddTail ((struct List *) &ArgNode->ItemList, (struct Node *) ItemNode);
	}

	return (ItemNode);
}

/****** configfile.library/cf_NewArgItem *************************************
*
*   NAME
*        cf_NewArgItem -- Creates a new argument node and a new item node.
*
*   SYNOPSIS
*        ArgNode = cf_NewArgItem(GrpNode,Name,Contents,Type,SpecialType);
*        D0                      A0      A1   D0       D1   D2
*
*        CFArgument * cf_NewArgItem(CFGroup *,STRPTR,LONG,ULONG,ULONG);
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
*        CFGroup * myGrpNode;
*
*        ...
*        
*        cf_NewArgument(myGrpNode,"ExampleArg","FooStr",CF_ITYP_STRING,NULL);
*        ...
*
*        In the CF file:
*
*        ...
*        ExampleArg="FooStr"
*        ...
*
*   NOTES
*        The Version 2 of the ConfigFile.library don't support anymore a
*        NULL pointer by GrpNode.
*
*   SEE ALSO
*        cf_NewGroup(), cf_NewItem(), cf_NewArgument()
*
******************************************************************************
*
*/

SLibCall iCFArgument * cf_NewArgItem ( REGA0 iCFGroup * GrpNode ,
	REGA1 STRPTR Name , REGD0 LONG Contents , REGD1 ULONG Type , REGD2 ULONG SpecialType )
{
	iCFArgument *NewArgNode = 0;

	if ( GrpNode )
	{
		NewArgNode = cf_NewArgument (GrpNode, Name);
		cf_NewItem (NewArgNode, Contents, Type, SpecialType);
	}

	return (NewArgNode);
}
