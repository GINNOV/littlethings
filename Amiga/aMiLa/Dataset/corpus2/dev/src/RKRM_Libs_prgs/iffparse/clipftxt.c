;/* clipftxt.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -j73 clipftxt.c
Blink FROM LIB:c.o,clipftxt.o TO clipftxt LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/

/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

/*
*
* clipftxt.c:   Writes ASCII text to clipboard unit as FTXT
*               (All clipboard data must be IFF)
*
* Usage: clipftxt unitnumber
*
* To convert to an example of reading only, comment out #define WRITEREAD
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/iffparse.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* Causes example to write FTXT first, then read it back
 * Comment out to create a reader only
 */
#define WRITEREAD


#define MINARGS 2

/* 2.0 Version string for c:Version to find */
UBYTE vers[] = "\0$VER: clipftxt 37.2";

UBYTE usage[] = "Usage: clipftxt unitnumber (use zero for primary unit)";

/*
 * Text error messages for possible IFFERR_#? returns from various
 * IFF routines.  To get the index into this array, take your IFFERR code,
 * negate it, and subtract one.
 *  idx = -error - 1;
 */
char    *errormsgs[] = {
        "End of file (not an error).",
        "End of context (not an error).",
        "No lexical scope.",
        "Insufficient memory.",
        "Stream read error.",
        "Stream write error.",
        "Stream seek error.",
        "File is corrupt.",
        "IFF syntax error.",
        "Not an IFF file.",
        "Required call-back hook missing.",
        "Return to client.  You should never see this."
};

#define RBUFSZ 512

#define  ID_FTXT        MAKE_ID('F','T','X','T')
#define  ID_CHRS        MAKE_ID('C','H','R','S')

struct Library *IFFParseBase;

UBYTE mytext[]="This FTXT written to clipboard by clipftxt example.\n";

void main(int argc, char **argv)
{
    struct IFFHandle    *iff = NULL;
    struct ContextNode  *cn;
    long                error=0, unitnumber=0, rlen;
    int textlen;
    UBYTE readbuf[RBUFSZ];

        /* if not enough args or '?', print usage */
        if(((argc)&&(argc<MINARGS))||(argv[argc-1][0]=='?'))
                {
                printf("%s\n",usage);
                exit(RETURN_WARN);
                }

        unitnumber = atoi(argv[1]);

        if (!(IFFParseBase = OpenLibrary ("iffparse.library", 0L)))
                {
                puts("Can't open iff parsing library.");
                goto bye;
                }

        /*
         * Allocate IFF_File structure.
         */
        if (!(iff = AllocIFF ()))
                {
                puts ("AllocIFF() failed.");
                goto bye;
                }

        /*
         * Set up IFF_File for Clipboard I/O.
         */
        if (!(iff->iff_Stream = (ULONG) OpenClipboard (unitnumber)))
                {
                puts ("Clipboard open failed.");
                goto bye;
                }
        else printf("Opened clipboard unit %ld\n",unitnumber);

        InitIFFasClip (iff);

#ifdef WRITEREAD

        /*
         * Start the IFF transaction.
         */
        if (error = OpenIFF (iff, IFFF_WRITE))
                {
                puts ("OpenIFF for write failed.");
                goto bye;
                }

        /*
         * Write our text to the clipboard as CHRS chunk in FORM FTXT
         *
         * First, write the FORM ID (FTXT)
         */
        if(!(error=PushChunk(iff, ID_FTXT, ID_FORM, IFFSIZE_UNKNOWN)))
                {
                /* Now the CHRS chunk ID followed by the chunk data
                 * We'll just write one CHRS chunk.
                 * You could write more chunks.
                 */
                if(!(error=PushChunk(iff, 0, ID_CHRS, IFFSIZE_UNKNOWN)))
                        {
                        /* Now the actual data (the text) */
                        textlen = strlen(mytext);
                        if(WriteChunkBytes(iff, mytext, textlen) != textlen)
                                {
                                puts("Error writing CHRS data.");
                                error = IFFERR_WRITE;
                                }
                        }
                if(!error) error = PopChunk(iff);
                }
        if(!error) error = PopChunk(iff);


        if(error)
                {
                printf ("IFF write failed, error %ld: %s\n",
                        error, errormsgs[-error - 1]);
                goto bye;
                }
        else printf("Wrote text to clipboard as FTXT\n");

        /*
         * Now let's close it, then read it back
         * First close the write handle, then close the clipboard
         */
        CloseIFF(iff);
        if (iff->iff_Stream) CloseClipboard ((struct ClipboardHandle *)
                                                iff->iff_Stream);

        if (!(iff->iff_Stream = (ULONG) OpenClipboard (unitnumber)))
                {
                puts ("Reopen of Clipboard failed.");
                goto bye;
                }
        else printf("Reopened clipboard unit %ld\n",unitnumber);

#endif /* WRITEREAD */

        if (error = OpenIFF (iff, IFFF_READ))
                {
                puts ("OpenIFF for read failed.");
                goto bye;
                }

        /* Tell iffparse we want to stop on FTXT CHRS chunks */
        if (error = StopChunk(iff, ID_FTXT, ID_CHRS))
                {
                puts ("StopChunk failed.");
                goto bye;
                }

        /* Find all of the FTXT CHRS chunks */
        while(1)
                {
                error = ParseIFF(iff,IFFPARSE_SCAN);
                if(error == IFFERR_EOC) continue;       /* enter next context */
                else if(error) break;

                /* We only asked to stop at FTXT CHRS chunks
                 * If no error we've hit a stop chunk
                 * Read the CHRS chunk data
                 */
                cn = CurrentChunk(iff);

                if((cn)&&(cn->cn_Type == ID_FTXT)&&(cn->cn_ID == ID_CHRS))
                        {
                        printf("CHRS chunk contains:\n");
                        while((rlen = ReadChunkBytes(iff,readbuf,RBUFSZ)) > 0)
                                {
                                Write(Output(),readbuf,rlen);
                                }
                        if(rlen < 0)    error = rlen;
                        }
                }

        if((error)&&(error != IFFERR_EOF))
                {
                printf ("IFF read failed, error %ld: %s\n",
                        error, errormsgs[-error - 1]);
                }

bye:
        if (iff) {
                /*
                 * Terminate the IFF transaction with the stream.  Free
                 * all associated structures.
                 */
                CloseIFF (iff);

                /*
                 * Close the clipboard stream
                 */
                if (iff->iff_Stream)
                                CloseClipboard ((struct ClipboardHandle *)
                                                iff->iff_Stream);
                /*
                 * Free the IFF_File structure itself.
                 */
                FreeIFF (iff);
                }
        if (IFFParseBase)       CloseLibrary (IFFParseBase);

        exit (RETURN_OK);
}
