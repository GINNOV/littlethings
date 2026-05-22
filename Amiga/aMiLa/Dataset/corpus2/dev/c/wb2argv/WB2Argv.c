/*
 *  WB2Argv v1.0, Amiga Workbench argv/argc emulation routines.
 *  Copyright (C) 1995-96 Jens T. Berger Thielemann
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *  Contact the author at:
 *		Jens Berger
 *		Spektrumvn. 4
 *		N-0666 Oslo
 *		Norway
 *		E-mail: <jensthi@ifi.uio.no>
 *
 *  Note: If you use any of these routines in your programs, you have to
 *  mention so in the document.
 *
 *
 */

#ifdef AMIGA

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <workbench/startup.h>
#include <proto/dos.h>
#include <workbench/workbench.h>
#include <proto/icon.h>
#include <proto/exec.h>

#include "WB2Argv.h"

/* #define WB_DEBUG */

#ifdef WB_DEBUG
char __stdiowin[] = "CON:0/10/640/180/WB2Argv";
char __stdiov37[] = "/AUTO/CLOSE/WAIT";
#endif

/*
 * Concatenates the `File' string to the `Dir' string, leaving the result
 * in the `Dir' buffer. Takes care of inserting `directory' characters;
 * if we've got the strings "/usr/foo" and "bar", we'll get
 * "/usr/foo/bar".
 *
 * Behaviour somewhat controlled by the macros SLASH and DIRCHARS in the
 * .h file.
 *
 */

#define DIRCHARS ":/"
#define SLASH '/'

void tackon(STRPTR Dir, const STRPTR File)
{
	UBYTE	EndC;
	ULONG	SLen;

	if(Dir && (SLen = strlen(Dir)))
	{
		EndC = Dir[SLen -1];
		if(!strchr(DIRCHARS, EndC))
		{
			Dir[SLen++] = SLASH;
			Dir[SLen  ] = 0;
		}
	}

	strcat(Dir, File);
}



/*
 * Converts a message from workbench into an argv look-a-like. Tooltypes
 * are converted to long-named options, suitable for passing to GNU's
 * getopt_long(). Shift-clicked files will be appended at the end; their
 * tooltypes will _currently_ not be processed. This may happen in a future
 * version (is it desirable?).
 *
 * Flags: Currently these do only control whether we'll convert the
 * case of the options. See WB2Argv.h for options.
 *
 * Returns an array of string-pointers; terminated with a NULL. To get
 * argc, call CountArgv().
 */


char **WB2Argv(struct WBStartup *WBMsg, LONGBITS Flags)
{
	ULONG	c = 0,
			CurArg = 0,
			NewArgc = 0;
	STRPTR	*NewArgv,
			*Tools,
			Buf;
	BPTR	OldCurDir;
	BOOL    TmpSucc = TRUE,
			IconOpen = FALSE;
	struct DiskObject *dskobj = NULL;

	if(WBMsg && (DOSBase->dl_lib.lib_Version > 36))
	{
		OldCurDir = CurrentDir(WBMsg->sm_ArgList->wa_Lock);

		/*
		 * First, count the # of argv entries. We get both from
		 * shift-clicked icons + tooltypes.
		 */

		NewArgc = WBMsg->sm_NumArgs;

 		if(IconBase = OpenLibrary("icon.library", 0))
		{
			IconOpen = TRUE;
			if(dskobj = GetDiskObject(WBMsg->sm_ArgList->wa_Name))
			{
				Tools = dskobj->do_ToolTypes;

				while(*Tools++)
					NewArgc++;
			}
		}

		/*
		 * Stuff it together...
		 */

		if(NewArgv = calloc(NewArgc + 2, sizeof(APTR)))
		{
			CurArg = 0;

			/* Program name */

			if(Buf = malloc(sizeof(UBYTE) * BUFSIZ))
			{
				CurrentDir(WBMsg->sm_ArgList->wa_Lock);

				if(NameFromLock(WBMsg->sm_ArgList->wa_Lock, Buf, BUFSIZ))
				{
					tackon(Buf, WBMsg->sm_ArgList->wa_Name);
					NewArgv[CurArg++] = Buf;
				}
			}

			if(dskobj)
			{
				/* Tooltypes becomes longnamed options */
				for(Tools = dskobj->do_ToolTypes;
					*Tools && TmpSucc;
					Tools++)
				{
					/* To avoid a false `--' */
					if(**Tools)
					{
						TmpSucc = FALSE;

						if(Buf = malloc(strlen(*Tools) + 4))
						{
							strcpy(Buf, "--");
							strcat(Buf, *Tools);

							TmpSucc = TRUE;
							NewArgv[CurArg++] = Buf;

							/* Make option lowercase */

							switch(Flags & W2A_CASEMASK)
							{
							case W2A_LOWER:
								for(;
									*Buf && (*Buf != '=');
									Buf++)
									*Buf = tolower(*Buf);
								break;
							case W2A_UPPER:
								for(;
									*Buf && (*Buf != '=');
									Buf++)
									*Buf = toupper(*Buf);
								break;
							case W2A_KEEPCASE:
								break;
							}
						}
					}
				}
			}

			/* End of options... */
			NewArgv[CurArg++] = "--";

			if(TmpSucc)
			{
				for(c = 1;			/* Skip program name */
				   (c < WBMsg->sm_NumArgs) && TmpSucc;
					c++)
				{
					TmpSucc = FALSE;
					if(Buf = malloc(sizeof(UBYTE) * BUFSIZ))
					{
						CurrentDir(WBMsg->sm_ArgList[c].wa_Lock);

						if(NameFromLock(WBMsg->sm_ArgList[c].wa_Lock, Buf, BUFSIZ))
						{
							tackon(Buf, WBMsg->sm_ArgList[c].wa_Name);
							NewArgv[CurArg++] = Buf;
							TmpSucc = TRUE;
						}
					}
				}
			}
		}
		CurrentDir(OldCurDir);

		if(dskobj)
			FreeDiskObject(dskobj);

		if(IconOpen)
			CloseLibrary(IconBase);

		if(TmpSucc)
			return(NewArgv);
	}

	return(NULL);
}

ULONG CountArgv(const char **argv)
{
	ULONG argc = 0;

	if(argv)
	{
		while(*argv++)
			argc++;
	}
	return(argc);
}

#ifdef WB_DEBUG
#	define EXIT_FAILURE	20
void main(int argc, char **argv)
{
	int c;
	if(_WBenchMsg)
	{
		if(argv = WB2Argv(_WBenchMsg, W2A_LOWER))
			argc = CountArgv(argv);
		else
			exit(EXIT_FAILURE);
	}

	for(c = 0; c < argc; c++)
		printf("%s\n", argv[c]);

}

#endif /* WB_DEBUG */

#endif /* AMIGA */
