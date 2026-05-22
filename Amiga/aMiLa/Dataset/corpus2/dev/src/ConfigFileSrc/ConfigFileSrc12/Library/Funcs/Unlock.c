/*
**		$PROJECT: ConfigFile.library
**		$FILE: Unlock.c
**		$DESCRIPTION: cf_Unlock#?() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#undef cf_UnlockArgList
#undef cf_UnlockGrpList
#undef cf_UnlockItemList

/****** configfile.library/cf_UnlockArgList **********************************
*
*   NAME
*        cf_UnlockArgList -- Unlocks the argument list of the group node.
*
*   SYNOPSIS
*        cf_UnlockArgList(GrpNode);
*                         A0
*
*        VOID cf_UnlockArgList(CFGroup *);
*
*   FUNCTION
*        This function unlocks the access on the argument list.
*
*   INPUTS
*        GrpNode - The group node for the argument list.
*
*   SEE ALSO
*        cf_UnlockGrpList(), cf_UnlockItemList(), cf_LockArgList()
*
******************************************************************************
*
*/

SLibCall VOID cf_UnlockArgList ( REGA0 iCFGroup * GrpNode )
{ return; }

/****** configfile.library/cf_UnlockGrpList **********************************
*
*   NAME
*        cf_UnlockGrpList -- Unlocks the group list of the header.
*
*   SYNOPSIS
*        cf_UnlockGrpList(Header);
*                         A0
*
*        VOID cf_UnlockGrpList(CFHeader *);
*
*   FUNCTION
*        This function unlocks the access on the group list.
*
*   INPUTS
*        Header - Pointer to the CFHeader structure.
*
*   SEE ALSO
*        cf_UnlockArgList(), cf_UnlockItemList(), cf_LockGrpList()
*
******************************************************************************
*
*/

SLibCall VOID cf_UnlockGrpList ( REGA0 iCFHeader * Header )
{ return; }

/****** configfile.library/cf_UnlockItemList *********************************
*
*   NAME
*        cf_UnlockItemList -- Unlocks the item list of the argument node.
*
*   SYNOPSIS
*        cf_UnlockItemList(ArgNode);
*                          A0
*
*        VOID cf_UnlockItemList(CFArgument *);
*
*   FUNCTION
*        This function unlocks the access on the item list.
*
*   INPUTS
*        ArgNode - The argument node for item list.
*
*   SEE ALSO
*        cf_UnlockArgList(), cf_UnlockGrpList(), cf_LockItemList()
*
******************************************************************************
*
*/

SLibCall VOID cf_UnlockItemList ( REGA0 iCFArgument * ArgNode )
{ return; }
