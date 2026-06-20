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
    icon.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 27-Apr-94
    Modified: 28-Apr-94
    _______________________________________________________________________
*/

#include "headers.h"
#include "icon.h"

VOID
AddIcon (STRPTR arcname)
{
	char *p;
	UBYTE *dt ;
	UBYTE path[MAXSTR+1],name[31];
	struct DiskObject *pdo = NULL ;

	if (IS_BFL_ADDICON) {

		// select the icon to use (internal or external ?)

		if ( strlen(ARG_ICONPATH) > 0 ) {
		  strcpy(name,ARG_ICONPATH);
		  if (p = strstr(name,".info")) *p = '\0' ;
		  pdo = GetDiskObjectNew( name ) ;
		}
		if ( ! pdo ) pdo = &ArcIcon ;

		// get the program's path and name to add the default tool entry

		dt = pdo->do_DefaultTool ;

		if (! GetProgramName(name,sizeof(name))) strcpy(name,_PROGNAME_);

		if (NameFromLock(GetProgramDir(),path,sizeof(path))
		    && AddPart(path,name,sizeof(path)))
		  pdo->do_DefaultTool = path;
		else
		  pdo->do_DefaultTool = _PROGNAME_;

		// write the icon

		pdo->do_CurrentX = NO_ICON_POSITION ;
		pdo->do_CurrentY = NO_ICON_POSITION ;
		PutDiskObject(arcname,pdo);

		pdo->do_DefaultTool = dt ;
		if ( pdo != &ArcIcon ) FreeDiskObject( pdo ) ;
	}
}

// Tab size: 4
