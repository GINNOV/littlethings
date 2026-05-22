/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    batch.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 16-Dec-93
    Modified: 18-Jan-97
    _______________________________________________________________________
*/

#include "headers.h"

//______________________________________________________________________________

BOOL
SetupFastMode (struct Object *root)

/* $DOC
 * FUNCTION
 *	Setup for "fast" mode (batch CLI/WB)
 * INPUTS
 *	root = object root
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
	LONG bits[2] = { 0x10 , 0x00 } ; // { test "a" bit , must be 0 }

	// select the files:
	     if (IS_ARG_IMAGE)                          DoSelect(root,SEL_INCLMATCH,ARG_FROM);
	else if (NOT ARG_SELECT[0])                     DoSelect(root,SEL_INCLOBJECT,NULL);
	else if (NOT stricmp(ARG_SELECT,"ALL"))         DoSelect(root,SEL_INCLOBJECT,NULL);
	else if (NOT stricmp(ARG_SELECT,"ARC"))         DoSelect(root,SEL_INCLBIT,(BYTE *)bits);
	else if (NOT PlaySelect(root,ARG_SELECT))       return(FALSE);

	InitOperation();
	return TRUE;
}
//______________________________________________________________________________


LONG
BatchBackup()

/* $DOC
 * FUNCTION
 *	Handles backup in "batch" mode
 * OUTPUTS
 *	Result = program return rc
 * $END
 */

{
	struct Object	*root;
	LONG	rc;
	UBYTE	*p;

	PrgAction = PA_BACKUP;

	rc = EXIT_FAILURE;	// soyons bien optimistes... :^)
	p = ARG_TO[0]? ARG_TO: PRF_BUPTO;

	if (NOT IS_ARG_IMAGE) {
		strcpy(StartDir,ARG_FROM);
		root = LoadDirTree(ARG_FROM);
	}
	else root = DevList;

	if (root && SetupFastMode(root) && DoBackup(root,p)) rc = EXIT_SUCCESS;

	if (root != DevList) FreeDirTree(root);
	return(rc);
}
//______________________________________________________________________________


LONG
BatchRestore()

/* $DOC
 * FUNCTION
 *	Handles restore in "batch" mode
 * OUTPUTS
 *	Result = program return rc
 * $END
 */

{
	struct Object	*root = NULL;
	LONG	rc = EXIT_FAILURE;

	PrgAction = PA_RESTORE;

	// load catalog:
	if (FindCatalog(ARG_FROM,FALSE)) {
		if (root = LoadCatalog(FALSE)) {
			if (SetupFastMode(root)) {
				DoRestore(root,ARG_TO[0]? ARG_TO: PRF_RESTO);
				rc = EXIT_SUCCESS;
			}
			FreeCatalog(root);
		}
	}

	return(rc);
}
//______________________________________________________________________________


LONG
BatchVerify()

/* $DOC
 * FUNCTION
 *	Handles verify in "batch" mode
 * OUTPUTS
 *	Result = program return rc
 * $END
 */

{
	struct Object	*root = NULL;
	LONG rc = EXIT_FAILURE;

	PrgAction = PA_VERIFY;

	// load catalog:
	if (FindCatalog(ARG_FROM,FALSE)) {
		if (root = LoadCatalog(FALSE)) {
			if (SetupFastMode(root)) {
				DoVerify(root);
				rc = EXIT_SUCCESS;
			}
			FreeCatalog(root);
		}
	}

	return(rc);
}

// Tab size: 4
