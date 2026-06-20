/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: GetName.c
**		$DESCRIPTION: rxcf_Get#?Name() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;
IMPORT struct Library *RexxSysBase;

/****** rexxconfigfile.library/cf_GetGrpName *********************************
*
*   NAME
*        cf_GetGrpName -- Get the name of a group node.
*
*   SYNOPSIS
*        Name = cf_GetGrpName(GrpNode)
*
*        NAME cf_GetGrpName(GRPNODE/N/A)
*
*   FUNCTION
*        This function get the name of a group node.
*
*   INPUTS
*        GrpNode - The group node.
*
*   RESULT
*        Name - The name of a group node.
*
*   EXAMPLE
*        ...
*        myGrpNode = cf_NewGroup(myHeader,"ExampleGroup")
*
*        GrpName = cf_GetGrpName(myGrpNode)
*        SAY 'The name of the group node is' GrpName
*        ...
*
*   SEE ALSO
*        cf_GetArgName()
*
******************************************************************************
*
*/

UWORD rxcf_GetGrpName ( RX_FUNC_ARGS, CFGroup * GrpNode )
{
	STRPTR GrpName = cf_GetGrpName (GrpNode);

	*ResStr = CreateArgstring (GrpName, StrLen (GrpName));
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetArgName *********************************
*
*   NAME
*        cf_GetArgName -- Get the name of an argument node.
*
*   SYNOPSIS
*        Name = cf_GetArgName(ArgNode)
*
*        NAME cf_GetArgName(ARGNODE/N/A)
*
*   FUNCTION
*        This function get the name of an argument node.
*
*   INPUTS
*        ArgNode - The argument node.
*
*   RESULT
*        Name - The name of an argument node.
*
*   EXAMPLE
*        ...
*        myArgNode = cf_NewArgument(myGrpNode,"ExampleArgument")
*
*        ArgName = cf_GetArgName(myArgNode)
*        SAY 'The name of the argument node is' ArgName
*        ...
*
*   SEE ALSO
*        cf_GetGrpName()
*
******************************************************************************
*
*/

UWORD rxcf_GetArgName ( RX_FUNC_ARGS, CFArgument * ArgNode )
{
	STRPTR ArgName = cf_GetArgName (ArgNode);

	*ResStr = CreateArgstring (ArgName, StrLen (ArgName));
	return (RC_OK);
}
