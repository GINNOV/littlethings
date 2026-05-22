/*
 * raw.c
 *
 *    This is a routine for setting a given stream to raw or cooked mode.
 * This is useful when you are using Lattice C to produce programs that
 * want to read single characters with the "getch()" or "fgetc" call.
 *
 * Written : 18-Jun-87 By Chuck McManis.
 *           If you use it I would appreciate credit for it somewhere.
 *
 * Small changes 17-Sep-95 by Olaf Barthel
 */

#include <dos/dosextens.h>
#include <clib/dos_protos.h>
#include <pragmas/dos_pragmas.h>

extern struct DosLibrary *DOSBase;

#include <stdio.h>
#include <errno.h>
#include <ios1.h>

static long
change_stream_mode(FILE *fp,LONG raw)
{
	struct MsgPort *mp;
	BPTR handle;

	handle = (BPTR)((struct UFB *)chkufb(fileno(fp)))->ufbfh;
	mp = ((struct FileHandle *)BADDR(handle))->fh_Type;

	if(mp && IsInteractive(handle))
	{
		if(DoPkt(mp,ACTION_SCREEN_MODE,raw,0,0,0,0))
			return(0);
		else
			errno = ENXIO;
	}
	else
		errno = ENOTTY;

	return(-1);
}

/*
 * Function raw() - Convert the specified file pointer to 'raw' mode. This
 * only works on TTY's and essentially keeps DOS from translating keys for
 * you, also (BIG WIN) it means getch() will return immediately rather than
 * wait for a return. You lose editing features though.
 */
long
raw(FILE *fp)
{
	return(change_stream_mode(fp,DOSTRUE));
}

/*
 * Function - cooked() this function returns the designate file pointer to
 * it's normal, wait for a <CR> mode. This is exactly like raw() except that
 * it sends a 0 to the console to make it back into a CON: from a RAW:
 */

long
cooked(FILE *fp)
{
	return(change_stream_mode(fp,DOSFALSE));
}
