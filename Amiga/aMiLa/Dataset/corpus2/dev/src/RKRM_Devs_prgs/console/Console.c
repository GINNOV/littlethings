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
 *************************************************************************
 *
 * Console.c
 *
 * Example of opening a window and using the console device
 * to send text and control sequences to it.  The example can be
 * easily modified to do additional control sequences.
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L
 *
 * Run from CLI only.
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <devices/console.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>
#include <stdlib.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


/* Note - using two character <CSI> ESC[.  Hex 9B could be used instead */
#define RESETCON  "\033c"
#define CURSOFF   "\033[0 p"
#define CURSON    "\033[ p"
#define DELCHAR   "\033[P"

/* SGR (set graphic rendition) */
#define COLOR02   "\033[32m"
#define COLOR03   "\033[33m"
#define ITALICS   "\033[3m"
#define BOLD      "\033[1m"
#define UNDERLINE "\033[4m"
#define NORMAL    "\033[0m"


/* our functions */
void cleanexit(UBYTE *,LONG);
void cleanup(void);
BYTE OpenConsole(struct IOStdReq *,struct IOStdReq *, struct Window *);
void CloseConsole(struct IOStdReq *);
void QueueRead(struct IOStdReq *, UBYTE *);
UBYTE ConGetChar(struct MsgPort *, UBYTE *);
LONG ConMayGetChar(struct MsgPort *, UBYTE *);
void ConPuts(struct IOStdReq *, UBYTE *);
void ConWrite(struct IOStdReq *, UBYTE *, LONG);
void ConPutChar(struct IOStdReq *, UBYTE);
void main(int argc, char **argv);
struct NewWindow nw =
    {
    10, 10,                           /* starting position (left,top) */
    620,180,                          /* width, height */
    -1,-1,                            /* detailpen, blockpen */
    CLOSEWINDOW,                      /* flags for idcmp */
    WINDOWDEPTH|WINDOWSIZING|
    WINDOWDRAG|WINDOWCLOSE|
    SMART_REFRESH|ACTIVATE,           /* window flags */
    NULL,                             /* no user gadgets */
    NULL,                             /* no user checkmark */
    "Console Test",                   /* title */
    NULL,                             /* pointer to window screen */
    NULL,                             /* pointer to super bitmap */
    100,45,                           /* min width, height */
    640,200,                          /* max width, height */
    WBENCHSCREEN                      /* open on workbench screen */
    };


/* Opens/allocations we'll need to clean up */
struct Library  *IntuitionBase = NULL;
struct Window   *win = NULL;
struct IOStdReq *writeReq = NULL;    /* I/O request block pointer */
struct MsgPort  *writePort = NULL;   /* replyport for writes      */
struct IOStdReq *readReq = NULL;     /* I/O request block pointer */
struct MsgPort  *readPort = NULL;    /* replyport for reads       */
BOOL OpenedConsole = FALSE;

BOOL FromWb;

void main(argc, argv)
int argc;
char **argv;
    {
    struct IntuiMessage *winmsg;
    ULONG signals, conreadsig, windowsig;
    LONG lch;
    SHORT InControl = 0;
    BOOL Done = FALSE;
    UBYTE ch, ibuf;
    UBYTE obuf[200];
    BYTE error;

    FromWb = (argc==0L) ? TRUE : FALSE;

    if(!(IntuitionBase=OpenLibrary("intuition.library",0)))
         cleanexit("Can't open intuition\n",RETURN_FAIL);

    /* Create reply port and io block for writing to console */
    if(!(writePort = CreatePort("RKM.console.write",0)))
         cleanexit("Can't create write port\n",RETURN_FAIL);

    if(!(writeReq = (struct IOStdReq *)
                    CreateExtIO(writePort,(LONG)sizeof(struct IOStdReq))))
         cleanexit("Can't create write request\n",RETURN_FAIL);

    /* Create reply port and io block for reading from console */
    if(!(readPort = CreatePort("RKM.console.read",0)))
         cleanexit("Can't create read port\n",RETURN_FAIL);

    if(!(readReq = (struct IOStdReq *)
                   CreateExtIO(readPort,(LONG)sizeof(struct IOStdReq))))
         cleanexit("Can't create read request\n",RETURN_FAIL);

    /* Open a window */
    if(!(win = OpenWindow(&nw)))
         cleanexit("Can't open window\n",RETURN_FAIL);

    /* Now, attach a console to the window */
    if(error = OpenConsole(writeReq,readReq,win))
         cleanexit("Can't open console.device\n",RETURN_FAIL);
    else OpenedConsole = TRUE;

    /* Demonstrate some console escape sequences */
    ConPuts(writeReq,"Here's some normal text\n");
    sprintf(obuf,"%s%sHere's text in color 3 and italics\n",COLOR03,ITALICS);
    ConPuts(writeReq,obuf);
    ConPuts(writeReq,NORMAL);
    Delay(50);      /* Delay for dramatic demo effect */
    ConPuts(writeReq,"We will now delete this asterisk =*=");
    Delay(50);
    ConPuts(writeReq,"\b\b");  /* backspace twice */
    Delay(50);
    ConPuts(writeReq,DELCHAR); /* delete the character */
    Delay(50);

    QueueRead(readReq,&ibuf); /* send the first console read request */

    ConPuts(writeReq,"\n\nNow reading console\n");
    ConPuts(writeReq,"Type some keys.  Close window when done.\n\n");

    conreadsig = 1 << readPort->mp_SigBit;
    windowsig = 1 << win->UserPort->mp_SigBit;

    while(!Done)
        {
        /* A character, or an IDCMP msg, or both could wake us up */
        signals = Wait(conreadsig|windowsig);

        /* If a console signal was received, get the character */
        if (signals & conreadsig)
            {
            if((lch = ConMayGetChar(readPort,&ibuf)) != -1)
                {
                ch = lch;
                /* Show hex and ascii (if printable) for char we got.
                 * If you want to parse received control sequences, such as
                 * function or Help keys, you would buffer control sequences
                 * as you receive them, starting to buffer whenever you
                 * receive 0x9B (or 0x1B[ for user-typed sequences) and
                 * ending when you receive a valid terminating character
                 * for the type of control sequence you are receiving.
                 * For CSI sequences, valid terminating characters
                 * are generally 0x40 through 0x7E.
                 * In our example, InControl has the following values:
                 * 0 = no, 1 = have 0x1B, 2 = have 0x9B OR 0x1B and [,
                 * 3 = now inside control sequence, -1 = normal end esc,
                 * -2 = non-CSI(no [) 0x1B end esc
                 * NOTE - a more complex parser is required to recognize
                 *  other types of control sequences.
                 */

                /* 0x1B ESC not followed by '[', is not CSI seq */
                if (InControl==1)
                    {
                    if(ch=='[') InControl = 2;
                    else InControl = -2;
                    }

                if ((ch==0x9B)||(ch==0x1B))  /* Control seq starting */
                    {
                    InControl = (ch==0x1B) ? 1 : 2;
                    ConPuts(writeReq,"=== Control Seq ===\n");
                    }

                /* We'll show value of this char we received */
                if (((ch >= 0x1F)&&(ch <= 0x7E))||(ch >= 0xA0))
                   sprintf(obuf,"Received: hex %02x = %c\n",ch,ch);
                else sprintf(obuf,"Received: hex %02x\n",ch);
                ConPuts(writeReq,obuf);

                /* Valid ESC sequence terminator ends an ESC seq */
                if ((InControl==3)&&((ch >= 0x40) && (ch <= 0x7E)))
                    {
                    InControl = -1;
                    }
                if (InControl==2) InControl = 3;
                /* ESC sequence finished (-1 if OK, -2 if bogus) */
                if (InControl < 0)
                    {
                    InControl = 0;
                    ConPuts(writeReq,"=== End Control ===\n");
                    }
                }
            }

        /* If IDCMP messages received, handle them */
        if (signals & windowsig)
            {
            /* We have to ReplyMsg these when done with them */
            while (winmsg = (struct IntuiMessage *)GetMsg(win->UserPort))
                {
                switch(winmsg->Class)
                    {
                    case CLOSEWINDOW:
                      Done = TRUE;
                      break;
                    default:
                      break;
                     }
                ReplyMsg((struct Message *)winmsg);
                }
            }
        }

    /* We always have an outstanding queued read request
     * so we must abort it if it hasn't completed,
     * and we must remove it.
     */
    if(!(CheckIO(readReq)))  AbortIO(readReq);
    WaitIO(readReq);     /* clear it from our replyport */

    cleanup();
    exit(RETURN_OK);
    }

void cleanexit(UBYTE *s,LONG n)
    {
    if(*s & (!FromWb)) printf(s);
    cleanup();
    exit(n);
    }

void cleanup()
    {
    if(OpenedConsole)
       CloseConsole(writeReq);
    if(win)
       CloseWindow(win);
    if(readReq)
       DeleteExtIO(readReq);
    if(readPort)
       DeletePort(readPort);
    if(writeReq)
       DeleteExtIO(writeReq);
    if(writePort)
       DeletePort(writePort);
    if(IntuitionBase)
       CloseLibrary(IntuitionBase);
    }


/* Attach console device to an open Intuition window.
 * This function returns a value of 0 if the console
 * device opened correctly and a nonzero value (the error
 * returned from OpenDevice) if there was an error.
 */
BYTE OpenConsole(writereq, readreq, window)
struct IOStdReq *writereq;
struct IOStdReq *readreq;
struct Window *window;
    {
    BYTE error;

    writereq->io_Data = (APTR) window;
    writereq->io_Length = sizeof(struct Window);
    error = OpenDevice("console.device", 0, writereq, 0);
    readreq->io_Device = writereq->io_Device; /* clone required parts */
    readreq->io_Unit   = writereq->io_Unit;
    return(error);
    }

void CloseConsole(struct IOStdReq *writereq)
    {
    CloseDevice(writereq);
    }

/* Output a single character to a specified console
 */
void ConPutChar(struct IOStdReq *writereq, UBYTE character)
    {
    writereq->io_Command = CMD_WRITE;
    writereq->io_Data = (APTR)&character;
    writereq->io_Length = 1;
    DoIO(writereq);
    /* command works because DoIO blocks until command is done
     * (otherwise ptr to the character could become invalid)
     */
    }


/* Output a stream of known length to a console
 */
void ConWrite(struct IOStdReq *writereq, UBYTE *string, LONG length)
    {
    writereq->io_Command = CMD_WRITE;
    writereq->io_Data = (APTR)string;
    writereq->io_Length = length;
    DoIO(writereq);
    /* command works because DoIO blocks until command is done
     * (otherwise ptr to string could become invalid in the meantime)
     */
    }


/* Output a NULL-terminated string of characters to a console
 */
void ConPuts(struct IOStdReq *writereq,UBYTE *string)
    {
    writereq->io_Command = CMD_WRITE;
    writereq->io_Data = (APTR)string;
    writereq->io_Length = -1;  /* means print till terminating null */
    DoIO(writereq);
    }

/* Queue up a read request to console, passing it pointer
 * to a buffer into which it can read the character
 */
void QueueRead(struct IOStdReq *readreq, UBYTE *whereto)
   {
   readreq->io_Command = CMD_READ;
   readreq->io_Data = (APTR)whereto;
   readreq->io_Length = 1;
   SendIO(readreq);
   }

/* Check if a character has been received.
 * If none, return -1
 */
LONG ConMayGetChar(struct MsgPort *msgport, UBYTE *whereto)
    {
    register temp;
    struct IOStdReq *readreq;

    if (!(readreq = (struct IOStdReq *)GetMsg(msgport))) return(-1);
    temp = *whereto;                /* get the character */
    QueueRead(readreq,whereto);     /* then re-use the request block */
    return(temp);
    }

/* Wait for a character
 */
UBYTE ConGetChar(struct MsgPort *msgport, UBYTE *whereto)
    {
    register temp;
    struct IOStdReq *readreq;

    WaitPort(msgport);
    readreq = (struct IOStdReq *)GetMsg(msgport);
    temp = *whereto;               /* get the character */
    QueueRead(readreq,whereto);    /* then re-use the request block*/
    return((UBYTE)temp);
    }
