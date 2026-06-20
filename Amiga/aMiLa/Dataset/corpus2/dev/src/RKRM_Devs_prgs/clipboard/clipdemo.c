/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 ***************************************************************************
 *
 * Clipdemo.c
 *
 * Demonstrate use of clipboard I/O.  Uses general functions
 * provided in cbio.c.  Important note: when this code is run 
 * with older versions of the Amiga OS (i.e., before V36) a memory 
 * loss of 536 bytes will occur due to bugs in the clipboard device.
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L+cbio.o
 *
 * Run from CLI only
 */

#include "exec/types.h"
#include "exec/ports.h"
#include "exec/io.h"
#include "exec/memory.h"
#include "devices/clipboard.h"
#include "libraries/dosextens.h"
#include "libraries/dos.h"

#include "cb.h"

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define FORGETIT 0
#define READIT   1
#define WRITEIT  2
#define POSTIT   3

/* prototypes */

int ReadClip( void );           /* Demonstrate reading clipboard data      */
int WriteClip( char * );        /* Demonstrate write to clipboard        */
int PostClip( char * );         /* Demonstrate posting data to clipboard */

void main( USHORT, char **);

char message[] = "\
\nPossible switches are:\n\n\
-r            Read, and output contents of clipboard.\n\
-w [string]   Write string to clipboard.\n\n\
-p [string]   Write string to clipboard using the clipboard POST mechanism.\n\n\
              The Post can be satisfied by reading data from\n\
              the clipboard.  Note that the message may never\n\
              be received if some other application posts, or\n\
              performs an immediate write to the clipboard.\n\n\
              To run this test you must run two copies of this example.\n\
              Use the -p switch with one to post data, and the -r switch\n\
              with another to read the data.\n\n\
              The process can be stopped by using the BREAK command,\n\
              in which case this example checks the CLIP write ID\n\
              to determine if it should write to the clipboard before\n\
              exiting.\n\n";



void main(argc,argv)
USHORT argc;
char **argv;
{

int todo;
char *string;

todo = FORGETIT;

if (argc)     /* from CLI ? */
    {

    /* Very simple code to parse for arguments - will suffice for
     * the sake of this example
     */

    if (argc > 1)
       {
       if (!(strcmp(argv[1],"-r")))
           todo = READIT;
       if (!(strcmp(argv[1],"-w")))
           todo = WRITEIT;
       if (!(strcmp(argv[1],"-p")))
           todo = POSTIT;

       string = NULL;

       if (argc > 2)
           string=argv[2];

       }

    switch (todo)
            {

            case READIT:

                 ReadClip();
                 break;

            case POSTIT:

                 PostClip(string);
                 break;

            case WRITEIT:

                 WriteClip(string);
                 break;

            default:

                 printf("%s",message);
                 break;

            }


    }
}

/*
 * Read, and output FTXT in the clipboard.
 *
 */

ReadClip()
{
struct IOClipReq *ior;
struct cbbuf *buf;


/* Open clipboard.device unit 0 */

if (ior=CBOpen(0L))
    {

    /* Look for FTXT in clipboard */

    if (CBQueryFTXT(ior))
        {

        /* Obtain a copy of the contents of each CHRS chunk */

        while (buf=CBReadCHRS(ior))
              {
              /* Process data */

              printf("%s\n",buf->mem);

              /* Free buffer allocated by CBReadCHRS() */

              CBFreeBuf(buf);
              }

        /* The next call is not really needed if you are sure */
        /* you read to the end of the clip.                   */

        CBReadDone(ior);
        }
    else
        {
        puts("No FTXT in clipboard");
        }

    CBClose(ior);
    }

else
    {
    puts("Error opening clipboard unit 0");
    }

return(0L);
}

/*
 * Write a string to the clipboard
 *
 */

WriteClip(string)
char *string;
{

struct IOClipReq *ior;

if (string == NULL)
    {
    puts("No string argument given");
    return(0L);
    }

/* Open clipboard.device unit 0 */

if (ior = CBOpen(0L))
    {
    if (!(CBWriteFTXT(ior,string)))
        {
        printf("Error writing to clipboard: io_Error = %ld\n",ior->io_Error);
        }
    CBClose(ior);
    }
else
    {
    puts("Error opening clipboard.device");
    }

return(0);
}


/*
 * Write a string to the clipboard using the POST mechanism
 *
 * The POST mechanism can be used by applications which want to
 * defer writing text to the clipboard until another application
 * needs it (by attempting to read it via CMD_READ).  However
 * note that you still need to keep a copy of the data until you
 * receive a SatisfyMsg from the clipboard.device, or your program
 * exits.
 *
 * In most cases it is easier to write the data immediately.
 *
 * If your program receives the SatisfyMsg from the clipboard.device,
 * you MUST write some data.  This is also how you reply to the message.
 *
 * If your program wants to exit before it has received the SatisfyMsg,
 * you must check the io_ClipID field at the time of the post against
 * the current post ID which is obtained by sending the CBD_CURRENTWRITEID
 * command.
 *
 * If the value in io_ClipID (returned by CBD_CURRENTWRITEID) is greater
 * than your post ID, it means that some other application has performed
 * a post, or immediate write after your post, and that you're application
 * will never receive the SatisfyMsg.
 *
 * If the value in io_ClipID (returned by CBD_CURRENTWRITEID) is equal
 * to your post ID, then you must write your data, and send CMD_UPDATE
 * before exiting.
 *
 */

PostClip(string)
char *string;
{

struct MsgPort *satisfy;
struct SatisfyMsg *sm;
struct IOClipReq *ior;
int mustwrite;
ULONG postID;

if (string == NULL)
    {
    puts("No string argument given");
    return(0L);
    }

if (satisfy = CreatePort(0L,0L))
    {

    /* Open clipboard.device unit 0 */

    if (ior = CBOpen(0L))
        {
        mustwrite = FALSE;

        /* Notify clipboard we have data */

        ior->io_Data    = (STRPTR)satisfy;
        ior->io_ClipID  = 0L;
        ior->io_Command = CBD_POST;
        DoIO( (struct IORequest *) ior);

        postID = ior->io_ClipID;

        printf("\nClipID = %ld\n",postID);

        /* Wait for CTRL-C break, or message from clipboard */
        Wait(SIGBREAKF_CTRL_C|(1L << satisfy->mp_SigBit));

        /* see if we got a message, or a break */
        puts("Woke up");


        if (sm = (struct SatisfyMsg *)GetMsg(satisfy))
            {
            puts("Got a message from the clipboard\n");

            /* We got a message - we MUST write some data */
            mustwrite = TRUE;
            }
        else
            {
            /* Determine if we must write before exiting by
             * checking to see if our POST is still valid
             */

            ior->io_Command = CBD_CURRENTWRITEID;
            DoIO( (struct IORequest *) ior);

            printf("CURRENTWRITEID = %ld\n",ior->io_ClipID);

            if (postID >= ior->io_ClipID)
                mustwrite = TRUE;

            }

        /* Write the string of text */

        if (mustwrite)
            {
            if (!(CBWriteFTXT(ior,string)))
                puts("Error writing to clipboard");
            }
        else
            {
            puts("No need to write to clipboard");
            }

        CBClose(ior);
        }
    else
        {
        puts("Error opening clipboard.device");
        }

    DeletePort(satisfy);
    }
else
    {
    puts("Error creating message port");
    }

return(0);
}
