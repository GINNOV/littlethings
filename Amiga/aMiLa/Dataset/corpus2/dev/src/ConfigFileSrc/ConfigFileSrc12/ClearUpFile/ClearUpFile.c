/*
**  $PROJECT: ClearUpFile
**
**  $VER: ClearUpFile.c 2.4 (2.10.97)
**
**  (C) Copyright 1996-1997 Marcel Karas
**      All Rights Reserved.
**
**  $HISTORY:
**
**  0.1  10.11.96 -- Inital first version.
**  1.0  10.11.96 -- First bug free version.
**  1.1  16.11.96 -- Changed Header->WBufLength to 16384.
**  1.2  05.12.96 -- First public version.
**  1.3  06.01.97 -- Changed Header->WBufLength to 32768.
**  2.0  04.02.97 -- Needs and uses now ConfigFile.library V2.
**                -- Opens a file now with cf_OpenPS() and a puddlesize 
**                   of 32768 bytes.
**  2.1  11.02.97 -- Added the new cf_Open() errorcodes.
**  2.2  12.02.97 -- Removed the stuff Printf() call by an
**                   OpenLibrary("dos.library", 36L) failure.
**  2.3  16.02.97 -- Optimized code.
**  2.4  02.10.97 -- Recompiled for public release.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <dos/rdargs.h>
#include <dos/dos.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "OLibTagged.h"

#include <Libraries/ConfigFile.h>
#include <CLib/ConfigFile_protos.h>
#include <Pragmas/ConfigFile_pragmas.h>

struct Library *DOSBase;
struct Library *SysBase;
struct Library *CFBase;

enum { ARG_FILE ,ARG_MAX };

VOID PrintErr ( STRPTR );

ULONG start ( VOID )
{
	struct RDArgs *RDA;
	LONG ArgAry[ARG_MAX] = { 0 };

	ULONG Result	= RETURN_ERROR, WMode;
	ULONG Error		= 0;

	CFHeader *Header;

	if ( DOSBase = TaggedOpenLibrary (TLIB_DOS) )
	{
		if ( CFBase = OpenLibrary (CF_NAME, 2L) )
		{
			RDA = AllocDosObject (DOS_RDARGS, NULL);

			if ( ReadArgs ("ConfigFile/A", ArgAry, RDA) )
			{
				Printf ("Open and read file\n");

				if ( Header = cf_Open ((STRPTR) ArgAry[ARG_FILE],
						CF_OMODE_OLDFILE | CF_OFLG_READ_TOO, &Error) )
				{
					Printf ("Write file\n");

					WMode = (Header->Flags & CF_HFLG_ASCII_FILE)
									? CF_WMODE_ASCII : CF_WMODE_SHORT;

					if ( cf_Write (Header, WMode | CF_WFLG_WRITE_ALWAYS, &Error) )
					{
						Printf ("Ok\n");

						Result = RETURN_OK;
					}
					else
					{
						switch ( Error )
						{
							case CF_WERR_ALLOC_WBUFFER:	PrintErr ("No memory for WriteBuffer"); break;
							default:								PrintErr ("Unkown write failure"); break;
						}
					}

					cf_Close (Header);
				}
				else
				{
					switch ( Error )
					{
						case CF_OERR_OPEN_FILE:		PrintErr ("Couldn't open CF File"); break;
						case CF_OERR_READ_FILE:		PrintErr ("Couldn't read CF File"); break;
						case CF_OERR_NO_FORMAT:		PrintErr ("File no CF Format"); break;
						case CF_OERR_NO_SIZE:		PrintErr ("File has no size"); break;
						case CF_OERR_HEADER_MEM:	PrintErr ("No memory for Header"); break;

						/* cf_Read() failures */
						case CF_RERR_FORMAT:			PrintErr ("File has an error in the format structure"); break;
						case CF_RERR_UNKOWN_ITYPE:	PrintErr ("An unkown item type was found"); break;

						default:							PrintErr ("Unkown open failure"); break;
					}
				}

				FreeArgs (RDA);
			}
			else	PrintErr ("Wrong arguments");

			FreeDosObject (DOS_RDARGS, RDA);
			CloseLibrary (CFBase);
		}
		else	PrintErr ("Couldn't open ConfigFile.library V2+");

		CloseLibrary (DOSBase);
	}

	return (Result);
}

VOID PrintErr ( STRPTR String ) { Printf ("ClearUpFile: %ls\n", String); }
