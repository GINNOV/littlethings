/*
**		$PROJECT: ConfigFile.library
**		$FILE: Remove.c
**		$DESCRIPTION: cf_Remove#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase	* SysBase;

/****** configfile.library/cf_RemoveArgument *********************************
*
*   NAME
*        cf_RemoveArgument -- Remove an argument node.
*
*   SYNOPSIS
*        cf_RemoveArgument(ArgNode);
*                          A0
*
*        VOID cf_RemoveArgument(CFArgument *);
*
*   FUNCTION
*        This function remove an argument node. Note don't adds the removed
*        ArgNode to another open CF file.
*
*   INPUTS
*        ArgNode - The argument node to remove.
*
*   SEE ALSO
*        cf_RemoveGroup(), cf_RemoveItem()
*
******************************************************************************
*
*/

LibCall VOID cf_RemoveArgument ( REGA0 iCFArgument * ArgNode )
{
	FuncDe(bug("cf_RemoveArgument($%08lx)\n{\n", ArgNode));

	if ( !( ArgNode->ExtFlags & CF_EFLG_REMOVED ) )
	{
		Remove ((struct Node *) ArgNode);

		ArgNode->ExtFlags						|= CF_EFLG_REMOVED;
		ArgNode->GrpNode->Header->Flags	|= CF_HFLG_CHANGED;
	}

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_RemoveGroup ************************************
*
*   NAME
*        cf_RemoveGroup -- Remove a group node.
*
*   SYNOPSIS
*        cf_RemoveGroup(GrpNode);
*                       A0
*
*        VOID cf_RemoveGroup(CFGroup *);
*
*   FUNCTION
*        This function remove a group node. Note don't adds the removed 
*        GrpNode to another open CF file.
*
*   INPUTS
*        GrpNode - The group node to remove.
*
*   SEE ALSO
*        cf_RemoveArgument(), cf_RemoveItem()
*
******************************************************************************
*
*/

LibCall VOID cf_RemoveGroup ( REGA0 iCFGroup * GrpNode )
{
	FuncDe(bug("cf_RemoveGroup($%08lx)\n{\n", GrpNode));

	if ( !( GrpNode->ExtFlags & CF_EFLG_REMOVED ) )
	{
		Remove ((struct Node *) GrpNode);

		GrpNode->ExtFlags 		|= CF_EFLG_REMOVED;
		GrpNode->Header->Flags	|= CF_HFLG_CHANGED;
	}

	FuncDe(bug("}\n"));
}

/****** configfile.library/cf_RemoveItem *************************************
*
*   NAME
*        cf_RemoveItem -- Remove an item node.
*
*   SYNOPSIS
*        cf_RemoveItem(ItemNode);
*                      A0
*
*        VOID cf_RemoveItem(CFItem *);
*
*   FUNCTION
*        This function remove an item node. Note don't adds the removed 
*        ItemNode to another open CF file.
*
*   INPUTS
*        ItemNode - The item node to remove.
*
*   SEE ALSO
*        cf_RemoveGroup(), cf_RemoveArgument()
*
******************************************************************************
*
*/

LibCall VOID cf_RemoveItem ( REGA0 iCFItem * ItemNode )
{
	FuncDe(bug("cf_RemoveItem($%08lx)\n{\n", ItemNode));

	if ( !( ItemNode->ExtFlags & CF_EFLG_REMOVED ) )
	{
		Remove ((struct Node *) ItemNode);

		ItemNode->ExtFlags								|= CF_EFLG_REMOVED;
		ItemNode->ArgNode->GrpNode->Header->Flags	|= CF_HFLG_CHANGED;
	}

	FuncDe(bug("}\n"));
}
