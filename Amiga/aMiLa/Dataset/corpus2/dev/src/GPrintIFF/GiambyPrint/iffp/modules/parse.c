/*  
 * parse.c - iffparse file IO support module
 *   based on some of looki.c by Leo Schwab
 *
 * The filename for clipboard is -c or -cUnit as in -c0 -c1 etc. (default 0)
 *
 * 39.10 - fix CloseClipboard() cast to (struct ClipboardHandle *)
 */

#include <exec/types.h>

#include "iffp/iff.h"

/* local function prototypes */

static LONG stdio_stream(struct Hook *, struct IFFHandle *, struct IFFStreamCmd *);

UBYTE *omodes[2] = {"r","w"};


/* openifile
 *
 * Passed a ParseInfo structure with a not-in-use IFFHandle, filename
 *   ("-c" or -cUnit like "-c1" for clipboard), and IFF open mode
 *   (IFFF_READ or IFFF_WRITE) opens file or clipboard for use with
 *   iffparse.library support modules.
 *
 * Returns 0 for success or an IFFERR (libraries/iffparse.h)
 */

LONG openifile(struct ParseInfo *pi, UBYTE *filename, ULONG iffopenmode)
{
	struct IFFHandle	*iff;
	BOOL	cboard;
	ULONG 	unit = PRIMARY_CLIP;
	LONG 	error;

	if(!pi)			return(CLIENT_ERROR);
        if(!(iff=pi->iff))	return(CLIENT_ERROR);

	cboard = (*filename == '-'  &&  filename[1] == 'c');
 	if(cboard && filename[2])	unit = atoi(&filename[2]);

	if (cboard)
		{
		/*
		 * Set up IFFHandle for Clipboard I/O.
		 */
		pi->clipboard = TRUE;
		if (!(iff->iff_Stream =
				(ULONG)OpenClipboard(unit)))
			{
			message(SI(MSG_IFFP_NOCLIP_D),unit);
			return(NOFILE);
			}
		InitIFFasClip(iff);
		}
	else
		{
		pi->clipboard = FALSE;
		/*
		 * Set up IFFHandle for buffered stdio I/O.
		 */
		if (!(iff->iff_Stream = (ULONG)
		   fopen(filename, omodes[iffopenmode & 1])))
			{
			message(SI(MSG_IFFP_NOFILE_S),filename);
			return(NOFILE);
			}
		else initiffasstdio(iff);
		}

	D(bug("%s file opened: \n", cboard ? "[Clipboard]" : (char *)filename));

	pi->filename = filename;

	error=OpenIFF(iff, iffopenmode);

	pi->opened = error ? FALSE : TRUE;	/* currently open handle */

	D(bug("OpenIFF error = %ld\n",error));
	return(error);
}


/* closeifile
 *
 * closes file or clipboard opened with openifile, and frees all
 *   iffparse context parsed by parseifile.
 *
 * Note - You should closeifile as soon as possible if using clipboard
 *   ("-c[n]").  You also need to closeifile if, for example, you wish to
 *   reopen the file to write changes back out.  See the copychunks.c
 *   module for routines which allow you clone the chunks iffparse has
 *   gathered so that you can closeifile and still be able to modify and
 *   write back out gathered chunks.
 *   
 */

void closeifile(struct ParseInfo *pi)
{
struct IFFHandle *iff;

	D(bug("closeifile:\n"));

	if(!pi)			return;
    	if(!(iff=pi->iff))	return;

	DD(bug("closeifile: About to CloseIFF if open, iff=$%lx, opened=%ld\n",
			iff, pi->opened));

	if(pi->opened)	CloseIFF(iff);

	DD(bug("closeifile: About to close %s, stream=$%lx\n",
			pi->clipboard ? "clipboard" : "file", iff->iff_Stream));
	if(iff->iff_Stream)
		{
		if (pi->clipboard)
		   CloseClipboard((struct ClipboardHandle *)(iff->iff_Stream));
		else
		   fclose ((FILE *)(iff->iff_Stream));
		}

	iff->iff_Stream = NULL;
	pi->clipboard = NULL;
	pi->opened = NULL;
}


/* parseifile
 *
 * Passed a ParseInfo with an initialized and open IFFHandle,
 *  grouptype (like ID_FORM), groupid (like ID_ILBM),
 *  and TAG_DONE terminated longword arrays of type,id
 *  for chunks to be grabbed, gathered, and stopped on
 *  (like { ID_ILBM, ID_BMHD, ID_ILBM, ID_CAMG, TAG_DONE })
 *  will parse an IFF file, grabbing/gathering and stopping
 *  on specified chunk.
 *
 * Note - you can call getcontext() (to continue after a stop chunk) or
 *  nextcontext() (after IFFERR_EOC, to parse next form in the same file)
 *  if you wish to continue parsing the same IFF file.  If parseifile()
 *  has to delve into a complex format to find your desired FORM, the
 *  pi->hunt flag will be set.  This should be a signal to you that
 *  you may not have the capability to simply modify and rewrite
 *  the data you have gathered.
 *
 * Returns 0 for success else and IFFERR (libraries/iffparse.h)
 */ 

LONG parseifile(pi,groupid,grouptype,propchks,collectchks,stopchks)
struct	ParseInfo *pi;
LONG groupid, grouptype;
LONG *propchks, *collectchks, *stopchks;
{
struct IFFHandle *iff;	
register struct ContextNode	*cn;
LONG			error = 0L;


	D(bug("parseifile:\n")); 

    	if(!(iff=pi->iff))	return(CLIENT_ERROR);

	if(!iff->iff_Stream)	return(IFFERR_READ);

	pi->hunt = FALSE;

	/*
	 * Declare property, collection and stop chunks.
	 */
	if (propchks)
	  if (error = PropChunks (iff, propchks, chkcnt(propchks)))
		return (error);
	if (collectchks)
	  if (error =
	      CollectionChunks(iff, collectchks, chkcnt(collectchks)))
		return (error);
	if (stopchks)
	  if (error = StopChunks (iff, stopchks, chkcnt(stopchks)))
		return (error);

	/*
	 * We want to stop at the end of an ILBM context.
	 */
	if (grouptype)
	  if (error = StopOnExit (iff, grouptype, groupid))
		return(error);

	/*
	 * Take first parse step to enter main chunk.
	 */
	if (error = ParseIFF (iff, IFFPARSE_STEP))
		return(error);

	/*
	 * Test the chunk info to see if simple form of type we want (ILBM).
	 */
	if (!(cn = CurrentChunk (iff)))
		{
		/*
		 * This really should never happen.  If it does, it means
		 * our parser is broken.
		 */
		message(SI(MSG_IFFP_NOTOP));
		return(NOFILE);
		}

	if (cn->cn_ID != groupid  ||  cn->cn_Type != grouptype)
		{
		
		D(bug("This is a(n) %.4s.%.4s.  Looking for embedded %.4s's...\n",
		  &cn->cn_Type, &cn->cn_ID, &grouptype));

		pi->hunt = TRUE;	/* Warning - this is a complex file */
		}

	if(!error)	error = getcontext(iff);
	return(error);
}

/* chkcnt
 *
 * simply counts the number of chunk pairs (type,id) in array
 */
LONG chkcnt(LONG *taggedarray)
{
LONG k = 0;

	while(taggedarray[k] != TAG_DONE) k++;
	return(k>>1);
}


/* currentchunkis
 *
 * returns the ID of the current chunk (like ID_CAMG)
 */
LONG currentchunkis(struct IFFHandle *iff, LONG type, LONG id)
{
register struct ContextNode	*cn;
LONG result = 0;

	if (cn = CurrentChunk (iff))
		{
		if((cn->cn_Type == type)&&(cn->cn_ID == id)) result = 1;
		}
	return(result);
}


/* contextis
 *
 * returns the enclosing context of the current chunk (like ID_ILBM)
 */
LONG contextis(struct IFFHandle *iff, LONG type, LONG id)
{
register struct ContextNode	*cn;
LONG result = 0;

       if (cn = (CurrentChunk (iff)))
           {
           if (cn = (ParentChunk(cn)))
               {
               if((cn->cn_Type == type)&&(cn->cn_ID == id)) result = 1;
               }
	   }

	D(bug("This is a %.4s %.4s\n",&cn->cn_Type,&cn->cn_ID));

	return(result);
}


/* getcontext()
 *
 * Continues to gather the context which was specified to parseifile(),
 *  stopping at specified stop chunk, or end of context, or EOF
 *
 * Returns 0 (stopped on a stop chunk)
 *      or IFFERR_EOC (end of context, not an error)
 *      or IFFER_EOF (end of file)
 */
LONG getcontext(iff)
struct	IFFHandle *iff;
{
	LONG error = 0L;

	/* Based on our parse initialization,
	 * ParseIFF() will return on a stop chunk (error = 0)
	 * or end of context for an ILBM FORM (error = IFFERR_EOC)
	 * or end of file (error = IFFERR_EOF)
	 */
	return(error = ParseIFF(iff, IFFPARSE_SCAN));
}


/* nextcontext
 *
 * If you have finished parsing and reading your context (IFFERR_EOC),
 *   nextcontext will enter the next context contained in the file
 *   and parse it.
 *
 * Returns 0 or an IFFERR such as IFFERR_EOF (end of file)
 */

LONG nextcontext(iff)
struct	IFFHandle *iff;
{
	LONG error = 0L;

	error = ParseIFF(iff, IFFPARSE_STEP);

	D(bug("nextcontext: Got through next step\n"));

	return(error);
}


/* findpropdata
 *
 * finds specified chunk parsed from IFF file, and
 *   returns pointer to its sp_Data (or 0 for not found)
 */
UBYTE *findpropdata(iff, type, id)
struct IFFHandle	*iff;
LONG type, id;
	{
	register struct StoredProperty	*sp;

	if(sp = FindProp (iff, type, id)) return(sp->sp_Data);
	return(0);
	}


/*
 * File I/O hook functions which the IFF library will call.
 * A return of 0 indicates success (no error).
 *
 * Iffparse.library calls this code via struct Hook and Hook.asm
 */
static LONG
stdio_stream (struct Hook *hook, struct IFFHandle *iff,
			struct IFFStreamCmd *actionpkt)
{
	register FILE	*stream;
	register LONG	nbytes;
	register int	actual;
	register UBYTE	*buf;
	long	len;

	stream	= (FILE *) iff->iff_Stream;
	if(!stream)	return(1);

	nbytes	= actionpkt->sc_NBytes;
	buf	= (UBYTE *) actionpkt->sc_Buf;

	switch (actionpkt->sc_Command) {
	case IFFSCC_READ:
		do {
			actual = nbytes > 32767 ? 32767 : nbytes;
			if ((len=fread (buf, 1, actual, stream)) != actual)
				break;
			nbytes -= actual;
			buf += actual;
		} while (nbytes > 0);
		return (nbytes ? IFFERR_READ : 0 );

	case IFFSCC_WRITE:
		do {
			actual = nbytes > 32767 ? 32767 : nbytes;
			if ((len=fwrite (buf, 1, actual, stream)) != actual)
				break;
			nbytes -= actual;
			buf += actual;
		} while (nbytes > 0);
		return (nbytes ? IFFERR_WRITE : 0);

	case IFFSCC_SEEK:
		return ((fseek (stream, nbytes, 1) == -1) ? IFFERR_SEEK : 0);

	default:
		/*  No _INIT or _CLEANUP required.  */
		return (0);
	}
}

/* initiffasstdio (ie. init iff as stdio)
 *
 * sets up hook callback for the file stream handler above
 */
void initiffasstdio (iff)
struct IFFHandle *iff;
{
	extern LONG		HookEntry();
	static struct Hook	stdiohook = {
		{ NULL },
		(ULONG (*)()) HookEntry,
		(ULONG (*)()) stdio_stream,
		NULL
	};

	/*
	 * Initialize the IFF structure to point to the buffered I/O
	 * routines.  Unbuffered I/O is terribly slow.
	 */
	InitIFF (iff, IFFF_FSEEK | IFFF_RSEEK, &stdiohook);
}


/*
 * PutCk
 *
 * Writes one chunk of data to an iffhandle
 *
 */
long PutCk(struct IFFHandle *iff, long id, long size, void *data)
    {
    long error = 0, wlen;

    D(bug("PutCk: asked to push chunk \"%.4s\" ($%lx) length %ld\n",&id,id,size));

    if(error=PushChunk(iff, 0, id, size))
	{
	D(bug("PutCk: PushChunk of %.4s, error = %s, size = %ld\n",
		id, IFFerr(error), id));
	}
    else
	{
	D(bug("PutCk: PushChunk of %.4s, error = %ld\n",&id, error));

	/* Write the actual data */
	if((wlen = WriteChunkBytes(iff,data,size)) != size)
	    {
	    D(bug("WriteChunkBytes error: size = %ld, wrote %ld\n",size,wlen));
	    error = IFFERR_WRITE;
	    }
	else error = PopChunk(iff);
	D(bug("PutCk: After PopChunk - error = %ld\n",error));
	}
    return(error);
    }

