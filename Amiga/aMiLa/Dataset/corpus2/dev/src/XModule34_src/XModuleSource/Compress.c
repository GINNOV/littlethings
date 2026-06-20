/*
**	Compress.c
**
**	(C) 1994 Bernardo Innocenti
**
**	Compression/Decompression handling functions.
*/

#include <exec/memory.h>
#include <libraries/xpk.h>
#include <utility/hooks.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/powerpacker_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/powerpacker_pragmas.h>

#include "XModule.h"
#include "Gui.h"


#define CTYPE_LHA			1
#define CTYPE_XPK			2
#define CTYPE_POWERPACKER	3


//struct Library *PPBase = NULL;
static struct Library *XpkBase = NULL;


UBYTE LhACommand[64] = "LhA >NIL: e -x0 -q \"%s\"";
UBYTE TmpDir[PATHNAME_MAX] = "T:XModuleTmp";
UBYTE LhAFilter[64] = "~(#?readme#?|#?txt#?|#?display#?|#?fileid#?)";






static LONG __asm __saveds XPKProgressFunc (register __a0 struct Hook *hook, register __a1 struct XpkProgress *pr)
{
	return (DisplayProgress (pr->UCur, pr->ULen));
}



static struct Hook XPKProgressHook =
{
	{ NULL, NULL },
	XPKProgressFunc,
	NULL,
	0
};



BPTR DecompressFile (STRPTR name, UWORD type)

/* This function will try to decompress the given file and store
 * it in TmpDir.  If TmpDir does not exist, it will be created.
 * The decompressed file is then locked and returned.
 * A return value of NULL means failure.  Call DecompressFileDone()
 * when you are done with the decompressed file.
 */
{
	struct AnchorPath *ap;
	BPTR ret = 0;
	BPTR dir, olddir;
	LONG err = 0;
	UBYTE FullName[PATHNAME_MAX];


	OpenProgressWindow();

	DisplayAction (MSG_DECRUNCHING);

	/* Find the full path name of the given file */
	{
		BPTR lock;

		if (lock = Lock (name, ACCESS_READ))
		{
			if (!NameFromLock (lock, FullName, PATHNAME_MAX))
				err = IoErr();
			UnLock (lock);
		}
		else err = IoErr();
	}

	if (!err)
	{
		/* Try to lock or create TmpDir */

		if (!(dir = Lock (TmpDir, ACCESS_READ)))
		{
			if (dir = CreateDir (TmpDir))
				if (!(ChangeMode (CHANGE_LOCK, dir, ACCESS_READ)))
				{
					UnLock (dir);
					dir = NULL;
				}
		}

		if (dir)
		{
			olddir = CurrentDir (dir);

			switch (type)
			{
				case CTYPE_LHA:
				{
					UBYTE buf[64+PATHNAME_MAX];

					SPrintf (buf, LhACommand, FullName);
					if (!SystemTagList (buf, NULL))
					{
						if (ap = AllocMem (sizeof (struct AnchorPath) + PATHNAME_MAX, MEMF_CLEAR))
						{
							ap->ap_Strlen = PATHNAME_MAX;

							if (!(err = MatchFirst (LhAFilter, ap)))
							{
								if (!(ret = Lock (ap->ap_Buf, ACCESS_READ)))
									err = IoErr();
							}

							MatchEnd (ap);
							FreeMem (ap, sizeof (struct AnchorPath) + PATHNAME_MAX);
						}
						else err = ERROR_NO_FREE_STORE; /* Fail AllocMem() */

					}
					else err = IoErr(); /* Fail SystemTagList() */

					break;
				}

				case CTYPE_XPK:
				{
					UBYTE dest[PATHNAME_MAX];
					UBYTE errstring[XPKERRMSGSIZE];

					if (!(XpkBase = OpenLibrary ("xpkmaster.library", 2L)))
					{
						CantOpenLib ("xpkmaster.library", 2L);
						CloseProgressWindow();
						return 0;
					}

					strcpy (dest, TmpDir);
					if (AddPart (dest, "XPKTmp", PATHNAME_MAX))
					{
						if (XpkUnpackTags (
							XPK_InName,		FullName,
							XPK_OutName,	dest,
							XPK_GetError,	errstring,
							XPK_ChunkHook,	&XPKProgressHook,
							// XPK_TaskPri,	ThisTask->pr_Task.tc_Node.ln_Pri-1,
							TAG_DONE))
						{
							ShowMessage (MSG_ERROR_DECOMPRESSING, FilePart (FullName), errstring);
						}
						else ret = Lock (dest, ACCESS_READ);
					}

					CloseLibrary (XpkBase); XpkBase = NULL;
					break;
				}

/*	 			case CTYPE_POWERPACKER:

					if (!(PPBase = OpenLibrary ("powerpacker.library", 0L)))
					{
						CantOpenLib ("powerpacker.library", 0L);
						CloseProgressWindow();
						return 0;
					}

					ShowMessage ("PowerPacker compressed files are not supported yet.");

					CloseLibrary (PPBase); PPBase = NULL;
*/
				default:
					break;
			}

			CurrentDir (olddir);
			UnLock (dir);
		}
		else err = IoErr(); /* Fail CreateDir() */
	}

	/* Report error */

	if (err)
	{
		if (err == ERROR_NO_MORE_ENTRIES)
			ShowMessage (MSG_NOTHING_IN_ARC, name);
		else
			ShowFault (MSG_CANT_LOAD_COMPRESSED, FALSE);
	}

	if (!ret) DecompressFileDone();

	CloseProgressWindow();

	return ret;
}



void DecompressFileDone (void)

/* This call releases all resources got by DecompressFile(). */
{
	BPTR dir, olddir;
	struct FileInfoBlock *fib;

	if (dir = Lock (TmpDir, ACCESS_READ))
	{
		olddir = CurrentDir (dir);

		if (fib = AllocDosObject (DOS_FIB, NULL))
		{
			if (Examine (dir, fib))
			{
				/* Delete all files in the temp directory */
				while (ExNext (dir, fib))
					DeleteFile (fib->fib_FileName);
			}

			FreeDosObject (DOS_FIB, fib);
		}

		CurrentDir (olddir);
		UnLock (dir);
	}

	DeleteFile (TmpDir);
}



LONG CruncherType (BPTR file)
{
	union
	{
		LONG fileid;
		struct
		{
			UWORD dummy;
			ULONG prefix;
		} lha;
	} id;

	if (Read (file, &id, sizeof (id)) != sizeof (id))
		return 0;

	if ((id.lha.prefix >> 8) == '-lh')
		return CTYPE_LHA;

	if (id.fileid == 'XPKF' || id.fileid == 'PP20' || id.fileid == 'PX20')
		return CTYPE_XPK;

	return 0;
}
