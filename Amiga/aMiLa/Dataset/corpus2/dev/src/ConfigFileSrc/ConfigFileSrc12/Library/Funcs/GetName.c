/*
**		$PROJECT: ConfigFile.library
**		$FILE: GetName.c
**		$DESCRIPTION: cf_Get#?Name() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

/****** configfile.library/cf_GetGrpName *************************************
*
*   NAME
*        cf_GetGrpName -- Get the name of a group node. (V2)
*
*   SYNOPSIS
*        NamePtr = cf_GetGrpName(GrpNode);
*        D0                      A0
*
*        STRPTR cf_GetGrpName(CFGroup *);
*
*   FUNCTION
*        This function gets a pointer to the name of a group node.
*
*   INPUTS
*        GrpNode - The group node.
*
*   RESULT
*        NamePtr - Pointer to the name of an group node.
*
*   EXAMPLE
*        CFHeader * myHeader;
*        CFGroup  * myGrpNode;
*        STRPTR     GrpName;
*
*        ...
*        myGrpNode = cf_NewGroup (myHeader, "ExampleGroup");
*
*        GrpName = cf_GetGrpName (myGrpNode);
*        printf ("The name of the group node is '%s'\n", GrpName);
*        ...
*
*   SEE ALSO
*        cf_GetArgName()
*
******************************************************************************
*
*/

SLibCall STRPTR cf_GetGrpName ( REGA0 iCFGroup * GrpNode )
{
	FuncDe(bug("cf_GetGrpName($%08lx)\n{\n   return([$%08lx,\"%ls\"])\n}\n",
			GrpNode, GrpNode->Name, GrpNode->Name));

	return (GrpNode->Name);
}

/****** configfile.library/cf_GetArgName *************************************
*
*   NAME
*        cf_GetArgName -- Get the name of an argument node. (V2)
*
*   SYNOPSIS
*        NamePtr = cf_GetArgName(ArgNode);
*        D0                      A0
*
*        STRPTR cf_GetArgName(CFArgument *);
*
*   FUNCTION
*        This function gets a pointer to the name of an argument node.
*
*   INPUTS
*        ArgNode - The argument node.
*
*   RESULT
*        NamePtr - Pointer to the name of an argument node.
*
*   EXAMPLE
*        CFGroup    * myGrpNode;
*        CFArgument * myArgNode;
*        STRPTR       ArgName;
*
*        ...
*        myArgNode = cf_NewArgument (myGrpNode, "ExampleArgument");
*
*        ArgName = cf_GetGrpName (myArgNode);
*        printf ("The name of the argument node is '%s'\n", ArgName);
*        ...
*
*   SEE ALSO
*        cf_GetGrpName()
*
******************************************************************************
*
*/

SLibCall STRPTR cf_GetArgName ( REGA0 iCFArgument * ArgNode )
{
	FuncDe(bug("cf_GetArgName($%08lx)\n{\n   return([$%08lx,\"%ls\"])\n}\n",
			ArgNode, ArgNode->Name, ArgNode->Name));

	return (ArgNode->Name);
}
