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
    getargs.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 14-Dec-93
    Modified: 16-Jan-98
    _______________________________________________________________________
*/

#include "headers.h"
#include "getargs.h"

STATIC void	ReadToolTypes	(struct WBArg *);

VOID
EraseAllArgs (BOOL all)
{
	memset(&Args,'\0',all? sizeof(ABARGS): offsetof(ABARGS,arg_PrefsPath[0]));
	ClearPrgFlag(PF_WBSTART);
}
//______________________________________________________________________________

BOOL
ReadCLIArgs()
{
	struct RDArgs	*rdargs;
	STATIC LONG	args[OPT_COUNT];

	memset(args,0,sizeof(args)); // voir autodoc ReadArgs(): this array should be cleared...

	if (rdargs = ReadArgs(TEMPLATE,args,NULL)) {
		if (args[OPT_BACKUP] || args[OPT_RESTORE] || args[OPT_VERIFY])
			SetPrgFlag(PF_BATCH);

		     if (args[OPT_BACKUP])      ARG_MODE = AMD_BACKUP;
		else if (args[OPT_RESTORE])     ARG_MODE = AMD_RESTORE;
		else if (args[OPT_VERIFY])      ARG_MODE = AMD_VERIFY;

		if (args[OPT_FROM])     strcpy(ARG_FROM,(STRPTR)args[OPT_FROM]);
		if (args[OPT_TO])       strcpy(ARG_TO,(STRPTR)args[OPT_TO]);

		if (args[OPT_SELECT])   strcpy(ARG_SELECT,(STRPTR)args[OPT_SELECT]);
		if (args[OPT_REPORT])   strcpy(ARG_REPORT,(STRPTR)args[OPT_REPORT]);
		if (args[OPT_CATALOG])  strcpy(ARG_CATALOG,(STRPTR)args[OPT_CATALOG]);
		if (args[OPT_PREFS])    strcpy(ARG_PREFS,(STRPTR)args[OPT_PREFS]);
		if (args[OPT_ECSUFFIX]) strcpy(ARG_ECSUFFIX,(STRPTR)args[OPT_ECSUFFIX]);
		if (args[OPT_ICONPATH]) strcpy(ARG_ICONPATH,(STRPTR)args[OPT_ICONPATH]);

		if (args[OPT_QUIET])    OR(ARG_FLAGS,AFL_QUIET);
		if (args[OPT_IMAGE])    OR(ARG_FLAGS,AFL_IMAGE);

		FreeArgs(rdargs);
	}
	else {
		HandleError(NULL,HERR_IOERR);
		return FALSE;
	}
	return TRUE;
}
//______________________________________________________________________________

BOOL
ReadWbArgs()
{
	struct WBArg	*wbarg;
	SHORT	i;
	TEXT	name[MAXSTR+1];
	BPTR	olddir,lock;

	for (i = 0, wbarg = _WBenchMsg->sm_ArgList;
		 i < _WBenchMsg->sm_NumArgs;
		 i++, wbarg++)
	{
		if (NOT wbarg->wa_Name) continue;

		if ( lock = wbarg->wa_Lock )
		  olddir = CurrentDir(lock);
		else
		{
		  name[0] = '\0' ;
		  olddir = NULL;
		}

		if (NOT NameFromLock(lock,name,MAXSTR)) name[0] = '\0' ;
		if ( *wbarg->wa_Name ) AddPart(name,wbarg->wa_Name,MAXSTR);

		if ((i > 0) && MyExamine(name)) // for project icons only
		{
		  // if it's a directory icon, then let's go for a backup.
		  // otherwise, it must be an archive file, so try to restore it:
		  ARG_MODE = GFib.fib_DirEntryType>0? AMD_BACKUP: AMD_RESTORE;
		  strcpy(ARG_FROM,name);
		  SetPrgFlag(PF_WBSTART);
		}

		ReadToolTypes(wbarg);

		if (olddir) CurrentDir(olddir);
	}
	return(TRUE);
}
//______________________________________________________________________________

__inline STATIC void
ReadToolTypes (struct WBArg *wbarg)
{
	struct DiskObject	*dobj;
	BYTE	**tools,*s;

	if (*wbarg->wa_Name && (dobj = GetDiskObject(wbarg->wa_Name))) {
		tools = (BYTE **)dobj->do_ToolTypes;

		if (s = FindToolType(tools,TT_TO  )) strcpy(ARG_TO,s);
		if (s = FindToolType(tools,TT_FROM)) strcpy(ARG_FROM,s);

		if (s = FindToolType(tools,TT_MODE)) {
			     if (MatchToolValue(s,TTMODE_BACKUP )) ARG_MODE = AMD_BACKUP;
			else if (MatchToolValue(s,TTMODE_RESTORE)) ARG_MODE = AMD_RESTORE;
			else if (MatchToolValue(s,TTMODE_VERIFY )) ARG_MODE = AMD_VERIFY;
			if (ARG_MODE) SetPrgFlag(PF_WBSTART);
		}

		if (FindToolType(tools,TT_IMAGE)) OR(ARG_FLAGS,AFL_IMAGE);

		if (s = FindToolType(tools,TT_SELECT))    strcpy(ARG_SELECT,s);
		if (s = FindToolType(tools,TT_REPORT))    strcpy(ARG_REPORT,s);
		if (s = FindToolType(tools,TT_CATALOG))   strcpy(ARG_CATALOG,s);
		if (s = FindToolType(tools,TT_PREFS))     strcpy(ARG_PREFS,s);
		if (s = FindToolType(tools,TT_PREFSPATH)) strcpy(ARG_PPATH,s);
		if (s = FindToolType(tools,TT_HELPPATH))  strcpy(ARG_HPATH,s);
		if (s = FindToolType(tools,TT_ECSUFFIX))  strcpy(ARG_ECSUFFIX,s);
		if (s = FindToolType(tools,TT_ICONPATH))  strcpy(ARG_ICONPATH,s);

		FreeDiskObject(dobj);
	}
}

// Tab size: 4
