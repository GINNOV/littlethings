/*
**		$PROJECT: ConfigFile.library
**		$FILE: Find.c
**		$DESCRIPTION: cf_Find#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library	* UtilityBase;

/****** configfile.library/cf_FindArgument ***********************************
*
*   NAME
*        cf_FindArgument -- Finds a specfic argument node. (case sensitive)
*
*   SYNOPSIS
*        ArgNode = cf_FindArgument(GrpNode,Name);
*        D0                        A0     A1
*
*        CFArgument * cf_FindArgument(CFGroup *,STRPTR);
*
*   FUNCTION
*        This function finds a specfic argument node.
*
*   INPUTS
*        GrpNode - The group node of the argument list to search.
*        Name - Name of the argument node. 
*
*   RESULT
*        ArgNode - The argument node or NULL.
*
*   SEE ALSO
*        cf_FindGroup(), cf_FindItem()
*
******************************************************************************
*
*/

LibCall iCFArgument * cf_FindArgument ( REGA0 iCFGroup * GrpNode , REGA1 STRPTR Name )
{
	iCFArgument * ArgNode;

	FuncDe(bug("cf_FindArgument($%08lx,\"%ls\")\n{\n", GrpNode, Name));

	if ( ArgNode = cf_LockArgList (GrpNode) )
	{
		while ( ArgNode = cf_NextArgument (ArgNode) )
//			if ( !Stricmp (Name, ArgNode->Name) ) return (ArgNode);
			if ( !StrCmp (Name, ArgNode->Name) )
			{
				FuncDe(bug("   return($%08lx)\n}\n", ArgNode));
				return (ArgNode);
			}
		
		cf_UnlockArgList (GrpNode);
	}

	FuncDe(bug("   return(NULL)\n}\n"));
	return (NULL);
}

/****** configfile.library/cf_FindGroup **************************************
*
*   NAME
*        cf_FindGroup -- Finds a specfic group node. (case sensitive)
*
*   SYNOPSIS
*        GrpNode = cf_FindGroup(Header,Name);
*        D0                     A0     A1
*
*        CFGroup * cf_FindGroup(CFHeader *,STRPTR);
*
*   FUNCTION
*        This function finds a specfic group node.
*
*   INPUTS
*        Header - A pointer to the Header of the group list to search.
*        Name - Name of the group node.
*
*   RESULT
*        GrpNode - The group node or NULL.
*
*   SEE ALSO
*        cf_FindArgument(), cf_FindItem()
*
******************************************************************************
*
*/

LibCall iCFGroup * cf_FindGroup ( REGA0 iCFHeader * Header , REGA1 STRPTR Name )
{
	iCFGroup * GrpNode;

	FuncDe(bug("cf_FindGroup($%08lx,\"%ls\")\n{\n", Header, Name));

	if ( GrpNode = cf_LockGrpList (Header) )
	{
		while ( GrpNode = cf_NextGroup (GrpNode) )
			if ( !StrCmp (Name, GrpNode->Name) )
			{
				FuncDe(bug("   return($%08lx)\n}\n", GrpNode));
				return (GrpNode);
			}
//			if ( !Stricmp (Name, GrpNode->Name) ) return (GrpNode);

		cf_UnlockGrpList (Header);
	}

	FuncDe(bug("   return(NULL)\n}\n"));
	return (NULL);
}

/****** configfile.library/cf_FindItem ***************************************
*
*   NAME
*        cf_FindItem -- Finds a specfic item node.
*
*   SYNOPSIS
*        ItemNode = cf_FindItem(ArgNode,Contents,Type);
*        D0                     A0      D0       D1
*
*        CFItem * cf_FindItem(CFArgument *,LONG,ULONG);
*
*   FUNCTION
*        This function finds a specfic item node.
*
*   INPUTS
*        ArgNode - The argument node of the item list to search.
*        Contents - Contents of the item node.
*        Type - The type of contents (if NULL the function fails).
*
*   RESULT
*        ItemNode - The item node or NULL.
*
*   SEE ALSO
*        cf_FindArgument(), cf_FindGroup()
*
******************************************************************************
*
*/

SLibCall iCFItem * cf_FindItem ( REGA0 iCFArgument * ArgNode , REGD0 LONG Contents , REGD1 ULONG Type )
{
	iCFItem * ItemNode;

	FuncDe(bug("cf_FindItem($%08lx,[$%08lx,%ld],%ld)\n{\n", ArgNode,
		Contents, Contents, Type));

	if ( ItemNode = cf_LockItemList (ArgNode) )
	{
		while ( ItemNode = cf_NextItem (ItemNode) )
		{
			if ( ItemNode->Type == Type )
			{
				if ( Type == CF_ITYP_STRING )
				{
					if ( !StrCmp ((STRPTR)Contents, ItemNode->Contents.String) )
					{
						FuncDe(bug("   return($%08lx)\n}\n", ItemNode));
						return (ItemNode);
					}
				}
				else
				{
					if ( ItemNode->Contents.Number == Contents )
					{
						FuncDe(bug("   return($%08lx)\n}\n", ItemNode));
						return (ItemNode);
					}
				}
			}
		}

		cf_UnlockItemList (ArgNode);
	}

	FuncDe(bug("   return(NULL)\n}\n"));
	return (NULL);
}
